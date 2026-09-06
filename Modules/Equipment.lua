---@class AE_Addon
local addon = select(2, ...)

---@class AE_Module_Equipment
local Module = addon.Core:NewModule("Equipment", "AceConsole-3.0", "AceTimer-3.0")
addon.Module_Equipment = Module

local Data = addon.Data
local LiqUI = addon.Libs.LiqUI
local TableCount = LiqUI.Utils.TableCount
local TableForEach = LiqUI.Utils.TableForEach

local EQUIPMENT_HEADER_HEIGHT = 30
local CRAFTED_QUALITY_MAX = 5

---@param itemLink string
---@return number[]
local function getItemLinkBonusIDs(itemLink)
  ---@type number[]
  local bonusIDs = {}
  local itemPayload = string.match(itemLink, "item:([%-?%d:]+)")
  if not itemPayload then
    return bonusIDs
  end
  local itemPayloadSplit = {strsplit(":", itemPayload)}
  local numBonuses = tonumber(itemPayloadSplit[13])
  if numBonuses == nil or numBonuses < 1 then
    return bonusIDs
  end
  for bonusIndex = 14, 13 + numBonuses do
    local bonusId = tonumber(itemPayloadSplit[bonusIndex])
    if bonusId ~= nil then
      table.insert(bonusIDs, bonusId)
    end
  end
  return bonusIDs
end

---@param text string
---@param complete boolean
---@param muted boolean
---@return string
local function colorUpgradeLevelText(text, complete, muted)
  if muted then
    return DISABLED_FONT_COLOR:WrapTextInColorCode(text)
  end
  if complete then
    return GREEN_FONT_COLOR:WrapTextInColorCode(text)
  end
  return text
end

---@param seasonID number?
---@return boolean
local function isUpgradeFromPreviousSeason(seasonID)
  if not seasonID or seasonID < 1 then
    return false
  end
  local currentSeason = LiqUI.Data:GetCurrentSeason()
  if not currentSeason or currentSeason < 1 then
    return false
  end
  return seasonID ~= currentSeason
end

---@param item AE_Equipment
---@return string, string
local function resolveEquipmentUpgradeLevel(item)
  ---@type string[]
  local displayParts = {}
  ---@type string[]
  local sortParts = {}

  local function appendLabel(text, complete, muted)
    table.insert(sortParts, text)
    table.insert(displayParts, colorUpgradeLevelText(text, complete, muted))
  end

  local upgradeLevel = item.itemUpgradeLevel or 0
  local upgradeMax = item.itemUpgradeMax or 0
  if item.itemUpgradeTrack and item.itemUpgradeTrack ~= "" and upgradeLevel > 0 and upgradeMax > 0 then
    local muted = item.itemUpgradeColor ~= nil and item.itemUpgradeColor == DISABLED_FONT_COLOR:GenerateHexColor()
    appendLabel(format("%s %d/%d", item.itemUpgradeTrack, upgradeLevel, upgradeMax), upgradeLevel == upgradeMax, muted)
  end

  local bonusIDs = getItemLinkBonusIDs(item.itemLink)

  if #displayParts == 0 then
    local fallbackTrack
    local fallbackLevel = 0
    local fallbackMax = 0
    TableForEach(bonusIDs, function(bonusId)
      local track, _, bonusIndex = LiqUI.Data:GetUpgradeTrackForBonusID(bonusId)
      if track and track.kind == "crest" and bonusIndex then
        fallbackTrack = track.name
        fallbackLevel = bonusIndex
        fallbackMax = #track.bonusIDs
      end
    end)
    if fallbackTrack then
      appendLabel(format("%s %d/%d", fallbackTrack, fallbackLevel, fallbackMax), fallbackLevel == fallbackMax, true)
    end
  end

  TableForEach(bonusIDs, function(bonusId)
    local track, season = LiqUI.Data:GetUpgradeTrackForBonusID(bonusId)
    if track and track.kind == "label" then
      appendLabel(track.name, true, isUpgradeFromPreviousSeason(season and season.seasonID))
    end
  end)

  local craftedQuality = C_TradeSkillUI.GetItemCraftedQualityByItemInfo(item.itemLink)
  if not craftedQuality then
    TableForEach(bonusIDs, function(bonusId)
      local quality = LiqUI.Data:GetCraftedQuality(bonusId)
      if quality then
        craftedQuality = quality
      end
    end)
  end
  if craftedQuality then
    local craftedSeason
    TableForEach(bonusIDs, function(bonusId)
      if LiqUI.Data:GetCraftedQuality(bonusId) then
        return
      end
      local seasonID = LiqUI.Data:GetCraftedSeason(bonusId)
      if seasonID and (not craftedSeason or seasonID > craftedSeason) then
        craftedSeason = seasonID
      end
    end)
    if not craftedSeason then
      TableForEach(bonusIDs, function(bonusId)
        local seasonID = LiqUI.Data:GetCraftedSeason(bonusId)
        if seasonID and (not craftedSeason or seasonID > craftedSeason) then
          craftedSeason = seasonID
        end
      end)
    end
    appendLabel(format("Crafted %d/%d", craftedQuality, CRAFTED_QUALITY_MAX), craftedQuality == CRAFTED_QUALITY_MAX, isUpgradeFromPreviousSeason(craftedSeason))
  end

  return table.concat(displayParts, " / "), table.concat(sortParts, " / ")
