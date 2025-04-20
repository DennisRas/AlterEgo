---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

---@class AE_RunHistory : AceModule
local Module = addon.Core:NewModule("RunHistory", "AceEvent-3.0", "AceTimer-3.0")
addon.RunHistory = Module

local RUN_DATE_FORMAT = "%b %d %Y - %H:%M:%S"

---Temp debug print function
---@param data any
local function Debug(data)
  DevTools_Dump(data)
end

---Convert timestamp to human readable text
---@param timestamp number
---@return string
local function human_date(timestamp)
  local diff = time() - timestamp

  if diff < 60 then
    return "Just now"
  elseif diff < 3600 then
    return math.floor(diff / 60) .. " |4minute:minutes; ago"
  elseif diff < 86400 then
    return math.floor(diff / 3600) .. " |4hour:hours; ago"
  elseif diff < 604800 then
    return math.floor(diff / 86400) .. " |4day:days; ago"
  elseif diff < 2592000 then
    return math.floor(diff / 604800) .. " |4week:weeks; ago"
  elseif diff < 31536000 then
    return math.floor(diff / 2592000) .. " |4month:months; ago"
  end

  return tostring(date(RUN_DATE_FORMAT, timestamp))
end

---@param stopTimer? boolean
---@param stopTimerID? number
---@return KeystoneTimer
local function GetKeystoneTimer(stopTimer, stopTimerID)
  Debug("GetKeystoneTimer()")
  local timerIDs = {GetWorldElapsedTimers()} ---@type number[]
  for _, timerID in ipairs(timerIDs) do
    local _, elapsedTime, timerType = GetWorldElapsedTime(timerID)
    if timerType == LE_WORLD_ELAPSED_TIMER_TYPE_CHALLENGE_MODE and elapsedTime then
      local isActive = not stopTimer or stopTimerID ~= timerID
      return {timerID = timerID, elapsedTime = elapsedTime, isActive = isActive}
    end
  end

  return {
    timerID = nil,
    elapsedTime = nil,
    isActive = nil,
  }
end

function Module:OnInitialize()
  Debug("OnInitialize()")
  self:Render()
end

function Module:OnEnable()
  Debug("OnEnable()")
  -- self:RegisterEvent("PLAYER_DEAD") -- MDT: Current Pull
  -- self:RegisterEvent("PLAYER_REGEN_ENABLED") -- MDT: Current Pull
  -- self:RegisterEvent("SCENARIO_POI_UPDATE")
  -- self:RegisterEvent("CRITERIA_COMPLETE")
  -- self:RegisterEvent("UNIT_THREAT_LIST_UPDATE") -- MDT: Current Pull
  -- self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED") -- MDT: Current Pull & Death logs
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
  Debug("OnDisable()")
  self:UnregisterAllEvents()
  self:Render()
end

function Module:GetChallengeData()
  Debug("GetChallengeData()")

  local challengeModeID = C_ChallengeMode.GetActiveChallengeMapID()
  local challengeModeActive = C_ChallengeMode.IsChallengeModeActive()
  local challengeCompletionInfo = C_ChallengeMode.GetChallengeCompletionInfo()
  local activeKeystoneInfo_level, activeKeystoneInfo_affixIDs, activeKeystoneInfo_wasCharged = C_ChallengeMode.GetActiveKeystoneInfo()
  local mapInfo_name, mapInfo_ID, mapInfo_timeLimit, mapInfo_texture, mapInfo_backgroundTexture = C_ChallengeMode.GetMapUIInfo(challengeModeID or 0)
  local instanceInfo_name, instanceInfo_instanceType, instanceInfo_difficultyID, instanceInfo_difficultyName, instanceInfo_maxPlayers, instanceInfo_dynamicDifficulty, instanceInfo_isDynamic, instanceInfo_instanceID, instanceInfo_instanceGroupSize, instanceInfo_LFGDungeonID = GetInstanceInfo()
  local deathCount_numDeaths, deathCount_timeLost = C_ChallengeMode.GetDeathCount()
  local keystoneTimer = GetKeystoneTimer()
  local _, _, numCriteria = C_ScenarioInfo.GetScenarioStepInfo()
  -- ---@type string?, string?, number?
  -- local _, _, stepCount = C_Scenario.GetStepInfo()

  ---@type ScenarioCriteriaInfo[]
  local criterias = {}
  ---@type ScenarioCriteriaEncounter[]
  local encounters = {}
  local trashCount = 0

  if numCriteria and numCriteria > 1 then
    for stepIndex = 1, numCriteria do
      local criteriaInfo = C_ScenarioInfo.GetCriteriaInfo(stepIndex)
      if criteriaInfo and criteriaInfo.description then
        -- Last step: Trash
        if stepIndex == numCriteria then
          local trashCountCriteria = criteriaInfo.quantityString and tonumber(strsub(criteriaInfo.quantityString, 1, strlen(criteriaInfo.quantityString) - 1)) or 0
          if trashCountCriteria and trashCountCriteria > 0 then
            trashCount = trashCountCriteria
          end
        else
          local encounter = encounters[stepIndex]
          if not encounter then
            encounter = {
              index = stepIndex,
              isInCombat = false,
              numPulls = 0,
              isCompleted = false,
              encounterID = criteriaInfo.assetID,
              combatStartTime = 0,
              combatEndTime = 0,
              completedStartTime = 0,
              completedEndTime = 0,
            }
          end
          -- TODO: Check criteriaDuration/elapsed for accurate numbers and potential time offsets
          if not encounter.isCompleted then
            if not criteriaInfo.completed then
              if not encounter.isInCombat and self.db.global.runHistory.activeEncounter then
                encounter.isInCombat = true
                encounter.combatStartTime = keystoneTimer.elapsedTime
                encounter.numPulls = encounter.numPulls + 1
              elseif encounter.isInCombat and not self.db.global.runHistory.activeEncounter then
                encounter.isInCombat = false
                encounter.combatEndTime = keystoneTimer.elapsedTime
              end
            else
              encounter.isInCombat = false
              encounter.numPulls = max(1, encounter.numPulls)
              encounter.isCompleted = true
              encounter.completedStartTime = encounter.combatStartTime or keystoneTimer.elapsedTime
              encounter.completedEndTime = encounter.combatEndTime or keystoneTimer.elapsedTime
            end
          end

          encounters[stepIndex] = encounter
        end
      end
      criterias[stepIndex] = criteriaInfo
    end
  end

  ---@type AE_RH_ChallengeModeData
  local data = {
    challengeModeID = challengeModeID,
    challengeModeActive = challengeModeActive,
    completionInfo = challengeCompletionInfo,
    keystoneInfo = {
      level = activeKeystoneInfo_level,
      affixIDs = activeKeystoneInfo_affixIDs,
      wasCharged = activeKeystoneInfo_wasCharged,
    },
    mapInfo = {
      name = mapInfo_name,
      id = mapInfo_ID,
      timeLimit = mapInfo_timeLimit,
      texture = mapInfo_texture,
      backgroundTexture = mapInfo_backgroundTexture,
    },
    instanceInfo = {
      name = instanceInfo_name,
      instanceType = instanceInfo_instanceType,
      difficultyID = instanceInfo_difficultyID,
      difficultyName = instanceInfo_difficultyName,
      maxPlayers = instanceInfo_maxPlayers,
      dynamicDifficulty = instanceInfo_dynamicDifficulty,
      isDynamic = instanceInfo_isDynamic,
      instanceID = instanceInfo_instanceID,
      instanceGroupSize = instanceInfo_instanceGroupSize,
      LFGDungeonID = instanceInfo_LFGDungeonID,
    },
    deathCount = {
      numDeaths = deathCount_numDeaths,
      timeLost = deathCount_timeLost,
    },
    numCriteria = numCriteria,
    keystoneTimer = keystoneTimer,
    criterias = criterias,
    encounters = encounters,
    trashCount = trashCount,
  }

  return data
