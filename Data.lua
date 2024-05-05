local addonName, AlterEgo = ...
local Utils = AlterEgo.Utils
local Core = AlterEgo.Core
local dbVersion = 16
local Data = {}
AlterEgo.Data = Data
Data.defaultCharacter = {
  GUID = "",
  lastUpdate = 0,
  currentSeason = 0,
  enabled = true,
  info = {
    name = "",
    realm = "",
    level = 0,
    race = {
      name = "",
      file = "",
      id = 0
    },
    class = {
      name = "",
      file = "",
      id = 0
    },
    factionGroup = {
      english = "",
      localized = ""
    },
    ilvl = {
      level = 0,
      equipped = 0,
      pvp = 0,
      color = "ffffffff"
    },
  },
  equipment = {},
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
  pvp = {},
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
    }
  },
}

Data.tooltipScan = CreateFrame("GameTooltip", "AE_Tooltip_Scan", nil, "GameTooltipTemplate") --[[@as GameTooltip]]
Data.tooltipScan:SetOwner(UIParent, "ANCHOR_NONE")

---@type Inventory[]
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

---@type Affix[]
Data.affixes = {
  {id = AFFIX_VOLCANIC,    base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_RAGING,      base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_BOLSTERING,  base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_SANGUINE,    base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_FORTIFIED,   base = 1, name = "", description = "", fileDataID = nil},
  {id = AFFIX_TYRANNICAL,  base = 1, name = "", description = "", fileDataID = nil},
  {id = AFFIX_BURSTING,    base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_SPITEFUL,    base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_STORMING,    base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_ENTANGLING,  base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_AFFLICTED,   base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_INCORPOREAL, base = 0, name = "", description = "", fileDataID = nil},
}

-- Rotation: https://mythicpl.us
---@type AffixRotation[]
Data.affixRotations = {
  {
    seasonID = 11,
    seasonDisplayID = 3,
    activation = {2, 7, 14},
    affixes = {
      {AFFIX_TYRANNICAL, AFFIX_STORMING,    AFFIX_RAGING},
      {AFFIX_FORTIFIED,  AFFIX_ENTANGLING,  AFFIX_BOLSTERING},
      {AFFIX_TYRANNICAL, AFFIX_INCORPOREAL, AFFIX_SPITEFUL},
      {AFFIX_FORTIFIED,  AFFIX_AFFLICTED,   AFFIX_RAGING},
      {AFFIX_TYRANNICAL, AFFIX_VOLCANIC,    AFFIX_SANGUINE},
      {AFFIX_FORTIFIED,  AFFIX_STORMING,    AFFIX_BURSTING},
      {AFFIX_TYRANNICAL, AFFIX_AFFLICTED,   AFFIX_BOLSTERING},
      {AFFIX_FORTIFIED,  AFFIX_INCORPOREAL, AFFIX_SANGUINE},
      {AFFIX_TYRANNICAL, AFFIX_ENTANGLING,  AFFIX_BURSTING},
      {AFFIX_FORTIFIED,  AFFIX_VOLCANIC,    AFFIX_SPITEFUL},
    }
  },
  {
    seasonID = 12,
    seasonDisplayID = 4,
    activation = {2, 5, 10},
    affixes = {
      {AFFIX_TYRANNICAL, AFFIX_STORMING,    AFFIX_RAGING},
      {AFFIX_FORTIFIED,  AFFIX_ENTANGLING,  AFFIX_BOLSTERING},
      {AFFIX_TYRANNICAL, AFFIX_INCORPOREAL, AFFIX_SPITEFUL},
      {AFFIX_FORTIFIED,  AFFIX_AFFLICTED,   AFFIX_RAGING},
      {AFFIX_TYRANNICAL, AFFIX_VOLCANIC,    AFFIX_SANGUINE},
      {AFFIX_FORTIFIED,  AFFIX_STORMING,    AFFIX_BURSTING},
      {AFFIX_TYRANNICAL, AFFIX_AFFLICTED,   AFFIX_BOLSTERING},
      {AFFIX_FORTIFIED,  AFFIX_INCORPOREAL, AFFIX_SANGUINE},
      {AFFIX_TYRANNICAL, AFFIX_ENTANGLING,  AFFIX_BURSTING},
      {AFFIX_FORTIFIED,  AFFIX_VOLCANIC,    AFFIX_SPITEFUL},
    }
  }
}

