---@alias AE_CurrencyType "crest" | "upgrade" | "catalyst" | "item" | "dinar" | "delve" | "spark" | "cloak"

---@class AE_Inventory
---@field id number
---@field name string

---@class AE_Season
---@field seasonID number
---@field seasonDisplayID number
---@field expansionID Enum.ExpansionLevel
---@field name string
---@field description string

---@class AE_Encounter
---@field index number
---@field name string|nil
---@field description string|nil
---@field journalEncounterID number|nil
---@field journalEncounterSectionID number|nil
---@field journalLink string|nil
---@field journalInstanceID number|nil
---@field instanceEncounterID number|nil
---@field instanceID number|nil

---@class AE_Raid
---@field seasonID number
---@field seasonDisplayID number
---@field journalInstanceID number
---@field instanceID number
---@field order number
---@field numEncounters number
---@field encounters AE_Encounter[]
---@field modifiedInstanceInfo table|nil
---@field abbr string
---@field name string
---@field short string?
---@field loot table

---@class AE_RaidDifficulty
---@field id number
---@field color colorRGBA
---@field order number
---@field abbr string
---@field name string
---@field short string?

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

---@class AE_CurrencyInfo : CurrencyInfo
---@field id number
---@field currencyType AE_CurrencyType

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

---@class AE_Dungeon
---@field seasonID number
---@field seasonDisplayID number
---@field challengeModeID number
---@field journalInstanceID number
---@field mapId number
---@field teleports number[]
---@field time number
---@field encounters AE_Encounter[]
---@field abbr string
---@field name string
---@field short string?
---@field loot table

---@class AE_SavedInstanceEncounter
---@field index number
---@field instanceEncounterID number
---@field bossName string
---@field fileDataID number|nil
---@field isKilled boolean

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

---@class AE_PreyHuntDifficulty
---@field id number
---@field name string
---@field affixes table<string, string> Affixes of the difficulty

---@class AE_PreyHuntQuest
---@field questID number
---@field difficultyID number ID of the difficulty
---@field name string Name of the quest

Enum.AE_PreyHuntDifficulty = {
  Normal = 1,
  Hard = 2,
  Nightmare = 3,
}
