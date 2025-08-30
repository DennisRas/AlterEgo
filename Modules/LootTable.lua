---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

---@class AE_Module_LootTable : AceModule
local Module = addon.Core:NewModule("LootTable", "AceEvent-3.0", "AceDB-3.0")

function Module:OnInitialize()
    -- TODO: Initialize module
    -- - Set up database access
    -- - Initialize loot cache
    -- - Create window
    
    -- Access shared database through main addon
    self.db = addon.db
    
    -- Initialize loot cache
    self.lootCache = {}
    self.isCacheInitialized = false
    
    -- Create window
    self:CreateWindow()
end

function Module:OnEnable()
    -- TODO: Register events if needed
end

function Module:OnDisable()
    -- TODO: Cleanup if needed
end

---Create the loot table window
function Module:CreateWindow()
    -- TODO: Create main window
    -- - Use addon.Window:New()
    -- - Set up sidebar and body
    -- - Hide window initially
end

---Create the sidebar
function Module:CreateSidebar()
    -- TODO: Create sidebar with filters
    -- - Add filter dropdowns
    -- - Add search box
    -- - Add clear filters button
end

---Create the main content area
function Module:CreateContent()
    -- TODO: Create main content area
    -- - Add table for displaying loot items
    -- - Add status text
end

---Initialize the loot cache from encounter journal
function Module:InitializeCache()
    -- TODO: Initialize cache
    -- - Query encounter journal for all items
    -- - Store class/spec requirements
    -- - Cache item metadata
    -- - Parse and store item stats for filtering:
    --   - Armor Type (cloth, leather, mail, plate)
    --   - Main stat (int, agi, str)
    --   - Role (tank, healer, dps) - detect from specs
    --   - Secondary stats (crit, haste, mastery, vers)
    --   - Dungeon source (list of dungeons)
    --   - Raid bosses (current raid instance for the season)
    -- - Handle "curios" items (items that open to get tier set pieces)
    
    if self.isCacheInitialized then
        return
    end
    
    print("Initializing loot cache...")
    
    -- Clear existing cache
    self.lootCache = {}
    
    -- Get current season
    local seasonID = addon.Data:GetCurrentSeason()
    
    -- Helper function to process an instance (raid or dungeon)
    local function ProcessInstance(instance, instanceType)
        -- Set up encounter journal for this instance
        EJ_ClearSearch()
        EJ_ResetLootFilter()
        EJ_SelectInstance(instance.journalInstanceID)
        
        -- Get loot for all class/spec combinations
        for classID = 1, GetNumClasses() do
            for specIndex = 1, GetNumSpecializationsForClassID(classID) do
                local specID = GetSpecializationInfoForClassID(classID, specIndex)
                if specID then
                    EJ_SetLootFilter(classID, specID)
                    
                    for i = 1, EJ_GetNumLoot() do
                        local lootInfo = C_EncounterJournal.GetLootInfoByIndex(i)
                        if lootInfo.name ~= nil and lootInfo.slot ~= nil and lootInfo.slot ~= "" then
                            local itemID = lootInfo.itemID
                            
                            -- Skip curios for now (TODO: Handle curios separately)
                            local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType = GetItemInfo(itemID)
                            if itemType == "Miscellaneous" and itemSubType == "Junk" then
                                -- This might be a curio - skip for now
                                -- TODO: Implement curio handling (open to get tier set piece)
                            else
                                -- Find or create item in cache
                                local item = self.lootCache[itemID]
                                if not item then
                                    item = {
                                        -- Basic item info
                                        itemID = itemID,
                                        name = lootInfo.name,
                                        link = lootInfo.link,
                                        quality = lootInfo.quality,
                                        itemLevel = lootInfo.itemLevel,
                                        slot = lootInfo.slot,
                                        texture = lootInfo.texture,
                                        
                                        -- Item stats
                                        stats = C_Item.GetItemStats(lootInfo.link),
                                        
                                        -- Instance info
                                        instanceID = instanceType == "raid" and instance.instanceID or instance.challengeModeID,
                                        instanceName = instance.name,
                                        instanceType = instanceType,
                                        seasonID = instance.seasonID,
                                        
                                        -- Class/spec requirements (will be populated below)
                                        classes = {},
                                        specs = {},
                                        
                                        -- TODO: Add parsed metadata for filtering
                                        -- armorType = nil, -- cloth, leather, mail, plate
                                        -- mainStat = nil,  -- int, agi, str
                                        -- role = nil,      -- tank, healer, dps
                                        -- secondaryStats = {}, -- crit, haste, mastery, vers
                                        -- isCurio = false, -- whether this is a curio item
                                    }
                                    self.lootCache[itemID] = item
                                end
                                
                                -- Mark this class and spec as able to use this item
                                item.classes[classID] = true
                                item.specs[specID] = true
                            end
                        end
                    end
                end
            end
        end
        
        EJ_ResetLootFilter()
    end
    
    -- Get raids and dungeons for current season
    local raids = addon.Data:GetRaids()
    local dungeons = addon.Data:GetDungeons()
    
    -- Process raids
    for _, raid in ipairs(raids) do
        if raid.seasonID == seasonID then
            ProcessInstance(raid, "raid")
        end
    end
    
    -- Process dungeons
    for _, dungeon in ipairs(dungeons) do
        if dungeon.seasonID == seasonID then
            ProcessInstance(dungeon, "dungeon")
        end
    end
    
    -- Convert from lookup table to array for easier iteration
    local itemArray = {}
    for itemID, item in pairs(self.lootCache) do
        table.insert(itemArray, item)
    end
    self.lootCache = itemArray
    
    print("Loot cache initialized with " .. #self.lootCache .. " items")
    self.isCacheInitialized = true
end

---Show the loot table window
function Module:ShowWindow()
    -- TODO: Show window
    -- - Initialize cache if needed
    -- - Update display
    -- - Show window
    
    -- Initialize cache if not already done
    if not self.isCacheInitialized then
        self:InitializeCache()
    end
    
    -- Show the window
    if self.window then
        self.window:Show()
    end
end

---Hide the loot table window
function Module:HideWindow()
    -- TODO: Hide window
end

---Toggle the loot table window visibility
function Module:ToggleWindow()
    -- TODO: Toggle window visibility
end
