---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

---@class AE_Module_LootTable : AceModule
local Module = addon.Core:NewModule("LootTable", "AceEvent-3.0", "AceTimer-3.0", "AceSerializer-3.0")
addon.Module_LootTable = Module

---Initialize the loot table module
function Module:OnInitialize()
  self.db = addon.Data.db
  self.cache = {
    loot = {},
    classSpec = nil,
    instances = nil,
    encounters = {},
  }
  self.isCacheInitialized = false
  self:RegisterStaticPopups()
  self:CreateWindow()
end

---Compress loot cache data for storage
---@return string
function Module:CompressCache()
  -- Convert cache to a minimal representation
  local compressed = {}

  for itemID, item in pairs(self.cache.loot) do
    local compressedItem = {
      id = item.itemID,
      n = item.name,
      l = item.link,
      q = item.quality,
      s = item.slot,
      t = item.texture,
      a = item.armorType,
      iid = item.instanceID,
      jid = item.journalInstanceID,
      iname = item.instanceName,
      itype = item.instanceType,
      sid = item.seasonID,
      st = item.stats, -- Add stats
      e = {},
      d = {},
      c = {},
      sp = {},
    }

    -- Compress encounters
    for encounterID, encounter in pairs(item.encounters) do
      compressedItem.e[encounterID] = {
        n = encounter.name,
        i = encounter.index,
        jid = encounter.journalEncounterID,
      }
    end

    -- Compress difficulties (convert to array)
    for difficulty, _ in pairs(item.difficulties) do
      table.insert(compressedItem.d, difficulty)
    end

    -- Compress classes (convert to array)
    for classID, _ in pairs(item.classes) do
      table.insert(compressedItem.c, classID)
    end

    -- Compress specs (convert to array)
    for specID, _ in pairs(item.specs) do
      table.insert(compressedItem.sp, specID)
    end

    compressed[itemID] = compressedItem
  end

  -- Serialize to string
  return self:Serialize(compressed)
end

---Decompress loot cache data from storage
---@param compressedData string
---@return boolean success
function Module:DecompressCache(compressedData)
  if not compressedData or compressedData == "" then
    return false
  end

  -- Deserialize from string
  local success, compressed = self:Deserialize(compressedData)
  if not success then
    return false
  end

  -- Ensure compressed is a table
  if type(compressed) ~= "table" then
    return false
  end

  -- Convert back to full representation
  self.cache.loot = {}

  for itemID, compressedItem in pairs(compressed) do
    local item = {
      itemID = compressedItem.id,
      name = compressedItem.n,
      link = compressedItem.l,
      quality = compressedItem.q,
      slot = compressedItem.s,
      texture = compressedItem.t,
      armorType = compressedItem.a,
      instanceID = compressedItem.iid,
      journalInstanceID = compressedItem.jid,
      instanceName = compressedItem.iname,
      instanceType = compressedItem.itype,
      seasonID = compressedItem.sid,
      stats = compressedItem.st, -- Add stats
      encounters = {},
      difficulties = {},
      classes = {},
      specs = {},
    }

    -- Decompress encounters
    for encounterID, encounter in pairs(compressedItem.e) do
      item.encounters[encounterID] = {
        name = encounter.n,
        index = encounter.i,
        journalEncounterID = encounter.jid,
      }
    end

    -- Decompress difficulties
    for _, difficulty in ipairs(compressedItem.d) do
      item.difficulties[difficulty] = true
    end

    -- Decompress classes
    for _, classID in ipairs(compressedItem.c) do
      item.classes[classID] = true
    end

    -- Decompress specs
    for _, specID in ipairs(compressedItem.sp) do
      item.specs[specID] = true
    end

    self.cache.loot[itemID] = item
  end

  return true
end

---Save the current loot cache to the database
function Module:SaveCacheToDatabase()
  if not self.cache.loot or not next(self.cache.loot) then
    return
  end

  local currentSeason = addon.Data:GetCurrentSeason()
  local compressedData = self:CompressCache()

  if compressedData then
    self.db.global.lootCache = {
      version = 1,
      seasonID = currentSeason,
      lastUpdate = time(),
      compressedData = compressedData,
    }
  end
end

---Enable the loot table module
function Module:OnEnable()
  -- TODO: Register events if needed
  -- - No events currently needed