end

---Start a new record
---@return AE_RH_Run?
function Module:StartRun()
  Debug("StartRun()")
  local activeRun = self:GetActiveRun()
  if activeRun then
    self:ClearActiveRun()
  end

  local seasonID = addon.Data:GetCurrentSeason()
  local data = self:GetChallengeData()
  local startTimestamp = GetServerTime()

  if not data.challengeModeID or not data.challengeModeActive then return nil end -- Bug

  -- Detect to see if the run has already been going for a bit
  if data.keystoneTimer.timerID and data.keystoneTimer.isActive and data.keystoneTimer.elapsedTime then
    startTimestamp = startTimestamp - data.keystoneTimer.elapsedTime
  end

  ---@type AE_RH_Run
  local run = {
    id = format("%s:%d:%d:%d", data.instanceInfo.instanceType, data.instanceInfo.instanceID, data.instanceInfo.instanceDifficultyID, startTimestamp),
    seasonID = seasonID,
    startTimestamp = startTimestamp,
    updateTimestamp = GetServerTime(),
    endTimestamp = 0,
    state = "RUNNING",
    members = {},
    events = {},
    loot = {},
    data = data,
  }

  -- TODO: Get member info
  -- TODO: Make use of Open-Raid-library to get spec, talents, gear etc.
  if IsInGroup() then
    for p = 0, GetNumGroupMembers() do
      local unitid = p == 0 and "player" or "party" .. p
      local guid = UnitGUID(unitid)
      local name, server = UnitName(unitid)
      local _, _, classID = UnitClass(unitid)
      local role = UnitGroupRolesAssigned(unitid)

      ---@type AE_RH_Member
      local member = {
        guid = guid or "",
        name = name,
        realm = server,
        classID = classID,
        role = role,
      }
      table.insert(run.members, member)
    end
  else
    -- Solo, really?
    local unitid = "player"
    local guid = UnitGUID(unitid)
    local name, server = UnitName(unitid)
    local _, _, classID = UnitClass(unitid)
    local role = UnitGroupRolesAssigned(unitid)

    ---@type AE_RH_Member
    local member = {
      guid = guid or "",
      name = name,
      realm = server,
      classID = classID,
      role = role,
    }
    table.insert(run.members, member)
  end

  table.insert(addon.Data.db.global.runHistory.runs, run)
  self:SetActiveRun(run.id)
  self:StartRecording()

  return run
end

---End the current run
---@param isCompleted boolean
---@return AE_RH_Run?
function Module:EndActiveRun(isCompleted)
  Debug("EndActiveRun()")
  self:StopRecording()

  local activeRun = self:GetActiveRun()
  if not activeRun then return nil end

  local data = self:GetChallengeData()
  activeRun.updateTimestamp = GetServerTime()
  activeRun.endTimestamp = GetServerTime()

  -- local completionMapChallengeModeID, completionLevel, completionTime, completionOnTime, completionKeystoneUpgradeLevels, completionPracticeRun,
  -- completionOldOverallDungeonScore, completionNewOverallDungeonScore, completionIsMapRecord,
  -- completionIsAffixRecord, completionPrimaryAffix, completionisEligibleForScore, completionUpgradeMembers = C_ChallengeMode.GetCompletionInfo()

  -- if completionTime and completionTime > 0 then
  --   run.completionMapChallengeModeID = completionMapChallengeModeID
  --   run.completionLevel = completionLevel
  --   run.completionTime = completionTime
  --   run.completionOnTime = completionOnTime
  --   run.completionKeystoneUpgradeLevels = completionKeystoneUpgradeLevels
  --   run.completionPracticeRun = completionPracticeRun
  --   run.completionOldOverallDungeonScore = completionOldOverallDungeonScore
  --   run.completionNewOverallDungeonScore = completionNewOverallDungeonScore
  --   run.completionIsMapRecord = completionIsMapRecord
  --   run.completionIsAffixRecord = completionIsAffixRecord
  --   run.completionPrimaryAffix = completionPrimaryAffix
  --   run.completionisEligibleForScore = completionisEligibleForScore
  --   run.completionUpgradeMembers = completionUpgradeMembers
  -- end

  if isCompleted then
    activeRun.data = data
    if activeRun.challengeModeOnTime then
      activeRun.state = "TIMED"
    else
      activeRun.state = "OVERTIME"
    end
  else
    activeRun.state = "ABANDONED"
  end

  self:SetActiveRun(nil)
  return activeRun
