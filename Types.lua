---@class AE_Inventory
---@field id number
---@field name string

---@class AE_Season
---@field seasonID number
---@field seasonDisplayID number
---@field name string
---@field affixes table<number, table<number, number>>
---@field dungeons AE_Dungeon[]
---@field raids AE_Raid[]
---@field currencies AE_Currency[]
---@field keystoneItemID number

---@class AE_Raid
---@field journalInstanceID number
---@field instanceID number
---@field order number
---@field encounters AE_Encounter[]
---@field modifiedInstanceInfo table|nil
---@field abbr string
---@field name string
---@field short string?
---@field loot table
-----@field numEncounters number
-----@field seasonID number
-----@field seasonDisplayID number

---@class AE_RaidDifficulty
---@field id number
---@field color table
---@field order number
---@field abbr string
---@field name string
---@field short string?

---@class AE_CharacterVault: WeeklyRewardActivityInfo
---@field exampleRewardLink string
---@field exampleRewardUpgradeLink string

---@alias AE_CurrencyType "crest" | "upgrade" | "catalyst" | "item" | "dinar" | "delve"

---@class AE_Currency
---@field id number
---@field currencyType AE_CurrencyType
-----@field seasonID number
-----@field seasonDisplayID number

---@class AE_CharacterCurrency : CurrencyInfo
---@field id number
---@field currencyType AE_CurrencyType

---@class AE_Character
---@field GUID WOWGUID
---@field lastUpdate number
---@field currentSeason number
---@field raids { savedInstances: AE_SavedInstance[] }
---@field equipment AE_Equipment[]
---@field currencies AE_CharacterCurrency[]
---@field vault { hasAVailableRewards: boolean, slots: AE_CharacterVault[]}
-- -@field pvp table

---@class AE_CharacterInfo
---@field label string
---@field value function
---@field onEnter fun(infoFrame: Frame, character: AE_Character)?
---@field onLeave fun(infoFrame: Frame, character: AE_Character)?
---@field onClick fun(infoFrame: Frame, character: AE_Character)?
---@field enabled boolean

---@class AE_Affix
---@field id number
---@field level number
---@field name string
---@field description string
---@field fileDataID number|nil
-----@field base 0 | 1

---@class AE_AffixWeek

---@class AE_AffixRotation
---@field activation number[]
---@field affixes table<number, number[]>
-----@field seasonID number
-----@field seasonDisplayID number

---@class AE_Keystone
---@field itemID number
-----@field seasonID number
-----@field seasonDisplayID number

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
---@field challengeModeID number
---@field journalInstanceID number
---@field mapId number
---@field spellID number
---@field time number
---@field encounters AE_Encounter[]
---@field abbr string
---@field name string
---@field short string?
---@field loot table
-----@field seasonID number
-----@field seasonDisplayID number

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
---@field raids { enabled: boolean, colors: boolean, currentTierOnly: boolean, hiddenDifficulties: table, boxes: boolean, modifiedInstanceOnly: boolean }
---@field interface { windowScale: number, windowColor: {r: number, g: number, b: number, a: number} }
---@field useRIOScoreColor boolean
-- -@field runHistory AE_RH
-- -@field pvp { enabled: boolean }

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

---@class AE_WindowOptions
---@field parent any?
---@field name string?
---@field title string?
---@field sidebar number?
---@field titlebar boolean?
---@field border number?
---@field windowScale number?
---@field windowColor table?

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
