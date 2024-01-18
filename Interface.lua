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
                if character.info.factionGroup ~= nil and character.info.factionGroup.localized ~= nil then
                    GameTooltip:AddLine(character.info.factionGroup.localized, 1, 1, 1);
                end
                if character.currencies ~= nil and AE_table_count(character.currencies) > 0 then
                    GameTooltip:AddLine(" ");
                    GameTooltip:AddDoubleLine("Currencies:", "Maximum:")
                    table.sort(character.currencies, function(a, b)
                        return a.id < b.id
                    end)
                    AE_table_foreach(character.currencies, function(currency)
                        if currency.useTotalEarnedForMaxQty then
                            GameTooltip:AddDoubleLine(CreateSimpleTextureMarkup(currency.iconFileID) .. " " .. currency.quantity, format("%d/%d", currency.totalEarned, currency.maxQuantity), 1, 1, 1, 1, 1, 1)
                        else
                            GameTooltip:AddDoubleLine(CreateSimpleTextureMarkup(currency.iconFileID) .. " " .. currency.quantity, format("%d", currency.maxQuantity), 1, 1, 1, 1, 1, 1)
                        end
                    end)
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
                        itemLevelTooltip2 = itemLevelTooltip2 .. "\n\n" .. STAT_AVERAGE_PVP_ITEM_LEVEL:format(tostring(floor(character.info.ilvl.pvp)));
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
                        local dungeonName = C_ChallengeMode.GetMapUIInfo(dungeon.challengeModeID)
                        if dungeonName ~= nil then
                            if dungeon.level > 0 then
                                GameTooltip:AddDoubleLine(dungeonName, "+" .. tostring(dungeon.level), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1, 1, 1)
                            else
                                GameTooltip:AddDoubleLine(dungeonName, "-", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, LIGHTGRAY_FONT_COLOR.r, LIGHTGRAY_FONT_COLOR.g, LIGHTGRAY_FONT_COLOR.b)
                            end
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
                            table.insert(dungeonScoreDungeonTable, dungeon.challengeModeID);
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
                local currentKeystone = WrapTextInColorCode("-", LIGHTGRAY_FONT_COLOR:GenerateHexColor())
                if character.mythicplus.keystone ~= nil then
                    local dungeon
                    if type(character.mythicplus.keystone.challengeModeID) == "number" and character.mythicplus.keystone.challengeModeID > 0 then
                        dungeon = AE_table_get(dungeons, "challengeModeID", character.mythicplus.keystone.challengeModeID)
                    elseif type(character.mythicplus.keystone.mapId) == "number" and character.mythicplus.keystone.mapId > 0 then
                        dungeon = AE_table_get(dungeons, "mapId", character.mythicplus.keystone.mapId)
                    end
                    if dungeon then
                        currentKeystone = dungeon.abbr
                        if type(character.mythicplus.keystone.level) == "number" and character.mythicplus.keystone.level > 0 then
                            currentKeystone = currentKeystone .. " +" .. tostring(character.mythicplus.keystone.level)
                        end
                    end
                end
                return currentKeystone
            end,
            enabled = true,
            OnEnter = function(character)
                if character.mythicplus.keystone ~= nil and type(character.mythicplus.keystone.itemLink) == "string" and character.mythicplus.keystone.itemLink ~= "" then
                    GameTooltip:SetHyperlink(character.mythicplus.keystone.itemLink)
                    GameTooltip:AddLine(" ")
                    GameTooltip:AddLine("<Shift Click to Link to Chat>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
                end
            end,
            OnClick = function(character)
                if character.mythicplus.keystone ~= nil and type(character.mythicplus.keystone.itemLink) == "string" and character.mythicplus.keystone.itemLink ~= "" then
                    if IsModifiedClick("CHATLINK") then
                        if not ChatEdit_InsertLink(character.mythicplus.keystone.itemLink) then
                            ChatFrame_OpenChat(character.mythicplus.keystone.itemLink);
                        end
                    end
                end
            end,
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
                            local name = "-"
                            local nameColor = LIGHTGRAY_FONT_COLOR
                            if slot.level > 0 then
                                local dataDifficulty = AE_table_get(self:GetRaidDifficulties(), "id", slot.level)
                                if dataDifficulty and dataDifficulty.abbr then
                                    name = dataDifficulty.abbr
                                else
                                    local difficultyName = GetDifficultyInfo(slot.level)
                                    if difficultyName then
                                        name = tostring(difficultyName):sub(1, 1)
                                    end
                                end
                                if self.db.global.raids.colors and dataDifficulty and dataDifficulty.color then
                                    nameColor = dataDifficulty.color
                                else
                                    nameColor = UNCOMMON_GREEN_COLOR
                                end
                            end
                            vaultLevels = vaultLevels .. WrapTextInColorCode(name, nameColor:GenerateHexColor()) .. "  "
                        end
                    end
                end
                if vaultLevels == "" then
                    vaultLevels = WrapTextInColorCode("-  -  -", LIGHTGRAY_FONT_COLOR:GenerateHexColor())
                end
                return strtrim(vaultLevels)
            end,
            OnEnter = function(character)
                GameTooltip:AddLine("Vault Progress", 1, 1, 1)
                if character.vault.slots ~= nil then
                    local slots = AE_table_filter(character.vault.slots, function(slot)
                        return slot.type == Enum.WeeklyRewardChestThresholdType.Raid
                    end)
                    for _, slot in ipairs(slots) do
                        local color = LIGHTGRAY_FONT_COLOR
                        local result = "Locked"
                        if slot.progress >= slot.threshold then
                            color = WHITE_FONT_COLOR
                            if slot.exampleRewardLink ~= nil and slot.exampleRewardLink ~= "" then
                                local itemLevel = GetDetailedItemLevelInfo(slot.exampleRewardLink)
                                local difficultyName = GetDifficultyInfo(slot.level)
                                local dataDifficulty = AE_table_get(self:GetRaidDifficulties(), "id", slot.level)
                                if dataDifficulty then
                                    difficultyName = dataDifficulty.short and dataDifficulty.short or dataDifficulty.name
                                end
                                result = format("%s (%d+)", difficultyName, itemLevel)
                            else
                                result = "?"
                            end
                        end
                        GameTooltip:AddDoubleLine(format("%d boss kills:", slot.threshold), result, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, color.r, color.g, color.b)
                    end

                    local incompleteSlots = AE_table_filter(character.vault.slots, function(slot)
                        return slot.type == Enum.WeeklyRewardChestThresholdType.Raid and slot.progress < slot.threshold
                    end)
                    if AE_table_count(incompleteSlots) > 0 then
                        table.sort(incompleteSlots, function(a, b) return a.threshold < b.threshold end)
                        GameTooltip:AddLine(" ")
                        local tooltip = ""
                        if AE_table_count(incompleteSlots) == AE_table_count(slots) then
                            tooltip = format("Defeat %d bosses this week to unlock your first Great Vault reward.", incompleteSlots[1].threshold)
                        else
                            local diff = incompleteSlots[1].threshold - incompleteSlots[1].progress
                            if diff == 1 then
                                tooltip = format("Defeat %d more boss this week to unlock another Great Vault reward.", diff)
                            else
                                tooltip = format("Defeat another %d bosses this week to unlock another Great Vault reward.", diff)
                            end
                        end
                        GameTooltip:AddLine(tooltip, nil, nil, nil, true)
                    end
                end
            end,
            enabled = self.db.global.raids.enabled,
        },
        {
            label = WrapTextInColorCode("Dungeons", "ffffffff"),
            value = function(character)
                local vaultLevels = ""
                if character.vault.slots ~= nil then
                    local slots = AE_table_filter(character.vault.slots, function(slot) return slot.type == Enum.WeeklyRewardChestThresholdType.Activities end)
                    for _, slot in ipairs(slots) do
                        local level = "-"
                        local color = LIGHTGRAY_FONT_COLOR
                        if slot.progress >= slot.threshold then
                            level = tostring(slot.level)
                            color = UNCOMMON_GREEN_COLOR
                        end
                        vaultLevels = vaultLevels .. WrapTextInColorCode(level, color:GenerateHexColor()) .. "  "
                    end
                end
                if vaultLevels == "" then
                    vaultLevels = WrapTextInColorCode("-  -  -", LIGHTGRAY_FONT_COLOR:GenerateHexColor())
                end
                return strtrim(vaultLevels)
            end,
            OnEnter = function(character)
                local weeklyRuns = AE_table_filter(character.mythicplus.runHistory, function(run) return run.thisWeek == true end)
                local weeklyRunsCount = AE_table_count(weeklyRuns) or 0
                GameTooltip:AddLine("Vault Progress", 1, 1, 1);
                -- GameTooltip:AddLine("Runs this Week: " .. "|cffffffff" .. tostring(weeklyRunsCount) .. "|r", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);

                if character.mythicplus ~= nil and character.mythicplus.numCompletedDungeonRuns ~= nil then
                    local numHeroic = character.mythicplus.numCompletedDungeonRuns.heroic or 0
                    if numHeroic > 0 then
                        GameTooltip:AddLine("Heroic runs this Week: " .. "|cffffffff" .. tostring(numHeroic) .. "|r", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                    end
                    local numMythic = character.mythicplus.numCompletedDungeonRuns.mythic or 0
                    if numMythic > 0 then
                        GameTooltip:AddLine("Mythic runs this Week: " .. "|cffffffff" .. tostring(numMythic) .. "|r", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                    end
                    local numMythicPlus = character.mythicplus.numCompletedDungeonRuns.mythicPlus or 0
                    if numMythicPlus > 0 then
                        GameTooltip:AddLine("Mythic+ runs this Week: " .. "|cffffffff" .. tostring(numMythicPlus) .. "|r", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
                    end
                end
                GameTooltip_AddBlankLineToTooltip(GameTooltip);

                local lastCompletedActivityInfo, nextActivityInfo = AE_GetActivitiesProgress(character);
                if not lastCompletedActivityInfo then
                    GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_INCOMPLETE);
                else
                    if nextActivityInfo then
                        local globalString = (lastCompletedActivityInfo.index == 1) and GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_FIRST or GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_SECOND;
                        GameTooltip_AddNormalLine(GameTooltip, globalString:format(nextActivityInfo.threshold - nextActivityInfo.progress));
                    else
                        GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_COMPLETED_THIRD);
                        local level, count = AE_GetLowestLevelInTopDungeonRuns(character, lastCompletedActivityInfo.threshold);
                        if level == WeeklyRewardsUtil.HeroicLevel then
                            GameTooltip_AddBlankLineToTooltip(GameTooltip);
                            GameTooltip_AddColoredLine(GameTooltip, GREAT_VAULT_IMPROVE_REWARD, GREEN_FONT_COLOR);
                            GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_HEROIC_IMPROVE:format(count));
                        else
                            local nextLevel = WeeklyRewardsUtil.GetNextMythicLevel(level);
                            if nextLevel < 20 then
                                GameTooltip_AddBlankLineToTooltip(GameTooltip);
                                GameTooltip_AddColoredLine(GameTooltip, GREAT_VAULT_IMPROVE_REWARD, GREEN_FONT_COLOR);
                                GameTooltip_AddNormalLine(GameTooltip, GREAT_VAULT_REWARDS_MYTHIC_IMPROVE:format(count, nextLevel));
                            end
                        end
                    end
                end

                if weeklyRunsCount > 0 then
                    GameTooltip_AddBlankLineToTooltip(GameTooltip)
                    table.sort(weeklyRuns, function(a, b) return a.level > b.level end)
                    for runIndex, run in ipairs(weeklyRuns) do
                        local threshold = AE_table_find(character.vault.slots, function(slot) return slot.type == Enum.WeeklyRewardChestThresholdType.Activities and runIndex == slot.threshold end)
                        local rewardLevel = C_MythicPlus.GetRewardLevelFromKeystoneLevel(run.level)
                        local dungeon = AE_table_get(dungeons, "challengeModeID", run.mapChallengeModeID)
                        local color = WHITE_FONT_COLOR
                        if threshold then
                            color = GREEN_FONT_COLOR
                        end
                        if dungeon then
                            GameTooltip:AddDoubleLine(dungeon.short and dungeon.short or dungeon.name, string.format("+%d (%d)", run.level, rewardLevel), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, color.r, color.g, color.b)
                        end
                        if runIndex == 8 then
                            break
                        end
                    end
                end
            end,
            enabled = true,
        },
    }
