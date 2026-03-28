# Changelog

## v1.4.5 - 2026-03-28

- Fixed an issue with incorrect currency values in the main window if maximum value is reached.

## v1.4.4 - 2026-03-25

- Added new Weekly Maximum information to currencies.
- Fixed an issue with Coffer Key Shards showing incorrect maximum.
- Fixed incorrect/missing dungeon data for Seat of the Triumvirate.
- Fixed teleport spell for the Skyreach dungeon.
- Removed confusing currency limit on Restored Coffer Keys.

## v1.4.3 - 2026-03-18

- Updated the changelog to be more concise and easier to read.
- Fixed a Lua error on login/reload caused by Prey Hunts.
- Fixed an issue with the raid progress icons. No, you haven't killed all 9 bosses yet :P
- Removed "Expires" from raid progress tooltips. With combined raids it was duplicated/crowded and it's pretty know when weekly reset happens.

## v1.4.2 - 2026-03-17

- Added tracking for Prey Hunt progress (experimental).
- Added new settings to enable/disable the feature and customize displayed difficulties.

## v1.4.1 - 2026-03-15

- Added option to remove characters from the character list.
- Added scrollbar for large character lists (60+ characters).
- Added guild information as a row in the main window (disabled by default) and character tooltip.
- Updated currency order for better relevance.
- Updated rating tooltip formatting (numbers and colors).
- Updated rating tooltip to hide automatically when Mythic+ is inactive.
- Fixed Lua error in combat caused by custom character sorting.
- Fixed rating tooltip not showing dungeon data for alts after a season reset.
- Removed buggy currency list from the character tooltip.

## v1.4.0 - 2026-03-11

- Added Midnight Season 1 data (raids, M+ dungeons, and currencies).
- Added forced switch to Midnight Season 1 even though the season hasn't started yet.
- Added setting to enable/disable the dungeon section in the main window.
- Updated raid progress in the main window to use icons instead of boxes.
- Updated raid section layout for clearer display of multiple raids in one row.
- Updated currency tooltips to avoid confusion with season maximums.
- Removed AceEvent library to prevent CPU issues.
- Fixed Lua errors in instances and battlegrounds.
- Fixed extra Raid and Currency rows showing incorrectly.

## v1.3.5 - 2026-01-21

- Fixed item level squish.

Please note: Because of the stat squish in Midnight, all item levels won't be fully accurate until you've logged the characters. Blizzard may also have incorrect item level ranges for a few days.

## v1.3.4 - 2026-01-21

- Updated all item levels reduced by ~560.
- Fixed old deprecated code causing IsWeeklyRewardAvailable errors.

## v1.3.3 - 2026-01-20

- Updated TOC number to support Midnight Pre-patch + Beta.

## v1.3.2 - 2025-08-06

- Added Reshii Wraps ranks to the Equipment window.
- Added Fractured Sparks to the Currencies section.
- Added Ethreal Strands to the Currencies section.
- Added workaround to show Upgrade Levels on old Season 2 items.
- Updated currency tooltip texts for clarity and consistency.
- Fixed currency tooltips displaying incorrect season data after first login.

Please note: This pre-season week provides partial data. Vault rewards and currencies may show incorrect values until Blizzard finalizes the backend.

## v1.3.1 - 2025-08-06

- Updated currencies not earned yet to show as blank ("-").
- Updated currency tooltips to display season maximum.
- Fixed Valorstones no longer resetting between seasons.
- Fixed maxQuantity issues for some currencies (Runed and Gilded Ethereal Crests).

## v1.3.0 - 2025-08-05

- Added TWW Season 3 data.
- Added several new settings.
- Added new Currency section (can be disabled in settings).
- Added new D.I.S.C. upgrade level to Equipment window.
- Updated TOC number to support patch 11.2.
- Updated settings layout and combined announcement options.
- Updated large code optimizations for performance and future features.
- Fixed minor typos and text errors.

## v1.2.6 - 2025-04-23

- Updated TOC number to support patch 11.1.5.
- Fixed keystones not showing due to new item quality color accessibility options.

## v1.2.5 - 2025-04-06

- Fixed typo: DCF is now properly labeled as DFC.
- Fixed Weekly Affixes window not displaying rotation.

## v1.2.4 - 2025-03-09

- Added Items in Equipment window are greyed out if from previous season.
- Fixed One-Armed Bandit correctly appearing as killed in Raid Progress.

## v1.2.3 - 2025-02-26

- Added addon category for new AddOn List (credit: Warcraft Wiki).
- Updated TOC number to support patch 11.1.

## v1.2.2 - 2025-02-23

- Added Season 2 data, including Raids, Dungeons, Affixes, and Currencies.
- Added new window background color setting for transparency.
- Updated performance by removing unused code.
- Updated weekly affix detection.
- Updated dungeon timers for Season 2.
- Updated settings and tooltip instructions.
- Updated all dropdown menus to new TWW layout.
- Fixed Vault tooltip raid difficulty display.

## v1.2.1 - 2025-02-14

- Added new keybind for opening Great Vault.
- Fixed keybind for opening AlterEgo window.

## v1.2.0 - 2025-02-12

- Added Custom Order character sorting.
- Added ability to move windows halfway off-screen.
- Added window focus behavior to bring to front.
- Added button and minimap right-click for Great Vault.
- Added gold amounts in character tooltips.
- Updated UI rendering for performance.
- Updated scrolling logic for smoother navigation.
- Updated load times and data processing.
- Updated extra windows opening offset.
- Updated .toc for patch 11.0.7.
- Fixed window positions saving between sessions.
- Fixed rendering issues with row highlighting.
- Fixed shift-click keystone link sharing.
- Fixed long character and realm names wrapping.
- Fixed Show Raid Progress bug with disappearing difficulties.

