AlterEgo = LibStub("AceAddon-3.0"):NewAddon("AlterEgo", "AceConsole-3.0", "AceEvent-3.0", "AceBucket-3.0")

local function MaxLength(str, len)
    if len == nil then
        len = 15
    end
    if string.len(str) > len then
        return str:sub(1, len) .. "..."
    end
    return str
end

AlterEgo.constants = {
    table = {
        rowHeight = 22,
        colWidth = 120,
        cellPadding = 6,
        cellLength = 18
    },
    colors = {
        primary = CreateColor(0.08235294117647059, 0.08627450980392157, 0.10196078431372549), -- #15161a
        dark = CreateColor(0.058823529411764705, 0.058823529411764705, 0.07058823529411765), -- #0f0f12
        light = CreateColor(0.10196078431372549, 0.10588235294117647, 0.12156862745098039), -- #1a1b1f
        lighter = CreateColor(0.21568627450980393, 0.22745098039215686, 0.2784313725490196, 0.3), -- #373a47
        highlight = CreateColor(0.21568627450980393, 0.22745098039215686, 0.2784313725490196, 0.3), -- #373a47
    },
    backdrop = {
        bgFile = "Interface/BUTTONS/WHITE8X8",
        tile = false,
        insets = {top = 0, right = 0, bottom = 0, left = 0}
    },
    defaultDB = {
        global = {
            characters = {},
        },
        profile = {
            settings = {}
        }
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
            abbr = "NL"
        },
        [2] = {
            id = 245,
            mapId = 1754,
            name = "Freehold",
            abbr = "FH"
        },
        [3] = {
            id = 251,
            mapId = 1841,
            name = "The Underrot",
            abbr = "UR"
        },
        [4] = {
            id = 403,
            mapId = 2451,
            name = "Uldaman: Legacy of Tyr",
            abbr = "UL"
        },
        [5] = {
            id = 404,
            mapId = 2519,
            name = "Neltharus",
            abbr = "NEL"
        },
        [6] = {
            id = 405,
            mapId = 2520,
            name = "Brackenhide Hollow",
            abbr = "BH"
        },
        [7] = {
            id = 406,
            mapId = 2527,
            name = "Halls of Infusion",
            abbr = "HOI"
        },
        [8] = {
            id = 438,
            mapId = 657,
            name = "The Vortex Pinnacle",
            abbr = "VP"
        },
    },
    characterTable = {
        [1] = {
            name = "Name",
            label = "Characters:",
            value = function(self, character)
                local characterColor = "|cffffffff"
                if character.class ~= nil then
                    local classColor = C_ClassColor.GetClassColor(character.class)
                    if classColor ~= nil then
                        characterColor = "|c" .. classColor.GenerateHexColor(classColor)
                    end
                end
                return characterColor .. MaxLength(character.name) .. "|r"
            end
        },
        [2] = {
            name = "Realm",
            label = "Realm:",
            value = function(self, character)
                return MaxLength(character.realm)
            end
        },
        [3] = {
            name = "Rating",
            label = "Rating:",
            value = function(self, character)
                local ratingColor = "|cffffffff"
                if character.rating > 0 then
                    local color = C_ChallengeMode.GetDungeonScoreRarityColor(character.rating)
                    if color ~= nil then
                        ratingColor = "|c" .. color.GenerateHexColor(color)
                    end
                end
                return ratingColor .. character.rating .. "|r"
            end
        },
        [4] = {
            name = "ItemLevel",
            label = "Item Level:",
            value = function(self, character)
                local r, g, b = GetItemLevelColor()
                local itemLevelColorHex = "|cffffffff"
                if r ~= nil then
                    local color = CreateColor(r, g, b, 1)
                    itemLevelColorHex = "|c" .. color:GenerateHexColor()
                end
                return itemLevelColorHex .. floor(character.ilvl) .. "|r"
            end
        },
        [5] = {
            name = "Vault1",
            label = "Vault 1:",
            value = function(self, character)
                if character.vault[1] == 0 then
                    return "-"
                end
                return character.vault[1]
            end
        },
        [6] = {
            name = "Vault2",
            label = "Vault 2:",
            value = function(self, character)
                if character.vault[2] == 0 then
                    return "-"
                end
                return character.vault[2]
            end
        },
        [7] = {
            name = "Vault3",
            label = "Vault 3:",
            value = function(self, character)
                if character.vault[3] == 0 then
                    return "-"
                end
                return character.vault[3]
            end
        },
        [8] = {
            name = "CurrentKey",
            label = "Current Key:",
            value = function(self, character)
                if character.key.map == nil or character.key.map == "" then
                    return "-"
                end
                local dungeon = self:GetDungeonByMapId(character.key.map)
                if dungeon == nil then
                    return "-"
                end
                return dungeon.abbr .. " +" .. character.key.level
            end
        },
    }
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
    self.db = LibStub("AceDB-3.0"):New("AlterEgoDB", defaultDB)
    self:RegisterChatCommand("alterego", "OnSlashCommand")
    self:RegisterChatCommand("ae", "OnSlashCommand")

    -- TODO: Split these into different event handlers
    self:RegisterBucketEvent({"BAG_UPDATE_DELAYED", "PLAYER_EQUIPMENT_CHANGED", "UNIT_INVENTORY_CHANGED"}, 1, "OnEvent")
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED", "OnEvent")
    self:RegisterEvent("CHALLENGE_MODE_RESET", "OnEvent")

    -- TODO: Do this on event updates as well
    C_MythicPlus.RequestMapInfo()

    AlterEgo:UpdateCharacter()
    AlterEgo:CreateUI()
