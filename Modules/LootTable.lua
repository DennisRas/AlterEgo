---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

---@class AE_Module_LootTable : AceModule
local Module = addon.Core:NewModule("LootTable", "AceEvent-3.0", "AceTimer-3.0")
addon.Module_LootTable = Module

function Module:OnInitialize()
  -- Initialize module
  -- - Set up database access ✓
  -- - Initialize loot cache ✓
  -- - Create window ✓

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
  -- - No events currently needed
end

function Module:OnDisable()
  -- TODO: Cleanup if needed
  -- - No cleanup currently needed
end

---Create the loot table window
function Module:CreateWindow()
  -- Create main window ✓
  -- - Use addon.Window:New() ✓
  -- - Set up sidebar and body ✓
  -- - Hide window initially ✓

  -- Create main window with built-in sidebar
  self.window = addon.Window:New({
    title = "Loot Table",
    sidebar = 250, -- Use built-in sidebar functionality
    width = 1150,  -- Body width (1150 + 250 sidebar = 1400 total)
    height = 570,  -- Body height (570 + 30 titlebar = 600 total)
    resizable = true,
    minimizable = true,
    maximizable = true,
  })

  -- Create a simple overlay frame that covers both sidebar and content (below titlebar)
  self.overlayFrame = CreateFrame("Frame", "$parentOverlay", self.window)
  self.overlayFrame:SetFrameLevel(self.window:GetFrameLevel() + 10)
  self.overlayFrame:SetPoint("TOPLEFT", self.window, "TOPLEFT", 0, -30)       -- Below titlebar
  self.overlayFrame:SetPoint("BOTTOMRIGHT", self.window, "BOTTOMRIGHT", 0, 0) -- Cover entire window

  -- Add background to make overlay visible using Utils (use header color from constants)
  addon.Utils:SetBackgroundColor(self.overlayFrame, 0, 0, 0, 0.95)

  -- Create status bar centered in the overlay
  self.statusBar = addon.Input:CreateStatusBar({
    parent = self.overlayFrame,
    text = "Ready",
    value = 0,
    maxValue = 100,
    width = 1000,                                         -- Much wider bar for longer text
    height = 40,                                          -- Taller bar with more padding
    progressColor = {r = 0.1, g = 0.3, b = 0.5, a = 1.0}, -- Darker, more muted blue
  })

  -- Center the status bar in the overlay
  self.statusBar:SetPoint("CENTER", self.overlayFrame, "CENTER", 0, 0)

  -- Hide overlay initially (will show when loading starts)
  self.overlayFrame:Hide()

  -- Create sidebar and content using the built-in sidebar
  self:CreateSidebar()
  self:CreateContent()

  -- Hide window initially
  self.window:Hide()
end

---Create the sidebar
function Module:CreateSidebar()
  -- Use the built-in sidebar from the window
  self.sidebar = self.window.sidebar

  -- TODO: Add filter components using addon.Input
  -- - Search textbox
  -- - Class dropdown
  -- - Spec dropdown
  -- - Instance dropdown
  -- - Clear filters button
end

---Create the main content area
function Module:CreateContent()
  -- Create main content area ✓
  -- - Add table for displaying loot items ✓
  -- - Add status text (removed - redundant with status bar)

  -- Use the existing body area directly (no need for extra content frame)
  self.content = self.window.body

  -- Create table for loot items
  self.lootTable = addon.Table:New({
    rows = {
      height = 22,
      striped = true,
    },
    header = {
      sticky = true,
      height = 30,
      sortable = true,
      clickable = true,
    },
  })

  -- Set parent and position
  self.lootTable:SetParent(self.content)
  self.lootTable:SetAllPoints()
end

---Calculate the total number of steps for cache initialization
function Module:CalculateCacheSteps()
  local totalSteps = 0
  -- Get current season
  local seasonID = addon.Data:GetCurrentSeason()

  -- Get raids and dungeons for current season
  local raids = addon.Data:GetRaids()
  local dungeons = addon.Data:GetDungeons()

  -- Prepare instance list
  local instances = {}
  for _, raid in ipairs(raids) do
    if raid.seasonID == seasonID then
      table.insert(instances, {instance = raid, type = "raid"})
    end
  end
  for _, dungeon in ipairs(dungeons) do
    if dungeon.seasonID == seasonID then
      table.insert(instances, {instance = dungeon, type = "dungeon"})
    end
  end

  -- Prepare class/spec combinations
  local classSpecs = {}
  for classID = 1, GetNumClasses() do
    for specIndex = 1, GetNumSpecializationsForClassID(classID) do
      local specID = GetSpecializationInfoForClassID(classID, specIndex)
      if specID then
        table.insert(classSpecs, {classID = classID, specID = specID})
      end
    end
  end

  totalSteps = #instances * #classSpecs
  return totalSteps
