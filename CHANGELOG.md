# Changelog

## v1.2.6 - 2025-04-23

### Updated

- Updated the TOC number to support patch 11.1.5

### Fixed

- Fixed an issue with keystones not showing because of the new item quality color accessibility options (requires relogging characters to update)

## v1.2.5 - 2025-04-06

### Fixed

- Corrected a typo: DCF is now properly labeled as DFC
- Fixed an issue where the Weekly Affixes window wasn't displaying the rotation

## v1.2.4 - 2025-03-09

### Added

- Items in the Equipment window will now be greyed out if they are from a previous season (requires relogging on characters to update)

### Fixed

- The One-Armed Bandit now correctly appears as killed in the Raid Progress section

## v1.2.3 - 2025-02-26

### Added

- Added addon category for the new AddOn List. Credit: Warcraft Wiki

### Updated

- Updated the TOC number to support patch 11.1

## v1.2.2 - 2025-02-23

### Added

- Added Season 2 data, including Raids, Dungeons, Affixes, and Currencies
- Added a new window background color setting that allows you to make the window transparent

### Updated

- Optimized performance by removing outdated and unused code
- Updated code for detecting the weekly affix rotation
- Adjusted dungeon timers for season 2 - No longer adds 90 seconds at level 7+
- Rearranged some settings and updated tooltip instructions
- Upgraded all dropdown menus (Settings, Sorting, etc.) to the new TWW layout

### Fixed

- Resolved an issue where raid difficulty levels in the Vault tooltip were incorrect

## v1.2.1 - 2025-02-14

### Added

- Added a new keybind option for opening the Great Vault

### Fixed

- The keybind for opening the AlterEgo window now functions properly again

## v1.2.0 - 2025-02-12

### Added

- Introduced a new character sorting option: Custom Order – Arrange your characters as you like
- All windows can now be moved halfway off-screen
- Focusing a window now brings it to the front of other windows
- Added a new button to open the Great Vault
- Right-clicking the minimap button now opens the Great Vault
- Character tooltips now display gold amounts

### Updated

- Completely rewrote UI rendering code for significantly improved performance
- Enhanced scrolling logic for smoother and more responsive navigation
- Reduced addon load times and improved game data processing speed
- Extra windows now open away from the center of the screen by default
- Updated addon .toc for patch 11.0.7

### Fixed

- Window positions are now properly saved between reloads and sessions
- Resolved rendering issues when highlighting certain rows with the mouse
- Shift-clicking a keystone to share its link in chat now works again
- Fixed character and realm names from wrapping onto a new line when too long
- Resolved a bug causing raid difficulties to disappear in the Show Raid Progress option

## v1.1.17 - 2024-12-21

### Added

- Introduced Season 1 Weekly affix rotation data

### Updated

- Optimized addon performance to prevent game freezes

### Fixed

- Resolved an issue where new keystones were not announced to party or guild
- Fixed lag and stuttering when looting items

## v1.1.16 - 2024-11-10

### Added

- Included dungeon timer cutoffs in the score tooltips

### Fixed

- Score icons now display the correct tier icon (+1, +2, +3)
- Score colors now account for the additional 90 seconds from Challenger's Peril

## v1.1.15 - 2024-09-29

### Fixed

- Fixed a Blizzard bug affecting "Best Run" data for dungeons (Thanks to everyone who reported it)
- Resolved an issue with line spacing in the dungeon vault tooltips

## v1.1.14 - 2024-09-18

### Added

- Introduced a new setting to display dungeon rating next to the key level
- Added the TWW Season 1 Catalyst currency

### Updated

- Removed the Tyrannical/Fortified columns
- Redesigned the column layout for dungeon levels and scores

### Fixed

- Corrected the number of affix buttons shown at the top of the window

## v1.1.13 - 2024-09-15

### Added

- Added Great Vault row: World Activities

### Updated

- Updated a couple of vault tooltips with progress details

## v1.1.12 - 2024-08-28

### Updated

- Added TWW Season 1 data, currencies and dungeons

### Fixed

- Temp. fix characters not showing at the new max level (80)

## v1.1.11 - 2024-08-14

### Updated

- Updated the TOC version to 11.0.2

## v1.1.10 - 2024-07-25

### Updated

- Updated the TOC version to 11.0.0

## v1.1.9 - 2024-06-09

### Updated

