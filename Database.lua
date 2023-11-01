---@diagnostic disable: inject-field
local defaultCharacter = {
    GUID = "",
    enabled = true,
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
    vault = {},
    key = {  map = 0, level = 0 },
    ratingSummary = {
        runs = {},
        currentSeasonScore = 0
    },
    history = {},
    bestDungeons = {},
    lastUpdate = 0
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

function AlterEgo:GetCharacters(unfiltered)
    local characters = {}
    for characterGUID, character in pairs(self.db.global.characters) do
        character.GUID = characterGUID
        table.insert(characters, character)
    end

    -- Sorting
    table.sort(characters, function (a, b)
        if self.db.global.sorting == "name.asc" then
            return a.name < b.name
        elseif self.db.global.sorting == "name.desc" then
            return a.name > b.name
        elseif self.db.global.sorting == "realm.asc" then
            return a.realm < b.realm
        elseif self.db.global.sorting == "realm.desc" then
            return a.realm > b.realm
        elseif self.db.global.sorting == "rating.asc" then
            return a.ratingSummary.currentSeasonScore < b.ratingSummary.currentSeasonScore
        elseif self.db.global.sorting == "rating.desc" then
            return a.ratingSummary.currentSeasonScore > b.ratingSummary.currentSeasonScore
        elseif self.db.global.sorting == "ilvl.asc" then
            return a.ilvl.level < b.ilvl.level
        elseif self.db.global.sorting == "ilvl.desc" then
            return a.ilvl.level > b.ilvl.level
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
        if character.level == nil or character.level < 70 then
            keep = false
        end
        if not character.enabled then
            keep = false
        end
        if self.db.global.showZeroRatedCharacters == false and (character.ratingSummary and character.ratingSummary.currentSeasonScore <= 0) then
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
    if playerName then character.name = playerName end
    if playerRealm then character.realm = playerRealm end
    if playerLevel then character.level = playerLevel end
    if type(character.race) ~= "table" then character.race = defaultCharacter.race end
    if playerRaceName then character.race.name = playerRaceName end
    if playerRaceFile then character.race.file = playerRaceFile end
    if playerRaceID then character.race.id = playerRaceID end
    if type(character.class) ~= "table" then character.class = defaultCharacter.class end
    if playerClassName then character.class.name = playerClassName end
    if playerClassFile then character.class.file = playerClassFile end
    if playerClassID then character.class.id = playerClassID end
    if type(character.factionGroup) ~= "table" then character.factionGroup = defaultCharacter.factionGroup end
    if playerFactionGroupEnglish then character.factionGroup.english = playerFactionGroupEnglish end
    if playerFactionGroupLocalized then character.factionGroup.localized = playerFactionGroupLocalized end
    if avgItemLevel then character.ilvl.level = avgItemLevel end
    if avgItemLevelEquipped then character.ilvl.equipped = avgItemLevelEquipped end
    if avgItemLevelPvp then character.ilvl.pvp = avgItemLevelPvp end
    if itemLevelColorR and itemLevelColorG and itemLevelColorB then
        character.ilvl.color = CreateColor(itemLevelColorR, itemLevelColorG, itemLevelColorB):GenerateHexColor()
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

    local weeklyRewardAvailable = C_MythicPlus.IsWeeklyRewardAvailable()
    local runHistory = C_MythicPlus.GetRunHistory(true, true)
    local keyStoneMapID = C_MythicPlus.GetOwnedKeystoneMapID()
    local keyStoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()
    local vault = C_WeeklyRewards.GetActivities(1)
    local bestSeasonScore, bestSeasonNumber = C_MythicPlus.GetSeasonBestMythicRatingFromThisExpansion(); 
    if weeklyRewardAvailable ~= nil then character.weeklyRewardAvailable = weeklyRewardAvailable end
    if ratingSummary ~= nil then character.ratingSummary = ratingSummary end
    if runHistory ~= nil then character.history = runHistory end
    if keyStoneMapID ~= nil then character.key.map = keyStoneMapID end
    if keyStoneLevel ~= nil then character.key.level = keyStoneLevel end
    if vault ~= nil then character.vault = vault end
    if bestSeasonScore ~= nil then character.bestSeasonScore = bestSeasonScore end
    if bestSeasonNumber ~= nil then character.bestSeasonNumber = bestSeasonNumber end

    for dungeonId, dungeon in pairs(dataDungeons) do
        if dungeon.texture == nil then
            local dungeonName, _, dungeonTimeLimit, dungeonTexture = C_ChallengeMode.GetMapUIInfo(dungeon.id)
            dungeon.name = dungeonName
            dungeon.time = dungeonTimeLimit
            dungeon.texture = dungeonTexture
        end

        if character.bestDungeons == nil then
            character.bestDungeons = {}
        end

        if character.bestDungeons[dungeon.id] == nil then
            character.bestDungeons[dungeon.id] = {
                bestTimed = {},
                bestNotTimed = {},
                affixScores = {},
                bestOverAllScore = 0
            }
        end

        local bestTimed, bestNotTimed = C_MythicPlus.GetSeasonBestForMap(dungeon.id);
        local affixScores, bestOverAllScore = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(dungeon.id)
        if bestTimed ~= nil then character.bestDungeons[dungeon.id].bestTimed = bestTimed end
        if bestNotTimed ~= nil then character.bestDungeons[dungeon.id].bestNotTimed = bestNotTimed end
        if affixScores ~= nil then character.bestDungeons[dungeon.id].affixScores = affixScores end
        if bestOverAllScore ~= nil then character.bestDungeons[dungeon.id].bestOverAllScore = bestOverAllScore end
    end

    character.lastUpdate = time()
    self:UpdateUI()
end