end

local function SetBackgroundColor(parent, r, g, b, a)
    if not parent.Background then
        parent.Background = parent:CreateTexture(parent:GetName() .. "Background", "BACKGROUND")
        parent.Background:SetTexture("Interface/BUTTONS/WHITE8X8")
        parent.Background:SetAllPoints()
    end

    parent.Background:SetVertexColor(r, g, b, a)
end

function AlterEgo:CreateCharacterColumn(parent, index)
    local affixes = AlterEgo:GetAffixes()
    local dungeons = AlterEgo:GetDungeons()
    local raids = AlterEgo:GetRaids()
    local anchorFrame

    local CharacterColumn = CreateFrame("Frame", "$parentCharacterColumn" .. index, parent)
    CharacterColumn:SetWidth(self.constants.sizes.column)
    SetBackgroundColor(CharacterColumn, 1, 1, 1, index % 2 == 0 and 0.01 or 0)
    anchorFrame = CharacterColumn

    -- Character info
    do
        local labels = AlterEgo:GetCharacterInfo()
        for labelIndex, info in ipairs(labels) do
            local CharacterFrame = CreateFrame(info.OnClick and "Button" or "Frame", "$parentInfo" .. labelIndex, CharacterColumn)
            if labelIndex > 1 then
                CharacterFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
                CharacterFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
            else
                CharacterFrame:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT")
                CharacterFrame:SetPoint("TOPRIGHT", anchorFrame, "TOPRIGHT")
            end

            CharacterFrame:SetHeight(self.constants.sizes.row)
            CharacterFrame.Text = CharacterFrame:CreateFontString(CharacterFrame:GetName() .. "Text", "OVERLAY")
            CharacterFrame.Text:SetPoint("LEFT", CharacterFrame, "LEFT", self.constants.sizes.padding, 0)
            CharacterFrame.Text:SetPoint("RIGHT", CharacterFrame, "RIGHT", -self.constants.sizes.padding, 0)
            CharacterFrame.Text:SetJustifyH("CENTER")
            CharacterFrame.Text:SetFont(self.constants.font.file, self.db.global.interface.fontSize, self.constants.font.flags)

            if info.backgroundColor then
                SetBackgroundColor(CharacterFrame, info.backgroundColor.r, info.backgroundColor.g, info.backgroundColor.b, info.backgroundColor.a)
            end

            anchorFrame = CharacterFrame
        end
    end

    CharacterColumn.AffixHeader = CreateFrame("Frame", "$parentAffixes", CharacterColumn)
    CharacterColumn.AffixHeader:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
    CharacterColumn.AffixHeader:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
    CharacterColumn.AffixHeader:SetHeight(self.constants.sizes.row)
    SetBackgroundColor(CharacterColumn.AffixHeader, 0, 0, 0, 0.3)
    anchorFrame = CharacterColumn.AffixHeader

    -- Affix header icons
    for affixIndex, affix in ipairs(affixes) do
        local AffixFrame = CreateFrame("Frame", CharacterColumn.AffixHeader:GetName() .. affixIndex, CharacterColumn)
        if affixIndex == 1 then
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
    for dungeonIndex in ipairs(dungeons) do
        local DungeonFrame = CreateFrame("Frame", "$parentDungeons" .. dungeonIndex, CharacterColumn)
        DungeonFrame:SetHeight(self.constants.sizes.row)
        DungeonFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
        DungeonFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
        SetBackgroundColor(DungeonFrame, 1, 1, 1, dungeonIndex % 2 == 0 and 0.01 or 0)
        anchorFrame = DungeonFrame

        -- Affix values
        for affixIndex, affix in ipairs(affixes) do
            local AffixFrame = CreateFrame("Frame", "$parentAffix" .. affixIndex, DungeonFrame)
            if affixIndex == 1 then
                AffixFrame:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT")
                AffixFrame:SetPoint("BOTTOMRIGHT", anchorFrame, "BOTTOM")
            else
                AffixFrame:SetPoint("TOPLEFT", anchorFrame, "TOP")
                AffixFrame:SetPoint("BOTTOMRIGHT", anchorFrame, "BOTTOMRIGHT")
            end

            AffixFrame.Text = AffixFrame:CreateFontString(AffixFrame:GetName() .. "Text", "OVERLAY")
            AffixFrame.Text:SetPoint("TOPLEFT", AffixFrame, "TOPLEFT", 1, -1)
            AffixFrame.Text:SetPoint("BOTTOMRIGHT", AffixFrame, "BOTTOM", -1, 1)
            AffixFrame.Text:SetFont(self.constants.font.file, self.db.global.interface.fontSize, self.constants.font.flags)
            AffixFrame.Text:SetJustifyH("RIGHT")
            AffixFrame.Tier = AffixFrame:CreateFontString(AffixFrame:GetName() .. "Tier", "OVERLAY")
            AffixFrame.Tier:SetPoint("TOPLEFT", AffixFrame, "TOP", 1, -1)
            AffixFrame.Tier:SetPoint("BOTTOMRIGHT", AffixFrame, "BOTTOMRIGHT", -1, 1)
            AffixFrame.Tier:SetFont(self.constants.font.file, self.db.global.interface.fontSize, self.constants.font.flags)
            AffixFrame.Tier:SetJustifyH("LEFT")
        end
        anchorFrame = DungeonFrame
    end

    -- Raid Rows
    for raidIndex, raid in ipairs(raids) do
        local RaidFrame = CreateFrame("Frame", "$parentRaid" .. raidIndex, CharacterColumn)
        RaidFrame:SetHeight(self.constants.sizes.row)
        RaidFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
        RaidFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
        SetBackgroundColor(RaidFrame, 0, 0, 0, 0.3)
        anchorFrame = RaidFrame

        for difficultyIndex in pairs(AlterEgo:GetRaidDifficulties()) do
            local DifficultyFrame = CreateFrame("Frame", "$parentDifficulty" .. difficultyIndex, RaidFrame)
            DifficultyFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
            DifficultyFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
            DifficultyFrame:SetHeight(self.constants.sizes.row)
            SetBackgroundColor(DifficultyFrame, 1, 1, 1, difficultyIndex % 2 == 0 and 0.01 or 0)
            anchorFrame = DifficultyFrame

            for encounterIndex in ipairs(raid.encounters) do
                local EncounterFrame = CreateFrame("Frame", "$parentEncounter" .. encounterIndex, DifficultyFrame)
                local size = self.constants.sizes.column
                size = size - self.constants.sizes.padding -- left/right cell padding
                size = size - (raid.numEncounters - 1) * 4 -- gaps
                size = size / raid.numEncounters           -- box sizes
                EncounterFrame:SetPoint("LEFT", anchorFrame, encounterIndex > 1 and "RIGHT" or "LEFT", self.constants.sizes.padding / 2, 0)
                EncounterFrame:SetSize(size, self.constants.sizes.row - 12)
                SetBackgroundColor(EncounterFrame, 1, 1, 1, 0.1)
                anchorFrame = EncounterFrame
            end
            anchorFrame = DifficultyFrame
        end
    end

    return CharacterColumn
