---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

---@class AE_Constants
addon.Constants = {
  prefix = format("<%s> ", addonName),
  media = {
    WhiteSquare = "Interface/BUTTONS/WHITE8X8",
    Logo = format("Interface/AddOns/%s/Media/Logo.blp", addonName),
    LogoTransparent = format("Interface/AddOns/%s/Media/LogoTransparent.blp", addonName),
    IconClose = format("Interface/AddOns/%s/Media/Icon_Close.blp", addonName),
    IconSettings = format("Interface/AddOns/%s/Media/Icon_Settings.blp", addonName),
    IconSorting = format("Interface/AddOns/%s/Media/Icon_Sorting.blp", addonName),
    IconCharacters = format("Interface/AddOns/%s/Media/Icon_Characters.blp", addonName),
    IconAnnounce = format("Interface/AddOns/%s/Media/Icon_Announce.blp", addonName),
    IconKeyhole = format("Interface/AddOns/%s/Media/Icon_Keyhole.blp", addonName),
    IconProfiles = format("Interface/AddOns/%s/Media/Icon_Profiles.blp", addonName),
  },
  colors = {
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
  },
  sizes = {
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
  },
  sortingOptions = {
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
  },
  -- Currency and UI constants
  currencies = {
    ETHEREAL_STRANDS = 3278,
  },
  traitUI = {
    RESHII_WRAPS_SYSTEM_ID = 29,
    RESHII_WRAPS_TREE_ID = 1115,
  },
}
