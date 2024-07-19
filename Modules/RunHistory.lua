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

function Module:OnEnable()
  self:Render()
end

function Module:OnDisable()
  self:Render()
end

function Module:Render()
  if not self.window then
    self.window = Window:New({
      name = "RunHistory",
      title = "Run History",
      sidebar = true,
    })
    self.window.body.table = Table:New()
    self.window.body.table:SetParent(self.window.body)
    self.window.body.table:SetAllPoints()
  end

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

  self.window.body.table:SetData(tableData)
end