---@type Keystone[]
Data.keystones = {
  {seasonID = 11, seasonDisplayID = 3, itemID = 180653},
  {seasonID = 12, seasonDisplayID = 4, itemID = 151086},
}

---@type Dungeon[]
Data.dungeons = {
  {seasonID = 10, seasonDisplayID = 2, challengeModeID = 206, mapId = 1458, spellID = 410078, time = 0, abbr = "NL",   name = "Neltharion's Lair"},
  {seasonID = 10, seasonDisplayID = 2, challengeModeID = 245, mapId = 1754, spellID = 410071, time = 0, abbr = "FH",   name = "Freehold"},
  {seasonID = 10, seasonDisplayID = 2, challengeModeID = 251, mapId = 1841, spellID = 410074, time = 0, abbr = "UNDR", name = "The Underrot"},
  {seasonID = 10, seasonDisplayID = 2, challengeModeID = 403, mapId = 2451, spellID = 393222, time = 0, abbr = "ULD",  name = "Uldaman: Legacy of Tyr"},
  {seasonID = 10, seasonDisplayID = 2, challengeModeID = 404, mapId = 2519, spellID = 393276, time = 0, abbr = "NELT", name = "Neltharus"},
  {seasonID = 10, seasonDisplayID = 2, challengeModeID = 405, mapId = 2520, spellID = 393267, time = 0, abbr = "BH",   name = "Brackenhide Hollow"},
  {seasonID = 10, seasonDisplayID = 2, challengeModeID = 406, mapId = 2527, spellID = 393283, time = 0, abbr = "HOI",  name = "Halls of Infusion"},
  {seasonID = 10, seasonDisplayID = 2, challengeModeID = 438, mapId = 657,  spellID = 410080, time = 0, abbr = "VP",   name = "The Vortex Pinnacle"},
  {seasonID = 11, seasonDisplayID = 3, challengeModeID = 168, mapId = 1279, spellID = 159901, time = 0, abbr = "EB",   name = "The Everbloom"},
  {seasonID = 11, seasonDisplayID = 3, challengeModeID = 198, mapId = 1466, spellID = 424163, time = 0, abbr = "DHT",  name = "Darkheart Thicket"},
  {seasonID = 11, seasonDisplayID = 3, challengeModeID = 199, mapId = 1501, spellID = 424153, time = 0, abbr = "BRH",  name = "Black Rook Hold"},
  {seasonID = 11, seasonDisplayID = 3, challengeModeID = 244, mapId = 1763, spellID = 424187, time = 0, abbr = "AD",   name = "Atal'Dazar"},
  {seasonID = 11, seasonDisplayID = 3, challengeModeID = 248, mapId = 1862, spellID = 424167, time = 0, abbr = "WM",   name = "Waycrest Manor"},
  {seasonID = 11, seasonDisplayID = 3, challengeModeID = 456, mapId = 643,  spellID = 424142, time = 0, abbr = "TOTT", name = "Throne of the Tides"},
  {seasonID = 11, seasonDisplayID = 3, challengeModeID = 463, mapId = 2579, spellID = 424197, time = 0, abbr = "FALL", name = "Dawn of the Infinite: Galakrond's Fall", short = "DOTI: Galakrond's Fall"},
  {seasonID = 11, seasonDisplayID = 3, challengeModeID = 464, mapId = 2579, spellID = 424197, time = 0, abbr = "RISE", name = "Dawn of the Infinite: Murozond's Rise",  short = "DOTI: Murozond's Rise"},
  {seasonID = 12, seasonDisplayID = 4, challengeModeID = 399, mapId = 2521, spellID = 393256, time = 0, abbr = "RLP",  name = "Ruby Life Pools"},
  {seasonID = 12, seasonDisplayID = 4, challengeModeID = 400, mapId = 2516, spellID = 393262, time = 0, abbr = "NO",   name = "The Nokhud Offensive"},
  {seasonID = 12, seasonDisplayID = 4, challengeModeID = 401, mapId = 2515, spellID = 393279, time = 0, abbr = "AV",   name = "The Azure Vault"},
  {seasonID = 12, seasonDisplayID = 4, challengeModeID = 402, mapId = 2526, spellID = 393273, time = 0, abbr = "AA",   name = "Algeth'ar Academy"},
  {seasonID = 12, seasonDisplayID = 4, challengeModeID = 403, mapId = 2451, spellID = 393222, time = 0, abbr = "ULD",  name = "Uldaman: Legacy of Tyr"},
  {seasonID = 12, seasonDisplayID = 4, challengeModeID = 404, mapId = 2519, spellID = 393276, time = 0, abbr = "NELT", name = "Neltharus"},
  {seasonID = 12, seasonDisplayID = 4, challengeModeID = 405, mapId = 2520, spellID = 393267, time = 0, abbr = "BH",   name = "Brackenhide Hollow"},
  {seasonID = 12, seasonDisplayID = 4, challengeModeID = 406, mapId = 2527, spellID = 393283, time = 0, abbr = "HOI",  name = "Halls of Infusion"},
}

