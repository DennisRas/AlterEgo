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
local Module = Core:NewModule("DungeonTimer", "AceEvent-3.0")

-- TODO: Add hour format and each segment optional
---Create a MM:SS string
---@param time number
---@return string
local function FormatTime(time)
  local timeMin = math.floor(time / 60)
  local timeSec = math.floor(time - (timeMin * 60))
  return ("%01d:%01d"):format(timeMin, timeSec)
end

-- TODO: Toggle visibilty of the objective tracker frame
local function ToggleDefaultTracker()
end

local function printEvent(...)
  -- DevTools_Dump({...})
  Module:Render()
end

---@param stopTimer? boolean
---@param stopTimerID? number
---@return number? timerID, number? elapsedTime, boolean? isActive
local function GetKeystoneTimer(stopTimer, stopTimerID)
  local timerIDs = {GetWorldElapsedTimers()} ---@type number[]
  for _, timerID in ipairs(timerIDs) do
    local _, elapsedTime, timerType = GetWorldElapsedTime(timerID)
    if timerType == LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE and elapsedTime then
      return timerID, elapsedTime, not stopTimer or stopTimerID ~= timerID
    end
  end
end

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

function Module:OnEnable()
  if not Data.db.global.dungeonTimer then Data.db.global.dungeonTimer = {} end -- TODO: Add this to the defaultCharacrer object/type

  -- self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") -- MDT: Current Pull
  -- self:RegisterEvent("PLAYER_DEAD") -- MDT: Current Pull
  -- self:RegisterEvent("PLAYER_REGEN_ENABLED") -- MDT: Current Pull
  -- self:RegisterEvent("SCENARIO_POI_UPDATE")
  -- self:RegisterEvent("UNIT_THREAT_LIST_UPDATE") -- MDT: Current Pull
  self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
  self:RegisterEvent("CHALLENGE_MODE_DEATH_COUNT_UPDATED", printEvent)
  self:RegisterEvent("CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN")
  self:RegisterEvent("CHALLENGE_MODE_KEYSTONE_SLOTTED")
  self:RegisterEvent("CHALLENGE_MODE_LEADERS_UPDATE", printEvent)
  self:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE", printEvent)
  self:RegisterEvent("CHALLENGE_MODE_MEMBER_INFO_UPDATED", printEvent)
  self:RegisterEvent("CHALLENGE_MODE_RESET", printEvent)
  self:RegisterEvent("CHALLENGE_MODE_START")
  self:RegisterEvent("ENCOUNTER_END")
  self:RegisterEvent("ENCOUNTER_START")
  self:RegisterEvent("MYTHIC_PLUS_NEW_WEEKLY_RECORD", printEvent)
  self:RegisterEvent("PLAYER_ENTERING_WORLD", printEvent)
  self:RegisterEvent("SCENARIO_CRITERIA_UPDATE", printEvent)
  self:RegisterEvent("WORLD_STATE_TIMER_START", printEvent)
  self:RegisterEvent("WORLD_STATE_TIMER_STOP", printEvent)
  self:Render()
end

local activeEncounter = false
function Module:ENCOUNTER_START(...)
  printEvent(...)
  local _, encounterID = ...
  activeEncounter = encounterID
end

function Module:ENCOUNTER_END(...)
  printEvent(...)
  -- local eventName, encounterID, encounterName, difficultyID, groupSize, success = ...
  activeEncounter = false
end

function Module:OnDisable()
end

-- criteriaString, criteriaType, completed, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, duration, elapsed, criteriaFailed, isWeightedProgress = C_Scenario.GetCriteriaInfo(criteriaIndex)

