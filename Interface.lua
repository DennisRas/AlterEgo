---@diagnostic disable: inject-field
local labels = {"Character", "Realm", "Rating", STAT_AVERAGE_ITEM_LEVEL, "Vault", "Current Key"}
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

local function SetBackgroundColor(parent, r, g, b, a)
    if not parent.Background then
        parent.Background = parent:CreateTexture(parent:GetName() .. "Background", "BACKGROUND")
        parent.Background:SetTexture("Interface/BUTTONS/WHITE8X8")
        parent.Background:SetAllPoints()
    end

    parent.Background:SetVertexColor(r, g, b, a)
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
    local width = sizes.sidebar.width + self:tablen(characters) * sizes.column
    local height = sizes.titlebar.height + (self:tablen(labels) + 1 + self:tablen(dungeons)) * sizes.row
    return width, height
end

function AlterEgo:CreateUI()
    if self.Window then return end

    local affixes = self:GetAffixes()
    local characters = self:GetCharacters()
    local charactersUnfiltered = self:GetCharacters(true)
    -- TODO: Create a method for this
    local dungeons = self:GetDungeons()

    self.Window = CreateFrame("Frame", "AlterEgoWindow", UIParent)
    self.Window:SetFrameStrata("HIGH")
    self.Window:SetClampedToScreen(true)
    self.Window:SetMovable(true)
    self.Window:SetPoint("CENTER")
    SetBackgroundColor(self.Window, colors.dark:GetRGBA())
    -- Border
    -- TODO: Make this work with insets
    self.Window.Border = CreateFrame("Frame", self.Window:GetName() .. "Border", self.Window, "BackdropTemplate")
    self.Window.Border:SetPoint("TOPLEFT", self.Window, "TOPLEFT", -10, -10)
    self.Window.Border:SetPoint("BOTTOMRIGHT", self.Window, "BOTTOMRIGHT", 10, 10)
    self.Window.Border:Hide()
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
    self.Window.TitleBar.Icon:SetTexture("Interface/AddOns/AlterEgo/LogoTransparent.blp")
    self.Window.TitleBar.Text = self.Window.TitleBar:CreateFontString(self.Window.TitleBar:GetName() .. "Text", "OVERLAY")
    self.Window.TitleBar.Text:SetPoint("LEFT", self.Window.TitleBar, "LEFT", 20 + sizes.padding, -1)
    self.Window.TitleBar.Text:SetFont(assets.font.file, assets.font.size + 2, assets.font.flags)
    self.Window.TitleBar.Text:SetText("AlterEgo")
    -- self.Window.TitleBar.Text:SetVertexColor(1, 0, 1, 1)
    self.Window.TitleBar.Dropdowns = CreateFrame("Frame", self.Window.TitleBar:GetName() .. "Dropdowns", self.Window.TitleBar)
    self.Window.TitleBar.CloseButton = CreateFrame("Button", self.Window.TitleBar:GetName() .. "CloseButton", self.Window.TitleBar)
    self.Window.TitleBar.CloseButton:SetPoint("RIGHT", self.Window.TitleBar, "RIGHT", 0, 0)
    self.Window.TitleBar.CloseButton:SetSize(sizes.titlebar.height, sizes.titlebar.height)
    self.Window.TitleBar.CloseButton:RegisterForClicks("AnyUp")
    SetBackgroundColor(self.Window.TitleBar.CloseButton, 1, 1, 1, 0)
    self.Window.TitleBar.CloseButton:SetScript("OnEnter", function()
        self.Window.TitleBar.CloseButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
        SetBackgroundColor(self.Window.TitleBar.CloseButton, 1, 1, 1, 0.05)
        GameTooltip:ClearAllPoints()
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(self.Window.TitleBar.CloseButton, "ANCHOR_TOP")
        GameTooltip:SetText("Close the window", 1, 1, 1, 1, true);
        GameTooltip:Show()
    end)
    self.Window.TitleBar.CloseButton:SetScript("OnLeave", function()
        self.Window.TitleBar.CloseButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
        SetBackgroundColor(self.Window.TitleBar.CloseButton, 1, 1, 1, 0)
        GameTooltip:Hide()
    end)
    self.Window.TitleBar.CloseButton:SetScript("OnClick", function() self:ToggleWindow() end)
    self.Window.TitleBar.CloseButton.Icon = self.Window.TitleBar:CreateTexture(self.Window.TitleBar.CloseButton:GetName() .. "Icon", "ARTWORK")
    self.Window.TitleBar.CloseButton.Icon:SetPoint("CENTER", self.Window.TitleBar.CloseButton, "CENTER")
    self.Window.TitleBar.CloseButton.Icon:SetSize(10, 10)
    self.Window.TitleBar.CloseButton.Icon:SetTexture("Interface/AddOns/AlterEgo/Close.blp") -- TODO: Create texture
    self.Window.TitleBar.CloseButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
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

    -- Character labels
    do
        for l, label in ipairs(labels) do
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
            CharacterLabel.Text:SetText(label)
            CharacterLabel.Text:SetVertexColor(1.0, 0.82, 0.0, 1)
        end
    end

    local DungeonHeaderLabel = CreateFrame("Frame", self.Window.Body.Sidebar:GetName() .. "Label", self.Window.Body.Sidebar)
    DungeonHeaderLabel:SetPoint("TOPLEFT", self.Window.Body.Sidebar:GetName() .. "Label" .. self:tablen(labels), "BOTTOMLEFT")
    DungeonHeaderLabel:SetPoint("TOPRIGHT", self.Window.Body.Sidebar:GetName() .. "Label" .. self:tablen(labels), "BOTTOMRIGHT")
    DungeonHeaderLabel:SetHeight(sizes.row)
    DungeonHeaderLabel.Text = DungeonHeaderLabel:CreateFontString(DungeonHeaderLabel:GetName() .. "Text", "OVERLAY")
    DungeonHeaderLabel.Text:SetPoint("TOPLEFT", DungeonHeaderLabel, "TOPLEFT", sizes.padding, 0)
    DungeonHeaderLabel.Text:SetPoint("BOTTOMRIGHT", DungeonHeaderLabel, "BOTTOMRIGHT", -sizes.padding, 0)
    DungeonHeaderLabel.Text:SetFont(assets.font.file, assets.font.size, assets.font.flags)
    DungeonHeaderLabel.Text:SetJustifyH("LEFT")
    DungeonHeaderLabel.Text:SetText("Dungeons")
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
        DungeonLabel.Text:SetFont(assets.font.file, assets.font.size - 2, assets.font.flags)
        DungeonLabel.Text:SetText(dungeon.name)
        DungeonLabel.Icon = DungeonLabel:CreateTexture(DungeonLabel:GetName() .. "Icon", "ARTWORK")
        DungeonLabel.Icon:SetSize(16, 16)
        DungeonLabel.Icon:SetPoint("LEFT", DungeonLabel, "LEFT", sizes.padding, 0)
        DungeonLabel.Icon:SetTexture(dungeon.icon)
    end

    self.Window.Body.ScrollFrame = CreateFrame("Frame", self.Window.Body:GetName() .. "ScrollFrame", self.Window.Body)
    self.Window.Body.ScrollFrame:SetPoint("TOPLEFT", self.Window.Body, "TOPLEFT", sizes.sidebar.width, 0)
    self.Window.Body.ScrollFrame:SetPoint("BOTTOMLEFT", self.Window.Body, "BOTTOMLEFT", sizes.sidebar.width, 0)
    self.Window.Body.ScrollFrame:SetPoint("BOTTOMRIGHT", self.Window.Body, "BOTTOMRIGHT")
    self.Window.Body.ScrollFrame:SetPoint("TOPRIGHT", self.Window.Body, "TOPRIGHT")
    self.Window.Body.ScrollFrame.Characters = CreateFrame("Frame", self.Window.Body.ScrollFrame:GetName() .. "Characters", self.Window.Body.ScrollFrame)
    self.Window.Body.ScrollFrame.Characters:SetAllPoints()

    -- Characters
    for c in ipairs(characters) do
        local CharacterColumn = CreateFrame("Frame", self.Window.Body.ScrollFrame.Characters:GetName() .. c, self.Window.Body.ScrollFrame.Characters)

        if c > 1 then
            CharacterColumn:SetPoint("TOPLEFT", self.Window.Body.ScrollFrame.Characters:GetName() .. (c-1), "TOPRIGHT")
            CharacterColumn:SetPoint("BOTTOMLEFT", self.Window.Body.ScrollFrame.Characters:GetName() .. (c-1), "BOTTOMRIGHT")
        else
            CharacterColumn:SetPoint("TOPLEFT", self.Window.Body.ScrollFrame.Characters:GetName(), "TOPLEFT")
            CharacterColumn:SetPoint("BOTTOMLEFT", self.Window.Body.ScrollFrame.Characters:GetName(), "BOTTOMLEFT")
        end

        CharacterColumn:SetWidth(sizes.column)
        SetBackgroundColor(CharacterColumn, 1, 1, 1, c % 2 == 0 and 0.01 or 0)

        -- Character info
        CharacterColumn.Name = CreateFrame("Frame", CharacterColumn:GetName() .. "Name", CharacterColumn)
        CharacterColumn.Name:SetPoint("TOPLEFT", CharacterColumn:GetName(), "TOPLEFT")
        CharacterColumn.Name:SetPoint("TOPRIGHT", CharacterColumn:GetName(), "TOPRIGHT")
        CharacterColumn.Name:SetHeight(sizes.row)
        CharacterColumn.Name.Text = CharacterColumn.Name:CreateFontString(CharacterColumn.Name:GetName() .. "Text", "OVERLAY")
        CharacterColumn.Name.Text:SetFont(assets.font.file, assets.font.size, assets.font.flags)
        CharacterColumn.Name.Text:SetAllPoints()
        CharacterColumn.Realm = CreateFrame("Frame", CharacterColumn:GetName() .. "Realm", CharacterColumn)
        CharacterColumn.Realm:SetPoint("TOPLEFT", CharacterColumn.Name:GetName(), "BOTTOMLEFT")
        CharacterColumn.Realm:SetPoint("TOPRIGHT", CharacterColumn.Name:GetName(), "BOTTOMRIGHT")
        CharacterColumn.Realm:SetHeight(sizes.row)
        CharacterColumn.Realm.Text = CharacterColumn.Realm:CreateFontString(CharacterColumn.Realm:GetName() .. "Text", "OVERLAY")
        CharacterColumn.Realm.Text:SetFont(assets.font.file, assets.font.size, assets.font.flags)
        CharacterColumn.Realm.Text:SetAllPoints()
        CharacterColumn.Rating = CreateFrame("Button", CharacterColumn:GetName() .. "Rating", CharacterColumn)
        CharacterColumn.Rating:SetPoint("TOPLEFT", CharacterColumn.Realm:GetName(), "BOTTOMLEFT")
        CharacterColumn.Rating:SetPoint("TOPRIGHT", CharacterColumn.Realm:GetName(), "BOTTOMRIGHT")
        CharacterColumn.Rating:SetHeight(sizes.row)
        CharacterColumn.Rating:RegisterForClicks("AnyUp")
        CharacterColumn.Rating.Text = CharacterColumn.Rating:CreateFontString(CharacterColumn.Rating:GetName() .. "Text", "OVERLAY")
        CharacterColumn.Rating.Text:SetFont(assets.font.file, assets.font.size, assets.font.flags)
        CharacterColumn.Rating.Text:SetAllPoints()
        CharacterColumn.ItemLevel = CreateFrame("Frame", CharacterColumn:GetName() .. "ItemLevel", CharacterColumn)
        CharacterColumn.ItemLevel:SetPoint("TOPLEFT", CharacterColumn.Rating:GetName(), "BOTTOMLEFT")
        CharacterColumn.ItemLevel:SetPoint("TOPRIGHT", CharacterColumn.Rating:GetName(), "BOTTOMRIGHT")
        CharacterColumn.ItemLevel:SetHeight(sizes.row)
        CharacterColumn.ItemLevel.Text = CharacterColumn.ItemLevel:CreateFontString(CharacterColumn.ItemLevel:GetName() .. "Text", "OVERLAY")
        CharacterColumn.ItemLevel.Text:SetFont(assets.font.file, assets.font.size, assets.font.flags)
        CharacterColumn.ItemLevel.Text:SetAllPoints()
        CharacterColumn.Vault = CreateFrame("Frame", CharacterColumn:GetName() .. "Vault", CharacterColumn)
        CharacterColumn.Vault:SetPoint("TOPLEFT", CharacterColumn.ItemLevel:GetName(), "BOTTOMLEFT")
        CharacterColumn.Vault:SetPoint("TOPRIGHT", CharacterColumn.ItemLevel:GetName(), "BOTTOMRIGHT")
        CharacterColumn.Vault:SetHeight(sizes.row)
        CharacterColumn.Vault.Text = CharacterColumn.Vault:CreateFontString(CharacterColumn.Vault:GetName() .. "Text", "OVERLAY")
        CharacterColumn.Vault.Text:SetFont(assets.font.file, assets.font.size, assets.font.flags)
        CharacterColumn.Vault.Text:SetAllPoints()
        CharacterColumn.CurrentKey = CreateFrame("Frame", CharacterColumn:GetName() .. "CurrentKey", CharacterColumn)
        CharacterColumn.CurrentKey:SetPoint("TOPLEFT", CharacterColumn.Vault:GetName(), "BOTTOMLEFT")
        CharacterColumn.CurrentKey:SetPoint("TOPRIGHT", CharacterColumn.Vault:GetName(), "BOTTOMRIGHT")
        CharacterColumn.CurrentKey:SetHeight(sizes.row)
        CharacterColumn.CurrentKey.Text = CharacterColumn.CurrentKey:CreateFontString(CharacterColumn.CurrentKey:GetName() .. "Text", "OVERLAY")
        CharacterColumn.CurrentKey.Text:SetFont(assets.font.file, assets.font.size, assets.font.flags)
        CharacterColumn.CurrentKey.Text:SetAllPoints()
        CharacterColumn.AffixHeader = CreateFrame("Frame", CharacterColumn:GetName() .. "Affixes", CharacterColumn)
        CharacterColumn.AffixHeader:SetPoint("TOPLEFT", CharacterColumn.CurrentKey:GetName(), "BOTTOMLEFT")
        CharacterColumn.AffixHeader:SetPoint("TOPRIGHT", CharacterColumn.CurrentKey:GetName(), "BOTTOMRIGHT")
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
    end

    self:UpdateUI()
