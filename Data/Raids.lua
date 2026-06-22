---@class AE_Addon
local addon = select(2, ...)

---@class AE_Data
local Data = addon.Data

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
  {seasonID = 15, seasonDisplayID = 3, instanceID = 2810, journalInstanceID = 1302, order = 3, numEncounters = 8, encounters = {}, loot = {}, modifiedInstanceInfo = nil, abbr = "MO",   name = "Manaforge Omega"},
  {seasonID = 17, seasonDisplayID = 1, instanceID = 2912, journalInstanceID = 1307, order = 1, numEncounters = 6, encounters = {}, loot = {}, modifiedInstanceInfo = nil, abbr = "VS",   name = "The Voidspire"},
  {seasonID = 17, seasonDisplayID = 1, instanceID = 2913, journalInstanceID = 1308, order = 2, numEncounters = 2, encounters = {}, loot = {}, modifiedInstanceInfo = nil, abbr = "MQD",  name = "March on Quel'Danas"},
  {seasonID = 17, seasonDisplayID = 1, instanceID = 2939, journalInstanceID = 1314, order = 3, numEncounters = 1, encounters = {}, loot = {}, modifiedInstanceInfo = nil, abbr = "DR",   name = "The Dreamrift"},
  {seasonID = 17, seasonDisplayID = 1, instanceID = 1592, journalInstanceID = 1305, order = 4, numEncounters = 1, encounters = {}, loot = {}, modifiedInstanceInfo = nil, abbr = "SF",   name = "Sporefall"},
}