end

---Disable the loot table module
function Module:OnDisable()
  -- TODO: Cleanup if needed
  -- - No cleanup currently needed
end

---Create the loot table window
function Module:CreateWindow()
  self.window = addon.Window:New({
    title = "Loot Table",
    sidebar = 250, -- Use built-in sidebar functionality
    width = 1240,  -- Body width (1190 + 250 sidebar = 1440 total)
    height = 570,  -- Body height (570 + 30 titlebar = 600 total)
    resizable = true,
    minimizable = true,
    maximizable = true,
  })

  self.overlayFrame = CreateFrame("Frame", "$parentOverlay", self.window)
  self.overlayFrame:SetFrameLevel(self.window:GetFrameLevel() + 10)
  self.overlayFrame:SetPoint("TOPLEFT", self.window, "TOPLEFT", 0, -30)
  self.overlayFrame:SetPoint("BOTTOMRIGHT", self.window, "BOTTOMRIGHT", 0, 0)

  addon.Utils:SetBackgroundColor(self.overlayFrame, 0, 0, 0, 0.95)

  self.statusBar = addon.Input:CreateStatusBar({
    parent = self.overlayFrame,
    text = "Ready",
    value = 0,
    maxValue = 100,
    width = 1000,                                         -- Much wider bar for longer text
    height = 40,                                          -- Taller bar with more padding
    progressColor = {r = 0.1, g = 0.3, b = 0.5, a = 1.0}, -- Darker, more muted blue
  })

  self.statusBar:SetPoint("CENTER", self.overlayFrame, "CENTER", 0, 0)

  self.overlayFrame:Hide()
  self:CreateSidebar()
  self:CreateContent()
  self:AddCacheResetButton()
  self.window:Hide()
end

---Create the sidebar area
function Module:CreateSidebar()
  self.sidebar = self.window.sidebar
end

---Create the main content area
function Module:CreateContent()
  self.content = self.window.body

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

  self.lootTable:SetParent(self.content)
  self.lootTable:SetAllPoints()
end

---Add cache reset button to titlebar
function Module:AddCacheResetButton()
  self.window:AddTitlebarButton({
    name = "CacheReset",
    icon = addon.Constants.media.IconSettings,
    tooltipTitle = "Reset Cache",
    tooltipDescription = "Clear cached loot data and rebuild from scratch",
    onClick = function()
      self:ResetCache()
    end,
  })
end

---Reset the loot cache and rebuild
function Module:ResetCache()
  -- Show confirmation dialog
  StaticPopup_Show("ALTEREGO_LOOT_CACHE_RESET")
end

---Perform the actual cache reset
function Module:PerformCacheReset()
  -- Clear all cache data
  self.cache.loot = {}
  self.cache.classSpec = nil
  self.cache.instances = nil
  self.cache.encounters = {}
  self.isCacheInitialized = false

  -- Clear database cache
  self.db.global.lootCache = {
    version = 0,
    seasonID = 0,
    lastUpdate = 0,
    compressedData = "",
  }

  -- Clear any existing cache state
  if self.cacheState then
    self:CancelAllTimers()
    self.cacheState = nil
  end

  -- Hide overlay and show status
  self:HideOverlay()
  self:ShowOverlay("Cache reset. Rebuilding...")

  -- Start fresh cache building
  self:BuildCache()
end

---Register static popup dialogs
function Module:RegisterStaticPopups()
  StaticPopupDialogs["ALTEREGO_LOOT_CACHE_RESET"] = {
    text = "Reset Loot Cache?\n\nThis will clear all cached loot data and rebuild it from scratch. This may take a few moments.",
    button1 = "Reset",
    button2 = "Cancel",
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
    OnAccept = function()
      self:PerformCacheReset()
    end,
  }
end

---Get current season instances (cached for session)
---@return table
function Module:GetCurrentSeasonInstances()
  if self.cache.instances then
    return self.cache.instances
  end

  local instances = {}

  for _, raid in ipairs(addon.Data:GetRaids()) do
    table.insert(instances, {instance = raid, type = "raid"})
  end
  for _, dungeon in ipairs(addon.Data:GetDungeons()) do
    table.insert(instances, {instance = dungeon, type = "dungeon"})
  end

  self.cache.instances = instances
  return instances