end

function AlterEgo:UpdateUI()
    if not self.Window then return end

    self.Window:SetSize(self:GetWindowSize())

    local affixes = self:GetAffixes()
    local characters = self:GetCharacters()
    local charactersUnfiltered = self:GetCharacters(true)
    local dungeons = self:GetDungeons()

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

    -- Characters
    -- local totalColumns = self:tablen(charactersUnfiltered)
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
        local currentKey = "-"
        local bestSeasonScore = nil
        local bestSeasonScoreColor = "ffffffff"
        local bestSeasonNumber = nil

        if character.name ~= nil then
            name = character.name
        end

        if character.realm ~= nil then
            realm = character.realm
        end

        if character.class.file ~= nil then
            local classColor = C_ClassColor.GetClassColor(character.class.file)
            if classColor ~= nil then
                nameColor = classColor.GenerateHexColor(classColor)
            end
        end

        if character.ratingSummary ~= nil and character.ratingSummary.currentSeasonScore ~= nil then
            local color = C_ChallengeMode.GetDungeonScoreRarityColor(character.ratingSummary.currentSeasonScore)
            if color ~= nil then
                ratingColor = color.GenerateHexColor(color)
            end
            rating = tostring(character.ratingSummary.currentSeasonScore)
        end

        if character.ilvl ~= nil then
            if character.ilvl.level ~= nil then
                itemLevel = tostring(floor(character.ilvl.level))
                itemLevelTooltip = itemLevelTooltip .. HIGHLIGHT_FONT_COLOR_CODE .. format(PAPERDOLLFRAME_TOOLTIP_FORMAT, STAT_AVERAGE_ITEM_LEVEL) .. " " .. floor(character.ilvl.level)
            end
            if character.ilvl.level ~= nil and character.ilvl.equipped ~= nil and character.ilvl.level ~= character.ilvl.equipped then
                itemLevelTooltip = itemLevelTooltip .. "  " .. format(STAT_AVERAGE_ITEM_LEVEL_EQUIPPED, character.ilvl.equipped);
            end
            if character.ilvl.level ~= nil then
                itemLevelTooltip = itemLevelTooltip .. FONT_COLOR_CODE_CLOSE
            end
            if character.ilvl.level ~= nil and character.ilvl.pvp ~= nil and floor(character.ilvl.level) ~= character.ilvl.pvp then
                itemLevelTooltip2 = itemLevelTooltip2.."\n\n"..STAT_AVERAGE_PVP_ITEM_LEVEL:format(tostring(floor(character.ilvl.pvp)));
            end
        end

        if character.itemLevelColor then
            itemLevelColor = character.itemLevelColor
        end

        for _, vault in ipairs(character.vault) do
            local level = "-"
            if vault.level > 0 then
                level = tostring(vault.level)
            end
            vaultLevels = vaultLevels .. level .. "  "
        end

        if character.key ~= nil and character.key.map ~= nil and character.key.level ~= nil then
            local dungeon = self:GetDungeonByMapId(character.key.map)
            if dungeon then
                currentKey = dungeon.abbr .. " +" .. tostring(character.key.level)
            end
        end

        if character.bestSeasonScore ~= nil then
            bestSeasonScore = character.bestSeasonScore
            local color = C_ChallengeMode.GetDungeonScoreRarityColor(bestSeasonScore)
            if color ~= nil then
                bestSeasonScoreColor = color.GenerateHexColor(color)
            end
        end

        if character.bestSeasonNumber ~= nil then
            bestSeasonNumber = character.bestSeasonNumber
        end

        local CharacterColumn = _G[self.Window.Body.ScrollFrame.Characters:GetName() .. c]
        CharacterColumn.Name.Text:SetText("|c" .. nameColor .. name .. "|r")
        CharacterColumn.Name:SetScript("OnEnter", function()
            GameTooltip:ClearAllPoints()
            GameTooltip:ClearLines()
            GameTooltip:SetOwner(CharacterColumn.Name, "ANCHOR_RIGHT")
            GameTooltip:AddLine("|c" .. nameColor .. name .. "|r");
            GameTooltip:AddLine(format("Level %d %s", character.level, character.race ~= nil and character.race.name or ""), 1, 1, 1);
            if character.factionGroup ~= nil and character.factionGroup.localized~= nil then
                GameTooltip:AddLine(character.factionGroup.localized, 1, 1, 1);
            end
            if character.lastUpdate ~= nil then
                GameTooltip:AddLine(" ");
                GameTooltip:AddLine(format("Last update:\n|cffffffff%s|r", date("%c", character.lastUpdate)), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
            end
            GameTooltip:Show()
        end)
        CharacterColumn.Name:SetScript("OnLeave", function() GameTooltip:Hide() end)
        CharacterColumn.Realm.Text:SetText("|c" .. realmColor .. realm .. "|r")
        CharacterColumn.Rating.Text:SetText("|c" .. ratingColor .. rating .. "|r")
        CharacterColumn.Rating:SetScript("OnEnter", function()
            GameTooltip:ClearAllPoints()
            GameTooltip:ClearLines()
            GameTooltip:SetOwner(CharacterColumn.ItemLevel, "ANCHOR_RIGHT")
            GameTooltip:AddLine("Mythic+ Rating", 1, 1, 1);
            GameTooltip:AddLine("Current Season: " .. "|c" .. ratingColor .. rating .. "|r", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
            GameTooltip:AddLine("Runs this Season: " .. "|cffffffff" .. (#character.history or 0) .. "|r", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
            if bestSeasonScore ~= nil then
                local score = "|c" .. bestSeasonScoreColor .. bestSeasonScore .. "|r"
                if bestSeasonNumber ~= nil then
                    score = score .. LIGHTGRAY_FONT_COLOR:WrapTextInColorCode(" (Season " .. bestSeasonNumber .. ")")
                end
                GameTooltip:AddLine("Best Season: " .. score, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
            end

            if character.ratingSummary ~= nil and character.ratingSummary.runs ~= nil then
                GameTooltip:AddLine(" ")
                for r,run in ipairs(character.ratingSummary.runs) do
                    local dungeonName = C_ChallengeMode.GetMapUIInfo(run.challengeModeID)
                    if dungeonName ~= nil then
                        GameTooltip:AddDoubleLine(dungeonName, "+" .. tostring(run.bestRunLevel), NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, 1, 1, 1)
                    end
                end
            end

            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("<Shift Click to Link to Chat>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
            GameTooltip:Show()
        end)
        CharacterColumn.Rating:SetScript("OnLeave", function() GameTooltip:Hide() end)
        CharacterColumn.Rating:SetScript("OnClick", function()
            if IsModifiedClick("CHATLINK") then
                local dungeonScoreDungeonTable = { };
                if character.ratingSummary ~= nil and character.ratingSummary.runs ~= nil then
                    for _, run in ipairs(character.ratingSummary.runs) do
                        table.insert(dungeonScoreDungeonTable, run.challengeModeID);
                        table.insert(dungeonScoreDungeonTable, run.finishedSuccess and 1 or 0);
                        table.insert(dungeonScoreDungeonTable, run.bestRunLevel);
                    end
                end
                local dungeonScoreTable = {
                    character.ratingSummary.currentSeasonScore,
                    character.GUID,
                    character.name,
                    character.class.id,
                    math.ceil(character.ilvl.level),
                    character.level,
                    character.history and #character.history or 0,
                    character.bestSeasonScore,
                    character.bestSeasonNumber,
                    unpack(dungeonScoreDungeonTable)
                };
                local link = NORMAL_FONT_COLOR:WrapTextInColorCode(LinkUtil.FormatLink("dungeonScore", DUNGEON_SCORE_LINK, unpack(dungeonScoreTable)));
                if not ChatEdit_InsertLink(link) then
                    ChatFrame_OpenChat(link);
                end
            end
        end)

        CharacterColumn.ItemLevel.Text:SetText("|c" .. itemLevelColor .. itemLevel .. "|r")
        if itemLevelTooltip then
            CharacterColumn.ItemLevel:SetScript("OnEnter", function()
                GameTooltip:ClearAllPoints()
                GameTooltip:ClearLines()
                GameTooltip:SetOwner(CharacterColumn.ItemLevel, "ANCHOR_RIGHT")
                GameTooltip:AddLine(itemLevelTooltip, 1, 1, 1);
                GameTooltip:AddLine(itemLevelTooltip2,  NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true);
                GameTooltip:Show()
            end)
            CharacterColumn.ItemLevel:SetScript("OnLeave", function() GameTooltip:Hide() end)
        end

        CharacterColumn.Vault.Text:SetText(vaultLevels:trim())
        CharacterColumn.CurrentKey.Text:SetText(currentKey)

        for d, dungeon in ipairs(dungeons) do
            local DungeonFrame =  _G[CharacterColumn:GetName() .. "Dungeons" .. d]
            DungeonFrame:SetScript("OnEnter", function()
                GameTooltip:ClearAllPoints()
                GameTooltip:ClearLines()
                GameTooltip:SetOwner(DungeonFrame, "ANCHOR_RIGHT")
                GameTooltip:SetText(dungeon.name, 1, 1, 1);

                if(character.bestDungeons[dungeon.id].bestOverAllScore and (character.bestDungeons[dungeon.id].bestTimed or character.bestDungeons[dungeon.id].bestNotTimed)) then
                    local color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(character.bestDungeons[dungeon.id].bestOverAllScore);
                    if not color then
                        color = HIGHLIGHT_FONT_COLOR;
                    end
                    GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_TOTAL_SCORE:format(color:WrapTextInColorCode(character.bestDungeons[dungeon.id].bestOverAllScore)), GREEN_FONT_COLOR);
                end

                local affixScores = character.bestDungeons[dungeon.id].affixScores
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

                if character.bestDungeons == nil or character.bestDungeons[dungeon.id] == nil or character.bestDungeons[dungeon.id].affixScores == nil then
                    level = "-"
                    levelColor = LIGHTGRAY_FONT_COLOR:GenerateHexColor()
                else
                    for _, affixScore in ipairs(character.bestDungeons[dungeon.id].affixScores) do
                        if affixScore.name == affix.name then
                            level = affixScore.level

                            if affixScore.durationSec <= dungeon.time * 0.6 then
                                tier = "|A:Professions-ChatIcon-Quality-Tier3:16:16:0:-1|a"
                            elseif affixScore.durationSec <= dungeon.time * 0.8 then
                                tier =  "|A:Professions-ChatIcon-Quality-Tier2:16:16:0:-1|a"
                            elseif affixScore.durationSec <= dungeon.time then
                                tier =  "|A:Professions-ChatIcon-Quality-Tier1:14:14:0:-1|a"
                            else
                                levelColor = LIGHTGRAY_FONT_COLOR:GenerateHexColor()
                            end
                        end
                    end

                end

                -- TODO: Align based on tier visibility
                AffixFrame.Text:SetText("|c" .. levelColor .. level .. "|r")
                AffixFrame.Tier:SetText(tier)
                -- DungeonFrame.Text:SetPoint("TOPLEFT", DungeonFrame, "TOPLEFT")
                -- DungeonFrame.Text:SetPoint("BOTTOMRIGHT", DungeonFrame, "BOTTOM")
                -- DungeonFrame.Tier:SetPoint("TOPRIGHT", DungeonFrame, "TOPRIGHT")
                -- DungeonFrame.Tier:SetPoint("BOTTOMLEFT", DungeonFrame, "BOTTOM")
            end
        end
    end

    -- TODO: Hide extra columns not needed anymore (hint: filtered vs unfiltered count)
end