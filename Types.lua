-- =============================================================
-- Types: Data Model - Inventory
-- =============================================================
---@class AE_Inventory
---@field id number
---@field name string

-- =============================================================
-- Types: Core / Addon
-- =============================================================
---@class AE_Addon

---@class AE_WindowManager

-- =============================================================
-- Types: Data Model - Raids / Dungeons
-- =============================================================
---@class AE_Raid
---@field seasonID number
---@field seasonDisplayID number
---@field journalInstanceID number
---@field instanceID number
---@field order number
-- ---@field numEncounters number
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

---@class AE_VaultType
---@field id Enum.WeeklyRewardChestThresholdType
---@field name string

---@class AE_WeeklyRewardActivityEncounterInfo : WeeklyRewardActivityEncounterInfo
---@field type Enum.WeeklyRewardChestThresholdType
---@field index number

---@class AE_CharacterVault: WeeklyRewardActivityInfo
---@field exampleRewardLink string
---@field exampleRewardUpgradeLink string

---@alias AE_CurrencyType "crest" | "upgrade" | "catalyst" | "item" | "dinar" | "delve" | "spark" | "cloak"

---@class AE_Currency
---@field id number
---@field seasonID number
---@field seasonDisplayID number
---@field useTotalEarnedForMaxQty boolean
---@field currencyType AE_CurrencyType

---@class AE_CharacterCurrency : CurrencyInfo
---@field id number
---@field currencyType AE_CurrencyType

---@class AE_CharacterInfo
---@field name string
---@field realm string
---@field level number
---@field race {name: string, file: string, id: number}
---@field class {name: string, file: string, id: number}
---@field factionGroup {english: string, localized: string}
---@field ilvl {level: number, equipped: number, pvp: number, color: string}

---@class AE_CharacterAffixScoreInfo : MythicPlusAffixScoreInfo
---@field id number

---@class AE_CharacterDungeon
---@field challengeModeID number
---@field rating number
---@field level number
---@field finishedSuccess boolean
---@field bestTimedRun MapSeasonBestInfo|nil
---@field bestNotTimedRun MapSeasonBestInfo|nil
---@field affixScores AE_CharacterAffixScoreInfo[]
---@field bestOverAllScore number

---@class AE_CharacterMythicPlus
---@field numCompletedDungeonRuns {heroic: number, mythic: number, mythicPlus: number}
---@field rating number
---@field keystone {challengeModeID: number, mapId: number, level: number, color: string, itemId: number, itemLink: string}
---@field weeklyRewardAvailable boolean
---@field bestSeasonScore number
---@field bestSeasonNumber number
---@field runHistory MythicPlusRunInfo[]
---@field dungeons AE_CharacterDungeon[]

-- =============================================================
-- Types: Character & Weekly Rewards
-- =============================================================
---@class AE_Character
---@field GUID WOWGUID
---@field lastUpdate number
---@field currentSeason number
---@field order number
---@field info AE_CharacterInfo
---@field equipment AE_Equipment[]
---@field money number
---@field currencies AE_CharacterCurrency[]
---@field raids { savedInstances: AE_SavedInstance[] }
---@field mythicplus AE_CharacterMythicPlus
---@field vault { hasAVailableRewards: boolean, slots: AE_CharacterVault[], activityEncounterInfo: AE_WeeklyRewardActivityEncounterInfo[]}

---@class AE_CharacterRows
---@field label string
---@field value function
---@field onEnter fun(infoFrame: Frame, character: AE_Character)?
---@field onLeave fun(infoFrame: Frame, character: AE_Character)?
---@field onClick fun(infoFrame: Frame, character: AE_Character)?
---@field backgroundColor ColorType?
---@field enabled boolean

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

---@alias AE_CharacterSortingOption "lastUpdate" | "name.asc" | "name.desc" | "realm.asc" | "realm.desc" | "class.asc" | "class.desc" | "ilvl.asc" | "ilvl.desc" | "rating.asc" | "rating.desc" | "custom"

