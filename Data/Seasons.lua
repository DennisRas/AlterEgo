---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

---@class AE_Data
local Data = addon.Data

---@type AE_Season[]
Data.seasons = {
  {seasonID = 9,  seasonDisplayID = 1, expansionID = Enum.ExpansionLevel.Dragonflight, name = "Dragonflight - Season 1",   description = "Vault of the Incarnates"},
  {seasonID = 10, seasonDisplayID = 2, expansionID = Enum.ExpansionLevel.Dragonflight, name = "Dragonflight - Season 2",   description = "Aberrus, the Shadowed Crucible"},
  {seasonID = 11, seasonDisplayID = 3, expansionID = Enum.ExpansionLevel.Dragonflight, name = "Dragonflight - Season 3",   description = "Amirdrassil, the Dream's Hope"},
  {seasonID = 12, seasonDisplayID = 4, expansionID = Enum.ExpansionLevel.Dragonflight, name = "Dragonflight - Season 4",   description = "Aberrus, the Shadowed Crucible"},
  {seasonID = 13, seasonDisplayID = 1, expansionID = Enum.ExpansionLevel.WarWithin,    name = "The War Within - Season 1", description = "Nerub-ar Palace"},
  {seasonID = 14, seasonDisplayID = 2, expansionID = Enum.ExpansionLevel.WarWithin,    name = "The War Within - Season 2", description = "Liberation of Undermine"},
  {seasonID = 15, seasonDisplayID = 3, expansionID = Enum.ExpansionLevel.WarWithin,    name = "The War Within - Season 3", description = "Manaforge Omega"},
  {seasonID = 16, seasonDisplayID = 4, expansionID = Enum.ExpansionLevel.WarWithin,    name = "The War Within - Season 4", description = "[Unused]"},
  {seasonID = 17, seasonDisplayID = 1, expansionID = Enum.ExpansionLevel.Midnight,     name = "Midnight - Season 1",       description = "The Voidspire, March on Quel'Danas, The Dreamrift, Sporefall"},
}
