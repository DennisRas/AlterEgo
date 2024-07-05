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
local Module = Core:NewModule("DungeonTimer")

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

function Module:OnEnable()
  if not Data.db.global.dungeonTimer then Data.db.global.dungeonTimer = {} end -- TODO: Add this to the defaultCharacrer object/type

  self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
  self:RegisterEvent("CHALLENGE_MODE_DEATH_COUNT_UPDATED")
  self:RegisterEvent("CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN")
  self:RegisterEvent("CHALLENGE_MODE_KEYSTONE_SLOTTED")
  self:RegisterEvent("CHALLENGE_MODE_LEADERS_UPDATE")
  self:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
  self:RegisterEvent("CHALLENGE_MODE_MEMBER_INFO_UPDATED")
  self:RegisterEvent("CHALLENGE_MODE_RESET")
  self:RegisterEvent("CHALLENGE_MODE_START")
  -- self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") -- MDT: Current Pull
  self:RegisterEvent("MYTHIC_PLUS_NEW_WEEKLY_RECORD")
  -- self:RegisterEvent("PLAYER_DEAD") -- MDT: Current Pull
  self:RegisterEvent("PLAYER_ENTERING_WORLD")
  -- self:RegisterEvent("PLAYER_REGEN_ENABLED") -- MDT: Current Pull
  -- self:RegisterEvent("UNIT_THREAT_LIST_UPDATE") -- MDT: Current Pull
  self:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
  -- self:RegisterEvent("SCENARIO_POI_UPDATE")
  self:Render()
end

function Module:OnDisable()
end

-- criteriaString, criteriaType, completed, quantity, totalQuantity, flags, assetID, quantityString, criteriaID, duration, elapsed, criteriaFailed, isWeightedProgress = C_Scenario.GetCriteriaInfo(criteriaIndex)

function Module:GetInstanceData()
  local _, _, _, _, _, _, _, instanceID = GetInstanceInfo()
  local activeKeystoneLevel, activeAffixIDs = C_ChallengeMode.GetActiveKeystoneInfo()
  local activeChallengeMapID = C_ChallengeMode.GetActiveChallengeMapID()
  local _, _, steps = C_Scenario.GetStepInfo()
  local mapName, _, mapTimeLimit = C_ChallengeMode.GetMapUIInfo(activeChallengeMapID)

  return {
    instanceID = instanceID,
    activeKeystoneLevel = activeKeystoneLevel,
    activeAffixIDs = activeAffixIDs,
    activeChallengeMapID = activeChallengeMapID,
    steps = steps,
    mapName = mapName,
    mapTimeLimit = mapTimeLimit,
  }
end

function Module:GetRunData()
  local numDeaths, timeLost = C_ChallengeMode.GetDeathCount()
  local _, elapsedTime = GetWorldElapsedTime(1)
  local mapChallengeModeID, level, time, onTime, keystoneUpgradeLevels, practiceRun, oldOverallDungeonScore, newOverallDungeonScore, IsMapRecord, IsAffixRecord, PrimaryAffix, isEligibleForScore, members = C_ChallengeMode.GetCompletionInfo()

  return {
    numDeaths = numDeaths,
    timeLost = timeLost,
    elapsedTime = elapsedTime,
    mapChallengeModeID = mapChallengeModeID,
    level = level,
    time = time,
    onTime = onTime,
    keystoneUpgradeLevels = keystoneUpgradeLevels,
    practiceRun = practiceRun,
    oldOverallDungeonScore = oldOverallDungeonScore,
    newOverallDungeonScore = newOverallDungeonScore,
    IsMapRecord = IsMapRecord,
    IsAffixRecord = IsAffixRecord,
    PrimaryAffix = PrimaryAffix,
    isEligibleForScore = isEligibleForScore,
    members = members,
  }
end

-- TODO: Move these to the main module?
-- These two events are still relevant even if the DungeonTimer module isn't enabled
function Module:CHALLENGE_MODE_KEYSTONE_SLOTTED()
  if true then return end --TODO: Add setting to enable/disable this
  -- TODO: Close all bags
end

function Module:CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN()
  if true then return end --TODO: Add setting to enable/disable this

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

function Module:CHALLENGE_MODE_COMPLETED()
  local timestamp = GetTime()

  -- TODO: Save run

  Data.db.global.dungeonTimer.currentRun = nil
end

function Module:CHALLENGE_MODE_START()
  -- if Data.db.global.dungeonTimer.currentRun then
  --   self:RestartRun()
  --   return
  -- end

  local timestamp = GetTime()
  local runData = self:GetRunData()
  local instanceData = self:GetInstanceData()

  if runData.time == 0 then
    Data.db.global.dungeonTimer.currentRun = {
      runData = runData,
      instanceData = instanceData
    }
  elseif instanceData.activeChallengeMapID then
  end
end

function Module:RestartRun()
end

function Module:Render()
  if not self.window then
    self.window = Window:New({
      name = "DungeonTimer",
      titlebar = false
    })
  end

  if Data.db.global.dungeonTimer and Data.db.global.dungeonTimer.currentRun then
    self.window:Show()
  else
    self.window:Hide()
  end
end