end

---Get all class/spec combinations (cached for session)
---@return table
function Module:GetClassSpecCombinations()
  if self.cache.classSpec then
    return self.cache.classSpec
  end

  local classSpecs = {}
  for classID = 1, GetNumClasses() do
    for specIndex = 1, GetNumSpecializationsForClassID(classID) do
      local specID = GetSpecializationInfoForClassID(classID, specIndex)
      if specID then
        table.insert(classSpecs, {classID = classID, specID = specID})
      end
    end
  end

  self.cache.classSpec = classSpecs
  return classSpecs
end

---Calculate the total number of steps for cache initialization
---@return number Total steps needed for cache building
function Module:CalculateCacheSteps()
  local instances = self:GetCurrentSeasonInstances()
  local classSpecs = self:GetClassSpecCombinations()
  return #instances * #classSpecs
end

---Update status display (UI only - no state management)
---@param text string? Status text to display
---@param progress number? Current progress value
---@param maxProgress number? Maximum progress value
function Module:UpdateStatus(text, progress, maxProgress)
  if self.statusBar then
    self.statusBar:SetText(text or "Processing...")
    if progress and maxProgress then
      self.statusBar:SetValue(progress)
      self.statusBar:SetMaxValue(maxProgress)
    end
  end
end

---Initialize cache - load from storage or build if needed
function Module:InitializeCache()
  if self.isCacheInitialized then
    return
  end

  local currentSeason = addon.Data:GetCurrentSeason()
  local cachedData = self.db.global.lootCache

  if cachedData and cachedData.seasonID == currentSeason and cachedData.compressedData and cachedData.compressedData ~= "" then
    if self:DecompressCache(cachedData.compressedData) then
      self.isCacheInitialized = true
      self:PopulateTable()
      self:HideOverlay()
      return
    end
  end

  -- No valid cache found - start building
  self:BuildCache()
end

---Build cache using timer-based processing
function Module:BuildCache()
  self:ShowOverlay("Preparing to cache loot data...")

  self.savedSlotFilter = C_EncounterJournal.GetSlotFilter()
  C_EncounterJournal.ResetSlotFilter()

  self.cache.loot = {}

  local instances = self:GetCurrentSeasonInstances()
  local classSpecs = self:GetClassSpecCombinations()
  local totalSteps = self:CalculateCacheSteps()

  self.cacheState = {
    currentInstanceIndex = 1,
    currentClassSpecIndex = 1,
    currentStep = 0,
  }

  self:ProcessNextCacheStep()
end

---Show overlay and set initial status
---@param text string
function Module:ShowOverlay(text)
  if self.overlayFrame then
    self.overlayFrame:Show()
  end
  if self.statusBar then
    self.statusBar:SetText(text or "Processing...")
  end
end

---Hide overlay
function Module:HideOverlay()
  if self.overlayFrame then
    self.overlayFrame:Hide()
  end
end

---Handle cache processing completion
function Module:OnCacheProcessingComplete()
  self:PopulateTable()
  self:HideOverlay()

  if self.savedSlotFilter then
    C_EncounterJournal.SetSlotFilter(self.savedSlotFilter)
  end
  self.savedSlotFilter = nil

  self:SaveCacheToDatabase()
end

---Process next step in cache initialization
function Module:ProcessNextCacheStep()
  if not self.cacheState then
    return
  end

  local state = self.cacheState
  local instances = self:GetCurrentSeasonInstances()
  local classSpecs = self:GetClassSpecCombinations()
  local totalSteps = self:CalculateCacheSteps()

  if state.currentInstanceIndex > #instances then
    self.isCacheInitialized = true
    self:UpdateStatus("Caching complete!", totalSteps, totalSteps)
    self:OnCacheProcessingComplete()
    self.cacheState = nil
    return
  end

  local instanceData = instances[state.currentInstanceIndex]
  local classSpecData = classSpecs[state.currentClassSpecIndex]

  local percentage = math.floor((state.currentStep / totalSteps) * 100)
  local statusText = string.format("Caching %s - %d%%",
                                   instanceData.instance.name,
                                   percentage)
  self:UpdateStatus(statusText, state.currentStep, totalSteps)

  local encounters = self:GetInstanceEncounters(instanceData.instance, instanceData.type)
  for _, encounter in pairs(encounters) do
    self:ProcessEncounterLoot(instanceData.instance, encounter, classSpecData.classID, classSpecData.specID, instanceData.type)
  end

  state.currentClassSpecIndex = state.currentClassSpecIndex + 1
  if state.currentClassSpecIndex > #classSpecs then
    state.currentClassSpecIndex = 1
    state.currentInstanceIndex = state.currentInstanceIndex + 1
  end
  state.currentStep = state.currentStep + 1

  self:ScheduleTimer(function()
                       self:ProcessNextCacheStep()
                     end, 0.01)