-- =============================================================
-- Types: Constants & Options
-- =============================================================
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
---@field sizes AE_ConstantsSizes
---@field sortingOptions AE_ConstantsCharacterSortingOption[]

-- =============================================================
-- Types: SavedVariables (DB Schema)
-- =============================================================
---@class AE_Global
---@field weeklyReset number
---@field characters AE_Character[]
---@field minimap { minimapPos: number, hide: boolean, lock: boolean }
---@field sorting AE_CharacterSortingOption
---@field showTiers boolean
---@field showAffixColors boolean
---@field showAffixHeader boolean
---@field showZeroRatedCharacters boolean
---@field showRealms boolean
---@field announceKeystones { autoParty: boolean, autoGuild: boolean, multiline: boolean, multilineNames: boolean}
---@field announceResets boolean
---@field raids { enabled: boolean, colors: boolean, currentTierOnly: boolean, hiddenDifficulties: table<number, boolean>, boxes: boolean, modifiedInstanceOnly: boolean }
---@field interface { windowScale: number, windowColor: ColorType}
---@field useRIOScoreColor boolean

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
---@field itemUpgradeColor string|nil
---@field itemSlotID number
---@field itemSlotName string

-- =============================================================
-- UI: Window
-- =============================================================
---@class AE_WindowOptions
---@field parent any?
---@field name string?
---@field title string?
---@field sidebar number?
---@field titlebar boolean?
---@field border number?
---@field windowScale number?
---@field windowColor table?
---@field point any[]?  -- e.g., {"CENTER"} or {"TOP", UIParent, "TOP", 0, -15}
---@field titlebarButtons AE_TitlebarButton[]? Array of buttons to add to the titlebar

---@class AE_Window : Frame
---@field config AE_WindowOptions
---@field titlebar Frame?
---@field body Frame?
---@field sidebar Frame?
---@field border Frame?
---@field titlebarButtons table<string, Frame> Table of created titlebar buttons
---@field Toggle fun(self: AE_Window, state?: boolean)
---@field SetTitle fun(self: AE_Window, title: string)
---@field SetBodySize fun(self: AE_Window, width: number, height: number)
---@field AddTitlebarButton fun(self: AE_Window, buttonConfig: AE_TitlebarButton): Frame
---@field RemoveTitlebarButton fun(self: AE_Window, buttonName: string)
---@field GetTitlebarButton fun(self: AE_Window, buttonName: string): Frame?

-- =============================================================
-- UI: Table (Data + Config)
-- =============================================================
---@class AE_TableData
---@field columns AE_TableDataColumn[]?
---@field rows AE_TableDataRow[]

---@class AE_TableConfigHeader
---@field enabled boolean?
---@field sticky boolean?
---@field height number?

---@class AE_TableConfigRows
---@field height number?
---@field highlight boolean?
---@field striped boolean?

---@class AE_TableConfigColumns
---@field width number?
---@field highlight boolean?
---@field striped boolean?

---@class AE_TableConfigCells
---@field padding number?
---@field highlight boolean?

---@class AE_TableConfig
---@field header AE_TableConfigHeader?
---@field rows AE_TableConfigRows?
---@field columns AE_TableConfigColumns?
---@field cells AE_TableConfigCells?
---@field data AE_TableData?

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

---@class AE_TableFrame : Frame

-- =============================================================
-- UI: Common Controls
-- =============================================================
---@class AE_TitlebarButton
---@field name string The unique name for the button
---@field icon string The icon texture path
---@field tooltipTitle string The tooltip title
---@field tooltipDescription string The tooltip description
---@field onClick function? The click handler function
---@field size number? The button size (defaults to titlebar height)
---@field iconSize number? The icon size (defaults to 12)
---@field enabled boolean? Whether the button is enabled (defaults to true)
---@field setupMenu function? Optional menu setup function for dropdown buttons

---@class AE_ScrollFrameConfig
---@field name string?
---@field scrollSpeedHorizontal number?
---@field scrollSpeedVertical number?
