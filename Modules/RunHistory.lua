---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

---@class AE_RunHistory : AceModule
local Module = addon.Core:NewModule("RunHistory", "AceEvent-3.0")
addon.RunHistory = Module

function Module:OnInitialize()
  self:Render()
end

function Module:OnEnable()
  -- self:RegisterEvent("PLAYER_DEAD") -- MDT: Current Pull
  -- self:RegisterEvent("PLAYER_REGEN_ENABLED") -- MDT: Current Pull
  -- self:RegisterEvent("SCENARIO_POI_UPDATE")
  -- self:RegisterEvent("CRITERIA_COMPLETE")
  -- self:RegisterEvent("UNIT_THREAT_LIST_UPDATE") -- MDT: Current Pull

  -- TODO
  self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") -- MDT: Current Pull & Death logs
  -- self:RegisterEvent("CHALLENGE_MODE_DEATH_COUNT_UPDATED")
  -- self:RegisterEvent("CHALLENGE_MODE_LEADERS_UPDATE")
  -- self:RegisterEvent("CHALLENGE_MODE_MEMBER_INFO_UPDATED")
  -- self:RegisterEvent("CHALLENGE_MODE_MAPS_UPDATE")
  -- self:RegisterEvent("CHALLENGE_MODE_RESET")
  -- self:RegisterEvent("MYTHIC_PLUS_NEW_WEEKLY_RECORD")
  -- self:RegisterEvent("SCENARIO_CRITERIA_UPDATE")
  -- self:RegisterEvent("WORLD_STATE_TIMER_START")
  -- self:RegisterEvent("WORLD_STATE_TIMER_STOP")
  -- self:RegisterEvent("GROUP_ROSTER_UPDATE")

  self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
  -- self:RegisterEvent("CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN")
  -- self:RegisterEvent("CHALLENGE_MODE_KEYSTONE_SLOTTED")
  self:RegisterEvent("CHALLENGE_MODE_START")
  self:RegisterEvent("ENCOUNTER_END")
  self:RegisterEvent("ENCOUNTER_START")
  self:RegisterEvent("PLAYER_ENTERING_WORLD")

  self:Render()
end

function Module:OnDisable()
  self:UnregisterAllEvents()
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

function Module:GetChallengeData()
  local data = {
    isChallengeModeActive = nil,

    activeKeystoneLevel = nil,
    activeKeystoneAffixIDs = nil,

    activeChallengeModeID = nil,

    challengeModeID = nil,
    challengeModeLevel = nil,
    challengeModeTime = nil,
    challengeModeOnTime = nil,
    challengeModeKeystoneUpgradeLevels = nil,
    challengeModePracticeRun = nil,
    challengeModeOldOverallDungeonScore = nil,
    challengeModeNewOverallDungeonScore = nil,
    challengeModeIsMapRecord = nil,
    challengeModeIsAffixRecord = nil,
    challengeModePrimaryAffix = nil,
    challengeModeisEligibleForScore = nil,
    challengeModeUpgradeMembers = nil,

    instanceName = nil,
    instanceType = nil,
    instanceDifficultyID = nil,
    instanceDifficultyName = nil,
    instanceMaxPlayers = nil,
    instanceDynamicDifficulty = nil,
    instanceIsDynamic = nil,
    instanceID = nil,
    instanceGroupSize = nil,
    instanceLFGDungeonID = nil,

    mapName = nil,
    mapID = nil,
    mapTimeLimit = nil,
    mapTexture = nil,
    mapBackgroundTexture = nil,

    stepCount = nil,

    deathCount = nil,
    deathTimeLost = nil,

    keystoneTimerID = nil,
    keystoneTimerElapsedTime = nil,

    bosses = {},
    trashCount = 0,
  }

  -- TODO: Get Party Members data

  data.isChallengeModeActive = C_ChallengeMode.IsChallengeModeActive()

  local activeKeystoneLevel, activeKeystoneAffixIDs = C_ChallengeMode.GetActiveKeystoneInfo()
  data.activeKeystoneLevel = activeKeystoneLevel
  data.activeKeystoneAffixIDs = activeKeystoneAffixIDs

  local activeChallengeModeID = C_ChallengeMode.GetActiveChallengeMapID() -- Note: Not MapChallengeMode.MapID, but MapChallengeMode.ID
  data.activeChallengeModeID = activeChallengeModeID

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

  if data.activeChallengeModeID then
    local mapName, mapID, mapTimeLimit, mapTexture, mapBackgroundTexture = C_ChallengeMode.GetMapUIInfo(data.activeChallengeModeID)
    if mapName then
      data.mapID = mapID
      data.mapName = mapName
      data.mapTimeLimit = mapTimeLimit
      data.mapTexture = mapTexture
      data.mapBackgroundTexture = mapBackgroundTexture
    end
  end

  local _, _, stepCount = C_Scenario.GetStepInfo()
  data.stepCount = stepCount

  local keystoneTimerID, keystoneTimerElapsedTime, keystoneTimerIsActive = GetKeystoneTimer()
  data.keystoneTimerID = keystoneTimerID
  data.keystoneTimerElapsedTime = keystoneTimerElapsedTime
  data.keystoneTimerIsActive = keystoneTimerIsActive

  local deathCount, deathTimeLost = C_ChallengeMode.GetDeathCount()
  data.deathCount = deathCount
  data.deathTimeLost = deathTimeLost

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
              completedEndTime = 0,
            }
          end
          -- TODO: Check criteriaDuration/elapsed for accurate numbers and potential time offsets
          if not boss.isCompleted then
            if not criteriaCompleted then
              if not boss.isInCombat and self.db.global.runHistory.activeEncounter then
                boss.isInCombat = true
                boss.combatStartTime = challengeModeTime
                boss.numPulls = boss.numPulls + 1
              elseif boss.isInCombat and not self.db.global.runHistory.activeEncounter then
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