end

function Module:PLAYER_ENTERING_WORLD()
  Debug("PLAYER_ENTERING_WORLD()")
  self.window:Show() -- DEV
  self:DetectActiveRun()
end

-- Todo: This is gonna suck
function Module:DetectActiveRun()
  Debug("DetectActiveRun()")

  local data = self:GetChallengeData()
  local activeRun = self:GetActiveRun()

  if activeRun then
    if data.challengeModeActive then
      Debug("DetectActiveRun: isChallengeModeActive")
      self:StartRecording()
      return
    else
      -- if not IsInGroup() then
      --   Debug("DetectActiveRun: not IsInGroup()")
      --   return self:EndActiveRun()
      -- end
    end
  else
    Debug("DetectActiveRun: activeRun = nil")
    if data.challengeModeActive then
      Debug("DetectActiveRun: challengeModeActive = true")
      self:StartRun()
      return
    end
  end
end

function Module:UpdateActiveRun()
  Debug("UpdateActiveRun()")
  local activeRun = self:GetActiveRun()
  if not activeRun then return end

  local data = self:GetChallengeData()
  if not data.challengeModeActive then return end

  activeRun.data = data
  activeRun.updateTimestamp = GetServerTime()

  self:Render()
end

---Get the active run
---@return AE_RH_Run|nil
function Module:GetActiveRun()
  Debug("GetActiveRun()")
  if not addon.Data.db.global.runHistory.activeRun then return nil end
  return addon.Utils:TableGet(addon.Data.db.global.runHistory.runs, "id", addon.Data.db.global.runHistory.activeRun)
end

---Set the active run
---@param runID string|nil
function Module:SetActiveRun(runID)
  Debug("SetActiveRun()")
  addon.Data.db.global.runHistory.activeRun = runID
end

function Module:ClearActiveRun()
  Debug("ClearActiveRun()")
  self:SetActiveRun(nil)
end

function Module:StartRecording()
  Debug("StartRecording()")
  self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  self.recording = self:ScheduleRepeatingTimer("UpdateActiveRun", 1)
end

function Module:StopRecording()
  Debug("StopRecording()")
  self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
  if self.recording then
    self:CancelTimer(self.recording)
  end
end

function Module:COMBAT_LOG_EVENT_UNFILTERED(...)
  Debug("COMBAT_LOG_EVENT_UNFILTERED()")
  local activeRun = self:GetActiveRun()
  if not activeRun or not C_ChallengeMode.IsChallengeModeActive() then
    self:StopRecording()
    return
  end

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
    table.insert(activeRun.events, event)
  end
end

function Module:GROUP_ROSTER_UPDATE(...)
  Debug("GROUP_ROSTER_UPDATE()")
  if not self:GetActiveRun() then return end
  -- TODO: Check if the run is over
  self:UpdateActiveRun()
end

function Module:CHALLENGE_MODE_START(...)
  Debug("CHALLENGE_MODE_START()")
  self:DetectActiveRun()
end

function Module:CHALLENGE_MODE_COMPLETED(...)
  Debug("CHALLENGE_MODE_COMPLETED()")
  self:EndActiveRun(true)
end

function Module:ENCOUNTER_START(...)
  Debug("ENCOUNTER_START()")
  local _, encounterID = ...
  addon.Data.db.global.runHistory.activeEncounter = encounterID
  self:UpdateActiveRun()
end

function Module:ENCOUNTER_END(...)
  Debug("ENCOUNTER_END()")
  addon.Data.db.global.runHistory.activeEncounter = nil
  self:UpdateActiveRun()
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

function Module:ShowRunDetails(run)
  Debug("ShowRunDetails()")
  self.selectedRun = run
  if not self.windowRunDetails then return end
  self.windowRunDetails:Show()
  self:RenderRunDetails()
end

function Module:ShowRunBoard(run)
  Debug("ShowRunBoard()")
  self.selectedRun = run
  if not self.windowRunBoard then return end
  self.windowRunBoard:Show()
  self:RenderRunBoard()
end

function Module:Render()
  Debug("Render()")
  self:RenderRunBoard()
  self:RenderRunDetails()
  self:RenderIndex()
end

