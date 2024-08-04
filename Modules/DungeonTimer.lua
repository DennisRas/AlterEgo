---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

local Utils = addon.Utils
local Table = addon.Table
local Window = addon.Window
local Core = addon.Core
local Data = addon.Data
local Constants = addon.Constants
local Input = addon.Input
local Module = Core:NewModule("DungeonTimer", "AceEvent-3.0", "AceTimer-3.0")

function Module:OnInitialize()
  self:WindowRender()
end

function Module:OnEnable()
  self:RegisterEvent("PLAYER_ENTERING_WORLD", "WindowRender")
  self:WindowRender()
end

function Module:OnDisable()
  self:WindowRender()
end

local padding = 10
local fontObject = "SystemFont_Med1"
local fontSpacing = 3

function Module:WindowRender()
  if not self.window then
    self.window = CreateFrame("Frame", "AlterEgoDungeonTimer", UIParent)
    self.window:SetMovable(true)
    self.window:SetUserPlaced(true)
    self.window:EnableMouse(true)
    self.window:SetFrameStrata("HIGH")
    self.window:SetFrameLevel(4000)
    self.window:SetToplevel(true)
    self.window:SetClampedToScreen(true)
    self.window:SetPoint("CENTER")
    self.window:SetScript("OnDragStart", function() self.window:StartMoving() end)
    self.window:SetScript("OnDragStop", function() self.window:StopMovingOrSizing() end)
    self.window.header = CreateFrame("Frame", "$parentHeader", self.window)
    self.window.dungeonName = self.window:CreateFontString("$parentDungeonName", "OVERLAY")
    self.window.dungeonName:SetFontObject("SystemFont_Med2")
    self.window.timer = self.window:CreateFontString("$parentTimer", "OVERLAY")
    self.window.timer:SetFontObject(fontObject)
    self.window.deathCount = self.window:CreateFontString("$parentdeathCount", "OVERLAY")
    self.window.deathCount:SetFontObject(fontObject)
    self.window.trashCount = self.window:CreateFontString("$parenttrashCount", "OVERLAY")
    self.window.trashCount:SetFontObject(fontObject)
    self.window.affixes = CreateFrame("Frame", "$parentAffixes", self.window)
    self.window.progress = CreateFrame("Frame", "$parentProgress", self.window)
    -- self.window.bosslist = CreateFrame("Frame", "$parentbosslist", self.window)
    self.window.bosses = {}
    self.window.status = CreateFrame("Frame", "$parentStatusbar", self.window)
    self.window.buttons = CreateFrame("Frame", "$parentButtons", self.window)
    self.window.buttons.readycheck = Input:Button({
      parent = self.window.buttons,
      text = "/readycheck",
      onClick = function()
        DoReadyCheck()
      end,
      width = 200
    })
    self.window.buttons.countdown = Input:Button({
      parent = self.window.buttons,
      text = "/countdown 10",
      onClick = function()
        C_PartyInfo.DoCountdown(10)
      end,
      width = 200
    })
    self.window.checklist = CreateFrame("Frame", "$parentChecklist", self.window)
    self.window.checklist.header = CreateFrame("Frame", "$parentHeader", self.window.checklist)
    self.window.checklist.header.text = self.window.checklist.header:CreateFontString("$parentText", "OVERLAY")
    self.window.checklist.header.text:SetFontObject("SystemFont_Med2")
    self.window.checklist.header.text:SetPoint("TOPLEFT", self.window.checklist.header, "TOPLEFT", padding, -padding)
    self.window.checklist.header.text:SetPoint("BOTTOMRIGHT", self.window.checklist.header, "BOTTOMRIGHT", -padding, padding)
    self.window.checklist.header.text:SetText("Checklist")
    self.window.checklist.header.text:SetJustifyH("LEFT")
    self.window.checklist.text = self.window.checklist:CreateFontString("$parentText", "OVERLAY")
    self.window.checklist.text:SetFontObject(fontObject)
    self.window.checklist.text:SetPoint("TOPLEFT", self.window.checklist, "TOPLEFT", padding, -padding - 3)
    self.window.checklist.text:SetPoint("BOTTOMRIGHT", self.window.checklist, "BOTTOMRIGHT", -padding, padding)
    self.window.checklist.text:SetJustifyH("LEFT")
    self.window.checklist.text:SetJustifyV("TOP")
    self.window.checklist.text:SetSpacing(fontSpacing)

    -- local pb = CreateFrame("Cooldown", "Test", UIParent)
    -- Utils:SetBackgroundColor(pb, 0, 0, 0, 0.2)
    -- pb:SetPoint("CENTER", UIParent, "CENTER", 400, 0)
    -- pb:SetReverse(true)
    -- pb:SetHideCountdownNumbers(true)
    -- pb:SetRotation(0)
    -- pb:SetSize(200, 200)
    -- pb:SetSwipeColor(1, 1, 1, 1)

    -- pb.text = pb:CreateFontString()
    -- pb.text:SetPoint("CENTER", pb, "CENTER")
    -- pb.text:SetFontObject("SystemFont_Shadow_Large2")
    -- local font, size, style = pb.text:GetFont()
    -- if font then
    --   pb.text:SetFont(font, size * 2.5, style)
    -- end

    -- local currentValue = 0
    -- local maxValue = 180

    -- pb:SetSwipeTexture(Constants.media.ProgressBarCircle);
    -- CooldownFrame_SetDisplayAsPercentage(pb, 0);
    -- C_Timer.NewTicker(0.02, function()
    --   if currentValue > maxValue then
    --     currentValue = 1
    --   else
    --     currentValue = currentValue + 1
    --   end
    --   pb:SetSwipeColor(currentValue / maxValue, 1 - (currentValue / maxValue), 0, 1)
    --   CooldownFrame_SetDisplayAsPercentage(pb, currentValue / maxValue);
    --   pb.text:SetText(SecondsToClock(maxValue - currentValue))
    -- end)
  end

  if not Data.db.global.dungeonTimer.enabled then
    self.window:Hide()
    return
  end

  -- local previewEnabled = Data.db.global.dungeonTimer.preview
  local previewEnabled = false

  local state = {
    windowShown = false,
    windowWidth = 300,
    windowHeight = 0,
    buttonsShown = false,
    dungeonName = "??",
    dungeonLevel = "",
    timer = "",
    deathCount = 2,
    deathCountShown = false,
    bosses = {
      {name = "Boss 1", killed = true,  time = 57 * 4,                                     split = 46},
      {name = "Boss 2", killed = true,  time = 57 * 4 + 45 * 5,                            split = 5},
      {name = "Boss 3", killed = true,  time = 57 * 4 + 45 * 5 + 32 * 6,                   split = -32},
      {name = "Boss 4", killed = false, time = 57 * 4 + 45 * 5 + 32 * 6 + 36 * 5,          split = -130},
      {name = "Boss 5", killed = false, time = 57 * 4 + 45 * 5 + 32 * 6 + 36 * 5 + 52 * 4, split = -221},
    },
    checklist = {
      CreateAtlasMarkup("UI-LFG-RoleIcon-Ready", 14, 14, 0, -2) .. DIM_GREEN_FONT_COLOR:WrapTextInColorCode(" |cffc69b6dLiquidora|r has a |cffa335ee+4 Keystone|r"),
      CreateAtlasMarkup("UI-LFG-RoleIcon-Ready", 14, 14, 0, -2) .. DIM_GREEN_FONT_COLOR:WrapTextInColorCode(" |cffff7c0aShikimi|r has a |cffa335ee+8 Keystone|r"),
      CreateAtlasMarkup("UI-LFG-RoleIcon-Ready", 14, 14, 0, -2) .. DIM_GREEN_FONT_COLOR:WrapTextInColorCode(" Everyone is flasked"),
      CreateAtlasMarkup("UI-LFG-RoleIcon-Ready", 14, 14, 0, -2) .. DIM_GREEN_FONT_COLOR:WrapTextInColorCode(" Everyone is buffed"),
      CreateAtlasMarkup("UI-LFG-RoleIcon-Ready", 14, 14, 0, -2) .. DIM_GREEN_FONT_COLOR:WrapTextInColorCode(" All affixes are covered with talents"),
      CreateAtlasMarkup("UI-LFG-RoleIcon-Decline", 14, 14, 0, -2) .. DIM_RED_FONT_COLOR:WrapTextInColorCode(" |cffc69b6dLiquidora|r does not have an invis potion"),
      CreateAtlasMarkup("UI-LFG-RoleIcon-Decline", 14, 14, 0, -2) .. DIM_RED_FONT_COLOR:WrapTextInColorCode(" |cffc69b6dLiquidora|r needs to repair (23%)"),
      CreateAtlasMarkup("UI-LFG-RoleIcon-Decline", 14, 14, 0, -2) .. DIM_RED_FONT_COLOR:WrapTextInColorCode(" |cffff7c0aShikimi|r is AFK!!!"),
      CreateAtlasMarkup("UI-LFG-RoleIcon-Decline", 14, 14, 0, -2) .. DIM_RED_FONT_COLOR:WrapTextInColorCode(" |cffff7c0aShikimi|r is missing a trinket"),
      CreateAtlasMarkup("UI-LFG-RoleIcon-Decline", 14, 14, 0, -2) .. DIM_RED_FONT_COLOR:WrapTextInColorCode(" |cff33937fInvictoker|r is not in the instance"),
      CreateAtlasMarkup("UI-LFG-RoleIcon-Decline", 14, 14, 0, -2) .. DIM_RED_FONT_COLOR:WrapTextInColorCode(" There has been no ReadyCheck yet"),
    },
  }

  local IsChallengeModeActive = C_ChallengeMode.IsChallengeModeActive()
  local activeKeystoneLevel, activeKeystoneAffixIDs = C_ChallengeMode.GetActiveKeystoneInfo()

  -- local currentRun = self:GetCurrentRun()
  local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()
  local dataDungeon
  if instanceID then
    dataDungeon = Utils:TableGet(Data.dungeons, "mapId", instanceID)
  end

  -- Active run
  if IsChallengeModeActive then
    if dataDungeon then
      state.bosses = {}
      local lastTime = math.random(100, 180)
      Utils:TableForEach(dataDungeon.encounters, function(encounter, encounterIndex)
        lastTime = lastTime + math.random(120, 300)
        table.insert(state.bosses, {
          name = encounter.name,
          killed = encounterIndex <= 2,
          time = lastTime,
          split = math.random(-180, 180),
        })
      end)
      state.dungeonName = format("%s +%d", dataDungeon.name, activeKeystoneLevel)
    else
      -- TODO: Show objective tracker data instead
    end
    state.deathCountShown = true
    -- "Dungeon Lobby"
  elseif dataDungeon then
    state.bosses = {}
    state.dungeonName = dataDungeon.name
    state.buttonsShown = true
    state.windowShown = true
    -- Preview mode
  elseif previewEnabled then
    state.dungeonName = "+10 PreviewMode"
    state.deathCountShown = true
    state.windowShown = true
  end

  local windowOffsetY = 0

  -- Header
  local headerHeight = 30
  self.window.header:SetPoint("TOPLEFT", self.window, "TOPLEFT", 0, -windowOffsetY)
  self.window.header:SetPoint("TOPRIGHT", self.window, "TOPRIGHT", 0, -windowOffsetY)
  self.window.header:SetHeight(headerHeight)
  windowOffsetY = windowOffsetY + headerHeight
  Utils:SetBackgroundColor(self.window.header, 0, 0, 0, 0.5)

  -- DungeonName
  self.window.dungeonName:SetParent(self.window.header)
  self.window.dungeonName:SetPoint("TOPLEFT", self.window.header, "TOPLEFT", padding, -padding)
  self.window.dungeonName:SetPoint("BOTTOMLEFT", self.window.header, "BOTTOMLEFT", padding, padding)
  self.window.dungeonName:SetText(state.dungeonName)

  -- DeathCount
  self.window.deathCount:SetParent(self.window.header)
  self.window.deathCount:SetPoint("TOPRIGHT", self.window.header, "TOPRIGHT", 0, -padding)
  self.window.deathCount:SetPoint("BOTTOMRIGHT", self.window.header, "BOTTOMRIGHT", 0, padding)
  self.window.deathCount:SetText(tostring(state.deathCount) .. CreateAtlasMarkup("Warfront-NeutralHero", 32, 32, -5))
  self.window.deathCount:SetShown(state.deathCountShown)

  -- Bosses
  local bossHeight = 22
  -- local bossOffsetY = padding
  Utils:TableForEach(self.window.bosses, function(bossFrame) bossFrame:Hide() end)
  if Utils:TableCount(state.bosses) > 0 then
    windowOffsetY = windowOffsetY + padding
    Utils:TableForEach(state.bosses, function(boss, bossIndex)
      local bossFrame = self.window.bosses[bossIndex]
      if not bossFrame then
        bossFrame = CreateFrame("Frame", "$parentBoss" .. bossIndex, self.window)
        bossFrame:SetHeight(bossHeight)
        bossFrame:SetPoint("TOPLEFT", self.window, "TOPLEFT", 0, -windowOffsetY)
        bossFrame:SetPoint("TOPRIGHT", self.window, "TOPRIGHT", 0, -windowOffsetY)
        bossFrame.textName = bossFrame:CreateFontString("$parentName", "OVERLAY")
        bossFrame.textName:SetFontObject("SystemFont_Shadow_Med2_Outline")
        bossFrame.textName:SetPoint("TOPLEFT", bossFrame, "TOPLEFT", padding, -padding)
        bossFrame.textName:SetPoint("BOTTOMLEFT", bossFrame, "BOTTOMLEFT", padding, padding)
        bossFrame.textName:SetPoint("TOPRIGHT", bossFrame, "TOPRIGHT", -60 * 2 - padding * 4, -padding)
        bossFrame.textName:SetPoint("BOTTOMRIGHT", bossFrame, "BOTTOMRIGHT", -60 * 2 - padding * 4, padding)
        bossFrame.textName:SetJustifyH("LEFT")
        bossFrame.textSplit = bossFrame:CreateFontString("$parentSplit", "OVERLAY")
        bossFrame.textSplit:SetFontObject("SystemFont_Shadow_Med1_Outline")
        bossFrame.textSplit:SetPoint("TOPRIGHT", bossFrame, "TOPRIGHT", -60 - padding * 3, 0)
        bossFrame.textSplit:SetPoint("BOTTOMRIGHT", bossFrame, "BOTTOMRIGHT", -60 - padding * 3, 0)
        bossFrame.textSplit:SetJustifyH("RIGHT")
        bossFrame.textTime = bossFrame:CreateFontString("$parentTime", "OVERLAY")
        bossFrame.textTime:SetFontObject("SystemFont_Shadow_Med2_Outline")
        bossFrame.textTime:SetPoint("TOPRIGHT", bossFrame, "TOPRIGHT", -padding, -padding)
        bossFrame.textTime:SetPoint("BOTTOMRIGHT", bossFrame, "BOTTOMRIGHT", -padding, padding)
        bossFrame.textTime:SetJustifyH("RIGHT")
        self.window.bosses[bossIndex] = bossFrame
      end
      local bossColor = WHITE_FONT_COLOR
      local splitColor = RED_FONT_COLOR
      local splitPrefix = ""
      local timeColor = WHITE_FONT_COLOR
      if boss.killed then
        bossColor = GREEN_FONT_COLOR
        if boss.split < 0 then
          timeColor = GREEN_FONT_COLOR
        else
          timeColor = RED_FONT_COLOR
        end
      end
      if boss.split < 0 then
        splitPrefix = "-"
        splitColor = DIM_GREEN_FONT_COLOR
      else
        splitPrefix = "+"
        splitColor = DIM_RED_FONT_COLOR
      end
      -- bossFrame.textName:SetWidth((bossFrame:GetWidth() / 3) * 2)
      bossFrame.textName:SetText(bossColor:WrapTextInColorCode(boss.name))
      bossFrame.textSplit:SetWidth(60)
      bossFrame.textSplit:SetText(splitColor:WrapTextInColorCode(splitPrefix .. SecondsToClock(math.abs(boss.split))))
      bossFrame.textSplit:SetShown(boss.killed)
      bossFrame.textTime:SetWidth(60)
      bossFrame.textTime:SetText(timeColor:WrapTextInColorCode(SecondsToClock(boss.time)))
      bossFrame:Show()
      windowOffsetY = windowOffsetY + bossHeight
    end)
    windowOffsetY = windowOffsetY + padding
    -- self.window.bosslist:SetPoint("TOPLEFT", self.window, "TOPLEFT", 0, -headerHeight)
    -- self.window.bosslist:SetPoint("TOPRIGHT", self.window, "TOPRIGHT", 0, -headerHeight)
    -- self.window.bosslist:SetHeight(bossHeight)
    -- self.window.bosslist:Show()
    -- windowOffsetY = windowOffsetY + bossOffsetY + padding
  end

  -- Buttons
  local buttonsHeight = 100
  self.window.buttons:SetPoint("TOPLEFT", self.window, "TOPLEFT", 0, -windowOffsetY)
  self.window.buttons:SetPoint("TOPRIGHT", self.window, "TOPRIGHT", 0, -windowOffsetY)
  self.window.buttons:SetHeight(buttonsHeight)
  self.window.buttons:SetShown(state.buttonsShown)
  self.window.buttons.readycheck:SetPoint("CENTER", self.window.buttons, "CENTER", 0, 15)
  self.window.buttons.countdown:SetPoint("CENTER", self.window.buttons, "CENTER", 0, -15)
  if state.buttonsShown then
    windowOffsetY = windowOffsetY + buttonsHeight
  end

  -- Checklist Header
  self.window.checklist.header:SetPoint("TOPLEFT", self.window, "TOPLEFT", 0, -windowOffsetY)
  self.window.checklist.header:SetPoint("TOPRIGHT", self.window, "TOPRIGHT", 0, -windowOffsetY)
  self.window.checklist.header:SetHeight(headerHeight)
  windowOffsetY = windowOffsetY + headerHeight
  Utils:SetBackgroundColor(self.window.checklist.header, 0, 0, 0, 0.5)

  -- Checklist
  local checklistHeight = #state.checklist * (16 + fontSpacing)
  self.window.checklist:SetPoint("TOPLEFT", self.window, "TOPLEFT", 0, -windowOffsetY)
  self.window.checklist:SetPoint("TOPRIGHT", self.window, "TOPRIGHT", 0, -windowOffsetY)
  self.window.checklist:SetHeight(checklistHeight)
  self.window.checklist.text:SetText(table.concat(state.checklist, "\n"))
  windowOffsetY = windowOffsetY + checklistHeight

  -- Window
  self.window:SetSize(state.windowWidth, windowOffsetY)
  self.window:SetShown(state.windowShown)
  Utils:SetBackgroundColor(self.window, 0, 0, 0, 0.7)
