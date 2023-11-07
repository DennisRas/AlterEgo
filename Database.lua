---@diagnostic disable: inject-field
local defaultCharacter = {
    GUID = "",
    lastUpdate = 0,
    enabled = true,
    info = {
        name = "",
        realm = "",
        level = 0,
        race = {
            name = "",
            file = "",
            id = 0
        },
        class = {
            name = "",
            file = "",
            id = 0
        },
        factionGroup = {
            english = "",
            localized = ""
        },
        ilvl = {
            level = 0,
            equipped = 0,
            pvp = 0,
            color = "ffffffff"
        },
    },
    raids = {
        savedInstances = {
            -- [1] = {
            --     ["id"] = lockoutId,
            --     ["name"] = name,
            --     ["lockoutId"] = lockoutId,
            --     ["reset"] = reset,
            --     ["expires"] = expires,
            --     ["difficultyId"] = difficultyId,
            --     ["locked"] = locked,
            --     ["instanceIDMostSig"] = instanceIDMostSig,
            --     ["isRaid"] = isRaid,
            --     ["maxPlayers"] = maxPlayers,
            --     ["difficultyName"] = difficultyName,
            --     ["numEncounters"] = numEncounters,
            --     ["encounterProgress"] = encounterProgress,
            --     ["extendDisabled"] = extendDisabled,
            --     ["instanceId"] = instanceId,
            --     link = GetSavedInstanceChatLink(i),
            --     ["encounters"] = encounters
            -- }
        },
    },
    mythicplus = { -- Mythic Plus
        rating = 0,
        keystone = {
            mapId = 0,
            level = 0,
            color = "",
            itemId = 0,
            itemLink = "",
        },
        weeklyRewardAvailable = false,
        bestSeasonScore = 0,
        bestSeasonNumber = 0,
        runHistory = {},
        dungeons = {
            -- [1] = {
            --     rating = 0,
            --     level = 0,
            --     finishedSuccess = false,
            --     bestTimedRun = {
            --         ["durationSec"] = 0,
            --         ["completionDate"] = {
            --             ["year"] = 0,
            --             ["month"] = 0,
            --             ["minute"] = 0,
            --             ["hour"] = 0,
            --             ["day"] = 0,
            --         },
            --         ["affixIDs"] = {
            --             0, 0, 0
            --         },
            --         ["level"] = 0,
            --         ["members"] = {
            --             {
            --                 ["specID"] = 0,
            --                 ["name"] = "",
            --                 ["classID"] = 0,
            --             }
            --         }
            --     },
            --     bestNotTimedRun = {},
            --     affixScores = {
            --         [1] = {
            --             ["name"] = "Tyrannical",
            --             ["overTime"] = false,
            --             ["level"] = 0,
            --             ["durationSec"] = 0,
            --             ["score"] = 0,
            --         },
            --         [2] = {
            --             ["name"] = "Fortified",
            --             ["overTime"] = false,
            --             ["level"] = 0,
            --             ["durationSec"] = 0,
            --             ["score"] = 0,
            --         },
            --     }
            -- }
        },
    },
    pvp = {},
    vault = {
        hasAvailableRewards = false,
        slots = {
            -- [1] = {
            --     ["threshold"] = 0,
            --     ["type"] = 0,
            --     ["index"] = 0,
            --     ["rewards"] = {},
            --     ["progress"] = 0,
            --     ["level"] = 0,
            --     ["raidString"] = "",
            --     ["id"] = 0,
            -- },
        }
    },
}

local dataAffixes = {
    [9] = { id = 9, name = "Tyrannical", icon = "Interface/Icons/achievement_boss_archaedas" },
    [10] = { id = 10, name = "Fortified", icon = "Interface/Icons/ability_toughness" },
}

