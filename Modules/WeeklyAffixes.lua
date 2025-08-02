---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

---@class AE_Module_WeeklyAffixes : AceModule
local Module = addon.Core:NewModule("WeeklyAffixes", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0", "AceBucket-3.0")
addon.Module_WeeklyAffixes = Module

function Module:OnInitialize()
  self:Render()
end

function Module:Render()
  local affixes = addon.Data:GetAffixes()
  local affixRotation = addon.Data:GetAffixRotation()
  local currentAffixes = addon.Data:GetCurrentAffixes()
  local activeWeek = addon.Data:GetActiveAffixRotation(currentAffixes)

  local tableWidth = 0
  local tableHeight = 0
  local columnWidth = 140
  local rowHeight = 28

  if not self.window then
    self.window = addon.Window:New({
      name = "Affixes",
      title = "Weekly Affixes",
      point = {"TOP", UIParent, "TOP", 0, -15},
    })
    self.table = addon.Table:New({rows = {height = rowHeight, striped = true}})
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
  local data = {columns = {}, rows = {}}

  if affixRotation then
    do -- First row with activation levels
      ---@type AE_TableDataRow
      local row = {columns = {}}
      addon.Utils:TableForEach(affixRotation.activation, function(activationLevel, activationLevelIndex)
        ---@type AE_TableDataColumn
        local column = {width = activationLevelIndex == 1 and 220 or columnWidth}
        ---@type AE_TableDataRowColumn
        local columnData = {text = "+" .. activationLevel, backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}}

        table.insert(data.columns, column)
        table.insert(row.columns, columnData)
        tableWidth = tableWidth + column.width
      end)
      table.insert(data.rows, row)
      tableHeight = tableHeight + rowHeight
    end

    addon.Utils:TableForEach(affixRotation.affixes, function(affixValues, weekIndex)
      ---@type AE_TableDataRow
      local row = {columns = {}}
      local backgroundColor = weekIndex == activeWeek and {r = 1, g = 1, b = 1, a = 0.1} or nil

      addon.Utils:TableForEach(affixValues, function(affixValue)
        if type(affixValue) == "number" then
          local affix = addon.Utils:TableGet(affixes, "id", affixValue)
          if affix then
            local name = weekIndex < activeWeek and LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(affix.name) or affix.name
            ---@type AE_TableDataRowColumn
            local columnData = {
              text = affix.fileDataID and "|T" .. affix.fileDataID .. ":0|t " .. name or name,
              backgroundColor = backgroundColor or nil,
              onEnter = function(columnFrame)
                GameTooltip:SetOwner(columnFrame, "ANCHOR_RIGHT")
                GameTooltip:SetText(affix.name, WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b, 1, true)
                GameTooltip:AddLine(affix.description, nil, nil, nil, true)
                GameTooltip:Show()
              end,
              onLeave = function()
                GameTooltip:Hide()
              end,
            }
            table.insert(row.columns, columnData)
          end
        else
          ---@type AE_TableDataRowColumn
          local columnData = {
            text = affixValue,
            backgroundColor = backgroundColor or nil,
          }
          table.insert(row.columns, columnData)
        end
      end)
      table.insert(data.rows, row)
      tableHeight = tableHeight + rowHeight
    end)
  else
    ---@type AE_TableDataColumn
    local column = {width = 500}
    ---@type AE_TableDataRow
    local row = {columns = {{text = "The weekly schedule is not updated. Check back next addon update!"}}}

    table.insert(data.columns, column)
    table.insert(data.rows, row)
    tableWidth = tableWidth + 500
    tableHeight = tableHeight + rowHeight
  end

  self.table:SetData(data)
  self.window:SetBodySize(tableWidth, tableHeight)
end
