---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

---@class AE_Data
local Data = {}
addon.Data = Data

Data.dbVersion = 22

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
  currencies = {},
  raids = {
    savedInstances = {},
  },
  mythicplus = {
    numCompletedDungeonRuns = {
      heroic = 0,
      mythic = 0,
      mythicPlus = 0,
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
    dungeons = {},
  },
  vault = {
    hasAvailableRewards = false,
    slots = {},
    activityEncounterInfo = {},
  },
}

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

---@type AE_Affix[]
Data.affixes = {
  {id = AFFIX_VOLCANIC,                   base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_RAGING,                     base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_BOLSTERING,                 base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_SANGUINE,                   base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_FORTIFIED,                  base = 1, name = "", description = "", fileDataID = nil},
  {id = AFFIX_TYRANNICAL,                 base = 1, name = "", description = "", fileDataID = nil},
  {id = AFFIX_BURSTING,                   base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_SPITEFUL,                   base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_STORMING,                   base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_ENTANGLING,                 base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_AFFLICTED,                  base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_INCORPOREAL,                base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_XALATAHS_GUILE,             base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_XALATAHS_BARGAIN_ASCENDANT, base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_CHALLENGERS_PERIL,          base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_XALATAHS_BARGAIN_VOIDBOUND, base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_XALATAHS_BARGAIN_OBLIVION,  base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_XALATAHS_BARGAIN_DEVOUR,    base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_XALATAHS_BARGAIN_PULSAR,    base = 0, name = "", description = "", fileDataID = nil},
}

---@type AE_RaidDifficulty[]
Data.raidDifficulties = {
  {id = 14, color = RARE_BLUE_COLOR,        order = 2, abbr = "N", name = "Normal"},
  {id = 15, color = EPIC_PURPLE_COLOR,      order = 3, abbr = "H", name = "Heroic"},
  {id = 16, color = LEGENDARY_ORANGE_COLOR, order = 4, abbr = "M", name = "Mythic"},
  {id = 17, color = UNCOMMON_GREEN_COLOR,   order = 1, abbr = "L", name = "Looking For Raid", short = "LFR"},
}

---@type AE_VaultType[]
Data.vaultTypes = {
  {id = Enum.WeeklyRewardChestThresholdType.Raid,       name = RAIDS},
  {id = Enum.WeeklyRewardChestThresholdType.Activities, name = DUNGEONS},
  {id = Enum.WeeklyRewardChestThresholdType.World,      name = WORLD},
}

