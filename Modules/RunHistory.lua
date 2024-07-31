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
local Module = Core:NewModule("RunHistory")

function Module:OnInitialize()
  self.window = Window:New({
    name = "RunHistory",
    title = "Run History",
    sidebar = 150,
  })
  -- self.window.body.table = Table:New()
  -- self.window.body.table:SetParent(self.window.body)
  -- self.window.body.table:SetAllPoints()
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
  self:RegisterEvent("CHALLENGE_MODE_KEYSTONE_RECEPTABLE_OPEN")
  self:RegisterEvent("CHALLENGE_MODE_KEYSTONE_SLOTTED")
  self:RegisterEvent("CHALLENGE_MODE_START")
  self:RegisterEvent("ENCOUNTER_END")
  self:RegisterEvent("ENCOUNTER_START")
  self:RegisterEvent("PLAYER_ENTERING_WORLD")

  self:Render()
end

function Module:OnDisable()
  self:UnregisterAllEvents()
end

function Module:StartRun()
  if self:GetActiveRun() then return end -- Already in a run?

  local data = Data:GetChallengeData()
  local seasonID = Data:GetCurrentSeason()

  ---@type AE_RH_Run
  local activeRun = {
    seasonID = seasonID,
    startTimestamp = 0,
    endTimestamp = 0,
    state = "RUNNING",
    challengeModeID = 0,
    challengeModeLevel = 0,
    challengeModeTimetable = {0, 0, 0},
    numDeaths = 0,
    timeLost = 0,
    affixes = {},
    members = {},
    events = {},
    items = {},
  }

  if data.isChallengeModeActive then
    activeRun.startTimestamp = activeRun.startTimestamp - data.time
    activeRun.challengeModeID = data.activeChallengeModeID
    activeRun.affixes = data.activeKeystoneAffixIDs
    activeRun.challengeModeLevel = data.activeKeystoneLevel
  end

  -- TODO: Make use of Open-Raid-library to get spec, talents, gear etc.
  if IsInGroup() then
    for p = 0, GetNumGroupMembers() do
      local unitid = p == 0 and "player" or "party" .. p
      local name, server = UnitName(unitid)
      local _, _, classID = UnitClass(unitid)
      local role = UnitGroupRolesAssigned(unitid)

      ---@type AE_RH_RunMember
      local member = {
        name = name,
        server = server,
        classID = classID,
        role = role,
      }
      table.insert(activeRun.members, member)
    end
  end

  self:SetActiveRun(activeRun)
end

---Get the active run
---@return AE_RH_Run|nil
function Module:GetActiveRun()
  return Data.db.global.runHistory.activeRun
end

---Set the active run
---@param run AE_RH_Run|nil
function Module:SetActiveRun(run)
  Data.db.global.runHistory.activeRun = run
end

function Module:EndActiveRun()
  local activeRun = self:GetActiveRun()
  if not activeRun then return end

  -- TODO: Set more data after a run is complete
  activeRun.endTimestamp = GetServerTime()

  table.insert(Data.db.global.runHistory.runs, activeRun)
  self:ClearActiveRun()
end

function Module:ClearActiveRun()
  self:SetActiveRun(nil)
end

function Module:UpdateCurrentRun()
  local data = self:GetData()
  local currentRun = self:GetActiveRun()
  if not currentRun then
    if data.isChallengeModeActive then
      self:StartRun()
      return
    end
  end


  local runData = self:GetData()
  if not Data.db.global.runHistory.activeRun then
    if runData.isChallengeModeActive then
      return self:StartRun()
    end
  end
end

function Module:COMBAT_LOG_EVENT_UNFILTERED(...)
  local timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = CombatLogGetCurrentEventInfo()
  if subEvent == "UNIT_DIED" and destGUID and string.find(destGUID, "Player") and not UnitIsFeignDeath(destGUID) then
    local activeRun = self:GetActiveRun()
    if not activeRun then return end
    local _, _, classID = UnitClass(destGUID)
    -- TODO: This can vary based on new expansion affix
    local timeLost = 5
    ---@type AE_RH_RunEventDeath
    local event = {
      timestamp = GetServerTime(),
      type = "DEATH",
      name = destName or "",
      classID = classID or 0,
      timeAdded = timeLost
    }
    activeRun.numDeaths = activeRun.numDeaths + 1
    activeRun.timeLost = activeRun.timeLost + timeLost
    table.insert(activeRun.events, event)
  end
end

function Module:GROUP_ROSTER_UPDATE(...)
  if not self:GetActiveRun() then return end
  -- TODO: Check if the run is over
end

function Module:CHALLENGE_MODE_START(...)
  local currentRun = self:GetActiveRun()
  if currentRun then
    self:ClearActiveRun()
  end
  self:StartRun()
end

function Module:CHALLENGE_MODE_COMPLETED(...)
  local currentRun = self:GetActiveRun()
  if not currentRun then
    return
  end
  currentRun.completedTimestamp = GetServerTime()

  self:EndActiveRun()
end

function Module:PLAYER_ENTERING_WORLD()
  self:UpdateCurrentRun()
end

function Module:ENCOUNTER_START(...)
  local _, encounterID = ...
  Data.db.global.runHistory.activeEncounter = encounterID
  self:UpdateCurrentRun()
end

function Module:ENCOUNTER_END(...)
  activeEncounter = false
  self:UpdateCurrentRun()
end

function Module:Render()
  if not self.window then return end

  ---@type AE_TableData
  local tableData = {
    columns = {
      {width = 100}, -- Date
      {width = 100}, -- Dungeon
      {width = 100}, -- Level
      {width = 100}, -- Time
      {width = 100}, -- Affixes
      {width = 100}, -- Tank
      {width = 100}, -- Healer
      {width = 100}, -- DPS
      {width = 100}, -- Score
      {width = 100}, -- Status
    },
    rows = {}
  }

  Utils:TableForEach(Data.db.global.runHistory.runs, function(run)
    local dungeon = Utils:TableGet(Data.dungeons, "challengeModeID", run.challengeModeID)
    local affixes = Utils:TableMap(run.affixes, function(affixID)
      return Utils:TableGet(Data.affixes, "id", affixID)
    end)
    local tanks = Utils:TableFilter(run.members, function(member) return member.role == "TANK" end)
    local healers = Utils:TableFilter(run.members, function(member) return member.role == "HEALER" end)
    local dps = Utils:TableFilter(run.members, function(member) return member.role == "DPS" end)
    ---@type AE_TableDataRow
    local row = {
      columns = {
        {text = tostring(run.startTimestamp)},
        {text = dungeon and dungeon.abbr or "??"},
        {text = run.challengeModeLevel},
        {text = tostring(run.challengeModeTime)}, -- Format seconds to time
        {text = table.concat(Utils:TableMap(affixes, function(affix) return affix.name or "??" end), ", ")},
        {text = table.concat(Utils:TableMap(tanks, function(member) return member.name or "??" end), ", ")},
        {text = table.concat(Utils:TableMap(healers, function(member) return member.name or "??" end), ", ")},
        {text = table.concat(Utils:TableMap(dps, function(member) return member.name or "??" end), ", ")},
        {text = run.challengeModeNewOverallDungeonScore},
        {text = run.status},
      }
    }
    table.insert(tableData.rows, row)
  end)

  -- self.window.body.table:SetData(tableData)
end