end

---Update status display
function Module:UpdateStatus(text, progress, maxProgress)
  if self.statusBar and self.overlayFrame then
    -- Show overlay when updating
    if not self.overlayFrame:IsShown() then
      self.overlayFrame:Show()
    end

    self.statusBar:SetText(text or "Processing...")
    if progress and maxProgress then
      self.statusBar:SetValue(progress)
      self.statusBar:SetMaxValue(maxProgress)
    end
  end
end

---Initialize the loot cache from encounter journal
function Module:InitializeCache()
  if self.isCacheInitialized then
    return
  end

  -- Reset encounter journal filters to get all items
  self.savedSlotFilter = C_EncounterJournal.GetSlotFilter()
  C_EncounterJournal.ResetSlotFilter()

  -- Initialize tracking data
  self.itemTypeCounts = {weapons = 0, armor = 0, other = 0}
  self.uniqueSlots = {}
  self.lootCache = {}

  -- Get current season instances
  local seasonID = addon.Data:GetCurrentSeason()
  local instances = {}

  for _, raid in ipairs(addon.Data:GetRaids()) do
    if raid.seasonID == seasonID then
      table.insert(instances, {instance = raid, type = "raid"})
    end
  end

  for _, dungeon in ipairs(addon.Data:GetDungeons()) do
    if dungeon.seasonID == seasonID then
      table.insert(instances, {instance = dungeon, type = "dungeon"})
    end
  end

  -- Prepare class/spec combinations
  local classSpecs = {}
  for classID = 1, GetNumClasses() do
    for specIndex = 1, GetNumSpecializationsForClassID(classID) do
      local specID = GetSpecializationInfoForClassID(classID, specIndex)
      if specID then
        table.insert(classSpecs, {classID = classID, specID = specID})
      end
    end
  end

  -- Initialize progressive loading
  local totalSteps = self:CalculateCacheSteps()
  self:UpdateStatus("Preparing to cache loot data...", 0, totalSteps)

  self.cacheState = {
    instances = instances,
    classSpecs = classSpecs,
    currentInstanceIndex = 1,
    currentClassSpecIndex = 1,
    totalSteps = totalSteps,
    currentStep = 0,
  }

  self:ProcessNextCacheStep()
end

---Process next step in cache initialization
function Module:ProcessNextCacheStep()
  if not self.cacheState then
    return
  end

  local state = self.cacheState

  -- Check if we're done
  if state.currentInstanceIndex > #state.instances then
    -- Convert from lookup table to array for easier iteration
    local itemArray = {}
    for itemID, item in pairs(self.lootCache) do
      table.insert(itemArray, item)
    end
    self.lootCache = itemArray

    self.isCacheInitialized = true

    -- Update status
    self:UpdateStatus("Caching complete!", state.totalSteps, state.totalSteps)

    -- Populate table with cached items
    self:PopulateTable()

    -- Hide overlay after completion
    if self.overlayFrame then
      self.overlayFrame:Hide()
    end

    -- Restore player's encounter journal slot filter
    -- This follows the same pattern as the official encounter journal code
    if self.savedSlotFilter then
      C_EncounterJournal.SetSlotFilter(self.savedSlotFilter)
    end
    self.savedSlotFilter = nil

    -- Clear cache state
    self.cacheState = nil

    return
  end

  local instanceData = state.instances[state.currentInstanceIndex]
  local classSpecData = state.classSpecs[state.currentClassSpecIndex]

  -- Update status with percentage and instance info
  local percentage = math.floor((state.currentStep / state.totalSteps) * 100)
  local statusText = string.format("Caching %s - %d%%",
                                   instanceData.instance.name,
                                   percentage)
  self:UpdateStatus(statusText, state.currentStep, state.totalSteps)

  -- Process this instance/class/spec combination
  self:ProcessInstanceClassSpec(instanceData.instance, instanceData.type, classSpecData.classID, classSpecData.specID)

  -- Move to next step
  state.currentClassSpecIndex = state.currentClassSpecIndex + 1
  if state.currentClassSpecIndex > #state.classSpecs then
    state.currentClassSpecIndex = 1
    state.currentInstanceIndex = state.currentInstanceIndex + 1
  end
  state.currentStep = state.currentStep + 1

  -- Schedule next step with minimal delay for faster processing
  self:ScheduleTimer(function()
                       self:ProcessNextCacheStep()
                     end, 0.01) -- 10ms delay - fast but still prevents freezing