end

-- SecondsToClock(): https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/AddOns/Blizzard_SharedXML/TimeUtil.lua#L256
-- local activeEncounter = false

-- if not Data.db.global.dungeonTimer then Data.db.global.dungeonTimer = {} end -- TODO: Add this to the defaultCharacrer object/type

-- self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") -- MDT: Current Pull
-- self:RegisterEvent("PLAYER_DEAD") -- MDT: Current Pull
-- self:RegisterEvent("PLAYER_REGEN_ENABLED") -- MDT: Current Pull
-- self:RegisterEvent("SCENARIO_POI_UPDATE")
-- self:RegisterEvent("CRITERIA_COMPLETE")
-- self:RegisterEvent("UNIT_THREAT_LIST_UPDATE") -- MDT: Current Pull

-- TODO
-- self:RegisterEvent("CHALLENGE_MODE_DEATH_COUNT_UPDATED")
-- self:RegisterEvent("CHALLENGE_MODE_LEADERS_UPDATE")
-- self:RegisterEvent("CHALLENGE_MODE_MEMBER_INFO_UPDATED")
-- self:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
-- self:RegisterEvent("CHALLENGE_MODE_RESET")
-- self:RegisterEvent("MYTHIC_PLUS_NEW_WEEKLY_RECORD")
-- self:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
-- self:RegisterEvent("WORLD_STATE_TIMER_START")
-- self:RegisterEvent("WORLD_STATE_TIMER_STOP")

