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
local Module = Core:NewModule("LootTable")

function Module:OnEnable()
  self:Render()
end

function Module:GetData()
  if not self.data then
    self.data = {}
  end
end

function Module:Render()
  if not self.window then
    self.window = Window:New({
      name = "LootTable",
      title = "Loot Table",
      sidebar = true,
    })
    self.window.body.table = Table:New({header = {sticky = true}})
    self.window.body.table:SetParent(self.window.body)
    self.window.body.table:SetAllPoints()
  end

  ---@type AE_TableData
  local tableData = {
    columns = {
      {width = 200}, -- Item
      {width = 60},  -- Dungeon
      {width = 160}, -- Boss
      {width = 120}, -- Classes
      {width = 120}, -- Specs
      {width = 100}, -- Slot
      {width = 100}, -- Type
    },
    rows = {}
  }

  for i = 1, 100 do
    ---@type AE_TableDataRow
    local row = {
      columns = {
        {text = "Item"},
        {text = "Dungeon"},
        {text = "Boss"},
        {text = "Classes"},
        {text = "Specs"},
        {text = "Slot"},
        {text = "Type"},
      }
    }
    table.insert(tableData.rows, row)
  end

  local width = 0
  Utils:TableForEach(tableData.columns, function(column)
    width = width + (column.width or 0)
  end)

  self.window.body.table:SetData(tableData)
  self.window:SetBodySize(width, 500)
  self.window:Show()
end
