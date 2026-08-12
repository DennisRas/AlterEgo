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
