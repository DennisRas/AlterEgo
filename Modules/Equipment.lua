local addonName, AlterEgo = ...
local Utils = AlterEgo.Utils
local Table = AlterEgo.Table
local Window = AlterEgo.Window
local Core = AlterEgo.Core
local Data = AlterEgo.Data
local Constants = AlterEgo.Constants
local Module = Core:NewModule("Equipment")

function Module:OnEnable()
  self:RegisterMessage("AE_EQUIPMENT_TOGGLE", "ToggleWindow")
  self:RegisterMessage("AE_EQUIPMENT_OPEN", "Open")
  self:Render()
end

function Module:OnDisable()
  self:UnregisterMessage("AE_EQUIPMENT_TOGGLE")
  self:ToggleWindow(false)
end

function Module:ToggleWindow(shown)
  if self.window then
    self.window:Toggle(shown)
    self:Render()
  end
end

function Module:Open(character)
  if self.window then
    if self.character and self.character == character and self.window:IsVisible() then
      self.window:Toggle(false)
      return
    end
    self.window:Toggle(true)
    self.character = character
    self:Render()
  end
end

function Module:Render()
  if not self.window then
    self.window = Window:CreateWindow({
      name = "Equipment",
      title = "Equipment"
    })
    self.table = Table:New({rowHeight = 28})
    self.table.frame:SetParent(self.window.body)
    self.table.frame:SetAllPoints()
  end

  local data = {
    columns = {
      {width = 100},
      {width = 280},
      {width = 80, align = "CENTER"},
      {width = 120},
    },
    rows = {
      {
        cols = {
          {text = "Slot",          backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
          {text = "Item",          backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
          {text = "iLevel",        backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
          {text = "Upgrade Level", backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
        }
      }
    }
  }
  if type(self.character.equipment) == "table" then
    Utils:TableForEach(self.character.equipment, function(item)
      local upgradeLevel = ""
      if item.itemUpgradeTrack ~= "" then
        upgradeLevel = format("%s %d/%d", item.itemUpgradeTrack, item.itemUpgradeLevel, item.itemUpgradeMax)
        if item.itemUpgradeLevel == item.itemUpgradeMax then
          upgradeLevel = GREEN_FONT_COLOR:WrapTextInColorCode(upgradeLevel)
        end
      end
      local row = {
        cols = {
          {text = _G[item.itemSlotName]},
          {
            text = "|T" .. item.itemTexture .. ":0|t " .. item.itemLink,
            OnEnter = function()
              GameTooltip:SetHyperlink(item.itemLink)
              GameTooltip:AddLine(" ")
              GameTooltip:AddLine("<Shift Click to Link to Chat>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
            end,
            OnClick = function()
              if IsModifiedClick("CHATLINK") then
                if not ChatEdit_InsertLink(item.itemLink) then
                  ChatFrame_OpenChat(item.itemLink);
                end
              end
            end
          },
          {text = WrapTextInColorCode(item.itemLevel, select(4, GetItemQualityColor(item.itemQuality)))},
          {text = upgradeLevel},
        }
      }
      table.insert(data.rows, row)
    end)
    self.table:SetData(data)
    local w, h = self.table:GetSize()
    self.window:SetSize(w, h + Constants.sizes.titlebar.height)
    local nameColor = WHITE_FONT_COLOR
    if self.character.info.class.file ~= nil then
      local classColor = C_ClassColor.GetClassColor(self.character.info.class.file)
      if classColor ~= nil then
        nameColor = classColor
      end
    end
    Window:SetTitle("Equipment", format("%s (%s)", nameColor:WrapTextInColorCode(self.character.info.name), self.character.info.realm))
  end
end
