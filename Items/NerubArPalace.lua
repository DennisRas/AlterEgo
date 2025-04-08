local NerubArPalace = LibStub("AceAddon-3.0"):GetAddon("AlterEgo"):NewModule("NerubArPalace")
local tocVersion = select(1, GetBuildInfo())

if tocVersion <= "11.0.2" then
    return
end

---@class AE_Addon
local addon = select(2, ...)


print("Loading NerubArPalace")

function NerubArPalace:OnEnable()
    print("NerubArPalace:OnEnable")
    local instance = addon.Items:RegisterInstance(2292, 6, {3524})
    ----- Ulgrax the Devourer
    local bossLoot = {
        infoId = 2607,
        instanceId = instance.id,
        items = {
            212388, --Ulgrax's Morsel-Masher
            212409, --Venom-Etched Claw
            212386, --Husk of Swallowing Darkness
            212428, --Final Meal's Horns
            212424, --Seasoned Earthen Boulderplates
            212446, --Royal Emblem of Nerub-ar
            212419, --Bile-Soaked Harness
            212426, --Crunchy Intruder's Wristband
            212425, --Devourer's Taut Innards
            212442, --Greatbelt of the Hungerer
            212423, --Rebel's Drained Marrowslacks
            212431, --Undermoth-Lined Footpads
            219915  --Foul Behemoth's Chelicera
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- The Bloodbound Horror
    bossLoot = {
        infoId = 2611,
        instanceId = instance.id,
        items = {
            212395, --Blood-Kissed Kukri
            212404, --Scepter of Manifested Miasma
            212417, --Beyond's Dark Visage
            212439, --Beacons of the False Dawn
            212421, --Goresplattered Membrane
            212438, --Polluted Spectre's Wraps
            212414, --Lost Watcher's Remains
            212430, --Shattered Eye Cincture
            212422, --Bloodbound Horror's Legplates
            225590, --Boots of the Black Bulwark
            212447, --Key to the Unseeming
            212451, --Aberrant Spellforge
            219917  --Creeping Coagulum
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Sikran, Captain of the Sureki
    bossLoot = {
        infoId = 2599,
        instanceId = instance.id,
        items = {
            225618, --Dreadful Stalwart's Emblem
            225619, --Mystic Stalwart's Emblem
            223097, --Pattern: Adrenal Surge Clasp
            225620, --Venerated Stalwart's Emblem
            225621, --Zenith Stalwart's Emblem
            212413, --Honored Executioner's Perforator
            212392, --Duelist's Dancing Steel
            212405, --Flawless Phase Blade
            212399, --Splintershot Silkbow
            212427, --Visor of the Ascended Captain
            225577, --Sureki Zealot's Insignia
            212415, --Throne Defender's Bangles
            212445, --Chitin-Spiked Jackboots
            212416, --Cosmic-Tinged Treads
            212449, --Sikran's Endless Arsenal
            -- Tier Set Hands
            211985, --Warrior Hands
            211994, --Paladin Hands
            212003, --Death Knight Hands
            212012, --Shaman Hands
            212021, --Hunter Hands
            212030, --Evoker Hands
            212039, --Rogue Hands
            212048, --Monk Hands
            212057, --Druid Hands
            212066, --Demon Hunter Hands
            212075, --Warlock Hands
            212084, --Priest Hands
            212093  --Mage Hands
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Rasha'nan
    bossLoot = {
        infoId = 2609,
        instanceId = instance.id,
        items = {
            225630, --Dreadful Obscenity's Idol
            225631, --Mystic Obscenity's Idol
            224435, --Pattern: Duskthread Lining
            225632, --Venerated Obscenity's Idol
            225633, --Zenith Obscenity's Idol
            212398, --Bludgeons of Blistering Wind
            212391, --Predator's Feasthooks
            212440, --Devotee's Discarded Headdress
            212448, --Locket of Broken Memories
            225574, --Wings of Shattered Sorrow
            212437, --Ravaged Lamplighter's Manacles
            225583, --Behemoth's Eroded Cinch
            225586, --Rasha'nan's Grotesque Talons
            212453, --Skyterror's Corrosive Organ
            -- Tier Set Shoulder
            211982, --Warrior Shoulder
            211991, --Paladin Shoulder
            212000, --Death Knight Shoulder
            212009, --Shaman Shoulder
            212018, --Hunter Shoulder
            212027, --Evoker Shoulder
            212036, --Rogue Shoulder
            212045, --Monk Shoulder
            212054, --Druid Shoulder
            212063, --Demon Hunter Shoulder
            212072, --Warlock Shoulder
            212081, --Priest Shoulder
            212090  --Mage Shoulder
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Broodtwister Ovi'nax
    bossLoot = {
        infoId = 2612,
        instanceId = instance.id,
        items = {
            225614, --Dreadful Blasphemer's Effigy
            225615, --Mystic Blasphemer's Effigy
            226190, --Recipe: Sticky Sweet Treat
            225616, --Venerated Blasphemer's Effigy
            225617, --Zenith Blasphemer's Effigy
            212389, --Spire of Transfused Horrors
            212387, --Broodtwister's Grim Catalyst
            225588, --Sanguine Experiment's Bandages
            212418, --Black Blood Injectors
            225580, --Accelerated Ascension Coil
            225582, --Assimilated Eggshell Slippers
            225576, --Writhing Ringworm
            212452, --Gruesome Syringe
            220305, --Ovi'nax's Mercurial Egg
            -- Tier Set Chest
            211987, --Warrior Chest
            211996, --Paladin Chest
            212005, --Death Knight Chest
            212014, --Shaman Chest
            212023, --Hunter Chest
            212032, --Evoker Chest
            212041, --Rogue Chest
            212050, --Monk Chest
            212059, --Druid Chest
            212068, --Demon Hunter Chest
            212077, --Warlock Chest
            212086, --Priest Chest
            212095  --Mage Chest
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Nexus-Princess Ky'veza
    bossLoot = {
        infoId = 2601,
        instanceId = instance.id,
        items = {
            225626, --Dreadful Slayer's Icon
            225627, --Mystic Slayer's Icon
            223048, --Plans: Siphoning Stiletto
            225628, --Venerated Slayer's Icon
            225629, --Zenith Slayer's Icon
            225636, --Regicide
            219877, --Void Reaper's Warp Blade
            212400, --Shade-Touched Silencer
            225581, --Ky'veza's Covert Clasps
            212441, --Bindings of the Starless Night
            225589, --Nether Bounty's Greatbelt
            225591, --Fleeting Massacre Footpads
            221023, --Treacherous Transmitter
            212456, --Void Reaper's Contract
            -- Tier Set Legs
            211983, --Warrior Legs
            211992, --Paladin Legs
            212001, --Death Knight Legs
            212010, --Shaman Legs
            212019, --Hunter Legs
            212028, --Evoker Legs
            212037, --Rogue Legs
            212046, --Monk Legs
            212055, --Druid Legs
            212064, --Demon Hunter Legs
            212073, --Warlock Legs
            212082, --Priest Legs
            212091  --Mage Legs
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- The Silken Court
    bossLoot = {
        infoId = 2608,
        instanceId = instance.id,
        items = {
            223094, --Design: Magnificent Jeweler's Setting
            225622, --Dreadful Conniver's Badge
            225623, --Mystic Conniver's Badge
            225624, --Venerated Conniver's Badge
            225625, --Zenith Conniver's Badge
            212407, --Anub'arash's Colossal Mandible
            212397, --Takazj's Entropic Edict
            225575, --Silken Advisor's Favor
            212429, --Whispering Voidlight Spaulders
            225584, --Skeinspinner's Duplicitous Cuffs
            212432, --Thousand-Scar Impalers
            212443, --Shattershell Greaves
            220202, --Spymaster's Web
            212450  --Swarmlord's Authority
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

    ----- Queen Ansurek
    bossLoot = {
        infoId = 2602,
        instanceId = instance.id,
        items = {
            223144, --Formula: Enchant Weapon - Authority of the Depths
            224151, --Reins of the Ascendant Skyrazor
            224147, --Reins of the Sureki Skyrazor
            225634, --Web-Wrapped Curio
            212401, --Ansurek's Final Judgment
            212394, --Sovereign's Disdain
            225579, --Crest of the Caustic Despot
            212444, --Frame of Felled Insurgents
            212433, --Omnivore's Venomous Camouflage
            212420, --Queensguard Carapace
            225587, --Devoted Offering's Irons
            212436, --Clutches of Paranoia
            225585, --Acrid Ascendant's Sash
            212435, --Liquified Defector's Leggings
            212434, --Voidspoken Sarong
            225578, --Seal of the Poisoned Pact
            212454, --Mad Queen's Mandate
            -- Tier Set Head
            211984, --Warrior Head
            211993, --Paladin Head
            212002, --Death Knight Head
            212011, --Shaman Head
            212020, --Hunter Head
            212029, --Evoker Head
            212038, --Rogue Head
            212047, --Monk Head
            212056, --Druid Head
            212065, --Demon Hunter Head
            212074, --Warlock Head
            212083, --Priest Head
            212092  --Mage Head
        }
    };
    addon.Items:RegisterBossLoots(bossLoot)

end
