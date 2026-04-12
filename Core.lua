---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

--@debug@
_G[addonName] = addon
--@end-debug@

---@class AE_Core : AceAddon
local Core = LibStub("AceAddon-3.0"):NewAddon(addonName, "AceConsole-3.0", "AceTimer-3.0")
addon.Core = Core

addon.Libs = {
  LibDBIcon = LibStub("LibDBIcon-1.0"),
  LibDataBroker = LibStub("LibDataBroker-1.1"),
}

---Initialize the addon
function Core:OnInitialize()
  _G["BINDING_NAME_ALTEREGO"] = "Toggle AlterEgo window"
  _G["BINDING_NAME_ALTEREGOVAULT"] = "Toggle Great Vault window"
  _G["BINDING_NAME_ALTEREGOEQUIPMENT"] = "Toggle Character Equipment window"
  _G["ALTEREGO_TOGGLE_WINDOW"] = self.ToggleWindow
  _G["ALTEREGO_TOGGLE_VAULT"] = self.ToggleVault
  _G["ALTEREGO_TOGGLE_EQUIPMENT"] = self.ToggleEquipment
  self:RegisterChatCommand("ae", function()
    self:ToggleWindow()
  end)
  self:RegisterChatCommand("alterego", function()
    self:ToggleWindow()
  end)
  addon.Data:Initialize()

  local libDataObject = {
    label = addonName,
    type = "launcher",
    icon = addon.Constants.media.Logo,
    OnClick = function(...)
      local mouseButton = select(2, ...)
      local isShiftKeyDown = IsLeftShiftKeyDown() or IsRightShiftKeyDown()
      if mouseButton then
        if mouseButton == "LeftButton" and isShiftKeyDown then
          self:ToggleEquipment()
        elseif mouseButton == "RightButton" then
          self:ToggleVault()
        else
          self:ToggleWindow()
        end
      else
        self:ToggleWindow()
      end
    end,
    OnTooltipShow = function(tooltip)
      tooltip:SetText(addonName, 1, 1, 1)
      tooltip:AddLine("|cff00ff00Left click|r to open AlterEgo.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
      tooltip:AddLine("|cff00ff00Right click|r to open the Great Vault.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
      tooltip:AddLine("|cff00ff00Shift+Left click|r to open your character equipment.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
      local dragText = "|cff00ff00Drag|r to move this icon"
      if addon.Data.db.global.minimap.lock then
        dragText = dragText .. " |cffff0000(locked)|r"
      end
      tooltip:AddLine(dragText .. ".", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
    end,
  }

  addon.Libs.LibDataBroker:NewDataObject(addonName, libDataObject)
  addon.Libs.LibDBIcon:Register(addonName, libDataObject, addon.Data.db.global.minimap)
  addon.Libs.LibDBIcon:AddButtonToCompartment(addonName)

  hooksecurefunc("ResetInstances", function()
    self:OnInstanceReset()
  end)
  self:Render()
end

---Toggle the main window
function Core:ToggleWindow()
  local window = addon.Window:GetWindow("Main")
  if not window then return end
  window:Toggle()
end

---Toggle the vault window
function Core:ToggleVault()
  if WeeklyRewardsFrame and ToggleFrame then
    ToggleFrame(WeeklyRewardsFrame)
  else
    WeeklyRewards_ShowUI()
  end
end

---Toggle the equipment window
function Core:ToggleEquipment()
  local module = addon.Core:GetModule("Equipment", true)
  if not module then return end
  local character = addon.Data:GetCharacter()
  if not character then return end
  module:OpenCharacter(character)
end

---Render all modules
function Core:Render()
  for _, module in addon.Core:IterateModules() do
    if module.Render ~= nil then
      module:Render()
    end
  end
end

---Register event handlers for game data updates
function Core:OnEnable()
  addon.Events:RegisterEvent(
    {
      "PLAYER_EQUIPMENT_CHANGED",
      "UNIT_INVENTORY_CHANGED",
    }, function()
      addon.Data:UpdateCharacterInfo()
      addon.Data:UpdateEquipment()
    end
  )
  addon.Events:RegisterEvent(
    {
      "QUEST_LOG_UPDATE",
    }, function()
      addon.Data:UpdatePreyProgress()
    end
  )
  addon.Events:RegisterEvent(
    {
      "GUILD_ROSTER_UPDATE",
      "PLAYER_GUILD_UPDATE",
    }, function(...)
      addon.Data:UpdateCharacterInfo()
    end
  )
  addon.Events:RegisterEvent(
    {
      "BOSS_KILL",
      "CHALLENGE_MODE_COMPLETED",
      "ENCOUNTER_END",
      "LFG_LOCK_INFO_RECEIVED",
      "RAID_INSTANCE_WELCOME",
    }, function()
      self:RequestGameData()
    end
  )
  addon.Events:RegisterEvent(
    {
      "CHALLENGE_MODE_MAPS_UPDATE",
      "WEEKLY_REWARDS_UPDATE",
    }, function()
      addon.Data:UpdateVault()
    end
  )
  addon.Events:RegisterEvent(
    {
      "LFG_UPDATE_RANDOM_INFO",
      "UPDATE_INSTANCE_INFO",
    }, function()
      addon.Data:UpdateRaidInstances()
    end
  )
  addon.Events:RegisterEvent(
    {
      "BAG_UPDATE_DELAYED",
      "CHALLENGE_MODE_COMPLETED",
      "CHALLENGE_MODE_COMPLETED",
      "CHALLENGE_MODE_MAPS_UPDATE",
      "CHALLENGE_MODE_MAPS_UPDATE",
      "CHALLENGE_MODE_RESET",
      "CHALLENGE_MODE_RESET",
      "ITEM_CHANGED",
      "MYTHIC_PLUS_NEW_WEEKLY_RECORD",
      "MYTHIC_PLUS_NEW_WEEKLY_RECORD",
    }, function()
      addon.Data:UpdateKeystoneItem()
    end
  )
  addon.Events:RegisterEvent(
    {
      "CHALLENGE_MODE_COMPLETED",
      "CHALLENGE_MODE_MAPS_UPDATE",
      "CHALLENGE_MODE_RESET",
      "MYTHIC_PLUS_NEW_WEEKLY_RECORD",
    }, function()
      addon.Data:UpdateMythicPlus()
    end
  )
  addon.Events:RegisterEvent(
    {
      "BONUS_ROLL_RESULT",
      "CHAT_MSG_CURRENCY",
      "CURRENCY_DISPLAY_UPDATE",
      "PLAYER_TRADE_CURRENCY",
      "POST_MATCH_CURRENCY_REWARD_UPDATE",
      "QUEST_CURRENCY_LOOT_RECEIVED",
      "SPELL_CONFIRMATION_PROMPT",
      "TRADE_CURRENCY_CHANGED",
      "TRADE_SKILL_CURRENCY_REWARD_RESULT",
    }, function()
      addon.Data:UpdateCurrencies()
    end
  )
  addon.Events:RegisterEvent(
    {
      "PLAYER_MONEY",
    }, function()
      addon.Data:UpdateMoney()
    end
  )
  addon.Events:RegisterEvent(
    "MYTHIC_PLUS_CURRENT_AFFIX_UPDATE",
    function()
      self:Render()
    end,
    true
  )
  addon.Events:RegisterEvent(
    "CHAT_MSG_SYSTEM",
    function(...)
      self:OnChatMessageSystem(...)
    end,
    true
  )
  addon.Events:RegisterEvent(
    "PLAYER_LEVEL_UP",
    function()
      addon.Data:UpdateDB()
    end,
    true
  )
  self:CheckGameData()
end

---Request game data from the API
function Core:RequestGameData()
  C_MythicPlus.RequestCurrentAffixes()
  C_MythicPlus.RequestMapInfo()
  C_MythicPlus.RequestRewards()
  RequestRaidInfo()
end

---Check if game data is loaded
function Core:CheckGameData()
  local seasonID, seasonDisplayID = addon.Data:GetCurrentSeason()
  if seasonID < 0 or seasonDisplayID < 0 then
    self:RequestGameData()
    self:ScheduleTimer("CheckGameData", 3)
    return
  end

  addon.Data:loadGameData()
  addon.Data:MigrateDB()
  addon.Data:TaskWeeklyReset()
  addon.Data:TaskSeasonReset()
  addon.Data:UpdateDB()
  self:Render()
end

---Handle instance reset
function Core:OnInstanceReset()
  local groupChannel = addon.Utils:GetGroupChannel()
  if not groupChannel or not addon.Data.db.global.announceResets or IsInInstance() or not UnitIsGroupLeader("player") then
    return
  end
  SendChatMessage(addon.Constants.prefix .. "Resetting instances...", groupChannel)
end

---Handle chat message system
---@param _ any
---@param msg string
function Core:OnChatMessageSystem(_, msg)
  local groupChannel = addon.Utils:GetGroupChannel()
  if not groupChannel or not addon.Data.db.global.announceResets or IsInInstance() or not UnitIsGroupLeader("player") then
    return
  end
  local resetPatterns = {INSTANCE_RESET_SUCCESS, INSTANCE_RESET_FAILED, INSTANCE_RESET_FAILED_OFFLINE, INSTANCE_RESET_FAILED_ZONING}
  addon.Utils:TableForEach(resetPatterns, function(resetPattern)
    if msg:match("^" .. resetPattern:gsub("%%s", ".+") .. "$") then
      SendChatMessage(addon.Constants.prefix .. msg, groupChannel)
    end
  end)
end

---Announce keystones to a chat channel
---@param chatType string
function Core:AnnounceKeystones(chatType)
  local characters = addon.Data:GetCharacters()
  local dungeons = addon.Data:GetDungeons()
  local multiline = addon.Data.db.global.announceKeystones.multiline
  local multilineNames = addon.Data.db.global.announceKeystones.multilineNames
  local keystones = {}
  local keystonesCompact = {}

  if addon.Utils:TableCount(characters) < 1 then
    self:Print("You have no characters saved.")
    return
  end

  addon.Utils:TableForEach(characters, function(character)
    local keystone = character.mythicplus.keystone
    local dungeon

    if type(keystone.level) ~= "number" or keystone.level < 1 then
      return
    end

    if type(keystone.challengeModeID) == "number" and keystone.challengeModeID > 0 then
      dungeon = addon.Utils:TableGet(dungeons, "challengeModeID", keystone.challengeModeID)
    elseif type(keystone.mapId) == "number" and keystone.mapId > 0 then
      dungeon = addon.Utils:TableGet(dungeons, "mapId", keystone.mapId)
    end

    if not dungeon then
      return
    end

    local text = dungeon.abbr .. " +" .. tostring(keystone.level)
    table.insert(keystones, {
      text = text,
      itemLink = keystone.itemLink,
      characterName = character.info.name,
    })
    table.insert(keystonesCompact, text)
  end)

  if addon.Utils:TableCount(keystones) < 1 then
    self:Print("You have no keystones saved.")
    return
  end

  if multiline then
    SendChatMessage(addon.Constants.prefix .. "My keystones:", chatType)
    addon.Utils:TableForEach(keystones, function(keystone)
      local chatMessage = keystone.itemLink and keystone.itemLink or keystone.text
      if multilineNames == true then
        chatMessage = keystone.characterName .. ": " .. chatMessage
      end
      SendChatMessage(chatMessage, chatType)
    end)
    return
  end

  SendChatMessage(addon.Constants.prefix .. "My keystones: " .. table.concat(keystonesCompact, " || "), chatType)
end