local dataDungeons = {
    [206] = { id = 206, mapId = 1458, time = 0, abbr = "NL", name = "Neltharion's Lair" },
    [245] = { id = 245, mapId = 1754, time = 0, abbr = "FH", name = "Freehold" },
    [251] = { id = 251, mapId = 1841, time = 0, abbr = "UR", name = "The Underrot" },
    [403] = { id = 403, mapId = 2451, time = 0, abbr = "UL", name = "Uldaman: Legacy of Tyr" },
    [404] = { id = 404, mapId = 2519, time = 0, abbr = "NEL", name = "Neltharus" },
    [405] = { id = 405, mapId = 2520, time = 0, abbr = "BH", name = "Brackenhide Hollow" },
    [406] = { id = 406, mapId = 2527, time = 0, abbr = "HOI", name = "Halls of Infusion" },
    [438] = { id = 438, mapId = 657, time = 0, abbr = "VP", name = "The Vortex Pinnacle" },
}

local dataRaids = {
    -- [1200] = { id = 1200, order = 1, mapId = 2522, encounters = 8, abbr = "VOTI", name = "Vault of the Incarnates" },
    -- [1208] = { id = 1208, order = 2, mapId = 2569, encounters = 9, abbr = "ATSC", name = "Aberrus, the Shadowed Crucible" },
    -- [1207] = { id = 1208, order = 3, mapId = 2549, encounters = 9, abbr = "ATDH", name = "Amirdrassil, the Dream's Hope" },
    [1208] = { id = 1208, order = 2, mapId = 2569, numEncounters = 9, abbr = "ATSC", name = "Aberrus, the Shadowed Crucible" },
}

local dataRaidDifficulties = {
    [14] = { id = 14, color = RARE_BLUE_COLOR, order = 2, abbr = "NM", name = "Normal" },
    [15] = { id = 15, color = EPIC_PURPLE_COLOR, order = 3, abbr = "HC", name = "Heroic" },
    [16] = { id = 16, color = LEGENDARY_ORANGE_COLOR, order = 4, abbr = "M", name = "Mythic" },
    [17] = { id = 17, color = UNCOMMON_GREEN_COLOR, order = 1, abbr = "LFR", name = "Looking For Raid" },
}

function AlterEgo:GetRaidDifficulties()
    local result = {}
    for rd, difficulty in pairs(dataRaidDifficulties) do
        table.insert(result, difficulty)
    end

    table.sort(result, function (a, b)
        return a.order < b.order
    end)

    return result
end

function AlterEgo:GetAffixes()
    local result = {}
    for id, affix in pairs(dataAffixes) do
        if affix.description == nil then
            local name, description = C_ChallengeMode.GetAffixInfo(affix.id);
            affix.name = name
            affix.description = description
        end
        table.insert(result, affix)
    end

    table.sort(result, function (a, b)
        return a.id < b.id
    end)

    return result
end

function AlterEgo:GetDungeons()
    local result = {}
    for d, dungeon in pairs(dataDungeons) do
        table.insert(result, dungeon)
    end

    table.sort(result, function (a, b)
        return a.name < b.name
    end)

    return result
end

function AlterEgo:GetRaids()
    local result = {}
    for r, raid in pairs(dataRaids) do
        table.insert(result, raid)
    end

    table.sort(result, function (a, b)
        return a.order < b.order
    end)

    return result
end