-- self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
-- self:RegisterEvent("CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN")
-- self:RegisterEvent("CHALLENGE_MODE_KEYSTONE_SLOTTED")
-- self:RegisterEvent("CHALLENGE_MODE_START")
-- self:RegisterEvent("ENCOUNTER_END")
-- self:RegisterEvent("ENCOUNTER_START")
-- self:RegisterEvent("PLAYER_ENTERING_WORLD")

-- self.renderTimer = self:ScheduleRepeatingTimer("Render", 1)

-- function Module:StartCurrentRun()
--   local data = self:GetData()
--   if data.isChallengeModeActive then
--     data.startTimestamp = data.startTimestamp - data.time
--     self:SetCurrentRun(data)
--   end
-- end

-- function Module:GetCurrentRun()
--   return Data.db.global.dungeonTimer.currentRun
-- end

-- function Module:SetCurrentRun(data)
--   Data.db.global.dungeonTimer.currentRun = data
-- end

-- function Module:EndCurrentRun()
--   local currentRun = self:GetCurrentRun()
--   if not currentRun then
--     return
--   end
--   currentRun.endTimestamp = GetServerTime()
--   if Data.db.global.runHistory.enabled then
--     table.insert(Data.db.global.runHistory, currentRun)
--   end
-- end

-- function Module:ClearCurrentRun()
--   self:SetCurrentRun(nil)
-- end

