---@diagnostic disable: undefined-field, inject-field, duplicate-set-field
AlterEgo = LibStub("AceAddon-3.0"):NewAddon("AlterEgo", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0", "AceBucket-3.0")
AlterEgo.constants = {
    sizes = {
        padding = 4,
        row = 22,
        column = 120,
        border = {
            width = 3
        },
        titlebar = {
            height = 30
        },
        sidebar = {
            width = 140,
            collapsedWidth = 30
        }
    },
    colors = {
        primary = CreateColorFromHexString("FF21232C"),
    },
    defaultDB = {
        global = {
            characters = {},
        },
        profile = {
            settings = {}
        }
    },
    defaultCharacter = {
        name = "-",
        realm = "-",
        class = "",
        itemLevel = 0,
        itemLevelColor = "ffffffff",
        vault = {},
        key = {
            map = 0,
            level = 0
        },
        dungeons = {}
    },
    options = {
        name = "AlterEgo",
        handler = AlterEgo,
        type = "group",
        args = {}
    },
    dungeons = {
        [1] = {
            id = 206,
            mapId = 1458,
            name = "Neltharion's Lair",
            abbr = "NL",
            time = 0
        },
        [2] = {
            id = 245,
            mapId = 1754,
            name = "Freehold",
            abbr = "FH",
            time = 0
        },
        [3] = {
            id = 251,
            mapId = 1841,
            name = "The Underrot",
            abbr = "UR",
            time = 0
        },
        [4] = {
            id = 403,
            mapId = 2451,
            name = "Uldaman: Legacy of Tyr",
            abbr = "UL",
            time = 0
        },
        [5] = {
            id = 404,
            mapId = 2519,
            name = "Neltharus",
            abbr = "NEL",
            time = 0
        },
        [6] = {
            id = 405,
            mapId = 2520,
            name = "Brackenhide Hollow",
            abbr = "BH",
            time = 0
        },
        [7] = {
            id = 406,
            mapId = 2527,
            name = "Halls of Infusion",
            abbr = "HOI",
            time = 0
        },
        [8] = {
            id = 438,
            mapId = 657,
            name = "The Vortex Pinnacle",
            abbr = "VP",
            time = 0
        },
    },
}

function AlterEgo:GetDungeonByMapId(mapId)
    for i, dungeon in ipairs(self.constants.dungeons) do
        if dungeon.mapId == mapId then
            return dungeon
        end
    end
    return nil
end

function AlterEgo:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("AlterEgoDB", self.constants.defaultDB)
    self:RegisterChatCommand("alterego", "OnSlashCommand")
    self:RegisterChatCommand("ae", "OnSlashCommand")
    self:RegisterBucketEvent({"BAG_UPDATE_DELAYED", "PLAYER_EQUIPMENT_CHANGED", "UNIT_INVENTORY_CHANGED"}, 10, "UpdateCharacter")
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED", "UpdateMythicPlus")
    self:RegisterEvent("CHALLENGE_MODE_RESET", "UpdateMythicPlus")

    self:UpdateAll()
    self:CreateNewUI()
end

function AlterEgo:OnSlashCommand(message)
    if not self.Window then return end
    if self.Window:IsVisible() then
        self.Window:Hide()
    else
        self.Window:Show()
    end
end

function AlterEgo:UpdateAll()
    self:UpdateCharacter()
    self:UpdateMythicPlus()
end

function AlterEgo:UpdateCharacter()
    local playerGUID = UnitGUID("player")
    if not playerGUID then
        return
    end

    if self.db.global.characters[playerGUID] == nil then
        self.db.global.characters[playerGUID] = self.constants.defaultCharacter
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
end

function AlterEgo:UpdateMythicPlus()
    local playerGUID = UnitGUID("player")
    if not playerGUID then
        return
    end

    if self.db.global.characters[playerGUID] == nil then
        self.db.global.characters[playerGUID] = self.constants.defaultCharacter
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

    for i, dungeon in ipairs(self.constants.dungeons) do
        local _, __, time = C_ChallengeMode.GetMapUIInfo(dungeon.id)
        self.constants.dungeons[i].time = time
    end

    local keyStoneMapID = C_MythicPlus.GetOwnedKeystoneMapID()
    if keyStoneMapID then
        self.db.global.characters[playerGUID].key.map = keyStoneMapID
    end

    local keyStoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()
    if keyStoneLevel then
        self.db.global.characters[playerGUID].key.level = keyStoneLevel
    end

    for i, dungeon in pairs(self.constants.dungeons) do
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