function AlterEgo:GetCharacters(unfiltered)
    local characters = {}
    for characterGUID, character in pairs(self.db.global.characters) do
        character.GUID = characterGUID
        table.insert(characters, character)
    end

    -- Sorting
    table.sort(characters, function (a, b)
        if self.db.global.sorting == "name.asc" then
            return a.info.name < b.info.name
        elseif self.db.global.sorting == "name.desc" then
            return a.info.name > b.info.name
        elseif self.db.global.sorting == "realm.asc" then
            return a.info.realm < b.info.realm
        elseif self.db.global.sorting == "realm.desc" then
            return a.info.realm > b.info.realm
        elseif self.db.global.sorting == "rating.asc" then
            return a.mythicplus.rating < b.mythicplus.rating
        elseif self.db.global.sorting == "rating.desc" then
            return a.mythicplus.rating > b.mythicplus.rating
        elseif self.db.global.sorting == "ilvl.asc" then
            return a.info.ilvl.level < b.info.ilvl.level
        elseif self.db.global.sorting == "ilvl.desc" then
            return a.info.ilvl.level > b.info.ilvl.level
        end
        return a.lastUpdate > b.lastUpdate
    end)

    -- Filters
    if unfiltered then
        return characters
    end

    local charactersFiltered = {}
    for _, character in ipairs(characters) do
        local keep = true
        if character.info.level == nil or character.info.level < 70 then
            keep = false
        end
        if not character.enabled then
            keep = false
        end
        if self.db.global.showZeroRatedCharacters == false and (character.mythicplus.rating and character.mythicplus.rating <= 0) then
            keep = false
        end
        if keep then
            table.insert(charactersFiltered, character)
        end
    end

    return charactersFiltered
end

function AlterEgo:GetDungeonByMapId(mapId)
    for dungeonId, dungeon in pairs(dataDungeons) do
        if dungeon.mapId == mapId then
            return dungeon
        end
    end
    return nil
end

function AlterEgo:UpdateDB()
    self:UpdateCharacterInfo()
    self:UpdateMythicPlus()
    self:UpdateRaidInstances()
end

function AlterEgo:UpdateRaidInstances()
    local playerGUID = UnitGUID("player")
    if not playerGUID then
        return
    end

    if self.db.global.characters[playerGUID] == nil then
        self.db.global.characters[playerGUID] = defaultCharacter
    end

    local character = self.db.global.characters[playerGUID]
    local numInstances = GetNumSavedInstances()
    -- if numInstances == nil then
    --     RequestRaidInfo()
    --     ---@diagnostic disable-next-line: undefined-field
    --     return self:ScheduleTimer("UpdateRaidInstances", 3)
    -- end

    -- Boss encounter: EJ_GetEncounterInfo(2522)

    character.raids.savedInstances = {}
    if numInstances > 0 then 
        for i = 1, numInstances do
            local name, lockoutId, reset, difficultyId, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress, extendDisabled, instanceId = GetSavedInstanceInfo(i)
            local expires = 0
            if reset and reset > 0 then
                expires = reset + time()
            end
            local encounters = {}
            for e = 1, numEncounters do
                local bossName, fileDataID, killed = GetSavedInstanceEncounterInfo(i, e)
                encounters[e] = {
                    encounterId = e,
                    ["bossName"] = bossName,
                    ["fileDataID"] = fileDataID or 0,
                    ["killed"] = killed
                }
            end
            character.raids.savedInstances[i] = {
                ["id"] = lockoutId,
                ["name"] = name,
                ["lockoutId"] = lockoutId,
                ["reset"] = reset,
                ["expires"] = expires,
                ["difficultyId"] = difficultyId,
                ["locked"] = locked,
                ["instanceIDMostSig"] = instanceIDMostSig,
                ["isRaid"] = isRaid,
                ["maxPlayers"] = maxPlayers,
                ["difficultyName"] = difficultyName,
                ["numEncounters"] = numEncounters,
                ["encounterProgress"] = encounterProgress,
                ["extendDisabled"] = extendDisabled,
                ["instanceId"] = instanceId,
                link = GetSavedInstanceChatLink(i),
                ["encounters"] = encounters
            }
        end
    end
    -- DevTools_Dump(character.raids)
end

