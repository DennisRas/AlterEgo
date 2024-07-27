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

-- function Module:GetData()
--   local dungeons = Data:GetDungeons()
--   if not self.data or #self.data < 1 then
--     self.data = {}

--     -- C_EncounterJournal.SetSlotFilter(Enum.ItemSlotFilterType.NoFilter)
--     Utils:TableForEach(dungeons, function(dungeon)
--       EJ_ClearSearch()
--       EJ_ResetLootFilter()
--       EJ_SetLootFilter(0, 0)
--       EJ_SetDifficulty(8)
--       EJ_SelectInstance(dungeon.journalInstanceID)
--       C_EncounterJournal.SetPreviewMythicPlusLevel(5)
--       local numLoot = EJ_GetNumLoot()

--       for i = 1, numLoot do
--         local item = C_EncounterJournal.GetLootInfoByIndex(i)
--         if item.name ~= nil and item.slot ~= nil and item.slot ~= "" then
--           item.stats = C_Item.GetItemStats(item.link)
--           item.dungeon = dungeon
--           DevTools_Dump("Added item: " .. item.name)
--           table.insert(self.data, item)
--         end
--       end
--     end)
--   end
--   return self.data
-- end

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
      {width = 300}, -- Item
      {width = 200}, -- Instance
      {width = 200}, -- Encounter
      -- {width = 80},  -- Classes
      -- {width = 80},  -- Specs
      {width = 140}, -- Slot
      {width = 100}, -- Type
    },
    rows = {
      -- Header
      {
        columns = {
          {text = "Item"},
          {text = "Instance"},
          {text = "Encounter"},
          -- {text = "Classes"},
          -- {text = "Specs"},
          {text = "Slot"},
          {text = "Type"},
        }
      }
    }
  }

  local dungeons = Data:GetDungeons()
  Utils:TableForEach(dungeons, function(dungeon)
    Utils:TableForEach(dungeon.loot, function(item)
      local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
      itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
      expansionID, setID, isCraftingReagent = GetItemInfo(item.link)

      ---@type AE_TableDataRow
      local row = {
        columns = {
          {
            text = "|T" .. itemTexture .. ":0|t " .. item.link,
            onEnter = function(columnFrame)
              GameTooltip:ClearAllPoints()
              GameTooltip:ClearLines()
              GameTooltip:SetOwner(columnFrame, "ANCHOR_RIGHT")
              GameTooltip:SetHyperlink(item.link)
              GameTooltip:AddLine(" ")
              GameTooltip:AddLine("<Shift Click to link to chat>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
              GameTooltip:Show()
            end,
            onLeave = function()
              GameTooltip:Hide()
            end,
            onClick = function()
              if IsModifiedClick("CHATLINK") then
                if not ChatEdit_InsertLink(item.link) then
                  ChatFrame_OpenChat(item.link);
                end
              end
            end
          },
          {text = dungeon.short or dungeon.name},
          {text = item.encounterID},
          -- {text = "-"},
          -- {text = "_"},
          {text = item.slot or "-"},
          {text = item.armorType or "-"},
        }
      }
      table.insert(tableData.rows, row)
    end)
  end)

  local raids = Data:GetRaids()
  Utils:TableForEach(raids, function(raid)
    Utils:TableForEach(raid.loot, function(item)
      local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
      itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
      expansionID, setID, isCraftingReagent = GetItemInfo(item.link)

      ---@type AE_TableDataRow
      local row = {
        columns = {
          {
            text = "|T" .. itemTexture .. ":0|t " .. item.link,
            onEnter = function(columnFrame)
              GameTooltip:ClearAllPoints()
              GameTooltip:ClearLines()
              GameTooltip:SetOwner(columnFrame, "ANCHOR_RIGHT")
              GameTooltip:SetHyperlink(item.link)
              GameTooltip:AddLine(" ")
              GameTooltip:AddLine("<Shift Click to link to chat>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
              GameTooltip:Show()
            end,
            onLeave = function()
              GameTooltip:Hide()
            end,
            onClick = function()
              if IsModifiedClick("CHATLINK") then
                if not ChatEdit_InsertLink(item.link) then
                  ChatFrame_OpenChat(item.link);
                end
              end
            end
          },
          {text = raid.name},
          {text = item.encounterID},
          -- {text = "-"},
          -- {text = "_"},
          {text = item.slot or "-"},
          {text = item.armorType or "-"},
        }
      }
      table.insert(tableData.rows, row)
    end)
  end)

  -- for i = 1, 100 do
  --   ---@type AE_TableDataRow
  --   local row = {
  --     columns = {
  --       {text = "Item"},
  --       {text = "Instance"},
  --       {text = "Encounter"},
  --       {text = "Classes"},
  --       {text = "Specs"},
  --       {text = "Slot"},
  --       {text = "Type"},
  --     }
  --   }
  --   table.insert(tableData.rows, row)
  -- end

  local width = 0
  Utils:TableForEach(tableData.columns, function(column)
    width = width + (column.width or 0)
  end)

  self.window.body.table:SetData(tableData)
  self.window:SetBodySize(width, 500)
  self.window:Show()
end