-- function Module:UpdateCurrentRun()
--   local data = self:GetData()
--   local currentRun = self:GetCurrentRun()
--   if not currentRun then
--     if data.isChallengeModeActive then
--       self:StartCurrentRun()
--       return
--     end
--   end


--   local runData = self:GetData()
--   if not Data.db.global.dungeonTimer.currentRun then
--     if runData.isChallengeModeActive then
--       return self:StartCurrentRun()
--     end
--   end
-- end

-- function Module:CHALLENGE_MODE_START(...)
--   local currentRun = self:GetCurrentRun()
--   if currentRun then
--     self:ClearCurrentRun()
--   end
--   self:StartCurrentRun()
-- end

-- function Module:CHALLENGE_MODE_COMPLETED(...)
--   local currentRun = self:GetCurrentRun()
--   if not currentRun then
--     return
--   end
--   currentRun.completedTimestamp = GetServerTime()

--   self:EndCurrentRun()
-- end

-- function Module:PLAYER_ENTERING_WORLD()
--   -- self:UpdateCurrentRun()
--   self:WindowRender()
-- end

-- function Module:ENCOUNTER_START(...)
--   local _, encounterID = ...
--   activeEncounter = encounterID
--   -- self:UpdateCurrentRun()
--   self:WindowRender()
-- end

