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
        -- primary = CreateColorFromHexString("ff15161a"), -- 0.08235294117647059, 0.08627450980392157, 0.10196078431372549
        primary = CreateColorFromHexString("FF21232C"), -- 0.1803921568627451, 0.19607843137254902, 0.2784313725490196
        dark = CreateColorFromHexString("FF1B1C24"), -- 0.058823529411764705, 0.058823529411764705, 0.07058823529411765
        light = CreateColorFromHexString("FF252833"), -- 0.10196078431372549, 0.10588235294117647, 0.12156862745098039
        lighter = CreateColorFromHexString("FF222329"), -- 0.21568627450980393, 0.22745098039215686, 0.2784313725490196, 0.3
        highlight = CreateColorFromHexString("FF2E313A"), -- 0.21568627450980393, 0.22745098039215686, 0.2784313725490196, 0.3
        font = CreateColorFromHexString("FF9097BD"), -- 0.3254901960784314, 0.35294117647058826, 0.5137254901960784
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
                local rating = character.rating
                local ratingColor = "ffffffff"
                if rating > 0 then
                    local color = C_ChallengeMode.GetDungeonScoreRarityColor(rating)
                    if color ~= nil then
                        ratingColor = color.GenerateHexColor(color)
                    end
                else
                    rating = "-"
                end
                return "|c" .. ratingColor .. rating .. "|r"
            end
        },
        [4] = {
            name = "ItemLevel",
            label = "Item Level:",
            value = function(self, character)
                local itemLevel = character.itemLevel
                local itemLevelColor = character.itemLevelColor

                if itemLevel == nil then
                    itemLevel = "-"
                else
                    itemLevel = floor(itemLevel)
                end

                if character.itemLevelColor == nil then
                    itemLevelColor = "ffffffff"
                end

                return "|c" .. itemLevelColor .. itemLevel .. "|r"
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

    for i, dungeon in ipairs(self.constants.dungeons) do
        local _, __, time = C_ChallengeMode.GetMapUIInfo(dungeon.id)
        self.constants.dungeons[i].time = time
    end
    

    AlterEgo:UpdateCharacter()
    AlterEgo:CreateUI()
end

function AlterEgo:OnSlashCommand(message)
    if self.frame:IsVisible() then
        self.frame:Hide()
    else
        self.frame:Show()
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
    local itemLevelColor = CreateColor(GetItemLevelColor()):GenerateHexColor()
    local mapID = C_MythicPlus.GetOwnedKeystoneMapID()
    local keyStoneLevel = C_MythicPlus.GetOwnedKeystoneLevel()
    -- local currentWeekBestLevel, weeklyRewardLevel, nextDifficultyWeeklyRewardLevel, nextBestLevel = C_MythicPlus.GetWeeklyChestRewardLevel()
    -- local rewardLevel = C_MythicPlus.GetRewardLevelFromKeystoneLevel(keyStoneLevel)
    -- local weeklyRewardAvailable = C_MythicPlus.IsWeeklyRewardAvailable()
    -- local history = C_MythicPlus.GetRunHistory(true)
    -- C_ChallengeMode.GetMapUIInfo(2527)

    self.db.global.characters[playerGUID] = {
        name = playerName,
        realm = playerRealm,
        class = playerClass,
        rating = ratingSummary.currentSeasonScore,
        itemLevel = avgItemLevelEquipped,
        itemLevelColor = itemLevelColor,
        vault = {},
        key = {
            map = mapID,
            level = keyStoneLevel or 0
        },
        dungeons = {}
    }

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
                -- if affixScore.name == "Fortified" then
                --     fortified = affixScore.level
                -- end
                -- if affixScore.name == "Tyrannical" then
                --     tyrannical = affixScore.level
                -- end
            end
            -- self:Print("-------")
            -- self.db.global.characters[playerGUID].dungeons[dungeon.id] = {
            --     [1] = tyrannical,
            --     [2] = fortified,
            -- }
        else
            self.db.global.characters[playerGUID].dungeons[dungeon.id] = {
                ["Fortified"] = {},
                ["Tyrannical"] = {},
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

    self.frame = CreateFrame("Frame", "AlterEgoFrame", UIParent, "BackdropTemplate")
    self.frame:SetPoint("CENTER")
    self.frame:SetSize(0, 0)
    self.frame:SetBackdrop(self.constants.backdrop)
    self.frame:SetBackdropColor(self.constants.colors.primary:GetRGBA())

    local rowIndex = 0

    -- Character loop
    for i, row in ipairs(self.constants.characterTable) do
        local frameRow = self.frame:GetName() .. "ROW" .. rowIndex
        self.frame[frameRow] = CreateFrame("Frame", frameRow, self.frame, "BackdropTemplate")
        self.frame[frameRow]:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, -self.constants.table.rowHeight * rowIndex)
        self.frame[frameRow]:SetSize(self.frame:GetWidth(), self.constants.table.rowHeight)
        self.frame[frameRow]:SetBackdrop(self.constants.backdrop)
        self.frame[frameRow]:SetBackdropColor(0,0,0,0)
        self.frame[frameRow]:SetScript("OnEnter", function()
            self.frame[frameRow]:SetBackdropColor(self.constants.colors.highlight:GetRGBA())
        end)
        self.frame[frameRow]:SetScript("OnLeave", function()
                self.frame[frameRow]:SetBackdropColor(0,0,0,0)
        end)

            local frameCell = frameRow .. "CELL0"
            self.frame[frameCell] = CreateFrame("Frame", frameCell, self.frame[frameRow], "BackdropTemplate")
            self.frame[frameCell]:SetSize(self.constants.table.colWidth, self.constants.table.rowHeight)
            self.frame[frameCell]:SetPoint("TOPLEFT", self.frame[frameRow], "TOPLEFT")
            self.frame[frameCell]:SetBackdrop(self.constants.backdrop)
            self.frame[frameCell]:SetBackdropColor(self.constants.colors.dark:GetRGBA())
            self.frame[frameCell].fontString = self.frame[frameCell]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            self.frame[frameCell].fontString:SetPoint("LEFT", self.frame[frameCell], "LEFT", self.constants.table.cellPadding, 0)
            self.frame[frameCell].fontString:SetJustifyH("LEFT")
        
        local lastCellFrame = self.frame[frameCell]
        local columnIndex = 1
        for _, character in pairs(characters) do
            local frameCell = frameRow .. "CELL" .. columnIndex
            self.frame[frameCell] = CreateFrame("Frame", frameCell, lastCellFrame, "BackdropTemplate")
            self.frame[frameCell]:SetSize(self.constants.table.colWidth, self.constants.table.rowHeight)
            self.frame[frameCell]:SetPoint("TOPLEFT", lastCellFrame, "TOPRIGHT")
            -- self.tableFrame[characterCellName]:SetBackdrop(self.static.backdrop)
            -- self.tableFrame[characterCellName]:SetBackdropColor(0, 0, 0, 0)
            self.frame[frameCell].fontString = self.frame[frameCell]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            self.frame[frameCell].fontString:SetPoint("CENTER", self.frame[frameCell], "CENTER", 0, 0)
            -- self.tableFrame[characterCellName].fontString:SetText(row:value(character))
            self.frame[frameCell].fontString:SetJustifyH("CENTER")
            lastCellFrame = self.frame[frameCell]
            columnIndex = columnIndex + 1
        end

        rowIndex = rowIndex + 1
    end

    -- Dungeon Header
    local dungeonHeaderRowName = self.frame:GetName() .. "DUNGEONHEADERROW"
    self.frame[dungeonHeaderRowName] = CreateFrame("Frame", dungeonHeaderRowName, self.frame, "BackdropTemplate")
    self.frame[dungeonHeaderRowName]:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, -self.constants.table.rowHeight * rowIndex)
    self.frame[dungeonHeaderRowName]:SetSize(self.frame:GetWidth(), self.constants.table.rowHeight)
    self.frame[dungeonHeaderRowName]:SetBackdrop(self.constants.backdrop)
    self.frame[dungeonHeaderRowName]:SetBackdropColor(self.constants.colors.dark:GetRGBA())

    local dungeonHeaderCellName = dungeonHeaderRowName .. "CELL0"
    self.frame[dungeonHeaderCellName] = CreateFrame("Frame", dungeonHeaderCellName, self.frame[dungeonHeaderRowName], "BackdropTemplate")
    self.frame[dungeonHeaderCellName]:SetSize(self.constants.table.colWidth, self.constants.table.rowHeight)
    self.frame[dungeonHeaderCellName]:SetPoint("TOPLEFT", self.frame[dungeonHeaderRowName], "TOPLEFT")
    -- self.frame[dungeonHeaderCellName]:SetBackdrop(self.constants.backdrop)
    -- self.frame[dungeonHeaderCellName]:SetBackdropColor(self.constants.colors.dark:GetRGBA())
    -- self.tableFrame[dungeonHeaderCellName]:SetBackdrop(self.constants.backdrop)
    -- self.tableFrame[dungeonHeaderCellName]:SetBackdropColor(self.constants.colors.lighter:GetRGBA())
    self.frame[dungeonHeaderCellName].fontString = self.frame[dungeonHeaderCellName]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.frame[dungeonHeaderCellName].fontString:SetPoint("LEFT", self.frame[dungeonHeaderCellName], "LEFT", self.constants.table.cellPadding, 0)
    self.frame[dungeonHeaderCellName].fontString:SetText("Dungeons:")
    self.frame[dungeonHeaderCellName].fontString:SetJustifyH("LEFT")

    local lastCellFrame = self.frame[dungeonHeaderCellName]
    local columnIndex = 1
    for _, character in pairs(characters) do
        for affixIndex = 1, 2 do
            dungeonHeaderCellName = dungeonHeaderRowName .. "CELL" .. columnIndex
            self.frame[dungeonHeaderCellName] = CreateFrame("Frame",  dungeonHeaderCellName, lastCellFrame, "BackdropTemplate")
            self.frame[dungeonHeaderCellName]:SetSize(self.constants.table.colWidth / 2, self.constants.table.rowHeight)
            self.frame[dungeonHeaderCellName]:SetPoint("TOPLEFT", lastCellFrame, "TOPRIGHT")
            -- self.tableFrame[dungeonHeaderCellName]:SetBackdrop(self.constants.backdrop)
            -- self.tableFrame[dungeonHeaderCellName]:SetBackdropColor(self.constants.colors.lighter:GetRGBA())
            self.frame[dungeonHeaderCellName].iconFrame = self.frame[dungeonHeaderCellName]:CreateTexture(dungeonHeaderCellName .. "ICON", "BACKGROUND")
            self.frame[dungeonHeaderCellName].iconFrame:SetSize(16, 16)
            self.frame[dungeonHeaderCellName].iconFrame:SetPoint("CENTER", self.frame[dungeonHeaderCellName], "CENTER", 0, 0)
            self.frame[dungeonHeaderCellName].iconFrame:SetTexture(affixIndex == 2 and "Interface/Icons/ability_toughness" or "Interface/Icons/achievement_boss_archaedas")
            lastCellFrame = self.frame[dungeonHeaderCellName]
            columnIndex = columnIndex + 1
        end
    end

    rowIndex = rowIndex + 1

    -- Dungeon Loop
    for i, dungeon in ipairs(self.constants.dungeons) do
        local dungeonRowFrame = self.frame:GetName() .. "ROW" .. rowIndex
        self.frame[dungeonRowFrame] = CreateFrame("Frame", dungeonRowFrame, self.frame, "BackdropTemplate")
        self.frame[dungeonRowFrame]:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 0, -self.constants.table.rowHeight * rowIndex)
        self.frame[dungeonRowFrame]:SetSize(self.frame:GetWidth(), self.constants.table.rowHeight)
        self.frame[dungeonRowFrame]:SetBackdrop(self.constants.backdrop)
        if i % 2 == 0 then
            self.frame[dungeonRowFrame]:SetBackdropColor(self.constants.colors.light:GetRGBA())
        else
            self.frame[dungeonRowFrame]:SetBackdropColor(0,0,0,0)
        end
        self.frame[dungeonRowFrame]:SetScript("OnEnter", function()
            self.frame[dungeonRowFrame]:SetBackdropColor(self.constants.colors.highlight:GetRGBA())
        end)
        self.frame[dungeonRowFrame]:SetScript("OnLeave", function()
            if i % 2 == 0 then
                self.frame[dungeonRowFrame]:SetBackdropColor(self.constants.colors.light:GetRGBA())
            else
                self.frame[dungeonRowFrame]:SetBackdropColor(0,0,0,0)
            end
        end)

        local dungeonHeaderFrame = dungeonRowFrame .. "CELL0"
        self.frame[dungeonHeaderFrame] = CreateFrame("Frame", dungeonHeaderFrame, self.frame[dungeonRowFrame], "BackdropTemplate")
        self.frame[dungeonHeaderFrame]:SetSize(self.constants.table.colWidth, self.constants.table.rowHeight)
        self.frame[dungeonHeaderFrame]:SetPoint("TOPLEFT", self.frame[dungeonRowFrame], "TOPLEFT")
        -- self.tableFrame[dungeonHeaderFrame]:SetBackdrop(self.static.backdrop)
        -- self.tableFrame[dungeonHeaderFrame]:SetBackdropColor(0, 0, 0, 0)
        self.frame[dungeonHeaderFrame]:SetBackdrop(self.constants.backdrop)
        self.frame[dungeonHeaderFrame]:SetBackdropColor(self.constants.colors.dark:GetRGBA())
        self.frame[dungeonHeaderFrame].fontString = self.frame[dungeonHeaderFrame]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.frame[dungeonHeaderFrame].fontString:SetPoint("LEFT", self.frame[dungeonHeaderFrame], "LEFT", self.constants.table.cellPadding, 0)
        -- self.tableFrame[dungeonHeaderFrame].fontString:SetText(MaxLength(map.name))
        self.frame[dungeonHeaderFrame].fontString:SetVertexColor(1, 1, 1)
        self.frame[dungeonHeaderFrame].fontString:SetJustifyH("LEFT")

        local lastCellFrame = self.frame[dungeonHeaderFrame]
        local columnIndex = 1
        for _, character in pairs(characters) do
            for affixIndex = 1, 2 do
                -- local level = character.dungeons[map.id][affixIndex]
                -- if level == 0 then
                --     level = " -"
                -- end
                local dungeonCellFrameLeft = dungeonRowFrame .. "CELL" .. columnIndex .. "LEFT"
                self.frame[dungeonCellFrameLeft] = CreateFrame("Frame", dungeonCellFrameLeft, lastCellFrame, "BackdropTemplate")
                self.frame[dungeonCellFrameLeft]:SetSize(self.constants.table.colWidth / 4, self.constants.table.rowHeight)
                self.frame[dungeonCellFrameLeft]:SetPoint("TOPLEFT", lastCellFrame, "TOPRIGHT")
                self.frame[dungeonCellFrameLeft].fontString = self.frame[dungeonCellFrameLeft]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                self.frame[dungeonCellFrameLeft].fontString:SetPoint("RIGHT", self.frame[dungeonCellFrameLeft], "RIGHT", -1, 0)
                self.frame[dungeonCellFrameLeft].fontString:SetJustifyH("RIGHT")
                local dungeonCellFrameRight = dungeonRowFrame .. "CELL" .. columnIndex .. "RIGHT"
                self.frame[dungeonCellFrameRight] = CreateFrame("Frame", dungeonCellFrameRight, self.frame[dungeonCellFrameLeft], "BackdropTemplate")
                self.frame[dungeonCellFrameRight]:SetSize(self.constants.table.colWidth / 4, self.constants.table.rowHeight)
                self.frame[dungeonCellFrameRight]:SetPoint("TOPLEFT", self.frame[dungeonCellFrameLeft], "TOPRIGHT")
                self.frame[dungeonCellFrameRight].fontString = self.frame[dungeonCellFrameRight]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                self.frame[dungeonCellFrameRight].fontString:SetPoint("LEFT", self.frame[dungeonCellFrameRight], "LEFT", 1, 0)
                self.frame[dungeonCellFrameRight].fontString:SetJustifyH("LEFT")
                lastCellFrame = self.frame[dungeonCellFrameRight]
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
        local characterRowFrame = self.frame:GetName() .. "ROW" .. rowIndex
        self.frame[characterRowFrame]:SetSize(frameWidth, self.constants.table.rowHeight)
        local characterCellName = characterRowFrame .. "CELL0"
        self.frame[characterCellName]:SetSize(self.constants.table.colWidth, self.constants.table.rowHeight)
        self.frame[characterCellName].fontString:SetText(MaxLength(row.label))

        local columnIndex = 1
        for _, character in pairs(characters) do
            characterCellName = characterRowFrame .. "CELL" .. columnIndex
            self.frame[characterCellName]:SetSize(self.constants.table.colWidth, self.constants.table.rowHeight)
            self.frame[characterCellName].fontString:SetText(row.value(self, character))
            columnIndex = columnIndex + 1
        end

        rowIndex = rowIndex + 1
    end

    -- Dungeon Header
    local dungeonHeaderRowName = self.frame:GetName() .. "DUNGEONHEADERROW"
    self.frame[dungeonHeaderRowName]:SetSize(frameWidth, self.constants.table.rowHeight)
    rowIndex = rowIndex + 1

    -- Dungeon Loop
    for i, dungeon in ipairs(self.constants.dungeons) do
        local dungeonRowFrame = self.frame:GetName() .. "ROW" .. rowIndex
        self.frame[dungeonRowFrame]:SetSize(frameWidth, self.constants.table.rowHeight)

        local dungeonHeaderFrame = dungeonRowFrame .. "CELL0"
        self.frame[dungeonHeaderFrame].fontString:SetText(MaxLength(dungeon.name))

        local columnIndex = 1
        local affixes = {"Fortified", "Tyrannical"}
        for _, character in pairs(characters) do
            for affixIndex, affixName in ipairs(affixes) do
                local characterAffix = character.dungeons[dungeon.id][affixName]
                local level = ""
                local levelColor = "ffffffff"
                local tier = ""
                if characterAffix == nil then
                    level = "-"
                end
                if characterAffix == nil or characterAffix.score == nil then
                    level = "-"
                    levelColor = LIGHTGRAY_FONT_COLOR:GenerateHexColor()
                else
                    level = characterAffix.level

                    -- if level < 10 then
                    --     level = "  " .. level
                    -- end

                    if characterAffix.durationSec <= dungeon.time * 0.6 then
                        tier = "|A:Professions-ChatIcon-Quality-Tier3:16:16:0:-1|a"
                    elseif characterAffix.durationSec <= dungeon.time * 0.8 then
                        tier =  "|A:Professions-ChatIcon-Quality-Tier2:16:16:0:-1|a"
                    elseif characterAffix.durationSec <= dungeon.time then
                        tier =  "|A:Professions-ChatIcon-Quality-Tier1:14:14:0:-1|a"
                    else
                        levelColor = LIGHTGRAY_FONT_COLOR:GenerateHexColor()
                    end
                end

                local dungeonCellFrameLeft = dungeonRowFrame .. "CELL" .. columnIndex .. "LEFT"
                self.frame[dungeonCellFrameLeft].fontString:SetText("|c" .. levelColor .. level .. "|r")
                local dungeonCellFrameRight = dungeonRowFrame .. "CELL" .. columnIndex .. "RIGHT"
                self.frame[dungeonCellFrameRight].fontString:SetText(tier)
                columnIndex = columnIndex + 1
            end
        end

        rowIndex = rowIndex + 1
    end

    self.frame:SetSize(frameWidth, self.constants.table.rowHeight * rowIndex)
end
