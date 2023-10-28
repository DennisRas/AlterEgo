---@diagnostic disable: inject-field
local defaultCharacter = {
    name = "",
    realm = "",
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
    -- Sorting?
    return dataAffixes
end

function AlterEgo:GetDungeons()
    -- Sorting?
    return dataDungeons
end

function AlterEgo:GetCharacters(unfiltered)
    local characters = self.db.global.characters
    local result = {}

    -- Sorting

    -- Filters
    if not unfiltered then
        return characters
    end

    return characters
end

function AlterEgo:GetDungeonByMapId(mapId)
    local dungeons = self:GetDungeons()
    for dungeonId, dungeon in pairs(dungeons) do
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
    local _, playerClass = UnitClass("player")
    local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvp = GetAverageItemLevel()
    local itemLevelColorR, itemLevelColorG, itemLevelColorB = GetItemLevelColor()
    if playerName then character.name = playerName end
    if playerRealm then character.realm = playerRealm end
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

    local dungeons = self:GetDungeons()
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

    for i, dungeon in pairs(dungeons) do
        if dungeons[i].texture == nil then
            local dungeonName, dungeonId, dungeonTimeLimit, dungeonTexture = C_ChallengeMode.GetMapUIInfo(dungeon.id)
            dungeons[i].name = dungeonName
            dungeons[i].time = dungeonTimeLimit
            dungeons[i].texture = dungeonTexture
        end

        if character.bestDungeons == nil then
            character.bestDungeons = {}
        end

        if character.bestDungeons[dungeon.id] == nil then
            character.bestDungeons[dungeon.id] = {}
        end

        local affixScores = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(dungeon.id)
        if affixScores ~= nil then
            character.bestDungeons[dungeon.id] = affixScores
        end
    end

    character.lastUpdate = time()
    self:UpdateUI()
end