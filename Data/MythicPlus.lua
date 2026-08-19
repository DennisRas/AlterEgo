---@class AE_Addon
local addon = select(2, ...)

---@class AE_Data
local Data = addon.Data

local AFFIX_TYRANNICAL = 9
local AFFIX_FORTIFIED = 10
local AFFIX_XALATAHS_GUILE = 147
local AFFIX_XALATAHS_BARGAIN_ASCENDANT = 148
local AFFIX_XALATAHS_BARGAIN_VOIDBOUND = 158
local AFFIX_XALATAHS_BARGAIN_DEVOUR = 160
local AFFIX_XALATAHS_BARGAIN_PULSAR = 162
local AFFIX_LINDORMIS_GUIDANCE = 165

---@type AE_Affix[]
Data.affixes = {
  {id = AFFIX_FORTIFIED,                  base = 1, name = "", description = "", fileDataID = nil},
  {id = AFFIX_TYRANNICAL,                 base = 1, name = "", description = "", fileDataID = nil},
  {id = AFFIX_XALATAHS_GUILE,             base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_XALATAHS_BARGAIN_ASCENDANT, base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_XALATAHS_BARGAIN_VOIDBOUND, base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_XALATAHS_BARGAIN_DEVOUR,    base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_XALATAHS_BARGAIN_PULSAR,    base = 0, name = "", description = "", fileDataID = nil},
  {id = AFFIX_LINDORMIS_GUIDANCE,         base = 0, name = "", description = "", fileDataID = nil},
}

-- Rotation: https://mythicpl.us
---@type AE_AffixRotation[]
Data.affixRotations = {
  {
    seasonID = 17,
    seasonDisplayID = 1,
    activation = {2, 5, 7, 10, 12},
    affixes = {
      {AFFIX_LINDORMIS_GUIDANCE, AFFIX_XALATAHS_BARGAIN_ASCENDANT, AFFIX_TYRANNICAL, AFFIX_FORTIFIED,  AFFIX_XALATAHS_GUILE},
      {AFFIX_LINDORMIS_GUIDANCE, AFFIX_XALATAHS_BARGAIN_PULSAR,    AFFIX_FORTIFIED,  AFFIX_TYRANNICAL, AFFIX_XALATAHS_GUILE},
      {AFFIX_LINDORMIS_GUIDANCE, AFFIX_XALATAHS_BARGAIN_VOIDBOUND, AFFIX_TYRANNICAL, AFFIX_FORTIFIED,  AFFIX_XALATAHS_GUILE},
      {AFFIX_LINDORMIS_GUIDANCE, AFFIX_XALATAHS_BARGAIN_DEVOUR,    AFFIX_FORTIFIED,  AFFIX_TYRANNICAL, AFFIX_XALATAHS_GUILE},
      {AFFIX_LINDORMIS_GUIDANCE, AFFIX_XALATAHS_BARGAIN_PULSAR,    AFFIX_TYRANNICAL, AFFIX_FORTIFIED,  AFFIX_XALATAHS_GUILE},
      {AFFIX_LINDORMIS_GUIDANCE, AFFIX_XALATAHS_BARGAIN_ASCENDANT, AFFIX_FORTIFIED,  AFFIX_TYRANNICAL, AFFIX_XALATAHS_GUILE},
      {AFFIX_LINDORMIS_GUIDANCE, AFFIX_XALATAHS_BARGAIN_DEVOUR,    AFFIX_TYRANNICAL, AFFIX_FORTIFIED,  AFFIX_XALATAHS_GUILE},
      {AFFIX_LINDORMIS_GUIDANCE, AFFIX_XALATAHS_BARGAIN_VOIDBOUND, AFFIX_FORTIFIED,  AFFIX_TYRANNICAL, AFFIX_XALATAHS_GUILE},
    },
  },
  {
    seasonID = 18,
    seasonDisplayID = 2,
    activation = {2, 5, 7, 10, 12},
    affixes = {
      {AFFIX_LINDORMIS_GUIDANCE, AFFIX_XALATAHS_BARGAIN_ASCENDANT, AFFIX_TYRANNICAL, AFFIX_FORTIFIED,  AFFIX_XALATAHS_GUILE},
      {AFFIX_LINDORMIS_GUIDANCE, AFFIX_XALATAHS_BARGAIN_PULSAR,    AFFIX_FORTIFIED,  AFFIX_TYRANNICAL, AFFIX_XALATAHS_GUILE},
      {AFFIX_LINDORMIS_GUIDANCE, AFFIX_XALATAHS_BARGAIN_VOIDBOUND, AFFIX_TYRANNICAL, AFFIX_FORTIFIED,  AFFIX_XALATAHS_GUILE},
      {AFFIX_LINDORMIS_GUIDANCE, AFFIX_XALATAHS_BARGAIN_DEVOUR,    AFFIX_FORTIFIED,  AFFIX_TYRANNICAL, AFFIX_XALATAHS_GUILE},
      {AFFIX_LINDORMIS_GUIDANCE, AFFIX_XALATAHS_BARGAIN_PULSAR,    AFFIX_TYRANNICAL, AFFIX_FORTIFIED,  AFFIX_XALATAHS_GUILE},
      {AFFIX_LINDORMIS_GUIDANCE, AFFIX_XALATAHS_BARGAIN_ASCENDANT, AFFIX_FORTIFIED,  AFFIX_TYRANNICAL, AFFIX_XALATAHS_GUILE},
      {AFFIX_LINDORMIS_GUIDANCE, AFFIX_XALATAHS_BARGAIN_DEVOUR,    AFFIX_TYRANNICAL, AFFIX_FORTIFIED,  AFFIX_XALATAHS_GUILE},
      {AFFIX_LINDORMIS_GUIDANCE, AFFIX_XALATAHS_BARGAIN_VOIDBOUND, AFFIX_FORTIFIED,  AFFIX_TYRANNICAL, AFFIX_XALATAHS_GUILE},
    },
  },
}