-- function Module:ENCOUNTER_END(...)
--   activeEncounter = false
--   -- self:UpdateCurrentRun()
--   self:WindowRender()
-- end

-- -- TODO: Move these to the main module?
-- -- These two events are still relevant even if the DungeonTimer module isn't enabled
-- function Module:CHALLENGE_MODE_KEYSTONE_SLOTTED(...)
--   if true then return end --TODO: Add setting to enable/disable this
--   -- TODO: Close all bags
-- end

-- function Module:CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN(...)
--   -- if true then return end --TODO: Add setting to enable/disable this

--   local keystoneItemID = Data:GetKeystoneItemID()
--   for bagID = 0, NUM_BAG_SLOTS do
--     for invID = 1, C_Container.GetContainerNumSlots(bagID) do
--       local itemID = C_Container.GetContainerItemID(bagID, invID)
--       if itemID and itemID == keystoneItemID then
--         local item = ItemLocation:CreateFromBagAndSlot(bagID, invID)
--         if item:IsValid() then
--           local canuse = C_ChallengeMode.CanUseKeystoneInCurrentMap(item)
--           if canuse then
--             C_Container.PickupContainerItem(bagID, invID)
--             C_Timer.After(0.1, function()
--               if CursorHasItem() then
--                 C_ChallengeMode.SlotKeystone()
--               end
--             end)
--             break
--           end
--         end
--       end
--     end
--   end
-- end

