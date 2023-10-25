---@diagnostic disable: inject-field
local labels = {"Character", "Realm", "Rating", "ItemLevel", "Vault", "Current Key"}
local affixes = {
    [1] = {
        id = 9,
        name = "Tyrannical",
        icon = "Interface/Icons/achievement_boss_archaedas"
    },
    [2] = {
        id = 10,
        name = "Fortified",
        icon = "Interface/Icons/ability_toughness"
    },
}

function AlterEgo:GetWindowSize()
    local characters = self:GetCharacters()
    -- TODO: Create a method for this
    local dungeons = self.constants.dungeons
    local width = self.constants.sizes.sidebar.width + #characters * self.constants.sizes.column
    local height = self.constants.sizes.titlebar.height + (#labels + 1 + #dungeons) * self.constants.sizes.row
    return width, height
end

function AlterEgo:CreateNewUI()
    if self.Window then return end

    local characters = self:GetCharacters()
    local charactersUnfiltered = self.db.global.characters
    -- TODO: Create a method for this
    local dungeons = self.constants.dungeons

    self.Window = CreateFrame("Frame", "AlterEgoWindow", UIParent)
    -- Border
    -- TODO: Make this work with insets
    self.Window.Border = CreateFrame("Frame", self.Window:GetName() .. "Border", self.Window, "BackdropTemplate")
    self.Window.Border:SetPoint("TOPLEFT", self.Window, "TOPLEFT", -10, -10)
    self.Window.Border:SetPoint("BOTTOMRIGHT", self.Window, "BOTTOMRIGHT", 10, 10)
    self.Window.Border:Hide()
    -- TitleBar
    self.Window.TitleBar = CreateFrame("Frame", self.Window:GetName() .. "TitleBar", self.Window)
    self.Window.TitleBar:SetPoint("TOPLEFT", self.Window, "TOPLEFT")
    self.Window.TitleBar:SetPoint("TOPRIGHT", self.Window, "TOPRIGHT")
    self.Window.TitleBar:SetHeight(self.constants.frame.titleBarHeight)
    self.Window.TitleBar.Icon = self.Window.TitleBar:CreateTexture(self.Window.TitleBar:GetName() .. "Icon", "ARTWORK")
    self.Window.TitleBar.Icon:SetPoint("LEFT", self.Window.TitleBar, "LEFT")
    self.Window.TitleBar.Icon:SetSize(20, 20)
    -- self.Window.TitleBar.Icon:SetTexture("...") -- TODO: Create icon
    self.Window.TitleBar.Text = self.Window.TitleBar:CreateFontString(self.Window.TitleBar:GetName() .. "Text", "OVERLAY")
    self.Window.TitleBar.Text:SetPoint("LEFT", self.Window.TitleBar.Icon, "RIGHT")
    self.Window.TitleBar.Text:SetText("AlterEgo")
    self.Window.TitleBar.Dropdowns = CreateFrame("Frame", self.Window.TitleBar:GetName() .. "Dropdowns", self.Window.TitleBar)
    self.Window.TitleBar.CloseButton = CreateFrame("Button", self.Window.TitleBar:GetName() .. "CloseButton", self.Window.TitleBar)
    self.Window.TitleBar.CloseButton:SetPoint("RIGHT", self.Window.TitleBar, "RIGHT")
    self.Window.TitleBar.CloseButton:SetSize(20, 20)
    self.Window.TitleBar.CloseButton.Icon = self.Window.TitleBar:CreateTexture(self.Window.TitleBar.CloseButton:GetName() .. "Icon", "ARTWORK")
    self.Window.TitleBar.CloseButton.Icon:SetPoint("CENTER", self.Window.TitleBar.CloseButton, "CENTER")
    self.Window.TitleBar.CloseButton.Icon:SetSize(16, 16)
    -- self.Window.TitleBar.CloseButton.Icon:SetTexture("...") -- TODO: Create texture
    -- Body
    self.Window.Body = CreateFrame("Frame", self.Window:GetName() .. "Body", self.Window)
    self.Window.Body:SetPoint("TOPLEFT", self.Window.TitleBar, "BOTTOMLEFT")
    self.Window.Body:SetPoint("TOPRIGHT", self.Window.TitleBar, "BOTTOMRIGHT")
    self.Window.Body:SetPoint("BOTTOMLEFT", self.Window, "BOTTOMLEFT")
    self.Window.Body:SetPoint("BOTTOMRIGHT", self.Window, "BOTTOMRIGHT")
    -- Sidebar
    self.Window.Body.Sidebar = CreateFrame("Frame", self.Window.Body:GetName() .. "Sidebar", self.Window.Body)
    self.Window.Body.Sidebar:SetPoint("TOPLEFT", self.Window.Body, "TOPLEFT")
    self.Window.Body.Sidebar:SetPoint("BOTTOMLEFT", self.Window.Body, "BOTTOMLEFT")
    self.Window.Body.Sidebar:SetWidth(self.constants.table.colWidth)
    self.Window.Body.Sidebar.Background = self.Window.Body.Sidebar:CreateTexture(nil, "BACKGROUND")
    self.Window.Body.Sidebar.Background:SetTexture("Interface/Tooltips/UI-Tooltip-Background")
    self.Window.Body.Sidebar.Background:SetVertexColor(0, 0, 0, 0.1)

    -- Character labels
    for i, label in ipairs(labels) do
        local LabelFrame = CreateFrame("Frame", self.Window.Body.Sidebar:GetName() .. "Label" .. i, self.Window.Body.Sidebar)
        if i > 1 then
            LabelFrame:SetPoint("TOPLEFT", self.Window.Body.Sidebar:GetName() .. "Label" .. (i-1), "BOTTOMLEFT")
            LabelFrame:SetPoint("TOPRIGHT", self.Window.Body.Sidebar:GetName() .. "Label" .. (i-1), "BOTTOMRIGHT")
        else
            LabelFrame:SetPoint("TOPLEFT", self.Window.Body.Sidebar:GetName(), "TOPLEFT")
            LabelFrame:SetPoint("TOPRIGHT", self.Window.Body.Sidebar:GetName(), "TOPRIGHT")
        end

        LabelFrame.Text = LabelFrame:CreateFontString(LabelFrame:GetName() .. "Text", "OVERLAY")
        LabelFrame.Text:SetPoint("LEFT", LabelFrame, "LEFT")
        LabelFrame.Text:SetText(label)
    end

    -- Dungeon names
    for i, dungeon in ipairs(dungeons) do
        local DungeonLabel = CreateFrame("Frame", self.Window.Body.Sidebar:GetName() .. "Dungeon" .. i, self.Window.Body.Sidebar)

        if i > 1 then
            DungeonLabel:SetPoint("TOPLEFT", self.Window.Body.Sidebar:GetName() .. "Dungeon" .. (i-1), "BOTTOMLEFT")
            DungeonLabel:SetPoint("TOPRIGHT", self.Window.Body.Sidebar:GetName() .. "Dungeon" .. (i-1), "BOTTOMRIGHT")
        else
            DungeonLabel:SetPoint("TOPLEFT", self.Window.Body.Sidebar:GetName(), "TOPLEFT")
            DungeonLabel:SetPoint("TOPRIGHT", self.Window.Body.Sidebar:GetName(), "TOPRIGHT")
        end

        DungeonLabel.Text = DungeonLabel:CreateFontString(DungeonLabel:GetName() .. "Text", "OVERLAY")
        DungeonLabel.Icon = DungeonLabel:CreateTexture(DungeonLabel:GetName() .. "Icon", "ARTWORK")
        DungeonLabel.Icon:SetSize(16, 16)
        DungeonLabel.Icon:SetPoint("LEFT", DungeonLabel, "LEFT", 0, 0)
        -- DungeonFrame.Icon:SetTexture(dungeon.icon)
    end

    self.Window.Body.ScrollFrame = CreateFrame("ScrollFrame", self.Window.Body:GetName() .. "ScrollFrame", self.Window.Body)
    self.Window.Body.ScrollFrame.Characters = CreateFrame("Frame", self.Window.Body.ScrollFrame:GetName() .. "Characters", self.Window.Body.ScrollFrame)

    -- Characters
    for i, _ in ipairs(charactersUnfiltered) do
        local CharacterColumn = CreateFrame("Frame", self.Window.Body.ScrollFrame.Characters:GetName() .. i, self.Window.Body.ScrollFrame.Characters)

        if i > 1 then
            CharacterColumn:SetPoint("TOPLEFT", self.Window.Body.ScrollFrame.Characters:GetName() .. (i-1), "TOPRIGHT")
            CharacterColumn:SetPoint("BOTTOMLEFT", self.Window.Body.ScrollFrame.Characters:GetName() .. (i-1), "BOTTOMRIGHT")
        else
            CharacterColumn:SetPoint("TOPLEFT", self.Window.Body.ScrollFrame.Characters:GetName(), "TOPLEFT")
            CharacterColumn:SetPoint("BOTTOMLEFT", self.Window.Body.ScrollFrame.Characters:GetName(), "BOTTOMLEFT")
        end

        CharacterColumn:SetWidth(self.constants.table.colWidth)

        -- Character info
        CharacterColumn.Name = CreateFrame("Frame", CharacterColumn:GetName() .. "Name", CharacterColumn)
        CharacterColumn.Name.Text = CharacterColumn.Name:CreateFontString(CharacterColumn.Name:GetName() .. "Text", "OVERLAY")
        CharacterColumn.Realm = CreateFrame("Frame", CharacterColumn:GetName() .. "Realm", CharacterColumn)
        CharacterColumn.Realm.Text = CharacterColumn.Realm:CreateFontString(CharacterColumn.Realm:GetName() .. "Text", "OVERLAY")
        CharacterColumn.Rating = CreateFrame("Frame", CharacterColumn:GetName() .. "Rating", CharacterColumn)
        CharacterColumn.Rating.Text = CharacterColumn.Rating:CreateFontString(CharacterColumn.Rating:GetName() .. "Text", "OVERLAY")
        CharacterColumn.ItemLevel = CreateFrame("Frame", CharacterColumn:GetName() .. "ItemLevel", CharacterColumn)
        CharacterColumn.ItemLevel.Text = CharacterColumn.ItemLevel:CreateFontString(CharacterColumn.ItemLevel:GetName() .. "Text", "OVERLAY")
        CharacterColumn.Vault = CreateFrame("Frame", CharacterColumn:GetName() .. "Vault", CharacterColumn)
        CharacterColumn.Vault.Text = CharacterColumn.Vault:CreateFontString(CharacterColumn.Vault:GetName() .. "Text", "OVERLAY")
        CharacterColumn.CurrentKey = CreateFrame("Frame", CharacterColumn:GetName() .. "CurrentKey", CharacterColumn)
        CharacterColumn.CurrentKey.Text = CharacterColumn.CurrentKey:CreateFontString(CharacterColumn.CurrentKey:GetName() .. "Text", "OVERLAY")

        -- Affix icons
        CharacterColumn.Affixes = CreateFrame("Frame", CharacterColumn:GetName() .. "Affixes", CharacterColumn)
        for j, affix in ipairs(affixes) do
            local AffixFrame = CreateFrame("Frame", CharacterColumn:GetName() .. "Affixes" .. j, CharacterColumn.Affixes)
            AffixFrame:SetBackdrop(self.constants.backdrop)
            AffixFrame:SetBackdropColor(0, 0, 0, 0.1)

            local relativeTo = CharacterColumn.Affixes
            if j == 1 then
                AffixFrame:SetPoint("TOPLEFT", relativeTo, "TOPLEFT")
                AffixFrame:SetPoint("BOTTOMRIGHT", relativeTo, "BOTTOM")
            else
                AffixFrame:SetPoint("TOPRIGHT", relativeTo, "TOPRIGHT")
                AffixFrame:SetPoint("BOTTOMLEFT", relativeTo, "BOTTOM")
            end

            AffixFrame.Icon = AffixFrame:CreateTexture(AffixFrame:GetName() .. "Icon", "ARTWORK")
            AffixFrame.Icon:SetTexture(affix.icon)
            AffixFrame.Icon:SetSize(16, 16)
            AffixFrame.Icon:SetPoint("CENTER", AffixFrame, "CENTER", 0, 0)

            -- Dungeon rows
            for k, dungeon in ipairs(dungeons) do
                local DungeonFrame = CreateFrame("Frame", AffixFrame:GetName() .. "Dungeons" .. k, AffixFrame)
                local relativeTo = AffixFrame:GetName()
                if k > 1 then
                    relativeTo = AffixFrame:GetName() .. "Dungeons" .. (k-1)
                end

                DungeonFrame:SetPoint("TOPLEFT", relativeTo, "BOTTOMLEFT")
                DungeonFrame:SetPoint("TOPRIGHT", relativeTo, "BOTTOMRIGHT")
                DungeonFrame.Text = DungeonFrame:CreateFontString(DungeonFrame:GetName() .. "Text", "OVERLAY")
                DungeonFrame.Text:SetPoint("TOPLEFT", DungeonFrame, "TOPLEFT")
                DungeonFrame.Text:SetPoint("BOTTOMRIGHT", DungeonFrame, "BOTTOM")
                DungeonFrame.Tier = DungeonFrame:CreateFontString(DungeonFrame:GetName() .. "Tier", "OVERLAY")
                DungeonFrame.Tier:SetPoint("TOPRIGHT", DungeonFrame, "TOPRIGHT")
                DungeonFrame.Tier:SetPoint("BOTTOMLEFT", DungeonFrame, "BOTTOM")
            end
        end
    end
end

function AlterEgo:UpdateNewUI()
    local characters = self:GetCharacters()
    local charactersUnfiltered = self.db.global.characters
    -- TODO: Create a method for this
    local dungeons = self.constants.dungeons

    -- Dungeon names
    for i, dungeon in ipairs(dungeons) do
        local DungeonLabel = _G[self.Window.Body.Sidebar:GetName() .. "Dungeon" .. i]
        DungeonLabel.Icon:SetTexture(dungeon.icon)
        DungeonLabel.Text:SetText(dungeon.name)
    end

    -- Characters
    local totalColumns = #charactersUnfiltered
    for i, character in ipairs(characters) do

        local name = character.name
        local nameColor = "ffffffff"
        local realm = character.realm
        local realmColor = "ffffffff"
        local rating = character.rating
        local ratingColor = "ffffffff"
        local itemLevel = character.itemLevel
        local itemLevelColor = "ffffffff"
        local vault = ""
        local currentKey = "-"

        if character.class ~= nil then
            local classColor = C_ClassColor.GetClassColor(character.class)
            if classColor ~= nil then
                nameColor = classColor.GenerateHexColor(classColor)
            end
        end

        if rating and rating > 0 then
            local color = C_ChallengeMode.GetDungeonScoreRarityColor(rating)
            if color ~= nil then
                ratingColor = color.GenerateHexColor(color)
            end
        else
            rating = "-"
        end

        if itemLevel == nil then
            itemLevel = "-"
        else
            itemLevel = floor(itemLevel)
        end

        if character.itemLevelColor then
            itemLevelColor = character.itemLevelColor
        end

        for _, key in ipairs(character.vault) do
            if key == 0 then
                vault = "-"
            end
            vault = vault .. vault .. "  "
        end

        if character.key and character.key.map and character.key.level then
            local dungeon = self:GetDungeonByMapId(character.key.map)
            if dungeon then
                currentKey = dungeon.abbr .. " +" .. character.key.level
            end
        end

        local CharacterColumn = _G[self.Window.Body.ScrollFrame.Characters:GetName() .. i]
        CharacterColumn.Name.Text:SetText("|c" .. nameColor .. name .. "|r")
        CharacterColumn.Realm.Text:SetText("|c" .. realmColor .. realm .. "|r")
        CharacterColumn.Rating.Text:SetText("|c" .. ratingColor .. rating .. "|r")
        CharacterColumn.ItemLevel.Text:SetText("|c" .. itemLevelColor .. itemLevel .. "|r")
        CharacterColumn.Vault.Text:SetText(vault:trim())
        CharacterColumn.CurrentKey.Text:SetText(currentKey)

        -- TODO: Create a method for affixes
        for j, affix in ipairs(affixes) do
            for k, dungeon in ipairs(dungeons) do
                local DungeonFrame = _G[CharacterColumn:GetName() .. "Affixes" .. j .. "Dungeons" .. k]
                local bestRun = character.dungeons[dungeon.id][affix.name]
                local level = "-"
                local levelColor = "ffffffff"
                local tier = ""

                if bestRun == nil or bestRun.level == nil or bestRun.score == nil or bestRun.durationSec == nil then
                    level = "-"
                    levelColor = LIGHTGRAY_FONT_COLOR:GenerateHexColor()
                else
                    level = bestRun.level

                    if bestRun.durationSec <= dungeon.time * 0.6 then
                        tier = "|A:Professions-ChatIcon-Quality-Tier3:16:16:0:-1|a"
                    elseif bestRun.durationSec <= dungeon.time * 0.8 then
                        tier =  "|A:Professions-ChatIcon-Quality-Tier2:16:16:0:-1|a"
                    elseif bestRun.durationSec <= dungeon.time then
                        tier =  "|A:Professions-ChatIcon-Quality-Tier1:14:14:0:-1|a"
                    else
                        levelColor = LIGHTGRAY_FONT_COLOR:GenerateHexColor()
                    end
                end

                -- TODO: Align based on tier visibility
                DungeonFrame.Text:SetText("|c" .. levelColor .. level .. "|r")
                DungeonFrame.Tier:SetText(tier)
                -- DungeonFrame.Text:SetPoint("TOPLEFT", DungeonFrame, "TOPLEFT")
                -- DungeonFrame.Text:SetPoint("BOTTOMRIGHT", DungeonFrame, "BOTTOM")
                -- DungeonFrame.Tier:SetPoint("TOPRIGHT", DungeonFrame, "TOPRIGHT")
                -- DungeonFrame.Tier:SetPoint("BOTTOMLEFT", DungeonFrame, "BOTTOM")
            end
        end
    end

    -- TODO: Hide extra columns not needed anymore (hint: filtered vs unfiltered count)
end