-- Rotation: https://mythicpl.us
---@type AE_AffixRotation[]
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
    },
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
    },
  },
  {
    seasonID = 13,
    seasonDisplayID = 1,
    activation = {2, 4, 7, 10, 12},
    affixes = {
      {AFFIX_XALATAHS_BARGAIN_ASCENDANT, AFFIX_TYRANNICAL, AFFIX_CHALLENGERS_PERIL, AFFIX_FORTIFIED,  AFFIX_XALATAHS_GUILE},
      {AFFIX_XALATAHS_BARGAIN_OBLIVION,  AFFIX_FORTIFIED,  AFFIX_CHALLENGERS_PERIL, AFFIX_TYRANNICAL, AFFIX_XALATAHS_GUILE},
      {AFFIX_XALATAHS_BARGAIN_VOIDBOUND, AFFIX_TYRANNICAL, AFFIX_CHALLENGERS_PERIL, AFFIX_FORTIFIED,  AFFIX_XALATAHS_GUILE},
      {AFFIX_XALATAHS_BARGAIN_DEVOUR,    AFFIX_FORTIFIED,  AFFIX_CHALLENGERS_PERIL, AFFIX_TYRANNICAL, AFFIX_XALATAHS_GUILE},
      {AFFIX_XALATAHS_BARGAIN_OBLIVION,  AFFIX_TYRANNICAL, AFFIX_CHALLENGERS_PERIL, AFFIX_FORTIFIED,  AFFIX_XALATAHS_GUILE},
      {AFFIX_XALATAHS_BARGAIN_ASCENDANT, AFFIX_FORTIFIED,  AFFIX_CHALLENGERS_PERIL, AFFIX_TYRANNICAL, AFFIX_XALATAHS_GUILE},
      {AFFIX_XALATAHS_BARGAIN_DEVOUR,    AFFIX_TYRANNICAL, AFFIX_CHALLENGERS_PERIL, AFFIX_FORTIFIED,  AFFIX_XALATAHS_GUILE},
      {AFFIX_XALATAHS_BARGAIN_VOIDBOUND, AFFIX_FORTIFIED,  AFFIX_CHALLENGERS_PERIL, AFFIX_TYRANNICAL, AFFIX_XALATAHS_GUILE},
    },
    {
      seasonID = 14,
      seasonDisplayID = 2,
      activation = {4, 7, 10, 12},
      affixes = {
        {AFFIX_XALATAHS_BARGAIN_ASCENDANT, AFFIX_TYRANNICAL, AFFIX_FORTIFIED,  AFFIX_XALATAHS_GUILE},
        {AFFIX_XALATAHS_BARGAIN_PULSAR,    AFFIX_FORTIFIED,  AFFIX_TYRANNICAL, AFFIX_XALATAHS_GUILE},
        {AFFIX_XALATAHS_BARGAIN_VOIDBOUND, AFFIX_TYRANNICAL, AFFIX_FORTIFIED,  AFFIX_XALATAHS_GUILE},
        {AFFIX_XALATAHS_BARGAIN_DEVOUR,    AFFIX_FORTIFIED,  AFFIX_TYRANNICAL, AFFIX_XALATAHS_GUILE},
        {AFFIX_XALATAHS_BARGAIN_PULSAR,    AFFIX_TYRANNICAL, AFFIX_FORTIFIED,  AFFIX_XALATAHS_GUILE},
        {AFFIX_XALATAHS_BARGAIN_ASCENDANT, AFFIX_FORTIFIED,  AFFIX_TYRANNICAL, AFFIX_XALATAHS_GUILE},
        {AFFIX_XALATAHS_BARGAIN_DEVOUR,    AFFIX_TYRANNICAL, AFFIX_FORTIFIED,  AFFIX_XALATAHS_GUILE},
        {AFFIX_XALATAHS_BARGAIN_VOIDBOUND, AFFIX_FORTIFIED,  AFFIX_TYRANNICAL, AFFIX_XALATAHS_GUILE},
      },
    },
  },
}

---@type AE_Keystone[]
Data.keystones = {
  {seasonID = 11, seasonDisplayID = 3, itemID = 151086},
  {seasonID = 12, seasonDisplayID = 4, itemID = 180653},
  {seasonID = 13, seasonDisplayID = 1, itemID = 180653},
  {seasonID = 14, seasonDisplayID = 2, itemID = 180653}, -- This could be 151086 unless that's just on the PTR
}