end

---Get encounter information for an instance (cached for session)
---@param instance table Instance data from addon.Data
---@param instanceType string Type of instance ("raid" or "dungeon")
---@return table encounters
function Module:GetInstanceEncounters(instance, instanceType)
  local cacheKey = instance.journalInstanceID
  if self.cache.encounters[cacheKey] then
    return self.cache.encounters[cacheKey]
  end

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

  self.cache.encounters[cacheKey] = encounters
  return encounters
end

---Process loot for a single encounter/class/spec combination
---@param instance table Instance data from addon.Data
---@param encounter table Encounter data
---@param classID number Class ID
---@param specID number Specialization ID
---@param instanceType string Type of instance ("raid" or "dungeon")
function Module:ProcessEncounterLoot(instance, encounter, classID, specID, instanceType)
  -- Set up encounter journal for this specific encounter
  EJ_ClearSearch()
  EJ_ResetLootFilter()
  EJ_SelectInstance(instance.journalInstanceID)
  EJ_SelectEncounter(encounter.journalEncounterID)

  -- Set difficulty to Mythic for raids, Mythic for dungeons
  if instanceType == "raid" then
    EJ_SetDifficulty(16) -- Mythic (raid)
  else
    EJ_SetDifficulty(23) -- Mythic (party/dungeon)
  end

  EJ_SetLootFilter(classID, specID)

  -- Get loot for this encounter/class/spec combination
  for i = 1, EJ_GetNumLoot() do
    local lootInfo = C_EncounterJournal.GetLootInfoByIndex(i)
    if lootInfo.name ~= nil and lootInfo.itemID then
      local itemID = lootInfo.itemID



      -- Find or create item in cache
      local item = self.cache.loot[itemID]
      if not item then
        local itemStats = C_Item.GetItemStats(lootInfo.link)

        item = {
          -- Basic item info
          itemID = itemID,
          name = lootInfo.name,
          link = lootInfo.link,
          quality = lootInfo.itemQuality,
          slot = lootInfo.slot or "No Slot",
          texture = lootInfo.icon,
          armorType = lootInfo.armorType or "Unknown",

          -- Instance info
          instanceID = instanceType == "raid" and instance.instanceID or instance.challengeModeID,
          journalInstanceID = instance.journalInstanceID,
          instanceName = instance.name,
          instanceType = instanceType,
          seasonID = instance.seasonID,

          -- Metadata
          stats = itemStats,
          encounters = {},
          difficulties = {},
          classes = {},
          specs = {},

          -- Error flags
          handError = lootInfo.handError,
          weaponTypeError = lootInfo.weaponTypeError,
          filterType = lootInfo.filterType,
        }


        self.cache.loot[itemID] = item
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

      -- Track difficulty (always Mythic for both raids and dungeons)
      item.difficulties["Mythic"] = true

      -- Add class/spec info
      item.classes[classID] = true
      item.specs[specID] = true
    end
  end
end

