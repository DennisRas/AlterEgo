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
-- Types: Data Model - Character Info
-- =============================================================
---@class AE_CharacterInfoRace
---@field name string
---@field file string
---@field id number

---@class AE_CharacterInfoClass
---@field name string
---@field file string
---@field id number

---@class AE_CharacterInfoFactionGroup
---@field english string
---@field localized string

---@class AE_CharacterInfoIlvl
---@field level number
---@field equipped number
---@field pvp number
---@field color string

---@class AE_CharacterInfo
---@field name string
---@field realm string
---@field level number
---@field race AE_CharacterInfoRace
---@field class AE_CharacterInfoClass
---@field factionGroup AE_CharacterInfoFactionGroup
---@field ilvl AE_CharacterInfoIlvl

-- =============================================================
-- Types: Data Model - Character Mythic Plus
-- =============================================================
---@class AE_CharacterMythicPlusNumCompletedDungeonRuns
---@field heroic number
---@field mythic number
---@field mythicPlus number

---@class AE_CharacterMythicPlusKeystone
---@field challengeModeID number
---@field mapId number
---@field level number
---@field color string
---@field itemId number
---@field itemLink string

---@class AE_CharacterMythicPlus
---@field numCompletedDungeonRuns AE_CharacterMythicPlusNumCompletedDungeonRuns
---@field rating number
---@field keystone AE_CharacterMythicPlusKeystone
---@field weeklyRewardAvailable boolean
---@field bestSeasonScore number
---@field bestSeasonNumber number
---@field runHistory MythicPlusRunInfo[]
---@field dungeons AE_CharacterDungeon[]

-- =============================================================
-- Types: Data Model - Character Raids
-- =============================================================
---@class AE_CharacterRaids
---@field savedInstances AE_SavedInstance[]

-- =============================================================
-- Types: Data Model - Character Vault
-- =============================================================
---@class AE_CharacterVault
---@field hasAvailableRewards boolean
---@field slots AE_CharacterVaultSlot[]
---@field activityEncounterInfo AE_WeeklyRewardActivityEncounterInfo[]

---@class AE_CharacterVaultSlot : WeeklyRewardActivityInfo
---@field exampleRewardLink string
---@field exampleRewardUpgradeLink string

-- =============================================================
-- Types: Data Model - Character
-- =============================================================
---@class AE_Character
---@field GUID WOWGUID
---@field lastUpdate number
---@field currentSeason number
---@field enabled boolean
---@field order number
---@field info AE_CharacterInfo
---@field equipment AE_Equipment[]
---@field money number
---@field currencies AE_CharacterCurrency[]
---@field raids AE_CharacterRaids
---@field mythicplus AE_CharacterMythicPlus
---@field vault AE_CharacterVault

-- =============================================================
-- Types: Data Model - Raids / Dungeons
-- =============================================================
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

---@class AE_VaultType
---@field id Enum.WeeklyRewardChestThresholdType
---@field name string

---@class AE_WeeklyRewardActivityEncounterInfo : WeeklyRewardActivityEncounterInfo
---@field type Enum.WeeklyRewardChestThresholdType
---@field index number

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
---@class AE_ConstantsSizesTitlebar
---@field height number

---@class AE_ConstantsSizesFooter
---@field height number

---@class AE_ConstantsSizesSidebar
---@field width number
---@field collapsedWidth number

---@class AE_ConstantsSizes
---@field padding number
---@field row number
---@field column number
---@field border number
---@field titlebar AE_ConstantsSizesTitlebar
---@field footer AE_ConstantsSizesFooter
---@field sidebar AE_ConstantsSizesSidebar

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


---@class AE_GlobalAnnounceKeystones
---@field autoParty boolean
---@field autoGuild boolean
---@field multiline boolean
---@field multilineNames boolean

---@class AE_GlobalVault
---@field raids boolean
---@field dungeons boolean
---@field world boolean

---@class AE_GlobalRaids
---@field enabled boolean
---@field colors boolean
---@field currentTierOnly boolean
---@field hiddenDifficulties table<number, boolean>
---@field boxes boolean
---@field modifiedInstanceOnly boolean

---@class AE_GlobalDungeons
---@field enabled boolean

---@class AE_GlobalWorld
---@field enabled boolean

---@class AE_GlobalCurrencies
---@field enabled boolean
---@field hiddenCurrencies table<number, boolean>
---@field showIcons boolean
---@field showMaxEarned boolean
---@field alignCenter boolean

---@class AE_GlobalInterface
---@field windowScale number
---@field windowColor ColorType

---@class AE_Global
---@field weeklyReset number
---@field characters AE_Character[]
---@field minimap LibDBIcon.button.DB
---@field sorting AE_CharacterSortingOption
---@field showTiers boolean
---@field showScores boolean
---@field showAffixColors boolean
---@field showAffixHeader boolean
---@field showZeroRatedCharacters boolean
---@field showRealms boolean
---@field announceKeystones AE_GlobalAnnounceKeystones
---@field announceResets boolean
---@field vault AE_GlobalVault
---@field raids AE_GlobalRaids
---@field dungeons AE_GlobalDungeons
---@field world AE_GlobalWorld
---@field currencies AE_GlobalCurrencies
---@field interface AE_GlobalInterface
---@field useRIOScoreColor boolean

-- =============================================================
-- Types: Input Components
-- =============================================================