---@type AE_Dungeon[]
Data.dungeons = {
  {seasonID = 10, seasonDisplayID = 2, challengeModeID = 206, mapId = 1458, journalInstanceID = 767,  encounters = {}, loot = {}, teleports = {410078},         time = 0, abbr = "NL",    name = "Neltharion's Lair"},
  {seasonID = 10, seasonDisplayID = 2, challengeModeID = 245, mapId = 1754, journalInstanceID = 1001, encounters = {}, loot = {}, teleports = {410071},         time = 0, abbr = "FH",    name = "Freehold"},
  {seasonID = 10, seasonDisplayID = 2, challengeModeID = 251, mapId = 1841, journalInstanceID = 1022, encounters = {}, loot = {}, teleports = {410074},         time = 0, abbr = "UNDR",  name = "The Underrot"},
  {seasonID = 10, seasonDisplayID = 2, challengeModeID = 403, mapId = 2451, journalInstanceID = 1197, encounters = {}, loot = {}, teleports = {393222},         time = 0, abbr = "ULD",   name = "Uldaman: Legacy of Tyr"},
  {seasonID = 10, seasonDisplayID = 2, challengeModeID = 404, mapId = 2519, journalInstanceID = 1199, encounters = {}, loot = {}, teleports = {393276},         time = 0, abbr = "NELT",  name = "Neltharus"},
  {seasonID = 10, seasonDisplayID = 2, challengeModeID = 405, mapId = 2520, journalInstanceID = 1196, encounters = {}, loot = {}, teleports = {393267},         time = 0, abbr = "BH",    name = "Brackenhide Hollow"},
  {seasonID = 10, seasonDisplayID = 2, challengeModeID = 406, mapId = 2527, journalInstanceID = 1204, encounters = {}, loot = {}, teleports = {393283},         time = 0, abbr = "HOI",   name = "Halls of Infusion"},
  {seasonID = 10, seasonDisplayID = 2, challengeModeID = 438, mapId = 657,  journalInstanceID = 68,   encounters = {}, loot = {}, teleports = {410080},         time = 0, abbr = "VP",    name = "The Vortex Pinnacle"},
  {seasonID = 11, seasonDisplayID = 3, challengeModeID = 168, mapId = 1279, journalInstanceID = 556,  encounters = {}, loot = {}, teleports = {159901},         time = 0, abbr = "EB",    name = "The Everbloom"},
  {seasonID = 11, seasonDisplayID = 3, challengeModeID = 198, mapId = 1466, journalInstanceID = 762,  encounters = {}, loot = {}, teleports = {424163},         time = 0, abbr = "DHT",   name = "Darkheart Thicket"},
  {seasonID = 11, seasonDisplayID = 3, challengeModeID = 199, mapId = 1501, journalInstanceID = 740,  encounters = {}, loot = {}, teleports = {424153},         time = 0, abbr = "BRH",   name = "Black Rook Hold"},
  {seasonID = 11, seasonDisplayID = 3, challengeModeID = 244, mapId = 1763, journalInstanceID = 968,  encounters = {}, loot = {}, teleports = {424187},         time = 0, abbr = "AD",    name = "Atal'Dazar"},
  {seasonID = 11, seasonDisplayID = 3, challengeModeID = 248, mapId = 1862, journalInstanceID = 1021, encounters = {}, loot = {}, teleports = {424167},         time = 0, abbr = "WM",    name = "Waycrest Manor"},
  {seasonID = 11, seasonDisplayID = 3, challengeModeID = 456, mapId = 643,  journalInstanceID = 65,   encounters = {}, loot = {}, teleports = {424142},         time = 0, abbr = "TOTT",  name = "Throne of the Tides"},
  {seasonID = 11, seasonDisplayID = 3, challengeModeID = 463, mapId = 2579, journalInstanceID = 1209, encounters = {}, loot = {}, teleports = {424197},         time = 0, abbr = "FALL",  name = "Dawn of the Infinite: Galakrond's Fall", short = "DOTI: Galakrond's Fall"},
  {seasonID = 11, seasonDisplayID = 3, challengeModeID = 464, mapId = 2579, journalInstanceID = 1209, encounters = {}, loot = {}, teleports = {424197},         time = 0, abbr = "RISE",  name = "Dawn of the Infinite: Murozond's Rise",  short = "DOTI: Murozond's Rise"},
  {seasonID = 12, seasonDisplayID = 4, challengeModeID = 399, mapId = 2521, journalInstanceID = 1202, encounters = {}, loot = {}, teleports = {393256},         time = 0, abbr = "RLP",   name = "Ruby Life Pools"},
  {seasonID = 12, seasonDisplayID = 4, challengeModeID = 400, mapId = 2516, journalInstanceID = 1198, encounters = {}, loot = {}, teleports = {393262},         time = 0, abbr = "NO",    name = "The Nokhud Offensive"},
  {seasonID = 12, seasonDisplayID = 4, challengeModeID = 401, mapId = 2515, journalInstanceID = 1203, encounters = {}, loot = {}, teleports = {393279},         time = 0, abbr = "AV",    name = "The Azure Vault"},
  {seasonID = 12, seasonDisplayID = 4, challengeModeID = 402, mapId = 2526, journalInstanceID = 1201, encounters = {}, loot = {}, teleports = {393273},         time = 0, abbr = "AA",    name = "Algeth'ar Academy"},
  {seasonID = 12, seasonDisplayID = 4, challengeModeID = 403, mapId = 2451, journalInstanceID = 1197, encounters = {}, loot = {}, teleports = {393222},         time = 0, abbr = "ULD",   name = "Uldaman: Legacy of Tyr"},
  {seasonID = 12, seasonDisplayID = 4, challengeModeID = 404, mapId = 2519, journalInstanceID = 1199, encounters = {}, loot = {}, teleports = {393276},         time = 0, abbr = "NELT",  name = "Neltharus"},
  {seasonID = 12, seasonDisplayID = 4, challengeModeID = 405, mapId = 2520, journalInstanceID = 1196, encounters = {}, loot = {}, teleports = {393267},         time = 0, abbr = "BH",    name = "Brackenhide Hollow"},
  {seasonID = 12, seasonDisplayID = 4, challengeModeID = 406, mapId = 2527, journalInstanceID = 1204, encounters = {}, loot = {}, teleports = {393283},         time = 0, abbr = "HOI",   name = "Halls of Infusion"},
  {seasonID = 13, seasonDisplayID = 1, challengeModeID = 503, mapId = 2660, journalInstanceID = 1271, encounters = {}, loot = {}, teleports = {445417},         time = 0, abbr = "ARAK",  name = "Ara-Kara, City of Echoes"},
  {seasonID = 13, seasonDisplayID = 1, challengeModeID = 502, mapId = 2669, journalInstanceID = 1274, encounters = {}, loot = {}, teleports = {445416},         time = 0, abbr = "COT",   name = "City of Threads"},
  {seasonID = 13, seasonDisplayID = 1, challengeModeID = 507, mapId = 670,  journalInstanceID = 71,   encounters = {}, loot = {}, teleports = {445424},         time = 0, abbr = "GB",    name = "Grim Batol"},
  {seasonID = 13, seasonDisplayID = 1, challengeModeID = 375, mapId = 2290, journalInstanceID = 1184, encounters = {}, loot = {}, teleports = {354464},         time = 0, abbr = "MISTS", name = "Mists of Tirna Scithe"},
  {seasonID = 13, seasonDisplayID = 1, challengeModeID = 353, mapId = 1822, journalInstanceID = 1023, encounters = {}, loot = {}, teleports = {445418, 464256}, time = 0, abbr = "SIEGE", name = "Siege of Boralus"},
  {seasonID = 13, seasonDisplayID = 1, challengeModeID = 505, mapId = 2662, journalInstanceID = 1270, encounters = {}, loot = {}, teleports = {445414},         time = 0, abbr = "DAWN",  name = "The Dawnbreaker"},
  {seasonID = 13, seasonDisplayID = 1, challengeModeID = 376, mapId = 2286, journalInstanceID = 1182, encounters = {}, loot = {}, teleports = {354462},         time = 0, abbr = "NW",    name = "The Necrotic Wake"},
  {seasonID = 13, seasonDisplayID = 1, challengeModeID = 501, mapId = 2652, journalInstanceID = 1269, encounters = {}, loot = {}, teleports = {445269},         time = 0, abbr = "SV",    name = "The Stonevault"},
  {seasonID = 14, seasonDisplayID = 2, challengeModeID = 247, mapId = 1594, journalInstanceID = 1012, encounters = {}, loot = {}, teleports = {467553, 467555}, time = 0, abbr = "ML",    name = "The MOTHERLODE!!"},
  {seasonID = 14, seasonDisplayID = 2, challengeModeID = 370, mapId = 2097, journalInstanceID = 1178, encounters = {}, loot = {}, teleports = {373274},         time = 0, abbr = "WORK",  name = "Operation: Mechagon"},
  {seasonID = 14, seasonDisplayID = 2, challengeModeID = 382, mapId = 2293, journalInstanceID = 1187, encounters = {}, loot = {}, teleports = {354467},         time = 0, abbr = "TOP",   name = "Theater of Pain"},
  {seasonID = 14, seasonDisplayID = 2, challengeModeID = 499, mapId = 2649, journalInstanceID = 1267, encounters = {}, loot = {}, teleports = {445444},         time = 0, abbr = "PSF",   name = "Priory of the Sacred Flame"},
  {seasonID = 14, seasonDisplayID = 2, challengeModeID = 500, mapId = 2648, journalInstanceID = 1268, encounters = {}, loot = {}, teleports = {445443},         time = 0, abbr = "ROOK",  name = "The Rookery"},
  {seasonID = 14, seasonDisplayID = 2, challengeModeID = 504, mapId = 2651, journalInstanceID = 1210, encounters = {}, loot = {}, teleports = {445441},         time = 0, abbr = "DCF",   name = "Darkflame Cleft"},
  {seasonID = 14, seasonDisplayID = 2, challengeModeID = 506, mapId = 2661, journalInstanceID = 1272, encounters = {}, loot = {}, teleports = {445440},         time = 0, abbr = "BREW",  name = "Cinderbrew Meadery"},
  {seasonID = 14, seasonDisplayID = 2, challengeModeID = 525, mapId = 2773, journalInstanceID = 1298, encounters = {}, loot = {}, teleports = {1216786},        time = 0, abbr = "FLOOD", name = "Operation: Floodgate"},
}