end

---@param item AE_Equipment
---@return string
local function equipmentItemSortName(item)
  local itemID = C_Item.GetItemIDForItemInfo(item.itemLink)
  if itemID then
    local name = C_Item.GetItemNameByID(itemID)
    if name then
      return name
    end
  end
  return item.itemLink or ""
end

---@param rowA AE_EquipmentTableRow
---@param rowB AE_EquipmentTableRow
---@return boolean
local function compareEquipmentTiebreak(rowA, rowB)
  local itemA = rowA.item
  local itemB = rowB.item
  if not itemA or not itemB then
    return false
  end
  if itemA.itemSlotID ~= itemB.itemSlotID then
    return itemA.itemSlotID < itemB.itemSlotID
  end
  local itemIDA = C_Item.GetItemIDForItemInfo(itemA.itemLink) or 0
  local itemIDB = C_Item.GetItemIDForItemInfo(itemB.itemLink) or 0
  return itemIDA < itemIDB
end

---@param rowA AE_EquipmentTableRow
---@param rowB AE_EquipmentTableRow
---@param primaryA number|string
---@param primaryB number|string
---@return boolean
local function compareEquipmentPrimaryThenSlot(rowA, rowB, primaryA, primaryB)
  if primaryA ~= primaryB then
    return primaryA < primaryB
  end
  return compareEquipmentTiebreak(rowA, rowB)
end

---@param rowA AE_EquipmentTableRow
---@param rowB AE_EquipmentTableRow
---@return boolean
local function compareEquipmentSlotColumn(rowA, rowB)
  local itemA = rowA.item
  local itemB = rowB.item
  if not itemA or not itemB then
    return false
  end
  return compareEquipmentPrimaryThenSlot(rowA, rowB, itemA.itemSlotID, itemB.itemSlotID)
end

---@param rowA AE_EquipmentTableRow
---@param rowB AE_EquipmentTableRow
---@return boolean
local function compareEquipmentItemColumn(rowA, rowB)
  local itemA = rowA.item
  local itemB = rowB.item
  if not itemA or not itemB then
    return false
  end
  local nameA = equipmentItemSortName(itemA)
  local nameB = equipmentItemSortName(itemB)
  if nameA ~= nameB then
    return nameA < nameB
  end
  return compareEquipmentTiebreak(rowA, rowB)
end

---@param rowA AE_EquipmentTableRow
---@param rowB AE_EquipmentTableRow
---@return boolean
local function compareEquipmentILvlColumn(rowA, rowB)
  local itemA = rowA.item
  local itemB = rowB.item
  if not itemA or not itemB then
    return false
  end
  return compareEquipmentPrimaryThenSlot(rowA, rowB, itemA.itemLevel, itemB.itemLevel)
end

---@param rowA AE_EquipmentTableRow
---@param rowB AE_EquipmentTableRow
---@return boolean
local function compareEquipmentUpgradeColumn(rowA, rowB)
  return compareEquipmentPrimaryThenSlot(rowA, rowB, rowA.upgradeSort, rowB.upgradeSort)
end

