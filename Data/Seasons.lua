---@class AE_Addon
local addon = select(2, ...)

---@class AE_Data
local Data = addon.Data

---@type AE_Season[]
Data.seasons = {
  {seasonID = 17, seasonDisplayID = 1, expansionID = Enum.ExpansionLevel.Midnight, name = "Midnight - Season 1", description = "The Voidspire, March on Quel'Danas, The Dreamrift, Sporefall"},
  {seasonID = 18, seasonDisplayID = 2, expansionID = Enum.ExpansionLevel.Midnight, name = "Midnight - Season 2", description = "The Tidebound Grotto, The Venomous Abyss"},
}
