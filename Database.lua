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
        killed = {
            -- [encounterId + "-" + difficultyId] = false,
        },
        savedInstances = {
            -- [1] = {
            --     ["id"] = 0,
            --     ["name"] = "",
            --     ["lockoutId"] = 0,
            --     ["reset"] = 0,
            --     ["difficultyId"] = 0,
            --     ["locked"] = false,
            --     ["extended"] = false,
            --     ["instanceIDMostSig"] = 0,
            --     ["isRaid"] = true,
            --     ["maxPlayers"] = 0,
            --     ["difficultyName"] = "",
            --     ["numEncounters"] = 0,
            --     ["encounterProgress"] = 0,
            --     ["extendDisabled"] = false,
            --     ["instanceId"] = 0,
            --     ["link"] = "",
            --     ["expires"] = 0,
            --     ["encounters"] = {
            --         [1] = {
            --             ["encounterId"] = 0,
            --             ["bossName"] = "",
            --             ["fileDataID"] = 0,
            --             ["killed"] = false
            --         }
            --     }
            -- }
        },
    },
    mythicplus = { -- Mythic Plus
        rating = 0,
        keystone = {
            dungeonId = 0,
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
            --     ["exampleRewardLink"] = ""
            --     ["exampleRewardUpgradeLink"] = ""
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
    [1208] = { id = 1208, order = 2, mapId = 2569, numEncounters = 9, encounters = {}, abbr = "ATSC", name = "Aberrus, the Shadowed Crucible" },
}

local dataRaidDifficulties = {
    [14] = { id = 14, color = RARE_BLUE_COLOR, order = 2, abbr = "NM", name = "Normal" },
    [15] = { id = 15, color = EPIC_PURPLE_COLOR, order = 3, abbr = "HC", name = "Heroic" },
    [16] = { id = 16, color = LEGENDARY_ORANGE_COLOR, order = 4, abbr = "M", name = "Mythic" },
    [17] = { id = 17, color = UNCOMMON_GREEN_COLOR, order = 1, abbr = "LFR", name = "Looking For Raid" },
}

function AlterEgo:GetCharacter(playerGUID)
    if playerGUID == nil then
        playerGUID = UnitGUID("player")
    end

    if self.db.global.characters[playerGUID] == nil then
        self.db.global.characters[playerGUID] = AE_table_copy(defaultCharacter)
    end

    self.db.global.characters[playerGUID].GUID = playerGUID

    return self.db.global.characters[playerGUID]
end

function AlterEgo:GetRaidDifficulties()
    local result = {}
    for _, difficulty in pairs(dataRaidDifficulties) do
        table.insert(result, difficulty)
    end

    table.sort(result, function (a, b)
        return a.order < b.order
    end)

    return result
end

function AlterEgo:GetAffixes()
    local result = {}
    for _, affix in pairs(dataAffixes) do
        table.insert(result, affix)
    end

    table.sort(result, function (a, b)
        return a.id < b.id
    end)

    return result
end

function AlterEgo:GetDungeons()
    local result = {}
    for _, dungeon in pairs(dataDungeons) do
        table.insert(result, dungeon)
    end

    table.sort(result, function (a, b)
        return a.name < b.name
    end)

    return result
end

function AlterEgo:GetRaids()
    local result = {}
    for _, raid in pairs(dataRaids) do
        table.insert(result, raid)
    end

    table.sort(result, function (a, b)
        return a.order < b.order
    end)

    return result
end

function AlterEgo:GetCharacters(unfiltered)
    local characters = {}
    for _, character in pairs(self.db.global.characters) do
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

function AlterEgo:UpdateDB()
    self:UpdateWeeklyReset()
    self:UpdateCharacterInfo()
    self:UpdateMythicPlus()
    self:UpdateRaidInstances()
end

function AlterEgo:UpdateWeeklyReset()
    local characters = self:GetCharacters()
    if self.db.global.weeklyReset ~= nil and self.db.global.weeklyReset <= time() then
        self:Print("Weekly Reset!")
        for _, character in ipairs(characters) do
            -- Todo: Run weekly task
        end
    end
    self.db.global.weeklyReset = time() + C_DateAndTime.GetSecondsUntilWeeklyReset()
end

function AlterEgo:UpdateGameData()
    for _, raid in pairs(dataRaids) do
        -- EncounterJournal Quirk: This has to be called first before we can get encounter journal info.
        EJ_SelectInstance(raid.id)
        raid.encounters = {}
        for e = 1, raid.numEncounters do
            local name, description, journalEncounterID, rootSectionID, link, journalInstanceID, dungeonEncounterID, instanceID = EJ_GetEncounterInfoByIndex(e, raid.id)
            local encounter = {
                ["name"] = name,
                ["description"] = description,
                ["journalEncounterID"] = journalEncounterID,
                ["rootSectionID"] = rootSectionID,
                ["link"] = link,
                ["journalInstanceID"] = journalInstanceID,
                ["dungeonEncounterID"] = dungeonEncounterID,
                ["instanceID"] = instanceID,
            }
            table.insert(raid.encounters, encounter)
        end
    end

    for _, dungeon in pairs(dataDungeons) do
        local dungeonName, _, dungeonTimeLimit, dungeonTexture = C_ChallengeMode.GetMapUIInfo(dungeon.id)
        dungeon.name = dungeonName
        dungeon.time = dungeonTimeLimit
        dungeon.texture = dungeon.texture ~= 0 and dungeonTexture or "Interface/Icons/achievement_bg_wineos_underxminutes"
    end

    for _, affix in pairs(dataAffixes) do
        local name, description = C_ChallengeMode.GetAffixInfo(affix.id);
        affix.name = name
        affix.description = description
    end
    self:UpdateDB()
end

function AlterEgo:UpdateRaidInstances()
    local character = self:GetCharacter()
    local raids = self:GetRaids();
    local numInstances = GetNumSavedInstances()
    -- if numInstances == nil then
    --     RequestRaidInfo()
    --     ---@diagnostic disable-next-line: undefined-field
    --     return self:ScheduleTimer("UpdateRaidInstances", 3)
    -- end

    -- Boss encounter: EJ_GetEncounterInfo(2522)

    character.raids.savedInstances = {}
    if numInstances > 0 then
        for instanceIndex = 1, numInstances do
            local name, lockoutId, reset, difficultyId, locked, extended, instanceIDMostSig, isRaid, maxPlayers, difficultyName, numEncounters, encounterProgress, extendDisabled, instanceId = GetSavedInstanceInfo(instanceIndex)
            local raid = AE_table_get(raids, "id", instanceId)
            local savedInstance = {
                ["id"] = lockoutId,
                ["name"] = name,
                ["lockoutId"] = lockoutId,
                ["reset"] = reset,
                ["difficultyId"] = difficultyId,
                ["locked"] = locked,
                ["extended"] = extended,
                ["instanceIDMostSig"] = instanceIDMostSig,
                ["isRaid"] = isRaid,
                ["maxPlayers"] = maxPlayers,
                ["difficultyName"] = difficultyName,
                ["numEncounters"] = numEncounters,
                ["encounterProgress"] = encounterProgress,
                ["extendDisabled"] = extendDisabled,
                ["instanceId"] = instanceId,
                ["link"] = GetSavedInstanceChatLink(instanceIndex),
                ["expires"] = 0,
                ["encounters"] = {}
            }
            if reset and reset > 0 then
                savedInstance.expires = reset + time()
            end
            for encounterIndex = 1, numEncounters do
                local bossName, fileDataID, killed = GetSavedInstanceEncounterInfo(instanceIndex, encounterIndex)
                local encounter = {
                    ["encounterIndex"] = encounterIndex,
                    ["id"] = raid and raid.encounters[encounterIndex].encounterId or 0,
                    ["bossName"] = bossName,
                    ["fileDataID"] = fileDataID or 0,
                    ["killed"] = killed
                }
                savedInstance.encounters[encounterIndex] = encounter
                if encounter.killed and encounter.id then
                    character.raids.killed[tostring(encounter.id) + "-" + difficultyId] = true
                end
            end
            character.raids.savedInstances[instanceIndex] = savedInstance
        end
    end
end

function AlterEgo:UpdateCharacterInfo()
    local character = self:GetCharacter()
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

    character.lastUpdate = GetServerTime()
    self:UpdateUI()
end

function AlterEgo:UpdateMythicPlus()
    local character = self:GetCharacter()
    local dungeons = self:GetDungeons()
    local ratingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary("player")

    if not ratingSummary then
        C_MythicPlus.RequestMapInfo()
        ---@diagnostic disable-next-line: undefined-field
        return self:ScheduleTimer("UpdateMythicPlus", 2)
    end

    local runHistory = C_MythicPlus.GetRunHistory(true, true)
    local bestSeasonScore, bestSeasonNumber = C_MythicPlus.GetSeasonBestMythicRatingFromThisExpansion()
    local weeklyRewardAvailable = C_MythicPlus.IsWeeklyRewardAvailable() -- Unused
    local HasAvailableRewards = C_WeeklyRewards.HasAvailableRewards() and C_WeeklyRewards.CanClaimRewards()

    if ratingSummary ~= nil and ratingSummary.currentSeasonScore ~= nil then character.mythicplus.rating = ratingSummary.currentSeasonScore end
    if runHistory ~= nil then character.mythicplus.runHistory = runHistory end
    if bestSeasonScore ~= nil then character.mythicplus.bestSeasonScore = bestSeasonScore end
    if bestSeasonNumber ~= nil then character.mythicplus.bestSeasonNumber = bestSeasonNumber end
    if weeklyRewardAvailable ~= nil then character.mythicplus.weeklyRewardAvailable = weeklyRewardAvailable end
    if HasAvailableRewards ~= nil then character.vault.hasAvailableRewards = HasAvailableRewards end

    -- Scan bags for keystone item
    do
        character.mythicplus.keystone = AE_table_copy(defaultCharacter.mythicplus.keystone)
        for bagId = 0, NUM_BAG_SLOTS do
            for slotId = 1, C_Container.GetContainerNumSlots(bagId) do
                local itemId = C_Container.GetContainerItemID(bagId, slotId)
                if itemId and itemId == 180653 then
                    local itemLink = C_Container.GetContainerItemLink(bagId, slotId)
                    local _, _, dungeonId, level = strsplit(':', itemLink)
                    local dungeon = AE_table_get(dungeons, "id", tonumber(dungeonId))
                    if dungeon then
                        character.mythicplus.keystone = {
                            ["dungeonId"] = tonumber(dungeon.id),
                            ["mapId"] = tonumber(dungeon.mapId),
                            ["level"] = tonumber(level),
                            ["color"] = C_ChallengeMode.GetKeystoneLevelRarityColor(level):GenerateHexColor(),
                            ["itemId"] = tonumber(itemId),
                            ["itemLink"] = itemLink,
                        }
                    end
                    break
                end
            end
        end
        local keyStoneMapID = C_MythicPlus.GetOwnedKeystoneMapID()
        local keyStoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()
        if keyStoneMapID ~= nil then character.mythicplus.keystone.mapId = tonumber(keyStoneMapID) end
        if keyStoneLevel ~= nil then character.mythicplus.keystone.level = tonumber(keyStoneLevel) end
    end

    -- Get vault info
    do
        wipe(character.vault.slots or {})
        for i = 1, 3 do
            local slots = C_WeeklyRewards.GetActivities(i)
            for _, slot in ipairs(slots) do
                slot.exampleRewardLink = ""
                slot.exampleRewardUpgradeLink = ""
                if slot.progress >= slot.threshold then
                    local itemLink, upgradeItemLink = C_WeeklyRewards.GetExampleRewardItemHyperlinks(slot.id)
                    slot.exampleRewardLink = itemLink
                    slot.exampleRewardUpgradeLink = upgradeItemLink
                end
                table.insert(character.vault.slots, slot)
            end
        end
    end

    -- Get dungeon data
    do
        wipe(character.mythicplus.dungeons or {})
        for _, dataDungeon in pairs(dataDungeons) do
            -- if dataDungeon.texture == nil then
            --     local dungeonName, _, dungeonTimeLimit, dungeonTexture = C_ChallengeMode.GetMapUIInfo(dataDungeon.id)
            --     dataDungeon.name = dungeonName
            --     dataDungeon.time = dungeonTimeLimit
            --     dataDungeon.texture = dungeonTexture
            -- end

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

            if ratingSummary ~= nil and ratingSummary.runs ~= nil then
                for _, run in ipairs(ratingSummary.runs) do
                    if run.challengeModeID == dataDungeon.id then
                        character.mythicplus.dungeons[dataDungeon.id].rating = run.mapScore
                        character.mythicplus.dungeons[dataDungeon.id].level = run.bestRunLevel
                        character.mythicplus.dungeons[dataDungeon.id].finishedSuccess = run.finishedSuccess
                    end
                end
            end
        end
    end

    -- local currentWeekBestLevel, weeklyRewardLevel, nextDifficultyWeeklyRewardLevel, nextBestLevel = C_MythicPlus.GetWeeklyChestRewardLevel()
    -- local rewardLevel = C_MythicPlus.GetRewardLevelFromKeystoneLevel(keyStoneLevel)

    character.lastUpdate = time()
    self:UpdateUI()
end

function AlterEgo:OnEncounterEnd(encounterID, encounterName, difficultyID, groupSize, success)
    local character = self:GetCharacter()
    if success then
        character.raids.killed[tostring(encounterID) + "-" + tostring(difficultyID)] = true
        RequestRaidInfo()
    end
end