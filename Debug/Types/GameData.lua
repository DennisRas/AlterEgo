---@alias AE_CurrencyType "crest" | "upgrade" | "catalyst" | "item" | "dinar" | "delve" | "delveMap" | "spark" | "cloak" | "bonusroll"

---@class AE_VaultType
---@field id Enum.WeeklyRewardChestThresholdType
---@field name string

---@class AE_WeeklyRewardActivityEncounterInfo : WeeklyRewardActivityEncounterInfo
---@field type Enum.WeeklyRewardChestThresholdType
---@field index number

---@class AE_Currency
---@field id number
---@field seasonID number
---@field seasonDisplayID number
---@field useTotalEarnedForMaxQty boolean
---@field currencyType AE_CurrencyType
---@field name string?
---@field questID number?
---@field spellID number?
---@field tooltipNote string|nil

---@class AE_CurrencyInfo
---@field id number
---@field name string
---@field description string?
---@field iconFileID number?
---@field quality Enum.ItemQuality|number?
---@field currencyType AE_CurrencyType
---@field useTotalEarnedForMaxQty boolean?
---@field tooltipNote string|nil
---@field maxQuantity number?
---@field maxWeeklyQuantity number?
---@field quantity number?
---@field totalEarned number?
---@field quantityEarnedThisWeek number?
---@field short string?

---@class AE_Affix
---@field id number
---@field base 0 | 1
---@field name string
---@field description string
---@field fileDataID number|nil

---@class AE_AffixRotation
---@field seasonID number
---@field seasonDisplayID number
---@field activation number[]
---@field affixes table<number, number[]>

---@class AE_Keystone
---@field seasonID number
---@field seasonDisplayID number
---@field itemID number

---@class AE_SavedInstance
---@field index number
---@field id number
---@field name string
---@field lockoutId number
---@field reset number
---@field difficultyID number
---@field locked boolean
---@field extended boolean
---@field instanceIDMostSig number
---@field isRaid boolean
---@field maxPlayers number
---@field difficultyName string
---@field numEncounters number
---@field encounterProgress number
---@field extendDisabled boolean
---@field instanceID number
---@field link string|nil
---@field expires number
---@field encounters AE_SavedInstanceEncounter[]

---@class AE_SavedInstanceEncounter
---@field index number
---@field instanceEncounterID number
---@field bossName string
---@field fileDataID number|nil
---@field isKilled boolean

---@class AE_PreyAffix
---@field id number
---@field name string
---@field description string

---@class AE_PreyDifficulty
---@field seasonID number
---@field seasonDisplayID number
---@field id number
---@field name string
---@field affixes number[]

---@class AE_PreyQuest
---@field questID number
---@field difficultyID number
---@field name string
