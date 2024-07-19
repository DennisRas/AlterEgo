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
local Module = Core:NewModule("DungeonTimer", "AceEvent-3.0", "AceTimer-3.0")

-- SecondsToClock(): https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/AddOns/Blizzard_SharedXML/TimeUtil.lua#L256
local activeEncounter = false

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

function Module:OnEnable()
  if not Data.db.global.dungeonTimer then Data.db.global.dungeonTimer = {} end -- TODO: Add this to the defaultCharacrer object/type

  -- self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") -- MDT: Current Pull
  -- self:RegisterEvent("PLAYER_DEAD") -- MDT: Current Pull
  -- self:RegisterEvent("PLAYER_REGEN_ENABLED") -- MDT: Current Pull
  -- self:RegisterEvent("SCENARIO_POI_UPDATE")
  -- self:RegisterEvent("CRITERIA_COMPLETE")
  -- self:RegisterEvent("UNIT_THREAT_LIST_UPDATE") -- MDT: Current Pull
  self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
  self:RegisterEvent("CHALLENGE_MODE_DEATH_COUNT_UPDATED")
  self:RegisterEvent("CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN")
  self:RegisterEvent("CHALLENGE_MODE_KEYSTONE_SLOTTED")
  self:RegisterEvent("CHALLENGE_MODE_LEADERS_UPDATE")
  self:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
  self:RegisterEvent("CHALLENGE_MODE_MEMBER_INFO_UPDATED")
  self:RegisterEvent("CHALLENGE_MODE_RESET")
  self:RegisterEvent("CHALLENGE_MODE_START")
  self:RegisterEvent("ENCOUNTER_END")
  self:RegisterEvent("ENCOUNTER_START")
  self:RegisterEvent("MYTHIC_PLUS_NEW_WEEKLY_RECORD")
  self:RegisterEvent("PLAYER_ENTERING_WORLD")
  self:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
  self:RegisterEvent("WORLD_STATE_TIMER_START")
  self:RegisterEvent("WORLD_STATE_TIMER_STOP")

  self.renderTimer = self:ScheduleRepeatingTimer("Render", 1)
end

function Module:StartCurrentRun()
  local data = self:GetData()
  if data.isChallengeModeActive then
    data.startTimestamp = data.startTimestamp - data.time
    self:SetCurrentRun(data)
  end
end

function Module:GetCurrentRun()
  return Data.db.global.dungeonTimer.currentRun
end

function Module:SetCurrentRun(data)
  Data.db.global.dungeonTimer.currentRun = data
end

function Module:EndCurrentRun()
  local currentRun = self:GetCurrentRun()
  if not currentRun then
    return
  end
  currentRun.endTimestamp = GetServerTime()
  if Data.db.global.runHistory.enabled then
    table.insert(Data.db.global.runHistory, currentRun)
  end
end

function Module:ClearCurrentRun()
  self:SetCurrentRun(nil)
end

function Module:UpdateCurrentRun()
  local data = self:GetData()
  local currentRun = self:GetCurrentRun()
  if not currentRun then
    if data.isChallengeModeActive then
      self:StartCurrentRun()
      return
    end
  end


  local runData = self:GetData()
  if not Data.db.global.dungeonTimer.currentRun then
    if runData.isChallengeModeActive then
      return self:StartCurrentRun()
    end
  end
end

function Module:CHALLENGE_MODE_START(...)
  local currentRun = self:GetCurrentRun()
  if currentRun then
    self:ClearCurrentRun()
  end
  self:StartCurrentRun()
end

function Module:CHALLENGE_MODE_COMPLETED(...)
  local currentRun = self:GetCurrentRun()
  if not currentRun then
    return
  end
  currentRun.completedTimestamp = GetServerTime()

  self:EndCurrentRun()
end

function Module:PLAYER_ENTERING_WORLD()
  self:UpdateCurrentRun()
end

function Module:ENCOUNTER_START(...)
  local _, encounterID = ...
  activeEncounter = encounterID
  self:UpdateCurrentRun()
end

function Module:ENCOUNTER_END(...)
  activeEncounter = false
  self:UpdateCurrentRun()
end

-- TODO: Move these to the main module?
-- These two events are still relevant even if the DungeonTimer module isn't enabled
function Module:CHALLENGE_MODE_KEYSTONE_SLOTTED(...)
  if true then return end --TODO: Add setting to enable/disable this
  -- TODO: Close all bags
end

function Module:CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN(...)
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

