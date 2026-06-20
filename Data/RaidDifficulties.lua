---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

---@class AE_Data
local Data = addon.Data

---@type AE_RaidDifficulty[]
Data.raidDifficulties = {
  {id = 14, color = RARE_BLUE_COLOR,        order = 2, abbr = "N", name = "Normal"},
  {id = 15, color = EPIC_PURPLE_COLOR,      order = 3, abbr = "H", name = "Heroic"},
  {id = 16, color = LEGENDARY_ORANGE_COLOR, order = 4, abbr = "M", name = "Mythic"},
  {id = 17, color = UNCOMMON_GREEN_COLOR,   order = 1, abbr = "L", name = "Looking For Raid", short = "LFR"},
}

---@type AE_VaultType[]
Data.vaultTypes = {
  {id = Enum.WeeklyRewardChestThresholdType.Raid,       name = RAIDS},
  {id = Enum.WeeklyRewardChestThresholdType.Activities, name = DUNGEONS},
  {id = Enum.WeeklyRewardChestThresholdType.World,      name = WORLD},
}
