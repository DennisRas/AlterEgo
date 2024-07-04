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

---@class AE_Currency
---@field id number
---@field seasonID number
---@field seasonDisplayID number
---@field currencyType "crest" | "upgrade" | "catalyst" | "item" | "dinar"

---@class AE_Dungeon
---@field seasonID number
---@field seasonDisplayID number
---@field challengeModeID number
---@field mapId number
---@field spellID number
---@field time number
---@field abbr string
---@field name string
---@field short string?

---@class AE_Inventory
---@field id number
---@field name string

---@class AE_Keystone
---@field seasonID number
---@field seasonDisplayID number
---@field itemID number

---@class AE_Raid
---@field seasonID number
---@field seasonDisplayID number
---@field journalInstanceID number
---@field instanceID number
---@field order number
---@field numEncounters number
---@field encounters table
---@field modifiedInstanceInfo table|nil
---@field abbr string
---@field name string
---@field short string?

---@class AE_RaidDifficulty
---@field id number
---@field color table
---@field order number
---@field abbr string
---@field name string
---@field short string?
