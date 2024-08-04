---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

---@class AE_Constants
local Constants = {
  prefix = format("<%s> ", addonName),
  colors = {
    primary = CreateColor(0.596, 0.796, 0.847),
    titlebar = CreateColor(0.0549, 0.0706, 0.0824),
    sidebar = CreateColor(0.0784, 0.0980, 0.1137),
  },
  media = {
    WhiteSquare = "Interface/BUTTONS/WHITE8X8",
    Logo = format("Interface/AddOns/%s/Media/Logo.blp", addonName),
    LogoTransparent = format("Interface/AddOns/%s/Media/LogoTransparent.blp", addonName),
    IconClose = format("Interface/AddOns/%s/Media/Icon_Close.blp", addonName),
    IconSettings = format("Interface/AddOns/%s/Media/Icon_Settings.blp", addonName),
    IconSorting = format("Interface/AddOns/%s/Media/Icon_Sorting.blp", addonName),
    IconCharacters = format("Interface/AddOns/%s/Media/Icon_Characters.blp", addonName),
    IconAnnounce = format("Interface/AddOns/%s/Media/Icon_Announce.blp", addonName),
    IconCheckmark = format("Interface/AddOns/%s/Media/Icon_Checkmark.blp", addonName),
    IconCaretDown = format("Interface/AddOns/%s/Media/Icon_CaretDown.blp", addonName),
    ProgressBarCircle = format("Interface/AddOns/%s/Media/ProgressBarCircle.blp", addonName),
  },
  sizes = {
    padding = 8,
    row = 22,
    column = 120,
    border = 4,
    titlebar = {
      height = 30
    },
    footer = {
      height = 16
    },
    sidebar = {
      width = 150,
      collapsedWidth = 30
    }
  },
  sortingOptions = {
    {value = "lastUpdate",  text = "Recently played"},
    {value = "name.asc",    text = "Name (A-Z)"},
    {value = "name.desc",   text = "Name (Z-A)"},
    {value = "realm.asc",   text = "Realm (A-Z)"},
    {value = "realm.desc",  text = "Realm (Z-A)"},
    {value = "rating.asc",  text = "Rating (Lowest)"},
    {value = "rating.desc", text = "Rating (Highest)"},
    {value = "ilvl.asc",    text = "Item Level (Lowest)"},
    {value = "ilvl.desc",   text = "Item Level (Highest)"},
    {value = "class.asc",   text = "Class (A-Z)"},
    {value = "class.desc",  text = "Class (Z-A)"},
  }
}
addon.Constants = Constants
