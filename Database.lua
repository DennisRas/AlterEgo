---@diagnostic disable: inject-field
local defaultCharacter = {
    name = "-",
    realm = "-",
    class = "",
    itemLevel = 0,
    itemLevelColor = "ffffffff",
    vault = {},
    key = { map = 0, level = 0 },
    dungeons = {}
}

local affixes = {
    { id = 9, name = "Tyrannical", icon = "Interface/Icons/achievement_boss_archaedas" },
    { id = 10, name = "Fortified", icon = "Interface/Icons/ability_toughness" },
}
local dungeons = {
    { id = 206, mapId = 1458, time = 0, abbr = "NL", name = "Neltharion's Lair" },
    { id = 245, mapId = 1754, time = 0, abbr = "FH", name = "Freehold" },
    { id = 251, mapId = 1841, time = 0, abbr = "UR", name = "The Underrot" },
    { id = 403, mapId = 2451, time = 0, abbr = "UL", name = "Uldaman: Legacy of Tyr" },
    { id = 404, mapId = 2519, time = 0, abbr = "NEL", name = "Neltharus" },
    { id = 405, mapId = 2520, time = 0, abbr = "BH", name = "Brackenhide Hollow" },
    { id = 406, mapId = 2527, time = 0, abbr = "HOI", name = "Halls of Infusion" },
    { id = 438, mapId = 657, time = 0, abbr = "VP", name = "The Vortex Pinnacle" },
}

function AlterEgo:GetAffixes()
    -- Sorting?
    return affixes
end

function AlterEgo:GetCharacters()
    local characters = self.db.global.characters
    local result = {}

    -- Temp fix
    for i, character in pairs(characters) do
        table.insert(result, character)
    end

    -- Filters
    -- Sorting

    return result
end

function AlterEgo:GetDungeons()
    -- Sorting?
    return dungeons
end

function AlterEgo:GetDungeonByMapId(mapId)
    local dungeons = self:GetDungeons()
    for i, dungeon in ipairs(dungeons) do
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

    local playerName = UnitName("player")
    if playerName then
        self.db.global.characters[playerGUID].name = playerName
    end

    local playerRealm = GetRealmName()
    if playerRealm then
        self.db.global.characters[playerGUID].realm = playerRealm
    end

    local _, playerClass = UnitClass("player")
    if playerClass then
        self.db.global.characters[playerGUID].class = playerClass
    end

    local _, avgItemLevelEquipped = GetAverageItemLevel()
    if avgItemLevelEquipped then
        self.db.global.characters[playerGUID].itemLevel = avgItemLevelEquipped
    end

    local itemLevelColorR, itemLevelColorG, itemLevelColorB = GetItemLevelColor()
    if itemLevelColorR and itemLevelColorG and itemLevelColorB then
        self.db.global.characters[playerGUID].itemLevelColor = CreateColor(itemLevelColorR, itemLevelColorG, itemLevelColorB):GenerateHexColor()
    end
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
    -- local weeklyRewardAvailable = C_MythicPlus.IsWeeklyRewardAvailable()
    -- local history = C_MythicPlus.GetRunHistory(true)
    -- C_ChallengeMode.GetMapUIInfo(2527)

    local ratingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary("player")
    if ratingSummary then
        self.db.global.characters[playerGUID].rating = ratingSummary.currentSeasonScore
    else
        C_MythicPlus.RequestMapInfo()
        return self:ScheduleTimer("UpdateMythicPlus", 1)
    end

    local keyStoneMapID = C_MythicPlus.GetOwnedKeystoneMapID()
    if keyStoneMapID then
        self.db.global.characters[playerGUID].key.map = keyStoneMapID
    end

    local keyStoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()
    if keyStoneLevel then
        self.db.global.characters[playerGUID].key.level = keyStoneLevel
    end

    local dungeons = self:GetDungeons()
    for i, dungeon in pairs(dungeons) do
        local _, __, time = C_ChallengeMode.GetMapUIInfo(dungeon.id)
        dungeons[i].time = time

        if self.db.global.characters[playerGUID].dungeons[dungeon.id] == nil then
            self.db.global.characters[playerGUID].dungeons[dungeon.id] = {
                ["Fortified"] = {},
                ["Tyrannical"] = {},
            }
        end

        local affixScores = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(dungeon.id)
        if affixScores ~= nil then
            local fortified = 0
            local tyrannical = 0
            for _, affixScore in pairs(affixScores) do
                self.db.global.characters[playerGUID].dungeons[dungeon.id][affixScore.name] = affixScore
            end
        else
            self.db.global.characters[playerGUID].dungeons[dungeon.id] = {
                ["Fortified"] = {},
                ["Tyrannical"] = {},
            }
        end
    end

    local activities = C_WeeklyRewards.GetActivities(1)
    for _, activity in pairs(activities) do
        self.db.global.characters[playerGUID].vault[activity.index] = activity.level
    end
    self:UpdateUI()
end