---@type Raid[]
Data.raids = {
  {seasonID = 9,  seasonDisplayID = 1, journalInstanceID = 1200, instanceID = 2522, order = 1, numEncounters = 8, encounters = {}, modifiedInstanceInfo = nil, abbr = "VOTI", name = "Vault of the Incarnates"},
  {seasonID = 10, seasonDisplayID = 2, journalInstanceID = 1208, instanceID = 2569, order = 2, numEncounters = 9, encounters = {}, modifiedInstanceInfo = nil, abbr = "ATSC", name = "Aberrus, the Shadowed Crucible"},
  {seasonID = 11, seasonDisplayID = 3, journalInstanceID = 1207, instanceID = 2549, order = 3, numEncounters = 9, encounters = {}, modifiedInstanceInfo = nil, abbr = "ATDH", name = "Amirdrassil, the Dream's Hope"},
  {seasonID = 12, seasonDisplayID = 4, journalInstanceID = 1200, instanceID = 2522, order = 1, numEncounters = 8, encounters = {}, modifiedInstanceInfo = nil, abbr = "VOTI", name = "Vault of the Incarnates"},
  {seasonID = 12, seasonDisplayID = 4, journalInstanceID = 1208, instanceID = 2569, order = 2, numEncounters = 9, encounters = {}, modifiedInstanceInfo = nil, abbr = "ATSC", name = "Aberrus, the Shadowed Crucible"},
  {seasonID = 12, seasonDisplayID = 4, journalInstanceID = 1207, instanceID = 2549, order = 3, numEncounters = 9, encounters = {}, modifiedInstanceInfo = nil, abbr = "ATDH", name = "Amirdrassil, the Dream's Hope"},
}

---@type RaidDifficulty[]
Data.raidDifficulties = {
  {id = 14, color = RARE_BLUE_COLOR,        order = 2, abbr = "N",   name = "Normal"},
  {id = 15, color = EPIC_PURPLE_COLOR,      order = 3, abbr = "HC",  name = "Heroic"},
  {id = 16, color = LEGENDARY_ORANGE_COLOR, order = 4, abbr = "M",   name = "Mythic"},
  {id = 17, color = UNCOMMON_GREEN_COLOR,   order = 1, abbr = "LFR", name = "Looking For Raid", short = "LFR"},
}

---@type Currency[]
Data.currencies = {
  {seasonID = 11, seasonDisplayID = 3, id = 2709, currencyType = "crest"},    -- Aspect
  {seasonID = 11, seasonDisplayID = 3, id = 2708, currencyType = "crest"},    -- Wyrm
  {seasonID = 11, seasonDisplayID = 3, id = 2707, currencyType = "crest"},    -- Drake
  {seasonID = 11, seasonDisplayID = 3, id = 2706, currencyType = "crest"},    -- Whelpling
  {seasonID = 11, seasonDisplayID = 3, id = 2245, currencyType = "upgrade"},  -- Flightstones
  {seasonID = 11, seasonDisplayID = 3, id = 2796, currencyType = "catalyst"}, -- Catalyst
  {seasonID = 12, seasonDisplayID = 4, id = 2812, currencyType = "crest"},    -- Aspect
  {seasonID = 12, seasonDisplayID = 4, id = 2809, currencyType = "crest"},    -- Wyrm
  {seasonID = 12, seasonDisplayID = 4, id = 2807, currencyType = "crest"},    -- Drake
  {seasonID = 12, seasonDisplayID = 4, id = 2806, currencyType = "crest"},    -- Whelpling
  {seasonID = 12, seasonDisplayID = 4, id = 2245, currencyType = "upgrade"},  -- Flightstones
  {seasonID = 12, seasonDisplayID = 4, id = 2912, currencyType = "catalyst"}, -- Catalyst
  {seasonID = 12, seasonDisplayID = 4, id = 3010, currencyType = "dinar"},    -- Dinar
}