end

function AlterEgo:OnSlashCommand(message)
    if self.tableFrame:IsVisible() then
        self.tableFrame:Hide()
    else
        self.tableFrame:Show()
    end
end

function AlterEgo:OnEvent()
    self:UpdateCharacter()
    self:UpdateUI()
end

function AlterEgo:UpdateCharacter()
    local playerName = UnitName("player")
    local _, playerClass = UnitClass("player")
    local playerRealm = GetRealmName()
    local activities = C_WeeklyRewards.GetActivities(1)
    -- local playerRealm = GetNormalizedRealmName()
    local playerGUID = UnitGUID("player")
    local ratingSummary = C_PlayerInfo.GetPlayerMythicPlusRatingSummary("player")
    local avgItemLevel, avgItemLevelEquipped, avgItemLevelPvp = GetAverageItemLevel()
    local mapID = C_MythicPlus.GetOwnedKeystoneMapID()
    local keyStoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()
    -- local currentWeekBestLevel, weeklyRewardLevel, nextDifficultyWeeklyRewardLevel, nextBestLevel = C_MythicPlus.GetWeeklyChestRewardLevel()
    -- local rewardLevel = C_MythicPlus.GetRewardLevelFromKeystoneLevel(keyStoneLevel)
    -- local weeklyRewardAvailable = C_MythicPlus.IsWeeklyRewardAvailable()
    -- local history = C_MythicPlus.GetRunHistory(true)
    -- C_ChallengeMode.GetMapUIInfo(mapid)

    self.db.global.characters[playerGUID] = {
        name = playerName,
        realm = playerRealm,
        class = playerClass,
        rating = ratingSummary.currentSeasonScore,
        ilvl = avgItemLevelEquipped,
        vault = {},
        key = {
            map = mapID,
            level = keyStoneLevel or 0
        },
        dungeons = {}
    }

    for i, dungeon in pairs(self.constants.dungeons) do
        local affixScores = C_MythicPlus.GetSeasonBestAffixScoreInfoForMap(dungeon.id)
        if affixScores ~= nil then
            local fortified = 0
            local tyrannical = 0
            for _, affixScore in pairs(affixScores) do
                if affixScore.name == "Fortified" then
                    fortified = affixScore.level
                end
                if affixScore.name == "Tyrannical" then
                    tyrannical = affixScore.level
                end
            end

            self.db.global.characters[playerGUID].dungeons[dungeon.id] = {
                [1] = tyrannical,
                [2] = fortified,
            }
        else
            self.db.global.characters[playerGUID].dungeons[dungeon.id] = {
                [1] = 0,
                [2] = 0,
            }
        end
    end

    for _, activity in pairs(activities) do
        self.db.global.characters[playerGUID].vault[activity.index] = activity.level
    end