---@type AE_Raid[]
Data.raids = {
  {seasonID = 9,  seasonDisplayID = 1, instanceID = 2522, journalInstanceID = 1200, order = 1, numEncounters = 8, encounters = {}, loot = {}, modifiedInstanceInfo = nil, abbr = "VOTI", name = "Vault of the Incarnates"},
  {seasonID = 10, seasonDisplayID = 2, instanceID = 2569, journalInstanceID = 1208, order = 2, numEncounters = 9, encounters = {}, loot = {}, modifiedInstanceInfo = nil, abbr = "ATSC", name = "Aberrus, the Shadowed Crucible"},
  {seasonID = 11, seasonDisplayID = 3, instanceID = 2549, journalInstanceID = 1207, order = 3, numEncounters = 9, encounters = {}, loot = {}, modifiedInstanceInfo = nil, abbr = "ATDH", name = "Amirdrassil, the Dream's Hope"},
  {seasonID = 12, seasonDisplayID = 4, instanceID = 2522, journalInstanceID = 1200, order = 1, numEncounters = 8, encounters = {}, loot = {}, modifiedInstanceInfo = nil, abbr = "VOTI", name = "Vault of the Incarnates"},
  {seasonID = 12, seasonDisplayID = 4, instanceID = 2569, journalInstanceID = 1208, order = 2, numEncounters = 9, encounters = {}, loot = {}, modifiedInstanceInfo = nil, abbr = "ATSC", name = "Aberrus, the Shadowed Crucible"},
  {seasonID = 12, seasonDisplayID = 4, instanceID = 2549, journalInstanceID = 1207, order = 3, numEncounters = 9, encounters = {}, loot = {}, modifiedInstanceInfo = nil, abbr = "ATDH", name = "Amirdrassil, the Dream's Hope"},
  {seasonID = 13, seasonDisplayID = 1, instanceID = 2657, journalInstanceID = 1273, order = 1, numEncounters = 8, encounters = {}, loot = {}, modifiedInstanceInfo = nil, abbr = "NAP",  name = "Nerub-ar Palace"},
  {seasonID = 14, seasonDisplayID = 2, instanceID = 2769, journalInstanceID = 1296, order = 2, numEncounters = 8, encounters = {}, loot = {}, modifiedInstanceInfo = nil, abbr = "LOU",  name = "Liberation of Undermine"},
}

