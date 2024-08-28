---@class Affix
---@field id number
---@field base 0 | 1
---@field name string
---@field description string
---@field fileDataID number|nil

---@class AffixRotation
---@field seasonID number
---@field seasonDisplayID number
---@field activation number[]
---@field affixes table<number, number[]>

---@class Currency
---@field id number
---@field seasonID number
---@field seasonDisplayID number
---@field currencyType "crest" | "upgrade" | "catalyst" | "item" | "dinar" | "delve"

---@class Dungeon
---@field seasonID number
---@field seasonDisplayID number
---@field challengeModeID number
---@field mapId number
---@field spellID number
---@field time number
---@field abbr string
---@field name string
---@field short string?

---@class Inventory
---@field id number
---@field name string

---@class Keystone
---@field seasonID number
---@field seasonDisplayID number
---@field itemID number

---@class Raid
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

---@class RaidDifficulty
---@field id number
---@field color table
---@field order number
---@field abbr string
---@field name string
---@field short string?
