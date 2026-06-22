---@class AE_Addon
local addon = select(2, ...)

---@type AE_Module_WeeklyAffixes|AceModule
local Module = addon.Core:NewModule("WeeklyAffixes", "AceConsole-3.0", "AceTimer-3.0")
addon.Module_WeeklyAffixes = Module

local Data = addon.Data
local Constants = addon.Constants
local LibLiqUI = addon.Libs.LiqUI
local TableForEach = LibLiqUI.Utils.TableForEach
local TableGet = LibLiqUI.Utils.TableGet

local PLACEHOLDER_BODY_WIDTH = 500
local PLACEHOLDER_BODY_HEIGHT = 80
local PLACEHOLDER_TEXT = "The weekly schedule is not updated.\nCheck back next addon update!"

function Module:OnInitialize()
  self:Render()
end

function Module:Render()
  local affixes = Data:GetAffixes()
  local affixRotation = Data:GetAffixRotation()
  local currentAffixes = Data:GetCurrentAffixes()
  local activeWeek = Data:GetActiveAffixRotation(currentAffixes)
  local columnWidth = 140
  local rowHeight = 28

  if not self.window then
    ---@type LiqUI_WindowInstance
    self.window = addon.LiqUI.Window:New({
      name = "Affixes",
      title = "Weekly Affixes",
      onShow = function()
        Module:Render()
      end,
    })
    ---@type LiqUI_TableInstance
    self.table = addon.LiqUI.Table:New({
      name = "Affixes",
      header = {enabled = false},
      rowStyle = {height = rowHeight, striped = true},
    })
    self.table:SetParent(self.window.body)
    self.table:SetPoint("TOPLEFT", self.window.body, "TOPLEFT", 0, 0)
    self.table:SetPoint("BOTTOMRIGHT", self.window.body, "BOTTOMRIGHT", 0, 0)
  end

  if not self.window:IsVisible() then
    return
  end

  if not affixRotation then
    self.window:ShowOverlay(PLACEHOLDER_TEXT)
    self.table:Hide()
    self.window:SetBodySize(PLACEHOLDER_BODY_WIDTH, PLACEHOLDER_BODY_HEIGHT)
    return
  end

  self.window:HideOverlay()
  self.table:Show()

  ---@type LiqUI_TableOptionsColumn[]
  local columns = {}
  ---@type LiqUI_TableData
  local rows = {}

  do
    ---@type LiqUI_TableDataRowExtended
    local row = {data = {}}
    TableForEach(affixRotation.activation, function(activationLevel, activationLevelIndex)
      local width = activationLevelIndex == 1 and 220 or columnWidth
      ---@type LiqUI_TableOptionsColumn
      local column = {id = "activation" .. activationLevelIndex, width = width}
      table.insert(columns, column)
      ---@type LiqUI_TableDataCellExtended
      local cell = {
        data = "+" .. activationLevel,
        backgroundColor = {r = 0, g = 0, b = 0, a = 0.3},
      }
      table.insert(row.data, cell)
    end)
    table.insert(rows, row)
  end

  TableForEach(affixRotation.affixes, function(affixValues, weekIndex)
    ---@type LiqUI_TableDataRowExtended
    local row = {
      backgroundColor = weekIndex == activeWeek and {r = 1, g = 1, b = 1, a = 0.1} or nil,
      data = {},
    }

    TableForEach(affixValues, function(affixValue)
      if type(affixValue) == "number" then
        local affix = TableGet(affixes, "id", affixValue)
        if affix then
          local name = weekIndex < activeWeek and LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(affix.name) or affix.name
          ---@type LiqUI_TableDataCellExtended
          local cell = {
            data = affix.fileDataID and "|T" .. affix.fileDataID .. ":0|t " .. name or name,
            backgroundColor = row.backgroundColor,
            onEnter = function(cellFrame)
              GameTooltip:SetOwner(cellFrame, "ANCHOR_RIGHT")
              GameTooltip:SetText(affix.name, WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b, 1, true)
              GameTooltip:AddLine(affix.description, nil, nil, nil, true)
              GameTooltip:Show()
            end,
            onLeave = function()
              GameTooltip:Hide()
            end,
          }
          table.insert(row.data, cell)
        end
      else
        ---@type LiqUI_TableDataCellExtended
        local cell = {
          data = affixValue,
          backgroundColor = row.backgroundColor,
        }
        table.insert(row.data, cell)
      end
    end)
    table.insert(rows, row)
  end)

  self.table:SetColumns(columns)
  self.table:SetData(rows)
  local bodyWidth, bodyHeight = self.table:GetSize()
  self.window:SetBodySize(bodyWidth, bodyHeight)
end
