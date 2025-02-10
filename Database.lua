---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

---@class AE_Data
local Data = {}
addon.Data = Data

Data.dbVersion = 21

Data.defaultDB = {
  ---@type AE_Global
  global = {
    weeklyReset = 0,
    characters = {},
    minimap = {
      minimapPos = 195,
      hide = false,
      lock = false,
    },
    sorting = "lastUpdate",
    showTiers = true,
    showScores = true,
    showAffixColors = true,
    showAffixHeader = true,
    showZeroRatedCharacters = true,
    showRealms = true,
    announceKeystones = {
      autoParty = true,
      autoGuild = false,
      multiline = false,
      multilineNames = false,
    },
    announceResets = true,
    world = {
      enabled = true,
    },
    raids = {
      enabled = true,
      colors = true,
      currentTierOnly = true,
      hiddenDifficulties = {},
      boxes = false,
      modifiedInstanceOnly = true,
    },
    interface = {
      -- fontSize = 12,
      windowScale = 100,
      windowColor = {r = 0.11372549019, g = 0.14117647058, b = 0.16470588235, a = 1},
    },
    useRIOScoreColor = false,
  },
}

---@type AE_Character
Data.defaultCharacter = {
  GUID = "",
  lastUpdate = 0,
  currentSeason = 0,
  enabled = true,
  order = 0,
  info = {
    name = "",
    realm = "",
    level = 0,
    race = {
      name = "",
      file = "",
      id = 0,
    },
    class = {
      name = "",
      file = "",
      id = 0,
    },
    factionGroup = {
      english = "",
      localized = "",
    },
    ilvl = {
      level = 0,
      equipped = 0,
      pvp = 0,
      color = "ffffffff",
    },
  },
  equipment = {},
  money = 0,
  currencies = {
    -- [1] = {
    --     name = string
    --     description = string
    --     isHeader = boolean
    --     isHeaderExpanded = boolean
    --     isTypeUnused = boolean
    --     isShowInBackpack = boolean
    --     quantity = number
    --     trackedQuantity = number
    --     iconFileID = number
    --     maxQuantity = number
    --     canEarnPerWeek = boolean
    --     quantityEarnedThisWeek = number
    --     isTradeable = boolean
    --     quality = Enum
    --     maxWeeklyQuantity = number
    --     totalEarned = number
    --     discovered = boolean
    --     useTotalEarnedForMaxQty = boolean
    -- }
  },
  raids = {
    savedInstances = {
      -- [1] = {
      --     ["id"] = 0,
      --     ["name"] = "",
      --     ["lockoutId"] = 0,
      --     ["reset"] = 0,
      --     ["difficultyID"] = 0,
      --     ["locked"] = false,
      --     ["extended"] = false,
      --     ["instanceIDMostSig"] = 0,
      --     ["isRaid"] = true,
      --     ["maxPlayers"] = 0,
      --     ["difficultyName"] = "",
      --     ["numEncounters"] = 0,
      --     ["encounterProgress"] = 0,
      --     ["extendDisabled"] = false,
      --     ["instanceID"] = 0,
      --     ["link"] = "",
      --     ["expires"] = 0,
      --     ["encounters"] = {
      --         [1] = {
      --             ["instanceEncounterID"] = 0,
      --             ["bossName"] = "",
      --             ["fileDataID"] = 0,
      --             ["killed"] = false
      --         }
      --     }
      -- }
    },
  },
  mythicplus = { -- Mythic Plus
    numCompletedDungeonRuns = {
      -- heroic = 0,
      -- mythic = 0,
      -- mythicPlus = 0
    },
    rating = 0,
    keystone = {
      challengeModeID = 0,
      mapId = 0,
      level = 0,
      color = "",
      itemId = 0,
      itemLink = "",
    },
    weeklyRewardAvailable = false,
    bestSeasonScore = 0,
    bestSeasonNumber = 0,
    runHistory = {},
    dungeons = {
      -- [1] = {
      --     rating = 0,
      --     level = 0,
      --     finishedSuccess = false,
      --     bestTimedRun = {
      --         ["durationSec"] = 0,
      --         ["completionDate"] = {
      --             ["year"] = 0,
      --             ["month"] = 0,
      --             ["minute"] = 0,
      --             ["hour"] = 0,
      --             ["day"] = 0,
      --         },
      --         ["affixIDs"] = {
      --             0, 0, 0
      --         },
      --         ["level"] = 0,
      --         ["members"] = {
      --             {
      --                 ["specID"] = 0,
      --                 ["name"] = "",
      --                 ["classID"] = 0,
      --             }
      --         }
      --     },
      --     bestNotTimedRun = {},
      --     affixScores = {
      --         [1] = {
      --             ["name"] = "Tyrannical",
      --             ["overTime"] = false,
      --             ["level"] = 0,
      --             ["durationSec"] = 0,
      --             ["score"] = 0,
      --         },
      --         [2] = {
      --             ["name"] = "Fortified",
      --             ["overTime"] = false,
      --             ["level"] = 0,
      --             ["durationSec"] = 0,
      --             ["score"] = 0,
      --         },
      --     }
      -- }
    },
  },
  -- pvp = {},
  vault = {
    hasAvailableRewards = false,
    slots = {
      -- [1] = {
      --     ["threshold"] = 0,
      --     ["type"] = 0,
      --     ["index"] = 0,
      --     ["rewards"] = {},
      --     ["progress"] = 0,
      --     ["level"] = 0,
      --     ["raidString"] = "",
      --     ["id"] = 0,
      --     ["exampleRewardLink"] = ""
      --     ["exampleRewardUpgradeLink"] = ""
      -- },
    },
  },
}

local AFFIX_VOLCANIC = 3
local AFFIX_RAGING = 6
local AFFIX_BOLSTERING = 7
local AFFIX_SANGUINE = 8
local AFFIX_TYRANNICAL = 9
local AFFIX_FORTIFIED = 10
local AFFIX_BURSTING = 11
local AFFIX_SPITEFUL = 123
local AFFIX_STORMING = 124
local AFFIX_ENTANGLING = 134
local AFFIX_AFFLICTED = 135
local AFFIX_INCORPOREAL = 136
local AFFIX_XALATAHS_GUILE = 147
local AFFIX_XALATAHS_BARGAIN_ASCENDANT = 148
local AFFIX_CHALLENGERS_PERIL = 152
local AFFIX_XALATAHS_BARGAIN_VOIDBOUND = 158
local AFFIX_XALATAHS_BARGAIN_OBLIVION = 159
local AFFIX_XALATAHS_BARGAIN_DEVOUR = 160
local AFFIX_XALATAHS_BARGAIN_PULSAR = 162

