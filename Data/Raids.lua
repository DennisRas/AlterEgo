---@class AE_Addon
local addon = select(2, ...)

---@class AE_Data
local Data = addon.Data

---@type AE_Raid[]
Data.raids = {
  {seasonID = 17, seasonDisplayID = 1, instanceID = 2912, journalInstanceID = 1307, order = 1, numEncounters = 6, encounters = {}, loot = {}, modifiedInstanceInfo = nil, abbr = "VS",  name = "The Voidspire"},
  {seasonID = 17, seasonDisplayID = 1, instanceID = 2913, journalInstanceID = 1308, order = 2, numEncounters = 2, encounters = {}, loot = {}, modifiedInstanceInfo = nil, abbr = "MQD", name = "March on Quel'Danas"},
  {seasonID = 17, seasonDisplayID = 1, instanceID = 2939, journalInstanceID = 1314, order = 3, numEncounters = 1, encounters = {}, loot = {}, modifiedInstanceInfo = nil, abbr = "DR",  name = "The Dreamrift"},
  {seasonID = 17, seasonDisplayID = 1, instanceID = 1592, journalInstanceID = 1305, order = 4, numEncounters = 1, encounters = {}, loot = {}, modifiedInstanceInfo = nil, abbr = "SF",  name = "Sporefall"},
  {seasonID = 18, seasonDisplayID = 2, instanceID = 2987, journalInstanceID = 1317, order = 1, numEncounters = 1, encounters = {}, loot = {}, modifiedInstanceInfo = nil, abbr = "TG",  name = "The Tidebound Grotto"},
  {seasonID = 18, seasonDisplayID = 2, instanceID = 3004, journalInstanceID = 1320, order = 2, numEncounters = 8, encounters = {}, loot = {}, modifiedInstanceInfo = nil, abbr = "VA",  name = "The Venomous Abyss"},
}

---@type AE_RaidDifficulty[]
Data.raidDifficulties = {
  {id = 14, color = RARE_BLUE_COLOR,        order = 2, abbr = "N", name = "Normal"},
  {id = 15, color = EPIC_PURPLE_COLOR,      order = 3, abbr = "H", name = "Heroic"},
  {id = 16, color = LEGENDARY_ORANGE_COLOR, order = 4, abbr = "M", name = "Mythic"},
  {id = 17, color = UNCOMMON_GREEN_COLOR,   order = 1, abbr = "L", name = "Looking For Raid", short = "LFR"},
}