function Module:StartRun()
  -- TODO: Start a new session if already in a run?
  local activeRun = self:GetActiveRun()
  if activeRun then
    self:ClearActiveRun()
  end

  local seasonID = addon.Data:GetCurrentSeason()
  -- local data = self:GetChallengeData()
  local instanceName, instanceType, instanceDifficultyID, instanceDifficultyName, instanceMaxPlayers, instanceDynamicDifficulty, instanceIsDynamic, instanceID, instanceGroupSize, instanceLFGDungeonID = GetInstanceInfo()
  local activeKeystoneLevel, activeKeystoneAffixIDs = C_ChallengeMode.GetActiveKeystoneInfo()
  local isChallengeModeActive = C_ChallengeMode.IsChallengeModeActive()
  local challengeModeID = C_ChallengeMode.GetActiveChallengeMapID()

  if not challengeModeID or not isChallengeModeActive then return end -- Bug
  local mapName, mapID, mapTimeLimit, mapTexture, mapBackgroundTexture = C_ChallengeMode.GetMapUIInfo(challengeModeID)

  local startTimestamp = GetServerTime()
  local keystoneTimerID, keystoneTimerElapsedTime, keystoneTimerIsActive = GetKeystoneTimer()
  if keystoneTimerIsActive then
    startTimestamp = startTimestamp - keystoneTimerElapsedTime
  end

  ---@type AE_RH_Run
  local run = {
    id = format("%s:%d:%d:%d", instanceType, instanceID, instanceDifficultyID, GetServerTime()),
    seasonID = seasonID,
    startTimestamp = GetServerTime(),
    updateTimestamp = GetServerTime(),
    endTimestamp = nil,
    state = "RUNNING",
    affixes = activeKeystoneAffixIDs,
    members = {},
    events = {},
    loot = {},

    -- isChallengeModeActive = C_ChallengeMode.IsChallengeModeActive(),

    -- activeKeystoneLevel = activeKeystoneLevel,
    -- activeKeystoneAffixIDs = activeKeystoneAffixIDs,
    -- activeChallengeModeID = C_ChallengeMode.GetActiveChallengeMapID(),

    challengeModeTimers = {0, 0, 0},

    challengeModeID = challengeModeID,
    challengeModeLevel = activeKeystoneLevel,
    challengeModeTime = nil,
    challengeModeOnTime = nil,
    challengeModeKeystoneUpgradeLevels = nil,
    challengeModePracticeRun = nil,
    challengeModeOldOverallDungeonScore = nil,
    challengeModeNewOverallDungeonScore = nil,
    challengeModeIsMapRecord = nil,
    challengeModeIsAffixRecord = nil,
    challengeModePrimaryAffix = nil,
    challengeModeisEligibleForScore = nil,
    challengeModeUpgradeMembers = nil,

    instanceName = instanceName,
    instanceType = instanceType,
    instanceDifficultyID = instanceDifficultyID,
    instanceDifficultyName = instanceDifficultyName,
    instanceMaxPlayers = instanceMaxPlayers,
    instanceDynamicDifficulty = instanceDynamicDifficulty,
    instanceIsDynamic = instanceIsDynamic,
    instanceID = instanceID,
    instanceGroupSize = instanceGroupSize,
    instanceLFGDungeonID = instanceLFGDungeonID,

    mapID = mapID,
    mapName = mapName,
    mapTimeLimit = mapTimeLimit,
    mapTexture = mapTexture,
    mapBackgroundTexture = mapBackgroundTexture,

    stepCount = nil,

    deathCount = nil,
    deathTimeLost = nil,

    keystoneTimerID = keystoneTimerID,
    keystoneTimerElapsedTime = keystoneTimerElapsedTime,
    keystoneTimerIsActive = keystoneTimerIsActive,

    bosses = {},
    trashCount = 0,
    objectives = {},
  }

  local _, _, stepCount = C_Scenario.GetStepInfo()
  run.stepCount = stepCount

  table.insert(addon.Data.db.global.runHistory.runs, run)

  self:SetActiveRun(run.id)
  self:UpdateRun()

  return run
end

function Module:EndRun()
  local run = self:GetActiveRun()
  if not run then return end

  -- TODO: Set more data after a run is complete
  run.endTimestamp = GetServerTime()

  self:UpdateRun()
  self:SetActiveRun(nil)
end

