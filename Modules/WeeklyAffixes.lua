local addonName, AlterEgo = ...
local Utils = AlterEgo.Utils
local Table = AlterEgo.Table
local Window = AlterEgo.Window
local Core = AlterEgo.Core
local Data = AlterEgo.Data
local Constants = AlterEgo.Constants
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
    self.window = Window:CreateWindow({
      name = "Affixes",
      title = "Weekly Affixes"
    })
    self.table = Table:New({rowHeight = 28})
    self.table.frame:SetParent(self.window.body)
    self.table.frame:SetPoint("TOPLEFT", self.window.body, "TOPLEFT")
  end

  local data = {columns = {}, rows = {}}
  local firstRow = {cols = {}}

  if affixRotation then
    Utils:TableForEach(affixRotation.activation, function(activationLevel)
      table.insert(data.columns, {width = 140})
      table.insert(firstRow.cols, {text = "+" .. activationLevel, backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}})
    end)
    table.insert(data.rows, firstRow)
    Utils:TableForEach(affixRotation.affixes, function(affixValues, weekIndex)
      local row = {cols = {}}
      local backgroundColor = weekIndex == activeWeek and {r = 1, g = 1, b = 1, a = 0.1} or nil
      Utils:TableForEach(affixValues, function(affixValue)
        if type(affixValue) == "number" then
          local affix = Utils:TableGet(affixes, "id", affixValue)
          if affix then
            local name = weekIndex < activeWeek and LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(affix.name) or affix.name
            table.insert(row.cols, {
              text = "|T" .. affix.fileDataID .. ":0|t " .. name,
              backgroundColor = backgroundColor or nil,
              OnEnter = function()
                GameTooltip:SetText(affix.name, WHITE_FONT_COLOR.r, WHITE_FONT_COLOR.g, WHITE_FONT_COLOR.b, 1, true);
                GameTooltip:AddLine(affix.description, nil, nil, nil, true);
              end,
            })
          end
        else
          table.insert(row.cols, {
            text = affixValue,
            backgroundColor = backgroundColor or nil,
          })
        end
      end)
      table.insert(data.rows, row)
    end)
  else
    table.insert(data.columns, {width = 500})
    table.insert(data.rows, {cols = {{text = "The weekly schedule is not updated. Check back next addon update!"}}})
  end

  self.table:SetData(data)
  local w, h = self.table:GetSize()
  self.window:SetSize(w, h + Constants.sizes.titlebar.height)
end
