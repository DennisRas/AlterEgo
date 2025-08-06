---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

---@class AE_Module_Equipment : AceModule
local Module = addon.Core:NewModule("Equipment", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0", "AceBucket-3.0")
addon.Module_Equipment = Module

function Module:OnInitialize()
  self:Render()
end

function Module:OnEnable()
  self:RegisterBucketEvent(
    {
      "PLAYER_EQUIPMENT_CHANGED",
      "UNIT_INVENTORY_CHANGED",
    }, 3, function()
      -- addon.Data:UpdateCharacterInfo()
      addon.Data:UpdateEquipment()
      self:Render()
    end
  )
end

---Opens a new equipment window
---@param character AE_Character
function Module:OpenCharacter(character)
  if not self.window then return end
  if self.equipmentCharacter and self.equipmentCharacter == character and self.window:IsVisible() then
    self.window:Hide()
    return
  end
  self.equipmentCharacter = character
  self:Render()
  self.window:Show()
end

function Module:Render()
  local tableWidth = 610
  local tableHeight = 0
  local rowHeight = 22

  if not self.window then
    self.window = addon.Window:New({
      name = "Equipment",
      title = "Character",
      point = {"TOPLEFT", UIParent, "TOPLEFT", 15, -15},
    })
    self.dataTable = addon.Table:New({rows = {height = rowHeight, striped = true}})
    self.dataTable:SetParent(self.window.body)
    self.dataTable:SetAllPoints()
    self.window:SetScript("OnShow", function()
      self:Render()
    end)
  end

  if not self.window:IsVisible() then
    return
  end

  local character = self.equipmentCharacter
  if not character or type(character.equipment) ~= "table" then
    self.window:Hide()
    return
  end

  ---@type AE_TableData
  local data = {
    columns = {
      {width = 100},
      {width = 280},
      {width = 80, align = "CENTER"},
      {width = 150},
    },
    rows = {
      {
        columns = {
          {text = "Slot",          backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
          {text = "Item",          backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
          {text = "iLevel",        backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
          {text = "Upgrade Level", backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
        },
      },
    },
  }
  tableHeight = tableHeight + 30

  addon.Utils:TableForEach(character.equipment, function(item)
    local upgradeLevel = ""
    if item.itemUpgradeTrack ~= "" then
      upgradeLevel = format("%s %d/%d", item.itemUpgradeTrack, item.itemUpgradeLevel, item.itemUpgradeMax)
      if item.itemUpgradeColor and item.itemUpgradeColor == DISABLED_FONT_COLOR:GenerateHexColor() then
        upgradeLevel = DISABLED_FONT_COLOR:WrapTextInColorCode(upgradeLevel)
      elseif item.itemUpgradeLevel == item.itemUpgradeMax then
        upgradeLevel = GREEN_FONT_COLOR:WrapTextInColorCode(upgradeLevel)
      end
    end

    ---Detect old season items as Blizz no longer adds old Upgrade Levels to the tooltip
    local itemPayload = string.match(item.itemLink, "item:([%-?%d:]+)")
    if itemPayload then
      local itemPayloadSplit = {strsplit(":", itemPayload)}
      local numBonuses = tonumber(itemPayloadSplit[13])
      if numBonuses ~= nil and numBonuses > 0 then
        for i = 14, 13 + numBonuses do
          local bonusId = tonumber(itemPayloadSplit[i])
          if bonusId ~= nil then
            for _, tracks in pairs(addon.Data.oldUpgradeLevels) do
              for trackName, ids in pairs(tracks) do
                for idx, id in pairs(ids) do
                  if id == bonusId then
                    upgradeLevel = DISABLED_FONT_COLOR:WrapTextInColorCode(format("%s %d/%d", trackName, idx, #ids))
                  end
                end
              end
            end
          end
        end
      end
    end

    ---TWW Season 2 Item: D.I.S.C.
    local itemID = C_Item.GetItemIDForItemInfo(item.itemLink)
    if itemID == 245966 or itemID == 245964 or itemID == 245965 or itemID == 242664 then
      local DISCLevels = {691, 694, 697, 701}
      local numDISCLevels = addon.Utils:TableCount(DISCLevels)
      addon.Utils:TableForEach(DISCLevels, function(DISCLevel, i)
        if item.itemLevel == DISCLevel then
          upgradeLevel = format("D.I.S.C. %d/%d", i, numDISCLevels)
          if i == numDISCLevels then
            upgradeLevel = GREEN_FONT_COLOR:WrapTextInColorCode(upgradeLevel)
          end
        end
      end)
    end

    ---@type AE_TableDataRow
    local row = {
      columns = {
        {text = _G[item.itemSlotName]},
        {
          text = "|T" .. item.itemTexture .. ":0|t " .. item.itemLink,
          onEnter = function(columnFrame)
            GameTooltip:SetOwner(columnFrame, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(item.itemLink)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("<Shift Click to Link to Chat>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
            GameTooltip:Show()
          end,
          onLeave = function()
            GameTooltip:Hide()
          end,
          onClick = function()
            if IsModifiedClick("CHATLINK") then
              if not ChatEdit_InsertLink(item.itemLink) then
                ChatFrame_OpenChat(item.itemLink)
              end
            end
          end,
        },
        {text = WrapTextInColorCode(tostring(item.itemLevel), select(4, GetItemQualityColor(item.itemQuality)))},
        {text = upgradeLevel},
      },
    }
    table.insert(data.rows, row)
    tableHeight = tableHeight + rowHeight
  end)

  local nameColor = WHITE_FONT_COLOR
  if character.info.class.file ~= nil then
    local classColor = C_ClassColor.GetClassColor(character.info.class.file)
    if classColor ~= nil then
      nameColor = classColor
    end
  end

  self.window:SetTitle(format("%s (%s)", nameColor:WrapTextInColorCode(character.info.name), character.info.realm))
  self.dataTable:SetData(data)
  self.window:SetBodySize(tableWidth, tableHeight)
end