end

function AlterEgo:GetCharacters()
    local characters = self.db.global.characters

    -- Filters
    -- Sorting

    return characters
end


function AlterEgo:CreateUI()
    local characters = AlterEgo:GetCharacters()

    self.tableFrame = CreateFrame("Frame", "AlterEgoFrame", UIParent, "BackdropTemplate")
    self.tableFrame:SetPoint("CENTER")
    self.tableFrame:SetSize(0, 0)
    self.tableFrame:SetBackdrop(self.constants.backdrop)
    self.tableFrame:SetBackdropColor(self.constants.colors.primary:GetRGBA())

    local rowIndex = 0

    -- Character loop
    for i, row in ipairs(self.constants.characterTable) do
        local characterRowFrame = self.tableFrame:GetName() .. "ROW" .. rowIndex
        self.tableFrame[characterRowFrame] = CreateFrame("Frame", characterRowFrame, self.tableFrame, "BackdropTemplate")
        self.tableFrame[characterRowFrame]:SetPoint("TOPLEFT", self.tableFrame, "TOPLEFT", 0, -self.constants.table.rowHeight * rowIndex)
        self.tableFrame[characterRowFrame]:SetSize(self.tableFrame:GetWidth(), self.constants.table.rowHeight)
        self.tableFrame[characterRowFrame]:SetBackdrop(self.constants.backdrop)
        self.tableFrame[characterRowFrame]:SetBackdropColor(0,0,0,0)
        self.tableFrame[characterRowFrame]:SetScript("OnEnter", function()
            self.tableFrame[characterRowFrame]:SetBackdropColor(self.constants.colors.highlight:GetRGBA())
        end)
        self.tableFrame[characterRowFrame]:SetScript("OnLeave", function()
                self.tableFrame[characterRowFrame]:SetBackdropColor(0,0,0,0)
        end)

        local characterCellName = characterRowFrame .. "CELL0"
        self.tableFrame[characterCellName] = CreateFrame("Frame", characterCellName, self.tableFrame[characterRowFrame], "BackdropTemplate")
        self.tableFrame[characterCellName]:SetSize(self.constants.table.colWidth, self.constants.table.rowHeight)
        self.tableFrame[characterCellName]:SetPoint("TOPLEFT", self.tableFrame[characterRowFrame], "TOPLEFT")
        -- self.tableFrame[characterCellName]:SetBackdrop(self.static.backdrop)
        -- self.tableFrame[characterCellName]:SetBackdropColor(0, 0, 0, 0)
        self.tableFrame[characterCellName]:SetBackdrop(self.constants.backdrop)
        self.tableFrame[characterCellName]:SetBackdropColor(self.constants.colors.dark:GetRGBA())
        self.tableFrame[characterCellName].fontString = self.tableFrame[characterCellName]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.tableFrame[characterCellName].fontString:SetPoint("LEFT", self.tableFrame[characterCellName], "LEFT", self.constants.table.cellPadding, 0)
        -- self.tableFrame[characterCellName].fontString:SetText(MaxLength(row.label))
        self.tableFrame[characterCellName].fontString:SetJustifyH("LEFT")

        local lastCellFrame = self.tableFrame[characterCellName]
        local columnIndex = 1
        for _, character in pairs(characters) do
            local characterCellName = characterRowFrame .. "CELL" .. columnIndex
            self.tableFrame[characterCellName] = CreateFrame("Frame", characterCellName, lastCellFrame, "BackdropTemplate")
            self.tableFrame[characterCellName]:SetSize(self.constants.table.colWidth, self.constants.table.rowHeight)
            self.tableFrame[characterCellName]:SetPoint("TOPLEFT", lastCellFrame, "TOPRIGHT")
            -- self.tableFrame[characterCellName]:SetBackdrop(self.static.backdrop)
            -- self.tableFrame[characterCellName]:SetBackdropColor(0, 0, 0, 0)
            self.tableFrame[characterCellName].fontString = self.tableFrame[characterCellName]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            self.tableFrame[characterCellName].fontString:SetPoint("CENTER", self.tableFrame[characterCellName], "CENTER", self.constants.table.cellPadding, 0)
            -- self.tableFrame[characterCellName].fontString:SetText(row:value(character))
            self.tableFrame[characterCellName].fontString:SetJustifyH("CENTER")
            lastCellFrame = self.tableFrame[characterCellName]
            columnIndex = columnIndex + 1
        end

        rowIndex = rowIndex + 1
    end

    -- Dungeon Header
    local dungeonHeaderRowName = self.tableFrame:GetName() .. "DUNGEONHEADERROW"
    self.tableFrame[dungeonHeaderRowName] = CreateFrame("Frame", dungeonHeaderRowName, self.tableFrame, "BackdropTemplate")
    self.tableFrame[dungeonHeaderRowName]:SetPoint("TOPLEFT", self.tableFrame, "TOPLEFT", 0, -self.constants.table.rowHeight * rowIndex)
    self.tableFrame[dungeonHeaderRowName]:SetSize(self.tableFrame:GetWidth(), self.constants.table.rowHeight)
    self.tableFrame[dungeonHeaderRowName]:SetBackdrop(self.constants.backdrop)
    self.tableFrame[dungeonHeaderRowName]:SetBackdropColor(self.constants.colors.lighter:GetRGBA())

    local dungeonHeaderCellName = dungeonHeaderRowName .. "CELL0"
    self.tableFrame[dungeonHeaderCellName] = CreateFrame("Frame", dungeonHeaderCellName, self.tableFrame[dungeonHeaderRowName], "BackdropTemplate")
    self.tableFrame[dungeonHeaderCellName]:SetSize(self.constants.table.colWidth, self.constants.table.rowHeight)
    self.tableFrame[dungeonHeaderCellName]:SetPoint("TOPLEFT", self.tableFrame[dungeonHeaderRowName], "TOPLEFT")
    self.tableFrame[dungeonHeaderCellName]:SetBackdrop(self.constants.backdrop)
    self.tableFrame[dungeonHeaderCellName]:SetBackdropColor(self.constants.colors.dark:GetRGBA())
    -- self.tableFrame[dungeonHeaderCellName]:SetBackdrop(self.constants.backdrop)
    -- self.tableFrame[dungeonHeaderCellName]:SetBackdropColor(self.constants.colors.lighter:GetRGBA())
    self.tableFrame[dungeonHeaderCellName].fontString = self.tableFrame[dungeonHeaderCellName]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.tableFrame[dungeonHeaderCellName].fontString:SetPoint("LEFT", self.tableFrame[dungeonHeaderCellName], "LEFT", self.constants.table.cellPadding, 0)
    self.tableFrame[dungeonHeaderCellName].fontString:SetText("Dungeons:")
    self.tableFrame[dungeonHeaderCellName].fontString:SetJustifyH("LEFT")

    local lastCellFrame = self.tableFrame[dungeonHeaderCellName]
    local columnIndex = 1
    for _, character in pairs(characters) do
        for affixIndex = 1, 2 do
            dungeonHeaderCellName = dungeonHeaderRowName .. "CELL" .. columnIndex
            self.tableFrame[dungeonHeaderCellName] = CreateFrame("Frame",  dungeonHeaderCellName, lastCellFrame, "BackdropTemplate")
            self.tableFrame[dungeonHeaderCellName]:SetSize(self.constants.table.colWidth / 2, self.constants.table.rowHeight)
            self.tableFrame[dungeonHeaderCellName]:SetPoint("TOPLEFT", lastCellFrame, "TOPRIGHT")
            -- self.tableFrame[dungeonHeaderCellName]:SetBackdrop(self.constants.backdrop)
            -- self.tableFrame[dungeonHeaderCellName]:SetBackdropColor(self.constants.colors.lighter:GetRGBA())
            self.tableFrame[dungeonHeaderCellName].fontString = self.tableFrame[dungeonHeaderCellName]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            self.tableFrame[dungeonHeaderCellName].fontString:SetPoint("CENTER", self.tableFrame[dungeonHeaderCellName], "CENTER", self.constants.table.cellPadding, 0)
            self.tableFrame[dungeonHeaderCellName].fontString:SetText("AFFIX")
            self.tableFrame[dungeonHeaderCellName].fontString:SetJustifyH("CENTER")
            lastCellFrame = self.tableFrame[dungeonHeaderCellName]
            columnIndex = columnIndex + 1
        end
    end

    rowIndex = rowIndex + 1

    -- Dungeon Loop
    for i, dungeon in ipairs(self.constants.dungeons) do
        local dungeonRowFrame = self.tableFrame:GetName() .. "ROW" .. rowIndex
        self.tableFrame[dungeonRowFrame] = CreateFrame("Frame", dungeonRowFrame, self.tableFrame, "BackdropTemplate")
        self.tableFrame[dungeonRowFrame]:SetPoint("TOPLEFT", self.tableFrame, "TOPLEFT", 0, -self.constants.table.rowHeight * rowIndex)
        self.tableFrame[dungeonRowFrame]:SetSize(self.tableFrame:GetWidth(), self.constants.table.rowHeight)
        self.tableFrame[dungeonRowFrame]:SetBackdrop(self.constants.backdrop)
        if i % 2 == 0 then
            self.tableFrame[dungeonRowFrame]:SetBackdropColor(self.constants.colors.light:GetRGBA())
        else
            self.tableFrame[dungeonRowFrame]:SetBackdropColor(0,0,0,0)
        end
        self.tableFrame[dungeonRowFrame]:SetScript("OnEnter", function()
            self.tableFrame[dungeonRowFrame]:SetBackdropColor(self.constants.colors.highlight:GetRGBA())
        end)
        self.tableFrame[dungeonRowFrame]:SetScript("OnLeave", function()
            if i % 2 == 0 then
                self.tableFrame[dungeonRowFrame]:SetBackdropColor(self.constants.colors.light:GetRGBA())
            else
                self.tableFrame[dungeonRowFrame]:SetBackdropColor(0,0,0,0)
            end
        end)

        local dungeonHeaderFrame = dungeonRowFrame .. "CELL0"
        self.tableFrame[dungeonHeaderFrame] = CreateFrame("Frame", dungeonHeaderFrame, self.tableFrame[dungeonRowFrame], "BackdropTemplate")
        self.tableFrame[dungeonHeaderFrame]:SetSize(self.constants.table.colWidth, self.constants.table.rowHeight)
        self.tableFrame[dungeonHeaderFrame]:SetPoint("TOPLEFT", self.tableFrame[dungeonRowFrame], "TOPLEFT")
        -- self.tableFrame[dungeonHeaderFrame]:SetBackdrop(self.static.backdrop)
        -- self.tableFrame[dungeonHeaderFrame]:SetBackdropColor(0, 0, 0, 0)
        self.tableFrame[dungeonHeaderFrame]:SetBackdrop(self.constants.backdrop)
        self.tableFrame[dungeonHeaderFrame]:SetBackdropColor(self.constants.colors.dark:GetRGBA())
        self.tableFrame[dungeonHeaderFrame].fontString = self.tableFrame[dungeonHeaderFrame]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.tableFrame[dungeonHeaderFrame].fontString:SetPoint("LEFT", self.tableFrame[dungeonHeaderFrame], "LEFT", self.constants.table.cellPadding, 0)
        -- self.tableFrame[dungeonHeaderFrame].fontString:SetText(MaxLength(map.name))
        self.tableFrame[dungeonHeaderFrame].fontString:SetJustifyH("LEFT")

        local lastCellFrame = self.tableFrame[dungeonHeaderFrame]
        local columnIndex = 1
        for _, character in pairs(characters) do
            for affixIndex = 1, 2 do
                -- local level = character.dungeons[map.id][affixIndex]
                -- if level == 0 then
                --     level = "-"
                -- end
                local dungeonCellFrame = dungeonRowFrame .. "CELL" .. columnIndex
                self.tableFrame[dungeonCellFrame] = CreateFrame("Frame", dungeonCellFrame, lastCellFrame, "BackdropTemplate")
                self.tableFrame[dungeonCellFrame]:SetSize(self.constants.table.colWidth / 2, self.constants.table.rowHeight)
                self.tableFrame[dungeonCellFrame]:SetPoint("TOPLEFT", lastCellFrame, "TOPRIGHT")
                -- self.tableFrame[dungeonCellFrame]:SetBackdrop(self.static.backdrop)
                -- self.tableFrame[dungeonCellFrame]:SetBackdropColor(0, 0, 0, 0)
                self.tableFrame[dungeonCellFrame].fontString = self.tableFrame[dungeonCellFrame]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                self.tableFrame[dungeonCellFrame].fontString:SetPoint("CENTER", self.tableFrame[dungeonCellFrame], "CENTER", self.constants.table.cellPadding, 0)
                -- self.tableFrame[dungeonCellFrame].fontString:SetText(level)
                self.tableFrame[dungeonCellFrame].fontString:SetJustifyH("CENTER")
                lastCellFrame = self.tableFrame[dungeonCellFrame]
                columnIndex = columnIndex + 1
            end
        end

        rowIndex = rowIndex + 1
    end

    AlterEgo:UpdateUI()
