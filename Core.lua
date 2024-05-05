local addonName, AlterEgo = ...
local Utils = AlterEgo.Utils
local Data = AlterEgo.Data
local Constants = AlterEgo.Constants
local LibDataBroker = LibStub("LibDataBroker-1.1")
local LibDBIcon = LibStub("LibDBIcon-1.0")

--@debug@
_G.AlterEgo = AlterEgo;
--@end-debug@

local Core = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0", "AceBucket-3.0")
AlterEgo.Core = Core

function Core:OnInitialize()
  _G["BINDING_NAME_ALTEREGO"] = "Show/Hide the window"
  self:RegisterChatCommand("ae", "ToggleWindow")
  self:RegisterChatCommand("alterego", "ToggleWindow")
  Data:Initialize()

  local libDataObject = {
    label = addonName,
    tocname = addonName,
    type = "launcher",
    icon = Constants.media.Logo,
    OnClick = function()
      self:ToggleWindow()
    end,
    OnTooltipShow = function(tooltip)
      tooltip:SetText(addonName, 1, 1, 1)
      tooltip:AddLine("Click to show the character summary.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
      local dragText = "Drag to move this icon"
      if Data.db.global.minimap.lock then
        dragText = dragText .. " |cffff0000(locked)|r"
      end
      tooltip:AddLine(dragText .. ".", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
    end
  }
  LibDataBroker:NewDataObject(addonName, libDataObject)
  LibDBIcon:Register(addonName, libDataObject, Data.db.global.minimap)
  LibDBIcon:AddButtonToCompartment(addonName)
  hooksecurefunc("ResetInstances", function()
    self:OnInstanceReset()
  end)
end

function Core:ToggleWindow()
  local module = self:GetModule("Main")
  if module then
    module:ToggleWindow()
  end
end

function Core:OnEnable()
  -- self:RequestGameData()
  -- self:CheckGameData()
  C_MythicPlus.RequestCurrentAffixes();
  C_MythicPlus.RequestMapInfo()
  C_MythicPlus.RequestRewards()
  RequestRaidInfo()
  Data:MigrateDB()
  Data:TaskWeeklyReset()
  Data:TaskSeasonReset()
end

-- function Core:RequestGameData()
--   C_MythicPlus.RequestCurrentAffixes();
--   C_MythicPlus.RequestMapInfo()
--   C_MythicPlus.RequestRewards()
--   RequestRaidInfo()
-- end

function Core:CheckGameData()
  local seasonID = C_MythicPlus.GetCurrentSeason()
  local currentUIDisplaySeason = C_MythicPlus.GetCurrentUIDisplaySeason()
  if seasonID == nil or seasonID == -1 or currentUIDisplaySeason == nil then
    self:RequestGameData()
    return self:ScheduleTimer("CheckGameData", 1)
  end

  self:RegisterBucketEvent({"BAG_UPDATE_DELAYED", "PLAYER_EQUIPMENT_CHANGED", "UNIT_INVENTORY_CHANGED", "ITEM_CHANGED"}, 3, function()
    Data:UpdateCharacterInfo()
    Data:UpdateKeystoneItem()
  end)
  self:RegisterBucketEvent({"RAID_INSTANCE_WELCOME", "LFG_LOCK_INFO_RECEIVED", "BOSS_KILL"}, 2, RequestRaidInfo)
  self:RegisterEvent("ENCOUNTER_END", RequestRaidInfo)
  self:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE", function()
    -- self:UpdateUI()
  end)
  self:RegisterBucketEvent("WEEKLY_REWARDS_UPDATE", 2, function()
    Data:UpdateVault()
  end)
  self:RegisterBucketEvent({"UPDATE_INSTANCE_INFO", "LFG_UPDATE_RANDOM_INFO"}, 3, function()
    Data:UpdateRaidInstances()
  end)
  self:RegisterBucketEvent({"CHALLENGE_MODE_COMPLETED", "CHALLENGE_MODE_RESET", "CHALLENGE_MODE_MAPS_UPDATE", "MYTHIC_PLUS_NEW_WEEKLY_RECORD"}, 3, function()
    Data:UpdateMythicPlus()
    Data:UpdateKeystoneItem()
  end)
  self:RegisterEvent("PLAYER_LEVEL_UP", function()
    Data:UpdateDB()
  end)
  self:RegisterEvent("CHAT_MSG_SYSTEM", "OnChatMessageSystem")
  self:RegisterBucketEvent({"BONUS_ROLL_RESULT", "QUEST_CURRENCY_LOOT_RECEIVED", "POST_MATCH_CURRENCY_REWARD_UPDATE", "PLAYER_TRADE_CURRENCY", "TRADE_CURRENCY_CHANGED", "TRADE_SKILL_CURRENCY_REWARD_RESULT", "SPELL_CONFIRMATION_PROMPT", "CHAT_MSG_CURRENCY", "CURRENCY_DISPLAY_UPDATE"}, 3, function()
    Data:UpdateCharacterInfo()
  end)

  Data:loadGameData()
  Data:MigrateDB()
  Data:TaskWeeklyReset()
  Data:TaskSeasonReset()
  -- self:CreateUI()
  Data:UpdateDB()
end

function Core:OnInstanceReset()
  local groupChannel = Utils:GetGroupChannel()
  if not groupChannel or not Data.db.global.announceResets or IsInInstance() or not UnitIsGroupLeader("player") then
    return
  end
  SendChatMessage(Constants.prefix .. "Resetting instances...", groupChannel)
end

function Core:OnChatMessageSystem(_, msg)
  local groupChannel = Utils:GetGroupChannel()
  if not groupChannel or not Data.db.global.announceResets or IsInInstance() or not UnitIsGroupLeader("player") then
    return
  end
  local resetPatterns = {INSTANCE_RESET_SUCCESS, INSTANCE_RESET_FAILED, INSTANCE_RESET_FAILED_OFFLINE, INSTANCE_RESET_FAILED_ZONING}
  Utils:TableForEach(resetPatterns, function(resetPattern)
    if msg:match("^" .. resetPattern:gsub("%%s", ".+") .. "$") then
      SendChatMessage(Constants.prefix .. msg, groupChannel)
    end
  end)
end

function Core:AnnounceKeystones(chatType)
  local characters = self:GetCharacters()
  local dungeons = self:GetDungeons()
  local multiline = Data.db.global.announceKeystones.multiline
  local multilineNames = Data.db.global.announceKeystones.multilineNames
  local keystones = {}
  local keystonesCompact = {}

  if Utils:TableCount(characters) < 1 then
    self:Print("No announcement: You have no characters saved.")
    return
  end

  Utils:TableForEach(characters, function(character)
    local keystone = character.mythicplus.keystone
    local dungeon

    if type(keystone.level) ~= "number" or keystone.level < 1 then
      return
    end

    if type(keystone.challengeModeID) == "number" and keystone.challengeModeID > 0 then
      dungeon = Utils:TableGet(dungeons, "challengeModeID", keystone.challengeModeID)
    elseif type(keystone.mapId) == "number" and keystone.mapId > 0 then
      dungeon = Utils:TableGet(dungeons, "mapId", keystone.mapId)
    end

    if not dungeon then
      return
    end

    local text = dungeon.abbr .. " +" .. tostring(keystone.level)
    table.insert(keystones, {
      text = text,
      itemLink = keystone.itemLink,
      characterName = character.info.name
    })
    table.insert(keystonesCompact, text)
  end)

  if Utils:TableCount(keystones) < 1 then
    self:Print("No announcement: You have no keystones saved.")
    return
  end

  if multiline then
    Utils:TableForEach(keystones, function(keystone)
      local chatMessage = keystone.itemLink and keystone.itemLink or keystone.text
      if multilineNames == true then
        chatMessage = keystone.characterName .. ": " .. chatMessage
      end
      SendChatMessage(chatMessage, chatType)
    end)
    return
  end

  SendChatMessage(Constants.prefix .. "My keystones: " .. table.concat(keystonesCompact, " || "), chatType)
end
