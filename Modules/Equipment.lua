---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

---@class AE_Module_Equipment : AceModule
local Module = addon.Core:NewModule("Equipment", "AceConsole-3.0", "AceTimer-3.0")
addon.Module_Equipment = Module

local Slots = {
  [1] = {id = 1, side = "LEFT", name = "Head", canEnchant = true, canSocket = true},
  [2] = {id = 2, side = "LEFT", name = "Neck", canEnchant = false, canSocket = false},
  [3] = {id = 3, side = "LEFT", name = "Shoulder", canEnchant = true, canSocket = false},
  [4] = {id = 4, side = "LEFT", name = "Shirt", canEnchant = false, canSocket = false},
  [5] = {id = 5, side = "LEFT", name = "Chest", canEnchant = true, canSocket = false},
  [6] = {id = 6, side = "RIGHT", name = "Waist", canEnchant = false, canSocket = true},
  [7] = {id = 7, side = "RIGHT", name = "Legs", canEnchant = true, canSocket = false},
  [8] = {id = 8, side = "RIGHT", name = "Feet", canEnchant = true, canSocket = false},
  [9] = {id = 9, side = "LEFT", name = "Wrist", canEnchant = false, canSocket = true},
  [10] = {id = 10, side = "RIGHT", name = "Hands", canEnchant = false, canSocket = false},
  [11] = {id = 11, side = "RIGHT", name = "Finger0", canEnchant = true, canSocket = false},
  [12] = {id = 12, side = "RIGHT", name = "Finger1", canEnchant = true, canSocket = false},
  [13] = {id = 13, side = "RIGHT", name = "Trinket0", canEnchant = false, canSocket = false},
  [14] = {id = 14, side = "RIGHT", name = "Trinket1", canEnchant = false, canSocket = false},
  [15] = {id = 15, side = "LEFT", name = "Back", canEnchant = false, canSocket = false},
  [16] = {id = 16, side = "RIGHT", name = "MainHand", canEnchant = true, canSocket = false},
  [17] = {id = 17, side = "LEFT", name = "SecondaryHand", canEnchant = true, canSocket = false},
  --    [18] = {id = 18, side = "LEFT", name = "Ranged", canEnchant = false},
  --    [19] = {id = 19, side = "LEFT", name = "Tabard", canEnchant = false}
}

function Module:OnInitialize()
  self:Render()
end

function Module:OnEnable()
  addon.Core:RegisterEvent(
    {
      "PLAYER_EQUIPMENT_CHANGED",
      "UNIT_INVENTORY_CHANGED",
    }, function()
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
  local tableWidth = 870
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
      {width = 180},
      {width = 80},
    },
    rows = {
      {
        columns = {
          {text = "Slot",          backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
          {text = "Item",          backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
          {text = "iLevel",        backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
          {text = "Upgrade Level", backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
          {text = "Enchant",       backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
          {text = "Gems",          backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
        },
      },
    },
  }
  tableHeight = tableHeight + 30

  addon.Utils:TableForEach(character.equipment, function(item)
    local itemID = C_Item.GetItemIDForItemInfo(item.itemLink)

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

    ---TWW Season 3 Item: Reshii Wraps
    if itemID == 235499 then
      local ItemLevels = {694, 701, 707, 714, 720, 730}
      local numItemLevels = addon.Utils:TableCount(ItemLevels)
      addon.Utils:TableForEach(ItemLevels, function(ItemLevel, i)
        if item.itemLevel == ItemLevel then
          upgradeLevel = format("%s %d/%d", RANK, i, numItemLevels)
          if i == numItemLevels then
            upgradeLevel = GREEN_FONT_COLOR:WrapTextInColorCode(upgradeLevel)
          end
        end
      end)
    end

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

    if enchantText == "" and Slots[item.itemSlotID] and Slots[item.itemSlotID].canEnchant then
      enchantText = "Missing"
      enchantColor = DIM_RED_FONT_COLOR
    end

    if addon.Utils:TableCount(socketTexts) == 0 and Slots[item.itemSlotID] and Slots[item.itemSlotID].canSocket then
      table.insert(socketTexts, DIM_RED_FONT_COLOR:WrapTextInColorCode("Missing"))
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
        {text = WrapTextInColorCode(tostring(floor(item.itemLevel)), select(4, GetItemQualityColor(item.itemQuality)))},
        {text = upgradeLevel},
        {
          text = enchantColor:WrapTextInColorCode(enchantText),
          onEnter = function(columnFrame)
            if enchantTooltip ~= "" then
              GameTooltip:SetOwner(columnFrame, "ANCHOR_RIGHT")
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
          text = strjoin(" ", unpack(socketTexts)),
          onEnter = function(columnFrame)
            if addon.Utils:TableCount(socketTooltipLines) > 0 then
              GameTooltip:SetOwner(columnFrame, "ANCHOR_RIGHT")
              GameTooltip:AddLine("Gems:")
              addon.Utils:TableForEach(socketTooltipLines, function(line)
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
    table.insert(data.rows, row)
    tableHeight = tableHeight + rowHeight
  end)

  local nameColor = WHITE_FONT_COLOR
  if character.info.class.file ~= nil then
    local classColor = C_ClassColor.GetClassColor(character.info.class.file)
    if classColor ~= nil then
      nameColor = CreateColor(classColor.r, classColor.g, classColor.b, 1)
    end
  end

  self.window:SetTitle(format("%s (%s)", nameColor:WrapTextInColorCode(character.info.name), character.info.realm))
  self.dataTable:SetData(data)
  self.window:SetBodySize(tableWidth, tableHeight)
  addon.Window:SetWindowScale(addon.Data.db.global.interface.windowScale / 100)
  addon.Window:SetWindowBackgroundColor(addon.Data.db.global.interface.windowColor)
end