end

function AlterEgo:UpdateUI()
    local characters = AlterEgo:GetCharacters()
    local frameWidth = self.constants.table.colWidth
    local rowIndex = 0

    for _, __ in pairs(characters) do
        frameWidth = frameWidth + self.constants.table.colWidth
    end

    -- Character loop
    for i, row in ipairs(self.constants.characterTable) do
        local characterRowFrame = self.tableFrame:GetName() .. "ROW" .. rowIndex
        self.tableFrame[characterRowFrame]:SetSize(frameWidth, self.constants.table.rowHeight)
        local characterCellName = characterRowFrame .. "CELL0"
        self.tableFrame[characterCellName]:SetSize(self.constants.table.colWidth, self.constants.table.rowHeight)
        self.tableFrame[characterCellName].fontString:SetText(MaxLength(row.label))

        local columnIndex = 1
        for _, character in pairs(characters) do
            characterCellName = characterRowFrame .. "CELL" .. columnIndex
            self.tableFrame[characterCellName]:SetSize(self.constants.table.colWidth, self.constants.table.rowHeight)
            self.tableFrame[characterCellName].fontString:SetText(row.value(self, character))
            columnIndex = columnIndex + 1
        end

        rowIndex = rowIndex + 1
    end

    -- Dungeon Header
    local dungeonHeaderRowName = self.tableFrame:GetName() .. "DUNGEONHEADERROW"
    self.tableFrame[dungeonHeaderRowName]:SetSize(frameWidth, self.constants.table.rowHeight)
    rowIndex = rowIndex + 1

    -- Dungeon Loop
    for i, dungeon in ipairs(self.constants.dungeons) do
        local dungeonRowFrame = self.tableFrame:GetName() .. "ROW" .. rowIndex
        self.tableFrame[dungeonRowFrame]:SetSize(frameWidth, self.constants.table.rowHeight)

        local dungeonHeaderFrame = dungeonRowFrame .. "CELL0"
        self.tableFrame[dungeonHeaderFrame].fontString:SetText(MaxLength(dungeon.name))

        local columnIndex = 1
        for _, character in pairs(characters) do
            for affixIndex = 1, 2 do
                local level = character.dungeons[dungeon.id][affixIndex]
                if level == 0 then
                    level = "-"
                end
                local dungeonCellFrame = dungeonRowFrame .. "CELL" .. columnIndex
                self.tableFrame[dungeonCellFrame].fontString:SetText(level)
                columnIndex = columnIndex + 1
            end
        end

        rowIndex = rowIndex + 1
    end

    self.tableFrame:SetSize(frameWidth, self.constants.table.rowHeight * rowIndex)
end