---@type AE_Dungeon[]
Data.dungeons = {
  {seasonID = 17, seasonDisplayID = 1, challengeModeID = 556, mapId = 658,  journalInstanceID = 278,  encounters = {}, loot = {}, teleports = {1254555},         time = 0, abbr = "POS",  name = "Pit of Saron"},
  {seasonID = 17, seasonDisplayID = 1, challengeModeID = 161, mapId = 1209, journalInstanceID = 476,  encounters = {}, loot = {}, teleports = {159898, 1254557}, time = 0, abbr = "SR",   name = "Skyreach"},
  {seasonID = 17, seasonDisplayID = 1, challengeModeID = 239, mapId = 1753, journalInstanceID = 945,  encounters = {}, loot = {}, teleports = {1254551},         time = 0, abbr = "SEAT", name = "Seat of the Triumvirate"},
  {seasonID = 17, seasonDisplayID = 1, challengeModeID = 402, mapId = 2526, journalInstanceID = 1201, encounters = {}, loot = {}, teleports = {393273},          time = 0, abbr = "AA",   name = "Algeth'ar Academy"},
  {seasonID = 17, seasonDisplayID = 1, challengeModeID = 557, mapId = 2805, journalInstanceID = 1299, encounters = {}, loot = {}, teleports = {1254400},         time = 0, abbr = "WS",   name = "Windrunner Spire"},
  {seasonID = 17, seasonDisplayID = 1, challengeModeID = 558, mapId = 2811, journalInstanceID = 1300, encounters = {}, loot = {}, teleports = {1254572},         time = 0, abbr = "MT",   name = "Magister's Terrace"},
  {seasonID = 17, seasonDisplayID = 1, challengeModeID = 560, mapId = 2874, journalInstanceID = 1315, encounters = {}, loot = {}, teleports = {1254559},         time = 0, abbr = "MC",   name = "Maisara Caverns"},
  {seasonID = 17, seasonDisplayID = 1, challengeModeID = 559, mapId = 2915, journalInstanceID = 1316, encounters = {}, loot = {}, teleports = {1254563},         time = 0, abbr = "NPX",  name = "Nexus-Point Xenas"},
  {seasonID = 18, seasonDisplayID = 2, challengeModeID = 588, mapId = 2993, journalInstanceID = 1322, encounters = {}, loot = {}, teleports = {1286812},         time = 0, abbr = "AOF",  name = "Altar of Fangs"},
  {seasonID = 18, seasonDisplayID = 2, challengeModeID = 587, mapId = 2813, journalInstanceID = 1304, encounters = {}, loot = {}, teleports = {1286809},         time = 0, abbr = "MR",   name = "Murder Row"},
  {seasonID = 18, seasonDisplayID = 2, challengeModeID = 586, mapId = 2825, journalInstanceID = 1311, encounters = {}, loot = {}, teleports = {1286807},         time = 0, abbr = "DON",  name = "Den of Nalorakk"},
  {seasonID = 18, seasonDisplayID = 2, challengeModeID = 584, mapId = 2859, journalInstanceID = 1309, encounters = {}, loot = {}, teleports = {1286801},         time = 0, abbr = "BV",  name = "The Blinding Vale"},
  {seasonID = 18, seasonDisplayID = 2, challengeModeID = 585, mapId = 2923, journalInstanceID = 1313, encounters = {}, loot = {}, teleports = {1286804},         time = 0, abbr = "VSA",   name = "Voidscar Arena"},
  {seasonID = 18, seasonDisplayID = 2, challengeModeID = 249, mapId = 1762, journalInstanceID = 1041, encounters = {}, loot = {}, teleports = {1286831},         time = 0, abbr = "KR",   name = "Kings' Rest"},
  {seasonID = 18, seasonDisplayID = 2, challengeModeID = 250, mapId = 1877, journalInstanceID = 1030, encounters = {}, loot = {}, teleports = {1286828},         time = 0, abbr = "TOS",  name = "Temple of Sethraliss"},
  {seasonID = 18, seasonDisplayID = 2, challengeModeID = 399, mapId = 2521, journalInstanceID = 1202, encounters = {}, loot = {}, teleports = {393256},          time = 0, abbr = "RLP",  name = "Ruby Life Pools"},
}

---@type AE_Keystone[]
Data.keystones = {
  {seasonID = 17, seasonDisplayID = 1, itemID = 180653},
  {seasonID = 18, seasonDisplayID = 2, itemID = 180653},
}
