local TwwS2 = LibStub("AceAddon-3.0"):GetAddon("AlterEgo"):NewModule("TwwS2")
local tocVersion = select(1, GetBuildInfo())

if tocVersion <= "11.0.2" then
    return
end

print("TwwS2 loaded")

---@class AE_Addon
local addon = select(2, ...)

-- Extract from BestInSlotRedux, where to retrieve it ?
local bonusesBfa = {11359,11996,9639,6646}
local bonusesBfa2 = {10067,11996,9639,6646}
local bonusesSl = {9987,11996,9639,6646}
local bonusesTwwS2a = {3170,11996,9639,6646}
local bonusesTwwS2b = {5900,11996,9639,6646}

function TwwS2:OnEnable()
    print("TwwS2:OnEnable")
    self:TheaterOfPain()
    self:OperationMechagon()
    self:TheMOTHERLODE()
    self:TheRookery()
    self:DarkflameCleft()
    self:CinderbrewMeadery()
    self:PrioryOfTheSacredFlame()
    self:OperationFloodgate()
end

function TwwS2:TheaterOfPain()
    local instance = addon.Items:RegisterInstance(1683, 8, bonusesSl)
    ----- An Affront of Challengers
    local bossLoot = {
        infoId = 2397,
        instanceId = instance.id,
        items = {
            178866, --Dessia's Decimating Decapitator
            178799, --Amphitheater Stalker's Hood
            178803, --Plague-Licked Amice
            178795, --Vest of Concealed Secrets
            178800, --Galvanized Oxxein Legguards
            178871, --Bloodoath Signet
            178810  --Vial of Spectral Essence
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

     ----- Gorechop
    bossLoot = {
        infoId = 2401,
        instanceId = instance.id,
        items = {
            178793, --Abdominal Securing Chestguard
            178806, --Contaminated Gauze Wristwraps
            178798, --Grips of OVerwhelming Beatings
            178869, --Fleshfused Circle
            178808  --Viscera of Coalesced Hatred
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Xav the Unfallen
    bossLoot = {
        infoId = 2390,
        instanceId = instance.id,
        items = {
            178865, --Xav's Pike of Authority
            178789, --Fleshcrafter's Knife
            178864, --Gorebound Predator's Gavel
            178863, --Gorestained Cleaver
            178794, --Triumphant Combatatnt's Chainmail
            178807, --Pit FFighter's Wristguards
            178801  --Fearless Challenger's Leggings
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Kul'Tharok
    bossLoot = {
        infoId = 2389,
        instanceId = instance.id,
        items = {
            178792, --Soulswen Vestments
            178805, --Girdle of Shattered Dreams
            178796, --Boots of Shuddering Matter
            178870, --Ritual Bone Band
            178809  --Soulletting Ruby
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Mordretha, the Endless Empress
    bossLoot = {
        infoId = 2417,
        instanceId = instance.id,
        items = {
            178867, --Barricade of the Endless Empire
            178868, --Deathwalker's Promise
            178802, --Unyielding Combatatn's Pauldrons
            178804, --Fallen Empress's Cord
            178797, --Vanquished Usurper's Footpads
            178872, --Ring of Perpetual Conflict
            178811  --Grim Codex
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)
end

function TwwS2:OperationMechagon()
    local instance = addon.Items:RegisterInstance(1490, 8, bonusesBfa2)
  
    ----- Tussle Tonks
    local bossLoot = {
        infoId = 2336,
        instanceId = instance.id,
        items = {
            168958, --Ringmaster's Cummerbund
            168965, --Modular Platinum Plating
            168964, --Hyperthread Boots
            168962, --Apex Perforator
            168966, --Heavy Alloy Legplates
            168957, --Mekgineer's Championship Belt
            168955, --Electrifying Cognitive Amplifier
            168967, --Gold-Coated Superconductors
            170510  --Forceful Logic Board
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- K.U.-J.0.
    bossLoot = {
        infoId = 2339,
        instanceId = instance.id,
        items = {
            168969, --Operator's Mitts
            168970, --Trashmaster's Mantle
            168972, --Pyroclastic Greatboots
            168971, --Swift Pneumatic Grips
            168968, --Flame-Seared Leggings
            170508  --Optimized Logic Board
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Machinist's Garden
    bossLoot = {
        infoId = 2348,
        instanceId = instance.id,
        items = {
            168975, --Machinist's Treasured Treads
            168973, --Neural Synapse Enhancer
            168974, --Self-Repairing Cuisses
            168976, --Automatic Waist Tightener
            169159, --Overclocking Bit Band
            169160, --Shorting Bit Band
            168977, --Rebooting Bit Band
            169161, --Protecting Bit Band
            169344, --Ingenious Mana Battery
            169608, --Tearing Sawtooth Blade
            170507, --Omnipurpose Logic Board
            167556  --Subroutine: Overclock
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- King Mechagon
    bossLoot = {
        infoId = 2331,
        instanceId = instance.id,
        items = {
            168980, --Gauntlets of Absolute Authority
            168986, --Mad King's Sporran
            168983, --Maniacal Monarch's Girdle
            168985, --Self-Sanitizing Handwraps
            168989, --Hyperthread Wristwraps
            168988, --Royal Attendant's Trousers
            168982, --Regal Mekanospurs
            168978, --Anodized Deflectors
            168671, --Electromagnetic Resistors
            169378, --Golden Snorf
            169774, --Progression Sprocket
            168842, --Engine of Mecha-Perfection
            169172, --Blueprint: Perfectly Timed Differential
            170509  --Performant Logic Board
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)
end

function TwwS2:TheMOTHERLODE()
    local instance = addon.Items:RegisterInstance(1010, 8, bonusesBfa)
 
    ----- Coin-Operated Crowd Pummeler
    local bossLoot = {
        infoId = 2109,
        instanceId = instance.id,
        items = {
            159638, --Electro-Arm Bludgeoner
            159357, --Linked Pummeler Grips
            158350, --Rowdy Reveler's Legwraps
            159663, --G0-4W4Y Crowd Repeller
            155864, --Power-Assisted Vicegrips
            159462, --Footbomb Championship Ring
            158353  --Servo-Arm Bindings
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Azerokk
    bossLoot = {
        infoId = 2114,
        instanceId = instance.id,
        items = {
            159612, --Azerokk's Resonating Heart
            159231, --Mine Rat's Handwarmers
            159226, --Excavator's Safety Belt
            159336, --Mercenary Miner's Boots
            159725, --Unscrupulous Geologist's Belt
            158357, --Bindings of Enraged Earth
            158359, --Stonefury Vambraces
            159679, --Sabatons of Rampaging Elements
            159361  --Shalebiter Interlinked Chain
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Rixxa Fluxflame
    bossLoot = {
        infoId = 2115,
        instanceId = instance.id,
        items = {
            159639, --P.A.C.I.F.I.S.T. Mk7
            159235, --Deranged Alchemist's Slippers
            159240, --Rixxa's Sweat-Wicking Cuffs
            159287, --Cloak of Questionable Intent
            159451, --Leadplate Legguards
            158341, --Chemical Blaster's Legguards
            159305  --Corrosive Handler's Gloves
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Mogul Razdunk
    bossLoot = {
        infoId = 2116,
        instanceId = instance.id,
        items = {
            161135, --Schematic: Mecha-Mogul Mk2
            159415, --Skyscorcher Pauldrons
            159298, --Venture Co. Plenipotentiary Vest
            158364, --High Altitude Turban
            159360, --Crashguard Spaulders
            159611, --Razdunk's Big Red Button
            158307, --Shrapnel-Dampening Chestguard
            159232, --Exquisitely Aerodynamic Shoulderpads
            158349, --Petticoat of the Self-Stylized Azerite Baron
            159641  --G3T-00t
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)
end

function TwwS2:TheRookery()
    print("Registering The Rookery 2316")
    local instance = addon.Items:RegisterInstance(2316, 8, bonusesTwwS2a)

    ----- Kyrioss
    local bossLoot = {
        infoId = 2566,
        instanceId = instance.id,
        items = {
            221032, --Aufgeladener Sturmrufer
            221033, --Hyperaktive Sturmklaue
            221037, --Geladene Krähenfederwickel
            221036, --Gewitterwindgreifhandschuhe
            221034, --Donnerbeschlagene Beinschützer
            221035, --Treter des galvanischen Himmelsseglers
            219294  --Energiegeladene Sturmkrähenfeder
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Sturmwache Gorren
    bossLoot = {
        infoId = 2567,
        instanceId = instance.id,
        items = {
            221038, --Grollender Donnerhammer
            221039, --Zornbesetzter Sturmbogen
            221045, --Sturmbrecherbollwerk
            221041, --Rüstung des Blitzbrechers
            221040, --Blitzableiterbänder
            221042, --Kilt des Windreiters
            221043, --Sohlen des Wolkenwanderers
            219295  --Siegel der algarischen Einigkeit
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Voidstone Monstrosity
    bossLoot = {
        infoId = 2568,
        instanceId = instance.id,
        items = {
            221046, --Kniebrecherbehemoth
            221044, --Schattendolch des Kolosses
            221047, --Starren des Monstrums
            221048, --Amicia des Vergessens
            221049, --Wams des erweckten Steins
            221050, --Uralte gehärtete Beinwickel
            221197, --Reif des Verseuchten
            219296  --Entropischer Skardynkern
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)
end

function TwwS2:DarkflameCleft()
    local instance = addon.Items:RegisterInstance(2303, 8, bonusesTwwS2a)
    
    ----- Old Waxbeard
    local bossLoot = {
        infoId = 2569,
        instanceId = instance.id,
        items = {
            221096, --Rail Rider's Slicer
            221097, --Arcane Bucket
            221098, --Mole Knight's Soot Armor
            221099, --Wick's Golden Loop
            219304  --Wagon Driver's Wax Whistle
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Lohenzar
    bossLoot = {
        infoId = 2559,
        instanceId = instance.id,
        items = {
            221100, --Waxsteel Great Helm
            221103, --Flickering Light Collar
            221104, --Twilight Wax Bindings
            221102, --Shimmering Ember Claws
            221101, --Strongly Scented Candlewick
            219305  --Decorated Lohenzar Wax
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- The Candle King
    bossLoot = {
        infoId = 2560,
        instanceId = instance.id,
        items = {
            221105, --Darkzone Decapitator
            221109, --Candle Bearer's Veil
            221108, --King's Malicious Grips
            221107, --Twilight Keeper's Belt Buckle
            221106, --Dusk Stomper's Sabatons
            219306  --Candle King's Stylus
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- The Darkness
    bossLoot = {
        infoId = 2561,
        instanceId = instance.id,
        items = {
            225548, --Wick's Leash
            221111, --Poleaxe of Dark Fate
            221110, --Crepuscular Carver
            221113, --Twilight Visage
            221115, --Light-Shy Amice
            221112, --Dark Buckle Fists
            221114, --Shadow Brood Leggings
            219307  --Fragment of Darkness
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)
end

function TwwS2:CinderbrewMeadery()
    local instance = addon.Items:RegisterInstance(2335, 8, bonusesTwwS2a)
    
    ----- Brewmaster Aldryr
    local bossLoot = {
        infoId = 2586,
        instanceId = instance.id,
        items = {
            221051, --Shatterer of the Shaken
            221052, --Foam-Filled Pauldrons
            221054, --Chef Nager's Towel
            221053, --Battle-Marked Gauntlets
            219297  --Cinderbrew Mug
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- I'pa
    bossLoot = {
        infoId = 2587,
        instanceId = instance.id,
        items = {
            221057, --Sticky Stirring Rod
            221056, --Vessel of the Drink
            221055, --Cinderbrew-Soaked Cowl
            221060, --Rescue Barrel Collar
            221059, --I'pa's Pale Beer Guards
            221058, --Brewmaster's Belt
            221061  --Hop-Laden Great Boots
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Benk Buzzbrew
    bossLoot = {
        infoId = 2588,
        instanceId = instance.id,
        items = {
            221063, --Swarm Breaker's Ladle
            221062, --Treacherous Blade of the Seething Queen-maker
            221201, --Fireproof Ember Bee Perch
            221064, --Fluffy Ember Cuffs
            221067, --Punctured Beekeeper's Gloves
            221065, --Pollen Catcher's Treads
            219298  --Voracious Honey Buzzer
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Goldie Barontasch
    bossLoot = {
        infoId = 2589,
        instanceId = instance.id,
        items = {
            221068, --Profit Splitter
            221070, --"Azeroth's Best C.E.O" Cap
            221072, --Profitable Business Coat
            221069, --Cut-Resistant Business Breastplate
            221071, --Wearing Boot Straps
            221198, --Ring of 85 Years Service
            219299  --Synergetic Brewterializer
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)
end

function TwwS2:PrioryOfTheSacredFlame()
    local instance = addon.Items:RegisterInstance(2308, 8, bonusesTwwS2a)
    
    ----- Captain Screechwing
    local bossLoot = {
        infoId = 2571,
        instanceId = instance.id,
        items = {
            221116, --Poleaxe of the Glorious Defender
            221117, --Sanctified Priory Wall
            221118, --Flame-Forged Armguards
            221119, --Holy-Bound Hand Protection
            221121, --Honor-Bound Follower's Sash
            221120, --Boots of the Brave Guardian
            219308  --Seal of the Priory
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Baron Brownspray
    bossLoot = {
        infoId = 2570,
        instanceId = instance.id,
        items = {
            221122, --Hand of Beledar
            221125, --Helm of the Righteous Crusade
            221126, --Garments of the Fanatic Guardian
            221124, --Bindings of the Blessed Baron
            221123, --Devoted Plate Treads
            219309  --Tome of Light's Devotion
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Prioress Murrbet
    bossLoot = {
        infoId = 2573,
        instanceId = instance.id,
        items = {
            221127, --Emberfire Greatsword
            221128, --Star-Forged Seraph's Mace
            221131, --Elysian Flame Crown
            221203, --Pyre-Forged Shoulderpieces of the Reviver
            221130, --Seraphim Wraps of the Called
            221129, --Divine Pyre Treads
            221200, --Band of the Radiant Necromancer
            219310  --Exploding Light Shard
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)
end

function TwwS2:OperationFloodgate()
    local instance = addon.Items:RegisterInstance(2387, 8, bonusesTwwS2b)
    
    ----- Big M.O.M.M.A.
    local bossLoot = {
        infoId = 2648,
        instanceId = instance.id,
        items = {
            234491, --Ultrasonic BOOMerang
            234500, --Mechanized Scrap Pauldrons
            234503, --Hidden Projectiles of the Sky Stormer
            234497, --Non-Conductive Murder Socks
            232542  --Medi-Copter of the Void-Fused
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Demolition Duo
    bossLoot = {
        infoId = 2649,
        instanceId = instance.id,
        items = {
            234492, --Keeza's R.D.F.F.E.K.
            234498, --Waterworks Filtration Mask
            234502, --Bront's Singed Blast Coat
            234505, --Floodlight of the Venture Provider
            232541  --Improvised Zephyrium Pacemaker
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Swampface
    bossLoot = {
        infoId = 2650,
        instanceId = instance.id,
        items = {
            236768, --Crabboom
            234494, --Gallytech Turbo Pin
            234506, --Muck Diver's Plate Armor
            234499, --Disturbed Seaweed Wraps
            234495, --Blade Strangler's Pants
            232543  --Resonating Ritual Muck
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Giesel Gigashock
    bossLoot = {
        infoId = 2651,
        instanceId = instance.id,
        items = {
            234490, --Circuit Breaker
            234493, --Giesel's Manipulating Voltometer
            234507, --Electrician's Suction Filter
            234496, --Saboteur's Rubber Jacket
            234504, --Scaffold Scraper's Jump Start
            234501, --Portable Power Generator
            232545  --Gigashock's Shock Cap
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)
end