---@class AE_InputOptionsBase
---@field parent Frame?
---@field onEnter function?
---@field onLeave function?
---@field width number
---@field height number

---@class AE_InputOptionsButton : AE_InputOptionsBase
---@field onClick function?
---@field text string

---@class AE_InputOptionsTextbox : AE_InputOptionsBase
---@field onChange function?
---@field placeholder string?

---@class AE_InputOptionsCheckbox : AE_InputOptionsBase
---@field onChange function?
---@field checked boolean
---@field text string

---@class AE_InputOptionsDropdownItem
---@field value string
---@field text string
---@field icon string?

---@class AE_InputOptionsDropdown : AE_InputOptionsBase
---@field onChange function?
---@field items AE_InputOptionsDropdownItem[]
---@field value string?
---@field maxHeight number
---@field size number
---@field sizeIcon number
---@field placeholder string

---@class AE_InputOptionsStatusBar : AE_InputOptionsBase
---@field text string?
---@field value number?
---@field maxValue number?
---@field progressColor table<string, number>?

-- =============================================================
-- Types: Input Components (Custom AE Types)
-- =============================================================

---@class AE_Button : Button
---@field config AE_InputOptionsButton
---@field hover boolean
---@field text FontString
---@field onClickHandler fun(self: AE_Button)
---@field onEnterHandler fun(self: AE_Button)
---@field onLeaveHandler fun(self: AE_Button)
---@field Update fun(self: AE_Button)
---@field updateCommon fun(self: AE_Button)
---@field IsEnabled fun(self: AE_Button): boolean

---@class AE_Textbox : EditBox
---@field config AE_InputOptionsTextbox
---@field hover boolean
---@field border Frame
---@field text FontString
---@field OnChange fun(self: AE_Textbox)
---@field Update fun(self: AE_Textbox)
---@field updateCommon fun(self: AE_Textbox)
---@field IsEnabled fun(self: AE_Textbox): boolean

---@class AE_Checkbox : Button
---@field config AE_InputOptionsCheckbox
---@field hover boolean
---@field checked boolean
---@field checkbox Button
---@field text FontString
---@field onClickHandler fun(self: AE_Checkbox)
---@field onEnterHandler fun(self: AE_Checkbox)
---@field onLeaveHandler fun(self: AE_Checkbox)
---@field Update fun(self: AE_Checkbox)
---@field updateCommon fun(self: AE_Checkbox)
---@field IsEnabled fun(self: AE_Checkbox): boolean

---@class AE_Dropdown : Frame
---@field config AE_InputOptionsDropdown
---@field hover boolean
---@field items AE_InputOptionsDropdownItem[]
---@field value string
---@field expanded boolean
---@field button Frame
---@field list Frame
---@field border Frame
---@field SetItems fun(self: AE_Dropdown, items: AE_InputOptionsDropdownItem[])
---@field AddItem fun(self: AE_Dropdown, item: AE_InputOptionsDropdownItem)
---@field RemoveItem fun(self: AE_Dropdown, item: AE_InputOptionsDropdownItem)
---@field SetValue fun(self: AE_Dropdown, value: string)
---@field GetValue fun(self: AE_Dropdown): string
---@field SetExpanded fun(self: AE_Dropdown, state: boolean)
---@field ClearItems fun(self: AE_Dropdown)
---@field Update fun(self: AE_Dropdown)
---@field UpdateList fun(self: AE_Dropdown)
---@field onClickHandler fun(self: AE_Dropdown)
---@field onEnterHandler fun(self: AE_Dropdown)
---@field onLeaveHandler fun(self: AE_Dropdown)
---@field updateCommon fun(self: AE_Dropdown)
---@field IsEnabled fun(self: AE_Dropdown): boolean

---@class AE_StatusBar : Frame
---@field config AE_InputOptionsStatusBar
---@field hover boolean
---@field value number
---@field maxValue number
---@field progressColor table<string, number>
---@field background Frame
---@field border Frame
---@field progress Frame
---@field text FontString
---@field SetText fun(self: AE_StatusBar, text: string)
---@field SetValue fun(self: AE_StatusBar, value: number)
---@field SetMaxValue fun(self: AE_StatusBar, maxValue: number)
---@field SetMinMaxValues fun(self: AE_StatusBar, minValue: number, maxValue: number)
---@field GetValue fun(self: AE_StatusBar): number
---@field GetMaxValue fun(self: AE_StatusBar): number
---@field UpdateProgress fun(self: AE_StatusBar)
---@field Update fun(self: AE_StatusBar)
---@field updateCommon fun(self: AE_StatusBar)
---@field IsEnabled fun(self: AE_StatusBar): boolean

---@class AE_Input
---@field Button fun(self: AE_Input, options: AE_InputOptionsButton): AE_Button
---@field Textbox fun(self: AE_Input, options: AE_InputOptionsTextbox): AE_Textbox
---@field CreateCheckbox fun(self: AE_Input, options: AE_InputOptionsCheckbox): AE_Checkbox
---@field CreateDropdown fun(self: AE_Input, options: AE_InputOptionsDropdown): AE_Dropdown
---@field CreateStatusBar fun(self: AE_Input, options: AE_InputOptionsStatusBar): AE_StatusBar

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
---@field width number? Initial body width (will call SetBodySize automatically)
---@field height number? Initial body height (will call SetBodySize automatically)

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