function Module:UpdateRun()
  -- local data = self:GetChallengeData()
  local run = self:GetActiveRun()
  if not run then return end

  run.isChallengeModeActive = C_ChallengeMode.IsChallengeModeActive()

  local activeKeystoneLevel, activeKeystoneAffixIDs = C_ChallengeMode.GetActiveKeystoneInfo()
  run.activeKeystoneLevel = activeKeystoneLevel
  run.activeKeystoneAffixIDs = activeKeystoneAffixIDs

  local activeChallengeModeID = C_ChallengeMode.GetActiveChallengeMapID() -- Note: Not MapChallengeMode.MapID, but MapChallengeMode.ID
  run.activeChallengeModeID = activeChallengeModeID

  local challengeModeID, challengeModeLevel, challengeModeTime, challengeModeOnTime, challengeModeKeystoneUpgradeLevels, challengeModePracticeRun, challengeModeOldOverallDungeonScore, challengeModeNewOverallDungeonScore, challengeModeIsMapRecord, challengeModeIsAffixRecord, challengeModePrimaryAffix, challengeModeisEligibleForScore, challengeModeUpgradeMembers = C_ChallengeMode.GetCompletionInfo()
  if challengeModeTime and challengeModeTime > 0 then
    run.challengeModeID = challengeModeID
    run.challengeModeLevel = challengeModeLevel
    run.challengeModeTime = challengeModeTime
    run.challengeModeOnTime = challengeModeOnTime
    run.challengeModeKeystoneUpgradeLevels = challengeModeKeystoneUpgradeLevels
    run.challengeModePracticeRun = challengeModePracticeRun
    run.challengeModeOldOverallDungeonScore = challengeModeOldOverallDungeonScore
    run.challengeModeNewOverallDungeonScore = challengeModeNewOverallDungeonScore
    run.challengeModeIsMapRecord = challengeModeIsMapRecord
    run.challengeModeIsAffixRecord = challengeModeIsAffixRecord
    run.challengeModePrimaryAffix = challengeModePrimaryAffix
    run.challengeModeisEligibleForScore = challengeModeisEligibleForScore
    run.challengeModeUpgradeMembers = challengeModeUpgradeMembers
  end

  -- local instanceName, instanceType, instanceDifficultyID, instanceDifficultyName, instanceMaxPlayers, instanceDynamicDifficulty, instanceIsDynamic, instanceID, instanceGroupSize, instanceLFGDungeonID = GetInstanceInfo()
  -- run.instanceName = instanceName
  -- run.instanceType = instanceType
  -- run.instanceDifficultyID = instanceDifficultyID
  -- run.instanceDifficultyName = instanceDifficultyName
  -- run.instanceMaxPlayers = instanceMaxPlayers
  -- run.instanceDynamicDifficulty = instanceDynamicDifficulty
  -- run.instanceIsDynamic = instanceIsDynamic
  -- run.instanceID = instanceID
  -- run.instanceGroupSize = instanceGroupSize
  -- run.instanceLFGDungeonID = instanceLFGDungeonID

  -- if run.activeChallengeModeID then
  --   local mapName, mapID, mapTimeLimit, mapTexture, mapBackgroundTexture = C_ChallengeMode.GetMapUIInfo(run.activeChallengeModeID)
  --   if mapName then
  --     run.mapID = mapID
  --     run.mapName = mapName
  --     run.mapTimeLimit = mapTimeLimit
  --     run.mapTexture = mapTexture
  --     run.mapBackgroundTexture = mapBackgroundTexture
  --   end
  -- end

  -- local _, _, stepCount = C_Scenario.GetStepInfo()
  -- run.stepCount = stepCount

  local keystoneTimerID, keystoneTimerElapsedTime, keystoneTimerIsActive = GetKeystoneTimer()
  run.keystoneTimerID = keystoneTimerID
  run.keystoneTimerElapsedTime = keystoneTimerElapsedTime
  run.keystoneTimerIsActive = keystoneTimerIsActive

  local deathCount, deathTimeLost = C_ChallengeMode.GetDeathCount()
  run.deathCount = deathCount
  run.deathTimeLost = deathTimeLost

  run.bosses = {}
  run.trashCount = 0
  run.objectives = {}
  if run.stepCount and run.stepCount > 0 then
    for stepIndex = 1, run.stepCount do
      table.insert(run.objectives, C_ScenarioInfo.GetCriteriaInfo(stepIndex))
    end
  end



  self:Render()
  -- if stepCount and stepCount > 1 then
  --   for stepIndex = 1, stepCount do
  --     local criteriaString, criteriaType, criteriaCompleted, criteriaQuantity, criteriaTotalQuantity, criteriaFlags, criteriaAssetID, criteriaQuantityString, criteriaID, criteriaDuration, criteriaElapsed, criteriaFailed, criteriaIsWeightedProgress = C_Scenario.GetCriteriaInfo(stepIndex)
  --     if criteriaString then
  --       if stepIndex == stepCount then -- Last step: Trash
  --         local trashCount = criteriaQuantityString and tonumber(strsub(criteriaQuantityString, 1, strlen(criteriaQuantityString) - 1)) or 0
  --         if trashCount > 0 then
  --           run.trashCount = trashCount
  --         end
  --       else
  --         local boss = run.bosses[stepIndex]
  --         if not boss then
  --           boss = {
  --             index = stepIndex,
  --             isInCombat = false,
  --             numPulls = 0,
  --             isCompleted = false,
  --             encounterID = criteriaAssetID,
  --             combatStartTime = 0,
  --             combatEndTime = 0,
  --             completedStartTime = 0,
  --             completedEndTime = 0,
  --           }
  --         end
  --         -- TODO: Check criteriaDuration/elapsed for accurate numbers and potential time offsets
  --         if not boss.isCompleted then
  --           if not criteriaCompleted then
  --             if not boss.isInCombat and self.db.global.runHistory.activeEncounter then
  --               boss.isInCombat = true
  --               boss.combatStartTime = challengeModeTime
  --               boss.numPulls = boss.numPulls + 1
  --             elseif boss.isInCombat and not self.db.global.runHistory.activeEncounter then
  --               boss.isInCombat = false
  --               boss.combatEndTime = challengeModeTime
  --             end
  --           else
  --             boss.isInCombat = false
  --             boss.numPulls = max(1, boss.numPulls)
  --             boss.isCompleted = true
  --             boss.completedStartTime = boss.combatStartTime or challengeModeTime
  --             boss.completedEndTime = boss.combatEndTime or challengeModeTime
  --           end
  --         end

  --         run.bosses[stepIndex] = boss
  --       end
  --     end
  --   end
  -- end




  -- if not run then
  --   if data.isChallengeModeActive then
  --     self:StartRun()
  --     return
  --   end
  -- end


  -- local runData = self:GetChallengeData()
  -- if not addon.Data.db.global.runHistory.activeRun then
  --   if runData.isChallengeModeActive then
  --     return self:StartRun()
  --   end
  -- end


  -- if data.isChallengeModeActive then
  --   run.startTimestamp = run.startTimestamp - data.time
  --   run.challengeModeID = data.activeChallengeModeID
  --   run.affixes = data.activeKeystoneAffixIDs
  --   run.challengeModeLevel = data.activeKeystoneLevel
  -- end

  -- -- TODO: Make use of Open-Raid-library to get spec, talents, gear etc.
  -- if IsInGroup() then
  --   for p = 0, GetNumGroupMembers() do
  --     local unitid = p == 0 and "player" or "party" .. p
  --     local name, server = UnitName(unitid)
  --     local _, _, classID = UnitClass(unitid)
  --     local role = UnitGroupRolesAssigned(unitid)

  --     ---@type AE_RH_RunMember
  --     local member = {
  --       name = name,
  --       realm = server,
  --       classID = classID,
  --       role = role,
  --     }
  --     table.insert(run.members, member)
  --   end
  -- else
  --   -- Solo, really?
  --   local unitid = "player"
  --   local name, server = UnitName(unitid)
  --   local _, _, classID = UnitClass(unitid)
  --   local role = UnitGroupRolesAssigned(unitid)

  --   ---@type AE_RH_RunMember
  --   local member = {
  --     name = name,
  --     realm = server,
  --     classID = classID,
  --     role = role,
  --   }
  --   table.insert(run.members, member)
  -- end
