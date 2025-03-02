---@class AE_Inventory
---@field id number
---@field name string

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

---@alias AE_CurrencyType "crest" | "upgrade" | "catalyst" | "item" | "dinar" | "delve"

---@class AE_Currency
---@field id number
---@field seasonID number
---@field seasonDisplayID number
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

---@alias AE_RH_State "RUNNING" | "TIMED" | "OVERTIME" | "ABANDONED"

---@class AE_RH_Run
---@field id string
---@field seasonID number
---@field startTimestamp number
---@field endTimestamp number?
---@field updateTimestamp number
---@field state AE_RH_State
---@field affixes number[]
---@field members AE_RH_Member[]
---@field events AE_RH_Event[]
---@field loot AE_RH_Loot[]
---@field challengeModeTimers number[]
---@field challengeModeID nil
---@field challengeModeLevel nil
---@field challengeModeTime nil
---@field challengeModeOnTime nil
---@field challengeModeKeystoneUpgradeLevels nil
---@field challengeModePracticeRun nil
---@field challengeModeOldOverallDungeonScore nil
---@field challengeModeNewOverallDungeonScore nil
---@field challengeModeIsMapRecord nil
---@field challengeModeIsAffixRecord nil
---@field challengeModePrimaryAffix nil
---@field challengeModeisEligibleForScore nil
---@field challengeModeUpgradeMembers nil
---@field instanceName string?
---@field instanceType string?
---@field instanceDifficultyID number?
---@field instanceDifficultyName string?
---@field instanceMaxPlayers number?
---@field instanceDynamicDifficulty number?
---@field instanceIsDynamic boolean?
---@field instanceID number?
---@field instanceGroupSize number?
---@field instanceLFGDungeonID number?
---@field mapID number?
---@field mapName string?
---@field mapTimeLimit number?
---@field mapTexture number?
---@field mapBackgroundTexture number?
---@field stepCount number?
---@field deathCount number?
---@field deathTimeLost number?
---@field keystoneTimerID number?
---@field keystoneTimerElapsedTime number?
---@field keystoneTimerIsActive boolean?
---@field bosses table
---@field trashCount number?
-----@field isChallengeModeActive boolean
-----@field activeKeystoneLevel number
-----@field activeKeystoneAffixIDs number[]
-----@field activeChallengeModeID number?

---@alias AE_RH_EventType "PLAYER_DEATH" | "ENCOUNTER_START" | "ENCOUNTER_KILL" | "ENCOUNTER_WIPE"

---@class AE_RH_Event
---@field timestamp number
---@field type AE_RH_EventType
---@field data table?

---@class AE_RH_Loot
---@field member WOWGUID
---@field itemName string
---@field itemLink string

---@class AE_RH_Member
---@field guid WOWGUID
---@field name string
---@field realm string
---@field role "TANK" | "HEALER" | "DAMAGER" | "NONE"
---@field classID integer
---@field specID integer?
---@field ratingStart number?
---@field ratingEnd number?
---@field ilvl number?
---@field equipment table?
---@field talents table?