-- ---@type AE_Affix[]
-- Data.affixes = {
--   {id = AFFIX_VOLCANIC,                   base = 0, name = "", description = "", fileDataID = nil},
--   {id = AFFIX_RAGING,                     base = 0, name = "", description = "", fileDataID = nil},
--   {id = AFFIX_BOLSTERING,                 base = 0, name = "", description = "", fileDataID = nil},
--   {id = AFFIX_SANGUINE,                   base = 0, name = "", description = "", fileDataID = nil},
--   {id = AFFIX_FORTIFIED,                  base = 1, name = "", description = "", fileDataID = nil},
--   {id = AFFIX_TYRANNICAL,                 base = 1, name = "", description = "", fileDataID = nil},
--   {id = AFFIX_BURSTING,                   base = 0, name = "", description = "", fileDataID = nil},
--   {id = AFFIX_SPITEFUL,                   base = 0, name = "", description = "", fileDataID = nil},
--   {id = AFFIX_STORMING,                   base = 0, name = "", description = "", fileDataID = nil},
--   {id = AFFIX_ENTANGLING,                 base = 0, name = "", description = "", fileDataID = nil},
--   {id = AFFIX_AFFLICTED,                  base = 0, name = "", description = "", fileDataID = nil},
--   {id = AFFIX_INCORPOREAL,                base = 0, name = "", description = "", fileDataID = nil},
--   {id = AFFIX_XALATAHS_GUILE,             base = 0, name = "", description = "", fileDataID = nil},
--   {id = AFFIX_XALATAHS_BARGAIN_ASCENDANT, base = 0, name = "", description = "", fileDataID = nil},
--   {id = AFFIX_CHALLENGERS_PERIL,          base = 0, name = "", description = "", fileDataID = nil},
--   {id = AFFIX_XALATAHS_BARGAIN_VOIDBOUND, base = 0, name = "", description = "", fileDataID = nil},
--   {id = AFFIX_XALATAHS_BARGAIN_OBLIVION,  base = 0, name = "", description = "", fileDataID = nil},
--   {id = AFFIX_XALATAHS_BARGAIN_DEVOUR,    base = 0, name = "", description = "", fileDataID = nil},
--   {id = AFFIX_XALATAHS_BARGAIN_PULSAR,    base = 0, name = "", description = "", fileDataID = nil},
-- }

---@type AE_Inventory[]
Data.inventory = {
  {id = INVSLOT_HEAD,     name = "HEADSLOT"},
  {id = INVSLOT_NECK,     name = "NECKSLOT"},
  {id = INVSLOT_SHOULDER, name = "SHOULDERSLOT"},
  {id = INVSLOT_BACK,     name = "BACKSLOT"},
  {id = INVSLOT_CHEST,    name = "CHESTSLOT"},
  {id = INVSLOT_WRIST,    name = "WRISTSLOT"},
  {id = INVSLOT_HAND,     name = "HANDSSLOT"},
  {id = INVSLOT_WAIST,    name = "WAISTSLOT"},
  {id = INVSLOT_LEGS,     name = "LEGSSLOT"},
  {id = INVSLOT_FEET,     name = "FEETSLOT"},
  {id = INVSLOT_FINGER1,  name = "FINGER0SLOT"},
  {id = INVSLOT_FINGER2,  name = "FINGER1SLOT"},
  {id = INVSLOT_TRINKET1, name = "TRINKET0SLOT"},
  {id = INVSLOT_TRINKET2, name = "TRINKET1SLOT"},
  {id = INVSLOT_MAINHAND, name = "MAINHANDSLOT"},
  {id = INVSLOT_OFFHAND,  name = "SECONDARYHANDSLOT"},
}

---@type AE_RaidDifficulty[]
Data.raidDifficulties = {
  {id = 14, color = RARE_BLUE_COLOR,        order = 2, abbr = "N", name = "Normal"},
  {id = 15, color = EPIC_PURPLE_COLOR,      order = 3, abbr = "H", name = "Heroic"},
  {id = 16, color = LEGENDARY_ORANGE_COLOR, order = 4, abbr = "M", name = "Mythic"},
  {id = 17, color = UNCOMMON_GREEN_COLOR,   order = 1, abbr = "L", name = "Looking For Raid", short = "LFR"},
}