Data.cache = {
  seasonID = nil,
  seasonDisplayID = nil,
  ---@type MythicPlusKeystoneAffix[]
  currentAffixes = {}
}

function Data:Initialize()
  self.db = LibStub("AceDB-3.0"):New(
    "AlterEgoDB",
    {
      global = {
        weeklyReset = 0,
        characters = {},
        minimap = {
          minimapPos = 195,
          hide = false,
          lock = false
        },
        sorting = "lastUpdate",
        showTiers = true,
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
        pvp = {
          enabled = false,
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
          windowColor = {r = 0.11372549019, g = 0.14117647058, b = 0.16470588235, a = 1}
        },
        useRIOScoreColor = false,
      }
    },
    true
  )
end

--- Get the current Season IDs
---@return number, number
function Data:GetCurrentSeason()
  if not self.cache.seasonID then
    self.cache.seasonID = C_MythicPlus.GetCurrentSeason()
  end
  if not self.cache.seasonDisplayID then
    self.cache.seasonDisplayID = C_MythicPlus.GetCurrentUIDisplaySeason()
  end
  -- return 12, 4
  return self.cache.seasonID or 0, self.cache.seasonDisplayID or 0
end

--- Get the currencies of the current season
---@return Currency[]
function Data:GetCurrencies()
  local seasonID = self:GetCurrentSeason()
  return Utils:TableFilter(self.currencies, function(dataCurrency)
    return dataCurrency.seasonID == seasonID
  end)
end

--- Get stored character by GUID
---@param playerGUID string?
---@return table|nil
function Data:GetCharacter(playerGUID)
  if playerGUID == nil then
    playerGUID = UnitGUID("player")
  end

  if playerGUID == nil then
    return nil
  end

  if self.db.global.characters[playerGUID] == nil then
    self.db.global.characters[playerGUID] = Utils:TableCopy(Data.defaultCharacter)
  end

  self.db.global.characters[playerGUID].GUID = playerGUID

  return self.db.global.characters[playerGUID]
end

---Get all of the raids in the current season
---@param unfiltered boolean?
---@return RaidDifficulty[]
function Data:GetRaidDifficulties(unfiltered)
  local result = {}
  for _, difficulty in pairs(self.raidDifficulties) do
    table.insert(result, difficulty)
  end

  table.sort(result, function(a, b)
    return a.order < b.order
  end)

  if unfiltered then
    return result
  end

  local filtered = {}
  for _, difficulty in ipairs(result) do
    if self.db.global.raids.hiddenDifficulties and not self.db.global.raids.hiddenDifficulties[difficulty.id] then
      table.insert(filtered, difficulty)
    end
  end

  return filtered
end

--- Get the current affixes of the season
---@return MythicPlusKeystoneAffix[]
function Data:GetCurrentAffixes()
  if Utils:TableCount(self.cache.currentAffixes) == 0 then
    local currentAffixes = C_MythicPlus.GetCurrentAffixes()
    if currentAffixes then
      self.cache.currentAffixes = currentAffixes
    end
  end
  return self.cache.currentAffixes
end

--- Get either all affixes or just the base seasonal affixes
---@param baseOnly boolean?
---@return Affix[]
function Data:GetAffixes(baseOnly)
  return Utils:TableFilter(self.affixes, function(dataAffix)
    return not baseOnly or dataAffix.base == 1
  end)
end

--- Get affix rotation of the season
---@return AffixRotation|nil
function Data:GetAffixRotation()
  local seasonID = self:GetCurrentSeason()
  Utils:TableGet(self.affixRotations, "seasonID", seasonID)