function AlterEgo:UpdateCharacterInfo()
    local playerGUID = UnitGUID("player")
    if not playerGUID then
        return
    end

    if self.db.global.characters[playerGUID] == nil then
        self.db.global.characters[playerGUID] = defaultCharacter
    end

    local character = self.db.global.characters[playerGUID]
    local playerName = UnitName("player")
    local playerRealm = GetRealmName()
    local playerLevel = UnitLevel("player")
    local playerRaceName, playerRaceFile, playerRaceID = UnitRace("player")
    local playerClassName, playerClassFile, playerClassID = UnitClass("player")
    local playerFactionGroupEnglish, playerFactionGroupLocalized = UnitFactionGroup("player")
    local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvp = GetAverageItemLevel()
    local itemLevelColorR, itemLevelColorG, itemLevelColorB = GetItemLevelColor()
    if playerName then character.info.name = playerName end
    if playerRealm then character.info.realm = playerRealm end
    if playerLevel then character.info.level = playerLevel end
    if type(character.info.race) ~= "table" then character.info.race = defaultCharacter.info.race end
    if playerRaceName then character.info.race.name = playerRaceName end
    if playerRaceFile then character.info.race.file = playerRaceFile end
    if playerRaceID then character.info.race.id = playerRaceID end
    if type(character.info.class) ~= "table" then character.info.class = defaultCharacter.info.class end
    if playerClassName then character.info.class.name = playerClassName end
    if playerClassFile then character.info.class.file = playerClassFile end
    if playerClassID then character.info.class.id = playerClassID end
    if type(character.info.factionGroup) ~= "table" then character.info.factionGroup = defaultCharacter.info.factionGroup end
    if playerFactionGroupEnglish then character.info.factionGroup.english = playerFactionGroupEnglish end
    if playerFactionGroupLocalized then character.info.factionGroup.localized = playerFactionGroupLocalized end
    if avgItemLevel then character.info.ilvl.level = avgItemLevel end
    if avgItemLevelEquipped then character.info.ilvl.equipped = avgItemLevelEquipped end
    if avgItemLevelPvp then character.info.ilvl.pvp = avgItemLevelPvp end
    if itemLevelColorR and itemLevelColorG and itemLevelColorB then
        character.info.ilvl.color = CreateColor(itemLevelColorR, itemLevelColorG, itemLevelColorB):GenerateHexColor()
    end

    character.GUID = playerGUID
    character.lastUpdate = GetServerTime()
    self:UpdateUI()
end