function Module:GetData()
  local data = {}

  -- TODO: Get Party Members data

  data.isChallengeModeActive = C_ChallengeMode.IsChallengeModeActive()

  local instanceName, instanceType, instanceDifficultyID, instanceDifficultyName, instanceMaxPlayers, instanceDynamicDifficulty, instanceIsDynamic, instanceID, instanceGroupSize, instanceLFGDungeonID = GetInstanceInfo()
  data.instanceName = instanceName
  data.instanceType = instanceType
  data.instanceDifficultyID = instanceDifficultyID
  data.instanceDifficultyName = instanceDifficultyName
  data.instanceMaxPlayers = instanceMaxPlayers
  data.instanceDynamicDifficulty = instanceDynamicDifficulty
  data.instanceIsDynamic = instanceIsDynamic
  data.instanceID = instanceID
  data.instanceGroupSize = instanceGroupSize
  data.instanceLFGDungeonID = instanceLFGDungeonID

  local activeKeystoneLevel, activeKeystoneAffixIDs = C_ChallengeMode.GetActiveKeystoneInfo()
  data.activeKeystoneLevel = activeKeystoneLevel
  data.activeKeystoneAffixIDs = activeKeystoneAffixIDs

  local activeChallengeModeID = C_ChallengeMode.GetActiveChallengeMapID() -- Note: Not MapChallengeMode.MapID, but MapChallengeMode.ID
  data.activeChallengeModeID = activeChallengeModeID

  if activeChallengeModeID then
    local mapName, mapID, mapTimeLimit = C_ChallengeMode.GetMapUIInfo(activeChallengeModeID)
    if mapName then
      data.mapName = mapName
      data.mapID = mapID
      data.mapTimeLimit = mapTimeLimit
    end
  end

  local _, _, stepCount = C_Scenario.GetStepInfo()
  data.stepCount = stepCount

  local deathCount, deathTimeLost = C_ChallengeMode.GetDeathCount()
  data.deathCount = deathCount
  data.deathTimeLost = deathTimeLost

  local keystoneTimerID, keystoneTimerElapsedTime = GetKeystoneTimer()
  data.keystoneTimerID = keystoneTimerID
  data.keystoneTimerElapsedTime = keystoneTimerElapsedTime

  local challengeModeID, challengeModeLevel, challengeModeTime, challengeModeOnTime, challengeModeKeystoneUpgradeLevels, challengeModePracticeRun, challengeModeOldOverallDungeonScore, challengeModeNewOverallDungeonScore, challengeModeIsMapRecord, challengeModeIsAffixRecord, challengeModePrimaryAffix, challengeModeisEligibleForScore, challengeModeUpgradeMembers = C_ChallengeMode.GetCompletionInfo()
  data.challengeModeID = challengeModeID
  data.challengeModeLevel = challengeModeLevel
  data.challengeModeTime = challengeModeTime
  data.challengeModeOnTime = challengeModeOnTime
  data.challengeModeKeystoneUpgradeLevels = challengeModeKeystoneUpgradeLevels
  data.challengeModePracticeRun = challengeModePracticeRun
  data.challengeModeOldOverallDungeonScore = challengeModeOldOverallDungeonScore
  data.challengeModeNewOverallDungeonScore = challengeModeNewOverallDungeonScore
  data.challengeModeIsMapRecord = challengeModeIsMapRecord
  data.challengeModeIsAffixRecord = challengeModeIsAffixRecord
  data.challengeModePrimaryAffix = challengeModePrimaryAffix
  data.challengeModeisEligibleForScore = challengeModeisEligibleForScore
  data.challengeModeUpgradeMembers = challengeModeUpgradeMembers

  data.bosses = {}
  data.trashCount = 0
  if stepCount and stepCount > 1 then
    for stepIndex = 1, stepCount do
      local criteriaString, criteriaType, criteriaCompleted, criteriaQuantity, criteriaTotalQuantity, criteriaFlags, criteriaAssetID, criteriaQuantityString, criteriaID, criteriaDuration, criteriaElapsed, criteriaFailed, criteriaIsWeightedProgress = C_Scenario.GetCriteriaInfo(stepIndex)
      if criteriaString then
        -- DevTools_Dump({criteriaString, criteriaType, completed, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, duration, elapsed, criteriaFailed, isWeightedProgress})
        if stepIndex == stepCount then -- Last step: Trash
          local trashCount = criteriaQuantityString and tonumber(strsub(criteriaQuantityString, 1, strlen(criteriaQuantityString) - 1)) or 0
          if trashCount > 0 then
            data.trashCount = trashCount
          end
        else
          local boss = data.bosses[stepIndex]
          if not boss then
            boss = {
              index = stepIndex,
              isInCombat = false,
              numPulls = 0,
              isCompleted = false,
              encounterID = criteriaAssetID,
              combatStartTime = 0,
              combatEndTime = 0,
              completedStartTime = 0,
              completedEndTime = 0
            }
          end
          -- TODO: Check criteriaDuration/elapsed for accurate numbers and potential time offsets
          if not boss.isCompleted then
            if not criteriaCompleted then
              if not boss.isInCombat and activeEncounter then
                boss.isInCombat = true
                boss.combatStartTime = challengeModeTime
                boss.numPulls = boss.numPulls + 1
              elseif boss.isInCombat and not activeEncounter then
                boss.isInCombat = false
                boss.combatEndTime = challengeModeTime
              end
            else
              boss.isInCombat = false
              boss.numPulls = max(1, boss.numPulls)
              boss.isCompleted = true
              boss.completedStartTime = boss.combatStartTime or challengeModeTime
              boss.completedEndTime = boss.combatEndTime or challengeModeTime
            end
          end

          data.bosses[stepIndex] = boss
        end
      end
    end
  end

  return data
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

  if not Data.db.global.dungeonTimer.enabled then
    self.window:Hide()
    return
  end

  local currentRun = self:GetCurrentRun()
  local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()
  local dungeon
  if instanceID then
    dungeon = Utils:TableGet(Data.dungeons, "mapID", instanceID)
  end

  if currentRun then
    self.window:SetTitle(format("%s +%d", dungeon and dungeon.abbr or "??", currentRun.activeKeystoneLevel))
    self.window:Show()
  elseif dungeon then
    self.window:SetTitle(dungeon and dungeon.abbr or "??")
    self.window:Show()
  elseif Data.db.global.dungeonTimer.preview then
    self.window:SetTitle("Preview")
    self.window:Show()
  end
end

-- TODO: Toggle visibilty of the objective tracker frame
local function ToggleDefaultTracker()
end

local function printEvent(...)
  DevTools_Dump({...})
  Module:Render()
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