function Module:GetRunData()
  local data = {}

  local instanceName, instanceType, difficultyID, difficultyName, maxPlayers, dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, lfgDungeonID = GetInstanceInfo()
  data.instanceName = instanceName
  data.instanceType = instanceType
  data.difficultyID = difficultyID
  data.difficultyName = difficultyName
  data.maxPlayers = maxPlayers
  data.dynamicDifficulty = dynamicDifficulty
  data.isDynamic = isDynamic
  data.instanceID = instanceID
  data.instanceGroupSize = instanceGroupSize
  data.lfgDungeonID = lfgDungeonID

  local activeKeystoneLevel, activeAffixIDs = C_ChallengeMode.GetActiveKeystoneInfo()
  data.activeKeystoneLevel = activeKeystoneLevel
  data.activeAffixIDs = activeAffixIDs

  local activeChallengeMapID = C_ChallengeMode.GetActiveChallengeMapID()
  data.activeChallengeMapID = activeChallengeMapID

  local _, _, steps = C_Scenario.GetStepInfo()
  data.steps = steps

  if activeChallengeMapID then
    local mapName, _, mapTimeLimit = C_ChallengeMode.GetMapUIInfo(activeChallengeMapID)
    if mapName then
      data.mapName = mapName
      data.mapTimeLimit = mapTimeLimit
    end
  end

  local numDeaths, timeLost = C_ChallengeMode.GetDeathCount()
  data.numDeaths = numDeaths
  data.timeLost = timeLost

  local timerID, elapsedTime = GetKeystoneTimer()
  data.elapsedTime = elapsedTime

  local mapChallengeModeID, level, time, onTime, keystoneUpgradeLevels, practiceRun, oldOverallDungeonScore, newOverallDungeonScore, IsMapRecord, IsAffixRecord, PrimaryAffix, isEligibleForScore, members = C_ChallengeMode.GetCompletionInfo()
  data.mapChallengeModeID = mapChallengeModeID
  data.level = level
  data.time = time
  data.onTime = onTime
  data.keystoneUpgradeLevels = keystoneUpgradeLevels
  data.practiceRun = practiceRun
  data.oldOverallDungeonScore = oldOverallDungeonScore
  data.newOverallDungeonScore = newOverallDungeonScore
  data.IsMapRecord = IsMapRecord
  data.IsAffixRecord = IsAffixRecord
  data.PrimaryAffix = PrimaryAffix
  data.isEligibleForScore = isEligibleForScore
  data.members = members

  data.bosses = {}
  data.trash = 0
  if steps and steps > 1 then
    for stepIndex = 1, steps do
      local criteriaString, criteriaType, completed, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, duration, elapsed, criteriaFailed, isWeightedProgress = C_Scenario.GetCriteriaInfo(stepIndex)
      if criteriaString then
        -- DevTools_Dump({criteriaString, criteriaType, completed, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, duration, elapsed, criteriaFailed, isWeightedProgress})
        if stepIndex == steps then -- Last step: Trash
          local trash = quantityString and tonumber(strsub(quantityString, 1, strlen(quantityString) - 1)) or 0
          if trash > 0 then
            data.trash = trash
          end
        else
          local boss = data.bosses[stepIndex]
          if not boss then
            boss = {
              index = stepIndex,
              isInCombat = false,
              numPulls = 0,
              isCompleted = false,
              encounterID = assetID,
              combatStartTime = 0,
              combartEndTime = 0,
              completedStartTime = 0,
              completedEndTime = 0
            }
          end
          -- TODO: Maybe check criteria duration/elapsed for accurate numbers
          if not boss.isCompleted then
            if not completed then
              if not boss.isInCombat and activeEncounter then
                boss.isInCombat = true
                boss.combatStartTime = time
                boss.numPulls = boss.numPulls + 1
              elseif boss.isInCombat and not activeEncounter then
                boss.isInCombat = false
                boss.combatEndTime = time
              end
            else
              boss.isInCombat = false
              boss.numPulls = max(1, boss.numPulls)
              boss.isCompleted = true
              boss.completedStartTime = boss.combatStartTime or time
              boss.completedEndTime = boss.combatEndTime or time
            end
          end

          data.bosses[stepIndex] = boss
        end
      end
    end
  end

  return data
end

-- TODO: Move these to the main module?
-- These two events are still relevant even if the DungeonTimer module isn't enabled
function Module:CHALLENGE_MODE_KEYSTONE_SLOTTED(...)
  printEvent(...)
  if true then return end --TODO: Add setting to enable/disable this
  -- TODO: Close all bags
end

function Module:CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN(...)
  printEvent(...)
  -- if true then return end --TODO: Add setting to enable/disable this

  local keystoneItemID = Data:GetKeystoneItemID()
  for bagID = 0, NUM_BAG_SLOTS do
    for invID = 1, C_Container.GetContainerNumSlots(bagID) do
      local itemID = C_Container.GetContainerItemID(bagID, invID)
      if itemID and itemID == keystoneItemID then
        local item = ItemLocation:CreateFromBagAndSlot(bagID, invID)
        if item:IsValid() then
          local canuse = C_ChallengeMode.CanUseKeystoneInCurrentMap(item)
          if canuse then
            C_Container.PickupContainerItem(bagID, invID)
            C_Timer.After(0.1, function()
              if CursorHasItem() then
                C_ChallengeMode.SlotKeystone()
              end
            end)
            break
          end
        end
      end
    end
  end
end

function Module:UpdateRun()
  local timestamp = GetTime()
  local data = self:GetRunData()
  -- local instanceData = self:GetRunData()

  if data.time == 0 then
    Data.db.global.dungeonTimer.currentRun = {
      data = data,
      -- instanceData = instanceData
    }
    -- elseif instanceData.activeChallengeMapID then
  end
end

function Module:CHALLENGE_MODE_COMPLETED(...)
  printEvent(...)
  local timestamp = GetTime()

  -- TODO: Save run

  Data.db.global.dungeonTimer.currentRun = nil
end

function Module:CHALLENGE_MODE_START(...)
  printEvent(...)
  -- if Data.db.global.dungeonTimer.currentRun then
  --   self:RestartRun()
  --   return
  -- end

  local timestamp = GetTime()
  local data = self:GetRunData()
  -- local instanceData = self:GetRunData()

  if data.time == 0 then
    Data.db.global.dungeonTimer.currentRun = {
      data = data,
      -- instanceData = instanceData
    }
    -- elseif instanceData.activeChallengeMapID then
  end
end

function Module:RestartRun()
end

function Module:Render()
  if not self.window then
    self.window = Window:New({
      name = "DungeonTimer",
      title = "DungeonTimer",
      titlebar = true
    })
  end

  Utils:SetBackgroundColor(self.window, 0, 0, 0, 0)

  self:UpdateRun()
  DevTools_Dump(Data.db.global.dungeonTimer)
  if Data.db.global.dungeonTimer and Data.db.global.dungeonTimer.currentRun then
    local currentRun = Data.db.global.dungeonTimer.currentRun
    local dungeons = Data:GetDungeons()
    local dungeon = Utils:TableGet(dungeons, "challengeModeID", currentRun.data.activeChallengeMapID)
    if dungeon then
      self.window:SetTitle(format("%s +%d", dungeon.abbr, currentRun.data.activeKeystoneLevel))
    end
    self.window:Show()
  else
    self.window:Hide()
  end
end