---@param rowA AE_EquipmentTableRow
---@param rowB AE_EquipmentTableRow
---@return boolean
local function compareEquipmentEnchantColumn(rowA, rowB)
  local itemA = rowA.item
  local itemB = rowB.item
  if not itemA or not itemB then
    return false
  end
  return compareEquipmentPrimaryThenSlot(rowA, rowB, rowA.enchantSort, rowB.enchantSort)
end

---@param rowA AE_EquipmentTableRow
---@param rowB AE_EquipmentTableRow
---@return boolean
local function compareEquipmentGemsColumn(rowA, rowB)
  local itemA = rowA.item
  local itemB = rowB.item
  if not itemA or not itemB then
    return false
  end
  return compareEquipmentPrimaryThenSlot(rowA, rowB, rowA.gemCount, rowB.gemCount)
end

function Module:OnInitialize()
  self:Render()
end

function Module:OnEnable()
  addon.Events:RegisterEvent(
    {
      "PLAYER_EQUIPMENT_CHANGED",
      "UNIT_INVENTORY_CHANGED",
    }, function()
      -- addon.Data:UpdateCharacterInfo()
      Data:UpdateEquipment()
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
  local tableWidth = 870
  local rowHeight = 22

  if not self.window then
    local windows = Data.db.global.liqui.windows
    local tables = Data.db.global.liqui.tables
    self.window = LiqUI:NewElement("Window", {
      name = addon.name .. "Equipment",
      storage = windows.Equipment,
      title = "Character",
      onShow = function()
        Module:Render()
      end,
    })
    self.dataTable = LiqUI:NewElement("Table", {
      name = addon.name .. "Equipment",
      storage = tables.Equipment,
      header = {enabled = true, sticky = true, height = EQUIPMENT_HEADER_HEIGHT},
      columns = {
        {id = "slot", headerText = "Slot", width = 100, sorting = {enabled = true, compare = compareEquipmentSlotColumn}},
        {id = "item", headerText = "Item", width = 280, sorting = {enabled = true, compare = compareEquipmentItemColumn}},
        {id = "ilevel", headerText = "iLevel", width = 80, align = "CENTER", sorting = {enabled = true, compare = compareEquipmentILvlColumn}},
        {id = "upgrade", headerText = "Upgrade Level", width = 190, sorting = {enabled = true, compare = compareEquipmentUpgradeColumn}},
        {id = "enchant", headerText = "Enchant", width = 180, sorting = {enabled = true, compare = compareEquipmentEnchantColumn}},
        {id = "gems", headerText = "Gems", width = 80, sorting = {enabled = true, compare = compareEquipmentGemsColumn}},
      },
      rowStyle = {height = rowHeight, striped = true},
      sorting = {
        enabled = true,
        defaultOrder = "asc",
        defaultCompare = compareEquipmentSlotColumn,
      },
    })
    self.dataTable:SetParent(self.window.body)
    self.dataTable:SetPoint("TOPLEFT", self.window.body, "TOPLEFT", 0, 0)
    self.dataTable:SetPoint("BOTTOMRIGHT", self.window.body, "BOTTOMRIGHT", 0, 0)
  end

  local window = self.window
  local dataTable = self.dataTable
  if not window then
    return
  end
  if not dataTable then
    return
  end

  if not window:IsVisible() then
    return
  end

  local character = self.equipmentCharacter
  if not character or type(character.equipment) ~= "table" then
    window:Hide()
    return
  end

  ---@type LiqUI_TableData
  local rows = {}

  TableForEach(character.equipment, function(item)
    local itemID = C_Item.GetItemIDForItemInfo(item.itemLink)

    local upgradeLevel, upgradeSort = resolveEquipmentUpgradeLevel(item)

    local enchantText, enchantTooltip, enchantColor = "", "", GREEN_FONT_COLOR
    ---@type string[]
    local socketTexts = {}
    ---@type string[]
    local socketTooltipLines = {}

    local tooltipData = C_TooltipInfo.GetHyperlink(item.itemLink)
    if tooltipData ~= nil then
      for _, line in pairs(tooltipData.lines) do
        if line.type == Enum.TooltipDataLineType.ItemEnchantmentPermanent then
          enchantText = line.leftText
          enchantTooltip = line.leftText
          -- Extract the enchant value from the enchant line
          local enchantValue = string.match(line.leftText, ENCHANTED_TOOLTIP_LINE:gsub("%%s", "(.*)"))
          if enchantValue ~= nil then
            enchantTooltip = enchantValue
            enchantText = enchantValue

            -- Extract the enchant name and atlas from the enchant line
            local enchantName, enchantAtlas = string.match(enchantValue, "(.*)|A:(.*):20:20|a")
            if enchantName ~= nil then
              enchantText = "|A:" .. enchantAtlas .. ":20:20|a" .. enchantName

              -- Remove the enchant prefix from the name
              local enchantNameSplit = {strsplit("-", enchantName)}
              if enchantNameSplit[2] ~= nil then
                enchantText = "|A:" .. enchantAtlas .. ":20:20|a" .. strtrim(enchantNameSplit[2])
              end
            end
          end
        end

        if line.type == Enum.TooltipDataLineType.GemSocket then
          if line.gemIcon then
            local gemTexture = CreateSimpleTextureMarkup(line.gemIcon, 14, 14)
            table.insert(socketTexts, gemTexture)
            table.insert(socketTooltipLines, gemTexture .. " " .. line.leftText)
          elseif line.socketType then
            local socketTexture = CreateSimpleTextureMarkup(string.format("Interface\\ItemSocketingFrame\\UI-EmptySocket-%s", line.socketType), 14, 14)
            table.insert(socketTexts, socketTexture)
            table.insert(socketTooltipLines, socketTexture .. " " .. line.leftText)
          end
        end
      end
    end

    local inventorySlot = LiqUI.Data:GetInventorySlotByID(item.itemSlotID)

    if enchantText == "" and inventorySlot and inventorySlot.canEnchant then
      enchantText = "Missing"
      enchantColor = DIM_RED_FONT_COLOR
    end

    if TableCount(socketTexts) == 0 and inventorySlot and inventorySlot.canSocket then
      table.insert(socketTexts, DIM_RED_FONT_COLOR:WrapTextInColorCode("Missing"))
    end

    local enchantSort = enchantTooltip ~= "" and enchantTooltip or enchantText
    local gemCount = TableCount(socketTexts)

    ---@type AE_EquipmentTableRow
    local row = {
      item = item,
      upgradeSort = upgradeSort,
      enchantSort = enchantSort,
      gemCount = gemCount,
      data = {
        {data = _G[item.itemSlotName]},
        {
          data = "|T" .. item.itemTexture .. ":0|t " .. item.itemLink,
          onEnter = function(cellFrame)
            GameTooltip:SetOwner(cellFrame, "ANCHOR_RIGHT")
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
        {data = (ITEM_QUALITY_COLORS[item.itemQuality] or WHITE_FONT_COLOR):WrapTextInColorCode(tostring(floor(item.itemLevel)))},
        {data = upgradeLevel},
        {
          data = enchantColor:WrapTextInColorCode(enchantText),
          onEnter = function(cellFrame)
            if enchantTooltip ~= "" then
              GameTooltip:SetOwner(cellFrame, "ANCHOR_RIGHT")
              GameTooltip:AddLine("Enchanted:")
              GameTooltip:AddLine(enchantTooltip, 1, 1, 1)
              GameTooltip:Show()
            end
          end,
          onLeave = function()
            GameTooltip:Hide()
          end,
        },
        {
          data = strjoin(" ", unpack(socketTexts)),
          onEnter = function(cellFrame)
            if TableCount(socketTooltipLines) > 0 then
              GameTooltip:SetOwner(cellFrame, "ANCHOR_RIGHT")
              GameTooltip:AddLine("Gems:")
              TableForEach(socketTooltipLines, function(line)
                GameTooltip:AddLine(line, 1, 1, 1)
              end)
              GameTooltip:Show()
            end
          end,
          onLeave = function()
            GameTooltip:Hide()
          end,
        },
      },
    }
    table.insert(rows, row)
  end)

  local nameColor = WHITE_FONT_COLOR
  if character.info.class.file ~= nil then
    local classColor = C_ClassColor.GetClassColor(character.info.class.file)
    if classColor ~= nil then
      nameColor = CreateColor(classColor.r, classColor.g, classColor.b, 1)
    end
  end

  window:SetTitle(format("%s (%s)", nameColor:WrapTextInColorCode(character.info.name), character.info.realm))
  dataTable:SetData(rows)
  local bodyWidth, bodyHeight = dataTable:GetSize()
  window:SetBodySize(bodyWidth > 0 and bodyWidth or tableWidth, bodyHeight)
end