end

---Get the active run
---@return AE_RH_Run|nil
function Module:GetActiveRun()
  if not addon.Data.db.global.runHistory.activeRun then return nil end
  return addon.Utils:TableGet(addon.Data.db.global.runHistory.runs, "id", addon.Data.db.global.runHistory.activeRun)
end

---Set the active run
---@param runID string|nil
function Module:SetActiveRun(runID)
  addon.Data.db.global.runHistory.activeRun = runID
end

function Module:ClearActiveRun()
  self:SetActiveRun(nil)
end

-- Todo: This is gonna suck
function Module:DetectAbandon()
end

function Module:COMBAT_LOG_EVENT_UNFILTERED(...)
  local run = self:GetActiveRun()
  if not run then return end

  local timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
  if subEvent == "UNIT_DIED" and destGUID and string.find(destGUID, "Player") and not UnitIsFeignDeath(destGUID) then
    local _, _, classID = UnitClass(destGUID)
    ---@type AE_RH_Event
    local event = {
      timestamp = timestamp,
      type = "PLAYER_DEATH",
      text = format("%s has died.", destName),
      data = {
        sourceGUID = sourceGUID,
        sourceName = sourceName,
        sourceFlags = sourceFlags,
        destGUID = destGUID,
        destName = destName,
        destFlags = destFlags,
      },
    }
    -- activeRun.numDeaths = activeRun.numDeaths + 1
    -- activeRun.timeLost = activeRun.timeLost + timeLost
    table.insert(run.events, event)
  end

  self:UpdateRun()
end

function Module:GROUP_ROSTER_UPDATE(...)
  if not self:GetActiveRun() then return end
  -- TODO: Check if the run is over
  self:UpdateRun()
end

function Module:CHALLENGE_MODE_START(...)
  self:StartRun()
end

function Module:CHALLENGE_MODE_COMPLETED(...)
  self:EndRun()
end

function Module:PLAYER_ENTERING_WORLD()
  self.window:Show() -- DEV

  local run = self:GetActiveRun()
  if not run then
    if C_ChallengeMode.IsChallengeModeActive() then
      self:StartRun()
    end
  end
  self:UpdateRun()
end

function Module:ENCOUNTER_START(...)
  local _, encounterID = ...
  addon.Data.db.global.runHistory.activeEncounter = encounterID
  self:UpdateRun()
end

function Module:ENCOUNTER_END(...)
  addon.Data.db.global.runHistory.activeEncounter = nil
  self:UpdateRun()
end

function Module:ToggleWindow()
  if not self.window then return end
  self.window:Toggle()
end

local function random_string(k)
  local pw = {}
  for i = 1, k
  do
    if i > 1 then
      local alphabet = "abcdefghijklmnopqrstuvwxyz"
      local n = string.len(alphabet)
      pw[i] = string.byte(alphabet, math.random(n))
    else
      local alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
      local n = string.len(alphabet)
      pw[i] = string.byte(alphabet, math.random(n))
    end
  end
  return string.char(unpack(pw))
end

