---@diagnostic disable: undefined-field, inject-field, duplicate-set-field
AlterEgo = LibStub("AceAddon-3.0"):NewAddon("AlterEgo", "AceConsole-3.0", "AceTimer-3.0", "AceEvent-3.0", "AceBucket-3.0")
AlterEgo.constants = {
    table = {
        rowHeight = 22,
        colWidth = 120,
        cellPadding = 6,
        cellLength = 18
    },
    frame = {
        titleBarHeight = 28,
        borderWidth = 3
    },
    colors = {
        primary = CreateColorFromHexString("FF21232C"),
        border = CreateColorFromHexString("FF14151A"),
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
    -- self.frame:SetBackdrop({
    --     bgFile = "Interface/BUTTONS/WHITE8X8",
    --     edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    --     edgeSize = 16,
    --     tile = false,
    --     tileEdge = true,
    --     insets = {top = 4, right = 4, bottom = 4, left = 4}
    -- })

    -- TODO: Consider this the border color
    self.frame:SetBackdropColor(self.constants.colors.darker:GetRGBA())
    -- self.frame:SetBackdropColor(0, 1, 0, 1)
    -- self.frame:SetBackdropBorderColor(self.constants.colors.darker:GetRGBA())
    self.frame:SetFrameStrata("HIGH")
    self.frame:SetClampedToScreen(true)
    self.frame:SetMovable(true)

    -- TODO: Uncomment for release
    -- tinsert(UISpecialFrames, self.frame:GetName())

    -- self.frame.border = CreateFrame("Frame", self.frame:GetName() .. "BORDER", UIParent, "BackdropTemplate")
    -- self.frame.border:SetPoint("TOPLEFT", self.frame, "TOPLEFT", -self.constants.frame.borderWidth, self.constants.frame.borderWidth)
    -- self.frame.border:SetBackdrop({
    --     edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
	--     edgeSize = 16,
    --     tile = false,
    --     tileEdge = true,
    --     insets = {top = 0, right = 0, bottom = 0, left = 0}
    -- })
    -- self.frame.border:SetBackdropBorderColor(self.constants.colors.darker:GetRGBA())

    self.frame.titlebar = CreateFrame("Frame", self.frame:GetName() .. "TITLEBAR", self.frame, "BackdropTemplate")
    self.frame.titlebar:SetPoint("TOPLEFT", self.frame, "TOPLEFT", self.constants.frame.borderWidth, -self.constants.frame.borderWidth)
    self.frame.titlebar:SetBackdrop(self.constants.backdrop)
    -- self.frame.titlebar:SetBackdropColor(1, 0, 0, 1)
    self.frame.titlebar:SetBackdropColor(self.constants.colors.darker:GetRGBA())
    self.frame.titlebar:EnableMouse(true)
    self.frame.titlebar:RegisterForDrag("LeftButton")
    self.frame.titlebar:SetScript("OnDragStart", function()
        self.frame:StartMoving()
    end)
    self.frame.titlebar:SetScript("OnDragStop", function()
        self.frame:StopMovingOrSizing()
    end)

    self.frame.titlebar.fontString = self.frame.titlebar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.frame.titlebar.fontString:SetPoint("LEFT", self.frame.titlebar, "LEFT", 6, 0)
    self.frame.titlebar.fontString:SetJustifyH("LEFT")
    self.frame.titlebar.fontString:SetText("AlterEgo")
    local font, size, flags = self.frame.titlebar.fontString:GetFont()
    self.frame.titlebar.fontString:SetFont(font, size + 2, flags)
    self.frame.titlebar.fontString:SetVertexColor(1, 1, 1, 1)
    self.frame.titlebar.closeBtn = CreateFrame("Frame", self.frame.titlebar:GetName() .. "CLOSEBTN", self.frame.titlebar, "BackdropTemplate")
    self.frame.titlebar.closeBtn:SetPoint("RIGHT", self.frame.titlebar, "RIGHT", -2, 0)
    self.frame.titlebar.closeBtn:SetSize(self.constants.table.rowHeight, self.constants.table.rowHeight)
    self.frame.titlebar.closeBtn:SetBackdrop(self.constants.backdrop)
    self.frame.titlebar.closeBtn:SetBackdropColor(1,1,1,0)
    self.frame.titlebar.closeBtn:SetScript("OnEnter", function()
        self.frame.titlebar.closeBtn:SetBackdropColor(1,1,1,0.1)
    end)
    self.frame.titlebar.closeBtn:SetScript("OnLeave", function()
        self.frame.titlebar.closeBtn:SetBackdropColor(1,1,1, 0)
    end)
    self.frame.titlebar.closeBtn:SetScript("OnMouseDown", function()
        self.frame.titlebar.closeBtn:SetBackdropColor(1,1,1,0)
        self.frame:Hide()
    end)
    self.frame.titlebar.closeBtn.fontString = self.frame.titlebar.closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    self.frame.titlebar.closeBtn.fontString:SetSize(self.frame.titlebar.closeBtn:GetSize())
    self.frame.titlebar.closeBtn.fontString:SetPoint("CENTER", self.frame.titlebar.closeBtn, "CENTER", 1, 0)
    self.frame.titlebar.closeBtn.fontString:SetJustifyH("CENTER")
    self.frame.titlebar.closeBtn.fontString:SetText("X")
    self.frame.titlebar.closeBtn.fontString:SetVertexColor(1, 1, 1, 1)
    local font, size = self.frame.titlebar.closeBtn.fontString:GetFont()
    self.frame.titlebar.closeBtn.fontString:SetFont(font, size + 1)

    self.frame.body = CreateFrame("Frame", self.frame:GetName() .. "BODY", self.frame, "BackdropTemplate")
    self.frame.body:SetPoint("TOPLEFT", self.frame.titlebar, "BOTTOMLEFT", 0, 0)
    self.frame.body:SetBackdrop(self.constants.backdrop)
    self.frame.body:SetBackdropColor(self.constants.colors.primary:GetRGBA())

    local rowIndex = 0

    -- Character loop
    for i, row in ipairs(self.constants.characterTable) do
        local frameRow = self.frame.body:GetName() .. "ROW" .. rowIndex
        self.frame.body[frameRow] = CreateFrame("Frame", frameRow, self.frame.body, "BackdropTemplate")
        self.frame.body[frameRow]:SetPoint("TOPLEFT", self.frame.body, "TOPLEFT", 0, -self.constants.table.rowHeight * rowIndex)
        -- self.frame.body[frameRow]:SetSize(self.frame.body:GetWidth(), self.constants.table.rowHeight)
        self.frame.body[frameRow]:SetBackdrop(self.constants.backdrop)
        self.frame.body[frameRow]:SetBackdropColor(0, 0, 0, 0)
        self.frame.body[frameRow]:SetScript("OnEnter", function()
            self.frame.body[frameRow]:SetBackdropColor(self.constants.colors.highlight:GetRGBA())
        end)
        self.frame.body[frameRow]:SetScript("OnLeave", function()
                self.frame.body[frameRow]:SetBackdropColor(0, 0, 0, 0)
        end)

        local frameCell = frameRow .. "CELL0"
        self.frame.body[frameCell] = CreateFrame("Frame", frameCell, self.frame.body[frameRow], "BackdropTemplate")
        -- self.frame.body[frameCell]:SetSize(self.constants.table.colWidth, self.constants.table.rowHeight)
        self.frame.body[frameCell]:SetPoint("TOPLEFT", self.frame.body[frameRow], "TOPLEFT")
        self.frame.body[frameCell]:SetBackdrop(self.constants.backdrop)
        self.frame.body[frameCell]:SetBackdropColor(self.constants.colors.dark:GetRGBA())
        -- self.frame.body[frameCell]:SetBackdropColor(1, 1, 0, 1)
        self.frame.body[frameCell].fontString = self.frame.body[frameCell]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        -- self.frame.body[frameCell].fontString:SetSize(self.frame.body[frameCell]:GetSize())
        self.frame.body[frameCell].fontString:SetPoint("LEFT", self.frame.body[frameCell], "LEFT", self.constants.table.cellPadding, 0)
        self.frame.body[frameCell].fontString:SetJustifyH("LEFT")
        
        local lastCellFrame = self.frame.body[frameCell]
        local columnIndex = 1
        for _, character in pairs(characters) do
            local frameCell = frameRow .. "CELL" .. columnIndex
            self.frame.body[frameCell] = CreateFrame("Frame", frameCell, lastCellFrame, "BackdropTemplate")
            -- self.frame.body[frameCell]:SetSize(self.constants.table.colWidth, self.constants.table.rowHeight)
            self.frame.body[frameCell]:SetPoint("TOPLEFT", lastCellFrame, "TOPRIGHT")
            self.frame.body[frameCell].fontString = self.frame.body[frameCell]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            -- self.frame.body[frameCell].fontString:SetSize(self.frame.body[frameCell]:GetSize())
            self.frame.body[frameCell].fontString:SetPoint("CENTER", self.frame.body[frameCell], "CENTER", 0, 0)
            self.frame.body[frameCell].fontString:SetJustifyH("CENTER")
            lastCellFrame = self.frame.body[frameCell]
            columnIndex = columnIndex + 1
        end

        rowIndex = rowIndex + 1
    end

    -- Dungeon Header Row
    local dungeonHeaderRowName = self.frame.body:GetName() .. "DUNGEONHEADERROW"
    self.frame.body[dungeonHeaderRowName] = CreateFrame("Frame", dungeonHeaderRowName, self.frame.body, "BackdropTemplate")
    self.frame.body[dungeonHeaderRowName]:SetPoint("TOPLEFT", self.frame.body, "TOPLEFT", 0, -self.constants.table.rowHeight * rowIndex)
    -- self.frame.body[dungeonHeaderRowName]:SetSize(self.frame.body:GetWidth(), self.constants.table.rowHeight)
    self.frame.body[dungeonHeaderRowName]:SetBackdrop(self.constants.backdrop)
    self.frame.body[dungeonHeaderRowName]:SetBackdropColor(self.constants.colors.dark:GetRGBA())
    
    -- Dungeon Header Cell 0
    local dungeonHeaderCellName = dungeonHeaderRowName .. "CELL0"
    self.frame.body[dungeonHeaderCellName] = CreateFrame("Frame", dungeonHeaderCellName, self.frame.body[dungeonHeaderRowName], "BackdropTemplate")
    -- self.frame.body[dungeonHeaderCellName]:SetSize(self.constants.table.colWidth, self.constants.table.rowHeight)
    self.frame.body[dungeonHeaderCellName]:SetPoint("TOPLEFT", self.frame.body[dungeonHeaderRowName], "TOPLEFT")
    self.frame.body[dungeonHeaderCellName].fontString = self.frame.body[dungeonHeaderCellName]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- self.frame.body[dungeonHeaderCellName].fontString:SetSize(self.frame.body[dungeonHeaderCellName]:GetSize())
    self.frame.body[dungeonHeaderCellName].fontString:SetPoint("LEFT", self.frame.body[dungeonHeaderCellName], "LEFT", self.constants.table.cellPadding, 0)
    self.frame.body[dungeonHeaderCellName].fontString:SetText("Dungeons:")
    self.frame.body[dungeonHeaderCellName].fontString:SetJustifyH("LEFT")

    -- Dungeon Header Cell X
    local lastCellFrame = self.frame.body[dungeonHeaderCellName]
    local columnIndex = 1
    for _, character in pairs(characters) do
        -- BUG: USE AFFIX TABLE
        for affixIndex = 1, 2 do
            dungeonHeaderCellName = dungeonHeaderRowName .. "CELL" .. columnIndex
            self.frame.body[dungeonHeaderCellName] = CreateFrame("Frame",  dungeonHeaderCellName, lastCellFrame, "BackdropTemplate")
            -- self.frame.body[dungeonHeaderCellName]:SetSize(self.constants.table.colWidth / 2, self.constants.table.rowHeight)
            self.frame.body[dungeonHeaderCellName]:SetPoint("TOPLEFT", lastCellFrame, "TOPRIGHT")
            self.frame.body[dungeonHeaderCellName].iconFrame = self.frame.body[dungeonHeaderCellName]:CreateTexture(dungeonHeaderCellName .. "ICON", "BACKGROUND")
            self.frame.body[dungeonHeaderCellName].iconFrame:SetSize(16, 16)
            self.frame.body[dungeonHeaderCellName].iconFrame:SetPoint("CENTER", self.frame.body[dungeonHeaderCellName], "CENTER", 0, 0)
            self.frame.body[dungeonHeaderCellName].iconFrame:SetTexture(affixIndex == 2 and "Interface/Icons/ability_toughness" or "Interface/Icons/achievement_boss_archaedas")
            lastCellFrame = self.frame.body[dungeonHeaderCellName]
            columnIndex = columnIndex + 1
        end
    end

    rowIndex = rowIndex + 1

    -- Dungeon Values
    for i, dungeon in ipairs(self.constants.dungeons) do
        local dungeonRowFrame = self.frame.body:GetName() .. "ROW" .. rowIndex
        self.frame.body[dungeonRowFrame] = CreateFrame("Frame", dungeonRowFrame, self.frame.body, "BackdropTemplate")
        self.frame.body[dungeonRowFrame]:SetPoint("TOPLEFT", self.frame.body, "TOPLEFT", 0, -self.constants.table.rowHeight * rowIndex)
        -- self.frame.body[dungeonRowFrame]:SetSize(self.frame.body:GetWidth(), self.constants.table.rowHeight)
        self.frame.body[dungeonRowFrame]:SetBackdrop(self.constants.backdrop)
        if i % 2 == 0 then
            self.frame.body[dungeonRowFrame]:SetBackdropColor(self.constants.colors.light:GetRGBA())
        else
            self.frame.body[dungeonRowFrame]:SetBackdropColor(0,0,0,0)
        end
        self.frame.body[dungeonRowFrame]:SetScript("OnEnter", function()
            self.frame.body[dungeonRowFrame]:SetBackdropColor(self.constants.colors.highlight:GetRGBA())
        end)
        self.frame.body[dungeonRowFrame]:SetScript("OnLeave", function()
            if i % 2 == 0 then
                self.frame.body[dungeonRowFrame]:SetBackdropColor(self.constants.colors.light:GetRGBA())
            else
                self.frame.body[dungeonRowFrame]:SetBackdropColor(0,0,0,0)
            end
        end)

        local dungeonHeaderFrame = dungeonRowFrame .. "CELL0"
        self.frame.body[dungeonHeaderFrame] = CreateFrame("Frame", dungeonHeaderFrame, self.frame.body[dungeonRowFrame], "BackdropTemplate")
        -- self.frame.body[dungeonHeaderFrame]:SetSize(self.constants.table.colWidth, self.constants.table.rowHeight)
        self.frame.body[dungeonHeaderFrame]:SetPoint("TOPLEFT", self.frame.body[dungeonRowFrame], "TOPLEFT")
        self.frame.body[dungeonHeaderFrame]:SetBackdrop(self.constants.backdrop)
        self.frame.body[dungeonHeaderFrame]:SetBackdropColor(self.constants.colors.dark:GetRGBA())
  
        local _, _, _, texture = C_ChallengeMode.GetMapUIInfo(dungeon.id);
        local mapIconTexture = "Interface/Icons/achievement_bg_wineos_underxminutes"
        if texture ~= 0 then
            mapIconTexture = tostring(texture)
        end

        self.frame.body[dungeonHeaderFrame].iconFrame = self.frame.body[dungeonHeaderFrame]:CreateTexture(dungeonHeaderFrame .. "ICON", "BACKGROUND")
        self.frame.body[dungeonHeaderFrame].iconFrame:SetSize(16, 16)
        self.frame.body[dungeonHeaderFrame].iconFrame:SetPoint("LEFT", self.frame.body[dungeonHeaderFrame], "LEFT", self.constants.table.cellPadding, 0)
        self.frame.body[dungeonHeaderFrame].iconFrame:SetTexture(mapIconTexture)
        self.frame.body[dungeonHeaderFrame].fontString = self.frame.body[dungeonHeaderFrame]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        -- self.frame.body[dungeonHeaderFrame].fontString:SetSize(self.constants.table.colWidth - 16 - self.constants.table.cellPadding * 3, 16)
        self.frame.body[dungeonHeaderFrame].fontString:SetPoint("LEFT", self.frame.body[dungeonHeaderFrame].iconFrame, "LEFT", 16 + self.constants.table.cellPadding, 0)
        self.frame.body[dungeonHeaderFrame].fontString:SetVertexColor(1, 1, 1)
        self.frame.body[dungeonHeaderFrame].fontString:SetJustifyH("LEFT")
        local font, size = self.frame.body[dungeonHeaderFrame].fontString:GetFont()
        self.frame.body[dungeonHeaderFrame].fontString:SetFont(font, size - 1)

        local lastCellFrame = self.frame.body[dungeonHeaderFrame]
        local columnIndex = 1
        for _, character in pairs(characters) do
            -- BUG: USE AFFIX TABLE
            for affixIndex = 1, 2 do
                local dungeonCellFrameLeft = dungeonRowFrame .. "CELL" .. columnIndex .. "LEFT"
                self.frame.body[dungeonCellFrameLeft] = CreateFrame("Frame", dungeonCellFrameLeft, lastCellFrame, "BackdropTemplate")
                -- self.frame.body[dungeonCellFrameLeft]:SetSize(self.constants.table.colWidth / 4, self.constants.table.rowHeight)
                self.frame.body[dungeonCellFrameLeft]:SetPoint("TOPLEFT", lastCellFrame, "TOPRIGHT")
                self.frame.body[dungeonCellFrameLeft].fontString = self.frame.body[dungeonCellFrameLeft]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                -- self.frame.body[dungeonCellFrameLeft].fontString:SetSize(self.frame.body[dungeonCellFrameLeft]:GetSize())
                self.frame.body[dungeonCellFrameLeft].fontString:SetPoint("RIGHT", self.frame.body[dungeonCellFrameLeft], "RIGHT", -1, 0)
                self.frame.body[dungeonCellFrameLeft].fontString:SetJustifyH("RIGHT")
                local dungeonCellFrameRight = dungeonRowFrame .. "CELL" .. columnIndex .. "RIGHT"
                self.frame.body[dungeonCellFrameRight] = CreateFrame("Frame", dungeonCellFrameRight, self.frame.body[dungeonCellFrameLeft], "BackdropTemplate")
                -- self.frame.body[dungeonCellFrameRight]:SetSize(self.constants.table.colWidth / 4, self.constants.table.rowHeight)
                self.frame.body[dungeonCellFrameRight]:SetPoint("TOPLEFT", self.frame.body[dungeonCellFrameLeft], "TOPRIGHT")
                self.frame.body[dungeonCellFrameRight].fontString = self.frame.body[dungeonCellFrameRight]:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                -- self.frame.body[dungeonCellFrameRight].fontString:SetSize(self.frame.body[dungeonCellFrameRight]:GetSize())
                self.frame.body[dungeonCellFrameRight].fontString:SetPoint("LEFT", self.frame.body[dungeonCellFrameRight], "LEFT", 1, 0)
                self.frame.body[dungeonCellFrameRight].fontString:SetJustifyH("LEFT")
                lastCellFrame = self.frame.body[dungeonCellFrameRight]
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
    local frameWidth = 0
    local rowIndex = 0

    -- First column
    frameWidth = frameWidth + self.constants.table.colWidth

    -- Character columns
    for _, __ in pairs(characters) do
        frameWidth = frameWidth + self.constants.table.colWidth
    end

    local frameWidthInner = frameWidth
    frameWidth = frameWidth + self.constants.frame.borderWidth * 2

    -- Character loop
    for i, row in ipairs(self.constants.characterTable) do
        local characterRowFrame = self.frame.body:GetName() .. "ROW" .. rowIndex
        self.frame.body[characterRowFrame]:SetSize(frameWidthInner, self.constants.table.rowHeight)

        local characterCellName = characterRowFrame .. "CELL0"
        self.frame.body[characterCellName]:SetSize(self.constants.table.colWidth, self.constants.table.rowHeight)
        self.frame.body[characterCellName].fontString:SetSize(self.frame.body[characterCellName]:GetSize())
        self.frame.body[characterCellName].fontString:SetText(row.label)

        local columnIndex = 1
        for _, character in pairs(characters) do
            characterCellName = characterRowFrame .. "CELL" .. columnIndex
            self.frame.body[characterCellName]:SetSize(self.constants.table.colWidth, self.constants.table.rowHeight)
            self.frame.body[characterCellName].fontString:SetText(row.value(self, character))
            self.frame.body[characterCellName].fontString:SetSize(self.frame.body[characterCellName]:GetSize())
            columnIndex = columnIndex + 1
        end

        rowIndex = rowIndex + 1
    end

    -- Dungeon Header Row
    local dungeonHeaderRowName = self.frame.body:GetName() .. "DUNGEONHEADERROW"
    self.frame.body[dungeonHeaderRowName]:SetSize(frameWidthInner, self.constants.table.rowHeight)
    
    -- Dungeon Header Cell 0
    local dungeonHeaderCellName = dungeonHeaderRowName .. "CELL0"
    self.frame.body[dungeonHeaderCellName]:SetSize(self.constants.table.colWidth, self.constants.table.rowHeight)
    self.frame.body[dungeonHeaderCellName].fontString:SetSize(self.frame.body[dungeonHeaderCellName]:GetSize())

    -- Dungeon Header Cell X
    local columnIndex = 1
    for _, character in pairs(characters) do
        -- BUG: USE AFFIX TABLE
        for affixIndex = 1, 2 do
            dungeonHeaderCellName = dungeonHeaderRowName .. "CELL" .. columnIndex
            self.frame.body[dungeonHeaderCellName]:SetSize(self.constants.table.colWidth / 2, self.constants.table.rowHeight)
            columnIndex = columnIndex + 1
        end
    end

    rowIndex = rowIndex + 1

    -- Dungeon Values
    for i, dungeon in ipairs(self.constants.dungeons) do
        local dungeonRowFrame = self.frame.body:GetName() .. "ROW" .. rowIndex
        self.frame.body[dungeonRowFrame]:SetSize(frameWidthInner, self.constants.table.rowHeight)

        local dungeonHeaderFrame = dungeonRowFrame .. "CELL0"
        self.frame.body[dungeonHeaderFrame]:SetSize(self.constants.table.colWidth, self.constants.table.rowHeight)
        self.frame.body[dungeonHeaderFrame].fontString:SetSize(self.constants.table.colWidth - 16 - self.constants.table.cellPadding * 3, 16)
        self.frame.body[dungeonHeaderFrame].fontString:SetText(dungeon.name)

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
                self.frame.body[dungeonCellFrameLeft]:SetSize(self.constants.table.colWidth / 4, self.constants.table.rowHeight)
                self.frame.body[dungeonCellFrameLeft].fontString:SetSize(self.frame.body[dungeonCellFrameLeft]:GetSize())
                self.frame.body[dungeonCellFrameLeft].fontString:SetText("|c" .. levelColor .. level .. "|r")
                local dungeonCellFrameRight = dungeonRowFrame .. "CELL" .. columnIndex .. "RIGHT"
                self.frame.body[dungeonCellFrameRight]:SetSize(self.constants.table.colWidth / 4, self.constants.table.rowHeight)
                self.frame.body[dungeonCellFrameRight].fontString:SetSize(self.frame.body[dungeonCellFrameRight]:GetSize())
                self.frame.body[dungeonCellFrameRight].fontString:SetText(tier)
                columnIndex = columnIndex + 1
            end
        end

        rowIndex = rowIndex + 1

        -- Frame sizing
        self.frame:SetSize(frameWidth, self.constants.frame.titleBarHeight + self.constants.table.rowHeight * rowIndex + self.constants.frame.borderWidth * 2)
        self.frame.titlebar:SetSize(frameWidthInner, self.constants.frame.titleBarHeight)
        self.frame.titlebar.fontString:SetSize(self.frame.titlebar:GetSize())
        self.frame.body:SetSize(frameWidthInner, self.constants.table.rowHeight * rowIndex)
    end
end