end

local CharacterColumns = {}
function AlterEgo:GetCharacterColumn(parent, index)
    if CharacterColumns[index] == nil then
        CharacterColumns[index] = self:CreateCharacterColumn(parent, index)
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

function AlterEgo:GetMaxWindowWidth()
    return GetScreenWidth() - 100
end

function AlterEgo:IsScrollbarNeeded()
    local characters = self:GetCharacters()
    local numCharacters = AE_table_count(characters)
    return numCharacters > 0 and self.constants.sizes.sidebar.width + numCharacters * self.constants.sizes.column > self:GetMaxWindowWidth()
end

function AlterEgo:GetWindowSize()
    local characters = self:GetCharacters()
    local numCharacters = AE_table_count(characters)
    local dungeons = self:GetDungeons()
    local raids = self:GetRaids()
    local difficulties = self:GetRaidDifficulties()
    local width = 0
    local maxWidth = self:GetMaxWindowWidth()
    local height = 0

    -- Width
    if numCharacters == 0 then
        width = 500
    else
        width = width + self.constants.sizes.sidebar.width
        width = width + numCharacters * self.constants.sizes.column
    end
    if width > maxWidth then
        width = maxWidth
        if numCharacters > 0 then
            height = height + self.constants.sizes.footer.height -- Shoes?
        end
    end

    -- Height
    height = height + self.constants.sizes.titlebar.height                                                                                                                  -- Titlebar duh
    height = height + AE_table_count(AE_table_filter(self:GetCharacterInfo(), function(label) return label.enabled == nil or label.enabled end)) * self.constants.sizes.row -- Character info
    height = height + self.constants.sizes.row                                                                                                                              -- DungeonHeader
    height = height + AE_table_count(dungeons) * self.constants.sizes.row                                                                                                   -- Dungeon rows
    if self.db.global.raids.enabled then
        height = height + AE_table_count(raids) * (AE_table_count(difficulties) + 1) * self.constants.sizes.row                                                             -- Raids
    end

    return width, height
end