---Populate the table with cached items
function Module:PopulateTable()
  if not self.lootTable or not self.cache.loot then
    return
  end

  ---@type AE_TableData
  local data = {
    columns = {
      {width = 350, sortable = true, sortKey = "name"},        -- Item (icon + name)
      {width = 150, sortable = true, sortKey = "slot"},        -- Slot
      {width = 120, sortable = true, sortKey = "type"},        -- Type
      {width = 120, sortable = true, sortKey = "primary"},     -- Primary
      {width = 200, sortable = true, sortKey = "secondaries"}, -- Secondaries
      {width = 300, sortable = true, sortKey = "source"},      -- Source (with instance icons)
    },
    rows = {
      {
        columns = {
          {text = "Item",        backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
          {text = "Slot",        backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
          {text = "Type",        backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
          {text = "Primary",     backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
          {text = "Secondaries", backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
          {text = "Source",      backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}},
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

  -- Add custom sorting for source column (strip icons)
  data.columns[6].sortCallback = function(aValue, bValue, direction, aRow, bRow)
    -- Sort by encounter name (strip icons)
    local aEncounterName = ""
    local bEncounterName = ""

    if aRow.itemData and aRow.itemData.encounters and next(aRow.itemData.encounters) then
      for _, encounter in pairs(aRow.itemData.encounters) do
        if encounter.name and encounter.name ~= "Multiple Encounters" then
          aEncounterName = encounter.name
          break
        end
      end
    end

    if bRow.itemData and bRow.itemData.encounters and next(bRow.itemData.encounters) then
      for _, encounter in pairs(bRow.itemData.encounters) do
        if encounter.name and encounter.name ~= "Multiple Encounters" then
          bEncounterName = encounter.name
          break
        end
      end
    end

    if direction == "asc" then
      return aEncounterName < bEncounterName
    else
      return aEncounterName > bEncounterName
    end
  end

  -- Add item rows
  for itemID, item in pairs(self.cache.loot) do
    -- Apply quality color to item name
    local itemText = item.name or "Unknown Item"
    if item.quality then
      itemText = WrapTextInColorCode(itemText, item.quality)
    else
      itemText = WrapTextInColorCode(itemText, WHITE_FONT_COLOR:GenerateHexColor())
    end

    -- Generate source text with instance icon
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

      -- Add instance icon prefix
      local instanceIcon = self:GetInstanceIcon(item)
      if instanceIcon then
        sourceText = instanceIcon .. " " .. sourceText
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
          text = item.armorType ~= "Unknown" and item.armorType or (item.slot == "No Slot" and "Special" or "Unknown"),
        },
        {
          text = self:GetPrimaryStat(item.stats),
        },
        {
          text = self:GetSecondaryStats(item.stats),
        },
        {
          text = sourceText,
          onClick = function()
            -- Open encounter journal to the first encounter for this item
            if item.encounters and next(item.encounters) then
              for _, encounter in pairs(item.encounters) do
                if encounter.journalEncounterID then
                  -- Use the direct EncounterJournal_OpenJournal function with all parameters
                  -- Set difficulty based on instance type
                  local difficultyID = item.instanceType == "raid" and 16 or 23 -- Mythic (raid) or Mythic (dungeon)
                  EncounterJournal_LoadUI()

                  -- Clear any existing filters and set difficulty before opening
                  EJ_ClearSearch()
                  EJ_ResetLootFilter()
                  EJ_SetDifficulty(difficultyID)

                  EncounterJournal_OpenJournal(difficultyID, item.journalInstanceID, encounter.journalEncounterID, nil, item.itemID, nil, nil)

                  -- Focus the journal window
                  if EncounterJournal:IsShown() then
                    EncounterJournal:Show()
                    EncounterJournal:Raise()
                  end

                  -- Manually select the loot tab as backup if it doesn't open automatically
                  C_Timer.After(0.1, function()
                    if EncounterJournal.encounter and EncounterJournal.encounter.info and EncounterJournal.encounter.info.lootTab then
                      EncounterJournal.encounter.info.lootTab:Click()
                    end
                    -- Ensure journal is focused after tab click
                    if EncounterJournal:IsShown() then
                      EncounterJournal:Show()
                      EncounterJournal:Raise()
                    end
                  end)
                  break -- Open to first encounter
                end
              end
            end
          end,
          onEnter = function(columnFrame)
            -- Show tooltip with encounter and instance info
            GameTooltip:SetOwner(columnFrame, "ANCHOR_TOP")
            GameTooltip:SetText("Source")

            -- Add encounter info
            if item.encounters and next(item.encounters) then
              local encounterNames = {}
              for _, encounter in pairs(item.encounters) do
                if encounter.name and encounter.name ~= "Multiple Encounters" then
                  table.insert(encounterNames, encounter.name)
                end
              end

              if #encounterNames > 0 then
                GameTooltip:AddDoubleLine("Encounter:", table.concat(encounterNames, ", "), 1, 1, 1, 1, 1, 1)
              end
            end

            -- Add instance info
            if item.instanceName then
              GameTooltip:AddDoubleLine("Instance:", item.instanceName, 1, 1, 1, 1, 1, 1)
            end

            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("<Click to open Encounter Journal>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
            GameTooltip:Show()

            -- Change cursor to indicate clickable
            columnFrame:SetScript("OnUpdate", function()
              if columnFrame:IsMouseOver() then
                SetCursor("Interface\\Cursor\\Point.blp")
              end
            end)
          end,
          onLeave = function(columnFrame)
            GameTooltip:Hide()
            ResetCursor()
            columnFrame:SetScript("OnUpdate", nil)
          end,
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

---Get primary stat from item stats
---@param stats table Item stats from C_Item.GetItemStats
---@return string
function Module:GetPrimaryStat(stats)
  if not stats then return "" end

  if stats.ITEM_MOD_STRENGTH_SHORT and stats.ITEM_MOD_STRENGTH_SHORT > 0 then
    return ITEM_MOD_STRENGTH_SHORT
  elseif stats.ITEM_MOD_AGILITY_SHORT and stats.ITEM_MOD_AGILITY_SHORT > 0 then
    return ITEM_MOD_AGILITY_SHORT
  elseif stats.ITEM_MOD_INTELLECT_SHORT and stats.ITEM_MOD_INTELLECT_SHORT > 0 then
    return ITEM_MOD_INTELLECT_SHORT
  end

  return ""
end

---Get secondary stats from item stats
---@param stats table Item stats from C_Item.GetItemStats
---@return string
function Module:GetSecondaryStats(stats)
  if not stats then return "" end

  local secondaries = {}

  if stats.ITEM_MOD_CRIT_RATING_SHORT and stats.ITEM_MOD_CRIT_RATING_SHORT > 0 then
    table.insert(secondaries, ITEM_MOD_CRIT_RATING_SHORT)
  end
  if stats.ITEM_MOD_HASTE_RATING_SHORT and stats.ITEM_MOD_HASTE_RATING_SHORT > 0 then
    table.insert(secondaries, ITEM_MOD_HASTE_RATING_SHORT)
  end
  if stats.ITEM_MOD_MASTERY_RATING_SHORT and stats.ITEM_MOD_MASTERY_RATING_SHORT > 0 then
    table.insert(secondaries, ITEM_MOD_MASTERY_RATING_SHORT)
  end
  if stats.ITEM_MOD_VERSATILITY and stats.ITEM_MOD_VERSATILITY > 0 then
    table.insert(secondaries, ITEM_MOD_VERSATILITY)
  end

  return table.concat(secondaries, " / ")
end

---Get instance icon texture
---@param item table Item data from cache
---@return string|nil
function Module:GetInstanceIcon(item)
  if not item.instanceName then
    return nil
  end

  -- Try to find the instance in our data to get the texture
  local instanceTexture = nil

  if item.instanceType == "dungeon" then
    -- Look for dungeon by journalInstanceID
    for _, dungeon in pairs(addon.Data:GetDungeons()) do
      if dungeon.journalInstanceID == item.journalInstanceID then
        instanceTexture = dungeon.texture
        break
      end
    end
  elseif item.instanceType == "raid" then
    -- Look for raid by journalInstanceID
    for _, raid in pairs(addon.Data:GetRaids()) do
      if raid.journalInstanceID == item.journalInstanceID then
        -- Try to get the raid instance texture using EJ_GetInstanceInfo
        local instanceName, description, bgImage, _, loreImage, buttonImage, dungeonAreaMapID, _, _, _, covenantID = EJ_GetInstanceInfo(raid.journalInstanceID)
        if buttonImage and buttonImage > 0 then
          instanceTexture = buttonImage
        else
          -- Fallback to a raid icon
          instanceTexture = "Interface/Icons/achievement_bg_winabg"
        end
        break
      end
    end
  end

  if instanceTexture then
    return "|T" .. instanceTexture .. ":0|t"
  else
    return nil
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
  if self.window then
    self.window:Show()
  end

  -- Ensure overlay is hidden initially
  self:HideOverlay()

  self:InitializeCache()
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