- The currency Antique Bronze Bullion now shows max quantity (relog characters). Thanks [@Numynum](https://github.com/Numynum)

### Fixed

- Fixed an issue with item upgrades being blocked by AlterEgo
- Equipment window now shows Awakened upgrade levels correctly (relog characters)

## v1.1.8 - 2024-05-08

### Updated

- Updated addon to Patch 10.2.7

### Fixed

- Fixed a major UI bug caused by the latest patch

## v1.1.7 - 2024-05-05

### Fixed

- Fixed an issue with missing affix data causing errors

## v1.1.6 - 2024-04-27

### Fixed

- Fixed an issue with keystones not being announced automatically
- Fixed an issue with Sennarth, The Cold Breath not showing as killed in the raid progress

## v1.1.5 - 2024-04-24

### Added

- Added a warning if the setting for hiding characters with zero rating is enabled when transitioning into a new season

### Updated

- Updated the teleportation tooltips from +20 to +10

### Fixed

- Fixed an issue with the new Antique Bronze Bullion currency

## v1.1.4 - 2024-04-22

### Fixed

- Fixed a bug with the raid section not showing before the new season (Thanks Kaivalya)

## v1.1.3 - 2024-04-22

### Added

- Added a new setting: Toggle Raid difficulties
- Added a new setting: Show PvP vault progress
- Added a new setting: Show Awakened raids only (active in Season 4)
- Added Season 4 currencies (active in Season 4)
- Added a new raid icon for the active Awakened raid (active in Season 4)
- Added a video spotlight (Thanks [@Sunshade](https://www.youtube.com/@SunshadeWoW))

### Updated

- Updated Season 4 keystone data (active in Season 4)
- Updated the addon description with new features
- Updated the addon events and UI updates for a better performance
- Moved and clarified the settings regarding manual keystone announcements
- Reduced and optimized addon images. Addon package is now much, much smaller

### Fixed

- Fixed string sorting issues with unicode characters
- Fixed an old bug with the score colors. They will now show the correct colors individually
- Fixed a couple of currency bugs. You may have to relog characters to save new data
- Fixed some bugs for when currencies have their maxQuantity removed by Blizzard

## v1.1.2 - 2024-04-11

### Added

- Added a new setting: Raider.io rating colors
- Added AlterEgo to WowInterface.com and Wago.io

### Updated

- Dropdowns now behave as expected on multiple clicks
- Dropdowns now remain open when toggling options
- Rating tooltip will no longer show "(Season 0)" as Best Season
- Removed Difficulty column from the Weekly Affixes window
- Updated TOC
- Cleaning up code and preparing for easier addon packaging/releases

### Fixed

- Fixed a localization bug with dungeon orders in rating tooltips
- Fixed a localization bug with dungeon values missing when switching between game clients (You may have to log your characters again to update the missing values)
- Fixed a game crash when shift clicking a rating tooltip with zero dungeon runs

## v1.1.1 - 2024-04-03

### Fixed

Fixed a horrendous Blizzard bug with keystone/dungeon colors.
Players in the US will most likely see white colors until Blizzard hotfixes this.

## v1.1.0 - 2024-02-01

### Added

- Added a new window: Weekly Affixes (Click the affixes at the top)
- Added a new window: Character Equipment (Click the character names)
- Added a new setting: Hide realm names
- Added a new setting: Window background color
- Added a new setting: Window scaling
- Added AlterEgo to the addon compartment (Thanks [@Wolkenschutz](https://github.com/Wolkenschutz))

### Updated

- Swapped the Fortified/Tyrannical columns to match raider.io
- Changed the order of crests and currencies by difficulty
- Added new tooltip instructions to all click actions
- The affix of the week is now highlighted above the dungeon scores
- Frames and windows have been recoded completely for a better/optimized performance

### Fixed

- Fixed font issues with characters saved across different client/realm languages
- Fixed an issue with the addon frames and textures clashing/mixing with other UI elements
- Max. Catalyst charges are now correctly increased weekly

## v1.0.9 - 2024-01-07

### Fixed

- Fixed font issues in different languages/alphabets (Cyrillic etc.)

## v1.0.8 - 2024-01-06

### Fixed

- Fixed an issue caused by the new teleport feature - Thanks to CrackedOrb/arcadepro for the report

## v1.0.7 - 2024-01-05

### Added

- You can now sort characters by class name
- Added dungeon teleportation to dungeon names
- Added flightstone/crest/catalyst tracking to the tooltips of character names

### Updated

- Rerolled keystones are now also announced

## v1.0.6 - 2023-12-28

### Added

- Added keystone announcements
- Added instance reset announcements

### Fixed

- Fixed a database migration loop

## v1.0.5 - 2023-12-14

### Added

- Added an icon to the AddOn List
- Added support for Heroic and Mythic dungeon runs
- Added the weekly affixes in the top of the window

### Updated

- Raid progress is now enabled by default on first use
- Color settings are now enabled by default
- Moved the settings around a bit

### Fixed

- Fixed a bug showing incorrect kills for the Council and Larodar encounters
- Rating tooltip no longer shows +0 as highest key level
- The vault tooltip no longer shows improvement text if all weekly dungeon runs are level 20+
- The "Rewards" label now hides properly when looting the vault
- Fixed a small graphical spacing issue with dropdowns

## v1.0.4 - 2023-11-22

### Fixed

- The keystone info no longer disappears if it's destroyed or moved to the bank
- The keystone should now show the correct DOTI abbreviation name
- Fixed a bug where all keystones didn't clear after the weekly reset

## v1.0.3 - 2023-11-19

### Added

- Added keybinding to show/hide the addon window

### Updated

- Changed the dungeon names in the vault tooltips to make the tooltip smaller

### Fixed

- Fixed an error regarding the colors of the dungeon key levels
- Fixed an issue with the keystone not updating when manually reducing the keystone level

## v1.0.2 - 2023-11-14

### Updated

- Changed raids and dungeons to Season 3 - Good luck and have fun :-)
- Mythic+ and Raid data should be reset once the new season begins

### Fixed

- Removed the invisible dropdown buttons, so they can't be clicked when window is hidden
- The vault values have been updated to work with the new Dungeons row in the Great Vault
- Fixed a couple of string bugs in tooltips

## v1.0.1 - 2023-11-13

### Added

- This changelog :-)

### Fixed

- The rating tooltip no longer shows dungeons from the wrong season
- Fixed an issue with the addon not knowing which season it is on load

## v1.0.0 - 2023-11-12

- First release <3
