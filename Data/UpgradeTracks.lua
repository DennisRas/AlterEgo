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
      {name = "Crafted",    bonusIDs = {9401, 9402, 9403, 9404, 9405, 9623, 9624, 9625, 9626, 9627}},
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
      {name = "Crafted",    bonusIDs = {9401, 9402, 9403, 9404, 9405, 9623, 9624, 9625, 9626, 9627}},
    },
  },
}
