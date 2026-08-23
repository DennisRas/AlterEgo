---@class AE_Addon
local addon = select(2, ...)

---@class AE_Data
local Data = addon.Data

local PREY_DIFFICULTY_NORMAL = 1
local PREY_DIFFICULTY_HARD = 2
local PREY_DIFFICULTY_NIGHTMARE = 3

local PREY_AFFIX_AMBUSH = 1
local PREY_AFFIX_TORMENT = 2
local PREY_AFFIX_HUNTERS_MOMENTUM = 3
local PREY_AFFIX_SEEPING_GORE = 4
local PREY_AFFIX_ECHO_OF_PREDATION = 5
local PREY_AFFIX_BLOODY_COMMAND = 6
local PREY_AFFIX_PACK_AMBUSH = 7
local PREY_AFFIX_EXPLODING_CORPSE_SNAKES = 8
local PREY_AFFIX_TOXIC_SNARE = 9

---@type AE_PreyAffix[]
Data.preyAffixes = {
  {id = PREY_AFFIX_AMBUSH,                  name = "Ambush",                   description = "Your target occasionally ambushes you while you are engaged in combat with other enemies, or when you trigger a trap."},
  {id = PREY_AFFIX_TORMENT,                 name = "Torment",                  description = "Astalor's artifact insidiously torments you, increasing damage taken by 2%. This effect stacks based on your Prey hunt progress."},
  {id = PREY_AFFIX_HUNTERS_MOMENTUM,        name = "Hunter's Momentum",        description = "Dying in this zone will reduce your hunt progress."},
  {id = PREY_AFFIX_SEEPING_GORE,            name = "Seeping Gore",             description = "While in combat, gore occasionally appears beneath you, inflicting Shadow damage after a short delay."},
  {id = PREY_AFFIX_ECHO_OF_PREDATION,       name = "Echo of Predation",        description = "A bloody spirit periodically stalks you, dealing massive Shadow damage on contact."},
  {id = PREY_AFFIX_BLOODY_COMMAND,          name = "Bloody Command",           description = "Astalor occasionally commands you to kill an enemy, causing you to bleed for massive Physical damage if you fail."},
  {id = PREY_AFFIX_PACK_AMBUSH,             name = "Pack Ambush",              description = "A pack of serpentine scouts occasionally attack from the shadows while you are in combat."},
  {id = PREY_AFFIX_EXPLODING_CORPSE_SNAKES, name = "Exploding Corpse Snakes",  description = "Snakes erupt from enemy corpses, exploding in a spray of venom when killed."},
  {id = PREY_AFFIX_TOXIC_SNARE,             name = "Toxic Snare",              description = "Envenomed Nets are thrown at your location while in combat, slowing you and inflicting Nature damage if triggered."},
}

---@type AE_PreyDifficulty[]
Data.preyDifficulties = {
  {seasonID = 17, seasonDisplayID = 1, id = PREY_DIFFICULTY_NORMAL,    name = "Normal",    affixes = {PREY_AFFIX_AMBUSH}},
  {seasonID = 17, seasonDisplayID = 1, id = PREY_DIFFICULTY_HARD,      name = "Hard",      affixes = {PREY_AFFIX_TORMENT, PREY_AFFIX_HUNTERS_MOMENTUM, PREY_AFFIX_SEEPING_GORE}},
  {seasonID = 17, seasonDisplayID = 1, id = PREY_DIFFICULTY_NIGHTMARE, name = "Nightmare", affixes = {PREY_AFFIX_ECHO_OF_PREDATION, PREY_AFFIX_BLOODY_COMMAND}},
  {seasonID = 18, seasonDisplayID = 2, id = PREY_DIFFICULTY_NORMAL,    name = "Normal",    affixes = {PREY_AFFIX_AMBUSH}},
  {seasonID = 18, seasonDisplayID = 2, id = PREY_DIFFICULTY_HARD,      name = "Hard",      affixes = {PREY_AFFIX_TORMENT, PREY_AFFIX_PACK_AMBUSH, PREY_AFFIX_EXPLODING_CORPSE_SNAKES, PREY_AFFIX_TOXIC_SNARE}},
  {seasonID = 18, seasonDisplayID = 2, id = PREY_DIFFICULTY_NIGHTMARE, name = "Nightmare", affixes = {PREY_AFFIX_TORMENT, PREY_AFFIX_PACK_AMBUSH, PREY_AFFIX_EXPLODING_CORPSE_SNAKES, PREY_AFFIX_TOXIC_SNARE}},
}