---@type AE_Currency[]
Data.currencies = {
  {seasonID = 11, seasonDisplayID = 3, id = 2709, currencyType = "crest"},                    -- Aspect
  {seasonID = 11, seasonDisplayID = 3, id = 2708, currencyType = "crest"},                    -- Wyrm
  {seasonID = 11, seasonDisplayID = 3, id = 2707, currencyType = "crest"},                    -- Drake
  {seasonID = 11, seasonDisplayID = 3, id = 2706, currencyType = "crest"},                    -- Whelpling
  {seasonID = 11, seasonDisplayID = 3, id = 2245, currencyType = "upgrade"},                  -- Flightstones
  {seasonID = 11, seasonDisplayID = 3, id = 2796, currencyType = "catalyst"},                 -- Catalyst
  {seasonID = 12, seasonDisplayID = 4, id = 2812, currencyType = "crest"},                    -- Aspect
  {seasonID = 12, seasonDisplayID = 4, id = 2809, currencyType = "crest"},                    -- Wyrm
  {seasonID = 12, seasonDisplayID = 4, id = 2807, currencyType = "crest"},                    -- Drake
  {seasonID = 12, seasonDisplayID = 4, id = 2806, currencyType = "crest"},                    -- Whelpling
  {seasonID = 12, seasonDisplayID = 4, id = 2245, currencyType = "upgrade"},                  -- Flightstones
  {seasonID = 12, seasonDisplayID = 4, id = 2912, currencyType = "catalyst"},                 -- Catalyst
  {seasonID = 12, seasonDisplayID = 4, id = 3010, currencyType = "dinar",   itemID = 213089}, -- Dinar
  {seasonID = 13, seasonDisplayID = 1, id = 2914, currencyType = "crest"},                    -- Weathered
  {seasonID = 13, seasonDisplayID = 1, id = 2915, currencyType = "crest"},                    -- Carved
  {seasonID = 13, seasonDisplayID = 1, id = 2916, currencyType = "crest"},                    -- Runed
  {seasonID = 13, seasonDisplayID = 1, id = 2917, currencyType = "crest"},                    -- Gilded
  {seasonID = 13, seasonDisplayID = 1, id = 3008, currencyType = "upgrade"},                  -- Valorstones
  {seasonID = 13, seasonDisplayID = 1, id = 2813, currencyType = "catalyst"},                 -- Catalyst
  {seasonID = 13, seasonDisplayID = 1, id = 3028, currencyType = "delve"},                    -- Restored Coffer key
  {seasonID = 14, seasonDisplayID = 2, id = 3110, currencyType = "crest"},                    -- Gilded
  {seasonID = 14, seasonDisplayID = 2, id = 3109, currencyType = "crest"},                    -- Runed
  {seasonID = 14, seasonDisplayID = 2, id = 3108, currencyType = "crest"},                    -- Carved
  {seasonID = 14, seasonDisplayID = 2, id = 3107, currencyType = "crest"},                    -- Weathered
  {seasonID = 14, seasonDisplayID = 2, id = 3008, currencyType = "upgrade"},                  -- Valorstones
  {seasonID = 14, seasonDisplayID = 2, id = 3116, currencyType = "catalyst"},                 -- Catalyst
  {seasonID = 14, seasonDisplayID = 2, id = 3028, currencyType = "delve"},                    -- Restored Coffer key
}