---Season Data
---@type AE_Season[]
Data.seasons = {
  {
    seasonID = 13,
    seasonDisplayID = 1,
    name = "The War Within Season 1",
    affixes = {
      {[2] = AFFIX_XALATAHS_BARGAIN_ASCENDANT, [4] = AFFIX_TYRANNICAL, [7] = AFFIX_CHALLENGERS_PERIL, [10] = AFFIX_FORTIFIED,  [12] = AFFIX_XALATAHS_GUILE},
      {[2] = AFFIX_XALATAHS_BARGAIN_OBLIVION,  [4] = AFFIX_FORTIFIED,  [7] = AFFIX_CHALLENGERS_PERIL, [10] = AFFIX_TYRANNICAL, [12] = AFFIX_XALATAHS_GUILE},
      {[2] = AFFIX_XALATAHS_BARGAIN_VOIDBOUND, [4] = AFFIX_TYRANNICAL, [7] = AFFIX_CHALLENGERS_PERIL, [10] = AFFIX_FORTIFIED,  [12] = AFFIX_XALATAHS_GUILE},
      {[2] = AFFIX_XALATAHS_BARGAIN_DEVOUR,    [4] = AFFIX_FORTIFIED,  [7] = AFFIX_CHALLENGERS_PERIL, [10] = AFFIX_TYRANNICAL, [12] = AFFIX_XALATAHS_GUILE},
      {[2] = AFFIX_XALATAHS_BARGAIN_OBLIVION,  [4] = AFFIX_TYRANNICAL, [7] = AFFIX_CHALLENGERS_PERIL, [10] = AFFIX_FORTIFIED,  [12] = AFFIX_XALATAHS_GUILE},
      {[2] = AFFIX_XALATAHS_BARGAIN_ASCENDANT, [4] = AFFIX_FORTIFIED,  [7] = AFFIX_CHALLENGERS_PERIL, [10] = AFFIX_TYRANNICAL, [12] = AFFIX_XALATAHS_GUILE},
      {[2] = AFFIX_XALATAHS_BARGAIN_DEVOUR,    [4] = AFFIX_TYRANNICAL, [7] = AFFIX_CHALLENGERS_PERIL, [10] = AFFIX_FORTIFIED,  [12] = AFFIX_XALATAHS_GUILE},
      {[2] = AFFIX_XALATAHS_BARGAIN_VOIDBOUND, [4] = AFFIX_FORTIFIED,  [7] = AFFIX_CHALLENGERS_PERIL, [10] = AFFIX_TYRANNICAL, [12] = AFFIX_XALATAHS_GUILE},
    },
    dungeons = {
      {challengeModeID = 503, mapId = 2660, journalInstanceID = 1271, encounters = {}, loot = {}, time = 0, abbr = "ARAK",  name = "Ara-Kara, City of Echoes", spellID = 445417},
      {challengeModeID = 502, mapId = 2669, journalInstanceID = 1274, encounters = {}, loot = {}, time = 0, abbr = "COT",   name = "City of Threads",          spellID = 445416},
      {challengeModeID = 507, mapId = 670,  journalInstanceID = 71,   encounters = {}, loot = {}, time = 0, abbr = "GB",    name = "Grim Batol",               spellID = 445424},
      {challengeModeID = 375, mapId = 2290, journalInstanceID = 1184, encounters = {}, loot = {}, time = 0, abbr = "MISTS", name = "Mists of Tirna Scithe",    spellID = 354464},
      {challengeModeID = 353, mapId = 1822, journalInstanceID = 1023, encounters = {}, loot = {}, time = 0, abbr = "SIEGE", name = "Siege of Boralus",         spellID = UnitFactionGroup("player") == "Alliance" and 445418 or 464256},
      {challengeModeID = 505, mapId = 2662, journalInstanceID = 1270, encounters = {}, loot = {}, time = 0, abbr = "DAWN",  name = "The Dawnbreaker",          spellID = 445414},
      {challengeModeID = 376, mapId = 2286, journalInstanceID = 1182, encounters = {}, loot = {}, time = 0, abbr = "NW",    name = "The Necrotic Wake",        spellID = 354462},
      {challengeModeID = 501, mapId = 2652, journalInstanceID = 1269, encounters = {}, loot = {}, time = 0, abbr = "SV",    name = "The Stonevault",           spellID = 445269},
    },
    raids = {
      {instanceID = 2657, journalInstanceID = 1273, order = 1, encounters = {}, loot = {}, abbr = "NAP", name = "Nerub-ar Palace"},
      -- {journalInstanceID = 1273, instanceID = 2657, order = 1, numEncounters = 8, encounters = {}, loot = {}, modifiedInstanceInfo = nil, abbr = "NAP", name = "Nerub-ar Palace"},
    },
    currencies = {
      {id = 2914, currencyType = "crest"},    -- Weathered
      {id = 2915, currencyType = "crest"},    -- Carved
      {id = 2916, currencyType = "crest"},    -- Runed
      {id = 2917, currencyType = "crest"},    -- Gilded
      {id = 3008, currencyType = "upgrade"},  -- Valorstones
      {id = 2813, currencyType = "catalyst"}, -- Catalyst
      {id = 3028, currencyType = "delve"},    -- Restored Coffer key
    },
    keystoneItemID = 180653,
  },
  {
    seasonID = 14,
    seasonDisplayID = 2,
    name = "The War Within Season 2",
    affixes = {
      {[4] = AFFIX_XALATAHS_BARGAIN_ASCENDANT, [7] = AFFIX_TYRANNICAL, [10] = AFFIX_FORTIFIED,  [12] = AFFIX_XALATAHS_GUILE},
      {[4] = AFFIX_XALATAHS_BARGAIN_OBLIVION,  [7] = AFFIX_FORTIFIED,  [10] = AFFIX_TYRANNICAL, [12] = AFFIX_XALATAHS_GUILE},
      {[4] = AFFIX_XALATAHS_BARGAIN_VOIDBOUND, [7] = AFFIX_TYRANNICAL, [10] = AFFIX_FORTIFIED,  [12] = AFFIX_XALATAHS_GUILE},
      {[4] = AFFIX_XALATAHS_BARGAIN_DEVOUR,    [7] = AFFIX_FORTIFIED,  [10] = AFFIX_TYRANNICAL, [12] = AFFIX_XALATAHS_GUILE},
      {[4] = AFFIX_XALATAHS_BARGAIN_OBLIVION,  [7] = AFFIX_TYRANNICAL, [10] = AFFIX_FORTIFIED,  [12] = AFFIX_XALATAHS_GUILE},
      {[4] = AFFIX_XALATAHS_BARGAIN_ASCENDANT, [7] = AFFIX_FORTIFIED,  [10] = AFFIX_TYRANNICAL, [12] = AFFIX_XALATAHS_GUILE},
      {[4] = AFFIX_XALATAHS_BARGAIN_DEVOUR,    [7] = AFFIX_TYRANNICAL, [10] = AFFIX_FORTIFIED,  [12] = AFFIX_XALATAHS_GUILE},
      {[4] = AFFIX_XALATAHS_BARGAIN_VOIDBOUND, [7] = AFFIX_FORTIFIED,  [10] = AFFIX_TYRANNICAL, [12] = AFFIX_XALATAHS_GUILE},
    },
    dungeons = {
      {challengeModeID = 503, mapId = 2660, journalInstanceID = 1271, encounters = {}, loot = {}, time = 0, abbr = "ARAK",  name = "Ara-Kara, City of Echoes", spellID = 445417},
      {challengeModeID = 502, mapId = 2669, journalInstanceID = 1274, encounters = {}, loot = {}, time = 0, abbr = "COT",   name = "City of Threads",          spellID = 445416},
      {challengeModeID = 507, mapId = 670,  journalInstanceID = 71,   encounters = {}, loot = {}, time = 0, abbr = "GB",    name = "Grim Batol",               spellID = 445424},
      {challengeModeID = 375, mapId = 2290, journalInstanceID = 1184, encounters = {}, loot = {}, time = 0, abbr = "MISTS", name = "Mists of Tirna Scithe",    spellID = 354464},
      {challengeModeID = 353, mapId = 1822, journalInstanceID = 1023, encounters = {}, loot = {}, time = 0, abbr = "SIEGE", name = "Siege of Boralus",         spellID = UnitFactionGroup("player") == "Alliance" and 445418 or 464256},
      {challengeModeID = 505, mapId = 2662, journalInstanceID = 1270, encounters = {}, loot = {}, time = 0, abbr = "DAWN",  name = "The Dawnbreaker",          spellID = 445414},
      {challengeModeID = 376, mapId = 2286, journalInstanceID = 1182, encounters = {}, loot = {}, time = 0, abbr = "NW",    name = "The Necrotic Wake",        spellID = 354462},
      {challengeModeID = 501, mapId = 2652, journalInstanceID = 1269, encounters = {}, loot = {}, time = 0, abbr = "SV",    name = "The Stonevault",           spellID = 445269},
    },
    raids = {
      {instanceID = 2657, journalInstanceID = 1273, order = 1, encounters = {}, loot = {}, abbr = "NAP", name = "Nerub-ar Palace"},
      -- {journalInstanceID = 1273, instanceID = 2657, order = 1, numEncounters = 8, encounters = {}, loot = {}, modifiedInstanceInfo = nil, abbr = "NAP", name = "Nerub-ar Palace"},
    },
    currencies = {
      {id = 2914, currencyType = "crest"},    -- Weathered
      {id = 2915, currencyType = "crest"},    -- Carved
      {id = 2916, currencyType = "crest"},    -- Runed
      {id = 2917, currencyType = "crest"},    -- Gilded
      {id = 3008, currencyType = "upgrade"},  -- Valorstones
      {id = 2813, currencyType = "catalyst"}, -- Catalyst
      {id = 3028, currencyType = "delve"},    -- Restored Coffer key
    },
    keystoneItemID = 180653,
  },
}

Data.cache = {
  seasonID = nil,
  seasonDisplayID = nil,
  ---@type MythicPlusKeystoneAffix[]
  currentAffixes = {},
  classes = {},
  specs = {},
  keystones = {},
  dungeons = {},
  raids = {},
  currencies = {},
  affixes = {},
}

---Initiate AceDB
function Data:Initialize()
  ---@class AceDBObject-3.0
  ---@field global AE_Global
  self.db = LibStub("AceDB-3.0"):New(
    "AlterEgoDB",
    self.defaultDB,
    true
  )
end

function Data:calculateDungeonTimer(time, level, tier)
  if tier == 3 then
    time = time * 0.6
  elseif tier == 2 then
    time = time * 0.8
  end

  local affixes = self:GetActiveAffixesByLevel(level)
  local hasPeril = addon.Utils:TableFind(affixes, function(affix)
    return affix == AFFIX_CHALLENGERS_PERIL
  end)
  if hasPeril then
    time = time + 90
  end

  return time
end

