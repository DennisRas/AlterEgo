local addonName = select(1, ...)
local addon = select(2, ...)

local Items = {
    itemData = {},
    unsavedItemData = {},
    instanceData = {},
    showAllItems = false,
    minItemLevel = 623, -- TWW S2 : veteran 1/8
    maxItemLevel = 678, -- TWW S2 : mythic 6/6
    invTypes = {
        [1] = "INVTYPE_HEAD",
        [2] = "INVTYPE_NECK",
        [3] = "INVTYPE_SHOULDER",
        [4] = "INVTYPE_BODY",
        [5] = {"INVTYPE_CHEST", "INVTYPE_ROBE"},
        [6] = "INVTYPE_WAIST",
        [7] = "INVTYPE_LEGS",
        [8] = "INVTYPE_FEET",
        [9] = "INVTYPE_WRIST",
        [10] = "INVTYPE_HAND",
        [11] = "INVTYPE_FINGER",
        [12] = "INVTYPE_FINGER",
        [13] = "INVTYPE_TRINKET",
        [14] = "INVTYPE_TRINKET",
        [15] = "INVTYPE_CLOAK",
        [16] = {"INVTYPE_WEAPON", "INVTYPE_2HWEAPON", "INVTYPE_WEAPONMAINHAND", "INVTYPE_RANGED", "INVTYPE_RANGEDRIGHT", "INVTYPE_NON_EQUIP"},
        [17] = {"INVTYPE_WEAPONOFFHAND", "INVTYPE_SHIELD", "INVTYPE_WEAPON", "INVTYPE_HOLDABLE", "INVTYPE_NON_EQUIP"},
        --[18] = {"INVTYPE_RANGED", "INVTYPE_THROWN", "INVTYPE_RANGEDRIGHT", "INVTYPE_RELIC"}
      }
}
addon.Items = Items

function Items:RegisterInstance(instanceId, difficulty, bonuses)
    local info = C_Map.GetMapInfo(instanceId)
    if not info then
        assert(false, "Instance " .. instanceId .. " not found")
        return
    end

    self.instanceData[info.mapID] = {
        id = info.mapID,
        name = info.name,
        difficulty = difficulty or 1,
        bonuses = bonuses
    }

    return self.instanceData[info.mapID]
end

-- @param #object instance The instance to register the items for
--      instanceId The difficulty of the instance
--      infoId Encounter info id
--      items The items that drop from the boss
function Items:RegisterBossLoots(bossLoots)
    local instance = self.instanceData[bossLoots.instanceId]
    if not instance then
        assert(false, "Instance " .. (bossLoots.instanceId or "nil") .. " not found")
        return
    end

    ---@diagnostic disable-next-line: undefined-global
    local bossName = EJ_GetEncounterInfo(bossLoots.infoId)
    if not bossName then
        assert(false, "Encounter " .. bossLoots.infoId .. " not found")
        return
    end

    for _, itemId in ipairs(bossLoots.items) do
        if not self.itemData[itemId] then
            local itemData = self:GetItemData(itemId, instance, bossName)
            if itemData then
                self.itemData[itemId] = itemData
            else
                self.unsavedItemData[itemId] = {
                    instanceId = instance.id,
                    infoId = bossLoots.infoId
                }
            end
        end
    end
end

function Items:GetItemData(itemId, instance, bossName)
    local itemString = self:GetItemString(itemId, instance.difficulty, instance.bonuses)
    local name, link, _, _, _, _, _, _, invType, texture = C_Item.GetItemInfo(itemString)
    if link then
        -- TODO: use the new GetDetailedItemLevelInfo after 11.1.5
        local actualLevel = C_Item.GetDetailedItemLevelInfo(link)
        local maxLevel = self:GetItemLevelFromTooltip(link, actualLevel)

        self.itemData[itemId] = {
            id = itemId,
            name = name,
            link = link,
            invType = invType,
            texture = texture,
            instanceName = instance.name,
            bossName = bossName,
            maxLevel = maxLevel
        }

        return self.itemData[itemId]
    end

    return nil
end

function Items:ParseIdFromLink(link)
    local itemId = 0
    local _, _, id = link:find("item:(%d+)")
    if id then
      local toNumber = tonumber(id)
      itemId = toNumber or 0
    end

    return itemId
end

function Items:RegisterItem(itemId)
    local item = self.unsavedItemData[itemId]
    if item then
        local instance = self.instanceData[item.instanceId]
        local bossName = EJ_GetEncounterInfo(item.infoId)
        if instance == nil or bossName == nil then
            return
        end

        local itemData = self:GetItemData(itemId, instance, bossName)

        if itemData then
            self.itemData[itemId] = itemData
            self.unsavedItemData[itemId] = nil
        end
    end
end

local upgradePattern = ITEM_UPGRADE_TOOLTIP_FORMAT_STRING
upgradePattern = upgradePattern:gsub("%%d", "%%s")
upgradePattern = upgradePattern:format("(.*)", "(%d+)", "(%d+)")

function Items:GetItemLevelFromTooltip(link, actualLevel)
    local scanTooltip = CreateFrame("GameTooltip", "AlterEgoScanTooltip", UIParent, "GameTooltipTemplate")
    scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    scanTooltip:SetHyperlink(link)

    local maxLevel = actualLevel
    for i = 2, scanTooltip:NumLines() do 
        local line = _G["AlterEgoScanTooltipTextLeft" .. i]:GetText()
        if line then
            local match, _, uTrack, uLevel, uMax = line:find(upgradePattern)
            if match then
                -- upgradable item, set to max level
                return actualLevel < self.maxItemLevel and self.maxItemLevel or actualLevel
            end
        end
    end

    return maxLevel
end

function Items:GetItemsBySlot(slotId, classId)
    local items = {}
    local invType = self.invTypes[slotId]
    for item, data in pairs(self.itemData) do
        local isItemForSlot = false
        if type(invType) == "table" then
            isItemForSlot = addon.Utils:TableContains(invType, data.invType)
        else
            isItemForSlot = data.invType == invType
        end

        if isItemForSlot then
            if classId == nil then
                table.insert(items, data)
            else
                local doesItemContainClass = C_Item.DoesItemContainSpec(item, classId)
                if doesItemContainClass then
                    table.insert(items, data)
                end
            end
        end
    end

    table.sort(items, function(a, b)
        return strcmputf8i(a.name, b.name) < 0
    end)

    return items
end

--item:itemId:enchantId:gemId1:gemId2:gemId3:gemId4:suffixId:uniqueId:linkLevel:specializationID:upgradeId:instanceDifficultyId:numBonusIds:bonusId1:bonusId2:upgradeValue
function Items:GetItemString(itemId, difficulty, bonuses)
    local baseItemString = ("item:%d"):format(itemId)
    local enchantString = ":::::::::::"
    local difficultyString = ("%d:"):format(difficulty)
    local nbBonuses = ("%d:"):format(#bonuses)
    local bonusString = "";
    for _, bonus in ipairs(bonuses) do
        bonusString = ("%s%d:"):format(bonusString, bonus)
    end
    for i = #bonuses + 1, 5 do
        bonusString = bonusString .. ":"
    end

    local itemString = ("%s%s%s%s%s"):format(baseItemString, enchantString, difficultyString, nbBonuses, bonusString)
    return itemString
end