---@type AE_PreyQuest[]
Data.preyQuests = {
  {questID = 91095, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Magister Sunbreaker (Normal)"},
  {questID = 91096, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Magistrix Emberlash (Normal)"},
  {questID = 91097, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Senior Tinker Ozwold (Normal)"},
  {questID = 91098, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: L-N-0R the Recycler (Normal)"},
  {questID = 91099, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Mordril Shadowfell (Normal)"},
  {questID = 91100, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Deliah Gloomsong (Normal)"},
  {questID = 91101, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Phaseblade Talasha (Normal)"},
  {questID = 91102, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Nexus-Edge Hadim (Normal)"},
  {questID = 91103, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Jo'zolo the Breaker (Normal)"},
  {questID = 91104, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Zadu, Fist of Nalorakk (Normal)"},
  {questID = 91105, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: The Talon of Jan'alai (Normal)"},
  {questID = 91106, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: The Wing of Akil'zon (Normal)"},
  {questID = 91107, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Ranger Swiftglade (Normal)"},
  {questID = 91108, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Lieutenant Blazewing (Normal)"},
  {questID = 91109, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Petyoll the Razorleaf (Normal)"},
  {questID = 91110, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Lamyne of the Undercroft (Normal)"},
  {questID = 91111, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: High Vindicator Vureem (Normal)"},
  {questID = 91112, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Crusader Luxia Maxwell (Normal)"},
  {questID = 91113, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Praetor Singularis (Normal)"},
  {questID = 91114, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Consul Nebulor (Normal)"},
  {questID = 91115, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Executor Kaenius (Normal)"},
  {questID = 91116, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Imperator Enigmalia (Normal)"},
  {questID = 91117, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Knight-Errant Bloodshatter (Normal)"},
  {questID = 91118, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Vylenna the Defector (Normal)"},
  {questID = 91119, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Lost Theldrin (Normal)"},
  {questID = 91120, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Neydra the Starving (Normal)"},
  {questID = 91121, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Thornspeaker Edgath (Normal)"},
  {questID = 91122, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Thorn-Witch Liset (Normal)"},
  {questID = 91123, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Grothoz, the Burning Shadow (Normal)"},
  {questID = 91124, difficultyID = PREY_DIFFICULTY_NORMAL,    name = "Prey: Dengzag, the Darkened Blaze (Normal)"},
  {questID = 91210, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Magister Sunbreaker (Hard)"},
  {questID = 91211, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Magister Sunbreaker (Nightmare)"},
  {questID = 91212, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Magistrix Emberlash (Hard)"},
  {questID = 91213, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Magistrix Emberlash (Nightmare)"},
  {questID = 91214, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Senior Tinker Ozwold (Hard)"},
  {questID = 91215, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Senior Tinker Ozwold (Nightmare)"},
  {questID = 91216, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: L-N-0R the Recycler (Hard)"},
  {questID = 91217, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: L-N-0R the Recycler (Nightmare)"},
  {questID = 91218, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Mordril Shadowfell (Hard)"},
  {questID = 91219, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Mordril Shadowfell (Nightmare)"},
  {questID = 91220, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Deliah Gloomsong (Hard)"},
  {questID = 91221, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Deliah Gloomsong (Nightmare)"},
  {questID = 91222, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Phaseblade Talasha (Hard)"},
  {questID = 91223, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Phaseblade Talasha (Nightmare)"},
  {questID = 91224, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Nexus-Edge Hadim (Hard)"},
  {questID = 91225, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Nexus-Edge Hadim (Nightmare)"},
  {questID = 91226, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Jo'zolo the Breaker (Hard)"},
  {questID = 91227, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Jo'zolo the Breaker (Nightmare)"},
  {questID = 91228, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Zadu, Fist of Nalorakk (Hard)"},
  {questID = 91229, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Zadu, Fist of Nalorakk (Nightmare)"},
  {questID = 91230, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: The Talon of Jan'alai (Hard)"},
  {questID = 91231, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: The Talon of Jan'alai (Nightmare)"},
  {questID = 91232, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: The Wing of Akil'zon (Hard)"},
  {questID = 91233, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: The Wing of Akil'zon (Nightmare)"},
  {questID = 91234, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Ranger Swiftglade (Hard)"},
  {questID = 91235, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Ranger Swiftglade (Nightmare)"},
  {questID = 91236, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Lieutenant Blazewing (Hard)"},
  {questID = 91237, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Lieutenant Blazewing (Nightmare)"},
  {questID = 91238, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Petyoll the Razorleaf (Hard)"},
  {questID = 91239, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Petyoll the Razorleaf (Nightmare)"},
  {questID = 91240, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Lamyne of the Undercroft (Hard)"},
  {questID = 91241, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Lamyne of the Undercroft (Nightmare)"},
  {questID = 91242, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: High Vindicator Vureem (Hard)"},
  {questID = 91243, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Crusader Luxia Maxwell (Hard)"},
  {questID = 91244, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Praetor Singularis (Hard)"},
  {questID = 91245, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Consul Nebulor (Hard)"},
  {questID = 91246, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Executor Kaenius (Hard)"},
  {questID = 91247, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Imperator Enigmalia (Hard)"},
  {questID = 91248, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Knight-Errant Bloodshatter (Hard)"},
  {questID = 91249, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Vylenna the Defector (Hard)"},
  {questID = 91250, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Lost Theldrin (Hard)"},
  {questID = 91251, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Neydra the Starving (Hard)"},
  {questID = 91252, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Thornspeaker Edgath (Hard)"},
  {questID = 91253, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Thorn-Witch Liset (Hard)"},
  {questID = 91254, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Grothoz, the Burning Shadow (Hard)"},
  {questID = 91255, difficultyID = PREY_DIFFICULTY_HARD,      name = "Prey: Dengzag, the Darkened Blaze (Hard)"},
  {questID = 91256, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: High Vindicator Vureem (Nightmare)"},
  {questID = 91257, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Crusader Luxia Maxwell (Nightmare)"},
  {questID = 91258, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Praetor Singularis (Nightmare)"},
  {questID = 91259, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Consul Nebulor (Nightmare)"},
  {questID = 91260, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Executor Kaenius (Nightmare)"},
  {questID = 91261, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Imperator Enigmalia (Nightmare)"},
  {questID = 91262, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Knight-Errant Bloodshatter (Nightmare)"},
  {questID = 91263, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Vylenna the Defector (Nightmare)"},
  {questID = 91264, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Lost Theldrin (Nightmare)"},
  {questID = 91265, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Neydra the Starving (Nightmare)"},
  {questID = 91266, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Thornspeaker Edgath (Nightmare)"},
  {questID = 91267, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Thorn-Witch Liset (Nightmare)"},
  {questID = 91268, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Grothoz, the Burning Shadow (Nightmare)"},
  {questID = 91269, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Dengzag, the Darkened Blaze (Nightmare)"},
  {questID = 95021, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Janoa the Fang (Nightmare)"},
  {questID = 95022, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Kursak the Coiled (Nightmare)"},
  {questID = 95023, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Batani the Scaled (Nightmare)"},
  {questID = 95024, difficultyID = PREY_DIFFICULTY_NIGHTMARE, name = "Prey: Kadani the Claw (Nightmare)"},
}
