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
local Module = Core:NewModule("Equipment")

function Module:OnEnable()
  self.character = nil
  self:Render()
end

function Module:OnDisable()
  self.character = nil
  self:Render()
end

function Module:ToggleWindow(show)
  if self.window then
    self.window:Toggle(show)
    self:Render()
  end
end

function Module:Open(character)
  if not self.window then
    return
  end

  if self.character and self.character == character then
    self.character = nil
  else
    self.character = character
  end

  self:Render()
end

function Module:Render()
  if not self.window then
    self.window = Window:New({
      name = "Equipment",
      title = "Equipment"
    })
    self.table = Table:New({rowHeight = 28})
    self.table:SetParent(self.window.body)
    self.table:SetAllPoints()
  end

  if not self.character or not self.character.equipment then
    self.character = nil
    self.window:Hide()
    return
  end

  local nameColor = WHITE_FONT_COLOR
  local data = {
    columns = {
      {
        width = 100
      },
      {
        width = 280
      },
      {
        width = 80,
        align = "CENTER"
      },
      {
        width = 150
      },
    },
    rows = {
      {
        columns = {
          {
            text = "Slot",
            backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}
          },
          {
            text = "Item",
            backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}
          },
          {
            text = "iLevel",
            backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}
          },
          {
            text = "Upgrade Level",
            backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}
          },
        }
      }
    }
  }

  Utils:TableForEach(self.character.equipment, function(item)
    local upgradeLevel = ""
    if item.itemUpgradeTrack and item.itemUpgradeTrack ~= "" then
      upgradeLevel = format("%s %d/%d", item.itemUpgradeTrack, item.itemUpgradeLevel, item.itemUpgradeMax)
      if item.itemUpgradeLevel == item.itemUpgradeMax and type(item.itemUpgradeMax) == "number" and item.itemUpgradeMax > 0 then
        upgradeLevel = GREEN_FONT_COLOR:WrapTextInColorCode(upgradeLevel)
      end
    end
    local row = {
      cols = {
        {
          text = _G[item.itemSlotName]
        },
        {
          text = "|T" .. item.itemTexture .. ":0|t " .. item.itemLink,
          OnEnter = function()
            GameTooltip:SetHyperlink(item.itemLink)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("<Shift Click to link to chat>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
          end,
          OnClick = function()
            if IsModifiedClick("CHATLINK") then
              if not ChatEdit_InsertLink(item.itemLink) then
                ChatFrame_OpenChat(item.itemLink);
              end
            end
          end
        },
        {
          text = WrapTextInColorCode(item.itemLevel, select(4, GetItemQualityColor(item.itemQuality)))
        },
        {
          text = upgradeLevel
        },
      }
    }
    table.insert(data.rows, row)
  end)
  self.table:SetData(data)

  local w, h = self.table:GetSize()
  self.window:SetSize(w, h + Constants.sizes.titlebar.height)

  if self.character.info.class.file ~= nil then
    local classColor = C_ClassColor.GetClassColor(self.character.info.class.file)
    if classColor ~= nil then
      nameColor = classColor
    end
  end

  self.window:SetTitle(format("%s (%s)", nameColor:WrapTextInColorCode(self.character.info.name), self.character.info.realm))
  self.window:Show()
end