-- TODO: Toggle visibilty of the objective tracker frame
-- local function ToggleDefaultTracker()
-- end

-- local function printEvent(...)
--   DevTools_Dump({...})
--   Module:WindowRender()
-- end


-- ---@param timerID number
-- ---@return number? elapsedTime
-- local function GetWorldElapsedTimerForKeystone(timerID)
--   local _, elapsedTime, timerType = GetWorldElapsedTime(timerID)
--   if timerType ~= LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE then
--     return
--   end
--   return elapsedTime
-- end

-- ---@return number? mapChallengeModeID
-- ---@return number? timeLimit
-- local function GetMapInfo()
--   local mapChallengeModeID = C_ChallengeMode.GetActiveChallengeMapID()
--   if not mapChallengeModeID then
--     return nil, nil
--   end
--   local _, _, timeLimit = C_ChallengeMode.GetMapUIInfo(mapChallengeModeID)
--   return mapChallengeModeID, timeLimit
-- end

-- ---@return (number|number[])? mapID, number? timeLimit
-- local function GetKeystoneForInstance()
--   local _, _, difficultyID, _, _, _, _, instanceID = GetInstanceInfo()
--   if not difficultyID then
--     return
--   end
--   local _, _, _, isChallengeMode, _, displayMythic = GetDifficultyInfo(difficultyID)
--   if not isChallengeMode and not displayMythic then
--     return
--   end
--   local mapID = INSTANCE_ID_TO_CHALLENGE_MAP_ID[instanceID]
--   if not mapID then
--     return
--   end
--   local firstMapID = type(mapID) == "table" and mapID[1] or mapID ---@type number
--   local _, _, timeLimit = C_ChallengeMode.GetMapUIInfo(firstMapID)
--   return mapID, timeLimit
-- end

