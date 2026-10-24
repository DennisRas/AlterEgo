---@class AE_MainAffixBar : Frame
---@field buttons Button[]

---@class AE_MainCharacterColumn : Frame
---@field infoFrames AE_MainCharacterInfoButton[]
---@field dungeonFrames AE_MainDungeonCell[]
---@field raidFrames Frame[]
---@field affixHeaderFrame Frame
---@field preyHeader Frame
---@field raidHeader Frame
---@field currencyHeaderFrame Frame
---@field currentCharacterOverlay AE_MainCharacterOverlay?
---@field preyProgress AE_MainTextFrame[]?
---@field difficultyFrames AE_MainRaidDifficultyRow[]?
---@field currencyFrames AE_MainCurrencyCell[]?

---@class AE_MainCharacterInfoButton : Button
---@field text FontString
---@field SortLeftButton AE_MainSortButton
---@field SortRightButton AE_MainSortButton

---@class AE_MainCharacterOverlay : Frame
---@field background Texture
---@field left Texture
---@field right Texture

---@class AE_MainContent : Frame
---@field scrollArea LiqUI_ScrollArea

---@class AE_MainCurrencyCell : Frame
---@field Text FontString

---@class AE_MainCurrencyLabel : Frame
---@field icon Texture
---@field text FontString

---@class AE_MainDungeonButton : Button
---@field icon Texture
---@field text FontString

---@class AE_MainDungeonCell : Frame
---@field Text FontString
---@field Tier FontString
---@field Score FontString

---@class AE_MainEncounterIcon : Frame
---@field Background Texture

---@class AE_MainLabelFrame : Frame
---@field text FontString

---@class AE_MainRaidDifficultyRow : Frame
---@field iconFrames AE_MainEncounterIcon[]

---@class AE_MainSidebar : Frame
---@field infoFrames AE_MainLabelFrame[]?
---@field preyLabel AE_MainLabelFrame?
---@field preyDifficulties AE_MainLabelFrame[]?
---@field mpluslabel AE_MainLabelFrame?
---@field mpluslabels AE_MainDungeonButton[]?
---@field raidHeader AE_MainLabelFrame?
---@field raidDifficulties AE_MainLabelFrame[]?
---@field currencyLabel AE_MainLabelFrame?
---@field currencyLabels AE_MainCurrencyLabel[]?

---@class AE_MainSortButton : Button
---@field Icon Texture

---@class AE_MainTextFrame : Frame
---@field Text FontString

---@class AE_MainWindow : LiqUI_WindowInstance
---@field body AE_MainWindowBody
---@field affixes AE_MainAffixBar
---@field characterFrames AE_MainCharacterColumn[]?

---@class AE_MainWindowBody : LiqUI_WindowBody
---@field sidebar AE_MainSidebar
---@field content AE_MainContent