---Get the current season IDs
---@return number, number
function Data:GetSeasonIDs()
  if not self.cache.seasonID or self.cache.seasonID == -1 then
    self.cache.seasonID = C_MythicPlus.GetCurrentSeason()
  end
  if not self.cache.seasonDisplayID or self.cache.seasonDisplayID == -1 then
    self.cache.seasonDisplayID = C_MythicPlus.GetCurrentUIDisplaySeason()
  end
  return self.cache.seasonID or -1, self.cache.seasonDisplayID or -1
end

---Get the season or current season
---@param seasonID number?
---@return AE_Season|nil
function Data:GetSeason(seasonID)
  local currentSeasonID = self:GetSeasonIDs()
  if seasonID ~= nil then
    currentSeasonID = seasonID
  end
  return addon.Utils:TableGet(self.seasons, "seasonID", currentSeasonID)
end

---Get the season currencies
---@param seasonID number?
---@return table
function Data:GetSeasonCurrencies(seasonID)
  local season = self:GetSeason(seasonID)
  local currencies = {}
  if not season or not season.currencies then return currencies end

  addon.Utils:TableForEach(season.currencies, function(currency)
    if not self.cache.currencies[currency.id] then
      local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currency.id)
      if not currencyInfo then return end
      currencyInfo.id = currency.id
      currencyInfo.currencyType = currency.currencyType
      if currency.itemID then
        currencyInfo.itemID = currency.itemID
        currencyInfo.quantity = C_Item.GetItemCount(currency.itemID, true)
        currencyInfo.iconFileID = C_Item.GetItemIconByID(currency.itemID) or 0
      end
      self.cache.currencies[currency.id] = currencyInfo
    end
    table.insert(currencies, self.cache.currencies[currency.id])
  end)
  return currencies
end

---Get the season affixes
---@param seasonID number?
-----@return AE_Affix[]
function Data:GetSeasonAffixes(seasonID)
  local season = self:GetSeason(seasonID)
  local affixes = {}
  if not season or not season.affixes then return affixes end

  addon.Utils:TableForEach(season.affixes, function(affixRotation)
    local affixWeek = {}
    addon.Utils:TableForEach(affixRotation, function(affix)
      -- Get cached data
      if not self.cache.affixes[affix.id] then
        local name, description, fileDataID = C_ChallengeMode.GetAffixInfo(affix.id)
        if not name then return end
        self.cache.affixes[affix.id] = {
          id = affix.id,
          name = name,
          description = description,
          fileDataID = fileDataID,
        }
      end
      -- Combine cached data with static data
      local affixData = self.cache.affixes[affix.id]
      affixData.level = affix.level
      table.insert(affixWeek, affixData)
    end)
    table.insert(affixes, affixWeek)
  end)

  return affixes
end

---Get the season raids
---@param seasonID number?
---@return table
function Data:GetSeasonRaids(seasonID)
  local season = self:GetSeason(seasonID)
  local raids = {}
  if not season or not season.raids then return raids end

  addon.Utils:TableForEach(season.raids, function(raid)
    if not self.cache.raids[raid.instanceID] then
      -- TODO: Get raid info
      raid.encounters = {}

      local encounterIndex = 1
      EJ_SelectInstance(raid.journalInstanceID)
      local _, _, bossID = EJ_GetEncounterInfoByIndex(encounterIndex, raid.journalInstanceID)
      while bossID do
        local name, description, journalEncounterID, journalEncounterSectionID, journalLink, journalInstanceID, instanceEncounterID, instanceID = EJ_GetEncounterInfoByIndex(encounterIndex, raid.journalInstanceID)
        ---@type AE_Encounter
        local encounter = {
          index = encounterIndex,
          name = name,
          description = description,
          journalInstanceID = journalInstanceID,
          journalEncounterID = journalEncounterID,
          journalEncounterSectionID = journalEncounterSectionID,
          journalLink = journalLink,
          instanceID = instanceID,
          instanceEncounterID = instanceEncounterID,
        }
        raid.encounters[encounterIndex] = encounter
        encounterIndex = encounterIndex + 1
        _, _, bossID = EJ_GetEncounterInfoByIndex(encounterIndex, raid.journalInstanceID)
      end
      raid.modifiedInstanceInfo = C_ModifiedInstance.GetModifiedInstanceInfoFromMapID(raid.instanceID)
      raid.loot = {}
      --   EJ_ClearSearch()
      --   EJ_ResetLootFilter()
      --   EJ_SelectInstance(raid.journalInstanceID)
      --   for classID = 1, GetNumClasses() do
      --     for specIndex = 1, GetNumSpecializationsForClassID(classID) do
      --       local specID = GetSpecializationInfoForClassID(classID, specIndex)
      --       if specID then
      --         EJ_SetLootFilter(classID, specID)
      --         for i = 1, EJ_GetNumLoot() do
      --           local lootInfo = C_EncounterJournal.GetLootInfoByIndex(i)
      --           if lootInfo.name ~= nil and lootInfo.slot ~= nil and lootInfo.slot ~= "" then
      --             local item = raid.loot[lootInfo.itemID]
      --             if not item then
      --               item = lootInfo
      --               item.stats = C_Item.GetItemStats(lootInfo.link)
      --               item.classes = {}
      --               item.specs = {}
      --               raid.loot[lootInfo.itemID] = item
      --             end
      --             item.classes[classID] = true
      --             item.specs[specID] = true
      --             -- table.insert(item.classes, classID)
      --             -- table.insert(item.specs, specID)
      --             -- TODO: Make above arrays unique
      --           end
      --         end
      --       end
      --     end
      --   end
      --   EJ_ResetLootFilter()
      self.cache.raids[raid.instanceID] = raid
    end
    table.insert(raids, self.cache.raids[raid.instanceID])
  end)

  table.sort(raids, function(a, b)
    return a.order < b.order
  end)

  return raids
end

