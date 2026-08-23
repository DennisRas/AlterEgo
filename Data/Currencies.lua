---@class AE_Addon
local addon = select(2, ...)

---@class AE_Data
local Data = addon.Data

local DELVERS_BOUNTY_QUEST_ID = 86371

---@type number[]
local DELVERS_BOUNTY_ITEM_IDS = {
  265714,
  233071,
  235628,
}

---@type number[]
local DELVERS_BOUNTY_SPELL_IDS = {
  1254631,
  473218,
}

---@type AE_Currency[]
Data.currencies = {
  {seasonID = 17, seasonDisplayID = 1, id = 3383, useTotalEarnedForMaxQty = true,  currencyType = "crest"},                                                                                                                                           -- Adventurer Dawncrest
  {seasonID = 17, seasonDisplayID = 1, id = 3341, useTotalEarnedForMaxQty = true,  currencyType = "crest"},                                                                                                                                           -- Veteran Dawncrest
  {seasonID = 17, seasonDisplayID = 1, id = 3343, useTotalEarnedForMaxQty = true,  currencyType = "crest"},                                                                                                                                           -- Champion Dawncrest
  {seasonID = 17, seasonDisplayID = 1, id = 3345, useTotalEarnedForMaxQty = true,  currencyType = "crest"},                                                                                                                                           -- Hero Dawncrest
  {seasonID = 17, seasonDisplayID = 1, id = 3347, useTotalEarnedForMaxQty = true,  currencyType = "crest"},                                                                                                                                           -- Myth Dawncrest
  {seasonID = 17, seasonDisplayID = 1, id = 3378, useTotalEarnedForMaxQty = true,  currencyType = "catalyst"},                                                                                                                                        -- Dawnlight Manaflux
  {seasonID = 17, seasonDisplayID = 1, id = 3212, useTotalEarnedForMaxQty = true,  currencyType = "spark",     tooltipNote = "There's a chance you'll have an extra Spark of Radiance from week one."},                                               -- Radiant Spark Dust
  {seasonID = 17, seasonDisplayID = 1, id = 3310, useTotalEarnedForMaxQty = false, currencyType = "delve"},                                                                                                                                           -- Coffer Key Shards
  {seasonID = 17, seasonDisplayID = 1, id = 3028, useTotalEarnedForMaxQty = false, currencyType = "delve"},                                                                                                                                           -- Restored Coffer key
  {seasonID = 17, seasonDisplayID = 1, id = 3356, useTotalEarnedForMaxQty = false, currencyType = "delve"},                                                                                                                                           -- Untainted Mana-Crystals
  {seasonID = 17, seasonDisplayID = 1, id = 265714, useTotalEarnedForMaxQty = false, currencyType = "delveMap", name = "Delver's Bounty", questID = DELVERS_BOUNTY_QUEST_ID, itemIDs = DELVERS_BOUNTY_ITEM_IDS, spellIDs = DELVERS_BOUNTY_SPELL_IDS},
  {seasonID = 17, seasonDisplayID = 1, id = 3418, useTotalEarnedForMaxQty = true,  currencyType = "bonusroll", tooltipNote = "Once this currency is unlocked, you can buy extra Voidcores beyond the maximum from Vaultkeeper Elysa in Silvermoon."}, -- Nebulous Voidcore
  {seasonID = 18, seasonDisplayID = 2, id = 3442, useTotalEarnedForMaxQty = true,  currencyType = "crest"},                                                                                                                                           -- Adventurer Mistcrest
  {seasonID = 18, seasonDisplayID = 2, id = 3443, useTotalEarnedForMaxQty = true,  currencyType = "crest"},                                                                                                                                           -- Veteran Mistcrest
  {seasonID = 18, seasonDisplayID = 2, id = 3444, useTotalEarnedForMaxQty = true,  currencyType = "crest"},                                                                                                                                           -- Champion Mistcrest
  {seasonID = 18, seasonDisplayID = 2, id = 3445, useTotalEarnedForMaxQty = true,  currencyType = "crest"},                                                                                                                                           -- Hero Mistcrest
  {seasonID = 18, seasonDisplayID = 2, id = 3446, useTotalEarnedForMaxQty = true,  currencyType = "crest"},                                                                                                                                           -- Myth Mistcrest
  {seasonID = 18, seasonDisplayID = 2, id = 3465, useTotalEarnedForMaxQty = true,  currencyType = "catalyst"},                                                                                                                                        -- Venomblight Manaflux
  {seasonID = 18, seasonDisplayID = 2, id = 3509, useTotalEarnedForMaxQty = true,  currencyType = "spark"},                                                                                                                                           -- Tidal Spark Dust
  {seasonID = 18, seasonDisplayID = 2, id = 3310, useTotalEarnedForMaxQty = false, currencyType = "delve"},                                                                                                                                           -- Coffer Key Shards
  {seasonID = 18, seasonDisplayID = 2, id = 3028, useTotalEarnedForMaxQty = false, currencyType = "delve"},                                                                                                                                           -- Restored Coffer key
  {seasonID = 18, seasonDisplayID = 2, id = 3356, useTotalEarnedForMaxQty = false, currencyType = "delve"},                                                                                                                                           -- Untainted Mana-Crystals
  {seasonID = 18, seasonDisplayID = 2, id = 265714, useTotalEarnedForMaxQty = false, currencyType = "delveMap", name = "Delver's Bounty", questID = DELVERS_BOUNTY_QUEST_ID, itemIDs = DELVERS_BOUNTY_ITEM_IDS, spellIDs = DELVERS_BOUNTY_SPELL_IDS},
  {seasonID = 18, seasonDisplayID = 2, id = 3513, useTotalEarnedForMaxQty = true,  currencyType = "bonusroll", tooltipNote = "Earned from the Great Vault. The count may be wrong until Season 2 starts and Voidcores are available."},             -- Nebulous Voidcore
}