end

--- Get the index of the active affix week
---@param currentAffixes MythicPlusKeystoneAffix|nil
---@return number
function Data:GetActiveAffixRotation(currentAffixes)
  local affixRotation = self:GetAffixRotation()
  local index = 0
  if currentAffixes and affixRotation then
    Utils:TableForEach(affixRotation.affixes, function(affix, i)
      if affix[1] == currentAffixes[1].id and affix[2] == currentAffixes[2].id and affix[3] == currentAffixes[3].id then
        index = i
      end
    end)
  end
  return index
end

--- Get the Keystone ItemID of the current season
---@return Keystone|nil
function Data:GetKeystoneItemID()
  local seasonID = self:GetCurrentSeason()
  local keystone = Utils:TableGet(self.keystones, "seasonID", seasonID)

  if keystone ~= nil then
    return keystone.itemID
  end

  return nil
end

--- Get all of the M+ dungeons in the current season
---@return Dungeon[]
function Data:GetDungeons()
  local seasonID = self:GetCurrentSeason()
  local dungeons = Utils:TableFilter(self.dungeons, function(dataDungeon)
    return dataDungeon.seasonID == seasonID
  end)

  table.sort(dungeons, function(a, b)
    return strcmputf8i(a.name, b.name) < 0
  end)

  return dungeons
end

--- Get all of the raids in the current season
---@param unfiltered boolean?
---@return Raid[]
function Data:GetRaids(unfiltered)
  local seasonID = self:GetCurrentSeason()
  local raids = Utils:TableFilter(self.raids, function(dataRaid)
    return dataRaid.seasonID == seasonID
  end)

  table.sort(raids, function(a, b)
    return a.order < b.order
  end)

  if unfiltered then
    return raids
  end

  if self.db.global.raids.modifiedInstanceOnly and seasonID == 12 then
    raids = Utils:TableFilter(raids, function(raid)
      return raid.modifiedInstanceInfo
    end)
  end

  return raids
end

--- Get user characters
---@param unfiltered boolean?
---@return table
function Data:GetCharacters(unfiltered)
  local characters = {}
  for _, character in pairs(self.db.global.characters) do
    if character.info.level ~= nil and character.info.level == 70 then
      table.insert(characters, character)
    end
  end

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
  self:UpdateRaidInstances()
  self:UpdateCharacterInfo()
  self:UpdateKeystoneItem()
  self:UpdateVault()
  self:UpdateMythicPlus()
end

function Data:MigrateDB()
  if type(self.db.global.dbVersion) ~= "number" then
    self.db.global.dbVersion = dbVersion
  end
  if self.db.global.dbVersion < dbVersion then
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
    if self.db.global.dbVersion == 10 then
      local affixes = self:GetAffixes()
      for characterIndex in pairs(self.db.global.characters) do
        local character = self.db.global.characters[characterIndex]
        if character.mythicplus.dungeons ~= nil then
          Utils:TableForEach(character.mythicplus.dungeons, function(dungeon)
            Utils:TableForEach(dungeon.affixScores, function(affixScore)
              local affix = Utils:TableGet(affixes, "name", affixScore.name)
              if affixScore.id == nil then
                affixScore.id = affix and affix.id or 0
              end
            end)
          end)
        end
      end
    end
    if self.db.global.dbVersion == 15 then
      for _, character in pairs(self.db.global.characters) do
        if character.currentSeason ~= nil and character.currentSeason == 3 then
          character.currentSeason = 11
        end
      end
    end
    self.db.global.dbVersion = self.db.global.dbVersion + 1
    self:MigrateDB()
  end
end