function Module:RenderRunDetails()
  Debug("RenderRunDetails()")
  if not self.windowRunDetails then
    self.windowRunDetails = addon.Window:New({
      name = "RunDetails",
      title = "Run Details",
    })
    self.windowRunDetails:SetBodySize(600, 400)

    local rowHeight = 26
    self.windowRunDetails.infoTable = addon.Table:New({
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
    self.windowRunDetails.infoTable:SetParent(self.windowRunDetails)
    self.windowRunDetails.infoTable:SetPoint("TOPLEFT", self.windowRunDetails, "TOPLEFT", 0, -30)
    self.windowRunDetails.infoTable:SetSize(300, 240)
    self.windowRunDetails.tabBody = CreateFrame("Frame", nil, self.windowRunDetails)
    self.windowRunDetails.tabBody:SetPoint("BOTTOMLEFT", self.windowRunDetails, "BOTTOMLEFT", 10, 10)
    self.windowRunDetails.tabBody:SetSize(280, 120)
    addon.Utils:SetBackgroundColor(self.windowRunDetails.tabBody, 0, 0, 0, 0.25)
    -- self.windowRunDetails.tabBody.content = addon.Utils:CreateScrollFrame({
    --   parent = self.windowRunDetails.tabBody,
    -- })
    -- self.windowRunDetails.tabBody.content:SetAllPoints()

    local tabs = {"Events", "Note", "Loot", "Data"}
    addon.Utils:TableForEach(tabs, function(tab, tabIndex)
      local tabFrame = CreateFrame("Frame", nil, self.windowRunDetails)
      local width = self.windowRunDetails.tabBody:GetWidth() / #tabs
      tabFrame:SetSize(width, 26)
      tabFrame:SetPoint("BOTTOMLEFT", self.windowRunDetails.tabBody, "TOPLEFT", width * (tabIndex - 1), 0)
      tabFrame.text = tabFrame:CreateFontString()
      tabFrame.text:SetFontObject("GameFontHighlight")
      tabFrame.text:SetPoint("LEFT", tabFrame, "LEFT", 10, 0)
      tabFrame.text:SetPoint("RIGHT", tabFrame, "RIGHT", -10, 0)
      tabFrame.text:SetText(tab)
      tabFrame.text:SetJustifyH("CENTER")
      tabFrame.text:SetJustifyV("MIDDLE")
      addon.Utils:SetBackgroundColor(tabFrame, 0, 0, 0, tabIndex == 1 and 0.25 or 0.1)
    end)
    -- self.windowRunDetails.tabFirst = CreateFrame("Frame", nil, self.windowRunDetails)
    -- self.windowRunDetails.tabFirst:SetSize(280 / 3, 26)
    -- self.windowRunDetails.tabFirst:SetPoint("BOTTOMLEFT", self.windowRunDetails.tabBody, "TOPLEFT", 0, 0)
    -- self.windowRunDetails.tabFirst.text = self.windowRunDetails.tabFirst:CreateFontString()
    -- self.windowRunDetails.tabFirst.text:SetFontObject("GameFontHighlight")
    -- self.windowRunDetails.tabFirst.text:SetPoint("LEFT", self.windowRunDetails.tabFirst, "LEFT", 10, 0)
    -- self.windowRunDetails.tabFirst.text:SetPoint("RIGHT", self.windowRunDetails.tabFirst, "RIGHT", -10, 0)
    -- self.windowRunDetails.tabFirst.text:SetText("Events")
    -- self.windowRunDetails.tabFirst.text:SetJustifyH("CENTER")
    -- self.windowRunDetails.tabFirst.text:SetJustifyV("MIDDLE")
    -- addon.Utils:SetBackgroundColor(self.windowRunDetails.tabFirst, 0, 0, 0, 0.25)

    -- self.windowRunDetails.tabSecond = CreateFrame("Frame", nil, self.windowRunDetails)
    -- self.windowRunDetails.tabSecond:SetSize(280 / 3, 26)
    -- self.windowRunDetails.tabSecond:SetPoint("BOTTOMLEFT", self.windowRunDetails.tabFirst, "BOTTOMRIGHT", 0, 0)
    -- self.windowRunDetails.tabSecond.text = self.windowRunDetails.tabSecond:CreateFontString()
    -- self.windowRunDetails.tabSecond.text:SetFontObject("GameFontHighlight")
    -- self.windowRunDetails.tabSecond.text:SetPoint("LEFT", self.windowRunDetails.tabSecond, "LEFT", 10, 0)
    -- self.windowRunDetails.tabSecond.text:SetPoint("RIGHT", self.windowRunDetails.tabSecond, "RIGHT", -10, 0)
    -- self.windowRunDetails.tabSecond.text:SetText("Loot")
    -- self.windowRunDetails.tabSecond.text:SetJustifyH("CENTER")
    -- self.windowRunDetails.tabSecond.text:SetJustifyV("MIDDLE")
    -- addon.Utils:SetBackgroundColor(self.windowRunDetails.tabSecond, 0, 0, 0, 0.1)

    -- self.windowRunDetails.tabThird = CreateFrame("Frame", nil, self.windowRunDetails)
    -- self.windowRunDetails.tabThird:SetSize(280 / 3, 26)
    -- self.windowRunDetails.tabThird:SetPoint("BOTTOMLEFT", self.windowRunDetails.tabSecond, "BOTTOMRIGHT", 0, 0)
    -- self.windowRunDetails.tabThird.text = self.windowRunDetails.tabThird:CreateFontString()
    -- self.windowRunDetails.tabThird.text:SetFontObject("GameFontHighlight")
    -- self.windowRunDetails.tabThird.text:SetPoint("LEFT", self.windowRunDetails.tabThird, "LEFT", 10, 0)
    -- self.windowRunDetails.tabThird.text:SetPoint("RIGHT", self.windowRunDetails.tabThird, "RIGHT", -10, 0)
    -- self.windowRunDetails.tabThird.text:SetText("Raw Data")
    -- self.windowRunDetails.tabThird.text:SetJustifyH("CENTER")
    -- self.windowRunDetails.tabThird.text:SetJustifyV("MIDDLE")
    -- addon.Utils:SetBackgroundColor(self.windowRunDetails.tabThird, 0, 0, 0, 0.1)

    self.windowRunDetails.tabBody.text = self.windowRunDetails.tabBody:CreateFontString()
    self.windowRunDetails.tabBody.text:SetPoint("TOPLEFT", self.windowRunDetails.tabBody, "TOPLEFT", 10, -10)
    self.windowRunDetails.tabBody.text:SetPoint("BOTTOMRIGHT", self.windowRunDetails.tabBody, "BOTTOMRIGHT", -10, 10)
    self.windowRunDetails.tabBody.text:SetFontObject("GameFontHighlight")
    self.windowRunDetails.tabBody.text:SetText("|cffaaaaaa00:01:20|r |cffC69B6DLiquidora|r has died.\n|cffaaaaaa00:05:11|r Ingra Maloch pulled.\n|cffaaaaaa00:07:56|r Ingra Maloch killed (2m45s).\n|cffaaaaaa00:22:01|r |cffC69B6DLiquidora|r has died.\n|cffaaaaaa00:31:21|r |cffC69B6DLiquidora|r has died.\n")
    self.windowRunDetails.tabBody.text:SetJustifyH("LEFT")
    self.windowRunDetails.tabBody.text:SetJustifyV("TOP")
    self.windowRunDetails.tabBody.text:SetTextHeight(11)
    self.windowRunDetails.tabBody.text:SetSpacing(3)

    self.windowRunDetails.playerBody = CreateFrame("Frame", nil, self.windowRunDetails)
    self.windowRunDetails.playerBody:SetPoint("TOPRIGHT", self.windowRunDetails, "TOPRIGHT", 0, -26 - 30)
    self.windowRunDetails.playerBody:SetPoint("BOTTOMRIGHT", self.windowRunDetails, "BOTTOMRIGHT", 0, 0)
    self.windowRunDetails.playerBody:SetWidth(300)
    addon.Utils:SetBackgroundColor(self.windowRunDetails.playerBody, 0, 0, 0, 0.2)

    for i = 1, 5 do
      local playerTab = CreateFrame("Frame", nil, self.windowRunDetails)
      playerTab:SetSize(60, 26)
      playerTab:SetPoint("BOTTOMLEFT", self.windowRunDetails.playerBody, "TOPLEFT", (i - 1) * 60, 0)
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

  if not self.windowRunDetails:IsVisible() then
    return
  end

  ---@type AE_RH_Run
  local selectedRun = self.selectedRun

  if not selectedRun then
    self.windowRunDetails:Hide()
    return
  end

  local affixes = {}
  for a = 13, 13 + math.random(1, 4) do
    local affix = addon.Data.affixes[a]
    table.insert(affixes, affix.fileDataID and "|T" .. affix.fileDataID .. ":16|t " or "")
  end

  local leftColor = {r = 0, g = 0, b = 0, a = 0.2}
  ---@type AE_TableData
  local data = {
    columns = {
      {width = 110},
      {width = 190},
    },
    rows = {
      {
        columns = {
          {
            text = "|cffddddddDungeon:|r",
            backgroundColor = leftColor,
          },
          {
            text = selectedRun and (selectedRun.mapTexture and "|T" .. selectedRun.mapTexture .. ":14|t  " or "") .. (selectedRun.mapName and selectedRun.mapName or "-") or "-",
          },
        },
      },
      {
        columns = {
          {
            text = "|cffddddddLevel:|r",
            backgroundColor = leftColor,
          },
          {
            text = selectedRun and selectedRun.challengeModeLevel or "-",
          },
        },
      },
      {
        columns = {
          {
            text = "|cffddddddAffixes:|r",
            backgroundColor = leftColor,
          },
          {
            text = table.concat(affixes, ""),
          },
        },
      },
      {
        columns = {
          {
            text = "|cffddddddTime:|r",
            backgroundColor = leftColor,
          },
          {
            text = selectedRun and selectedRun.keystoneTimerElapsedTime and SecondsToClock(selectedRun.keystoneTimerElapsedTime) or "-",
          },
        },
      },
      {
        columns = {
          {
            text = "|cffddddddResult:|r",
            backgroundColor = leftColor,
          },
          {
            text = selectedRun and selectedRun.state or "-",
          },
        },
      },
      {
        columns = {
          {
            text = "|cffddddddScore:|r",
            backgroundColor = leftColor,
          },
          {
            -- text = run and run.challengeModeNewOverallDungeonScore and tostring(run.challengeModeNewOverallDungeonScore) or "-",
            text = "240 (+30)",
          },
        },
      },
      {
        columns = {
          {
            text = "|cffddddddAvg. iLvl:|r",
            backgroundColor = leftColor,
          },
          {
            text = "634.2",
          },
        },
      },
      {
        columns = {
          {
            text = "|cffddddddDeaths:|r",
            backgroundColor = leftColor,
          },
          {
            -- text = run and run.deathCount and tostring(run.deathCount) or "-",
            text = "3",
          },
        },
      },
      {
        columns = {
          {
            text = "|cffddddddDate:|r",
            backgroundColor = leftColor,
          },
          {
            text = selectedRun and tostring(human_date(selectedRun.startTimestamp)) or "-",
          },
        },
      },
    },
  }
  self.windowRunDetails.infoTable:SetData(data)

  self.windowRunDetails:SetScript("OnShow", function()
    self:RenderRunDetails()
  end)
end

function Module:RenderIndex()
  Debug("RenderIndex()")
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
    self.window.sidebar.inputStatus:SetItems({
      {value = "",          text = "All Results"},
      {value = "RUNNING",   text = "Running"},
      {value = "TIMED",     text = "Timed"},
      {value = "OVERTIME",  text = "Overtime"},
      {value = "ABANDONED", text = "Abandoned"},
    })
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
        highlight = true,
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
      {width = 80},                   -- Dungeon
      {width = 60, align = "center"}, -- Level
      {width = 80},                   -- Time
      {width = 110},                  -- Affixes
      {width = 110},                  -- Tank
      {width = 110},                  -- Healer
      {width = 300},                  -- DPS
      {width = 60, align = "center"}, -- Score
      {width = 110},                  -- Result
      {width = 120},                  -- Date
      {width = 60, align = "center"}, -- Note
    },
    rows = {
      {
        columns = {
          {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Dungeon")},
          {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Level")},
          {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Time")},
          {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Affixes")},
          {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Tank")},
          {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Healer")},
          {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("DPS")},
          {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Score")},
          {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Result")},
          {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Date")},
          {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Note")},
        },
      },
    },
  }
  tableHeight = tableHeight + 30

  --- TODO: Add search filters
  ---@type AE_RH_Run[]
  local runs = addon.Utils:TableFilter(addon.Data.db.global.runHistory.runs, function(run)
    return true
  end)

  table.sort(runs, function(a, b)
    return (a.startTimestamp or 0) > (b.startTimestamp or 0)
  end)

  addon.Utils:TableForEach(runs, function(run, runIndex)
    local affixes = {}
    for a = 13, 13 + math.random(1, 4) do
      local affix = addon.Data.affixes[a]
      table.insert(affixes, affix.fileDataID and "|T" .. affix.fileDataID .. ":16|t " or "")
    end

    local dungeon = addon.Utils:TableGet(dungeons, "challengeModeID", run.data.challengeModeID)
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
        self:ShowRunDetails(run)
        self:ShowRunBoard(run)
      end,
      columns = {
        {text = dungeonName},
        {text = "+" .. tostring(run.data.keystoneInfo.level)},
        {text = SecondsToClock(run.data.keystoneTimer.elapsedTime or 0)},
        {text = table.concat(affixes, "")},
        -- {text = table.concat(run.affixes, "")},
        -- {text = ""},
        -- {text = ""},
        -- {text = ""},
        {text = random_player(true)},
        {text = random_player(false, true)},
        {text = format("%s  %s  %s", random_player(), random_player(), random_player())},
        {text = tostring(run.data.completionInfo.newOverallDungeonScore or 0)},
        {text = run.state},
        {
          text = tostring(human_date(run.startTimestamp)),
          onEnter = function(f)
            GameTooltip:SetOwner(f, "ANCHOR_TOP")
            GameTooltip:SetText(date(RUN_DATE_FORMAT, run.startTimestamp), 1, 1, 1)
            GameTooltip:Show()
          end,
          onLeave = function()
            GameTooltip:Hide()
          end,
        },
        {text = CreateAtlasMarkup("UI-HUD-MicroMenu-AdventureGuide-" .. (math.random() > 0.8 and "Up" or "Disabled"), 24, 24 * 1.25)},
      },
    }
    table.insert(data.rows, row)
    tableHeight = tableHeight + rowHeight
  end)

  -- local lastWhen = GetServerTime()
  -- for i = 1, 20 do
  --   local when = date("%c", lastWhen)
  --   lastWhen = lastWhen - math.random(5000, 15000)

  --   local level = math.random(2, 12)
  --   local levelText = tostring(level)

  --   local score = 80 + level * 30
  --   local scoreText = tostring(score)
  --   local scoreColor = WHITE_FONT_COLOR

  --   local time = math.random(500, 2000)
  --   local timeText = SecondsToClock(time)
  --   local timeColor = WHITE_FONT_COLOR

  --   local status = math.random(1, 10)
  --   local statusText = GREEN_FONT_COLOR:WrapTextInColorCode("Timed")
  --   local statusColor = WHITE_FONT_COLOR

  --   local rarityColor = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(score)
  --   if rarityColor ~= nil then
  --     scoreColor = rarityColor
  --   end

  --   local affixes = {}
  --   for a = 13, 13 + math.random(1, 4) do
  --     local affix = addon.Data.affixes[a]
  --     table.insert(affixes, affix.fileDataID and "|T" .. affix.fileDataID .. ":16|t " or "")
  --   end

  --   local dungeon = dungeons[math.random(#dungeons)]
  --   local dungeonName = "ARAK"
  --   if dungeon then
  --     dungeonName = dungeon.texture and "|T" .. dungeon.texture .. ":16|t  " or ""
  --     dungeonName = dungeonName .. (dungeon.abbr and dungeon.abbr or dungeon.name)
  --   end

  --   if status > 9 then
  --     statusText = "Abandoned"
  --     scoreText = ""
  --     timeText = ""
  --     scoreColor = DIM_RED_FONT_COLOR
  --     timeColor = DIM_RED_FONT_COLOR
  --     statusColor = DIM_RED_FONT_COLOR
  --   elseif status > 7 then
  --     statusText = "Overtime"
  --     scoreColor = DISABLED_FONT_COLOR
  --     timeColor = DISABLED_FONT_COLOR
  --     statusColor = DISABLED_FONT_COLOR
  --   else
  --     statusText = "Timed"
  --     statusColor = DIM_GREEN_FONT_COLOR

  --     if time < 800 then
  --       timeText = timeText .. "  |A:Professions-ChatIcon-Quality-Tier3:16:16:0:0|a"
  --     elseif time < 1200 then
  --       timeText = timeText .. "  |A:Professions-ChatIcon-Quality-Tier2:16:16:0:0|a"
  --     else
  --       timeText = timeText .. "  |A:Professions-ChatIcon-Quality-Tier1:16:16:0:0|a"
  --     end
  --   end

  --   ---@type AE_TableDataRow
  --   local row = {
  --     columns = {
  --       {text = dungeonName},
  --       {text = scoreColor:WrapTextInColorCode(levelText)},
  --       {text = scoreColor:WrapTextInColorCode(scoreText)},
  --       {text = timeColor:WrapTextInColorCode(timeText)},
  --       {text = statusColor:WrapTextInColorCode(statusText)},
  --       {text = table.concat(affixes, "")},
  --       {text = random_player(true)},
  --       {text = random_player(false, true)},
  --       {text = format("%s  %s  %s", random_player(), random_player(), random_player())},
  --       -- {text = random_player()},
  --       -- {text = random_player()},
  --       -- {text = random_player()},
  --       {text = tostring(when)},
  --       -- {text = tostring(when) .. "  " .. CreateAtlasMarkup("UI-HUD-MicroMenu-AdventureGuide-" .. (math.random() > 0.8 and "Up" or "Disabled"), 24, 30) .. "  "},
  --       {text = CreateAtlasMarkup("UI-HUD-MicroMenu-AdventureGuide-" .. (math.random() > 0.8 and "Up" or "Disabled"), 24, 24 * 1.25)},
  --       -- UI-HUD-MicroMenu-AdventureGuide-Up
  --     },
  --   }
  --   table.insert(data.rows, row)
  --   tableHeight = tableHeight + rowHeight
  -- end

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

function Module:RenderRunBoard()
  Debug("RenderRunBoard()")
  if not self.windowRunBoard then
    self.windowRunBoard = addon.Window:New({
      name = "RunBoard",
      title = "Run Details (v2)",
    })

    local bodyWidth = 880
    local bodyHeight = 420

    self.windowRunBoard:SetBodySize(bodyWidth, bodyHeight)

    local topHeight = 240
    local rowHeight = 26
    self.windowRunBoard.infoTable = addon.Table:New({
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
    self.windowRunBoard.infoTable:SetParent(self.windowRunBoard)
    self.windowRunBoard.infoTable:SetPoint("TOPLEFT", self.windowRunBoard, "TOPLEFT", 0, -30)
    self.windowRunBoard.infoTable:SetSize(bodyWidth / 2, topHeight)

    self.windowRunBoard.tabBody = CreateFrame("Frame", nil, self.windowRunBoard)
    self.windowRunBoard.tabBody:SetPoint("TOPLEFT", self.windowRunBoard, "TOPLEFT", bodyWidth / 2, -30)
    self.windowRunBoard.tabBody:SetSize(bodyWidth / 2, topHeight)
    addon.Utils:SetBackgroundColor(self.windowRunBoard.tabBody, 0, 0, 0, 0.25)

    local tabs = {"Events", "Note", "Loot", "Data"}
    addon.Utils:TableForEach(tabs, function(tab, tabIndex)
      local tabFrame = CreateFrame("Frame", nil, self.windowRunBoard)
      local width = self.windowRunBoard.tabBody:GetWidth() / #tabs
      tabFrame:SetSize(width, 26)
      tabFrame:SetPoint("TOPLEFT", self.windowRunBoard.tabBody, "TOPLEFT", width * (tabIndex - 1), 0)
      tabFrame.text = tabFrame:CreateFontString()
      tabFrame.text:SetFontObject("GameFontHighlight")
      tabFrame.text:SetPoint("LEFT", tabFrame, "LEFT", 10, 0)
      tabFrame.text:SetPoint("RIGHT", tabFrame, "RIGHT", -10, 0)
      tabFrame.text:SetText(tab)
      tabFrame.text:SetJustifyH("CENTER")
      tabFrame.text:SetJustifyV("MIDDLE")
      addon.Utils:SetBackgroundColor(tabFrame, 0, 0, 0, tabIndex == 1 and 0.25 or 0.1)
    end)

    self.windowRunBoard.tabBody.text = self.windowRunBoard.tabBody:CreateFontString()
    self.windowRunBoard.tabBody.text:SetPoint("TOPLEFT", self.windowRunBoard.tabBody, "TOPLEFT", 10, -36)
    self.windowRunBoard.tabBody.text:SetPoint("BOTTOMRIGHT", self.windowRunBoard.tabBody, "BOTTOMRIGHT", -10, 10)
    self.windowRunBoard.tabBody.text:SetFontObject("GameFontHighlight")
    self.windowRunBoard.tabBody.text:SetText("|cffaaaaaa00:01:20|r |cffC69B6DLiquidora|r has died.\n|cffaaaaaa00:05:11|r Ingra Maloch pulled.\n|cffaaaaaa00:07:56|r Ingra Maloch killed (2m45s).\n|cffaaaaaa00:22:01|r |cffC69B6DLiquidora|r has died.\n|cffaaaaaa00:31:21|r |cffC69B6DLiquidora|r has died.\n")
    self.windowRunBoard.tabBody.text:SetJustifyH("LEFT")
    self.windowRunBoard.tabBody.text:SetJustifyV("TOP")
    self.windowRunBoard.tabBody.text:SetTextHeight(11)
    self.windowRunBoard.tabBody.text:SetSpacing(3)

    self.windowRunBoard.memberTable = addon.Table:New({
      -- header = {
      --   enabled = false,
      -- },
      rows = {
        height = 30,
        striped = true,
        highlight = true,
      },
      cells = {
        padding = 10,
        highlight = false,
      },
    })
    self.windowRunBoard.memberTable:SetParent(self.windowRunBoard)
    self.windowRunBoard.memberTable:SetPoint("BOTTOMLEFT", self.windowRunBoard, "BOTTOMLEFT", 0, 0)
    self.windowRunBoard.memberTable:SetSize(bodyWidth, 180)
  end

  if not self.windowRunBoard:IsVisible() then
    return
  end

  ---@type AE_RH_Run
  local selectedRun = self.selectedRun

  if not selectedRun then
    self.windowRunBoard:Hide()
    return
  end

  do
    local affixes = {}
    for a = 13, 13 + math.random(1, 4) do
      local affix = addon.Data.affixes[a]
      table.insert(affixes, affix.fileDataID and "|T" .. affix.fileDataID .. ":16|t " or "")
    end

    local leftColor = {r = 0, g = 0, b = 0, a = 0.2}
    ---@type AE_TableData
    local data = {
      columns = {
        {width = 150},
        {width = 250},
      },
      rows = {
        {
          columns = {
            {
              text = "|cffddddddDungeon:|r",
              backgroundColor = leftColor,
            },
            {
              text = selectedRun and (selectedRun.data.mapInfo.texture and "|T" .. selectedRun.data.mapInfo.texture .. ":14|t  " or "") .. (selectedRun.data.mapInfo.name and selectedRun.data.mapInfo.name or "-") or "-",
            },
          },
        },
        {
          columns = {
            {
              text = "|cffddddddLevel:|r",
              backgroundColor = leftColor,
            },
            {
              text = selectedRun and tostring(selectedRun.data.keystoneInfo.level) or "-",
            },
          },
        },
        {
          columns = {
            {
              text = "|cffddddddTime:|r",
              backgroundColor = leftColor,
            },
            {
              text = selectedRun and selectedRun.data.keystoneTimer.elapsedTime and SecondsToClock(selectedRun.data.keystoneTimer.elapsedTime) or "-",
            },
          },
        },
        {
          columns = {
            {
              text = "|cffddddddAffixes:|r",
              backgroundColor = leftColor,
            },
            {
              text = table.concat(affixes, ""),
            },
          },
        },
        {
          columns = {
            {
              text = "|cffddddddResult:|r",
              backgroundColor = leftColor,
            },
            {
              text = selectedRun and selectedRun.state or "-",
            },
          },
        },
        {
          columns = {
            {
              text = "|cffddddddScore:|r",
              backgroundColor = leftColor,
            },
            {
              text = selectedRun and selectedRun.data.completionInfo and selectedRun.data.completionInfo.newOverallDungeonScore and tostring(selectedRun.data.completionInfo.newOverallDungeonScore) or "-",
              -- text = run and run.challengeModeNewOverallDungeonScore and tostring(run.challengeModeNewOverallDungeonScore) or "-",
              -- text = "240 (+30)",
            },
          },
        },
        {
          columns = {
            {
              text = "|cffddddddAvg. iLvl:|r",
              backgroundColor = leftColor,
            },
            {
              text = "634.2",
            },
          },
        },
        {
          columns = {
            {
              text = "|cffddddddDeaths:|r",
              backgroundColor = leftColor,
            },
            {
              -- text = run and run.deathCount and tostring(run.deathCount) or "-",
              text = selectedRun and tostring(selectedRun.data.deathCount.numDeaths) or "-",
            },
          },
        },
        {
          columns = {
            {
              text = "|cffddddddStart time:|r",
              backgroundColor = leftColor,
            },
            {
              text = selectedRun and selectedRun.startTimestamp and selectedRun.startTimestamp > 0 and tostring(date(RUN_DATE_FORMAT, selectedRun.startTimestamp)) or "-",
            },
          },
        },
        {
          columns = {
            {
              text = "|cffddddddLast update:|r",
              backgroundColor = leftColor,
            },
            {
              text = selectedRun and selectedRun.updateTimestamp and selectedRun.updateTimestamp > 0 and tostring(date(RUN_DATE_FORMAT, selectedRun.updateTimestamp)) or "-",
            },
          },
        },
        {
          columns = {
            {
              text = "|cffddddddEnd time:|r",
              backgroundColor = leftColor,
            },
            {
              text = selectedRun and selectedRun.endTimestamp and selectedRun.endTimestamp > 0 and tostring(date(RUN_DATE_FORMAT, selectedRun.endTimestamp)) or "-",
            },
          },
        },
      },
    }
    self.windowRunBoard.infoTable:SetData(data)
  end

  do -- Member table
    local memberTableHeaderBackgroundColor = {r = 0, g = 0, b = 0, a = 0.5}
    ---@type AE_TableData
    local data = {
      columns = {
        {width = 150},                              -- Player
        {width = 110},                              -- Score
        {width = 60, align = "center"},             -- Ilvl
        {width = 70, align = "center"},             -- DPS
        {width = 70, align = "center"},             -- HPS
        {width = 90, align = "center"},             -- Dmg Taken
        {width = 80, align = "center"},             -- Deaths
        {width = 80, align = "center"},             -- Interrupts
        {width = 80, align = "center"},             -- Dispels
        {width = 20, align = "left",  padding = 0}, -- Show Gear
        {width = 20, align = "left",  padding = 0}, -- Show Talents
        {width = 24, align = "left",  padding = 0}, -- Show Note
        {width = 26, align = "left",  padding = 0}, -- Search Player
      },
      rows = {
        {
          columns = {
            {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Player"),     backgroundColor = memberTableHeaderBackgroundColor},
            {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Score"),      backgroundColor = memberTableHeaderBackgroundColor},
            {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Ilvl"),       backgroundColor = memberTableHeaderBackgroundColor},
            {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("DPS"),        backgroundColor = memberTableHeaderBackgroundColor},
            {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("HPS"),        backgroundColor = memberTableHeaderBackgroundColor},
            {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Dmg Taken"),  backgroundColor = memberTableHeaderBackgroundColor},
            {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Deaths"),     backgroundColor = memberTableHeaderBackgroundColor},
            {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Interrupts"), backgroundColor = memberTableHeaderBackgroundColor},
            {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode("Dispels"),    backgroundColor = memberTableHeaderBackgroundColor},
            {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(""),           backgroundColor = memberTableHeaderBackgroundColor},
            {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(""),           backgroundColor = memberTableHeaderBackgroundColor},
            {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(""),           backgroundColor = memberTableHeaderBackgroundColor},
            {text = HIGHLIGHT_FONT_COLOR:WrapTextInColorCode(""),           backgroundColor = memberTableHeaderBackgroundColor},
          },
        },
      },
    }

    for i = 1, 5 do
      local playerName = random_player(i == 1, i == 2)
      local playerIcon = CreateAtlasMarkup("UI-LFG-RoleIcon-Tank", 18, 18, -3, 0)
      if i == 2 then
        playerIcon = CreateAtlasMarkup("UI-LFG-RoleIcon-Healer", 18, 18, -3, 0)
      elseif i > 2 then
        playerIcon = CreateAtlasMarkup("UI-LFG-RoleIcon-DPS", 18, 18, -3, 0)
      end
      ---@type AE_TableDataRow
      local row = {
        onClick = function()
        end,
        columns = {
          {text = playerIcon .. " " .. playerName},                                                                                      -- Player
          {text = "1200 (+150)"},                                                                                                        -- Score
          {text = "662.2"},                                                                                                              -- Ilvl
          {text = "0.00U"},                                                                                                              -- DPS
          {text = "0.00U"},                                                                                                              -- HPS
          {text = "0.00U"},                                                                                                              -- Dmg Taken
          {text = "0"},                                                                                                                  -- Deaths
          {text = "0"},                                                                                                                  -- Interrupts
          {text = "0"},                                                                                                                  -- Dispels
          {text = CreateAtlasMarkup("lootroll-icon-transmog", 16, 16)},                                                                  -- Show Gear
          {text = CreateAtlasMarkup("Front-Tree-Icon", 16, 16)},                                                                         -- Show Talents
          {text = CreateAtlasMarkup("UI-HUD-MicroMenu-AdventureGuide-" .. (math.random() > 0.8 and "Up" or "Disabled"), 20, 20 * 1.25)}, -- Show Note
          {text = CreateAtlasMarkup("talents-search-suggestion-magnifyingglass", 14, 14)},                                               -- Search Player
        },
      }
      table.insert(data.rows, row)
    end
    self.windowRunBoard.memberTable:SetData(data)
  end

  self.windowRunBoard:SetScript("OnShow", function()
    self:RenderRunBoard()
  end)
end
