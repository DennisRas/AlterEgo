---@class AE_Addon
local addon = select(2, ...)

---@class AE_Data
local Data = addon.Data

---@type AE_VaultType[]
Data.vaultTypes = {
  {id = Enum.WeeklyRewardChestThresholdType.Raid,       name = RAIDS},
  {id = Enum.WeeklyRewardChestThresholdType.Activities, name = DUNGEONS},
  {id = Enum.WeeklyRewardChestThresholdType.World,      name = WORLD},
}

---@type table<number, table<number, number>>
Data.mythicPlusVaultItemLevels = {
  [17] = {
    [2] = 259,
    [3] = 259,
    [4] = 263,
    [5] = 263,
    [6] = 266,
    [7] = 269,
    [8] = 269,
    [9] = 269,
    [10] = 272,
  },
  [18] = {
    [2] = 305,
    [3] = 305,
    [4] = 308,
    [5] = 308,
    [6] = 311,
    [7] = 315,
    [8] = 315,
    [9] = 315,
    [10] = 318,
  },
}