-- ---@return number? mapID, number? timeLimit, number[]? otherMapIDs
-- local function GetKeystoneOrInstanceInfo()
--   local mapChallengeModeID, timeLimit = GetMapInfo()
--   local mapIDs ---@type number[]?
--   if not mapChallengeModeID then
--     local temp, timer = GetKeystoneForInstance()
--     if temp then
--       timeLimit = timer
--       if type(temp) == "table" then
--         mapChallengeModeID = temp[1]
--         mapIDs = temp
--       elseif type(temp) == "number" then
--         mapChallengeModeID = temp
--       end
--     end
--   end
--   return mapChallengeModeID, timeLimit, mapIDs
-- end

-- criteriaString, criteriaType, completed, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, duration, elapsed, criteriaFailed, isWeightedProgress = C_Scenario.GetCriteriaInfo(criteriaIndex)

-- challengeModeActive = C_ChallengeMode.IsChallengeModeActive()

-- function Module:GetActiveRun()
--   local runData = self:GetRunData()
--   if not Data.db.global.dungeonTimer.currentRun then
--     Data.db.global.dungeonTimer.currentRun = runData
--   end
--   Data.db.global.dungeonTimer.currentRun = runData
-- end

-- function Module:Update()
--   local data = {}

--   local instanceName, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, lfgDungeonID = GetInstanceInfo()
--   data.instanceName = instanceName
--   data.instanceType = instanceType
--   data.difficultyID = difficultyID
--   data.difficultyName = difficultyName
--   data.maxPlayers = maxPlayers
--   data.dynamicDifficulty = dynamicDifficulty
--   data.isDynamic = isDynamic
--   data.instanceID = instanceID
--   data.instanceGroupSize = instanceGroupSize
--   data.lfgDungeonID = lfgDungeonID