end

---Get encounter information for an instance
function Module:GetInstanceEncounters(instance, instanceType)
  local encounters = {}

  -- Select the instance in the encounter journal
  EJ_SelectInstance(instance.journalInstanceID)

  -- Get all encounters for this instance
  local encounterIndex = 1
  local _, _, bossID = EJ_GetEncounterInfoByIndex(encounterIndex, instance.journalInstanceID)

  while bossID do
    local name, description, journalEncounterID, journalEncounterSectionID, journalLink, journalInstanceID, instanceEncounterID, instanceID = EJ_GetEncounterInfoByIndex(encounterIndex, instance.journalInstanceID)

    if name then
      encounters[encounterIndex] = {
        index = encounterIndex,
        name = name,
        description = description,
        journalEncounterID = journalEncounterID,
        journalEncounterSectionID = journalEncounterSectionID,
        journalLink = journalLink,
        journalInstanceID = journalInstanceID,
        instanceEncounterID = instanceEncounterID,
        instanceID = instanceID,
      }
    end

    encounterIndex = encounterIndex + 1
    _, _, bossID = EJ_GetEncounterInfoByIndex(encounterIndex, instance.journalInstanceID)
  end

  return encounters
end

---Process a single instance/class/spec combination
function Module:ProcessInstanceClassSpec(instance, instanceType, classID, specID)
  -- Get encounter information for this instance (only once per instance)
  if not self.instanceEncounters then
    self.instanceEncounters = {}
  end

  local instanceKey = instance.journalInstanceID
  if not self.instanceEncounters[instanceKey] then
    self.instanceEncounters[instanceKey] = self:GetInstanceEncounters(instance, instanceType)
  end

  local encounters = self.instanceEncounters[instanceKey]

  -- Process each encounter to get its loot
  for encounterIndex, encounter in pairs(encounters) do
    -- Set up encounter journal for this specific encounter
    EJ_ClearSearch()
    EJ_ResetLootFilter()
    EJ_SelectInstance(instance.journalInstanceID)
    EJ_SelectEncounter(encounter.journalEncounterID)
    EJ_SetLootFilter(classID, specID)

    -- Get loot for this encounter/class/spec combination
    for i = 1, EJ_GetNumLoot() do
      local lootInfo = C_EncounterJournal.GetLootInfoByIndex(i)
      if lootInfo.name ~= nil and lootInfo.slot ~= nil and lootInfo.slot ~= "" then
        local itemID = lootInfo.itemID

        -- Track unique slots for debugging
        if lootInfo.slot then
          self.uniqueSlots[lootInfo.slot] = (self.uniqueSlots[lootInfo.slot] or 0) + 1
        end

        -- Count item types for debugging (use slot to determine type)
        if lootInfo.slot and (lootInfo.slot == "One-Hand" or lootInfo.slot == "Two-Hand" or lootInfo.slot == "Main Hand" or lootInfo.slot == "Off Hand") then
          self.itemTypeCounts.weapons = self.itemTypeCounts.weapons + 1
        elseif lootInfo.slot and (lootInfo.slot == "Head" or lootInfo.slot == "Chest" or lootInfo.slot == "Shoulder" or lootInfo.slot == "Back" or lootInfo.slot == "Wrist" or lootInfo.slot == "Hands" or lootInfo.slot == "Waist" or lootInfo.slot == "Legs" or lootInfo.slot == "Feet" or lootInfo.slot == "Finger" or lootInfo.slot == "Trinket") then
          self.itemTypeCounts.armor = self.itemTypeCounts.armor + 1
        else
          self.itemTypeCounts.other = self.itemTypeCounts.other + 1
        end

        -- Find or create item in cache
        local item = self.lootCache[itemID]
        if not item then
          item = {
            -- Basic item info
            itemID = itemID,
            name = lootInfo.name,
            link = lootInfo.link,
            quality = lootInfo.itemQuality,
            slot = lootInfo.slot,
            texture = lootInfo.icon,
            armorType = lootInfo.armorType or "Unknown",

            -- Instance info
            instanceID = instanceType == "raid" and instance.instanceID or instance.challengeModeID,
            instanceName = instance.name,
            instanceType = instanceType,
            seasonID = instance.seasonID,

            -- Metadata
            stats = C_Item.GetItemStats(lootInfo.link),
            encounters = {},
            difficulties = {},
            classes = {},
            specs = {},

            -- Error flags
            handError = lootInfo.handError,
            weaponTypeError = lootInfo.weaponTypeError,
            filterType = lootInfo.filterType,
          }
          self.lootCache[itemID] = item
        end

        -- Mark this class and spec as able to use this item
        item.classes[classID] = true
        item.specs[specID] = true

        -- Track encounter source
        local numEncounters = EJ_GetNumEncountersForLootByIndex(i)
        if numEncounters == 1 then
          item.encounters[encounter.journalEncounterID] = {
            name = encounter.name,
            index = encounter.index,
            journalEncounterID = encounter.journalEncounterID,
          }
        elseif numEncounters == 2 then
          local itemInfoSecond = C_EncounterJournal.GetLootInfoByIndex(i, 2)
          local secondEncounterID = itemInfoSecond and itemInfoSecond.encounterID
          if encounter.journalEncounterID and secondEncounterID then
            item.encounters[encounter.journalEncounterID] = {
              name = encounter.name,
              index = encounter.index,
              journalEncounterID = encounter.journalEncounterID,
            }
            if secondEncounterID then
              item.encounters[secondEncounterID] = {
                name = "Multiple Encounters",
                index = 0,
                journalEncounterID = secondEncounterID,
              }
            end
          end
        elseif numEncounters > 2 then
          item.encounters[encounter.journalEncounterID] = {
            name = "Multiple Encounters",
            index = encounter.index,
            journalEncounterID = encounter.journalEncounterID,
          }
        end

        -- Track difficulty
        if instanceType == "raid" then
          local difficultyID = EJ_GetDifficulty()
          local difficultyName = "Normal"

          if difficultyID == 15 then
            difficultyName = "Heroic"
          elseif difficultyID == 16 then
            difficultyName = "Mythic"
          elseif difficultyID == 14 then
            difficultyName = "LFR"
          end

          item.difficulties[difficultyName] = true
        else
          item.difficulties["Mythic+"] = true
        end
      end
    end
  end

  EJ_ResetLootFilter()
