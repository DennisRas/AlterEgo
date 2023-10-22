---@diagnostic disable: undefined-field, inject-field, duplicate-set-field
AlterEgo = LibStub("AceAddon-3.0"):NewAddon("AlterEgo", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0", "AceBucket-3.0")
AlterEgo.constants = {
    table = {
        rowHeight = 22,
        colWidth = 120,
        cellPadding = 6,
        cellLength = 18
    },
    colors = {
        primary = CreateColorFromHexString("FF21232C"),
        darker = CreateColorFromHexString("FF14151A"),
        dark = CreateColorFromHexString("FF1B1C24"),
        light = CreateColorFromHexString("FF252833"),
        lighter = CreateColorFromHexString("FF222329"),
        highlight = CreateColorFromHexString("FF2E313A"),
        font = CreateColorFromHexString("FF9097BD"),
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
                return characterColor .. character.name .. "|r"
            end
        },
        [2] = {
            name = "Realm",
            label = "Realm:",
            value = function(self, character)
                return character.realm
            end
        },
        [3] = {
            name = "Rating",
            label = "Rating:",
            value = function(self, character)
                local rating = character.rating
                local ratingColor = "ffffffff"
                if rating and rating > 0 then
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
            name = "Vault",
            label = "Vault:",
            value = function(self, character)

                local vaults = ""
                for i,vault in ipairs(character.vault) do
                    if vault == 0 then
                        vault = "-"
                    end
                    vaults = vaults .. vault .. "  "
                end
                
                return vaults:trim()
            end
        },
        [6] = {
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
    self.db = LibStub("AceDB-3.0"):New("AlterEgoDB", self.constants.defaultDB)
    self:RegisterChatCommand("alterego", "OnSlashCommand")
    self:RegisterChatCommand("ae", "OnSlashCommand")
    self:RegisterBucketEvent({"BAG_UPDATE_DELAYED", "PLAYER_EQUIPMENT_CHANGED", "UNIT_INVENTORY_CHANGED"}, 1, "UpdateCharacter")
    self:RegisterEvent("CHALLENGE_MODE_COMPLETED", "UpdateMythicPlus")
    self:RegisterEvent("CHALLENGE_MODE_RESET", "UpdateMythicPlus")

    self:UpdateAll()
    self:CreateUI()
end

function AlterEgo:OnSlashCommand(message)
    if self.frame:IsVisible() then
        self.frame:Hide()
    else
        self.frame:Show()
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

    self:UpdateUI()
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

    self:UpdateUI()
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

    -- TODO: Uncomment for release
    -- tinsert(UISpecialFrames, self.frame:GetName())

    self.frame.header = CreateFrame("Frame", self.frame:GetName() .. "HEADER", self.frame, "BackdropTemplate")
    self.frame.header:SetPoint("BOTTOM", self.frame, "TOP")
    self.frame.header:SetSize(self.frame:GetWidth(), self.constants.table.rowHeight)
    self.frame.header:SetBackdrop(self.constants.backdrop)
    self.frame.header:SetBackdropColor(self.constants.colors.darker:GetRGBA())
    self.frame.header.fontString = self.frame.header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.frame.header.fontString:SetSize(self.frame.header:GetSize())
    self.frame.header.fontString:SetPoint("CENTER", self.frame.header, "CENTER", 0, 0)
    self.frame.header.fontString:SetJustifyH("CENTER")
    self.frame.header.fontString:SetText("AlterEgo")
    self.frame.header.closeBtn = CreateFrame("Frame", self.frame.header:GetName() .. "CLOSEBTN", self.frame.header, "BackdropTemplate")
    self.frame.header.closeBtn:SetPoint("RIGHT", self.frame.header, "RIGHT", 0, 0)
    self.frame.header.closeBtn:SetSize(self.constants.table.rowHeight, self.constants.table.rowHeight)
    self.frame.header.closeBtn:SetBackdrop(self.constants.backdrop)
    self.frame.header.closeBtn:SetBackdropColor(1,1,1,0)
    self.frame.header.closeBtn:SetScript("OnEnter", function()
        self.frame.header.closeBtn:SetBackdropColor(1,1,1,0.15)
    end)
    self.frame.header.closeBtn:SetScript("OnLeave", function()
        self.frame.header.closeBtn:SetBackdropColor(1,1,1,0)
    end)
    self.frame.header.closeBtn:SetScript("OnLeave", function()
        self.frame.header.closeBtn:SetBackdropColor(1,1,1,0)
    end)
    self.frame.header.closeBtn:SetScript("OnMouseDown", function()
        self.frame.header.closeBtn:SetBackdropColor(1,1,1,0)
        self.frame:Hide()
    end)
    self.frame.header.closeBtn.fontString = self.frame.header.closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.frame.header.closeBtn.fontString:SetSize(self.frame.header.closeBtn:GetSize())
    self.frame.header.closeBtn.fontString:SetPoint("CENTER", self.frame.header.closeBtn, "CENTER", 0, 0)
    self.frame.header.closeBtn.fontString:SetJustifyH("CENTER")
    self.frame.header.closeBtn.fontString:SetText("X")
    local font, size = self.frame.header.closeBtn.fontString:GetFont()
    self.frame.header.closeBtn.fontString:SetFont(font, size + 1)

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
            self.frame[frameCell].fontString:SetSize(self.frame[frameCell]:GetSize())
            self.frame[frameCell].fontString:SetPoint("LEFT", self.frame[frameCell], "LEFT", self.constants.table.cellPadding, 0)
            self.frame[frameCell].fontString:SetJustifyH("LEFT")
        
        local lastCellFrame = self.frame[frameCell]
        local columnIndex = 1
        for _, character in pairs(characters) do
            local frameCell = frameRow .. "CELL" .. columnIndex
            self.frame[frameCell] = CreateFrame("Frame", frameCell, lastCellFrame, "BackdropTemplate")
            self.frame[frameCell]:SetSize(self.constants.table.colWidth, self.constants.table.rowHeight)
            self.frame[frameCell]:SetPoint("TOPLEFT", lastCellFrame, "TOPRIGHT")
            self.frame[frameCell].fontString = self.frame[frameCell]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            self.frame[frameCell].fontString:SetSize(self.frame[frameCell]:GetSize())
            self.frame[frameCell].fontString:SetPoint("CENTER", self.frame[frameCell], "CENTER", 0, 0)
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
    self.frame[dungeonHeaderCellName].fontString = self.frame[dungeonHeaderCellName]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.frame[dungeonHeaderCellName].fontString:SetSize(self.frame[dungeonHeaderCellName]:GetSize())
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
        self.frame[dungeonHeaderFrame]:SetBackdrop(self.constants.backdrop)
        self.frame[dungeonHeaderFrame]:SetBackdropColor(self.constants.colors.dark:GetRGBA())
  
        local _, _, _, texture = C_ChallengeMode.GetMapUIInfo(dungeon.id);
        local mapIconTexture = "Interface/Icons/achievement_bg_wineos_underxminutes"
        if texture ~= 0 then
            mapIconTexture = tostring(texture)
        end

        self.frame[dungeonHeaderFrame].iconFrame = self.frame[dungeonHeaderFrame]:CreateTexture(dungeonHeaderFrame .. "ICON", "BACKGROUND")
        self.frame[dungeonHeaderFrame].iconFrame:SetSize(16, 16)
        self.frame[dungeonHeaderFrame].iconFrame:SetPoint("LEFT", self.frame[dungeonHeaderFrame], "LEFT", self.constants.table.cellPadding, 0)
        self.frame[dungeonHeaderFrame].iconFrame:SetTexture(mapIconTexture)


        self.frame[dungeonHeaderFrame].fontString = self.frame[dungeonHeaderFrame]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        self.frame[dungeonHeaderFrame].fontString:SetSize(self.constants.table.colWidth - 16 - self.constants.table.cellPadding * 3, 16)
        self.frame[dungeonHeaderFrame].fontString:SetPoint("LEFT", self.frame[dungeonHeaderFrame].iconFrame, "LEFT", 16 + self.constants.table.cellPadding, 0)
        self.frame[dungeonHeaderFrame].fontString:SetVertexColor(1, 1, 1)
        self.frame[dungeonHeaderFrame].fontString:SetJustifyH("LEFT")
        local font, size = self.frame[dungeonHeaderFrame].fontString:GetFont()
        self.frame[dungeonHeaderFrame].fontString:SetFont(font, size - 1)

        local lastCellFrame = self.frame[dungeonHeaderFrame]
        local columnIndex = 1
        for _, character in pairs(characters) do
            for affixIndex = 1, 2 do
                local dungeonCellFrameLeft = dungeonRowFrame .. "CELL" .. columnIndex .. "LEFT"
                self.frame[dungeonCellFrameLeft] = CreateFrame("Frame", dungeonCellFrameLeft, lastCellFrame, "BackdropTemplate")
                self.frame[dungeonCellFrameLeft]:SetSize(self.constants.table.colWidth / 4, self.constants.table.rowHeight)
                self.frame[dungeonCellFrameLeft]:SetPoint("TOPLEFT", lastCellFrame, "TOPRIGHT")
                self.frame[dungeonCellFrameLeft].fontString = self.frame[dungeonCellFrameLeft]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                self.frame[dungeonCellFrameLeft].fontString:SetSize(self.frame[dungeonCellFrameLeft]:GetSize())
                self.frame[dungeonCellFrameLeft].fontString:SetPoint("RIGHT", self.frame[dungeonCellFrameLeft], "RIGHT", -1, 0)
                self.frame[dungeonCellFrameLeft].fontString:SetJustifyH("RIGHT")
                local dungeonCellFrameRight = dungeonRowFrame .. "CELL" .. columnIndex .. "RIGHT"
                self.frame[dungeonCellFrameRight] = CreateFrame("Frame", dungeonCellFrameRight, self.frame[dungeonCellFrameLeft], "BackdropTemplate")
                self.frame[dungeonCellFrameRight]:SetSize(self.constants.table.colWidth / 4, self.constants.table.rowHeight)
                self.frame[dungeonCellFrameRight]:SetPoint("TOPLEFT", self.frame[dungeonCellFrameLeft], "TOPRIGHT")
                self.frame[dungeonCellFrameRight].fontString = self.frame[dungeonCellFrameRight]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                self.frame[dungeonCellFrameRight].fontString:SetSize(self.frame[dungeonCellFrameRight]:GetSize())
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
    if not self.frame then return end

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
        self.frame[characterCellName].fontString:SetText(row.label)

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
        self.frame[dungeonHeaderFrame].fontString:SetText(dungeon.name)

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
    self.frame.header:SetWidth(self.frame:GetWidth())
end
