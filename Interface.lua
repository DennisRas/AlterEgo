---@diagnostic disable: inject-field, deprecated
function AlterEgo:GetCharacterInfo()
    local dungeons = self:GetDungeons()
    return {
        {
            label = CHARACTER,
            value = function(character)
                local name = "-"
                local nameColor = "ffffffff"
                if character.info.name ~= nil then
                    name = character.info.name
                end
                if character.info.class.file ~= nil then
                    local classColor = C_ClassColor.GetClassColor(character.info.class.file)
                    if classColor ~= nil then
                        nameColor = classColor.GenerateHexColor(classColor)
                    end
                end
                return "|c" .. nameColor .. name .. "|r"
            end,
            OnEnter = function(character)
                local name = "-"
                local nameColor = "ffffffff"
                if character.info.name ~= nil then
                    name = character.info.name
                end
                if character.info.class.file ~= nil then
                    local classColor = C_ClassColor.GetClassColor(character.info.class.file)
                    if classColor ~= nil then
                        nameColor = classColor.GenerateHexColor(classColor)
                    end
                end
                GameTooltip:AddLine("|c" .. nameColor .. name .. "|r");
                GameTooltip:AddLine(format("Level %d %s", character.info.level, character.info.race ~= nil and character.info.race.name or ""), 1, 1, 1);
                if character.info.factionGroup ~= nil and character.info.factionGroup.localized~= nil then
                    GameTooltip:AddLine(character.info.factionGroup.localized, 1, 1, 1);
                end
                if character.lastUpdate ~= nil then
                    GameTooltip:AddLine(" ");
                    GameTooltip:AddLine(format("Last update:\n|cffffffff%s|r", date("%c", character.lastUpdate)), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                end
            end,
            enabled = true,
        },
        {
            label = "Realm",
            value = function(character)
                local realm = "-"
                local realmColor = "ffffffff"
                if character.info.realm ~= nil then
                    realm = character.info.realm
                end
                return "|c" .. realmColor .. realm .. "|r"
            end,
            tooltip = false,
            enabled = true,
        },
        {
            label = STAT_AVERAGE_ITEM_LEVEL,
            value = function(character)
                local itemLevel = ""
                local itemLevelColor = "ffffffff"
                if character.info.ilvl ~= nil then
                    if character.info.ilvl.level ~= nil then
                        itemLevel = tostring(floor(character.info.ilvl.level))
                    end
                    if character.info.ilvl.color then
                        itemLevelColor = character.info.ilvl.color
                    end
                end
                return "|c" .. itemLevelColor .. itemLevel .. "|r"
            end,
            OnEnter = function(character)
                local itemLevelTooltip = ""
                local itemLevelTooltip2 = STAT_AVERAGE_ITEM_LEVEL_TOOLTIP
                if character.info.ilvl ~= nil then
                    if character.info.ilvl.level ~= nil then
                        itemLevelTooltip = itemLevelTooltip .. HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVERAGE_ITEM_LEVEL) .. " " .. floor(character.info.ilvl.level)
                    end
                    if character.info.ilvl.level ~= nil and character.info.ilvl.equipped ~= nil and character.info.ilvl.level ~= character.info.ilvl.equipped then
                        itemLevelTooltip = itemLevelTooltip .. "  " .. format(STAT_AVERAGE_ITEM_LEVEL_EQUIPPED, character.info.ilvl.equipped);
                    end
                    if character.info.ilvl.level ~= nil then
                        itemLevelTooltip = itemLevelTooltip .. FONT_COLOR_CODE_CLOSE
                    end
                    if character.info.ilvl.level ~= nil and character.info.ilvl.pvp ~= nil and floor(character.info.ilvl.level) ~= character.info.ilvl.pvp then
                        itemLevelTooltip2 = itemLevelTooltip2.."\n\n"..STAT_AVERAGE_PVP_ITEM_LEVEL:format(tostring(floor(character.info.ilvl.pvp)));
                    end
                end
                GameTooltip:AddLine(itemLevelTooltip, 1, 1, 1);
                GameTooltip:AddLine(itemLevelTooltip2, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
            end,
            enabled = true,
        },
        {
            label = "Rating",
            value = function(character)
                local rating = "-"
                local ratingColor = "ffffffff"
                if character.mythicplus.rating ~= nil then
                    local color = C_ChallengeMode.GetDungeonScoreRarityColor(character.mythicplus.rating)
                    if color ~= nil then
                        ratingColor = color.GenerateHexColor(color)
                    end
                    rating = tostring(character.mythicplus.rating)
                end
                return "|c" .. ratingColor .. rating .. "|r"
            end,
            OnEnter = function(character)
                local rating = "-"
                local ratingColor = "ffffffff"
                local bestSeasonScore = nil
                local bestSeasonScoreColor = "ffffffff"
                local bestSeasonNumber = nil
                if character.mythicplus.bestSeasonScore ~= nil then
                    bestSeasonScore = character.mythicplus.bestSeasonScore
                    local color = C_ChallengeMode.GetDungeonScoreRarityColor(bestSeasonScore)
                    if color ~= nil then
                        bestSeasonScoreColor = color.GenerateHexColor(color)
                    end
                end
                if character.mythicplus.bestSeasonNumber ~= nil then
                    bestSeasonNumber = character.mythicplus.bestSeasonNumber
                end
                if character.mythicplus.rating ~= nil then
                    local color = C_ChallengeMode.GetDungeonScoreRarityColor(character.mythicplus.rating)
                    if color ~= nil then
                        ratingColor = color.GenerateHexColor(color)
                    end
                    rating = tostring(character.mythicplus.rating)
                end
                GameTooltip:AddLine("Mythic+ Rating", 1, 1, 1);
                GameTooltip:AddLine("Current Season: " .. "|c" .. ratingColor .. rating .. "|r", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                GameTooltip:AddLine("Runs this Season: " .. "|cffffffff" .. (#character.mythicplus.runHistory or 0) .. "|r", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                if bestSeasonScore ~= nil then
                    local score = "|c" .. bestSeasonScoreColor .. bestSeasonScore .. "|r"
                    if bestSeasonNumber ~= nil then
                        score = score .. LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(" (Season " .. bestSeasonNumber .. ")")
                    end
                    GameTooltip:AddLine("Best Season: " .. score, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                end
                if character.mythicplus.dungeons ~= nil and AE_table_count(character.mythicplus.dungeons) > 0 then
                    GameTooltip:AddLine(" ")
                    for _, dungeon in pairs(character.mythicplus.dungeons) do
                        local dungeonName = C_ChallengeMode.GetMapUIInfo(dungeon.id)
                        if dungeonName ~= nil then
                            GameTooltip:AddDoubleLine(dungeonName, "+" .. tostring(dungeon.level), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1, 1, 1)
                        end
                    end
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("<Shift Click to Link to Chat>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
                end
            end,
            OnClick = function(character)
                if character.mythicplus.dungeons ~= nil and AE_table_count(character.mythicplus.dungeons) > 0 then
                    if IsModifiedClick("CHATLINK") then
                        local dungeonScoreDungeonTable = {};
                        for _, dungeon in pairs(character.mythicplus.dungeons) do
                            table.insert(dungeonScoreDungeonTable, dungeon.id);
                            table.insert(dungeonScoreDungeonTable, dungeon.finishedSuccess and 1 or 0);
                            table.insert(dungeonScoreDungeonTable, dungeon.level);
                        end
                        local dungeonScoreTable = {
                            character.mythicplus.rating,
                            character.GUID,
                            character.info.name,
                            character.info.class.id,
                            math.ceil(character.info.ilvl.level),
                            character.info.level,
                            character.mythicplus.runHistory and AE_table_count(character.mythicplus.runHistory) or 0,
                            character.mythicplus.bestSeasonScore,
                            character.mythicplus.bestSeasonNumber,
                            unpack(dungeonScoreDungeonTable)
                        };
                        local link = NORMAL_FONT_COLOR:WrapTextInColorCode(LinkUtil.FormatLink("dungeonScore", DUNGEON_SCORE_LINK, unpack(dungeonScoreTable)));
                        if not ChatEdit_InsertLink(link) then
                            ChatFrame_OpenChat(link);
                        end
                    end
                end
            end,
            enabled = true,
        },
        {
            label = "Current Keystone",
            value = function(character)
                local currentKeystone = "-"
                if character.mythicplus.keystone ~= nil and character.mythicplus.keystone.mapId ~= nil and character.mythicplus.keystone.level ~= nil then
                    local dungeon = self:GetDungeonByMapId(character.mythicplus.keystone.mapId)
                    if dungeon then
                        currentKeystone = dungeon.abbr .. " +" .. tostring(character.mythicplus.keystone.level)
                    end
                end
                return currentKeystone
            end,
            enabled = true,
        },
        {
            label = "Vault",
            value = function(character)
                if character.vault.hasAvailableRewards == true then
                    return WrapTextInColorCode("Rewards", GREEN_FONT_COLOR:GenerateHexColor())
                end
                return ""
            end,
            OnEnter = function(character)
                if character.vault.hasAvailableRewards == true then
                    GameTooltip:AddLine("It's payday!", 1, 1, 1)
                    GameTooltip:AddLine(GREAT_VAULT_REWARDS_WAITING, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b, true)
                end
            end,
            backgroundColor = {r = 0, g = 0, b = 0, a = 0.3}
        },
        {
            label = WrapTextInColorCode("Raids", "ffffffff"),
            value = function(character)
                local vaultLevels = ""
                if character.vault.slots ~= nil then
                    for _, slot in ipairs(character.vault.slots) do
                        if slot.type == Enum.WeeklyRewardChestThresholdType.Raid then
                            local level = "-"
                            if slot.level > 0 then
                                local name = GetDifficultyInfo(slot.level)
                                -- local name = DifficultyUtil.GetDifficultyName(slot.level); -- WTF BLizzard?
                                level = tostring(name):sub(1, 1)
                            end
                            vaultLevels = vaultLevels .. level .. "  "
                        end
                    end
                end
                if vaultLevels == "" then
                    vaultLevels = "-  -  -"
                end
                return vaultLevels:trim()
            end,
            enabled = self.db.global.raids.enabled,
        },
        {
            label = WrapTextInColorCode("Dungeons", "ffffffff"),
            value = function(character)
                local vaultLevels = ""
                if character.vault.slots ~= nil then
                    for _, slot in ipairs(character.vault.slots) do
                        if slot.type == Enum.WeeklyRewardChestThresholdType.MythicPlus then
                            local level = "-"
                            if slot.level > 0 then
                                level = tostring(slot.level)
                            end
                            vaultLevels = vaultLevels .. level .. "  "
                        end
                    end
                end
                if vaultLevels == "" then
                    vaultLevels = "-  -  -"
                end
                return vaultLevels:trim()
            end,
            OnEnter = function(character)
                local runs = AE_table_filter(character.mythicplus.runHistory, function(run) return run.thisWeek == true end)
                local countRuns = AE_table_count(runs) or 0
                GameTooltip:AddLine("Vault Progress", 1, 1, 1);
                GameTooltip:AddLine("Runs this Week: " .. "|cffffffff" .. countRuns .. "|r", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                GameTooltip:AddLine(" ")

                local function GetLowestLevelInTopRuns(numRuns)
                    table.sort(runs, function(a, b) return a.level > b.level; end);
                    local lowestLevel;
                    local lowestCount = 0;
                    for i = math.min(numRuns, #runs), 1, -1 do
                        local run = runs[i];
                        if not lowestLevel then
                            lowestLevel = run.level;
                        end
                        if lowestLevel == run.level then
                            lowestCount = lowestCount + 1;
                        else
                            break;
                        end
                    end
                    return lowestLevel, lowestCount;
                end

                -- local runHistory = C_WeeklyRewards.GetActivities(Enum.WeeklyRewardChestThresholdType.MythicPlus);
                local slots = AE_table_filter(character.vault.slots, function(slot) return slot.type == Enum.WeeklyRewardChestThresholdType.MythicPlus end)
                table.sort(slots, function(a, b) return a.index < b.index; end);
                local lastCompletedIndex = 0;
                for i, activityInfo in ipairs(slots) do
                    if activityInfo.progress >= activityInfo.threshold then
                        lastCompletedIndex = i;
                    end
                end
                if lastCompletedIndex == 0 then
                    GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_INCOMPLETE);
                else
                    if lastCompletedIndex == #slots then
                        GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_THIRD);
                        GameTooltip_AddBlankLineToTooltip(GameTooltip);
                        GameTooltip_AddColoredLine(GameTooltip, GREAT_VAULT_IMPROVE_REWARD, GREEN_FONT_COLOR);
                        local info = slots[lastCompletedIndex];
                        local level, count = GetLowestLevelInTopRuns(info.threshold);
                        GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_IMPROVE:format(count, level + 1));
                    else
                        local nextInfo = slots[lastCompletedIndex + 1];
                        local textString = (lastCompletedIndex == 1) and GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_FIRST or GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_SECOND;
                        local level, count = GetLowestLevelInTopRuns(nextInfo.threshold);
                        GameTooltip_AddNormalLine(GameTooltip, textString:format(nextInfo.threshold - nextInfo.progress, nextInfo.threshold, level));
                    end
                end

                if countRuns > 0 then
                    GameTooltip:AddLine(" ")
                    table.sort(runs, function(a, b) return a.level > b.level end)
                    for i, run in ipairs(runs) do
                        local threshold = false
                        for _, slot in ipairs(character.vault.slots) do
                            if slot.type == Enum.WeeklyRewardChestThresholdType.MythicPlus and i == slot.threshold then
                                threshold = true
                            end
                        end
                        local dungeon = AE_table_get(dungeons, "id", run.mapChallengeModeID)
                        if dungeon then
                            local rewardLevel = C_MythicPlus.GetRewardLevelFromKeystoneLevel(run.level)
                            if threshold then
                                GameTooltip:AddDoubleLine(dungeon.name, string.format("+%d (%d)", run.level, rewardLevel), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
                            else
                                GameTooltip:AddDoubleLine(dungeon.name, string.format("+%d (%d)", run.level, rewardLevel), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1, 1, 1)
                            end
                        end
                        if i == 8 then
                            break
                        end
                    end
                end
                -- if countRuns < 8 then
                --     for i = countRuns, 8 do
                --         GameTooltip:AddDoubleLine("-", "-", LIGHTGRAY_FONT_COLOR.r, LIGHTGRAY_FONT_COLOR.g, LIGHTGRAY_FONT_COLOR.b, LIGHTGRAY_FONT_COLOR.r, LIGHTGRAY_FONT_COLOR.g, LIGHTGRAY_FONT_COLOR.b)
                --     end
                -- end
            end,
            enabled = true,
        },
    }
end
local assets = {
    font = {
        file = "Fonts\\FRIZQT__.TTF",
        size = 12,
        flags = ""
    },
}
local sizes = {
    padding = 8,
    row = 22,
    column = 120,
    border = 4,
    titlebar = {
        height = 30
    },
    sidebar = {
        width = 150,
        collapsedWidth = 30
    }
}

local colors = {
    primary = CreateColorFromHexString("FF98cbd8"),
    dark = CreateColorFromHexString("FF1d242a"),
}

local sortingOptions = {
    {value = "lastUpdate", text = "Recently played"},
    {value = "name.asc", text = "Name (A-Z)"},
    {value = "name.desc", text = "Name (Z-A)"},
    {value = "realm.asc", text = "Realm (A-Z)"},
    {value = "realm.desc", text = "Realm (Z-A)"},
    {value = "rating.asc", text = "Rating (Lowest)"},
    {value = "rating.desc", text = "Rating (Highest)"},
    {value = "ilvl.asc", text = "Item Level (Lowest)"},
    {value = "ilvl.desc", text = "Item Level (Highest)"},
}

local function SetBackgroundColor(parent, r, g, b, a)
    if not parent.Background then
        parent.Background = parent:CreateTexture(parent:GetName() .. "Background", "BACKGROUND")
        parent.Background:SetTexture("Interface/BUTTONS/WHITE8X8")
        parent.Background:SetAllPoints()
    end

    parent.Background:SetVertexColor(r, g, b, a)
end

local CreateCharacterColumn = function(parent, index)
    local CharacterColumn = CreateFrame("Frame", parent:GetName() .. "CharacterColumn" .. index, parent)
    local affixes = AlterEgo:GetAffixes()
    local dungeons = AlterEgo:GetDungeons()
    local raids = AlterEgo:GetRaids()

    CharacterColumn:SetWidth(sizes.column)
    SetBackgroundColor(CharacterColumn, 1, 1, 1, index % 2 == 0 and 0.01 or 0)

    -- Character info
    local anchorFrame = CharacterColumn
    do
        local labels = AlterEgo:GetCharacterInfo()
        for l, info in ipairs(labels) do
            local CharacterFrame = CreateFrame(info.OnClick and "Button" or "Frame", CharacterColumn:GetName() .. "Info" .. l, CharacterColumn)
            if l > 1 then
                CharacterFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
                CharacterFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
            else
                CharacterFrame:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT")
                CharacterFrame:SetPoint("TOPRIGHT", anchorFrame, "TOPRIGHT")
            end

            CharacterFrame:SetHeight(sizes.row)
            CharacterFrame.Text = CharacterFrame:CreateFontString(CharacterFrame:GetName() .. "Text", "OVERLAY")
            CharacterFrame.Text:SetPoint("LEFT", CharacterFrame, "LEFT", sizes.padding, 0)
            CharacterFrame.Text:SetPoint("RIGHT", CharacterFrame, "RIGHT", -sizes.padding, 0)
            CharacterFrame.Text:SetJustifyH("CENTER")
            CharacterFrame.Text:SetFont(assets.font.file, assets.font.size, assets.font.flags)

            if info.backgroundColor then
                SetBackgroundColor(CharacterFrame, info.backgroundColor.r, info.backgroundColor.g, info.backgroundColor.b, info.backgroundColor.a)
            end

            anchorFrame = CharacterFrame
        end
    end

    CharacterColumn.AffixHeader = CreateFrame("Frame", CharacterColumn:GetName() .. "Affixes", CharacterColumn)
    CharacterColumn.AffixHeader:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
    CharacterColumn.AffixHeader:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
    CharacterColumn.AffixHeader:SetHeight(sizes.row)
    SetBackgroundColor(CharacterColumn.AffixHeader, 0, 0, 0, 0.3)

    -- Affix header icons
    for a, affix in ipairs(affixes) do
        local AffixFrame = CreateFrame("Frame", CharacterColumn.AffixHeader:GetName() .. a, CharacterColumn)
        if a == 1 then
            AffixFrame:SetPoint("TOPLEFT", CharacterColumn.AffixHeader:GetName(), "TOPLEFT")
            AffixFrame:SetPoint("BOTTOMRIGHT", CharacterColumn.AffixHeader:GetName(), "BOTTOM")
        else
            AffixFrame:SetPoint("TOPLEFT", CharacterColumn.AffixHeader:GetName(), "TOP")
            AffixFrame:SetPoint("BOTTOMRIGHT", CharacterColumn.AffixHeader:GetName(), "BOTTOMRIGHT")
        end
        AffixFrame.Icon = AffixFrame:CreateTexture(AffixFrame:GetName() .. "Icon", "ARTWORK")
        AffixFrame.Icon:SetTexture(affix.icon)
        AffixFrame.Icon:SetSize(16, 16)
        AffixFrame.Icon:SetPoint("CENTER", AffixFrame, "CENTER", 0, 0)
        AffixFrame:SetScript("OnEnter", function()
            GameTooltip:ClearAllPoints()
            GameTooltip:ClearLines()
            GameTooltip:SetOwner(AffixFrame, "ANCHOR_RIGHT")
            GameTooltip:SetText(affix.name, 1, 1, 1, 1, true);
            GameTooltip:AddLine(affix.description, nil, nil, nil, true);
            GameTooltip:Show()
        end)
        AffixFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    -- Dungeon rows
    for d, dungeon in ipairs(dungeons) do
        local DungeonFrame = CreateFrame("Frame", CharacterColumn:GetName() .. "Dungeons" .. d, CharacterColumn)
        local relativeTo = CharacterColumn.AffixHeader:GetName()

        if d > 1 then
            relativeTo = CharacterColumn:GetName() .. "Dungeons" .. (d-1)
        end

        DungeonFrame:SetHeight(sizes.row)
        DungeonFrame:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT")
        DungeonFrame:SetPoint("TOPRIGHT", relativeTo, "BOTTOMRIGHT")
        SetBackgroundColor(DungeonFrame, 1, 1, 1, d % 2 == 0 and 0.01 or 0)

        -- Affix values
        for a, affix in ipairs(affixes) do
            local AffixFrame = CreateFrame("Frame", DungeonFrame:GetName() .. "Affix" .. a, DungeonFrame)
            if a == 1 then
                AffixFrame:SetPoint("TOPLEFT", DungeonFrame:GetName(), "TOPLEFT")
                AffixFrame:SetPoint("BOTTOMRIGHT", DungeonFrame:GetName(), "BOTTOM")
            else
                AffixFrame:SetPoint("TOPLEFT", DungeonFrame:GetName(), "TOP")
                AffixFrame:SetPoint("BOTTOMRIGHT", DungeonFrame:GetName(), "BOTTOMRIGHT")
            end

            AffixFrame.Text = AffixFrame:CreateFontString(AffixFrame:GetName() .. "Text", "OVERLAY")
            AffixFrame.Text:SetPoint("TOPLEFT", AffixFrame, "TOPLEFT", 1, -1)
            AffixFrame.Text:SetPoint("BOTTOMRIGHT", AffixFrame, "BOTTOM", -1, 1)
            AffixFrame.Text:SetFont(assets.font.file, assets.font.size, assets.font.flags)
            AffixFrame.Text:SetJustifyH("RIGHT")
            AffixFrame.Tier = AffixFrame:CreateFontString(AffixFrame:GetName() .. "Tier", "OVERLAY")
            AffixFrame.Tier:SetPoint("TOPLEFT", AffixFrame, "TOP", 1, -1)
            AffixFrame.Tier:SetPoint("BOTTOMRIGHT", AffixFrame, "BOTTOMRIGHT", -1, 1)
            AffixFrame.Tier:SetFont(assets.font.file, assets.font.size, assets.font.flags)
            AffixFrame.Tier:SetJustifyH("LEFT")
        end
    end

    -- Raid Rows
    local anchorFrame = _G[CharacterColumn:GetName() .. "Dungeons" .. #dungeons]
    for r, raid in ipairs(raids) do
        local RaidFrame = CreateFrame("Frame", CharacterColumn:GetName() .. "Raid" .. r, CharacterColumn)
        RaidFrame:SetHeight(sizes.row)
        RaidFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
        RaidFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
        SetBackgroundColor(RaidFrame, 0, 0, 0, 0.3)

        anchorFrame = RaidFrame

        -- local RaidVault = CreateFrame("Frame", CharacterColumn:GetName() .. "Raid" .. r .. "Vault", CharacterColumn)
        -- RaidVault:SetHeight(sizes.row)
        -- RaidVault:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
        -- RaidVault:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
        -- RaidVault.Text = RaidVault:CreateFontString(RaidVault:GetName() .. "Text", "OVERLAY")
        -- RaidVault.Text:SetPoint("TOPLEFT", RaidVault, "TOPLEFT", 1, -1)
        -- RaidVault.Text:SetPoint("BOTTOMRIGHT", RaidVault, "BOTTOMRIGHT", -1, 1)
        -- RaidVault.Text:SetFont(assets.font.file, assets.font.size, assets.font.flags)
        -- RaidVault.Text:SetJustifyH("CENTER")

        -- anchorFrame = RaidVault

        for rd, difficulty in pairs(AlterEgo:GetRaidDifficulties()) do
            local DifficultyFrame = CreateFrame("Frame", CharacterColumn:GetName() .. "Raid" .. r .. "Difficulty" .. rd, RaidFrame)
            DifficultyFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
            DifficultyFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
            DifficultyFrame:SetHeight(sizes.row)
            SetBackgroundColor(DifficultyFrame, 1, 1, 1, rd % 2 == 0 and 0.01 or 0)

            local previousEncounterFrame = DifficultyFrame
            for e = 1, raid.encounters do
                local EncounterFrame = CreateFrame("Frame", CharacterColumn:GetName() .. "Raid" .. r .. "Difficulty" .. rd .. "Encounter" .. e, DifficultyFrame)
                local size = sizes.column
                size = size - sizes.padding -- left/right cell padding
                size = size - (raid.encounters - 1) * 4 -- gaps
                size = size / raid.encounters -- box sizes
                EncounterFrame:SetPoint("LEFT", previousEncounterFrame, e > 1 and "RIGHT" or "LEFT", sizes.padding / 2, 0)
                EncounterFrame:SetSize(size, sizes.row - 12)
                SetBackgroundColor(EncounterFrame, 1, 1, 1, 0.1)
                previousEncounterFrame = EncounterFrame
            end
            anchorFrame = DifficultyFrame
        end
    end

    return CharacterColumn
end

local CharacterColumns = {}
function AlterEgo:GetCharacterColumn(parent, index)
    if CharacterColumns[index] == nil then
        CharacterColumns[index] = CreateCharacterColumn(parent, index)
    end

    CharacterColumns[index]:Show()
    return CharacterColumns[index]
end

function AlterEgo:HideCharacterColumns()
    for _, CharacterColumn in ipairs(CharacterColumns) do
        CharacterColumn:Hide()
    end
end

function AlterEgo:ToggleWindow()
    if not self.Window then return end
    if self.Window:IsVisible() then
        self.Window:Hide()
    else
        self.Window:Show()
    end
end

function AlterEgo:GetWindowSize()
    local characters = self:GetCharacters()
    local dungeons = self:GetDungeons()
    local raids = self:GetRaids()
    local difficulties = self:GetRaidDifficulties()
    local width = sizes.sidebar.width + AE_table_count(characters) * sizes.column
    local raidHeight = 0
    if self.db.global.raids.enabled then
        raidHeight = AE_table_count(raids) * (AE_table_count(difficulties) + 1) * sizes.row
    end
    local height = sizes.titlebar.height + AE_table_count(self:GetCharacterInfo()) * sizes.row + sizes.row + AE_table_count(dungeons) * sizes.row + raidHeight
    return width, height
end

function AlterEgo:CreateUI()
    if self.Window then return end

    local affixes = self:GetAffixes()
    local characters = self:GetCharacters()
    local charactersUnfiltered = self:GetCharacters(true)
    local dungeons = self:GetDungeons()
    local raids = self:GetRaids()
    local difficulties = self:GetRaidDifficulties()

    self.Window = CreateFrame("Frame", "AlterEgoWindow", UIParent)
    self.Window:SetFrameStrata("HIGH")
    self.Window:SetClampedToScreen(true)
    self.Window:SetMovable(true)
    self.Window:SetPoint("CENTER")
    SetBackgroundColor(self.Window, colors.dark:GetRGBA())

    -- Border
    self.Window.Border = CreateFrame("Frame", self.Window:GetName() .. "Border", self.Window, "BackdropTemplate")
    self.Window.Border:SetPoint("TOPLEFT", self.Window, "TOPLEFT", -3, 3)
    self.Window.Border:SetPoint("BOTTOMRIGHT", self.Window, "BOTTOMRIGHT", 3, -3)
    self.Window.Border:SetBackdrop({
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = sizes.border, right = sizes.border, top = sizes.border, bottom = sizes.border },
    })
    self.Window.Border:SetBackdropBorderColor(0, 0, 0, .5)
    self.Window.Border:Show()

    -- TitleBar
    self.Window.TitleBar = CreateFrame("Frame", self.Window:GetName() .. "TitleBar", self.Window)
    self.Window.TitleBar:EnableMouse(true)
    self.Window.TitleBar:RegisterForDrag("LeftButton")
    self.Window.TitleBar:SetScript("OnDragStart", function() self.Window:StartMoving() end)
    self.Window.TitleBar:SetScript("OnDragStop", function() self.Window:StopMovingOrSizing() end)
    self.Window.TitleBar:SetPoint("TOPLEFT", self.Window, "TOPLEFT")
    self.Window.TitleBar:SetPoint("TOPRIGHT", self.Window, "TOPRIGHT")
    self.Window.TitleBar:SetHeight(sizes.titlebar.height)
    SetBackgroundColor(self.Window.TitleBar, 0, 0, 0, 0.5)
    self.Window.TitleBar.Icon = self.Window.TitleBar:CreateTexture(self.Window.TitleBar:GetName() .. "Icon", "ARTWORK")
    self.Window.TitleBar.Icon:SetPoint("LEFT", self.Window.TitleBar, "LEFT", 6, 0)
    self.Window.TitleBar.Icon:SetSize(20, 20)
    self.Window.TitleBar.Icon:SetTexture("Interface/AddOns/AlterEgo/Media/LogoTransparent.blp")
    self.Window.TitleBar.Text = self.Window.TitleBar:CreateFontString(self.Window.TitleBar:GetName() .. "Text", "OVERLAY")
    self.Window.TitleBar.Text:SetPoint("LEFT", self.Window.TitleBar, "LEFT", 20 + sizes.padding, -1)
    self.Window.TitleBar.Text:SetFont(assets.font.file, assets.font.size + 2, assets.font.flags)
    self.Window.TitleBar.Text:SetText("AlterEgo")

    self.Window.TitleBar.CloseButton = CreateFrame("Button", self.Window.TitleBar:GetName() .. "CloseButton", self.Window.TitleBar)
    self.Window.TitleBar.CloseButton:SetPoint("RIGHT", self.Window.TitleBar, "RIGHT", 0, 0)
    self.Window.TitleBar.CloseButton:SetSize(sizes.titlebar.height, sizes.titlebar.height)
    self.Window.TitleBar.CloseButton:RegisterForClicks("AnyUp")
    self.Window.TitleBar.CloseButton:SetScript("OnClick", function() self:ToggleWindow() end)
    self.Window.TitleBar.CloseButton.Icon = self.Window.TitleBar:CreateTexture(self.Window.TitleBar.CloseButton:GetName() .. "Icon", "ARTWORK")
    self.Window.TitleBar.CloseButton.Icon:SetPoint("CENTER", self.Window.TitleBar.CloseButton, "CENTER")
    self.Window.TitleBar.CloseButton.Icon:SetSize(10, 10)
    self.Window.TitleBar.CloseButton.Icon:SetTexture("Interface/AddOns/AlterEgo/Media/Icon_Close.blp")
    self.Window.TitleBar.CloseButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    self.Window.TitleBar.CloseButton:SetScript("OnEnter", function()
        self.Window.TitleBar.CloseButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
        SetBackgroundColor(self.Window.TitleBar.CloseButton, 1, 1, 1, 0.05)
        GameTooltip:ClearAllPoints()
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(self.Window.TitleBar.CloseButton, "ANCHOR_TOP")
        GameTooltip:SetText("Will you be back?", 1, 1, 1, 1, true);
        GameTooltip:AddLine("Click to close the window.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
        GameTooltip:Show()
    end)
    self.Window.TitleBar.CloseButton:SetScript("OnLeave", function()
        self.Window.TitleBar.CloseButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
        SetBackgroundColor(self.Window.TitleBar.CloseButton, 1, 1, 1, 0)
        GameTooltip:Hide()
    end)

    self.Window.TitleBar.SettingsButton = CreateFrame("Button", self.Window.TitleBar:GetName() .. "SettingsButton", self.Window.TitleBar)
    self.Window.TitleBar.SettingsButton:SetPoint("RIGHT", self.Window.TitleBar.CloseButton, "LEFT", 0, 0)
    self.Window.TitleBar.SettingsButton:SetSize(sizes.titlebar.height, sizes.titlebar.height)
    self.Window.TitleBar.SettingsButton:RegisterForClicks("AnyUp")
    self.Window.TitleBar.SettingsButton:SetScript("OnClick", function() ToggleDropDownMenu(1, nil, self.Window.TitleBar.SettingsButton.Dropdown) end)
    self.Window.TitleBar.SettingsButton.Icon = self.Window.TitleBar:CreateTexture(self.Window.TitleBar.SettingsButton:GetName() .. "Icon", "ARTWORK")
    self.Window.TitleBar.SettingsButton.Icon:SetPoint("CENTER", self.Window.TitleBar.SettingsButton, "CENTER")
    self.Window.TitleBar.SettingsButton.Icon:SetSize(12, 12)
    self.Window.TitleBar.SettingsButton.Icon:SetTexture("Interface/AddOns/AlterEgo/Media/Icon_Settings.blp")
    self.Window.TitleBar.SettingsButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    self.Window.TitleBar.SettingsButton.Dropdown = CreateFrame("Frame", self.Window.TitleBar.SettingsButton:GetName() .. "Dropdown", UIParent, "UIDropDownMenuTemplate")
    self.Window.TitleBar.SettingsButton.Dropdown:SetPoint("CENTER", self.Window.TitleBar.SettingsButton, "CENTER", 0, -8)
    UIDropDownMenu_SetWidth(self.Window.TitleBar.SettingsButton.Dropdown, sizes.titlebar.height)
    UIDropDownMenu_Initialize(self.Window.TitleBar.SettingsButton.Dropdown, function()
        UIDropDownMenu_AddButton({text = "Minimap", isTitle = true, notCheckable = true})
        UIDropDownMenu_AddButton({
            text = "Show the minimap button",
            checked = not self.db.global.minimap.hide,
            isNotRadio = true,
            tooltipTitle = "Show the minimap button",
            tooltipText = "It does get crowded around the minimap sometimes.",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
                self.db.global.minimap.hide = checked
                self.Libs.LDBIcon:Refresh("AlterEgo", self.db.global.minimap)
            end
        })
        UIDropDownMenu_AddButton({
            text = "Lock the minimap button",
            checked = self.db.global.minimap.lock,
            isNotRadio = true,
            tooltipTitle = "Lock the minimap button",
            tooltipText = "No more moving the button around accidentally!",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
                self.db.global.minimap.lock = not checked
                self.Libs.LDBIcon:Refresh("AlterEgo", self.db.global.minimap)
            end
        })
        UIDropDownMenu_AddButton({text = "Dungeons", isTitle = true, notCheckable = true})
        UIDropDownMenu_AddButton({
            text = "Show tier icons",
            checked = self.db.global.showTiers,
            isNotRadio = true,
            tooltipTitle = "Show tier icons",
            tooltipText = "Show the tier icons (|A:Professions-ChatIcon-Quality-Tier1:16:16:0:-1|a |A:Professions-ChatIcon-Quality-Tier2:16:16:0:-1|a |A:Professions-ChatIcon-Quality-Tier3:16:16:0:-1|a) in the grid.",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
                self.db.global.showTiers = not checked
                self:UpdateUI()
            end
        }) 
        UIDropDownMenu_AddButton({
            text = "Show colors on dungeon scores",
            checked = self.db.global.showAffixColors,
            isNotRadio = true,
            tooltipTitle = "Show colors on dungeon scores",
            tooltipText = "Show some colors!",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
                self.db.global.showAffixColors = not checked
                self:UpdateUI()
            end
        })
        UIDropDownMenu_AddButton({text = "Characters", isTitle = true, notCheckable = true})
        UIDropDownMenu_AddButton({
            text = "Show characters with zero rating",
            checked = self.db.global.showZeroRatedCharacters,
            isNotRadio = true,
            tooltipTitle = "Show characters with zero rating",
            tooltipText = "Too many alts?",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
                self.db.global.showZeroRatedCharacters = not checked
                self:UpdateUI()
            end
        })
        UIDropDownMenu_AddButton({text = "Raids", isTitle = true, notCheckable = true})
        UIDropDownMenu_AddButton({
            text = "Show the current raid tier",
            checked = self.db.global.raids and self.db.global.raids.enabled,
            isNotRadio = true,
            tooltipTitle = "Show the current raid tier",
            tooltipText = "Because Mythic Plus ain't enough!",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
                self.db.global.raids.enabled = not checked
                self:UpdateUI()
            end
        })
        UIDropDownMenu_AddButton({
            text = "Show different colors per difficulty",
            checked = self.db.global.raids and self.db.global.raids.colors,
            isNotRadio = true,
            tooltipTitle = "Show different colors per difficulty",
            tooltipText = "Argharhggh! So much greeeen!",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
                self.db.global.raids.colors = not checked
                self:UpdateUI()
            end
        })
    end, "MENU")
    self.Window.TitleBar.SettingsButton:SetScript("OnEnter", function()
        self.Window.TitleBar.SettingsButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
        SetBackgroundColor(self.Window.TitleBar.SettingsButton, 1, 1, 1, 0.05)
        GameTooltip:ClearAllPoints()
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(self.Window.TitleBar.SettingsButton, "ANCHOR_TOP")
        GameTooltip:SetText("Settings", 1, 1, 1, 1, true);
        GameTooltip:AddLine("Let's customize things a bit", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
        GameTooltip:Show()
    end)
    self.Window.TitleBar.SettingsButton:SetScript("OnLeave", function()
        self.Window.TitleBar.SettingsButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
        SetBackgroundColor(self.Window.TitleBar.SettingsButton, 1, 1, 1, 0)
        GameTooltip:Hide()
    end)

    self.Window.TitleBar.SortingButton = CreateFrame("Button", self.Window.TitleBar:GetName() .. "Sorting", self.Window.TitleBar)
    self.Window.TitleBar.SortingButton:SetPoint("RIGHT", self.Window.TitleBar.SettingsButton, "LEFT", 0, 0)
    self.Window.TitleBar.SortingButton:SetSize(sizes.titlebar.height, sizes.titlebar.height)
    self.Window.TitleBar.SortingButton:SetScript("OnClick", function() ToggleDropDownMenu(1, nil, self.Window.TitleBar.SortingButton.Dropdown) end)
    self.Window.TitleBar.SortingButton.Icon = self.Window.TitleBar:CreateTexture(self.Window.TitleBar.SortingButton:GetName() .. "Icon", "ARTWORK")
    self.Window.TitleBar.SortingButton.Icon:SetPoint("CENTER", self.Window.TitleBar.SortingButton, "CENTER")
    self.Window.TitleBar.SortingButton.Icon:SetSize(16, 16)
    self.Window.TitleBar.SortingButton.Icon:SetTexture("Interface/AddOns/AlterEgo/Media/Icon_Sorting.blp")
    self.Window.TitleBar.SortingButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    self.Window.TitleBar.SortingButton.Dropdown = CreateFrame("Frame", self.Window.TitleBar.SortingButton:GetName() .. "Dropdown", UIParent, "UIDropDownMenuTemplate")
    self.Window.TitleBar.SortingButton.Dropdown:SetPoint("CENTER", self.Window.TitleBar.SortingButton, "CENTER", 0, -8)
    UIDropDownMenu_SetWidth(self.Window.TitleBar.SortingButton.Dropdown, sizes.titlebar.height)
    UIDropDownMenu_Initialize(self.Window.TitleBar.SortingButton.Dropdown, function()
        for _, option in ipairs(sortingOptions) do
            UIDropDownMenu_AddButton({
                text = option.text,
                checked = self.db.global.sorting == option.value,
                arg1 = option.value,
                func = function(button, arg1, arg2, checked)
                    self.db.global.sorting = arg1
                    self:UpdateUI()
                end
            })
        end
    end, "MENU")
    self.Window.TitleBar.SortingButton:SetScript("OnEnter", function()
        self.Window.TitleBar.SortingButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
        SetBackgroundColor(self.Window.TitleBar.SortingButton, 1, 1, 1, 0.05)
        GameTooltip:ClearAllPoints()
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(self.Window.TitleBar.SortingButton, "ANCHOR_TOP")
        GameTooltip:SetText("Sorting", 1, 1, 1, 1, true);
        GameTooltip:AddLine("Sort your characters.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
        GameTooltip:Show()
    end)
    self.Window.TitleBar.SortingButton:SetScript("OnLeave", function()
        self.Window.TitleBar.SortingButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
        SetBackgroundColor(self.Window.TitleBar.SortingButton, 1, 1, 1, 0)
        GameTooltip:Hide()
    end)

    self.Window.TitleBar.CharactersButton = CreateFrame("Button", self.Window.TitleBar:GetName() .. "Characters", self.Window.TitleBar)
    self.Window.TitleBar.CharactersButton:SetPoint("RIGHT", self.Window.TitleBar.SortingButton, "LEFT", 0, 0)
    self.Window.TitleBar.CharactersButton:SetSize(sizes.titlebar.height, sizes.titlebar.height)
    self.Window.TitleBar.CharactersButton:SetScript("OnClick", function() ToggleDropDownMenu(1, nil, self.Window.TitleBar.CharactersButton.Dropdown) end)
    self.Window.TitleBar.CharactersButton.Icon = self.Window.TitleBar:CreateTexture(self.Window.TitleBar.CharactersButton:GetName() .. "Icon", "ARTWORK")
    self.Window.TitleBar.CharactersButton.Icon:SetPoint("CENTER", self.Window.TitleBar.CharactersButton, "CENTER")
    self.Window.TitleBar.CharactersButton.Icon:SetSize(14, 14)
    self.Window.TitleBar.CharactersButton.Icon:SetTexture("Interface/AddOns/AlterEgo/Media/Icon_Characters.blp")
    self.Window.TitleBar.CharactersButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    self.Window.TitleBar.CharactersButton.Dropdown = CreateFrame("Frame", self.Window.TitleBar.CharactersButton:GetName() .. "Dropdown", UIParent, "UIDropDownMenuTemplate")
    self.Window.TitleBar.CharactersButton.Dropdown:SetPoint("CENTER", self.Window.TitleBar.CharactersButton, "CENTER", 0, -8)
    UIDropDownMenu_SetWidth(self.Window.TitleBar.CharactersButton.Dropdown, sizes.titlebar.height)
    UIDropDownMenu_Initialize(self.Window.TitleBar.CharactersButton.Dropdown, function()
        local charactersUnfilteredList = self:GetCharacters(true)
        for _, character in ipairs(charactersUnfilteredList) do
            local nameColor = "ffffffff"
            if character.info.class.file ~= nil then
                local classColor = C_ClassColor.GetClassColor(character.info.class.file)
                if classColor ~= nil then
                    nameColor = classColor.GenerateHexColor(classColor)
                end
            end
            UIDropDownMenu_AddButton({
                text = "|c" .. nameColor .. character.info.name .. "|r (" .. character.info.realm .. ")",
                checked = character.enabled,
                isNotRadio = true,
                arg1 = character.GUID,
                func = function(button, arg1, arg2, checked)
                    self.db.global.characters[arg1].enabled = not checked
                    self:UpdateUI()
                end
            })
        end
    end, "MENU")
    self.Window.TitleBar.CharactersButton:SetScript("OnEnter", function()
        self.Window.TitleBar.CharactersButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
        SetBackgroundColor(self.Window.TitleBar.CharactersButton, 1, 1, 1, 0.05)
        GameTooltip:ClearAllPoints()
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(self.Window.TitleBar.CharactersButton, "ANCHOR_TOP")
        GameTooltip:SetText("Characters", 1, 1, 1, 1, true);
        GameTooltip:AddLine("Enable/Disable your characters.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
        GameTooltip:Show()
    end)
    self.Window.TitleBar.CharactersButton:SetScript("OnLeave", function()
        self.Window.TitleBar.CharactersButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
        SetBackgroundColor(self.Window.TitleBar.CharactersButton, 1, 1, 1, 0)
        GameTooltip:Hide()
    end)

    -- Body
    self.Window.Body = CreateFrame("Frame", self.Window:GetName() .. "Body", self.Window)
    self.Window.Body:SetPoint("TOPLEFT", self.Window.TitleBar, "BOTTOMLEFT")
    self.Window.Body:SetPoint("TOPRIGHT", self.Window.TitleBar, "BOTTOMRIGHT")
    self.Window.Body:SetPoint("BOTTOMLEFT", self.Window, "BOTTOMLEFT")
    self.Window.Body:SetPoint("BOTTOMRIGHT", self.Window, "BOTTOMRIGHT")
    SetBackgroundColor(self.Window.Body, 0, 0, 0, 0)

    -- Sidebar
    self.Window.Body.Sidebar = CreateFrame("Frame", self.Window.Body:GetName() .. "Sidebar", self.Window.Body)
    self.Window.Body.Sidebar:SetPoint("TOPLEFT", self.Window.Body, "TOPLEFT")
    self.Window.Body.Sidebar:SetPoint("BOTTOMLEFT", self.Window.Body, "BOTTOMLEFT")
    self.Window.Body.Sidebar:SetWidth(sizes.sidebar.width)
    SetBackgroundColor(self.Window.Body.Sidebar, 0, 0, 0, 0.3)

    -- Character info
    local anchorFrame
    do
        local labels = self:GetCharacterInfo()
        for l, info in ipairs(labels) do
            local CharacterLabel = CreateFrame("Frame", self.Window.Body.Sidebar:GetName() .. "Label" .. l, self.Window.Body.Sidebar)
            if l > 1 then
                CharacterLabel:SetPoint("TOPLEFT", self.Window.Body.Sidebar:GetName() .. "Label" .. (l-1), "BOTTOMLEFT")
                CharacterLabel:SetPoint("TOPRIGHT", self.Window.Body.Sidebar:GetName() .. "Label" .. (l-1), "BOTTOMRIGHT")
            else
                CharacterLabel:SetPoint("TOPLEFT", self.Window.Body.Sidebar:GetName(), "TOPLEFT")
                CharacterLabel:SetPoint("TOPRIGHT", self.Window.Body.Sidebar:GetName(), "TOPRIGHT")
            end

            CharacterLabel:SetHeight(sizes.row)
            CharacterLabel.Text = CharacterLabel:CreateFontString(CharacterLabel:GetName() .. "Text", "OVERLAY")
            CharacterLabel.Text:SetPoint("LEFT", CharacterLabel, "LEFT", sizes.padding, 0)
            CharacterLabel.Text:SetPoint("RIGHT", CharacterLabel, "RIGHT", -sizes.padding, 0)
            CharacterLabel.Text:SetJustifyH("LEFT")
            CharacterLabel.Text:SetFont(assets.font.file, assets.font.size, assets.font.flags)
            CharacterLabel.Text:SetText(info.label)
            CharacterLabel.Text:SetVertexColor(1.0, 0.82, 0.0, 1)

            anchorFrame = CharacterLabel
        end
    end

    local DungeonHeaderLabel = CreateFrame("Frame", self.Window.Body.Sidebar:GetName() .. "DungeonHeaderLabel", self.Window.Body.Sidebar)
    DungeonHeaderLabel:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
    DungeonHeaderLabel:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
    DungeonHeaderLabel:SetHeight(sizes.row)
    DungeonHeaderLabel.Text = DungeonHeaderLabel:CreateFontString(DungeonHeaderLabel:GetName() .. "Text", "OVERLAY")
    DungeonHeaderLabel.Text:SetPoint("TOPLEFT", DungeonHeaderLabel, "TOPLEFT", sizes.padding, 0)
    DungeonHeaderLabel.Text:SetPoint("BOTTOMRIGHT", DungeonHeaderLabel, "BOTTOMRIGHT", -sizes.padding, 0)
    DungeonHeaderLabel.Text:SetFont(assets.font.file, assets.font.size, assets.font.flags)
    DungeonHeaderLabel.Text:SetJustifyH("LEFT")
    DungeonHeaderLabel.Text:SetText("Mythic Plus")
    DungeonHeaderLabel.Text:SetVertexColor(1.0, 0.82, 0.0, 1)

    -- Dungeon names
    for d, dungeon in ipairs(dungeons) do
        local DungeonLabel = CreateFrame("Frame", self.Window.Body.Sidebar:GetName() .. "Dungeon" .. d, self.Window.Body.Sidebar)

        if d > 1 then
            DungeonLabel:SetPoint("TOPLEFT", self.Window.Body.Sidebar:GetName() .. "Dungeon" .. (d-1), "BOTTOMLEFT")
            DungeonLabel:SetPoint("TOPRIGHT", self.Window.Body.Sidebar:GetName() .. "Dungeon" .. (d-1), "BOTTOMRIGHT")
        else
            DungeonLabel:SetPoint("TOPLEFT", DungeonHeaderLabel:GetName(), "BOTTOMLEFT")
            DungeonLabel:SetPoint("TOPRIGHT", DungeonHeaderLabel:GetName(), "BOTTOMRIGHT")
        end

        DungeonLabel:SetHeight(sizes.row)
        DungeonLabel.Text = DungeonLabel:CreateFontString(DungeonLabel:GetName() .. "Text", "OVERLAY")
        DungeonLabel.Text:SetPoint("TOPLEFT", DungeonLabel, "TOPLEFT", 16 + sizes.padding * 2, -3)
        DungeonLabel.Text:SetPoint("BOTTOMRIGHT", DungeonLabel, "BOTTOMRIGHT", -sizes.padding, 3)
        DungeonLabel.Text:SetJustifyH("LEFT")
        DungeonLabel.Text:SetFont(assets.font.file, assets.font.size, assets.font.flags)
        DungeonLabel.Text:SetText(dungeon.name)
        DungeonLabel.Icon = DungeonLabel:CreateTexture(DungeonLabel:GetName() .. "Icon", "ARTWORK")
        DungeonLabel.Icon:SetSize(16, 16)
        DungeonLabel.Icon:SetPoint("LEFT", DungeonLabel, "LEFT", sizes.padding, 0)
        DungeonLabel.Icon:SetTexture(dungeon.icon)
    end

    -- Raids & Difficulties
    local anchorFrame = _G[self.Window.Body.Sidebar:GetName() .. "Dungeon" .. #dungeons]
    for r, raid in ipairs(raids) do
        local RaidHeaderLabel = CreateFrame("Frame", self.Window.Body.Sidebar:GetName() .. "Raid" .. r, self.Window.Body.Sidebar)
        RaidHeaderLabel:SetHeight(sizes.row)
        RaidHeaderLabel:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
        RaidHeaderLabel:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
        RaidHeaderLabel.Text = RaidHeaderLabel:CreateFontString(RaidHeaderLabel:GetName() .. "Text", "OVERLAY")
        RaidHeaderLabel.Text:SetPoint("TOPLEFT", RaidHeaderLabel, "TOPLEFT", sizes.padding, 0)
        RaidHeaderLabel.Text:SetPoint("BOTTOMRIGHT", RaidHeaderLabel, "BOTTOMRIGHT", -sizes.padding, 0)
        RaidHeaderLabel.Text:SetFont(assets.font.file, assets.font.size, assets.font.flags)
        RaidHeaderLabel.Text:SetJustifyH("LEFT")
        RaidHeaderLabel.Text:SetText(raid.name)
        RaidHeaderLabel.Text:SetVertexColor(1.0, 0.82, 0.0, 1)

        anchorFrame = RaidHeaderLabel

        for rd, difficulty in ipairs(difficulties) do
            local RaidDifficulty = CreateFrame("Frame", self.Window.Body.Sidebar:GetName() .. "Raid" .. r .. "Difficulty" .. rd, RaidHeaderLabel)

            RaidDifficulty:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
            RaidDifficulty:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")

            RaidDifficulty:SetHeight(sizes.row)
            RaidDifficulty.Text = RaidDifficulty:CreateFontString(RaidDifficulty:GetName() .. "Text", "OVERLAY")
            RaidDifficulty.Text:SetPoint("TOPLEFT", RaidDifficulty, "TOPLEFT", sizes.padding, -3)
            RaidDifficulty.Text:SetPoint("BOTTOMRIGHT", RaidDifficulty, "BOTTOMRIGHT", -sizes.padding, 3)
            RaidDifficulty.Text:SetJustifyH("LEFT")
            RaidDifficulty.Text:SetFont(assets.font.file, assets.font.size, assets.font.flags)
            RaidDifficulty.Text:SetText(difficulty.name)
            -- RaidLabel.Icon = RaidLabel:CreateTexture(RaidLabel:GetName() .. "Icon", "ARTWORK")
            -- RaidLabel.Icon:SetSize(16, 16)
            -- RaidLabel.Icon:SetPoint("LEFT", RaidLabel, "LEFT", sizes.padding, 0)
            -- RaidLabel.Icon:SetTexture(raid.icon)
            anchorFrame = RaidDifficulty
        end
    end

    self.Window.Body.ScrollFrame = CreateFrame("Frame", self.Window.Body:GetName() .. "ScrollFrame", self.Window.Body)
    self.Window.Body.ScrollFrame:SetPoint("TOPLEFT", self.Window.Body, "TOPLEFT", sizes.sidebar.width, 0)
    self.Window.Body.ScrollFrame:SetPoint("BOTTOMLEFT", self.Window.Body, "BOTTOMLEFT", sizes.sidebar.width, 0)
    self.Window.Body.ScrollFrame:SetPoint("BOTTOMRIGHT", self.Window.Body, "BOTTOMRIGHT")
    self.Window.Body.ScrollFrame:SetPoint("TOPRIGHT", self.Window.Body, "TOPRIGHT")
    self.Window.Body.ScrollFrame.Characters = CreateFrame("Frame", self.Window.Body.ScrollFrame:GetName() .. "Characters", self.Window.Body.ScrollFrame)
    self.Window.Body.ScrollFrame.Characters:SetAllPoints()

    self:UpdateUI()
end

function AlterEgo:UpdateUI()
    if not self.Window then return end

    self.Window:SetSize(self:GetWindowSize())

    local affixes = self:GetAffixes()
    local characters = self:GetCharacters()
    local charactersUnfiltered = self:GetCharacters(true)
    local dungeons = self:GetDungeons()
    local raids = self:GetRaids()
    local difficulties = self:GetRaidDifficulties()

    self:HideCharacterColumns()

    -- Dungeon names
    for d, dungeon in ipairs(dungeons) do
        local DungeonLabel = _G[self.Window.Body.Sidebar:GetName() .. "Dungeon" .. d]
        DungeonLabel.Icon:SetTexture(dungeon.icon)
        DungeonLabel.Text:SetFont(assets.font.file, assets.font.size, assets.font.flags)
        DungeonLabel.Text:SetText(dungeon.name)
        local mapIconTexture = "Interface/Icons/achievement_bg_wineos_underxminutes"
        if dungeon.texture ~= 0 then
            mapIconTexture = tostring(dungeon.texture)
        end
        DungeonLabel.Icon:SetTexture(mapIconTexture)
        DungeonLabel:SetScript("OnEnter", function()
            GameTooltip:ClearAllPoints()
            GameTooltip:ClearLines()
            GameTooltip:SetOwner(DungeonLabel, "ANCHOR_RIGHT")
            GameTooltip:SetText(dungeon.name, 1, 1, 1);
            GameTooltip:Show()
        end)

        DungeonLabel:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    -- Raids & Difficulties
    for r, raid in ipairs(raids) do
        local RaidHeaderLabel = _G[self.Window.Body.Sidebar:GetName() .. "Raid" .. r]
        if self.db.global.raids.enabled then
            RaidHeaderLabel:Show()
        else
            RaidHeaderLabel:Hide()
        end
    end

    -- Characters
    local lastCharacterColumn = nil
    for c, character in ipairs(characters) do
        local name = "-"
        local nameColor = "ffffffff"
        local realm = "-"
        local realmColor = "ffffffff"
        local rating = "-"
        local ratingColor = "ffffffff"
        local itemLevel = ""
        local itemLevelTooltip = ""
        local itemLevelTooltip2 = STAT_AVERAGE_ITEM_LEVEL_TOOLTIP
        local itemLevelColor = "ffffffff"
        local vaultLevels = ""
        local currentKeystone = "-"
        local bestSeasonScore = nil
        local bestSeasonScoreColor = "ffffffff"
        local bestSeasonNumber = nil

        if character.info.name ~= nil then
            name = character.info.name
        end

        if character.info.realm ~= nil then
            realm = character.info.realm
        end

        if character.info.class.file ~= nil then
            local classColor = C_ClassColor.GetClassColor(character.info.class.file)
            if classColor ~= nil then
                nameColor = classColor.GenerateHexColor(classColor)
            end
        end

        if character.mythicplus.rating ~= nil then
            local color = C_ChallengeMode.GetDungeonScoreRarityColor(character.mythicplus.rating)
            if color ~= nil then
                ratingColor = color.GenerateHexColor(color)
            end
            rating = tostring(character.mythicplus.rating)
        end

        if character.info.ilvl ~= nil then
            if character.info.ilvl.level ~= nil then
                itemLevel = tostring(floor(character.info.ilvl.level))
                itemLevelTooltip = itemLevelTooltip .. HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVERAGE_ITEM_LEVEL) .. " " .. floor(character.info.ilvl.level)
            end
            if character.info.ilvl.level ~= nil and character.info.ilvl.equipped ~= nil and character.info.ilvl.level ~= character.info.ilvl.equipped then
                itemLevelTooltip = itemLevelTooltip .. "  " .. format(STAT_AVERAGE_ITEM_LEVEL_EQUIPPED, character.info.ilvl.equipped);
            end
            if character.info.ilvl.level ~= nil then
                itemLevelTooltip = itemLevelTooltip .. FONT_COLOR_CODE_CLOSE
            end
            if character.info.ilvl.level ~= nil and character.info.ilvl.pvp ~= nil and floor(character.info.ilvl.level) ~= character.info.ilvl.pvp then
                itemLevelTooltip2 = itemLevelTooltip2.."\n\n"..STAT_AVERAGE_PVP_ITEM_LEVEL:format(tostring(floor(character.info.ilvl.pvp)));
            end
            if character.info.ilvl.color then
                itemLevelColor = character.info.ilvl.color
            end
        end

        -- for _, vault in ipairs(character.vault) do
        --     local level = "-"
        --     if vault.level > 0 then
        --         level = tostring(vault.level)
        --     end
        --     vaultLevels = vaultLevels .. level .. "  "
        -- end

        if character.mythicplus.keystone ~= nil and character.mythicplus.keystone.mapId ~= nil and character.mythicplus.keystone.level ~= nil then
            local dungeon = self:GetDungeonByMapId(character.mythicplus.keystone.mapId)
            if dungeon then
                currentKeystone = dungeon.abbr .. " +" .. tostring(character.mythicplus.keystone.level)
            end
        end

        if character.mythicplus.bestSeasonScore ~= nil then
            bestSeasonScore = character.mythicplus.bestSeasonScore
            local color = C_ChallengeMode.GetDungeonScoreRarityColor(bestSeasonScore)
            if color ~= nil then
                bestSeasonScoreColor = color.GenerateHexColor(color)
            end
        end

        if character.mythicplus.bestSeasonNumber ~= nil then
            bestSeasonNumber = character.mythicplus.bestSeasonNumber
        end

        local CharacterColumn = self:GetCharacterColumn(self.Window.Body.ScrollFrame.Characters, c)
        SetBackgroundColor(CharacterColumn, 1, 1, 1, c % 2 == 0 and 0.01 or 0)
        if c > 1 then
            CharacterColumn:SetPoint("TOPLEFT", lastCharacterColumn, "TOPRIGHT")
            CharacterColumn:SetPoint("BOTTOMLEFT", lastCharacterColumn, "BOTTOMRIGHT")
        else
            CharacterColumn:SetPoint("TOPLEFT", self.Window.Body.ScrollFrame.Characters:GetName(), "TOPLEFT")
            CharacterColumn:SetPoint("BOTTOMLEFT", self.Window.Body.ScrollFrame.Characters:GetName(), "BOTTOMLEFT")
        end
        lastCharacterColumn = CharacterColumn


        -- Character info
        local anchorFrame = CharacterColumn
        do
            local labels = AlterEgo:GetCharacterInfo()
            for l, info in ipairs(labels) do
                local CharacterFrame = _G[CharacterColumn:GetName() .. "Info" .. l]
                CharacterFrame.Text:SetText(info.value(character))
                if info.OnEnter then
                    CharacterFrame:SetScript("OnEnter", function()
                        GameTooltip:ClearAllPoints()
                        GameTooltip:ClearLines()
                        GameTooltip:SetOwner(CharacterFrame, "ANCHOR_RIGHT")
                        info.OnEnter(character)
                        GameTooltip:Show()
                    end)
                    CharacterFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
                end
                if info.OnClick then
                    CharacterFrame:SetScript("OnClick", function()
                        info.OnClick(character)
                    end)
                end
                anchorFrame = CharacterFrame
            end
        end

        -- Dungeon rows
        for d, dungeon in ipairs(dungeons) do
            local DungeonFrame =  _G[CharacterColumn:GetName() .. "Dungeons" .. d]

            local scoreColor = HIGHLIGHT_FONT_COLOR
            if (character.mythicplus.dungeons[dungeon.id] and character.mythicplus.dungeons[dungeon.id].rating and AE_table_count(character.mythicplus.dungeons[dungeon.id].affixScores)) then
                scoreColor = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(character.mythicplus.dungeons[dungeon.id].rating);
            end

            DungeonFrame:SetScript("OnEnter", function()
                GameTooltip:ClearAllPoints()
                GameTooltip:ClearLines()
                GameTooltip:SetOwner(DungeonFrame, "ANCHOR_RIGHT")
                GameTooltip:SetText(dungeon.name, 1, 1, 1);

                if (character.mythicplus.dungeons[dungeon.id] and character.mythicplus.dungeons[dungeon.id].rating and AE_table_count(character.mythicplus.dungeons[dungeon.id].affixScores)) then
                    GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_TOTAL_SCORE:format(scoreColor:WrapTextInColorCode(character.mythicplus.dungeons[dungeon.id].rating)), GREEN_FONT_COLOR);
                end

                local affixScores = character.mythicplus.dungeons[dungeon.id].affixScores
                if(affixScores and #affixScores > 0) then
                    for _, affixInfo in ipairs(affixScores) do
                        GameTooltip_AddBlankLineToTooltip(GameTooltip);
                        GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_BEST_AFFIX:format(affixInfo.name));
                        GameTooltip_AddColoredLine(GameTooltip, MYTHIC_PLUS_POWER_LEVEL:format(affixInfo.level), HIGHLIGHT_FONT_COLOR);
                        if(affixInfo.overTime) then
                            if(affixInfo.durationSec >= SECONDS_PER_HOUR) then
                                GameTooltip_AddColoredLine(GameTooltip, DUNGEON_SCORE_OVERTIME_TIME:format(SecondsToClock(affixInfo.durationSec, true)), LIGHTGRAY_FONT_COLOR);
                            else
                                GameTooltip_AddColoredLine(GameTooltip, DUNGEON_SCORE_OVERTIME_TIME:format(SecondsToClock(affixInfo.durationSec, false)), LIGHTGRAY_FONT_COLOR);
                            end
                        else
                            if(affixInfo.durationSec >= SECONDS_PER_HOUR) then
                                GameTooltip_AddColoredLine(GameTooltip, SecondsToClock(affixInfo.durationSec, true), HIGHLIGHT_FONT_COLOR);
                            else
                                GameTooltip_AddColoredLine(GameTooltip, SecondsToClock(affixInfo.durationSec, false), HIGHLIGHT_FONT_COLOR);
                            end
                        end
                    end
                end

                GameTooltip:Show()
                SetBackgroundColor(DungeonFrame, 1, 1, 1, 0.05)
            end)
            DungeonFrame:SetScript("OnLeave", function()
                GameTooltip:Hide()
                SetBackgroundColor(DungeonFrame, 1, 1, 1, d % 2 == 0 and 0.01 or 0)
            end)

            for a, affix in ipairs(affixes) do
                local AffixFrame = _G[CharacterColumn:GetName() .. "Dungeons" .. d .. "Affix" .. a]
                local level = "-"
                local levelColor = "ffffffff"
                local tier = ""

                if character.mythicplus.dungeons == nil or character.mythicplus.dungeons[dungeon.id] == nil or character.mythicplus.dungeons[dungeon.id].affixScores == nil then
                    level = "-"
                    levelColor = LIGHTGRAY_FONT_COLOR:GenerateHexColor()
                else
                    for _, affixScore in ipairs(character.mythicplus.dungeons[dungeon.id].affixScores) do
                        if affixScore.name == affix.name then
                            level = affixScore.level

                            if affixScore.durationSec <= dungeon.time * 0.6 then
                                tier = "|A:Professions-ChatIcon-Quality-Tier3:16:16:0:-1|a"
                            elseif affixScore.durationSec <= dungeon.time * 0.8 then
                                tier =  "|A:Professions-ChatIcon-Quality-Tier2:16:16:0:-1|a"
                            elseif affixScore.durationSec <= dungeon.time then
                                tier =  "|A:Professions-ChatIcon-Quality-Tier1:14:14:0:-1|a"
                            end

                            if tier == "" then
                                levelColor = LIGHTGRAY_FONT_COLOR:GenerateHexColor()
                            elseif self.db.global.showAffixColors then
                                levelColor = scoreColor:GenerateHexColor()
                            end
                        end
                    end
                end

                AffixFrame.Text:SetText("|c" .. levelColor .. level .. "|r")
                AffixFrame.Tier:SetText(tier)

                if self.db.global.showTiers then
                    AffixFrame.Text:SetPoint("BOTTOMRIGHT", AffixFrame, "BOTTOM", -1, 1)
                    AffixFrame.Text:SetJustifyH("RIGHT")
                    AffixFrame.Tier:Show()
                else
                    AffixFrame.Text:SetPoint("BOTTOMRIGHT", AffixFrame, "BOTTOMRIGHT", -1, 1)
                    AffixFrame.Text:SetJustifyH("CENTER")
                    AffixFrame.Tier:Hide()
                end
            end
        end

        -- Raid Rows
        for r, raid in ipairs(raids) do
            local RaidFrame = _G[CharacterColumn:GetName() .. "Raid" .. r]
            if self.db.global.raids.enabled then
                RaidFrame:Show()
            else
                RaidFrame:Hide()
            end

            for rd, difficulty in pairs(difficulties) do
                local DifficultyFrame = _G[CharacterColumn:GetName() .. "Raid" .. r .. "Difficulty" .. rd]
                if self.db.global.raids.enabled then
                    DifficultyFrame:Show()
                else
                    DifficultyFrame:Hide()
                end

                for e = 1, raid.encounters do
                    local EncounterFrame = _G[CharacterColumn:GetName() .. "Raid" .. r .. "Difficulty" .. rd .. "Encounter" .. e]
                    local killed = false
                    if character.raids.savedInstances ~= nil then
                        for k, savedInstance in pairs(character.raids.savedInstances) do
                            if savedInstance.instanceId == raid.mapId and savedInstance.expires > time() and savedInstance.difficultyId == difficulty.id then
                                local encounter = savedInstance.encounters[e]
                                if encounter and encounter.killed then
                                    killed = true
                                end
                            end
                        end
                    end
                    if killed then
                        local color = difficulty.color
                        if not self.db.global.raids.colors then
                            color = UNCOMMON_GREEN_COLOR
                        end
                        SetBackgroundColor(EncounterFrame, color.r, color.g, color.b, 0.5)
                    else
                        SetBackgroundColor(EncounterFrame, 1, 1, 1, 0.1)
                    end
                end
            end
        end
    end
end