---@diagnostic disable: inject-field
local defaultCharacter = {
    name = "",
    realm = "",
    level = 0,
    class = "",
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
    for charachterId, character in pairs(self.db.global.characters) do
        table.insert(characters, character)
    end

    -- Sorting
    -- TODO: Options
    table.sort(characters, function (a, b)
        return a.lastUpdate > b.lastUpdate
    end)

    -- Filters
    if not unfiltered then
        return characters
    end

    local charactersFiltered = {}
    for i, character in ipairs(unfiltered) do
        if character.level ~= nil and character.level == 70 then
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
    local _, playerClass = UnitClass("player")
    local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvp = GetAverageItemLevel()
    local itemLevelColorR, itemLevelColorG, itemLevelColorB = GetItemLevelColor()
    if playerName then character.name = playerName end
    if playerRealm then character.realm = playerRealm end
    if playerLevel then character.level = playerLevel end
    if playerClass then character.class = playerClass end
    if avgItemLevel then character.ilvl.level = avgItemLevel end
    if avgItemLevelEquipped then character.ilvl.equipped = avgItemLevelEquipped end
    if avgItemLevelPvp then character.ilvl.pvp = avgItemLevelPvp end
    if itemLevelColorR and itemLevelColorG and itemLevelColorB then
        character.ilvl.color = CreateColor(itemLevelColorR, itemLevelColorG, itemLevelColorB):GenerateHexColor()
    end

    character.lastUpdate = time()
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
    if weeklyRewardAvailable ~= nil then character.weeklyRewardAvailable = weeklyRewardAvailable end
    if ratingSummary ~= nil then character.ratingSummary = ratingSummary end
    if runHistory ~= nil then character.history = runHistory end
    if keyStoneMapID ~= nil then character.key.map = keyStoneMapID end
    if keyStoneLevel ~= nil then character.key.level = keyStoneLevel end
    if vault ~= nil then character.vault = vault end

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