--   local activeKeystoneLevel, activeAffixIDs = C_ChallengeMode.GetActiveKeystoneInfo()
--   data.activeKeystoneLevel = activeKeystoneLevel
--   data.activeAffixIDs = activeAffixIDs

--   local activeChallengeModeID = C_ChallengeMode.GetActiveChallengeMapID() -- Note: Not MapChallengeMode.MapID, but MapChallengeMode.ID
--   data.activeChallengeModeID = activeChallengeModeID

--   local _, _, steps = C_Scenario.GetStepInfo()
--   data.steps = steps

--   if activeChallengeModeID then
--     local mapName, _, mapTimeLimit = C_ChallengeMode.GetMapUIInfo(activeChallengeModeID)
--     if mapName then
--       data.mapName = mapName
--       data.mapTimeLimit = mapTimeLimit
--     end
--   end

--   local deathCount, deathTimeLost = C_ChallengeMode.GetDeathCount()
--   data.deathCount = deathCount
--   data.deathTimeLost = deathTimeLost

--   local timerID, elapsedTime = GetKeystoneTimer()
--   data.elapsedTime = elapsedTime

--   local mapChallengeModeID, level, time, onTime, keystoneUpgradeLevels, practiceRun, oldOverallDungeonScore, newOverallDungeonScore, IsMapRecord, IsAffixRecord, PrimaryAffix, isEligibleForScore, members = C_ChallengeMode.GetCompletionInfo()
--   data.mapChallengeModeID = mapChallengeModeID
--   data.level = level
--   data.time = time
--   data.onTime = onTime
--   data.keystoneUpgradeLevels = keystoneUpgradeLevels
--   data.practiceRun = practiceRun
--   data.oldOverallDungeonScore = oldOverallDungeonScore
--   data.newOverallDungeonScore = newOverallDungeonScore
--   data.IsMapRecord = IsMapRecord
--   data.IsAffixRecord = IsAffixRecord
--   data.PrimaryAffix = PrimaryAffix
--   data.isEligibleForScore = isEligibleForScore
--   data.members = members

--   data.bosses = {}
--   data.trash = 0
--   if steps and steps > 1 then
--     for stepIndex = 1, steps do
--       local criteriaString, criteriaType, completed, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, duration, elapsed, criteriaFailed, isWeightedProgress = C_Scenario.GetCriteriaInfo(stepIndex)
--       if criteriaString then
--         -- DevTools_Dump({criteriaString, criteriaType, completed, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, duration, elapsed, criteriaFailed, isWeightedProgress})
--         if stepIndex == steps then -- Last step: Trash
--           local trash = quantityString and tonumber(strsub(quantityString, 1, strlen(quantityString) - 1)) or 0
--           if trash > 0 then
--             data.trash = trash
--           end
--         else
--           local boss = data.bosses[stepIndex]
--           if not boss then
--             boss = {
--               index = stepIndex,
--               isInCombat = false,
--               numPulls = 0,
--               isCompleted = false,
--               encounterID = assetID,
--               combatStartTime = 0,
--               combartEndTime = 0,
--               completedStartTime = 0,
--               completedEndTime = 0
--             }
--           end
--           -- TODO: Maybe check criteria duration/elapsed for accurate numbers
--           if not boss.isCompleted then
--             if not completed then
--               if not boss.isInCombat and activeEncounter then
--                 boss.isInCombat = true
--                 boss.combatStartTime = time
--                 boss.numPulls = boss.numPulls + 1
--               elseif boss.isInCombat and not activeEncounter then
--                 boss.isInCombat = false
--                 boss.combatEndTime = time
--               end
--             else
--               boss.isInCombat = false
--               boss.numPulls = max(1, boss.numPulls)
--               boss.isCompleted = true
--               boss.completedStartTime = boss.combatStartTime or time
--               boss.completedEndTime = boss.combatEndTime or time
--             end
--           end

--           data.bosses[stepIndex] = boss
--         end
--       end
--     end
--   end

--   return data
-- end
