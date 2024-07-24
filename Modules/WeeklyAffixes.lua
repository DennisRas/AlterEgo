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
local Module = Core:NewModule("WeeklyAffixes")

function Module:OnEnable()
  Core:RegisterEvent("MYTHIC_PLUS_CURRENT_AFFIX_UPDATE", function()
    self:Render()
  end)
  self:Render()
end

function Module:OnDisable()
  self.window:Hide()
end

---Show the window
function Module:Open()
  self:Render()
  self.window:Show()
end

function Module:Render()
  local affixes = Data:GetAffixes()
  local affixRotation = Data:GetAffixRotation()
  local currentAffixes = Data:GetCurrentAffixes()
  local activeWeek = Data:GetActiveAffixRotation(currentAffixes)

  if not self.window then
    self.window = Window:New({
      name = "Affixes",
      title = "Weekly Affixes"
    })
    self.table = Table:New({rowHeight = 28})
    self.table:SetParent(self.window.body)
    self.table:SetPoint("TOPLEFT", self.window.body, "TOPLEFT")
  end

  ---@type AE_TableData
  local data = {columns = {}, rows = {}}
  ---@type AE_TableDataRow
  local firstRow = {columns = {}}

  if affixRotation then
    Utils:TableForEach(affixRotation.activation, function(activationLevel)
      ---@type AE_TableDataColumn
      local column = {width = 140}
      ---@type AE_TableDataRowColumn
      local columnData = {text = "+" .. activationLevel, backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}}

      table.insert(data.columns, column)
      table.insert(firstRow.columns, columnData)
    end)
    table.insert(data.rows, firstRow)
    Utils:TableForEach(affixRotation.affixes, function(affixValues, weekIndex)
      ---@type AE_TableDataRow
      local row = {columns = {}}
      local backgroundColor = weekIndex == activeWeek and {r = 1, g = 1, b = 1, a = 0.1} or nil

      Utils:TableForEach(affixValues, function(affixValue)
        if type(affixValue) == "number" then
          local affix = Utils:TableGet(affixes, "id", affixValue)
          if affix then
            local name = weekIndex < activeWeek and LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(affix.name) or affix.name
            ---@type AE_TableDataRowColumn
            local columnData = {
              text = "|T" .. affix.fileDataID .. ":0|t " .. name,
              backgroundColor = backgroundColor or nil,
              onEnter = function(columnFrame)
                GameTooltip:ClearAllPoints()
                GameTooltip:ClearLines()
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
    end)
  else
    ---@type AE_TableDataColumn
    local column = {width = 500}
    ---@type AE_TableDataRow
    local row = {columns = {{text = "The weekly schedule is not updated. Check back next addon update!"}}}

    table.insert(data.columns, column)
    table.insert(data.rows, row)
  end

  self.table:SetData(data)
  local w, h = self.table:GetSize()
  self.window:SetSize(w, h + Constants.sizes.titlebar.height)
end