## v1.1.17 - 2024-12-21

- Added Season 1 Weekly affix rotation data.
- Updated performance to prevent game freezes.
- Fixed keystones not announced to party/guild.
- Fixed lag and stuttering when looting items.

## v1.1.16 - 2024-11-10

- Added dungeon timer cutoffs in score tooltips.
- Fixed score icons display and Challenger's Peril timing adjustments.

## v1.1.15 - 2024-09-29

- Fixed Blizzard bug affecting "Best Run" data.
- Fixed line spacing in dungeon vault tooltips.

## v1.1.14 - 2024-09-18

- Added setting to display dungeon rating next to key level.
- Added TWW Season 1 Catalyst currency.
- Updated removed Tyrannical/Fortified columns and redesigned layout.
- Fixed number of affix buttons displayed.

## v1.1.13 - 2024-09-15

- Added Great Vault row: World Activities.
- Updated vault tooltips with progress details.

## v1.1.12 - 2024-08-28

- Updated TWW Season 1 data, currencies and dungeons.
- Fixed characters not showing at new max level (80).

## v1.1.11 - 2024-08-14

- Updated TOC version to 11.0.2.

## v1.1.10 - 2024-07-25

- Updated TOC version to 11.0.0.

## v1.1.9 - 2024-06-09

- Updated Antique Bronze Bullion currency max quantity display.
- Fixed item upgrades blocked by AlterEgo.
- Fixed Equipment window showing Awakened upgrade levels.

## v1.1.8 - 2024-05-08

- Updated addon to Patch 10.2.7.
- Fixed major UI bug from latest patch.

## v1.1.7 - 2024-05-05

- Fixed missing affix data causing errors.

## v1.1.6 - 2024-04-27

- Fixed keystones not announced automatically.
- Fixed Sennarth, The Cold Breath not showing as killed in Raid Progress.

## v1.1.5 - 2024-04-24

- Added warning if hiding zero-rating characters is enabled for new season.
- Updated teleportation tooltips from +20 to +10.
- Fixed Antique Bronze Bullion currency issues.

## v1.1.4 - 2024-04-22

- Fixed raid section not showing before new season.

## v1.1.3 - 2024-04-22

- Added settings: Toggle Raid difficulties, Show PvP vault progress, Show Awakened raids only (Season 4).
- Added Season 4 currencies and active raid icon.
- Added video spotlight (Thanks @Sunshade).
- Updated Season 4 keystone data.
- Updated addon description and events for performance.
- Updated manual keystone announcement settings.
- Updated optimized addon images.
- Fixed string sorting issues with unicode.
- Fixed old score color bug.
- Fixed some currency bugs (may require relog).

## v1.1.2 - 2024-04-11

- Added Raider.io rating colors setting.
- Added AlterEgo to WowInterface.com and Wago.io.
- Updated dropdown behavior.
- Updated rating tooltip to hide "(Season 0)".
- Updated removed Difficulty column from Weekly Affixes window.
- Updated TOC and cleaned up code.
- Fixed localization bug with dungeon order.
- Fixed localization bug with missing dungeon values.
- Fixed crash when shift-clicking rating tooltip with zero runs.

## v1.1.1 - 2024-04-03

- Fixed Blizzard keystone/dungeon color bug (US players may see white until hotfix).

## v1.1.0 - 2024-02-01

- Added Weekly Affixes window.
- Added Character Equipment window.
- Added Hide realm names setting.
- Added Window background color setting.
- Added Window scaling setting.
- Added AlterEgo to addon compartment (Thanks @Wolkenschutz).
- Updated Fortified/Tyrannical column order.
- Updated crests/currencies order by difficulty.
- Updated tooltip instructions.
- Updated affix of the week highlight.
- Updated frames/windows for optimized performance.
- Fixed font issues with characters across clients.
- Fixed frame/texture clash issues.
- Fixed Max. Catalyst charges weekly increase.

## v1.0.9 - 2024-01-07

- Fixed font issues in different alphabets.

## v1.0.8 - 2024-01-06

- Fixed teleport feature issue (Thanks CrackedOrb/arcadepro).

## v1.0.7 - 2024-01-05

- Added class sorting for characters.
- Added dungeon teleportation.
- Added flightstone/crest/catalyst tracking.
- Updated rerolled keystone announcements.

## v1.0.6 - 2023-12-28

- Added keystone announcements.
- Added instance reset announcements.
- Fixed database migration loop.

## v1.0.5 - 2023-12-14

- Added icon to AddOn List.
- Added Heroic and Mythic dungeon run support.
- Added weekly affixes display.
- Updated default raid progress.
- Updated default color settings.
- Updated settings layout.
- Fixed incorrect kills for Council/Larodar.
- Fixed rating tooltip +0 display.
- Fixed vault tooltip improvement text.
- Fixed Rewards label hiding.
- Fixed dropdown spacing.

## v1.0.4 - 2023-11-22

- Fixed keystone disappearing if destroyed/moved.
- Fixed DOTI abbreviation for keystone.
- Fixed keystones not clearing after weekly reset.

## v1.0.3 - 2023-11-19

- Added keybinding to show/hide addon window.
- Updated vault tooltip dungeon names.
- Fixed dungeon key level color errors.
- Fixed manual keystone level reduction issue.

## v1.0.2 - 2023-11-14

- Updated raids/dungeons to Season 3.
- Updated Mythic+/Raid data reset behavior.
- Fixed invisible dropdown buttons.
- Fixed Great Vault values with new Dungeons row.
- Fixed string tooltip bugs.

## v1.0.1 - 2023-11-13

- Added this changelog.
- Fixed rating tooltip showing wrong season.
- Fixed addon season detection on load.

## v1.0.0 - 2023-11-12

- First release <3
