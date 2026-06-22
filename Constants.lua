---@class AE_Addon
local addon = select(2, ...)

---@class AE_Constants
local Constants = {}
addon.Constants = Constants

Constants.prefix = format("<%s> ", addon.name)
Constants.commands = {
  "ae",
}
Constants.media = {
  WhiteSquare = "Interface/BUTTONS/WHITE8X8",
  Logo = format("Interface/AddOns/%s/Media/Logo.blp", addon.name),
  LogoTransparent = format("Interface/AddOns/%s/Media/LogoTransparent.blp", addon.name),
  IconClose = format("Interface/AddOns/%s/Media/Icon_Close.blp", addon.name),
  IconSettings = format("Interface/AddOns/%s/Media/Icon_Settings.blp", addon.name),
  IconSorting = format("Interface/AddOns/%s/Media/Icon_Sorting.blp", addon.name),
  IconCharacters = format("Interface/AddOns/%s/Media/Icon_Characters.blp", addon.name),
  IconAnnounce = format("Interface/AddOns/%s/Media/Icon_Announce.blp", addon.name),
  IconKeyhole = format("Interface/AddOns/%s/Media/Icon_Keyhole.blp", addon.name),
  IconKill = format("Interface/AddOns/%s/Media/Icon_Skull2.blp", addon.name),
}
Constants.colors = {
  -- Primary brand colors
  primary = {r = 0.2, g = 0.6, b = 1.0, a = 1.0},
  titlebar = {r = 0.1, g = 0.1, b = 0.1, a = 1.0},
  -- Common UI colors
  black = {r = 0, g = 0, b = 0, a = 1.0},
  white = {r = 1, g = 1, b = 1, a = 1.0},
  gray = {r = 0.5, g = 0.5, b = 0.5, a = 1.0},
  red = {r = 1, g = 0, b = 0, a = 1.0},
  -- Background colors with alpha
  header = {r = 0, g = 0, b = 0, a = 0.3},
  border = {r = 0.5, g = 0.5, b = 0.5, a = 0.3},
  borderLight = {r = 0.5, g = 0.5, b = 0.5, a = 0.1},
  striped = {r = 1, g = 1, b = 1, a = 0.01},
  stripedAlt = {r = 1, g = 1, b = 1, a = 0.02},
  -- Interactive elements
  closeButton = {r = 1, g = 0, b = 0, a = 0.2},
  closeButtonHover = {r = 1, g = 0, b = 0, a = 0.4},
  buttonHover = {r = 1, g = 1, b = 1, a = 0.05},
  -- Transparent
  transparent = {r = 0, g = 0, b = 0, a = 0},
}
Constants.sizes = {
  padding = 8,
  row = 22,
  column = 100,
  border = 4,
  titlebar = {
    height = 30,
  },
  footer = {
    height = 16,
  },
  sidebar = {
    width = 150,
    collapsedWidth = 30,
  },
}
Constants.sortingOptions = {
  {value = "lastUpdate",  text = "Recently played"},
  {value = "name.asc",    text = "Name (A-Z)"},
  {value = "name.desc",   text = "Name (Z-A)"},
  {value = "realm.asc",   text = "Realm (A-Z)"},
  {value = "realm.desc",  text = "Realm (Z-A)"},
  {value = "class.asc",   text = "Class (A-Z)"},
  {value = "class.desc",  text = "Class (Z-A)"},
  {value = "ilvl.asc",    text = "Item Level (Lowest)"},
  {value = "ilvl.desc",   text = "Item Level (Highest)"},
  {value = "rating.asc",  text = "Rating (Lowest)"},
  {value = "rating.desc", text = "Rating (Highest)"},
  {value = "custom",      text = "Custom Order",        tooltipTitle = "Choose your own order", tooltipText = "Place your mouse on the character name to change the order"},
}

---@enum AE_PreyHuntDifficultyId
Constants.preyHuntDifficulty = {
  Normal = 1,
  Hard = 2,
  Nightmare = 3,
}
