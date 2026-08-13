---@class AE_Addon
local addon = select(2, ...)

---@class AE_Data
local Data = addon.Data

--- Credit: https://www.raidbots.com/static/data/live/bonuses.json (via Liq Character Sheet)
---@type AE_UpgradeSeason[]
Data.upgradeTracks = {
  {
    seasonID = 17,
    seasonDisplayID = 1,
    tracks = {
      {name = "Adventurer", bonusIDs = {12769, 12770, 12771, 12772, 12773, 12774}},
      {name = "Veteran",    bonusIDs = {12777, 12778, 12779, 12780, 12781, 12782}},
      {name = "Champion",   bonusIDs = {12785, 12786, 12787, 12788, 12789, 12790}},
      {name = "Hero",       bonusIDs = {12793, 12794, 12795, 12796, 12797, 12798}},
      {name = "Myth",       bonusIDs = {12801, 12802, 12803, 12804, 12805, 12806}},
    },
  },
  {
    seasonID = 18,
    seasonDisplayID = 2,
    tracks = {
      {name = "Adventurer", bonusIDs = {12817, 12818, 12819, 12820, 12821, 12822}},
      {name = "Veteran",    bonusIDs = {12825, 12826, 12827, 12828, 12829, 12830}},
      {name = "Champion",   bonusIDs = {12833, 12834, 12835, 12836, 12837, 12838}},
      {name = "Hero",       bonusIDs = {12841, 12842, 12843, 12844, 12845, 12846}},
      {name = "Myth",       bonusIDs = {12849, 12850, 12851, 12852, 12853, 12854}},
    },
  },
}

---@type table<number, AE_UpgradeBonusLabel>
Data.upgradeBonusLabels = {
  [13789] = {name = "Sporefused: Veteran", seasonID = 17},
  [13788] = {name = "Sporefused: Champion", seasonID = 17},
  [13787] = {name = "Sporefused: Hero", seasonID = 17},
  [13786] = {name = "Sporefused: Myth", seasonID = 17},
  [13653] = {name = "Ascendant Voidforged: Hero", seasonID = 17},
  [13654] = {name = "Ascendant Voidforged: Myth", seasonID = 17},
  [13655] = {name = "Ascendant Voidforged", seasonID = 17},
}

---@type table<number, number>
Data.craftedQualityBonusIDs = {
  [9401] = 1,
  [9402] = 2,
  [9403] = 3,
  [9404] = 4,
  [9405] = 5,
  [9623] = 1,
  [9624] = 2,
  [9625] = 3,
  [9626] = 4,
  [9627] = 5,
  [12493] = 1,
  [12494] = 2,
  [12495] = 3,
  [12496] = 4,
  [12497] = 5,
  [12498] = 1,
  [12499] = 2,
  [12500] = 3,
  [12501] = 4,
  [12502] = 5,
}

---@type table<number, number>
Data.craftedSeasonBonusIDs = {
  [13622] = 17,
  [13751] = 18,
}