---Get the season M+ dungeons
---@param seasonID number?
---@return AE_Dungeon[]
function Data:GetSeasonDungeons(seasonID)
  local season = self:GetSeason(seasonID)
  local dungeons = {}
  if not season or not season.dungeons then return dungeons end

  addon.Utils:TableForEach(season.dungeons, function(dungeon)
    if not self.cache.dungeons[dungeon.challengeModeID] then
      -- TODO: Get and store more dungeon data for m+
      local dungeonName, _, dungeonTimeLimit, dungeonTexture = C_ChallengeMode.GetMapUIInfo(dungeon.challengeModeID)
      if not dungeonName then return end
      dungeon.name = dungeonName
      dungeon.time = dungeonTimeLimit
      dungeon.texture = dungeon.texture ~= 0 and dungeonTexture or "Interface/Icons/achievement_bg_wineos_underxminutes"
      dungeon.encounters = {}

      local encounterIndex = 1
      EJ_SelectInstance(dungeon.journalInstanceID)
      local _, _, bossID = EJ_GetEncounterInfoByIndex(encounterIndex, dungeon.journalInstanceID)
      while bossID do
        local name, description, journalEncounterID, journalEncounterSectionID, journalLink, journalInstanceID, instanceEncounterID, instanceID = EJ_GetEncounterInfoByIndex(encounterIndex, dungeon.journalInstanceID)
        ---@type AE_Encounter
        local encounter = {
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
        dungeon.encounters[encounterIndex] = encounter
        encounterIndex = encounterIndex + 1
        _, _, bossID = EJ_GetEncounterInfoByIndex(encounterIndex, dungeon.journalInstanceID)
      end

      dungeon.loot = {}
      -- EJ_ClearSearch()
      -- EJ_ResetLootFilter()
      -- EJ_SelectInstance(dungeon.journalInstanceID)

      -- local count = 0
      -- for classID = 1, GetNumClasses() do
      --   for specIndex = 1, GetNumSpecializationsForClassID(classID) do
      --     local specID = GetSpecializationInfoForClassID(classID, specIndex)
      --     if specID then
      --       EJ_SetLootFilter(classID, specID)
      --       for i = 1, EJ_GetNumLoot() do
      --         local lootInfo = C_EncounterJournal.GetLootInfoByIndex(i)
      --         if lootInfo.name ~= nil and lootInfo.slot ~= nil and lootInfo.slot ~= "" then
      --           local item = dungeon.loot[lootInfo.itemID]
      --           if not item then
      --             item = lootInfo
      --             item.stats = C_Item.GetItemStats(lootInfo.link)
      --             item.classes = {}
      --             item.specs = {}
      --             dungeon.loot[lootInfo.itemID] = item
      --             count = count + 1
      --           end
      --           item.classes[classID] = true
      --           item.specs[specID] = true
      --           -- table.insert(item.classes, classID)
      --           -- table.insert(item.specs, specID)
      --           -- TODO: Make above arrays unique
      --         end
      --       end
      --     end
      --   end
      -- end
      -- EJ_ResetLootFilter()

      self.cache.dungeons[dungeon.challengeModeID] = dungeon
    end
    table.insert(dungeons, self.cache.dungeons[dungeon.challengeModeID])
  end)

  table.sort(dungeons, function(a, b)
    return strcmputf8i(a.name, b.name) < 0
  end)

  return dungeons
end

---Get all of the raids in the current season
---@param unfiltered boolean?
---@return AE_RaidDifficulty[]
function Data:GetRaidDifficulties(unfiltered)
  local difficulties = addon.Utils:TableFilter(self.raidDifficulties, function(difficulty)
    return unfiltered or (self.db.global.raids.hiddenDifficulties and not self.db.global.raids.hiddenDifficulties[difficulty.id])
  end)

  table.sort(difficulties, function(a, b)
    return a.order < b.order
  end)

  return difficulties
end

---Get the current affixes of the week
---@return MythicPlusKeystoneAffix[]
function Data:GetCurrentWeeklyAffixes()
  if addon.Utils:TableCount(self.cache.currentAffixes) == 0 then
    local currentAffixes = C_MythicPlus.GetCurrentAffixes()
    if currentAffixes then
      self.cache.currentAffixes = currentAffixes
    end
  end
  return self.cache.currentAffixes
end

---Get the season Keystone ItemID
---@param seasonID number?
---@return number|nil
function Data:GetSeasonKeystoneItemID(seasonID)
  local season = self:GetSeason(seasonID)
  return season and season.keystoneItemID or nil
end

---Get the season affix rotation
---@param seasonID number?
---@return AE_AffixRotation|nil
function Data:GetAffixRotation(seasonID)
  local season = self:GetSeason(seasonID)
  return season and season.affixes or {}
end

---------------------------------------------------------------------
---------------------------------------------------------------------
---------------------------------------------------------------------
---------------------------------------------------------------------

---Get stored character by GUID
---@param playerGUID WOWGUID?
---@return AE_Character|nil
function Data:GetCharacter(playerGUID)
  if playerGUID == nil then
    playerGUID = UnitGUID("player")
  end

  if playerGUID == nil then
    return nil
  end

  if self.db.global.characters[playerGUID] == nil then
    self.db.global.characters[playerGUID] = addon.Utils:TableCopy(Data.defaultCharacter)
  end

  self.db.global.characters[playerGUID].GUID = playerGUID

  return self.db.global.characters[playerGUID]
end

---Get the index of the active affix week
---TODO: This is hardcoded for 3 affixes only but somehow still works
---@param currentAffixes MythicPlusKeystoneAffix|nil
---@return number
function Data:GetActiveAffixRotation(currentAffixes)
  local affixRotation = self:GetAffixRotation()
  local index = 0
  if currentAffixes and affixRotation then
    addon.Utils:TableForEach(affixRotation.affixes, function(affix, i)
      if affix[1] == currentAffixes[1].id and affix[2] == currentAffixes[2].id and affix[3] == currentAffixes[3].id then
        index = i
      end
    end)
  end
  return index
end

---Get activated affix IDs by keystone level
---@param level number
---@return number[]
function Data:GetActiveAffixesByLevel(level)
  ---@type number[]
  local affixes = {}
  local affixRotation = self:GetAffixRotation()
  if affixRotation and affixRotation.activation and affixRotation.affixes then
    addon.Utils:TableForEach(affixRotation.activation, function(activationLevel, activationIndex)
      if activationLevel >= level then
        local affix = affixRotation.affixes[activationIndex]
        if affix then
          table.insert(affixes, affix)
        end
      end
    end)
  end
  return affixes
end

---Set a new character order
---@param character AE_Character
---@param direction number
function Data:SortCharacter(character, direction)
  local characters = self:GetCharacters()
  for i, _ in pairs(characters) do
    if characters[i].GUID == character.GUID then
      if direction > 0 and i < #characters and characters[i + 1] then
        self.db.global.characters[character.GUID].order = characters[i + 1].order + 0.5
        break
      end
      if direction < 0 and i > 1 and characters[i - 1] then
        self.db.global.characters[character.GUID].order = characters[i - 1].order - 0.5
      end
    end
  end
end

---Get user characters
---@param unfiltered boolean?
---@return AE_Character[]
function Data:GetCharacters(unfiltered)
  local characters = {}
  for _, character in pairs(self.db.global.characters) do
    if character.info.level ~= nil and character.info.level >= 80 then -- Todo later: GetMaxLevelForPlayerExpansion()
      table.insert(characters, character)
    end
  end

  -- Update custom order
  local order = 1
  table.sort(characters, function(a, b)
    return (a.order or 0) < (b.order or 0)
  end)
  addon.Utils:TableForEach(characters, function(character)
    self.db.global.characters[character.GUID].order = order
    order = order + 1
  end)

  -- Sorting
  table.sort(characters, function(a, b)
    if self.db.global.sorting == "name.asc" then
      return strcmputf8i(a.info.name, b.info.name) < 0
    elseif self.db.global.sorting == "name.desc" then
      return strcmputf8i(a.info.name, b.info.name) > 0
    elseif self.db.global.sorting == "realm.asc" then
      return strcmputf8i(a.info.realm, b.info.realm) < 0
    elseif self.db.global.sorting == "realm.desc" then
      return strcmputf8i(a.info.realm, b.info.realm) > 0
    elseif self.db.global.sorting == "rating.asc" then
      return a.mythicplus.rating < b.mythicplus.rating
    elseif self.db.global.sorting == "rating.desc" then
      return a.mythicplus.rating > b.mythicplus.rating
    elseif self.db.global.sorting == "ilvl.asc" then
      return a.info.ilvl.level < b.info.ilvl.level
    elseif self.db.global.sorting == "ilvl.desc" then
      return a.info.ilvl.level > b.info.ilvl.level
    elseif self.db.global.sorting == "class.asc" then
      return strcmputf8i(a.info.class.name, b.info.class.name) < 0
    elseif self.db.global.sorting == "class.desc" then
      return strcmputf8i(a.info.class.name, b.info.class.name) > 0
    elseif self.db.global.sorting == "custom" then
      return (a.order or 0) < (b.order or 0)
    end
    return a.lastUpdate > b.lastUpdate
  end)

  -- Filters
  if unfiltered then
    return characters
  end

  local charactersFiltered = {}
  for _, character in ipairs(characters) do
    local keep = true
    if not character.enabled then
      keep = false
    end
    if self.db.global.showZeroRatedCharacters == false and (character.mythicplus.rating and character.mythicplus.rating <= 0) then
      keep = false
    end
    if keep then
      table.insert(charactersFiltered, character)
    end
  end

  return charactersFiltered
end

function Data:UpdateDB()
  self:UpdateCharacterInfo()
  self:UpdateEquipment()
  self:UpdateMoney()
  self:UpdateCurrencies()
  self:UpdateKeystoneItem()
  self:UpdateRaidInstances()
  self:UpdateVault()
  self:UpdateMythicPlus()
end

function Data:MigrateDB()
  if type(self.db.global.dbVersion) ~= "number" then
    self.db.global.dbVersion = self.dbVersion
  end
  if self.db.global.dbVersion < self.dbVersion then
    if self.db.global.dbVersion == 1 then
      for characterIndex in pairs(self.db.global.characters) do
        self.db.global.characters[characterIndex].raids.killed = nil
        if self.db.global.characters[characterIndex].raids.savedInstances then
          for savedInstanceIndex, savedInstance in ipairs(self.db.global.characters[characterIndex].raids.savedInstances) do
            if savedInstance.instanceID == 2549 and savedInstance.encounters then
              self.db.global.characters[characterIndex].raids.savedInstances[savedInstanceIndex].encounters[4].instanceEncounterID = 2731
              self.db.global.characters[characterIndex].raids.savedInstances[savedInstanceIndex].encounters[5].instanceEncounterID = 2728
            end
          end
        end
      end
    end
    -- Add missing affix IDs
    if self.db.global.dbVersion == 10 then
      local affixes = self:GetSeasonAffixes()
      for characterIndex in pairs(self.db.global.characters) do
        local character = self.db.global.characters[characterIndex]
        if character.mythicplus.dungeons ~= nil then
          addon.Utils:TableForEach(character.mythicplus.dungeons, function(dungeon)
            addon.Utils:TableForEach(dungeon.affixScores, function(affixScore)
              local affix = addon.Utils:TableGet(affixes, "name", affixScore.name)
              if affixScore.id == nil then
                affixScore.id = affix and affix.id or 0
              end
            end)
          end)
        end
      end
    end
    -- Convert season ID from display ID to season major version ID
    if self.db.global.dbVersion == 15 then
      for _, character in pairs(self.db.global.characters) do
        if character.currentSeason ~= nil and character.currentSeason == 3 then
          character.currentSeason = 11
        end
      end
    end
    -- Fix SavedInstance/EncounterJournal name mismatch for "Sennarth, t|The Cold Breath"
    if self.db.global.dbVersion == 16 then
      for _, character in pairs(self.db.global.characters) do
        if character.raids and character.raids.savedInstances then
          for _, savedInstance in pairs(character.raids.savedInstances) do
            if savedInstance.instanceID == 2522 and savedInstance.encounters then
              for _, encounter in pairs(savedInstance.encounters) do
                if encounter.index and encounter.index == 5 and encounter.instanceEncounterID == 0 then
                  encounter.instanceEncounterID = 2592
                end
              end
            end
          end
        end
      end
    end
    self.db.global.dbVersion = self.db.global.dbVersion + 1
    self:MigrateDB()
  end
end

function Data:TaskWeeklyReset()
  if type(self.db.global.weeklyReset) == "number" and self.db.global.weeklyReset <= time() then
    addon.Utils:TableForEach(self.db.global.characters, function(character)
      if character.currencies ~= nil then
        addon.Utils:TableForEach(character.currencies, function(currency)
          if currency.currencyType == "crest" and currency.maxQuantity > 0 then
            currency.maxQuantity = currency.maxQuantity + 90
          end
          -- if currency.currencyType == "catalyst" then
          --   currency.quantity = math.min(currency.quantity + 1, currency.maxQuantity)
          -- end
        end)
      end
      addon.Utils:TableForEach(character.vault.slots, function(slot)
        if slot.progress >= slot.threshold then
          character.vault.hasAvailableRewards = true
        end
      end)
      addon.Utils:TableForEach(character.mythicplus.runHistory, function(run)
        run.thisWeek = false
      end)
      wipe(character.vault.slots or {})
      wipe(character.mythicplus.keystone or {})
      wipe(character.mythicplus.numCompletedDungeonRuns or {})
    end)
  end
  self.db.global.weeklyReset = time() + C_DateAndTime.GetSecondsUntilWeeklyReset()
end

function Data:TaskSeasonReset()
  local seasonID = self:GetSeasonIDs()
  if seasonID then
    addon.Utils:TableForEach(self.db.global.characters, function(character)
      if character.currentSeason == nil or character.currentSeason < seasonID then
        wipe(character.mythicplus.runHistory or {})
        wipe(character.mythicplus.dungeons or {})
        wipe(character.currencies or {})
        character.mythicplus.rating = 0
        character.currentSeason = seasonID
      end
    end)
  end
end

function Data:loadGameData()
  self:GetSeasonAffixes()
  self:GetSeasonRaids()
  self:GetSeasonDungeons()
end

function Data:UpdateRaidInstances()
  local character = self:GetCharacter()
  if not character then return end

  local raids = self:GetSeasonRaids()
  local numSavedInstances = GetNumSavedInstances()

  wipe(character.raids.savedInstances or {})
  if numSavedInstances == 0 then return end

  for savedInstanceIndex = 1, numSavedInstances do
    local name, lockoutId, reset, difficultyID, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress, extendDisabled, instanceID = GetSavedInstanceInfo(savedInstanceIndex)
    local raid = addon.Utils:TableGet(raids, "instanceID", instanceID)
    ---@type AE_SavedInstance
    local savedInstance = {
      index = savedInstanceIndex,
      id = lockoutId,
      name = name,
      lockoutId = lockoutId,
      reset = reset,
      difficultyID = difficultyID,
      locked = locked,
      extended = extended,
      instanceIDMostSig = instanceIDMostSig,
      isRaid = isRaid,
      maxPlayers = maxPlayers,
      difficultyName = difficultyName,
      numEncounters = numEncounters,
      encounterProgress = encounterProgress,
      extendDisabled = extendDisabled,
      instanceID = instanceID,
      link = GetSavedInstanceChatLink(savedInstanceIndex),
      expires = 0,
      encounters = {},
    }
    if reset and reset > 0 then
      savedInstance.expires = reset + time()
    end
    for encounterIndex = 1, numEncounters do
      local bossName, fileDataID, isKilled = GetSavedInstanceEncounterInfo(savedInstanceIndex, encounterIndex)
      local instanceEncounterID = 0
      if raid then
        addon.Utils:TableForEach(raid.encounters, function(encounter)
          if string.lower(encounter.name) == string.lower(bossName) then
            instanceEncounterID = encounter.instanceEncounterID
          end
        end)
      end
      ---@type AE_SavedInstanceEncounter
      local savedInstanceEncounter = {
        index = encounterIndex,
        instanceEncounterID = instanceEncounterID,
        bossName = bossName,
        fileDataID = fileDataID or 0,
        isKilled = isKilled,
      }
      savedInstance.encounters[encounterIndex] = savedInstanceEncounter
    end
    character.raids.savedInstances[savedInstanceIndex] = savedInstance
  end
  addon.UI:Render()
end

function Data:UpdateCharacterInfo()
  local character = self:GetCharacter()
  if not character then return end

  local playerName = UnitName("player")
  local playerRealm = GetRealmName()
  local playerLevel = UnitLevel("player")
  local playerRaceName, playerRaceFile, playerRaceID = UnitRace("player")
  local playerClassName, playerClassFile, playerClassID = UnitClass("player")
  local playerFactionGroupEnglish, playerFactionGroupLocalized = UnitFactionGroup("player")
  local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvp = GetAverageItemLevel()
  local itemLevelColorR, itemLevelColorG, itemLevelColorB = GetItemLevelColor()

  if playerName then character.info.name = playerName end
  if playerRealm then character.info.realm = playerRealm end
  if playerLevel then character.info.level = playerLevel end
  if type(character.info.race) ~= "table" then character.info.race = self.defaultCharacter.info.race end
  if playerRaceName then character.info.race.name = playerRaceName end
  if playerRaceFile then character.info.race.file = playerRaceFile end
  if playerRaceID then character.info.race.id = playerRaceID end
  if type(character.info.class) ~= "table" then character.info.class = self.defaultCharacter.info.class end
  if playerClassName then character.info.class.name = playerClassName end
  if playerClassFile then character.info.class.file = playerClassFile end
  if playerClassID then character.info.class.id = playerClassID end
  if type(character.info.factionGroup) ~= "table" then character.info.factionGroup = self.defaultCharacter.info.factionGroup end
  if playerFactionGroupEnglish then character.info.factionGroup.english = playerFactionGroupEnglish end
  if playerFactionGroupLocalized then character.info.factionGroup.localized = playerFactionGroupLocalized end
  if avgItemLevel then character.info.ilvl.level = avgItemLevel end
  if avgItemLevelEquipped then character.info.ilvl.equipped = avgItemLevelEquipped end
  if avgItemLevelPvp then character.info.ilvl.pvp = avgItemLevelPvp end
  if itemLevelColorR and itemLevelColorG and itemLevelColorB then character.info.ilvl.color = CreateColor(itemLevelColorR, itemLevelColorG, itemLevelColorB):GenerateHexColor() end

  character.lastUpdate = GetServerTime()
  addon.UI:Render()
end

---Store the character money
function Data:UpdateMoney()
  local character = self:GetCharacter()
  if not character then return end

  local money = GetMoney()
  if money then
    character.money = money
  end
end

function Data:UpdateCurrencies()
  local character = self:GetCharacter()
  if not character then return end

  if character.currencies == nil then
    character.currencies = {}
  else
    wipe(character.currencies or {})
  end

  addon.Utils:TableForEach(self.cache.currencies, function(dataCurrency)
    local currency = C_CurrencyInfo.GetCurrencyInfo(dataCurrency.id)
    if not currency then return end
    currency.id = dataCurrency.id
    currency.currencyType = dataCurrency.currencyType
    if dataCurrency.itemID then
      currency.quantity = C_Item.GetItemCount(dataCurrency.itemID, true)
      currency.iconFileID = C_Item.GetItemIconByID(dataCurrency.itemID) or 0
    end
    table.insert(character.currencies, currency)
  end)
end

function Data:UpdateEquipment()
  local character = self:GetCharacter()
  if not character then return end

  if character.equipment == nil then
    character.equipment = {}
  else
    wipe(character.equipment or {})
  end

  local upgradePattern = ITEM_UPGRADE_TOOLTIP_FORMAT_STRING
  upgradePattern = upgradePattern:gsub("%%d", "%%s")
  upgradePattern = upgradePattern:format("(.+)", "(%d+)", "(%d+)")

  addon.Utils:TableForEach(self.inventory, function(slot)
    local inventoryItemLink = GetInventoryItemLink("player", slot.id)
    if not inventoryItemLink then return end

    local itemUpgradeTrack, itemUpgradeLevel, itemUpgradeMax = "", 0, 0
    local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
    itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
    expansionID, setID, isCraftingReagent = C_Item.GetItemInfo(inventoryItemLink)
    if itemName == nil then return end

    local tooltipData = C_TooltipInfo.GetInventoryItem("player", slot.id)
    addon.Utils:TableForEach(tooltipData.lines, function(line)
      if not line.leftText then return end
      local match, _, uTrack, uLevel, uMax = line.leftText:find(upgradePattern)
      if not match then return end
      if uTrack then
        itemUpgradeTrack = uTrack
      end
      if uLevel then
        itemUpgradeLevel = tonumber(uLevel) or itemUpgradeLevel
      end
      if uMax then
        itemUpgradeMax = tonumber(uMax) or itemUpgradeMax
      end
    end)

    ---@type AE_Equipment
    local equipment = {
      itemName = itemName,
      itemLink = itemLink,
      itemQuality = itemQuality,
      itemLevel = itemLevel,
      itemMinLevel = itemMinLevel,
      itemType = itemType,
      itemSubType = itemSubType,
      itemStackCount = itemStackCount,
      itemEquipLoc = itemEquipLoc,
      itemTexture = itemTexture,
      sellPrice = sellPrice,
      classID = classID,
      subclassID = subclassID,
      bindType = bindType,
      expansionID = expansionID,
      setID = setID,
      isCraftingReagent = isCraftingReagent,
      itemUpgradeTrack = itemUpgradeTrack,
      itemUpgradeLevel = itemUpgradeLevel,
      itemUpgradeMax = itemUpgradeMax,
      itemSlotID = slot.id,
      itemSlotName = slot.name,
    }
    table.insert(character.equipment, equipment)
  end)
end

function Data:UpdateKeystoneItem()
  local character = self:GetCharacter()
  if not character then return end
  local dungeons = self:GetSeasonDungeons()
  local keystoneItemID = self:GetSeasonKeystoneItemID()

  local keystoneItemLink = nil
  if keystoneItemID ~= nil then
    for bagID = 0, NUM_BAG_SLOTS do
      for slotID = 1, C_Container.GetContainerNumSlots(bagID) do
        local itemId = C_Container.GetContainerItemID(bagID, slotID)
        if itemId and itemId == keystoneItemID then
          keystoneItemLink = C_Container.GetContainerItemLink(bagID, slotID)
          break
        end
      end
      if keystoneItemLink then
        break
      end
    end
  end

  if not keystoneItemLink then
    local keyStoneMapID = C_MythicPlus.GetOwnedKeystoneMapID()
    local keyStoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()
    if keyStoneMapID ~= nil then character.mythicplus.keystone.mapId = tonumber(keyStoneMapID) end
    if keyStoneLevel ~= nil then character.mythicplus.keystone.level = tonumber(keyStoneLevel) end
    return
  end

  local _, _, challengeModeID, level = strsplit(":", keystoneItemLink)
  if not challengeModeID then return end

  local dungeon = addon.Utils:TableGet(dungeons, "challengeModeID", tonumber(challengeModeID))
  if not dungeon then return end

  local newKeystone = false
  if character.mythicplus.keystone.mapId and character.mythicplus.keystone.level then
    if character.mythicplus.keystone.mapId ~= tonumber(dungeon.mapId) or character.mythicplus.keystone.level < tonumber(level) then
      newKeystone = true
    end
  elseif tonumber(dungeon.mapId) and tonumber(level) then
    newKeystone = true
  end

  local color = "ffffffff"
  local levelNumber = tonumber(level)
  if levelNumber then
    local keystoneColor = C_ChallengeMode.GetKeystoneLevelRarityColor(levelNumber)
    if keystoneColor ~= nil then
      color = keystoneColor:GenerateHexColor()
    end
  end

  character.mythicplus.keystone = {
    challengeModeID = tonumber(dungeon.challengeModeID),
    mapId = tonumber(dungeon.mapId),
    level = tonumber(level),
    color = color,
    itemId = tonumber(keystoneItemID),
    itemLink = keystoneItemLink,
  }

  if newKeystone then
    if IsInGroup() and self.db.global.announceKeystones.autoParty then
      SendChatMessage(addon.Constants.prefix .. "New Keystone: " .. keystoneItemLink, "PARTY")
    end
    if IsInGuild() and self.db.global.announceKeystones.autoGuild then
      SendChatMessage(addon.Constants.prefix .. "New Keystone: " .. keystoneItemLink, "GUILD")
    end
  end

  addon.UI:Render()
end

function Data:UpdateVault()
  local character = self:GetCharacter()
  if not character then return end

  wipe(character.vault.slots or {})

  local activities = C_WeeklyRewards.GetActivities()
  addon.Utils:TableForEach(activities, function(activity)
    activity.exampleRewardLink = ""
    activity.exampleRewardUpgradeLink = ""
    if activity.progress >= activity.threshold then
      local itemLink, upgradeItemLink = C_WeeklyRewards.GetExampleRewardItemHyperlinks(activity.id)
      activity.exampleRewardLink = itemLink
      activity.exampleRewardUpgradeLink = upgradeItemLink
    end
    table.insert(character.vault.slots, activity)
  end)
  local HasAvailableRewards = C_WeeklyRewards.HasAvailableRewards()
  if HasAvailableRewards ~= nil then character.vault.hasAvailableRewards = HasAvailableRewards end
  addon.UI:Render()
end

function Data:UpdateMythicPlus()
  local character = self:GetCharacter()
  if not character then return end

  local dungeons = self:GetSeasonDungeons()
  local ratingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary("player")
  local runHistory = C_MythicPlus.GetRunHistory(true, true)
  local bestSeasonScore, bestSeasonNumber = C_MythicPlus.GetSeasonBestMythicRatingFromThisExpansion()
  local weeklyRewardAvailable = C_MythicPlus.IsWeeklyRewardAvailable() -- Unused
  local HasAvailableRewards = C_WeeklyRewards.HasAvailableRewards()
  local numHeroic, numMythic, numMythicPlus = C_WeeklyRewards.GetNumCompletedDungeonRuns()
  local affixes = self:GetSeasonAffixes()

  if ratingSummary ~= nil and ratingSummary.currentSeasonScore ~= nil then character.mythicplus.rating = ratingSummary.currentSeasonScore end
  if runHistory ~= nil then character.mythicplus.runHistory = runHistory end
  if bestSeasonScore ~= nil then character.mythicplus.bestSeasonScore = bestSeasonScore end
  if bestSeasonNumber ~= nil then character.mythicplus.bestSeasonNumber = bestSeasonNumber end
  if weeklyRewardAvailable ~= nil then character.mythicplus.weeklyRewardAvailable = weeklyRewardAvailable end
  if HasAvailableRewards ~= nil then character.vault.hasAvailableRewards = HasAvailableRewards end

  character.mythicplus.numCompletedDungeonRuns = {
    heroic = numHeroic or 0,
    mythic = numMythic or 0,
    mythicPlus = numMythicPlus or 0,
  }

  wipe(character.mythicplus.dungeons or {})
  for _, dataDungeon in pairs(dungeons) do
    local bestTimedRun, bestNotTimedRun = C_MythicPlus.GetSeasonBestForMap(dataDungeon.challengeModeID)
    local affixScores, bestOverAllScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(dataDungeon.challengeModeID)
    local dungeon = {
      challengeModeID = dataDungeon.challengeModeID,
      bestTimedRun = {},
      bestNotTimedRun = {},
      affixScores = {},
      rating = 0,
      level = 0,
      finishedSuccess = false,
      bestOverAllScore = 0,
    }
    if bestTimedRun ~= nil then dungeon.bestTimedRun = bestTimedRun end
    if bestNotTimedRun ~= nil then dungeon.bestNotTimedRun = bestNotTimedRun end
    if affixScores ~= nil then
      addon.Utils:TableForEach(affixScores, function(affixScore)
        local affix = addon.Utils:TableGet(affixes, "name", affixScore.name)
        affixScore.id = affix and affix.id or 0
      end)
      dungeon.affixScores = affixScores
    end
    if bestOverAllScore ~= nil then dungeon.bestOverAllScore = bestOverAllScore end
    if ratingSummary ~= nil and ratingSummary.runs ~= nil then
      for _, run in ipairs(ratingSummary.runs) do
        if run.challengeModeID == dataDungeon.challengeModeID then
          dungeon.rating = run.mapScore
          dungeon.level = run.bestRunLevel
          dungeon.finishedSuccess = run.finishedSuccess
        end
      end
    end
    table.insert(character.mythicplus.dungeons, dungeon)
  end
  addon.UI:Render()
end

-- function Data:GetClasses()
--   if addon.Utils:TableCount(Data.cache.classes) > 0 then
--     return Data.cache.classes
--   end

--   for classID = 1, GetNumClasses() do
--     local className, classFile = GetClassInfo(classID)
--     if className then
--       table.insert(Data.cache.classes, {
--         ID = classID,
--         name = className,
--         file = classFile,
--         numSpecs = GetNumSpecializationsForClassID(classID)
--       })
--     end
--   end

--   return Data.cache.classes
-- end

-- function Data:GetSpecs()
--   if addon.Utils:TableCount(Data.cache.specs) > 0 then
--     return Data.cache.specs
--   end

--   local classes = Data:GetClasses()
--   addon.Utils:TableForEach(classes, function(cls)
--     for specIndex = 1, GetNumSpecializationsForClassID(cls.ID) do
--       local specID, name, description, icon, role, isRecommended, isAllowed = GetSpecializationInfoForClassID(cls.ID, specIndex)
--       if specID then
--         table.insert(Data.cache.specs, {
--           ID = specID,
--           name = name,
--           description = description,
--           icon = icon,
--           role = role,
--           isRecommended = isRecommended,
--           isAllowed = isAllowed,
--           classID = cls.ID,
--           className = cls.name,
--           classFile = cls.file
--         })
--       end
--     end
--   end)

--   return Data.cache.specs
-- end