function AlterEgo:UpdateMythicPlus()
    local playerGUID = UnitGUID("player")
    if not playerGUID then
        return
    end

    if self.db.global.characters[playerGUID] == nil then
        self.db.global.characters[playerGUID] = defaultCharacter
    end

    -- local currentWeekBestLevel, weeklyRewardLevel, nextDifficultyWeeklyRewardLevel, nextBestLevel = C_MythicPlus.GetWeeklyChestRewardLevel()
    -- local rewardLevel = C_MythicPlus.GetRewardLevelFromKeystoneLevel(keyStoneLevel)

    local character = self.db.global.characters[playerGUID]
    local ratingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary("player")
    if not ratingSummary then
        C_MythicPlus.RequestMapInfo()
        ---@diagnostic disable-next-line: undefined-field
        return self:ScheduleTimer("UpdateMythicPlus", 2)
    end

    local runHistory = C_MythicPlus.GetRunHistory(true, true)
    local bestSeasonScore, bestSeasonNumber = C_MythicPlus.GetSeasonBestMythicRatingFromThisExpansion()
    if ratingSummary ~= nil then character.mythicplus.rating = ratingSummary.currentSeasonScore end
    if runHistory ~= nil then character.mythicplus.runHistory = runHistory end
    if bestSeasonScore ~= nil then character.mythicplus.bestSeasonScore = bestSeasonScore end
    if bestSeasonNumber ~= nil then character.mythicplus.bestSeasonNumber = bestSeasonNumber end

    local weeklyRewardAvailable = C_MythicPlus.IsWeeklyRewardAvailable() -- Unused
    local HasAvailableRewards = C_WeeklyRewards.HasAvailableRewards() and C_WeeklyRewards.CanClaimRewards()
    if weeklyRewardAvailable ~= nil then character.mythicplus.weeklyRewardAvailable = weeklyRewardAvailable end
    if HasAvailableRewards ~= nil then character.vault.hasAvailableRewards = HasAvailableRewards end

    -- Scan bags for keystone item
    character.mythicplus.keystone = defaultCharacter.mythicplus.keystone
    for bagId = 0, NUM_BAG_SLOTS do
        for slotId = 1, C_Container.GetContainerNumSlots(bagId) do
            local itemId = C_Container.GetContainerItemID(bagId, slotId)
            if itemId and itemId == 180653 then
                local itemLink = C_Container.GetContainerItemLink(bagId, slotId)
                local _, _, mapId, level = strsplit(':', itemLink)
                character.mythicplus.keystone = {
                    ["mapId"] = mapId,
                    ["level"] = tonumber(level),
                    ["color"] = C_ChallengeMode.GetKeystoneLevelRarityColor(level):GenerateHexColor(),
                    ["itemId"] = itemId,
                    ["itemLink"] = itemLink,
                }
                break
            end
        end
    end
    if not character.mythicplus.keystone.mapId then
        local keyStoneMapID = C_MythicPlus.GetOwnedKeystoneMapID()
        local keyStoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()
        if keyStoneMapID ~= nil then character.mythicplus.keystone.mapId = keyStoneMapID end
        if keyStoneLevel ~= nil then character.mythicplus.keystone.level = keyStoneLevel end
    end

    if character.vault == nil then
        character.vault = {
            hasAvailableRewards = false,
            slots = {}
        }
    end

    character.vault.slots = {}
    for i = 1, 3 do
        local slots = C_WeeklyRewards.GetActivities(i)
        for _, slot in ipairs(slots) do
            table.insert(character.vault.slots, slot)
        end
    end

    character.mythicplus.dungeons = {}
    for _, dataDungeon in pairs(dataDungeons) do
        if dataDungeon.texture == nil then
            local dungeonName, _, dungeonTimeLimit, dungeonTexture = C_ChallengeMode.GetMapUIInfo(dataDungeon.id)
            dataDungeon.name = dungeonName
            dataDungeon.time = dungeonTimeLimit
            dataDungeon.texture = dungeonTexture
        end

        if character.mythicplus.dungeons[dataDungeon.id] == nil then
            character.mythicplus.dungeons[dataDungeon.id] = {
                id = dataDungeon.id,
                bestTimedRun = {},
                bestNotTimedRun = {},
                affixScores = {},
                rating = 0,
                level = 0,
                finishedSuccess = false,
            }
        end

        local bestTimedRun, bestNotTimedRun = C_MythicPlus.GetSeasonBestForMap(dataDungeon.id);
        local affixScores, bestOverAllScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(dataDungeon.id)
        if bestTimedRun ~= nil then character.mythicplus.dungeons[dataDungeon.id].bestTimedRun = bestTimedRun end
        if bestNotTimedRun ~= nil then character.mythicplus.dungeons[dataDungeon.id].bestNotTimedRun = bestNotTimedRun end
        if affixScores ~= nil then character.mythicplus.dungeons[dataDungeon.id].affixScores = affixScores end
        -- if bestOverAllScore ~= nil then character.mythicplus.dungeons[dungeon.id].bestOverAllScore = bestOverAllScore end
    end

    if ratingSummary ~= nil and ratingSummary.runs ~= nil then
        for _, run in ipairs(ratingSummary.runs) do
            character.mythicplus.dungeons[run.challengeModeID].rating = run.mapScore
            character.mythicplus.dungeons[run.challengeModeID].level = run.bestRunLevel
            character.mythicplus.dungeons[run.challengeModeID].finishedSuccess = run.finishedSuccess
        end
    end

    character.lastUpdate = time()
    self:UpdateUI()
end