end

---Populate the table with cached items
function Module:PopulateTable()
  if not self.lootTable or not self.lootCache then
    return
  end

  ---@type AE_TableData
  local data = {
    columns = {
      {width = 350, sortable = true, sortKey = "name"},     -- Item (icon + name)
      {width = 150, sortable = true, sortKey = "slot"},     -- Slot
      {width = 150, sortable = true, sortKey = "type"},     -- Type
      {width = 250, sortable = true, sortKey = "source"},   -- Source
      {width = 250, sortable = true, sortKey = "instance"}, -- Instance
    },
    rows = {
      {
        columns = {
          {text = "Item",     backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
          {text = "Slot",     backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
          {text = "Type",     backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
          {text = "Source",   backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
          {text = "Instance", backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
        },
      },
    },
  }

  -- Add custom sorting callbacks to columns
  data.columns[1].sortCallback = function(aValue, bValue, direction, aRow, bRow)
    -- Sort by item name (strip color codes and icons)
    local aName = aRow.itemData and aRow.itemData.name or ""
    local bName = bRow.itemData and bRow.itemData.name or ""

    if direction == "asc" then
      return aName < bName
    else
      return aName > bName
    end
  end

  -- Add item rows
  for _, item in ipairs(self.lootCache) do
    -- Apply quality color to item name
    local itemText = item.name or "Unknown Item"
    if item.quality then
      itemText = WrapTextInColorCode(itemText, item.quality)
    else
      itemText = WrapTextInColorCode(itemText, WHITE_FONT_COLOR:GenerateHexColor())
    end

    -- Generate source text
    local sourceText = "Unknown"
    if item.encounters and next(item.encounters) then
      local encounterNames = {}
      for _, encounter in pairs(item.encounters) do
        if encounter.name and encounter.name ~= "Multiple Encounters" then
          table.insert(encounterNames, encounter.name)
        end
      end

      if #encounterNames == 1 then
        sourceText = encounterNames[1]
      elseif #encounterNames == 2 then
        sourceText = string.format("%s, %s", encounterNames[1], encounterNames[2])
      elseif #encounterNames > 2 then
        sourceText = string.format("%s +%d more", encounterNames[1], #encounterNames - 1)
      else
        sourceText = "Multiple Encounters"
      end
    end

    ---@type AE_TableDataRow
    local row = {
      itemData = item, -- Store item data for custom sorting
      columns = {
        {
          text = "|T" .. (item.texture or "") .. ":0|t " .. itemText,
          onEnter = function(columnFrame)
            if item.link then
              GameTooltip:SetOwner(columnFrame, "ANCHOR_RIGHT")
              GameTooltip:SetHyperlink(item.link)
              GameTooltip:AddLine(" ")
              GameTooltip:AddLine("<Shift Click to Link to Chat>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
              GameTooltip:Show()
            end
          end,
          onLeave = function()
            GameTooltip:Hide()
          end,
          onClick = function()
            if IsModifiedClick("CHATLINK") then
              if not ChatEdit_InsertLink(item.link) then
                ChatFrame_OpenChat(item.link)
              end
            end
          end,
        },
        {
          text = item.slot or "Unknown",
        },
        {
          text = item.armorType or "Unknown",
        },
        {
          text = sourceText,
        },
        {
          text = item.instanceName or "Unknown",
        },
      },
    }

    table.insert(data.rows, row)
  end

  -- Update table data (keep window size fixed)
  self.lootTable:SetData(data)
end

---Custom sorting callback for item quality
---@param aValue string
---@param bValue string
---@param direction "asc"|"desc"
---@param aRow AE_TableDataRow
---@param bRow AE_TableDataRow
---@return boolean
function Module:SortByQuality(aValue, bValue, direction, aRow, bRow)
  -- Extract quality from item data (assuming it's stored in the row data)
  local aQuality = aRow.itemData and aRow.itemData.quality or 1
  local bQuality = bRow.itemData and bRow.itemData.quality or 1

  if direction == "asc" then
    return aQuality < bQuality
  else
    return aQuality > bQuality
  end
end

---Custom sorting callback for item level
---@param aValue string
---@param bValue string
---@param direction "asc"|"desc"
---@param aRow AE_TableDataRow
---@param bRow AE_TableDataRow
---@return boolean
function Module:SortByItemLevel(aValue, bValue, direction, aRow, bRow)
  -- Extract item level from item data
  local aIlvl = aRow.itemData and aRow.itemData.itemLevel or 0
  local bIlvl = bRow.itemData and bRow.itemData.itemLevel or 0

  if direction == "asc" then
    return aIlvl < bIlvl
  else
    return aIlvl > bIlvl
  end
end

-- =============================================================
-- TODO: Future Enhancements
-- =============================================================

-- TODO: Implement filter components in CreateSidebar()
-- - Search textbox for item name filtering
-- - Class/Spec dropdowns for filtering usable items
-- - Instance/Difficulty dropdowns
-- - Type dropdown (Cloth, Leather, Mail, Plate, etc.)
-- - Clear filters button

-- TODO: Implement additional metadata parsing
-- - Parse main stat (int, agi, str) from item stats
-- - Parse role (tank, healer, dps) from spec requirements
-- - Parse secondary stats (crit, haste, mastery, vers)
-- - Handle "curios" items (items that open to get tier set pieces)

-- TODO: Implement sorting and performance optimizations
-- - Sort by item name, slot, type, source, instance
-- - Sort by quality (epic > rare > uncommon > common)
-- - Virtual scrolling for large item lists
-- - Debounced search/filter updates

---Show the loot table window
function Module:ShowWindow()
  self:InitializeCache()

  if self.window then
    self.window:Show()
  end
end

---Hide the loot table window
function Module:HideWindow()
  if self.window then
    self.window:Hide()
  end
end

---Toggle the loot table window visibility
function Module:ToggleWindow()
  if self.window then
    if self.window:IsShown() then
      self:HideWindow()
    else
      self:ShowWindow()
    end
  end
end