Data.cache = {
  seasonID = nil,
  seasonDisplayID = nil,
  ---@type MythicPlusKeystoneAffix[]
  currentAffixes = {},
  classes = {},
  specs = {},
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

---Get the current Season IDs
---@return number, number
function Data:GetCurrentSeason()
  if not self.cache.seasonID or self.cache.seasonID == -1 then
    self.cache.seasonID = C_MythicPlus.GetCurrentSeason()
  end
  if not self.cache.seasonDisplayID or self.cache.seasonDisplayID == -1 then
    self.cache.seasonDisplayID = C_MythicPlus.GetCurrentUIDisplaySeason()
  end
  return self.cache.seasonID or -1, self.cache.seasonDisplayID or -1
end

---Get the currencies of the current season
---@return AE_Currency[]
function Data:GetCurrencies()
  local seasonID = self:GetCurrentSeason()
  return addon.Utils:TableFilter(self.currencies, function(dataCurrency)
    return dataCurrency.seasonID == seasonID
  end)
end

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

---Get all of the raids in the current season
---@param unfiltered boolean?
---@return AE_RaidDifficulty[]
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

---Get the current affixes of the week
---@return MythicPlusKeystoneAffix[]
function Data:GetCurrentAffixes()
  if addon.Utils:TableCount(self.cache.currentAffixes) == 0 then
    local currentAffixes = C_MythicPlus.GetCurrentAffixes()
    if currentAffixes then
      self.cache.currentAffixes = currentAffixes
    end
  end
  return self.cache.currentAffixes
end

---Get either all affixes or just the base seasonal affixes
---@param baseOnly boolean?
---@return AE_Affix[]
function Data:GetAffixes(baseOnly)
  return addon.Utils:TableFilter(self.affixes, function(dataAffix)
    return not baseOnly or dataAffix.base == 1
  end)
end

---Get affix rotation of the season
---@return AE_AffixRotation|nil
function Data:GetAffixRotation()
  local seasonID = self:GetCurrentSeason()
  return addon.Utils:TableGet(self.affixRotations, "seasonID", seasonID)
end

---Get the index of the active affix week
---@param currentAffixes MythicPlusKeystoneAffix|nil
---@return number
function Data:GetActiveAffixRotation(currentAffixes)
  local affixRotation = self:GetAffixRotation()
  local index = 0
  if currentAffixes and affixRotation then
    addon.Utils:TableForEach(affixRotation.affixes, function(affixWeek, affixWeekIndex)
      local thisWeek = true
      addon.Utils:TableForEach(affixWeek, function(affixID, affixIndex)
        if not (currentAffixes[affixIndex] and currentAffixes[affixIndex].id == affixID) then
          thisWeek = false
        end
      end)
      if thisWeek then
        index = affixWeekIndex
      end
    end)
  end
  return index
end

---Get the Keystone ItemID of the current season
---@return number|nil
function Data:GetKeystoneItemID()
  local seasonID = self:GetCurrentSeason()
  local keystone = addon.Utils:TableGet(self.keystones, "seasonID", seasonID)

  if keystone ~= nil then
    return keystone.itemID
  end

  return nil
end

---Get all of the M+ dungeons in the current season
---@return AE_Dungeon[]
function Data:GetDungeons()
  local seasonID = self:GetCurrentSeason()
  local dungeons = addon.Utils:TableFilter(self.dungeons, function(dataDungeon)
    return dataDungeon.seasonID == seasonID
  end)

  table.sort(dungeons, function(a, b)
    return strcmputf8i(a.name, b.name) < 0
  end)

  return dungeons
end

---Get all of the raids in the current season
---@param unfiltered boolean?
---@return AE_Raid[]
function Data:GetRaids(unfiltered)
  local seasonID = self:GetCurrentSeason()
  local raids = addon.Utils:TableFilter(self.raids, function(dataRaid)
    return dataRaid.seasonID == seasonID
  end)

  table.sort(raids, function(a, b)
    return a.order < b.order
  end)

  if unfiltered then
    return raids
  end

  if self.db.global.raids.modifiedInstanceOnly and seasonID == 12 then
    raids = addon.Utils:TableFilter(raids, function(raid)
      return raid.modifiedInstanceInfo ~= nil
    end)
  end

  return raids
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
      local affixes = self:GetAffixes()
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
      wipe(character.vault.activityEncounterInfo or {})
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
  local seasonID = self:GetCurrentSeason()

  for _, raid in pairs(self.raids) do
    -- if raid.seasonID == seasonID then
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
    -- end

    if raid.seasonID == seasonID then
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
    end
  end

  for _, dungeon in pairs(self.dungeons) do
    -- if dungeon.seasonID == seasonID then
    --   EJ_ClearSearch()
    --   EJ_ResetLootFilter()
    --   EJ_SelectInstance(dungeon.journalInstanceID)

    --   local count = 0
    --   for classID = 1, GetNumClasses() do
    --     for specIndex = 1, GetNumSpecializationsForClassID(classID) do
    --       local specID = GetSpecializationInfoForClassID(classID, specIndex)
    --       if specID then
    --         EJ_SetLootFilter(classID, specID)
    --         for i = 1, EJ_GetNumLoot() do
    --           local lootInfo = C_EncounterJournal.GetLootInfoByIndex(i)
    --           if lootInfo.name ~= nil and lootInfo.slot ~= nil and lootInfo.slot ~= "" then
    --             local item = dungeon.loot[lootInfo.itemID]
    --             if not item then
    --               item = lootInfo
    --               item.stats = C_Item.GetItemStats(lootInfo.link)
    --               item.classes = {}
    --               item.specs = {}
    --               dungeon.loot[lootInfo.itemID] = item
    --               count = count + 1
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
    -- end

    if dungeon.seasonID == seasonID then
      -- TODO: Get and store more dungeon data for m+
      local dungeonName, _, dungeonTimeLimit, dungeonTexture = C_ChallengeMode.GetMapUIInfo(dungeon.challengeModeID)
      dungeon.name = dungeonName
      dungeon.time = dungeonTimeLimit
      dungeon.texture = dungeon.texture ~= 0 and dungeonTexture or "Interface/Icons/achievement_bg_wineos_underxminutes"

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
    end
  end

  for _, affix in pairs(self.affixes) do
    local name, description, fileDataID = C_ChallengeMode.GetAffixInfo(affix.id)
    affix.name = name
    affix.description = description
    affix.fileDataID = fileDataID
  end
end

function Data:UpdateRaidInstances()
  local character = self:GetCharacter()
  if not character then return end
  character.raids.savedInstances = wipe(character.raids.savedInstances or {})

  local raids = self:GetRaids()
  local numSavedInstances = GetNumSavedInstances()
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
  if not money then return end

  character.money = money
end

function Data:UpdateCurrencies()
  local character = self:GetCharacter()
  if not character then return end

  character.currencies = wipe(character.currencies or {})

  addon.Utils:TableForEach(self.currencies or {}, function(dataCurrency)
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

  character.equipment = wipe(character.equipment or {})

  local upgradePattern = ITEM_UPGRADE_TOOLTIP_FORMAT_STRING
  upgradePattern = upgradePattern:gsub("%%d", "%%s")
  upgradePattern = upgradePattern:format("(.+)", "(%d+)", "(%d+)")

  addon.Utils:TableForEach(self.inventory or {}, function(slot)
    local inventoryItemLink = GetInventoryItemLink("player", slot.id)
    if not inventoryItemLink then return end

    local itemUpgradeTrack, itemUpgradeLevel, itemUpgradeMax, itemUpgradeColor = "", 0, 0, ""
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
      if line.leftColor then
        itemUpgradeColor = line.leftColor:GenerateHexColor()
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
      itemUpgradeColor = itemUpgradeColor,
      itemSlotID = slot.id,
      itemSlotName = slot.name,
    }
    table.insert(character.equipment, equipment)
  end)
end

function Data:UpdateKeystoneItem()
  local character = self:GetCharacter()
  if not character then return end
  local dungeons = self:GetDungeons()
  local keystoneItemID = self:GetKeystoneItemID()

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
    if keyStoneMapID ~= nil then character.mythicplus.keystone.mapId = tonumber(keyStoneMapID) or 0 end
    if keyStoneLevel ~= nil then character.mythicplus.keystone.level = tonumber(keyStoneLevel) or 0 end
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
    challengeModeID = tonumber(dungeon.challengeModeID) or 0,
    mapId = tonumber(dungeon.mapId) or 0,
    level = tonumber(level) or 0,
    color = color,
    itemId = tonumber(keystoneItemID) or 0,
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

  character.vault.activityEncounterInfo = wipe(character.vault.activityEncounterInfo or {})
  character.vault.slots = wipe(character.vault.slots or {})

  addon.Utils:TableForEach(self.vaultTypes or {}, function(vaultType)
    for index = 1, 3 do
      local encounters = C_WeeklyRewards.GetActivityEncounterInfo(vaultType.id, index)
      if encounters then
        addon.Utils:TableForEach(encounters, function(encounter)
          if not encounter then return end
          encounter.type = vaultType.id
          encounter.index = index
          table.insert(character.vault.activityEncounterInfo, encounter)
        end)
      end
    end
  end)

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

  local dungeons = self:GetDungeons()
  local ratingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary("player")
  local runHistory = C_MythicPlus.GetRunHistory(true, true)
  local bestSeasonScore, bestSeasonNumber = C_MythicPlus.GetSeasonBestMythicRatingFromThisExpansion()
  local weeklyRewardAvailable = C_MythicPlus.IsWeeklyRewardAvailable() -- Unused
  local HasAvailableRewards = C_WeeklyRewards.HasAvailableRewards()
  local numHeroic, numMythic, numMythicPlus = C_WeeklyRewards.GetNumCompletedDungeonRuns()
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

  character.mythicplus.dungeons = wipe(character.mythicplus.dungeons or {})
  for _, dataDungeon in pairs(dungeons) do
    local bestTimedRun, bestNotTimedRun = C_MythicPlus.GetSeasonBestForMap(dataDungeon.challengeModeID)
    local affixScores, bestOverAllScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(dataDungeon.challengeModeID)

    if affixScores then
      addon.Utils:TableForEach(affixScores, function(affixScore)
        local affix = addon.Utils:TableGet(affixes, "name", affixScore.name)
        affixScore.id = affix and affix.id or 0
      end)
    end

    ---@type AE_CharacterDungeon
    local dungeon = {
      challengeModeID = dataDungeon.challengeModeID,
      rating = 0,
      level = 0,
      finishedSuccess = false,
      bestTimedRun = bestTimedRun,
      bestNotTimedRun = bestNotTimedRun,
      affixScores = affixScores,
      bestOverAllScore = bestOverAllScore,
    }

    if ratingSummary then
      local run = addon.Utils:TableFind(ratingSummary.runs or {}, function(run)
        return run.challengeModeID == dataDungeon.challengeModeID
      end)
      if run then
        dungeon.rating = run.mapScore
        dungeon.level = run.bestRunLevel
        dungeon.finishedSuccess = run.finishedSuccess
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