function AlterEgo:CreateUI()
    if self.Window then return end
    local dungeons = self:GetDungeons()
    local raids = self:GetRaids()
    local difficulties = self:GetRaidDifficulties()
    local labels = self:GetCharacterInfo()
    local anchorFrame

    self.Window = CreateFrame("Frame", "AlterEgoWindow", UIParent)
    self.Window:SetFrameStrata("HIGH")
    self.Window:SetClampedToScreen(true)
    self.Window:SetMovable(true)
    self.Window:SetPoint("CENTER")
    SetBackgroundColor(self.Window, self.db.global.interface.windowColor.r, self.db.global.interface.windowColor.g, self.db.global.interface.windowColor.b, self.db.global.interface.windowColor.a)
    table.insert(UISpecialFrames, self.Window:GetName())

    do -- Border
        self.Window.Border = CreateFrame("Frame", "$parentBorder", self.Window, "BackdropTemplate")
        self.Window.Border:SetPoint("TOPLEFT", self.Window, "TOPLEFT", -3, 3)
        self.Window.Border:SetPoint("BOTTOMRIGHT", self.Window, "BOTTOMRIGHT", 3, -3)
        self.Window.Border:SetBackdrop({edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 16, insets = {left = self.constants.sizes.border, right = self.constants.sizes.border, top = self.constants.sizes.border, bottom = self.constants.sizes.border}})
        self.Window.Border:SetBackdropBorderColor(0, 0, 0, .5)
        self.Window.Border:Show()
    end

    do -- TitleBar
        self.Window.TitleBar = CreateFrame("Frame", "$parentTitleBar", self.Window)
        self.Window.TitleBar:EnableMouse(true)
        self.Window.TitleBar:RegisterForDrag("LeftButton")
        self.Window.TitleBar:SetScript("OnDragStart", function() self.Window:StartMoving() end)
        self.Window.TitleBar:SetScript("OnDragStop", function() self.Window:StopMovingOrSizing() end)
        self.Window.TitleBar:SetPoint("TOPLEFT", self.Window, "TOPLEFT")
        self.Window.TitleBar:SetPoint("TOPRIGHT", self.Window, "TOPRIGHT")
        self.Window.TitleBar:SetHeight(self.constants.sizes.titlebar.height)
        SetBackgroundColor(self.Window.TitleBar, 0, 0, 0, 0.5)
        self.Window.TitleBar.Icon = self.Window.TitleBar:CreateTexture("$parentIcon", "ARTWORK")
        self.Window.TitleBar.Icon:SetPoint("LEFT", self.Window.TitleBar, "LEFT", 6, 0)
        self.Window.TitleBar.Icon:SetSize(20, 20)
        self.Window.TitleBar.Icon:SetTexture(self.constants.media.LogoTransparent)
        self.Window.TitleBar.Text = self.Window.TitleBar:CreateFontString("$parentText", "OVERLAY")
        self.Window.TitleBar.Text:SetPoint("LEFT", self.Window.TitleBar, "LEFT", 20 + self.constants.sizes.padding, -1)
        self.Window.TitleBar.Text:SetFont(self.constants.font.file, 14, self.constants.font.flags)
        self.Window.TitleBar.Text:SetText("AlterEgo")
        anchorFrame = self.Window.TitleBar
        for i = 1, 3 do
            self.Window.TitleBar["Affix" .. i] = self.Window.TitleBar:CreateTexture("$parentAffix" .. i, "ARTWORK")
            self.Window.TitleBar["Affix" .. i]:SetSize(20, 20)
            anchorFrame = self.Window.TitleBar["Affix" .. i]
        end
        self.Window.TitleBar.CloseButton = CreateFrame("Button", "$parentCloseButton", self.Window.TitleBar)
        self.Window.TitleBar.CloseButton:SetPoint("RIGHT", self.Window.TitleBar, "RIGHT", 0, 0)
        self.Window.TitleBar.CloseButton:SetSize(self.constants.sizes.titlebar.height, self.constants.sizes.titlebar.height)
        self.Window.TitleBar.CloseButton:RegisterForClicks("AnyUp")
        self.Window.TitleBar.CloseButton:SetScript("OnClick", function() self:ToggleWindow() end)
        self.Window.TitleBar.CloseButton.Icon = self.Window.TitleBar:CreateTexture(self.Window.TitleBar.CloseButton:GetName() .. "Icon", "ARTWORK")
        self.Window.TitleBar.CloseButton.Icon:SetPoint("CENTER", self.Window.TitleBar.CloseButton, "CENTER")
        self.Window.TitleBar.CloseButton.Icon:SetSize(10, 10)
        self.Window.TitleBar.CloseButton.Icon:SetTexture(self.constants.media.IconClose)
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
        self.Window.TitleBar.SettingsButton = CreateFrame("Button", "$parentSettingsButton", self.Window.TitleBar)
        self.Window.TitleBar.SettingsButton:SetPoint("RIGHT", self.Window.TitleBar.CloseButton, "LEFT", 0, 0)
        self.Window.TitleBar.SettingsButton:SetSize(self.constants.sizes.titlebar.height, self.constants.sizes.titlebar.height)
        self.Window.TitleBar.SettingsButton:RegisterForClicks("AnyUp")
        self.Window.TitleBar.SettingsButton:SetScript("OnClick", function() ToggleDropDownMenu(1, nil, self.Window.TitleBar.SettingsButton.Dropdown) end)
        self.Window.TitleBar.SettingsButton.Icon = self.Window.TitleBar:CreateTexture(self.Window.TitleBar.SettingsButton:GetName() .. "Icon", "ARTWORK")
        self.Window.TitleBar.SettingsButton.Icon:SetPoint("CENTER", self.Window.TitleBar.SettingsButton, "CENTER")
        self.Window.TitleBar.SettingsButton.Icon:SetSize(12, 12)
        self.Window.TitleBar.SettingsButton.Icon:SetTexture(self.constants.media.IconSettings)
        self.Window.TitleBar.SettingsButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
        self.Window.TitleBar.SettingsButton.Dropdown = CreateFrame("Frame", self.Window.TitleBar.SettingsButton:GetName() .. "Dropdown", self.Window.TitleBar, "UIDropDownMenuTemplate")
        self.Window.TitleBar.SettingsButton.Dropdown:SetPoint("CENTER", self.Window.TitleBar.SettingsButton, "CENTER", 0, -6)
        self.Window.TitleBar.SettingsButton.Dropdown.Button:Hide()
        UIDropDownMenu_SetWidth(self.Window.TitleBar.SettingsButton.Dropdown, self.constants.sizes.titlebar.height)
        UIDropDownMenu_Initialize(
            self.Window.TitleBar.SettingsButton.Dropdown,
            function(frame, level, subMenuName)
                if subMenuName == "windowscale" then
                    for i = 80, 200, 10 do
                        UIDropDownMenu_AddButton(
                            {
                                text = i .. "%",
                                value = i,
                                checked = self.db.global.interface.windowScale == i,
                                func = function(button)
                                    self.db.global.interface.windowScale = button.value
                                    self:UpdateUI()
                                end
                            },
                            level
                        )
                    end
                elseif subMenuName == "fontsize" then
                    for i = 10, 14 do
                        UIDropDownMenu_AddButton(
                            {
                                text = i,
                                checked = self.db.global.interface.fontSize == i,
                                func = function(button)
                                    self.db.global.interface.fontSize = button.value
                                    self:UpdateUI()
                                end
                            },
                            level
                        )
                    end
                elseif level == 1 then
                    UIDropDownMenu_AddButton({text = "General", isTitle = true, notCheckable = true})
                    UIDropDownMenu_AddButton({
                        text = "Show the weekly affixes",
                        checked = self.db.global.showAffixHeader,
                        isNotRadio = true,
                        tooltipTitle = "Show the weekly affixes",
                        tooltipText = "The affixes will be shown at the top.",
                        tooltipOnButton = true,
                        func = function(button, arg1, arg2, checked)
                            self.db.global.showAffixHeader = not checked
                            self:UpdateUI()
                        end
                    })
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
                    UIDropDownMenu_AddButton({
                        text = "Announce instance resets",
                        checked = self.db.global.announceResets,
                        isNotRadio = true,
                        tooltipTitle = "Announce instance resets",
                        tooltipText = "Let others in your group know when you've reset the instances.",
                        tooltipOnButton = true,
                        func = function(button, arg1, arg2, checked)
                            self.db.global.announceResets = not checked
                            self:UpdateUI()
                        end
                    })
                    UIDropDownMenu_AddButton({text = "Keystone Announcements", isTitle = true, notCheckable = true})
                    UIDropDownMenu_AddButton({
                        text = "Announce new keystones (Party)",
                        checked = self.db.global.announceKeystones.autoParty,
                        isNotRadio = true,
                        tooltipTitle = "New keystones (Party)",
                        tooltipText = "Announce to your party when you loot a new keystone.",
                        tooltipOnButton = true,
                        func = function(button, arg1, arg2, checked)
                            self.db.global.announceKeystones.autoParty = not checked
                            self:UpdateUI()
                        end
                    })
                    UIDropDownMenu_AddButton({
                        text = "Announce new keystones (Guild)",
                        checked = self.db.global.announceKeystones.autoGuild,
                        isNotRadio = true,
                        tooltipTitle = "New keystones (Guild)",
                        tooltipText = "Announce to your guild when you loot a new keystone.",
                        tooltipOnButton = true,
                        func = function(button, arg1, arg2, checked)
                            self.db.global.announceKeystones.autoGuild = not checked
                            self:UpdateUI()
                        end
                    })
                    UIDropDownMenu_AddButton({
                        text = "Announce keystones in one message",
                        checked = not self.db.global.announceKeystones.multiline,
                        isNotRadio = true,
                        tooltipTitle = "Announce keystones in one message",
                        tooltipText = "With too many alts it could get spammy.",
                        tooltipOnButton = true,
                        func = function(button, arg1, arg2, checked)
                            self.db.global.announceKeystones.multiline = checked
                            self:UpdateUI()
                        end
                    })
                    UIDropDownMenu_AddButton({text = "Dungeons", isTitle = true, notCheckable = true})
                    UIDropDownMenu_AddButton({
                        text = "Show timed icons",
                        checked = self.db.global.showTiers,
                        isNotRadio = true,
                        tooltipTitle = "Show timed icons",
                        tooltipText = "Show the timed icons (|A:Professions-ChatIcon-Quality-Tier1:16:16:0:-1|a |A:Professions-ChatIcon-Quality-Tier2:16:16:0:-1|a |A:Professions-ChatIcon-Quality-Tier3:16:16:0:-1|a).",
                        tooltipOnButton = true,
                        func = function(button, arg1, arg2, checked)
                            self.db.global.showTiers = not checked
                            self:UpdateUI()
                        end
                    })
                    UIDropDownMenu_AddButton({
                        text = "Show score colors",
                        checked = self.db.global.showAffixColors,
                        isNotRadio = true,
                        tooltipTitle = "Show score colors",
                        tooltipText = "Show some colors!",
                        tooltipOnButton = true,
                        func = function(button, arg1, arg2, checked)
                            self.db.global.showAffixColors = not checked
                            self:UpdateUI()
                        end
                    })
                    UIDropDownMenu_AddButton({text = "Raids", isTitle = true, notCheckable = true})
                    UIDropDownMenu_AddButton({
                        text = "Show raid progress",
                        checked = self.db.global.raids and self.db.global.raids.enabled,
                        isNotRadio = true,
                        tooltipTitle = "Show raid progress",
                        tooltipText = "Because Mythic Plus ain't enough!",
                        tooltipOnButton = true,
                        func = function(button, arg1, arg2, checked)
                            self.db.global.raids.enabled = not checked
                            self:UpdateUI()
                        end
                    })
                    UIDropDownMenu_AddButton({
                        text = "Show difficulty colors",
                        checked = self.db.global.raids and self.db.global.raids.colors,
                        isNotRadio = true,
                        tooltipTitle = "Show difficulty colors",
                        tooltipText = "Argharhggh! So much greeeen!",
                        tooltipOnButton = true,
                        func = function(button, arg1, arg2, checked)
                            self.db.global.raids.colors = not checked
                            self:UpdateUI()
                        end
                    })
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
                    UIDropDownMenu_AddButton({text = "Interface", isTitle = true, notCheckable = true})
                    UIDropDownMenu_AddButton({
                        text = "Window color",
                        notCheckable = true,
                        hasColorSwatch = true,
                        r = self.db.global.interface.windowColor.r,
                        g = self.db.global.interface.windowColor.g,
                        b = self.db.global.interface.windowColor.b,
                        -- notClickable = true,
                        hasOpacity = false,
                        func = UIDropDownMenuButton_OpenColorPicker,
                        swatchFunc = function()
                            local r, g, b = ColorPickerFrame:GetColorRGB();
                            self.db.global.interface.windowColor.r = r
                            self.db.global.interface.windowColor.g = g
                            self.db.global.interface.windowColor.b = b
                            SetBackgroundColor(self.Window, self.db.global.interface.windowColor.r, self.db.global.interface.windowColor.g, self.db.global.interface.windowColor.b, self.db.global.interface.windowColor.a)
                        end,
                        cancelFunc = function(color)
                            self.db.global.interface.windowColor.r = color.r
                            self.db.global.interface.windowColor.g = color.g
                            self.db.global.interface.windowColor.b = color.b
                            SetBackgroundColor(self.Window, self.db.global.interface.windowColor.r, self.db.global.interface.windowColor.g, self.db.global.interface.windowColor.b, self.db.global.interface.windowColor.a)
                        end
                    })
                    UIDropDownMenu_AddButton({text = "Window scale", notCheckable = true, hasArrow = true, menuList = "windowscale"})
                    UIDropDownMenu_AddButton({text = "Font size", notCheckable = true, hasArrow = true, menuList = "fontsize"})
                end
            end,
            "MENU"
        )
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
        self.Window.TitleBar.SortingButton = CreateFrame("Button", "$parentSorting", self.Window.TitleBar)
        self.Window.TitleBar.SortingButton:SetPoint("RIGHT", self.Window.TitleBar.SettingsButton, "LEFT", 0, 0)
        self.Window.TitleBar.SortingButton:SetSize(self.constants.sizes.titlebar.height, self.constants.sizes.titlebar.height)
        self.Window.TitleBar.SortingButton:SetScript("OnClick", function() ToggleDropDownMenu(1, nil, self.Window.TitleBar.SortingButton.Dropdown) end)
        self.Window.TitleBar.SortingButton.Icon = self.Window.TitleBar:CreateTexture(self.Window.TitleBar.SortingButton:GetName() .. "Icon", "ARTWORK")
        self.Window.TitleBar.SortingButton.Icon:SetPoint("CENTER", self.Window.TitleBar.SortingButton, "CENTER")
        self.Window.TitleBar.SortingButton.Icon:SetSize(16, 16)
        self.Window.TitleBar.SortingButton.Icon:SetTexture(self.constants.media.IconSorting)
        self.Window.TitleBar.SortingButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
        self.Window.TitleBar.SortingButton.Dropdown = CreateFrame("Frame", self.Window.TitleBar.SortingButton:GetName() .. "Dropdown", self.Window.TitleBar.SortingButton, "UIDropDownMenuTemplate")
        self.Window.TitleBar.SortingButton.Dropdown:SetPoint("CENTER", self.Window.TitleBar.SortingButton, "CENTER", 0, -6)
        self.Window.TitleBar.SortingButton.Dropdown.Button:Hide()
        UIDropDownMenu_SetWidth(self.Window.TitleBar.SortingButton.Dropdown, self.constants.sizes.titlebar.height)
        UIDropDownMenu_Initialize(
            self.Window.TitleBar.SortingButton.Dropdown,
            function()
                for _, option in ipairs(self.constants.sortingOptions) do
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
            end,
            "MENU"
        )
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
        self.Window.TitleBar.CharactersButton = CreateFrame("Button", "$parentCharacters", self.Window.TitleBar)
        self.Window.TitleBar.CharactersButton:SetPoint("RIGHT", self.Window.TitleBar.SortingButton, "LEFT", 0, 0)
        self.Window.TitleBar.CharactersButton:SetSize(self.constants.sizes.titlebar.height, self.constants.sizes.titlebar.height)
        self.Window.TitleBar.CharactersButton:SetScript("OnClick", function() ToggleDropDownMenu(1, nil, self.Window.TitleBar.CharactersButton.Dropdown) end)
        self.Window.TitleBar.CharactersButton.Icon = self.Window.TitleBar:CreateTexture(self.Window.TitleBar.CharactersButton:GetName() .. "Icon", "ARTWORK")
        self.Window.TitleBar.CharactersButton.Icon:SetPoint("CENTER", self.Window.TitleBar.CharactersButton, "CENTER")
        self.Window.TitleBar.CharactersButton.Icon:SetSize(14, 14)
        self.Window.TitleBar.CharactersButton.Icon:SetTexture(self.constants.media.IconCharacters)
        self.Window.TitleBar.CharactersButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
        self.Window.TitleBar.CharactersButton.Dropdown = CreateFrame("Frame", self.Window.TitleBar.CharactersButton:GetName() .. "Dropdown", self.Window.TitleBar.CharactersButton, "UIDropDownMenuTemplate")
        self.Window.TitleBar.CharactersButton.Dropdown:SetPoint("CENTER", self.Window.TitleBar.CharactersButton, "CENTER", 0, -6)
        self.Window.TitleBar.CharactersButton.Dropdown.Button:Hide()
        UIDropDownMenu_SetWidth(self.Window.TitleBar.CharactersButton.Dropdown, self.constants.sizes.titlebar.height)
        UIDropDownMenu_Initialize(
            self.Window.TitleBar.CharactersButton.Dropdown,
            function()
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
            end,
            "MENU"
        )
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
        self.Window.TitleBar.AnnounceButton = CreateFrame("Button", "$parentCharacters", self.Window.TitleBar)
        self.Window.TitleBar.AnnounceButton:SetPoint("RIGHT", self.Window.TitleBar.CharactersButton, "LEFT", 0, 0)
        self.Window.TitleBar.AnnounceButton:SetSize(self.constants.sizes.titlebar.height, self.constants.sizes.titlebar.height)
        self.Window.TitleBar.AnnounceButton:SetScript("OnClick", function() ToggleDropDownMenu(1, nil, self.Window.TitleBar.AnnounceButton.Dropdown) end)
        self.Window.TitleBar.AnnounceButton.Icon = self.Window.TitleBar:CreateTexture(self.Window.TitleBar.AnnounceButton:GetName() .. "Icon", "ARTWORK")
        self.Window.TitleBar.AnnounceButton.Icon:SetPoint("CENTER", self.Window.TitleBar.AnnounceButton, "CENTER")
        self.Window.TitleBar.AnnounceButton.Icon:SetSize(12, 12)
        self.Window.TitleBar.AnnounceButton.Icon:SetTexture(self.constants.media.IconAnnounce)
        self.Window.TitleBar.AnnounceButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
        self.Window.TitleBar.AnnounceButton.Dropdown = CreateFrame("Frame", self.Window.TitleBar.AnnounceButton:GetName() .. "Dropdown", self.Window.TitleBar.AnnounceButton, "UIDropDownMenuTemplate")
        self.Window.TitleBar.AnnounceButton.Dropdown:SetPoint("CENTER", self.Window.TitleBar.AnnounceButton, "CENTER", 0, -6)
        self.Window.TitleBar.AnnounceButton.Dropdown.Button:Hide()
        UIDropDownMenu_SetWidth(self.Window.TitleBar.AnnounceButton.Dropdown, self.constants.sizes.titlebar.height)
        UIDropDownMenu_Initialize(
            self.Window.TitleBar.AnnounceButton.Dropdown,
            function()
                UIDropDownMenu_AddButton({
                    text = "Send to Party Chat",
                    isNotRadio = true,
                    notCheckable = true,
                    tooltipTitle = "Party",
                    tooltipText = "Announce all your keystones to the party chat",
                    tooltipOnButton = true,
                    func = function()
                        if not IsInGroup() then
                            self:Print("No announcement. You are not in a party.")
                            return
                        end
                        self:AnnounceKeystones("PARTY", self.db.global.announceKeystones.multiline)
                    end
                })
                UIDropDownMenu_AddButton({
                    text = "Send to Guild Chat",
                    isNotRadio = true,
                    notCheckable = true,
                    tooltipTitle = "Guild",
                    tooltipText = "Announce all your keystones to the guild chat",
                    tooltipOnButton = true,
                    func = function()
                        if not IsInGuild() then
                            self:Print("No announcement. You are not in a guild.")
                            return
                        end
                        self:AnnounceKeystones("GUILD", self.db.global.announceKeystones.multiline)
                    end
                })
            end,
            "MENU"
        )
        self.Window.TitleBar.AnnounceButton:SetScript("OnEnter", function()
            self.Window.TitleBar.AnnounceButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
            SetBackgroundColor(self.Window.TitleBar.AnnounceButton, 1, 1, 1, 0.05)
            GameTooltip:ClearAllPoints()
            GameTooltip:ClearLines()
            GameTooltip:SetOwner(self.Window.TitleBar.AnnounceButton, "ANCHOR_TOP")
            GameTooltip:SetText("Announce Keystones", 1, 1, 1, 1, true);
            GameTooltip:AddLine("Sharing is caring.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
            GameTooltip:Show()
        end)
        self.Window.TitleBar.AnnounceButton:SetScript("OnLeave", function()
            self.Window.TitleBar.AnnounceButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
            SetBackgroundColor(self.Window.TitleBar.AnnounceButton, 1, 1, 1, 0)
            GameTooltip:Hide()
        end)
    end

    do -- Body
        self.Window.Body = CreateFrame("Frame", "$parentBody", self.Window)
        self.Window.Body:SetPoint("TOPLEFT", self.Window.TitleBar, "BOTTOMLEFT")
        self.Window.Body:SetPoint("TOPRIGHT", self.Window.TitleBar, "BOTTOMRIGHT")
        SetBackgroundColor(self.Window.Body, 0, 0, 0, 0)
    end

    do -- No characters enabled
        self.Window.Body.NoCharacterText = self.Window.Body:CreateFontString("$parentNoCharacterText", "ARTWORK")
        self.Window.Body.NoCharacterText:SetPoint("TOPLEFT", self.Window.Body, "TOPLEFT", 50, -50)
        self.Window.Body.NoCharacterText:SetPoint("BOTTOMRIGHT", self.Window.Body, "BOTTOMRIGHT", -50, 50)
        self.Window.Body.NoCharacterText:SetJustifyH("CENTER")
        self.Window.Body.NoCharacterText:SetJustifyV("CENTER")
        self.Window.Body.NoCharacterText:SetFont(self.constants.font.file, self.db.global.interface.fontSize, self.constants.font.flags)
        self.Window.Body.NoCharacterText:SetText("|cffffffffHi there :-)|r\n\nYou need to enable a max level character for this addon to show you some goodies!")
        self.Window.Body.NoCharacterText:SetVertexColor(1.0, 0.82, 0.0, 1)
        self.Window.Body.NoCharacterText:Hide()
    end

    do -- Sidebar
        self.Window.Body.Sidebar = CreateFrame("Frame", "$parentSidebar", self.Window.Body)
        self.Window.Body.Sidebar:SetPoint("TOPLEFT", self.Window.Body, "TOPLEFT")
        self.Window.Body.Sidebar:SetPoint("BOTTOMLEFT", self.Window.Body, "BOTTOMLEFT")
        self.Window.Body.Sidebar:SetWidth(self.constants.sizes.sidebar.width)
        SetBackgroundColor(self.Window.Body.Sidebar, 0, 0, 0, 0.3)
        anchorFrame = self.Window.Body.Sidebar
    end

    do -- Character info
        for labelIndex, info in ipairs(labels) do
            local Label = CreateFrame("Frame", "$parentLabel" .. labelIndex, self.Window.Body.Sidebar)
            if labelIndex > 1 then
                Label:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
                Label:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
            else
                Label:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT")
                Label:SetPoint("TOPRIGHT", anchorFrame, "TOPRIGHT")
            end
            Label:SetHeight(self.constants.sizes.row)
            Label.Text = Label:CreateFontString(Label:GetName() .. "Text", "OVERLAY")
            Label.Text:SetPoint("LEFT", Label, "LEFT", self.constants.sizes.padding, 0)
            Label.Text:SetPoint("RIGHT", Label, "RIGHT", -self.constants.sizes.padding, 0)
            Label.Text:SetJustifyH("LEFT")
            Label.Text:SetFont(self.constants.font.file, self.db.global.interface.fontSize, self.constants.font.flags)
            Label.Text:SetText(info.label)
            Label.Text:SetVertexColor(1.0, 0.82, 0.0, 1)
            anchorFrame = Label
        end
    end

    do -- MythicPlus Label
        local Label = CreateFrame("Frame", "$parentMythicPlusLabel", self.Window.Body.Sidebar)
        Label:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
        Label:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
        Label:SetHeight(self.constants.sizes.row)
        Label.Text = Label:CreateFontString(Label:GetName() .. "Text", "OVERLAY")
        Label.Text:SetPoint("TOPLEFT", Label, "TOPLEFT", self.constants.sizes.padding, 0)
        Label.Text:SetPoint("BOTTOMRIGHT", Label, "BOTTOMRIGHT", -self.constants.sizes.padding, 0)
        Label.Text:SetFont(self.constants.font.file, self.db.global.interface.fontSize, self.constants.font.flags)
        Label.Text:SetJustifyH("LEFT")
        Label.Text:SetText("Mythic Plus")
        Label.Text:SetVertexColor(1.0, 0.82, 0.0, 1)
        anchorFrame = Label
    end

    do -- Dungeon names
        for dungeonIndex, dungeon in ipairs(dungeons) do
            local Label = CreateFrame("Button", "$parentDungeon" .. dungeonIndex, self.Window.Body.Sidebar, "InsecureActionButtonTemplate")
            Label:SetPoint("TOPLEFT", anchorFrame:GetName(), "BOTTOMLEFT")
            Label:SetPoint("TOPRIGHT", anchorFrame:GetName(), "BOTTOMRIGHT")
            Label:SetHeight(self.constants.sizes.row)
            Label.Icon = Label:CreateTexture(Label:GetName() .. "Icon", "ARTWORK")
            Label.Icon:SetSize(16, 16)
            Label.Icon:SetPoint("LEFT", Label, "LEFT", self.constants.sizes.padding, 0)
            Label.Icon:SetTexture(dungeon.icon)
            Label.Text = Label:CreateFontString(Label:GetName() .. "Text", "OVERLAY")
            Label.Text:SetPoint("TOPLEFT", Label, "TOPLEFT", 16 + self.constants.sizes.padding * 2, -3)
            Label.Text:SetPoint("BOTTOMRIGHT", Label, "BOTTOMRIGHT", -self.constants.sizes.padding, 3)
            Label.Text:SetJustifyH("LEFT")
            Label.Text:SetFont(self.constants.font.file, self.db.global.interface.fontSize, self.constants.font.flags)
            Label.Text:SetText(dungeon.short and dungeon.short or dungeon.name)
            anchorFrame = Label
        end
    end

    do -- Raids & Difficulties
        for raidIndex, raid in ipairs(raids) do
            local RaidFrame = CreateFrame("Frame", "$parentRaid" .. raidIndex, self.Window.Body.Sidebar)
            RaidFrame:SetHeight(self.constants.sizes.row)
            RaidFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
            RaidFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
            RaidFrame:SetScript("OnEnter", function()
                GameTooltip:ClearAllPoints()
                GameTooltip:ClearLines()
                GameTooltip:SetOwner(RaidFrame, "ANCHOR_RIGHT")
                GameTooltip:SetText(raid.name, 1, 1, 1);
                GameTooltip:Show()
            end)
            RaidFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
            RaidFrame.Text = RaidFrame:CreateFontString(RaidFrame:GetName() .. "Text", "OVERLAY")
            RaidFrame.Text:SetPoint("TOPLEFT", RaidFrame, "TOPLEFT", self.constants.sizes.padding, 0)
            RaidFrame.Text:SetPoint("BOTTOMRIGHT", RaidFrame, "BOTTOMRIGHT", -self.constants.sizes.padding, 0)
            RaidFrame.Text:SetFont(self.constants.font.file, self.db.global.interface.fontSize, self.constants.font.flags)
            RaidFrame.Text:SetJustifyH("LEFT")
            RaidFrame.Text:SetText(raid.short and raid.short or raid.name)
            RaidFrame.Text:SetVertexColor(1.0, 0.82, 0.0, 1)
            anchorFrame = RaidFrame

            for difficultyIndex, difficulty in ipairs(difficulties) do
                local DifficultFrame = CreateFrame("Frame", "$parentDifficulty" .. difficultyIndex, RaidFrame)
                DifficultFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
                DifficultFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
                DifficultFrame:SetHeight(self.constants.sizes.row)
                DifficultFrame:SetScript("OnEnter", function()
                    GameTooltip:ClearAllPoints()
                    GameTooltip:ClearLines()
                    GameTooltip:SetOwner(DifficultFrame, "ANCHOR_RIGHT")
                    GameTooltip:SetText(difficulty.name, 1, 1, 1);
                    GameTooltip:Show()
                end)
                DifficultFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
                DifficultFrame.Text = DifficultFrame:CreateFontString(DifficultFrame:GetName() .. "Text", "OVERLAY")
                DifficultFrame.Text:SetPoint("TOPLEFT", DifficultFrame, "TOPLEFT", self.constants.sizes.padding, -3)
                DifficultFrame.Text:SetPoint("BOTTOMRIGHT", DifficultFrame, "BOTTOMRIGHT", -self.constants.sizes.padding, 3)
                DifficultFrame.Text:SetJustifyH("LEFT")
                DifficultFrame.Text:SetFont(self.constants.font.file, self.db.global.interface.fontSize, self.constants.font.flags)
                DifficultFrame.Text:SetText(difficulty.short and difficulty.short or difficulty.name)
                -- RaidLabel.Icon = RaidLabel:CreateTexture(RaidLabel:GetName() .. "Icon", "ARTWORK")
                -- RaidLabel.Icon:SetSize(16, 16)
                -- RaidLabel.Icon:SetPoint("LEFT", RaidLabel, "LEFT", self.constants.sizes.padding, 0)
                -- RaidLabel.Icon:SetTexture(raid.icon)
                anchorFrame = DifficultFrame
            end
        end
    end

    self.Window.Body.ScrollFrame = CreateFrame("ScrollFrame", "$parentScrollFrame", self.Window.Body)
    self.Window.Body.ScrollFrame:SetPoint("TOPLEFT", self.Window.Body, "TOPLEFT", self.constants.sizes.sidebar.width, 0)
    self.Window.Body.ScrollFrame:SetPoint("BOTTOMLEFT", self.Window.Body, "BOTTOMLEFT", self.constants.sizes.sidebar.width, 0)
    self.Window.Body.ScrollFrame:SetPoint("BOTTOMRIGHT", self.Window.Body, "BOTTOMRIGHT")
    self.Window.Body.ScrollFrame:SetPoint("TOPRIGHT", self.Window.Body, "TOPRIGHT")
    self.Window.Body.ScrollFrame.ScrollChild = CreateFrame("Frame", "$parentScrollChild", self.Window.Body.ScrollFrame)
    self.Window.Body.ScrollFrame:SetScrollChild(self.Window.Body.ScrollFrame.ScrollChild)

    self.Window.Footer = CreateFrame("Frame", "$parentFooter", self.Window)
    self.Window.Footer:SetHeight(self.constants.sizes.footer.height)
    self.Window.Footer:SetPoint("BOTTOMLEFT", self.Window, "BOTTOMLEFT")
    self.Window.Footer:SetPoint("BOTTOMRIGHT", self.Window, "BOTTOMRIGHT")
    SetBackgroundColor(self.Window.Footer, 0, 0, 0, .3)

    self.Window.Footer.Scrollbar = CreateFrame("Slider", "$parentScrollbar", self.Window.Footer, "UISliderTemplate")
    self.Window.Footer.Scrollbar:SetPoint("TOPLEFT", self.Window.Footer, "TOPLEFT", self.constants.sizes.sidebar.width, 0)
    self.Window.Footer.Scrollbar:SetPoint("BOTTOMRIGHT", self.Window.Footer, "BOTTOMRIGHT", -self.constants.sizes.padding / 2, 0)
    self.Window.Footer.Scrollbar:SetMinMaxValues(0, 100)
    self.Window.Footer.Scrollbar:SetValue(0)
    self.Window.Footer.Scrollbar:SetValueStep(1)
    self.Window.Footer.Scrollbar:SetOrientation("HORIZONTAL")
    self.Window.Footer.Scrollbar:SetObeyStepOnDrag(true)
    self.Window.Footer.Scrollbar.NineSlice:Hide()
    self.Window.Footer.Scrollbar.thumb = self.Window.Footer.Scrollbar:GetThumbTexture()
    self.Window.Footer.Scrollbar.thumb:SetPoint("CENTER")
    self.Window.Footer.Scrollbar.thumb:SetColorTexture(1, 1, 1, 0.15)
    self.Window.Footer.Scrollbar.thumb:SetHeight(self.constants.sizes.footer.height - 10)
    self.Window.Footer.Scrollbar:SetScript("OnValueChanged", function(_, value)
        self.Window.Body.ScrollFrame:SetHorizontalScroll(value)
    end)
    self.Window.Footer.Scrollbar:SetScript("OnEnter", function()
        self.Window.Footer.Scrollbar.thumb:SetColorTexture(1, 1, 1, 0.2)
    end)
    self.Window.Footer.Scrollbar:SetScript("OnLeave", function()
        self.Window.Footer.Scrollbar.thumb:SetColorTexture(1, 1, 1, 0.15)
    end)
    self.Window.Body.ScrollFrame:SetScript("OnMouseWheel", function(_, delta)
        self.Window.Footer.Scrollbar:SetValue(self.Window.Footer.Scrollbar:GetValue() - delta * ((self.Window.Body.ScrollFrame.ScrollChild:GetWidth() - self.Window.Body.ScrollFrame:GetWidth()) * 0.1))
    end)

    self.Window.Body:SetPoint("BOTTOMLEFT", self.Window.Footer, "TOPLEFT")
    self.Window.Body:SetPoint("BOTTOMRIGHT", self.Window.Footer, "TOPRIGHT")
    self:UpdateUI()
end

function AlterEgo:UpdateUI()
    if not self.Window then return end

    local affixes = self:GetAffixes()
    local characters = self:GetCharacters()
    local numCharacters = AE_table_count(self:GetCharacters())
    local charactersUnfiltered = self:GetCharacters(true)
    local dungeons = self:GetDungeons()
    local raids = self:GetRaids()
    local difficulties = self:GetRaidDifficulties()
    local labels = self:GetCharacterInfo()
    local anchorFrame

    if numCharacters == 0 then
        self.Window.Body.Sidebar:Hide()
        self.Window.Body.ScrollFrame:Hide()
        self.Window.Footer:Hide()
        self.Window.Body.NoCharacterText:Show()
    else
        self.Window.Body.Sidebar:Show()
        self.Window.Body.ScrollFrame:Show()
        self.Window.Footer:Show()
        self.Window.Body.NoCharacterText:Hide()
    end

    self.Window:SetSize(self:GetWindowSize())
    self.Window:SetScale(self.db.global.interface.windowScale / 100)
    SetBackgroundColor(self.Window, self.db.global.interface.windowColor.r, self.db.global.interface.windowColor.g, self.db.global.interface.windowColor.b, self.db.global.interface.windowColor.a)
    self.Window.Body.ScrollFrame.ScrollChild:SetSize(numCharacters * self.constants.sizes.column, self.Window.Body.ScrollFrame:GetHeight())

    if self:IsScrollbarNeeded() then
        self.Window.Footer.Scrollbar:SetMinMaxValues(0, self.Window.Body.ScrollFrame.ScrollChild:GetWidth() - self.Window.Body.ScrollFrame:GetWidth())
        self.Window.Footer.Scrollbar.thumb:SetWidth(self.Window.Footer.Scrollbar:GetWidth() / 10)
        self.Window.Body:SetPoint("BOTTOMLEFT", self.Window.Footer, "TOPLEFT")
        self.Window.Body:SetPoint("BOTTOMRIGHT", self.Window.Footer, "TOPRIGHT")
        self.Window.Footer:Show()
    else
        self.Window.Body.ScrollFrame:SetHorizontalScroll(0)
        self.Window.Body:SetPoint("BOTTOMLEFT", self.Window, "BOTTOMLEFT")
        self.Window.Body:SetPoint("BOTTOMRIGHT", self.Window, "BOTTOMRIGHT")
        self.Window.Footer:Hide()
    end

    self.Window.Body.NoCharacterText:SetFont(assets.font.file, self.db.global.interface.fontSize, assets.font.flags)

    local currentAffixes = C_MythicPlus.GetCurrentAffixes();
    anchorFrame = self.Window.TitleBar
    for i = 1, 3 do
        local frame = self.Window.TitleBar["Affix" .. i]
        if frame then
            if currentAffixes then
                local name, desc, filedataid = C_ChallengeMode.GetAffixInfo(currentAffixes[i].id);
                frame:SetTexture(filedataid)
                frame:SetScript("OnEnter", function()
                    GameTooltip:ClearAllPoints()
                    GameTooltip:ClearLines()
                    GameTooltip:SetOwner(frame, "ANCHOR_TOP")
                    GameTooltip:SetText(name, 1, 1, 1);
                    GameTooltip:AddLine(desc, nil, nil, nil, true)
                    GameTooltip:Show()
                end)
                frame:SetScript("OnLeave", function() GameTooltip:Hide() end)
            end
            if i == 1 then
                frame:ClearAllPoints()
                if numCharacters == 1 then
                    frame:SetPoint("LEFT", self.Window.TitleBar.Icon, "RIGHT", 6, 0)
                    self.Window.TitleBar.Text:Hide()
                else
                    frame:SetPoint("CENTER", anchorFrame, "CENTER", -26, 0)
                    self.Window.TitleBar.Text:Show()
                end
            else
                frame:SetPoint("LEFT", anchorFrame, "RIGHT", 6, 0)
            end
            if self.db.global.showAffixHeader then
                frame:Show()
            else
                frame:Hide()
            end
            anchorFrame = frame
        end
    end

    self:HideCharacterColumns()

    do -- Character Labels
        anchorFrame = self.Window.Body.Sidebar
        for labelIndex, info in ipairs(labels) do
            local Label = _G[self.Window.Body.Sidebar:GetName() .. "Label" .. labelIndex]
            if info.enabled ~= nil and not info.enabled then
                Label:Hide()
            else
                if labelIndex > 1 then
                    Label:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
                    Label:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
                else
                    Label:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT")
                    Label:SetPoint("TOPRIGHT", anchorFrame, "TOPRIGHT")
                end
                Label.Text:SetFont(assets.font.file, self.db.global.interface.fontSize, assets.font.flags)
                Label:Show()
                anchorFrame = Label
            end
        end
    end

    do -- MythicPlus Label
        local Label = _G[self.Window.Body.Sidebar:GetName() .. "MythicPlusLabel"]
        Label.Text:SetFont(assets.font.file, self.db.global.interface.fontSize, assets.font.flags)
    end

    do -- Dungeon names
        for dungeonIndex, dungeon in ipairs(dungeons) do
            local Label = _G[self.Window.Body.Sidebar:GetName() .. "Dungeon" .. dungeonIndex]
            Label.Icon:SetTexture(dungeon.icon)
            Label.Text:SetFont(self.constants.font.file, self.db.global.interface.fontSize, self.constants.font.flags)
            Label.Text:SetText(dungeon.short and dungeon.short or dungeon.name)
            Label.Icon:SetTexture(tostring(dungeon.texture))
            if dungeon.spellID and IsSpellKnown(dungeon.spellID) and not InCombatLockdown() then
                Label:SetAttribute("type", "spell")
                Label:SetAttribute("spell", dungeon.spellID)
                Label:RegisterForClicks("AnyUp", "AnyDown")
                Label:EnableMouse(true)
            end
            Label:SetScript("OnEnter", function()
                GameTooltip:ClearAllPoints()
                GameTooltip:ClearLines()
                GameTooltip:SetOwner(Label, "ANCHOR_RIGHT")
                GameTooltip:SetText(dungeon.name, 1, 1, 1);
                if dungeon.spellID then
                    if IsSpellKnown(dungeon.spellID) then
                        GameTooltip:ClearLines()
                        GameTooltip:SetSpellByID(dungeon.spellID)
                        _G[GameTooltip:GetName() .. "TextLeft1"]:SetText(dungeon.name)
                    else
                        GameTooltip:AddLine("Time this dungeon on level 20 to unlock teleportation.", nil, nil, nil, true)
                    end
                end
                GameTooltip:Show()
            end)
            Label:SetScript("OnLeave", function() GameTooltip:Hide() end)
        end
    end

    do -- Raids & Difficulties
        for raidIndex in ipairs(raids) do
            local Label = _G[self.Window.Body.Sidebar:GetName() .. "Raid" .. raidIndex]
            if self.db.global.raids.enabled then
                Label.Text:SetFont(assets.font.file, self.db.global.interface.fontSize, assets.font.flags)
                Label:Show()
            else
                Label:Hide()
            end

            for difficultyIndex, difficulty in ipairs(difficulties) do
                local DifficultFrame = _G[Label:GetName() .. "Difficulty" .. difficultyIndex]
                if DifficultFrame then
                    DifficultFrame.Text:SetFont(assets.font.file, self.db.global.interface.fontSize, assets.font.flags)
                end
            end
        end
    end

    do -- Characters
        anchorFrame = self.Window.Body.ScrollFrame.ScrollChild
        for characterIndex, character in ipairs(characters) do
            local CharacterColumn = self:GetCharacterColumn(self.Window.Body.ScrollFrame.ScrollChild, characterIndex)
            if characterIndex > 1 then
                CharacterColumn:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT")
                CharacterColumn:SetPoint("BOTTOMLEFT", anchorFrame, "BOTTOMRIGHT")
            else
                CharacterColumn:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT")
                CharacterColumn:SetPoint("BOTTOMLEFT", anchorFrame, "BOTTOMLEFT")
            end
            SetBackgroundColor(CharacterColumn, 1, 1, 1, characterIndex % 2 == 0 and 0.01 or 0)
            anchorFrame = CharacterColumn

            do -- Character info
                anchorFrame = CharacterColumn
                for labelIndex, info in ipairs(labels) do
                    local CharacterFrame = _G[CharacterColumn:GetName() .. "Info" .. labelIndex]
                    CharacterFrame.Text:SetText(info.value(character))
                    CharacterFrame.Text:SetFont(assets.font.file, self.db.global.interface.fontSize, assets.font.flags)
                    if info.OnEnter then
                        CharacterFrame:SetScript("OnEnter", function()
                            GameTooltip:ClearAllPoints()
                            GameTooltip:ClearLines()
                            GameTooltip:SetOwner(CharacterFrame, "ANCHOR_RIGHT")
                            info.OnEnter(character)
                            GameTooltip:Show()
                            if not info.backgroundColor then
                                SetBackgroundColor(CharacterFrame, 1, 1, 1, 0.05)
                            end
                        end)
                        CharacterFrame:SetScript("OnLeave", function()
                            GameTooltip:Hide()
                            if not info.backgroundColor then
                                SetBackgroundColor(CharacterFrame, 1, 1, 1, 0)
                            end
                        end)
                    else
                        if not info.backgroundColor then
                            CharacterFrame:SetScript("OnEnter", function()
                                SetBackgroundColor(CharacterFrame, 1, 1, 1, 0.05)
                            end)
                            CharacterFrame:SetScript("OnLeave", function()
                                SetBackgroundColor(CharacterFrame, 1, 1, 1, 0)
                            end)
                        end
                    end
                    if info.OnClick then
                        CharacterFrame:SetScript("OnClick", function()
                            info.OnClick(character)
                        end)
                    end
                    if info.enabled ~= nil and not info.enabled then
                        CharacterFrame:Hide()
                    else
                        if labelIndex > 1 then
                            CharacterFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
                            CharacterFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
                        else
                            CharacterFrame:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT")
                            CharacterFrame:SetPoint("TOPRIGHT", anchorFrame, "TOPRIGHT")
                        end
                        anchorFrame = CharacterFrame
                        CharacterFrame:Show()
                    end
                end
            end

            do -- Dungeon rows
                -- Todo: Look into C_ChallengeMode.GetKeystoneLevelRarityColor(level)
                for dungeonIndex, dungeon in ipairs(dungeons) do
                    local DungeonFrame = _G[CharacterColumn:GetName() .. "Dungeons" .. dungeonIndex]
                    local characterDungeon = AE_table_get(character.mythicplus.dungeons, "challengeModeID", dungeon.challengeModeID)
                    local scoreColor = HIGHLIGHT_FONT_COLOR
                    if characterDungeon and characterDungeon.affixScores and AE_table_count(characterDungeon.affixScores) > 0 then
                        if (characterDungeon.rating) then
                            local color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(characterDungeon.rating);
                            if color then
                                scoreColor = color
                            end
                        end
                    end
                    DungeonFrame:SetScript("OnEnter", function()
                        GameTooltip:ClearAllPoints()
                        GameTooltip:ClearLines()
                        GameTooltip:SetOwner(DungeonFrame, "ANCHOR_RIGHT")
                        GameTooltip:SetText(dungeon.name, 1, 1, 1);
                        if characterDungeon and characterDungeon.affixScores and AE_table_count(characterDungeon.affixScores) > 0 then
                            if (characterDungeon.rating) then
                                GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_TOTAL_SCORE:format(scoreColor:WrapTextInColorCode(characterDungeon.rating)), GREEN_FONT_COLOR);
                            end
                            for _, affixInfo in ipairs(characterDungeon.affixScores) do
                                GameTooltip_AddBlankLineToTooltip(GameTooltip);
                                GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_BEST_AFFIX:format(affixInfo.name));
                                GameTooltip_AddColoredLine(GameTooltip, MYTHIC_PLUS_POWER_LEVEL:format(affixInfo.level), HIGHLIGHT_FONT_COLOR);
                                if (affixInfo.overTime) then
                                    if (affixInfo.durationSec >= SECONDS_PER_HOUR) then
                                        GameTooltip_AddColoredLine(GameTooltip, DUNGEON_SCORE_OVERTIME_TIME:format(SecondsToClock(affixInfo.durationSec, true)), LIGHTGRAY_FONT_COLOR);
                                    else
                                        GameTooltip_AddColoredLine(GameTooltip, DUNGEON_SCORE_OVERTIME_TIME:format(SecondsToClock(affixInfo.durationSec, false)), LIGHTGRAY_FONT_COLOR);
                                    end
                                else
                                    if (affixInfo.durationSec >= SECONDS_PER_HOUR) then
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
                        SetBackgroundColor(DungeonFrame, 1, 1, 1, dungeonIndex % 2 == 0 and 0.01 or 0)
                    end)

                    for affixIndex, affix in ipairs(affixes) do
                        local AffixFrame = _G[CharacterColumn:GetName() .. "Dungeons" .. dungeonIndex .. "Affix" .. affixIndex]
                        local level = "-"
                        local levelColor = "ffffffff"
                        local tier = ""

                        if characterDungeon == nil or characterDungeon.affixScores == nil then
                            level = "-"
                            levelColor = LIGHTGRAY_FONT_COLOR:GenerateHexColor()
                        else
                            for _, affixScore in ipairs(characterDungeon.affixScores) do
                                if affixScore.name == affix.name then
                                    level = affixScore.level

                                    if affixScore.durationSec <= dungeon.time * 0.6 then
                                        tier = "|A:Professions-ChatIcon-Quality-Tier3:16:16:0:-1|a"
                                    elseif affixScore.durationSec <= dungeon.time * 0.8 then
                                        tier = "|A:Professions-ChatIcon-Quality-Tier2:16:16:0:-1|a"
                                    elseif affixScore.durationSec <= dungeon.time then
                                        tier = "|A:Professions-ChatIcon-Quality-Tier1:14:14:0:-1|a"
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
                        AffixFrame.Text:SetFont(assets.font.file, self.db.global.interface.fontSize, assets.font.flags)
                        AffixFrame.Tier:SetText(tier)
                        AffixFrame.Tier:SetFont(assets.font.file, self.db.global.interface.fontSize, assets.font.flags)

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
            end

            do -- Raid Rows
                for raidIndex, raid in ipairs(raids) do
                    local RaidFrame = _G[CharacterColumn:GetName() .. "Raid" .. raidIndex]
                    if self.db.global.raids.enabled then
                        RaidFrame:Show()
                    else
                        RaidFrame:Hide()
                    end
                    for difficultyIndex, difficulty in pairs(difficulties) do
                        local DifficultyFrame = _G[RaidFrame:GetName() .. "Difficulty" .. difficultyIndex]
                        DifficultyFrame:SetScript("OnEnter", function()
                            GameTooltip:ClearAllPoints()
                            GameTooltip:ClearLines()
                            GameTooltip:SetOwner(DifficultyFrame, "ANCHOR_RIGHT")
                            GameTooltip:SetText("Raid Progress", 1, 1, 1, 1, true);
                            GameTooltip:AddLine(format("Difficulty: |cffffffff%s|r", difficulty.short and difficulty.short or difficulty.name));
                            if character.raids.savedInstances ~= nil then
                                local savedInstance = AE_table_find(character.raids.savedInstances, function(savedInstance)
                                    return savedInstance.difficultyID == difficulty.id and savedInstance.instanceID == raid.instanceID and savedInstance.expires > time()
                                end)
                                if savedInstance ~= nil then
                                    GameTooltip:AddLine(format("Expires: |cffffffff%s|r", date("%c", savedInstance.expires)))
                                end
                            end
                            GameTooltip:AddLine(" ")
                            for _, encounter in ipairs(raid.encounters) do
                                local color = LIGHTGRAY_FONT_COLOR
                                if character.raids.savedInstances then
                                    local savedInstance = AE_table_find(character.raids.savedInstances, function(savedInstance)
                                        return savedInstance.difficultyID == difficulty.id and savedInstance.instanceID == raid.instanceID and savedInstance.expires > time()
                                    end)
                                    if savedInstance ~= nil then
                                        local savedEncounter = AE_table_find(savedInstance.encounters, function(enc)
                                            return enc.instanceEncounterID == encounter.instanceEncounterID and enc.killed == true
                                        end)
                                        if savedEncounter ~= nil then
                                            color = GREEN_FONT_COLOR
                                        end
                                    end
                                end
                                GameTooltip:AddLine(WrapTextInColorCode(encounter.name, color:GenerateHexColor()))
                            end
                            GameTooltip:Show()
                            SetBackgroundColor(DifficultyFrame, 1, 1, 1, 0.05)
                        end)
                        DifficultyFrame:SetScript("OnLeave", function()
                            GameTooltip:Hide()
                            SetBackgroundColor(DifficultyFrame, 1, 1, 1, 0)
                        end)
                        anchorFrame = DifficultyFrame
                        for encounterIndex, encounter in ipairs(raid.encounters) do
                            local color = {r = 1, g = 1, b = 1}
                            local alpha = 0.1
                            local EncounterFrame = _G[DifficultyFrame:GetName() .. "Encounter" .. encounterIndex]
                            if not EncounterFrame then
                                EncounterFrame = CreateFrame("Frame", "$parentEncounter" .. encounterIndex, DifficultyFrame)
                                local size = self.constants.sizes.column
                                size = size - self.constants.sizes.padding -- left/right cell padding
                                size = size - (raid.numEncounters - 1) * 4 -- gaps
                                size = size / raid.numEncounters           -- box sizes
                                EncounterFrame:SetPoint("LEFT", anchorFrame, encounterIndex > 1 and "RIGHT" or "LEFT", self.constants.sizes.padding / 2, 0)
                                EncounterFrame:SetSize(size, self.constants.sizes.row - 12)
                                SetBackgroundColor(EncounterFrame, 1, 1, 1, 0.1)
                                anchorFrame = EncounterFrame
                            end
                            if character.raids.savedInstances then
                                local savedInstance = AE_table_find(character.raids.savedInstances, function(savedInstance)
                                    return savedInstance.difficultyID == difficulty.id and savedInstance.instanceID == raid.instanceID and savedInstance.expires > time()
                                end)
                                if savedInstance ~= nil then
                                    local savedEncounter = AE_table_find(savedInstance.encounters, function(enc)
                                        return enc.instanceEncounterID == encounter.instanceEncounterID and enc.killed == true
                                    end)
                                    if savedEncounter ~= nil then
                                        color = UNCOMMON_GREEN_COLOR
                                        if self.db.global.raids.colors then
                                            color = difficulty.color
                                        end
                                        alpha = 0.5
                                    end
                                end
                            end
                            SetBackgroundColor(EncounterFrame, color.r, color.g, color.b, alpha)
                        end
                        anchorFrame = CharacterColumn
                    end
                end
            end
            anchorFrame = CharacterColumn
        end
    end
end