function Data:TaskWeeklyReset()
  if type(self.db.global.weeklyReset) == "number" and self.db.global.weeklyReset <= time() then
    Utils:TableForEach(self.db.global.characters, function(character)
      if character.currencies ~= nil then
        Utils:TableForEach(character.currencies, function(currency)
          if currency.currencyType == "crest" and currency.maxQuantity > 0 then
            currency.maxQuantity = currency.maxQuantity + 90
          end
          if currency.currencyType == "catalyst" or currency.currencyType == "dinar" then
            currency.quantity = math.min(currency.quantity + 1, currency.maxQuantity)
          end
        end)
      end
      Utils:TableForEach(character.vault.slots, function(slot)
        if slot.progress >= slot.threshold then
          character.vault.hasAvailableRewards = true
        end
      end)
      Utils:TableForEach(character.mythicplus.runHistory, function(run)
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
  local seasonID = self:GetCurrentSeason()
  if seasonID then
    Utils:TableForEach(self.db.global.characters, function(character)
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
  for _, raid in pairs(self.raids) do
    -- EncounterJournal Quirk: This has to be called first before we can get encounter journal info.
    EJ_SelectInstance(raid.journalInstanceID)
    wipe(raid.encounters or {})
    for encounterIndex = 1, raid.numEncounters do
      local name, description, journalEncounterID, journalEncounterSectionID, journalLink, journalInstanceID, instanceEncounterID, instanceID = EJ_GetEncounterInfoByIndex(encounterIndex, raid.journalInstanceID)
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
      raid.encounters[encounterIndex] = encounter
    end
    raid.modifiedInstanceInfo = C_ModifiedInstance.GetModifiedInstanceInfoFromMapID(raid.instanceID)
  end

  for _, dungeon in pairs(self.dungeons) do
    local dungeonName, _, dungeonTimeLimit, dungeonTexture = C_ChallengeMode.GetMapUIInfo(dungeon.challengeModeID)
    dungeon.name = dungeonName
    dungeon.time = dungeonTimeLimit
    dungeon.texture = dungeon.texture ~= 0 and dungeonTexture or "Interface/Icons/achievement_bg_wineos_underxminutes"
  end

  for affixIndex, affix in pairs(self.affixes) do
    local name, description, fileDataID = C_ChallengeMode.GetAffixInfo(affix.id);
    affix.name = name
    affix.description = description
    affix.fileDataID = fileDataID
  end
end

function Data:UpdateRaidInstances()
  local character = self:GetCharacter()
  if not character then
    return
  end
  local raids = self:GetRaids();
  local numSavedInstances = GetNumSavedInstances()
  character.raids.savedInstances = {}
  if numSavedInstances > 0 then
    for savedInstanceIndex = 1, numSavedInstances do
      local name, lockoutId, reset, difficultyID, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress, extendDisabled, instanceID = GetSavedInstanceInfo(savedInstanceIndex)
      local raid = Utils:TableGet(raids, "instanceID", instanceID)
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
        encounters = {}
      }
      if reset and reset > 0 then
        savedInstance.expires = reset + time()
      end
      for encounterIndex = 1, numEncounters do
        local bossName, fileDataID, killed = GetSavedInstanceEncounterInfo(savedInstanceIndex, encounterIndex)
        local instanceEncounterID = 0
        if raid then
          local raidEncounter = Utils:TableGet(raid.encounters, "name", bossName)
          if raidEncounter then
            instanceEncounterID = raidEncounter.instanceEncounterID
          end
        end
        local encounter = {
          index = encounterIndex,
          instanceEncounterID = instanceEncounterID,
          bossName = bossName,
          fileDataID = fileDataID or 0,
          killed = killed
        }
        savedInstance.encounters[encounterIndex] = encounter
      end
      character.raids.savedInstances[savedInstanceIndex] = savedInstance
    end
  end
  -- self:UpdateUI()
end

function Data:UpdateCharacterInfo()
  local character = self:GetCharacter()
  if not character then
    return
  end
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
  if type(character.info.race) ~= "table" then character.info.race = Data.defaultCharacter.info.race end
  if playerRaceName then character.info.race.name = playerRaceName end
  if playerRaceFile then character.info.race.file = playerRaceFile end
  if playerRaceID then character.info.race.id = playerRaceID end
  if type(character.info.class) ~= "table" then character.info.class = Data.defaultCharacter.info.class end
  if playerClassName then character.info.class.name = playerClassName end
  if playerClassFile then character.info.class.file = playerClassFile end
  if playerClassID then character.info.class.id = playerClassID end
  if type(character.info.factionGroup) ~= "table" then character.info.factionGroup = Data.defaultCharacter.info.factionGroup end
  if playerFactionGroupEnglish then character.info.factionGroup.english = playerFactionGroupEnglish end
  if playerFactionGroupLocalized then character.info.factionGroup.localized = playerFactionGroupLocalized end
  if avgItemLevel then character.info.ilvl.level = avgItemLevel end
  if avgItemLevelEquipped then character.info.ilvl.equipped = avgItemLevelEquipped end
  if avgItemLevelPvp then character.info.ilvl.pvp = avgItemLevelPvp end
  if itemLevelColorR and itemLevelColorG and itemLevelColorB then character.info.ilvl.color = CreateColor(itemLevelColorR, itemLevelColorG, itemLevelColorB):GenerateHexColor() end
  if character.currencies == nil then
    character.currencies = {}
  else
    wipe(character.currencies or {})
  end
  if character.equipment == nil then
    character.equipment = {}
  else
    wipe(character.equipment or {})
  end

  local upgradePattern = ITEM_UPGRADE_TOOLTIP_FORMAT_STRING
  upgradePattern = upgradePattern:gsub("%%d", "%%s")
  upgradePattern = upgradePattern:format("(.+)", "(%d)", "(%d)")
  for slotIndex, slot in ipairs(self.inventory) do
    local inventoryItemLink = GetInventoryItemLink("player", slot.id)
    if inventoryItemLink then
      local itemUpgradeTrack, itemUpgradeLevel, itemUpgradeMax = "", "", ""
      local itemName, itemLink, itemQuality, itemLevel, itemMinLevel, itemType, itemSubType,
      itemStackCount, itemEquipLoc, itemTexture, sellPrice, classID, subclassID, bindType,
      expacID, setID, isCraftingReagent = GetItemInfo(inventoryItemLink)

      self.tooltipScan:ClearLines()
      self.tooltipScan:SetHyperlink(inventoryItemLink)
      Utils:TableForEach({self.tooltipScan:GetRegions()}, function(region)
        if region:IsObjectType("FontString") then
          local text = region:GetText()
          if text then
            local match, _, uTrack, uLevel, uMax = text:find(upgradePattern)
            if match then
              itemUpgradeTrack = uTrack
              itemUpgradeLevel = uLevel
              itemUpgradeMax = uMax
            end
          end
        end
      end)

      if itemName ~= nil then
        table.insert(character.equipment, {
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
          expacID = expacID,
          setID = setID,
          isCraftingReagent = isCraftingReagent,
          itemUpgradeTrack = itemUpgradeTrack,
          itemUpgradeLevel = itemUpgradeLevel,
          itemUpgradeMax = itemUpgradeMax,
          itemSlotID = slot.id,
          itemSlotName = slot.name
        })
      end
    end
  end
  Utils:TableForEach(self.currencies, function(dataCurrency)
    local currency = C_CurrencyInfo.GetCurrencyInfo(dataCurrency.id)
    if currency then
      currency.id = dataCurrency.id
      currency.currencyType = dataCurrency.currencyType
      table.insert(character.currencies, currency)
    end
  end)
  character.lastUpdate = GetServerTime()
  -- self:UpdateUI()
end

function Data:UpdateKeystoneItem()
  local character = self:GetCharacter()
  if not character then
    return
  end
  local dungeons = self:GetDungeons()
  local keystoneItemID = self:GetKeystoneItemID()
  -- character.mythicplus.keystone = Utils:TableCopy(Data.defaultCharacter.mythicplus.keystone)
  if keystoneItemID ~= nil then
    for bagId = 0, NUM_BAG_SLOTS do
      for slotId = 1, C_Container.GetContainerNumSlots(bagId) do
        local itemId = C_Container.GetContainerItemID(bagId, slotId)
        if itemId and itemId == keystoneItemID then
          local itemLink = C_Container.GetContainerItemLink(bagId, slotId)
          local _, _, challengeModeID, level = strsplit(":", itemLink)
          local dungeon = Utils:TableGet(dungeons, "challengeModeID", tonumber(challengeModeID))
          if dungeon then
            local newKeystone = false
            if character.mythicplus.keystone.mapId and character.mythicplus.keystone.level then
              if character.mythicplus.keystone.mapId ~= tonumber(dungeon.mapId) or character.mythicplus.keystone.level < tonumber(level) then
                newKeystone = true
              end
            elseif tonumber(dungeon.mapId) and tonumber(level) then
              newKeystone = true
            end
            local keystoneColor = "ffffffff"
            local color = C_ChallengeMode.GetKeystoneLevelRarityColor(level)
            if color ~= nil then
              keystoneColor = color:GenerateHexColor()
            end
            character.mythicplus.keystone = {
              challengeModeID = tonumber(dungeon.challengeModeID),
              mapId = tonumber(dungeon.mapId),
              level = tonumber(level),
              color = keystoneColor,
              itemId = tonumber(itemId),
              itemLink = itemLink,
            }
            if newKeystone then
              if IsInGroup() and self.db.global.announceKeystones.autoParty then
                SendChatMessage(self.constants.prefix .. "New Keystone: " .. itemLink, "PARTY")
              end
              if IsInGuild() and self.db.global.announceKeystones.autoGuild then
                SendChatMessage(self.constants.prefix .. "New Keystone: " .. itemLink, "GUILD")
              end
            end
          end
          break
        end
      end
    end
  end
  local keyStoneMapID = C_MythicPlus.GetOwnedKeystoneMapID()
  local keyStoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()
  if keyStoneMapID ~= nil then character.mythicplus.keystone.mapId = tonumber(keyStoneMapID) end
  if keyStoneLevel ~= nil then character.mythicplus.keystone.level = tonumber(keyStoneLevel) end
  -- self:UpdateUI()
end

function Data:UpdateVault()
  local character = self:GetCharacter()
  if not character then
    return
  end
  wipe(character.vault.slots or {})
  for i = 1, 3 do
    local slots = C_WeeklyRewards.GetActivities(i)
    Utils:TableForEach(slots, function(slot)
      slot.exampleRewardLink = ""
      slot.exampleRewardUpgradeLink = ""
      if slot.progress >= slot.threshold then
        local itemLink, upgradeItemLink = C_WeeklyRewards.GetExampleRewardItemHyperlinks(slot.id)
        slot.exampleRewardLink = itemLink
        slot.exampleRewardUpgradeLink = upgradeItemLink
      end
      table.insert(character.vault.slots, slot)
    end)
  end
  local HasAvailableRewards = C_WeeklyRewards.HasAvailableRewards()
  if HasAvailableRewards ~= nil then character.vault.hasAvailableRewards = HasAvailableRewards end
  -- self:UpdateUI()
end

function Data:UpdateMythicPlus()
  local character = self:GetCharacter()
  if not character then
    return
  end
  local dungeons = self:GetDungeons()
  local ratingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary("player")
  local runHistory = C_MythicPlus.GetRunHistory(true, true)
  local bestSeasonScore, bestSeasonNumber = C_MythicPlus.GetSeasonBestMythicRatingFromThisExpansion()
  local weeklyRewardAvailable = C_MythicPlus.IsWeeklyRewardAvailable() -- Unused
  local HasAvailableRewards = C_WeeklyRewards.HasAvailableRewards()
  local numHeroic, numMythic, numMythicPlus = C_WeeklyRewards.GetNumCompletedDungeonRuns();
  local affixes = self:GetAffixes()

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
    local bestTimedRun, bestNotTimedRun = C_MythicPlus.GetSeasonBestForMap(dataDungeon.challengeModeID);
    local affixScores, bestOverAllScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(dataDungeon.challengeModeID)
    local dungeon = {
      challengeModeID = dataDungeon.challengeModeID,
      bestTimedRun = {},
      bestNotTimedRun = {},
      affixScores = {},
      rating = 0,
      level = 0,
      finishedSuccess = false,
      bestOverAllScore = 0
    }
    if bestTimedRun ~= nil then dungeon.bestTimedRun = bestTimedRun end
    if bestNotTimedRun ~= nil then dungeon.bestNotTimedRun = bestNotTimedRun end
    if affixScores ~= nil then
      Utils:TableForEach(affixScores, function(affixScore)
        local affix = Utils:TableGet(affixes, "name", affixScore.name)
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
  -- self:UpdateUI()
end

-- function Data:OnEncounterEnd(instanceEncounterID, encounterName, difficultyID, groupSize, success)
--   if success then
--     RequestRaidInfo()
--   end
-- self:UpdateUI()
-- end
