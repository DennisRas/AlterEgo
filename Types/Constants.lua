---@alias ColorTable { r: number, g: number, b: number, a: number }

---@alias AE_CharacterSortingOption "lastUpdate" | "name.asc" | "name.desc" | "realm.asc" | "realm.desc" | "class.asc" | "class.desc" | "ilvl.asc" | "ilvl.desc" | "rating.asc" | "rating.desc" | "custom"

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
---@field media table<string, string>
---@field colors table<string, ColorTable>
---@field sizes AE_ConstantsSizes
---@field sortingOptions AE_ConstantsCharacterSortingOption[]
