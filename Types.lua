---@class AE_Character
---@field GUID WOWGUID
---@field lastUpdate number
---@field raids { savedInstances: AE_SavedInstance[] }
---@field equipment AE_Equipment[]
---@field currencies AE_CharacterCurrency[]
---@field pvp table
---@field vault { hasAVailableRewards: boolean, slots: AE_CharacterVault[]}

---TODO: Flatten
---@class AE_Global
---@field weeklyReset number
---@field characters AE_Character[]
---@field minimap { minimapPos: number, hide: boolean, lock: boolean }
---@field sorting string -- TODO: Enum/Alias
---@field showTiers boolean
---@field showAffixColors boolean
---@field showAffixHeader boolean
---@field showZeroRatedCharacters boolean
---@field showRealms boolean
---@field announceKeystones { autoParty: boolean, autoGuild: boolean, multiline: boolean, multilineNames: boolean}
---@field announceResets boolean
---@field pvp { enabled: boolean }
---@field raids { enabled: boolean, colors: boolean, currentTierOnly: boolean, hiddenDifficulties: table, boxes: boolean, modifiedInstanceOnly: boolean }
---@field interface { windowScale: number, windowColor: {r: number, g: number, b: number, a: number} }
---@field useRIOScoreColor boolean
---@field runHistory AE_GlobalRunHistory

---@class AE_GlobalRunHistory
---@field enabled boolean
---@field runs AE_GlobalRunHistoryRun[]

---@class AE_GlobalRunHistoryRun
---@field callengeModeID number
---@field startTimestamp number
---@field affixes number[]
---@field members AE_GlobalRunHistoryRunMember[]
---@field challengeModeTime number
---@field onTime boolean
---@field practiceRun boolean
---@field oldOverallDungeonScore number?
---@field newOverallDungeonScore number
---@field IsMapRecord boolean
---@field IsAffixRecord boolean
---@field PrimaryAffix number
---@field isEligibleForScore boolean
---@field numDeaths number
---@field timeLost number

---@class AE_GlobalRunHistoryRunMember
---@field GUID WOWGUID
---@field role "TANK" | "HEAL" | "DAMAGE"
---@field name string
---@field server string
---@field class string
---@field spec string
---@field score string
---@field ilvl number

---@class AE_Equipment
---@field itemName string
---@field itemLink string
---@field itemQuality Enum.ItemQuality
---@field itemLevel number
---@field itemMinLevel number
---@field itemType string
---@field itemSubType string
---@field itemStackCount number
---@field itemEquipLoc string
---@field itemTexture integer
---@field sellPrice number
---@field classID number
---@field subclassID number
---@field bindType number
---@field expansionID number
---@field setID number?
---@field isCraftingReagent boolean
---@field itemUpgradeTrack string|nil
---@field itemUpgradeLevel number|nil
---@field itemUpgradeMax number|nil
---@field itemSlotID number
---@field itemSlotName string

---@class AE_CharacterVault: WeeklyRewardActivityInfo
---@field exampleRewardLink string
---@field exampleRewardUpgradeLink string

---@class AE_CharacterCurrency : CurrencyInfo
---@field id number
---@field currencyType currencyType

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

---@alias currencyType "crest" | "upgrade" | "catalyst" | "item" | "dinar"

---@class AE_Currency
---@field id number
---@field seasonID number
---@field seasonDisplayID number
---@field currencyType currencyType

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
---@field loot table

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
---@field encounters AE_Encounter[]
---@field modifiedInstanceInfo table|nil
---@field abbr string
---@field name string
---@field short string?
---@field loot table

---@class AE_RaidDifficulty
---@field id number
---@field color table
---@field order number
---@field abbr string
---@field name string
---@field short string?

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

---@class AE_SavedInstance
---@field index number
---@field id number
---@field name string
---@field lockoutId number,
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

---@class AE_WidgetOptionsParagraph
---@field text string?
---@field fontObject string?
---@field height number?

---@class AE_WidgetOptionsLine
---@field height number?
---@field padding number?

---@class AE_WidgetOptionsTitle
---@field text string?
---@field fontObject string?
---@field height number?
---@field underline boolean?

---@class AE_WidgetOptionsDropdown
---@field items table
---@field value string?
---@field onChange function?
---@field text string?
---@field fontObject string?
---@field height number?

---@class AE_WidgetOptionsColorPicker
---@field value ColorMixin?
---@field onChange function?
---@field layout string?
---@field text string?
---@field fontObject string?
---@field height number?

---@class AE_WidgetOptionsCheckbox
---@field checked boolean?
---@field onChange function?
---@field layout string?
---@field text string?
---@field fontObject string?
---@field height number?

---@class AE_InputOptionsCheckbox
---@field parent any?
---@field checked boolean?
---@field onEnter function?
---@field onLeave function?
---@field onClick function?
---@field onChange function?
---@field size number?
---@field sizeIcon number?

---@class AE_InputOptionsDropdown
---@field parent any?
---@field onEnter function?
---@field onLeave function?
---@field onClick function?
---@field onChange function?
---@field items AE_InputOptionsDropdownItem[]
---@field value string?
---@field placeholder string?
---@field maxHeight number?
---@field size number?
---@field sizeIcon number?

---@class AE_InputOptionsDropdownItem
---@field value string
---@field text string?
---@field icon string|number?

---@class AE_InputOptionsColorPicker
---@field parent any?
---@field onEnter function?
---@field onLeave function?
---@field onClick function?
---@field onChange function?
---@field value ColorMixin?
---@field size number?

---@class AE_TableData
---@field columns AE_TableDataColumn[]?
---@field rows AE_TableDataRow[]

---@class AE_TableDataColumn
---@field width number
---@field align string?

---@class AE_TableDataRow
---@field columns AE_TableDataRowColumn[]

---@class AE_TableDataRowColumn
---@field text string?
---@field backgroundColor table?
---@field onEnter function?
---@field onLeave function?
---@field onClick function?

---@class AE_WindowOptions
---@field parent any?
---@field name string?
---@field title string?
---@field sidebar boolean?
---@field titlebar boolean?
---@field border number?
---@field windowScale number?
---@field windowColor table?
