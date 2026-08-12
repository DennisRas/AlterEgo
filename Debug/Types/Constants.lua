---@alias AE_CharacterSortingOption "lastUpdate" | "name.asc" | "name.desc" | "realm.asc" | "realm.desc" | "class.asc" | "class.desc" | "ilvl.asc" | "ilvl.desc" | "rating.asc" | "rating.desc" | "custom"

---@alias AE_RaidKillIconId "skull" | "diamond"

---@class AE_RaidKillIcon
---@field id AE_RaidKillIconId
---@field label string
---@field texture string
---@field scale number

---@class AE_ConstantsSizes
---@field padding number
---@field row number
---@field column number
---@field border number
---@field titlebar {height: number}
---@field footer {height: number}
---@field sidebar {width: number, collapsedWidth: number}

---@class AE_ConstantsCharacterSortingOption
---@field value AE_CharacterSortingOption
---@field text string
---@field tooltipTitle string?
---@field tooltipText string?

---@class AE_Constants
---@field prefix string
---@field commands string[]
---@field media table<string, string>
---@field raidKillIcons AE_RaidKillIcon[]
---@field colors table<string, ColorTable>
---@field sizes AE_ConstantsSizes
---@field sortingOptions AE_ConstantsCharacterSortingOption[]