local function random_player(isTank, isHealer)
  isTank = isTank or false
  isHealer = isHealer or false
  local color = WHITE_FONT_COLOR
  local classes = {}
  if isTank then
    classes = {"PALADIN", "DRUID", "WARRIOR", "DEATHKNIGHT", "MONK", "DEMONHUNTER"}
  elseif isHealer then
    classes = {"PRIEST", "PALADIN", "DRUID", "SHAMAN", "MONK"}
  else
    classes = {"HUNTER", "WARLOCK", "PRIEST", "PALADIN", "MAGE", "ROGUE", "DRUID", "SHAMAN", "WARRIOR", "DEATHKNIGHT", "MONK", "DEMONHUNTER"}
  end
  local randomClass = classes[math.random(#classes)]
  if randomClass then
    color = RAID_CLASS_COLORS[randomClass]
  end
  local name = random_string(math.random(8, 14))
  return color:WrapTextInColorCode(name)
end

---Open run details
---@param run AE_RH_Run
function Module:ShowRun(run)
  self.selectedRun = run
  if not self.windowRun then return end
  self.windowRun:Show()
  self:RenderRunHistory()
end

function Module:Render()
  self:RenderRun()
  self:RenderRunHistory()
end

function Module:RenderRun()
  if not self.windowRun then
    self.windowRun = addon.Window:New({
      name = "RunDetails",
      title = "Run Details",
    })
    self.windowRun:SetBodySize(600, 400)
    self.windowRun:SetScript("OnShow", function()
      self:RenderRun()
    end)

    local rowHeight = 26
    self.windowRun.infoTable = addon.Table:New({
      header = {
        enabled = false,
      },
      rows = {
        height = rowHeight,
        striped = true,
        highlight = false,
      },
      cells = {
        padding = 10,
        highlight = false,
      },
    })
    self.windowRun.infoTable:SetParent(self.windowRun)
    self.windowRun.infoTable:SetPoint("TOPLEFT", self.windowRun, "TOPLEFT", 0, -30)
    self.windowRun.infoTable:SetSize(300, 240)

    -- self.windowRun.textLeft = self.windowRun:CreateFontString()
    -- self.windowRun.textLeft:SetPoint("TOPLEFT", self.windowRun, "TOPLEFT", 10, -40)
    -- self.windowRun.textLeft:SetSize(150, 300)
    -- self.windowRun.textLeft:SetFontObject("GameFontHighlight")
    -- self.windowRun.textLeft:SetText("")
    -- self.windowRun.textLeft:SetJustifyH("LEFT")
    -- self.windowRun.textLeft:SetJustifyV("TOP")
    -- self.windowRun.textLeft:SetTextHeight(11)
    -- self.windowRun.textLeft:SetSpacing(3)

    -- self.windowRun.textRight = self.windowRun:CreateFontString()
    -- self.windowRun.textRight:SetPoint("TOPLEFT", self.windowRun, "TOPLEFT", 170, -40)
    -- self.windowRun.textRight:SetSize(150, 300)
    -- self.windowRun.textRight:SetFontObject("GameFontHighlight")
    -- self.windowRun.textRight:SetText("")
    -- self.windowRun.textRight:SetJustifyH("LEFT")
    -- self.windowRun.textRight:SetJustifyV("TOP")
    -- self.windowRun.textRight:SetTextHeight(11)
    -- self.windowRun.textRight:SetSpacing(3)

    self.windowRun.tabBody = CreateFrame("Frame", nil, self.windowRun)
    self.windowRun.tabBody:SetPoint("BOTTOMLEFT", self.windowRun, "BOTTOMLEFT", 10, 10)
    self.windowRun.tabBody:SetSize(280, 120)
    addon.Utils:SetBackgroundColor(self.windowRun.tabBody, 0, 0, 0, 0.25)
    -- self.windowRun.tabBody.content = addon.Utils:CreateScrollFrame({
    --   parent = self.windowRun.tabBody,
    -- })
    -- self.windowRun.tabBody.content:SetAllPoints()

    local tabs = {"Events", "Note", "Loot", "Data"}
    addon.Utils:TableForEach(tabs, function(tab, tabIndex)
      local tabFrame = CreateFrame("Frame", nil, self.windowRun)
      local width = self.windowRun.tabBody:GetWidth() / #tabs
      tabFrame:SetSize(width, 26)
      tabFrame:SetPoint("BOTTOMLEFT", self.windowRun.tabBody, "TOPLEFT", width * (tabIndex - 1), 0)
      tabFrame.text = tabFrame:CreateFontString()
      tabFrame.text:SetFontObject("GameFontHighlight")
      tabFrame.text:SetPoint("LEFT", tabFrame, "LEFT", 10, 0)
      tabFrame.text:SetPoint("RIGHT", tabFrame, "RIGHT", -10, 0)
      tabFrame.text:SetText(tab)
      tabFrame.text:SetJustifyH("CENTER")
      tabFrame.text:SetJustifyV("MIDDLE")
      addon.Utils:SetBackgroundColor(tabFrame, 0, 0, 0, tabIndex == 1 and 0.25 or 0.1)
    end)
    -- self.windowRun.tabFirst = CreateFrame("Frame", nil, self.windowRun)
    -- self.windowRun.tabFirst:SetSize(280 / 3, 26)
    -- self.windowRun.tabFirst:SetPoint("BOTTOMLEFT", self.windowRun.tabBody, "TOPLEFT", 0, 0)
    -- self.windowRun.tabFirst.text = self.windowRun.tabFirst:CreateFontString()
    -- self.windowRun.tabFirst.text:SetFontObject("GameFontHighlight")
    -- self.windowRun.tabFirst.text:SetPoint("LEFT", self.windowRun.tabFirst, "LEFT", 10, 0)
    -- self.windowRun.tabFirst.text:SetPoint("RIGHT", self.windowRun.tabFirst, "RIGHT", -10, 0)
    -- self.windowRun.tabFirst.text:SetText("Events")
    -- self.windowRun.tabFirst.text:SetJustifyH("CENTER")
    -- self.windowRun.tabFirst.text:SetJustifyV("MIDDLE")
    -- addon.Utils:SetBackgroundColor(self.windowRun.tabFirst, 0, 0, 0, 0.25)

    -- self.windowRun.tabSecond = CreateFrame("Frame", nil, self.windowRun)
    -- self.windowRun.tabSecond:SetSize(280 / 3, 26)
    -- self.windowRun.tabSecond:SetPoint("BOTTOMLEFT", self.windowRun.tabFirst, "BOTTOMRIGHT", 0, 0)
    -- self.windowRun.tabSecond.text = self.windowRun.tabSecond:CreateFontString()
    -- self.windowRun.tabSecond.text:SetFontObject("GameFontHighlight")
    -- self.windowRun.tabSecond.text:SetPoint("LEFT", self.windowRun.tabSecond, "LEFT", 10, 0)
    -- self.windowRun.tabSecond.text:SetPoint("RIGHT", self.windowRun.tabSecond, "RIGHT", -10, 0)
    -- self.windowRun.tabSecond.text:SetText("Loot")
    -- self.windowRun.tabSecond.text:SetJustifyH("CENTER")
    -- self.windowRun.tabSecond.text:SetJustifyV("MIDDLE")
    -- addon.Utils:SetBackgroundColor(self.windowRun.tabSecond, 0, 0, 0, 0.1)

    -- self.windowRun.tabThird = CreateFrame("Frame", nil, self.windowRun)
    -- self.windowRun.tabThird:SetSize(280 / 3, 26)
    -- self.windowRun.tabThird:SetPoint("BOTTOMLEFT", self.windowRun.tabSecond, "BOTTOMRIGHT", 0, 0)
    -- self.windowRun.tabThird.text = self.windowRun.tabThird:CreateFontString()
    -- self.windowRun.tabThird.text:SetFontObject("GameFontHighlight")
    -- self.windowRun.tabThird.text:SetPoint("LEFT", self.windowRun.tabThird, "LEFT", 10, 0)
    -- self.windowRun.tabThird.text:SetPoint("RIGHT", self.windowRun.tabThird, "RIGHT", -10, 0)
    -- self.windowRun.tabThird.text:SetText("Raw Data")
    -- self.windowRun.tabThird.text:SetJustifyH("CENTER")
    -- self.windowRun.tabThird.text:SetJustifyV("MIDDLE")
    -- addon.Utils:SetBackgroundColor(self.windowRun.tabThird, 0, 0, 0, 0.1)

    self.windowRun.tabBody.text = self.windowRun.tabBody:CreateFontString()
    self.windowRun.tabBody.text:SetPoint("TOPLEFT", self.windowRun.tabBody, "TOPLEFT", 10, -10)
    self.windowRun.tabBody.text:SetPoint("BOTTOMRIGHT", self.windowRun.tabBody, "BOTTOMRIGHT", -10, 10)
    self.windowRun.tabBody.text:SetFontObject("GameFontHighlight")
    self.windowRun.tabBody.text:SetText("|cffaaaaaa00:01:20  |r |cffC69B6DLiquidora|r has died.\n|cffaaaaaa00:05:11  |r Ingra Maloch pulled.\n|cffaaaaaa00:07:56  |r Ingra Maloch killed (2m45s).\n|cffaaaaaa00:22:01  |r |cffC69B6DLiquidora|r has died.\n|cffaaaaaa00:31:21  |r |cffC69B6DLiquidora|r has died.\n")
    self.windowRun.tabBody.text:SetJustifyH("LEFT")
    self.windowRun.tabBody.text:SetJustifyV("TOP")
    self.windowRun.tabBody.text:SetTextHeight(11)
    self.windowRun.tabBody.text:SetSpacing(3)

    self.windowRun.playerBody = CreateFrame("Frame", nil, self.windowRun)
    self.windowRun.playerBody:SetPoint("TOPRIGHT", self.windowRun, "TOPRIGHT", 0, -26 - 30)
    self.windowRun.playerBody:SetPoint("BOTTOMRIGHT", self.windowRun, "BOTTOMRIGHT", 0, 0)
    self.windowRun.playerBody:SetWidth(300)
    addon.Utils:SetBackgroundColor(self.windowRun.playerBody, 0, 0, 0, 0.2)

    for i = 1, 5 do
      local playerTab = CreateFrame("Frame", nil, self.windowRun)
      playerTab:SetSize(60, 26)
      playerTab:SetPoint("BOTTOMLEFT", self.windowRun.playerBody, "TOPLEFT", (i - 1) * 60, 0)
      playerTab.text = playerTab:CreateFontString()
      playerTab.text:SetFontObject("GameFontHighlight")
      playerTab.text:SetPoint("LEFT", playerTab, "LEFT", 10, 0)
      playerTab.text:SetPoint("RIGHT", playerTab, "RIGHT", -10, 0)
      playerTab.text:SetJustifyH("CENTER")
      playerTab.text:SetJustifyV("MIDDLE")
      playerTab.text:SetText(random_player(i == 1, i == 2))
      addon.Utils:SetBackgroundColor(playerTab, 0, 0, 0, i == 1 and 0.2 or 0.1)
    end
  end

  if not self.windowRun:IsVisible() then
    return
  end

  local run = self.selectedRun
  if not run then
    self.windowRun:Hide()
    return
  end

  local affixes = {}
  for a = 13, 13 + math.random(1, 4) do
    local affix = addon.Data.affixes[a]
    table.insert(affixes, affix.fileDataID and "|T" .. affix.fileDataID .. ":16|t " or "")
  end

  local info = {
    ["Dungeon"]   = (run.mapTexture and "|T" .. run.mapTexture .. ":14|t  " or "") .. (run.mapName or "-"),
    ["Level"]     = run.challengeModeLevel,
    ["Affixes"]   = table.concat(affixes, ""),
    ["Time"]      = run.keystoneTimerElapsedTime and SecondsToClock(run.keystoneTimerElapsedTime),
    ["Result"]    = run.state,
    ["Score"]     = run.challengeModeNewOverallDungeonScore and format("%d (+%d)", run.challengeModeNewOverallDungeonScore, run.challengeModeNewOverallDungeonScore - run.challengeModeOldOverallDungeonScore) or 0,
    ["Avg. iLvl"] = 0,
    ["Deaths"]    = run.deathCount,
    ["Date"]      = run.startTimestamp and date("%c", run.startTimestamp),
  }

  ---@type AE_TableData
  local infoTableData = {
    columns = {
      {width = 110},
      {width = 190, align = "right"},
    },
    rows = {},
  }

  addon.Utils:TableForEach(info, function(val, key)
    ---@type AE_TableDataRow
    local row = {
      columns = {
        {text = WrapTextInColorCode(tostring(key) .. ":", "dddddd"), backgroundColor = {r = 0, g = 0, b = 0, a = 0.2}},
        {text = val and tostring(val) or "-"},
      },
    }
    table.insert(infoTableData.rows, row)
  end)

  self.windowRun.infoTable:SetData(infoTableData)
end

function Module:RenderRunHistory()
  local tableWidth = 0
  local tableHeight = 0
  local rowHeight = 24
  local dungeons = addon.Data:GetDungeons()

  if not self.window then
    self.window = addon.Window:New({
      name = "RunHistory",
      title = "Run History",
      sidebar = 200,
    })

    self.window.sidebar.inputSearch = addon.Input:Textbox({parent = self.window.sidebar, value = "", placeholder = "Search..."})
    self.window.sidebar.inputSearch:SetPoint("TOPLEFT", self.window.sidebar, "TOPLEFT", 10, -10)
    self.window.sidebar.inputSearch:SetPoint("TOPRIGHT", self.window.sidebar, "TOPRIGHT", -10, -10)
    self.window.sidebar.inputCharacters = addon.Input:CreateDropdown({parent = self.window.sidebar, value = "", items = {}})
    self.window.sidebar.inputCharacters:SetPoint("TOPLEFT", self.window.sidebar.inputSearch, "BOTTOMLEFT", 0, -10)
    self.window.sidebar.inputCharacters:SetPoint("TOPRIGHT", self.window.sidebar.inputSearch, "BOTTOMRIGHT", 0, -10)
    self.window.sidebar.inputCharacters:SetItems({{value = "", text = "All Characters"}})
    self.window.sidebar.inputInstances = addon.Input:CreateDropdown({parent = self.window.sidebar, value = "", items = {}})
    self.window.sidebar.inputInstances:SetPoint("TOPLEFT", self.window.sidebar.inputCharacters, "BOTTOMLEFT", 0, -10)
    self.window.sidebar.inputInstances:SetPoint("TOPRIGHT", self.window.sidebar.inputCharacters, "BOTTOMRIGHT", 0, -10)
    self.window.sidebar.inputInstances:SetItems({{value = "", text = "All Dungeons"}})
    self.window.sidebar.inputStatus = addon.Input:CreateDropdown({parent = self.window.sidebar, value = "", items = {}})
    self.window.sidebar.inputStatus:SetPoint("TOPLEFT", self.window.sidebar.inputInstances, "BOTTOMLEFT", 0, -10)
    self.window.sidebar.inputStatus:SetPoint("TOPRIGHT", self.window.sidebar.inputInstances, "BOTTOMRIGHT", 0, -10)
    self.window.sidebar.inputStatus:SetItems({{value = "", text = "All Results"}})
    self.window.sidebar.inputAffixes = addon.Input:CreateDropdown({parent = self.window.sidebar, value = "", items = {}})
    self.window.sidebar.inputAffixes:SetPoint("TOPLEFT", self.window.sidebar.inputStatus, "BOTTOMLEFT", 0, -10)
    self.window.sidebar.inputAffixes:SetPoint("TOPRIGHT", self.window.sidebar.inputStatus, "BOTTOMRIGHT", 0, -10)
    self.window.sidebar.inputAffixes:SetItems({{value = "", text = "All Affixes"}})

    self.table = addon.Table:New({
      header = {
        enabled = true,
        sticky = true,
        height = 30,
      },
      rows = {
        height = rowHeight,
        striped = true,
      },
    })
    self.table:SetParent(self.window.body)
    self.table:SetAllPoints()
    self.window:SetScript("OnShow", function()
      self:Render()
    end)
  end

  if not self.window:IsVisible() then
    return
  end

  ---@type AE_TableData
  local data = {
    columns = {
      {width = 80},
      {width = 50,  align = "center"},
      {width = 60,  align = "center"},
      {width = 90},
      {width = 100},
      {width = 120},
      {width = 120},
      {width = 120},
      {width = 300},
      {width = 180, align = "right"},
      {width = 45,  align = "center"},
    },
    rows = {
      {
        columns = {
          {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Dungeon")},
          {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Level")},
          {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Score")},
          {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Time")},
          {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Result")},
          {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Affixes")},
          {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Tank")},
          {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Healer")},
          {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("DPS")},
          {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("")},
          {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Note")},
        },
      },
    },
  }
  tableHeight = tableHeight + 30


  ---@type AE_RH_Run[]
  local runs = addon.Data.db.global.runHistory.runs
  addon.Utils:TableForEach(runs, function(run, runIndex)
    local dungeon = addon.Utils:TableGet(dungeons, "challengeModeID", run.challengeModeID)
    local dungeonName = "-"
    if dungeon then
      dungeonName = dungeon.abbr and dungeon.abbr or dungeon.name
      if dungeon.texture then
        dungeonName = "|T" .. dungeon.texture .. ":14|t  " .. dungeonName
      end
    end
    ---@type AE_TableDataRow
    local row = {
      onClick = function()
        self:ShowRun(run)
      end,
      columns = {
        {text = dungeonName},
        {text = tostring(run.challengeModeLevel)},
        {text = tostring(run.challengeModeNewOverallDungeonScore or 0)},
        {text = SecondsToClock(run.challengeModeTime or run.keystoneTimerElapsedTime or 0)},
        {text = run.state},
        {text = table.concat(run.affixes, "")},
        {text = ""},
        {text = ""},
        {text = ""},
        {text = tostring(date("%c", run.startTimestamp))},
        {text = CreateAtlasMarkup("UI-HUD-MicroMenu-AdventureGuide-" .. (math.random() > 0.8 and "Up" or "Disabled"), 24, 24 * 1.25)},
      },
    }
    table.insert(data.rows, row)
    tableHeight = tableHeight + rowHeight
  end)

  local lastWhen = GetServerTime()
  for i = 1, 2 do
    local when = date("%c", lastWhen)
    lastWhen = lastWhen - math.random(5000, 15000)

    local level = math.random(2, 12)
    local levelText = tostring(level)

    local score = 80 + level * 30
    local scoreText = tostring(score)
    local scoreColor = WHITE_FONT_COLOR

    local time = math.random(500, 2000)
    local timeText = SecondsToClock(time)
    local timeColor = WHITE_FONT_COLOR

    local status = math.random(1, 10)
    local statusText = GREEN_FONT_COLOR:WrapTextInColorCode("Timed")
    local statusColor = WHITE_FONT_COLOR

    local rarityColor = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(score)
    if rarityColor ~= nil then
      scoreColor = rarityColor
    end

    local affixes = {}
    for a = 13, 13 + math.random(1, 4) do
      local affix = addon.Data.affixes[a]
      table.insert(affixes, affix.fileDataID and "|T" .. affix.fileDataID .. ":16|t " or "")
    end

    local dungeon = dungeons[math.random(#dungeons)]
    local dungeonName = "ARAK"
    if dungeon then
      dungeonName = dungeon.texture and "|T" .. dungeon.texture .. ":16|t  " or ""
      dungeonName = dungeonName .. (dungeon.abbr and dungeon.abbr or dungeon.name)
    end

    if status > 9 then
      statusText = "Abandoned"
      scoreText = ""
      timeText = ""
      scoreColor = DIM_RED_FONT_COLOR
      timeColor = DIM_RED_FONT_COLOR
      statusColor = DIM_RED_FONT_COLOR
    elseif status > 7 then
      statusText = "Overtime"
      scoreColor = DISABLED_FONT_COLOR
      timeColor = DISABLED_FONT_COLOR
      statusColor = DISABLED_FONT_COLOR
    else
      statusText = "Timed"
      statusColor = DIM_GREEN_FONT_COLOR

      if time < 800 then
        timeText = timeText .. "  |A:Professions-ChatIcon-Quality-Tier3:16:16:0:0|a"
      elseif time < 1200 then
        timeText = timeText .. "  |A:Professions-ChatIcon-Quality-Tier2:16:16:0:0|a"
      else
        timeText = timeText .. "  |A:Professions-ChatIcon-Quality-Tier1:16:16:0:0|a"
      end
    end

    ---@type AE_TableDataRow
    local row = {
      columns = {
        {text = dungeonName},
        {text = scoreColor:WrapTextInColorCode(levelText)},
        {text = scoreColor:WrapTextInColorCode(scoreText)},
        {text = timeColor:WrapTextInColorCode(timeText)},
        {text = statusColor:WrapTextInColorCode(statusText)},
        {text = table.concat(affixes, "")},
        {text = random_player(true)},
        {text = random_player(false, true)},
        {text = format("%s  %s  %s", random_player(), random_player(), random_player())},
        -- {text = random_player()},
        -- {text = random_player()},
        -- {text = random_player()},
        {text = tostring(when)},
        -- {text = tostring(when) .. "  " .. CreateAtlasMarkup("UI-HUD-MicroMenu-AdventureGuide-" .. (math.random() > 0.8 and "Up" or "Disabled"), 24, 30) .. "  "},
        {text = CreateAtlasMarkup("UI-HUD-MicroMenu-AdventureGuide-" .. (math.random() > 0.8 and "Up" or "Disabled"), 24, 24 * 1.25)},
        -- UI-HUD-MicroMenu-AdventureGuide-Up
      },
    }
    table.insert(data.rows, row)
    tableHeight = tableHeight + rowHeight
  end

  addon.Utils:TableForEach(data.columns, function(col)
    tableWidth = tableWidth + (col.width or 0)
  end)

  self.table:SetData(data)
  self.window:SetBodySize(tableWidth, 400)







  -- ---@type AE_TableData
  -- local tableData = {
  --   columns = {
  --     {width = 100}, -- Date
  --     {width = 100}, -- Dungeon
  --     {width = 100}, -- Level
  --     {width = 100}, -- Time
  --     {width = 100}, -- Affixes
  --     {width = 100}, -- Tank
  --     {width = 100}, -- Healer
  --     {width = 100}, -- DPS
  --     {width = 100}, -- Score
  --     {width = 100}, -- Status
  --   },
  --   rows = {},
  -- }

  -- addon.Utils:TableForEach(addon.Data.db.global.runHistory.runs, function(run)
  --   local dungeon = addon.Utils:TableGet(addon.Data.dungeons, "challengeModeID", run.challengeModeID)
  --   local affixes = addon.Utils:TableMap(run.affixes, function(affixID)
  --     return addon.Utils:TableGet(addon.Data.affixes, "id", affixID)
  --   end)
  --   local tanks = addon.Utils:TableFilter(run.members, function(member) return member.role == "TANK" end)
  --   local healers = addon.Utils:TableFilter(run.members, function(member) return member.role == "HEALER" end)
  --   local dps = addon.Utils:TableFilter(run.members, function(member) return member.role == "DPS" end)
  --   ---@type AE_TableDataRow
  --   local row = {
  --     columns = {
  --       {text = tostring(run.startTimestamp)},
  --       {text = dungeon and dungeon.abbr or "??"},
  --       {text = tostring(run.challengeModeLevel)},
  --       {text = tostring(run.challengeModeTime)}, -- Format seconds to time
  --       {text = table.concat(addon.Utils:TableMap(affixes, function(affix) return affix.name or "??" end), ", ")},
  --       {text = table.concat(addon.Utils:TableMap(tanks, function(member) return member.name or "??" end), ", ")},
  --       {text = table.concat(addon.Utils:TableMap(healers, function(member) return member.name or "??" end), ", ")},
  --       {text = table.concat(addon.Utils:TableMap(dps, function(member) return member.name or "??" end), ", ")},
  --       {text = run.challengeModeNewOverallDungeonScore},
  --       {text = run.status},
  --     },
  --   }
  --   table.insert(tableData.rows, row)
  -- end)

  -- self.window.body.table:SetData(tableData)
end
