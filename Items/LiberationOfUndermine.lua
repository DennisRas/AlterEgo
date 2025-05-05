local LiberationOfUndermine = LibStub("AceAddon-3.0"):GetAddon("AlterEgo"):NewModule("LiberationOfUndermine")
local tocVersion = select(1, GetBuildInfo())

if tocVersion <= "11.0.2" then
    return
end

---@class AE_Addon
local addon = select(2, ...)

function LiberationOfUndermine:OnEnable()

    local instance = addon.Items:RegisterInstance(2406, 6, {3524})

    ----- Strolch and the Gang Keepers
    local bossLoot = {
        infoId = 2639,
        instanceId = instance.id,
        items = {
            223048, --Plans: Draining Stiletto
            228892, --Greasemonkey's Gear Shift
            231268, --Blast Rage Machete
            228858, --Full Throttle Visage
            228875, --Vandal's Skull Plate
            228839, --Racing Flag of the Underground Circuit
            228852, --Glory's Flame Blazer
            228868, --Souped-Up Bracers
            228861, --Tuning Tool Belt
            228865, --Pit Doctor's Underskirt
            228876, --Dragster's Final Meters
            228862, --Shrapnel-Infused Sabatons
            230197, --Gang Keeper's Spare Key
            230019  --Strolch's Pit Whistle
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Cauldron of Carnage
    bossLoot = {
        infoId = 2640,
        instanceId = instance.id,
        items = {
            228806, --High-Profit Bloody Galvite
            228804, --Mystic Bloody Galvite
            228803, --Dreadful Bloody Galvite
            228805, --Venerated Bloody Galvite
            228904, --Crowd Favorite
            228900, --Arc of Tension
            228890, --Superfan's Brawling Buzzer
            228846, --Galvanic Graffiti Cuffs
            228873, --Heavyweight Champion Belt
            228856, --Battler's Victory Cord
            228847, --Hot-Footed Heel Turners
            228840, --Faded Championship Ring
            230191, --Luminodo's Pilot Light
            230190, --Torq's Big Red Button
            -- Tier Set Hands
            229236, --Warrior Hands
            229245, --Paladin Hands
            229254, --Death Knight Hands
            229263, --Shaman Hands
            229272, --Hunter Hands
            229281, --Evoker Hands
            229290, --Rogue Hands
            229299, --Monk Hands
            229308, --Druid Hands
            229317, --Demon Hunter Hands
            229326, --Warlock Hands
            229335, --Priest Hands
            229344  --Mage Hands
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Rik Resonance
    bossLoot = {
        infoId = 2641,
        instanceId = instance.id,
        items = {
            228818, --High-Profit Polished Galvite
            224435, --Pattern: Duskthread Lining
            228816, --Mystic Polished Galvite
            228815, --Dreadful Polished Galvite
            228817, --Venerated Polished Galvite
            228895, --Mixed Ignition Saber
            228897, --Needle Storm Fireworks
            231311, --Frontman's Wonder Wall
            228841, --Semi-Enchanting Amulet
            228857, --Underground Party Entry Band
            228869, --Killer Queen's Wrist Snapper
            228845, --Riot Diva's Sash
            228874, --Rik's Strolling Boots
            230194, --Hall Radio
            -- Tier Set Shoulder
            229233, --Warrior Shoulder
            229242, --Paladin Shoulder
            229251, --Death Knight Shoulder
            229260, --Shaman Shoulder
            229269, --Hunter Shoulder
            229278, --Evoker Shoulder
            229287, --Rogue Shoulder
            229296, --Monk Shoulder
            229305, --Druid Shoulder
            229314, --Demon Hunter Shoulder
            229323, --Warlock Shoulder
            229332, --Priest Shoulder
            229341  --Mage Shoulder
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Stix Bunkerwrecker
    bossLoot = {
        infoId = 2642,
        instanceId = instance.id,
        items = {
            236687, --Explosive Hearthstone
            228814, --High-Profit Rusty Galvite
            228812, --Mystic Rusty Galvite
            228811, --Dreadful Rusty Galvite
            228813, --Venerated Rusty Galvite
            228903, --Trash Diver
            228896, --Stix's Metal Detector
            228871, --Cleanup Crew's Waste Mask
            228859, --Disinfected Scrap Hood
            228849, --Waste Mech Compactor
            228854, --Bilge Rat's Discarded Leggings
            230189, --Scrap Maestro's Megamagnet
            230026, --Scrapfield 9001
            -- Tier Set Legs
            229234, --Warrior Legs
            229243, --Paladin Legs
            229252, --Death Knight Legs
            229261, --Shaman Legs
            229270, --Hunter Legs
            229279, --Evoker Legs
            229288, --Rogue Legs
            229297, --Monk Legs
            229306, --Druid Legs
            229315, --Demon Hunter Legs
            229324, --Warlock Legs
            229333, --Priest Legs
            229342  --Mage Legs
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Cogmaster Lockstock
    bossLoot = {
        infoId = 2653,
        instanceId = instance.id,
        items = {
            228802, --High-Profit Oiled Galvite
            223097, --Pattern: Adrenaline Rush Buckle
            228800, --Mystic Oiled Galvite
            228799, --Dreadful Oiled Galvite
            228801, --Venerated Oiled Galvite
            228898, --Alpha Coil Thunder Staff
            228894, --GIGADEATH Chain Blade
            228844, --Test Pilot's Flight Sack
            228884, --Test Subject's Shackles
            228867, --Gravislick Grips
            228882, --Refiner's Conveyor Belt
            228888, --Rushed Beta Treads
            230186, --Mr. Wakemaker
            230193, --Master Lock-and-Stock
            -- Tier Set Chest
            229238, --Warrior Chest
            229247, --Paladin Chest
            229256, --Death Knight Chest
            229265, --Shaman Chest
            229274, --Hunter Chest
            229283, --Evoker Chest
            229292, --Rogue Chest
            229301, --Monk Chest
            229310, --Druid Chest
            229319, --Demon Hunter Chest
            229328, --Warlock Chest
            229337, --Priest Chest
            229346  --Mage Chest
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- The One-Armed Bandit
    bossLoot = {
        infoId = 2644,
        instanceId = instance.id,
        items = {
            228810, --High-Profit Gilded Galvite
            228808, --Mystic Gilded Galvite
            228807, --Dreadful Gilded Galvite
            228809, --Venerated Gilded Galvite
            228905, --Gigabank Breaker
            232526, --Gambleplate
            231266, --Random Number Perforator
            228906, --Management's Cheat Detector
            228850, --Bargain Blouse
            228885, --High Roller's Top
            228886, --Coin-Operated Belt
            228883, --Dubious Table Runners
            228843, --Miniature Roulette Cauldron
            230188, --Garbagio's Bottle Service
            230027, --House of Cards
            -- Tier Set Head
            229235, --Warrior Head
            229244, --Paladin Head
            229253, --Death Knight Head
            229262, --Shaman Head
            229271, --Hunter Head
            229280, --Evoker Head
            229289, --Rogue Head
            229298, --Monk Head
            229307, --Druid Head
            229316, --Demon Hunter Head
            229325, --Warlock Head
            229334, --Priest Head
            229343  --Mage Head
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Mug'Zee, Security Chief
    bossLoot = {
        infoId = 2645,
        instanceId = instance.id,
        items = {
            223094, --Design: Superior Jeweler's Setting
            228902, --Cartel Member's Rejected Offer
            232804, --Capo's Melted Knuckles
            228901, --High Earner's Club
            228893, --"Little Friend"
            228842, --Gobfather's Gifted Jewelry
            228870, --Underboss's Tailored Coat
            228860, --Failed Enforcer's Shoulderguards
            228851, --"Bulletproof" Chestguard
            228878, --Made Man's Handcuffs
            228863, --Enforcer's Long Fingers
            228880, --Contract Killer's Holster
            228853, --Hired Muscle's Legguards
            228879, --Cemented Murloc Waders
            230192, --Mug's Mummkrug
            230199  --Zee's Gangster Hotline
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Chrome King Gallywix
    bossLoot = {
        infoId = 2646,
        instanceId = instance.id,
        items = {
            236960, --A.S.M.R. Prototype
            223144, --Formula: Weapon - Authority of the Depths
            228819, --Overly Jeweled Curio
            228891, --Capital Seizer
            228899, --Gallywix's Iron Thumb
            228889, --Titan of Industry
            228848, --Darkmoon Cutthroat's Tricorne
            228855, --Resourceful Spaulders
            228864, --"Optimized" Cartel Uniform
            228881, --Illegally Funded Bracers
            228872, --Golden Handshakers
            228877, --Coveted Dealer's Chain
            228866, --Deep Pocketed Pantaloons
            228887, --Cutthroat's Competition Stompers
            231265, --The Jastor Diamond
            230198, --Eye of Kezan
            230029, --Chrombustion Bomb Suit
            -- Token All Set Items
            -- Tier Set Chest
            229238, --Warrior Chest
            229247, --Paladin Chest
            229256, --Death Knight Chest
            229265, --Shaman Chest
            229274, --Hunter Chest
            229283, --Evoker Chest
            229292, --Rogue Chest
            229301, --Monk Chest
            229310, --Druid Chest
            229319, --Demon Hunter Chest
            229328, --Warlock Chest
            229337, --Priest Chest
            229346, --Mage Chest
            -- Tier Set Hands
            229236, --Warrior Hands
            229245, --Paladin Hands
            229254, --Death Knight Hands
            229263, --Shaman Hands
            229272, --Hunter Hands
            229281, --Evoker Hands
            229290, --Rogue Hands
            229299, --Monk Hands
            229308, --Druid Hands
            229317, --Demon Hunter Hands
            229326, --Warlock Hands
            229335, --Priest Hands
            229344, --Mage Hands
            -- Tier Set Head
            229235, --Warrior Head
            229244, --Paladin Head
            229253, --Death Knight Head
            229262, --Shaman Head
            229271, --Hunter Head
            229280, --Evoker Head
            229289, --Rogue Head
            229298, --Monk Head
            229307, --Druid Head
            229316, --Demon Hunter Head
            229325, --Warlock Head
            229334, --Priest Head
            229343, --Mage Head
            -- Tier Set Legs
            229234, --Warrior Legs
            229243, --Paladin Legs
            229252, --Death Knight Legs
            229261, --Shaman Legs
            229270, --Hunter Legs
            229279, --Evoker Legs
            229288, --Rogue Legs
            229297, --Monk Legs
            229306, --Druid Legs
            229315, --Demon Hunter Legs
            229324, --Warlock Legs
            229333, --Priest Legs
            229342, --Mage Legs
            -- Tier Set Shoulder
            229233, --Warrior Shoulder
            229242, --Paladin Shoulder
            229251, --Death Knight Shoulder
            229260, --Shaman Shoulder
            229269, --Hunter Shoulder
            229278, --Evoker Shoulder
            229287, --Rogue Shoulder
            229296, --Monk Shoulder
            229305, --Druid Shoulder
            229314, --Demon Hunter Shoulder
            229323, --Warlock Shoulder
            229332, --Priest Shoulder
            229341  --Mage Shoulder
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

end