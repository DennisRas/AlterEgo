local addonName, AlterEgo = ...
local Constants = AlterEgo.Constants
local Utils = AlterEgo.Utils
local Window = AlterEgo.Window
local Core = AlterEgo.Core
local Data = AlterEgo.Data
local Main = Core:NewModule("Main", "AceEvent-3.0")

local SIDEBAR_WIDTH = 150
local CHARACTER_WIDTH = 120

function Main:CreateCharacterColumn(parent, index)
  local affixes = Data:GetAffixes(true)
  local dungeons = Data:GetDungeons()
  local raids = Data:GetRaids(true)
  local difficulties = Data:GetRaidDifficulties(true)
  local anchorFrame

  local CharacterColumn = CreateFrame("Frame", "$parentCharacterColumn" .. index, parent)
  CharacterColumn:SetWidth(CHARACTER_WIDTH)
  self:SetBackgroundColor(CharacterColumn, 1, 1, 1, index % 2 == 0 and 0.01 or 0)
  anchorFrame = CharacterColumn

  -- Character info
  do
    local labels = Data:GetCharacterInfo()
    for labelIndex, info in ipairs(labels) do
      local CharacterFrame = CreateFrame(info.OnClick and "Button" or "Frame", "$parentInfo" .. labelIndex, CharacterColumn)
      if labelIndex > 1 then
        CharacterFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
        CharacterFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
      else
        CharacterFrame:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT")
        CharacterFrame:SetPoint("TOPRIGHT", anchorFrame, "TOPRIGHT")
      end

      CharacterFrame:SetHeight(Constants.sizes.row)
      CharacterFrame.Text = CharacterFrame:CreateFontString(CharacterFrame:GetName() .. "Text", "OVERLAY")
      CharacterFrame.Text:SetPoint("LEFT", CharacterFrame, "LEFT", Constants.sizes.padding, 0)
      CharacterFrame.Text:SetPoint("RIGHT", CharacterFrame, "RIGHT", -Constants.sizes.padding, 0)
      CharacterFrame.Text:SetJustifyH("CENTER")
      CharacterFrame.Text:SetFontObject("GameFontHighlight_NoShadow")
      if info.backgroundColor then
        self:SetBackgroundColor(CharacterFrame, info.backgroundColor.r, info.backgroundColor.g, info.backgroundColor.b, info.backgroundColor.a)
      end

      anchorFrame = CharacterFrame
    end
  end

  -- Affix header
  CharacterColumn.AffixHeader = CreateFrame("Frame", "$parentAffixes", CharacterColumn)
  CharacterColumn.AffixHeader:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
  CharacterColumn.AffixHeader:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
  CharacterColumn.AffixHeader:SetHeight(Constants.sizes.row)
  self:SetBackgroundColor(CharacterColumn.AffixHeader, 0, 0, 0, 0.3)
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
    AffixFrame.Icon:SetTexture(affix.fileDataID)
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
    AffixFrame:SetScript("OnLeave", function()
      GameTooltip:Hide()
    end)
  end

  -- Dungeon rows
  for dungeonIndex in ipairs(dungeons) do
    local DungeonFrame = CreateFrame("Frame", "$parentDungeons" .. dungeonIndex, CharacterColumn)
    DungeonFrame:SetHeight(Constants.sizes.row)
    DungeonFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
    DungeonFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
    self:SetBackgroundColor(DungeonFrame, 1, 1, 1, dungeonIndex % 2 == 0 and 0.01 or 0)
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
      AffixFrame.Text:SetFontObject("GameFontHighlight_NoShadow")
      AffixFrame.Text:SetJustifyH("RIGHT")
      AffixFrame.Tier = AffixFrame:CreateFontString(AffixFrame:GetName() .. "Tier", "OVERLAY")
      AffixFrame.Tier:SetPoint("TOPLEFT", AffixFrame, "TOP", 1, -1)
      AffixFrame.Tier:SetPoint("BOTTOMRIGHT", AffixFrame, "BOTTOMRIGHT", -1, 1)
      AffixFrame.Tier:SetFontObject("GameFontHighlight_NoShadow")
      AffixFrame.Tier:SetJustifyH("LEFT")
    end
    anchorFrame = DungeonFrame
  end

  -- Raid Rows
  for raidIndex, raid in ipairs(raids) do
    local RaidFrame = CreateFrame("Frame", "$parentRaid" .. raidIndex, CharacterColumn)
    RaidFrame:SetHeight(Constants.sizes.row)
    RaidFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
    RaidFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
    self:SetBackgroundColor(RaidFrame, 0, 0, 0, 0.3)
    anchorFrame = RaidFrame

    for difficultyIndex in pairs(difficulties) do
      local DifficultyFrame = CreateFrame("Frame", "$parentDifficulty" .. difficultyIndex, RaidFrame)
      DifficultyFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
      DifficultyFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
      DifficultyFrame:SetHeight(Constants.sizes.row)
      self:SetBackgroundColor(DifficultyFrame, 1, 1, 1, difficultyIndex % 2 == 0 and 0.01 or 0)
      anchorFrame = DifficultyFrame

      for encounterIndex in ipairs(raid.encounters) do
        local EncounterFrame = CreateFrame("Frame", "$parentEncounter" .. encounterIndex, DifficultyFrame)
        local size = CHARACTER_WIDTH
        size = size - Constants.sizes.padding      -- left/right cell padding
        size = size - (raid.numEncounters - 1) * 4 -- gaps
        size = size / raid.numEncounters           -- box sizes
        EncounterFrame:SetPoint("LEFT", anchorFrame, encounterIndex > 1 and "RIGHT" or "LEFT", Constants.sizes.padding / 2, 0)
        EncounterFrame:SetSize(size, Constants.sizes.row - 12)
        self:SetBackgroundColor(EncounterFrame, 1, 1, 1, 0.1)
        anchorFrame = EncounterFrame
      end
      anchorFrame = DifficultyFrame
    end
  end

  return CharacterColumn
end

local CharacterColumns = {}
function Main:GetCharacterColumn(parent, index)
  if CharacterColumns[index] == nil then
    CharacterColumns[index] = self:CreateCharacterColumn(parent, index)
  end
  CharacterColumns[index]:Show()
  return CharacterColumns[index]
end

--- Hide all character columns
function Main:HideCharacterColumns()
  Utils:TableForEach(CharacterColumns, function(CharacterColumn)
    CharacterColumn:Hide()
  end)
end

--- Does the main window need scrollbars?
---@return boolean
function Main:IsScrollbarNeeded()
  local numCharacters = Utils:TableCount(self:GetCharacters())
  return numCharacters > 0 and SIDEBAR_WIDTH + numCharacters * CHARACTER_WIDTH > self:GetMaxWindowWidth()
end

--- Calculate the main window size
---@return number, number
function Main:GetWindowSize()
  local numCharacters = Utils:TableCount(self:GetCharacters())
  local numDungeons = Utils:TableCount(Data:GetDungeons())
  local numRaids = Utils:TableCount(Data:GetRaids())
  local numDifficulties = Utils:TableCount(Data:GetRaidDifficulties())
  local numCharacterInfo = Utils:TableCount(Utils:TableFilter(Data:GetCharacterInfo(), function(label)
    return label.enabled == nil or label.enabled == true
  end))
  local width = 0
  local maxWidth = Window:GetMaxWindowWidth()
  local height = 0

  -- Width
  if numCharacters == 0 then
    width = 500
  else
    width = width + SIDEBAR_WIDTH
    width = width + numCharacters * CHARACTER_WIDTH
  end
  if width > maxWidth then
    width = maxWidth
    if numCharacters > 0 then
      height = height + Constants.sizes.footer.height -- Shoes?
    end
  end

  -- Height
  height = height + Constants.sizes.titlebar.height                          -- Titlebar duh
  height = height + numCharacterInfo * Constants.sizes.row                   -- Character info
  height = height + (numDungeons + 1) * Constants.sizes.row                  -- Dungeons
  if Data.db.global.raids.enabled == true then
    height = height + numRaids * (numDifficulties + 1) * Constants.sizes.row -- Raids
  end

  return width, height
end

function Main:Render()
  local currentAffixes = Data:GetCurrentAffixes()
  local activeWeek = Data:GetActiveAffixRotation(currentAffixes)
  local seasonID = Data:GetCurrentSeason()
  local affixes = Data:GetAffixes()
  local affixRotation = Data:GetAffixRotation()
  local difficulties = Data:GetRaidDifficulties(true)
  local dungeons = Data:GetDungeons()
  local labels = Data:GetCharacterInfo()
  local raids = Data:GetRaids(true)
  local characters = self:GetCharacters()

  local anchorFrame

  if not self.window then
    self.window = Window:CreateWindow({
      name = "Main",
      title = addonName,
      sidebar = true
    })
  end

  -- Zero characters
  if not self.zeroCharacters then
    self.zeroCharacters = self.window.body:CreateFontString("$parentNoCharacterText", "ARTWORK")
    self.zeroCharacters:SetPoint("TOPLEFT", self.window.body, "TOPLEFT", 50, -50)
    self.zeroCharacters:SetPoint("BOTTOMRIGHT", self.window.body, "BOTTOMRIGHT", -50, 50)
    self.zeroCharacters:SetJustifyH("CENTER")
    self.zeroCharacters:SetJustifyV("CENTER")
    self.zeroCharacters:SetFontObject("GameFontHighlight_NoShadow")
    self.zeroCharacters:SetText("|cffffffffHi there :-)|r\n\nYou need to enable a max level character for this addon to show you some goodies!")
    self.zeroCharacters:SetVertexColor(1.0, 0.82, 0.0, 1)
    self.zeroCharacters:Hide()
  end

  -- Affixes
  if not self.window.affixes then
    self.window.affixes = CreateFrame("Frame", "$parentAffixes", self.window.TitleBar)
    self.window.affixes.buttons = {}
  end
  if Utils:TableCount(currentAffixes) > 0 then
    Utils:TableForEach(currentAffixes, function(currentAffix, i)
      local name, desc, fileDataID = C_ChallengeMode.GetAffixInfo(currentAffix.id);
      local button = self.window.affixes.buttons[i]
      if not button then
        button = CreateFrame("Button", "$parent" .. i, self.window.affixes)
        button:SetScript("OnEnter", function()
          GameTooltip:ClearAllPoints()
          GameTooltip:ClearLines()
          GameTooltip:SetOwner(button, "ANCHOR_TOP")
          GameTooltip:SetText(name, 1, 1, 1);
          GameTooltip:AddLine(desc, nil, nil, nil, true)
          GameTooltip:AddLine(" ")
          GameTooltip:AddLine("<Click to View Weekly Affixes>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
          GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function()
          GameTooltip:Hide()
        end)
        button:SetScript("OnClick", function()
          self:SendMessage("AE_WEEKLYAFFIXES_TOGGLE")
        end)
        self.window.affixes.buttons[i] = button
      end
      button:SetSize(20, 20)
      button:SetNormalTexture(fileDataID)
    end)
    self.window.affixes:Show()
  else
    self.window.affixes:Hide()
  end

  if self:IsScrollbarNeeded() then
    self.window.Footer.Scrollbar:SetMinMaxValues(0, self.window.body.ScrollFrame.ScrollChild:GetWidth() - self.window.body.ScrollFrame:GetWidth())
    self.window.Footer.Scrollbar.thumb:SetWidth(self.window.Footer.Scrollbar:GetWidth() / 10)
    self.window.body:SetPoint("BOTTOMLEFT", self.window.Footer, "TOPLEFT")
    self.window.body:SetPoint("BOTTOMRIGHT", self.window.Footer, "TOPRIGHT")
    self.window.Footer:Show()
  else
    self.window.body.ScrollFrame:SetHorizontalScroll(0)
    self.window.body:SetPoint("BOTTOMLEFT", self.window, "BOTTOMLEFT")
    self.window.body:SetPoint("BOTTOMRIGHT", self.window, "BOTTOMRIGHT")
    self.window.Footer:Hide()
  end

  if Utils:TableCount(characters) <= 0 then
    self.zeroCharacters:Show()
    self.window.body.Sidebar:Hide()
    self.window.body.ScrollFrame:Hide()
    self.window.Footer:Hide()
  else
    self.zeroCharacters:Hide()
    self.window.body.Sidebar:Show()
    self.window.body.ScrollFrame:Show()
    self.window.Footer:Show()
  end

  self.window:SetSize(self:GetWindowSize())
  self.window.body.ScrollFrame.ScrollChild:SetSize(Utils:TableCount(characters) * CHARACTER_WIDTH, self.window.body.ScrollFrame:GetHeight())
  Window:SetWindowScale(Data.db.global.interface.windowScale / 100)
  Window:SetWindowBackgroundColor(Data.db.global.interface.windowColor)
end

function Main:CreateUI()
  local currentAffixes = Data:GetCurrentAffixes()
  local activeWeek = Data:GetActiveAffixRotation(currentAffixes)
  local seasonID = Data:GetCurrentSeason()
  local affixes = Data:GetAffixes()
  local affixRotation = Data:GetAffixRotation()
  local difficulties = Data:GetRaidDifficulties(true)
  local dungeons = Data:GetDungeons()
  local labels = Data:GetCharacterInfo()
  local raids = Data:GetRaids(true)
  local anchorFrame

  local winMain = self:CreateWindow("Main", "AlterEgo", UIParent)
  local winEquipment = self:CreateWindow("Character", "Character", UIParent)
  local winKeyManager = self:CreateWindow("KeyManager", "KeyManager", UIParent)

  winEquipment.Body.Table = self.Table:New()
  winEquipment.Body.Table.frame:SetParent(winEquipment.Body)
  winEquipment.Body.Table.frame:SetPoint("TOPLEFT", winEquipment.Body, "TOPLEFT")

  do -- TitleBar
    anchorFrame = winMain.TitleBar
    winMain.TitleBar.Affixes = CreateFrame("Button", "$parentAffixes", winMain.TitleBar)
    for i = 1, 3 do
      local affixButton = CreateFrame("Button", "$parent" .. i, winMain.TitleBar.Affixes)
      affixButton:SetSize(20, 20)
      if Utils:TableCount(currentAffixes) > 0 then
        local currentAffix = currentAffixes[i]
        if currentAffix ~= nil then
          local name, desc, fileDataID = C_ChallengeMode.GetAffixInfo(currentAffix.id);
          affixButton:SetNormalTexture(fileDataID)
          affixButton:SetScript("OnEnter", function()
            GameTooltip:ClearAllPoints()
            GameTooltip:ClearLines()
            GameTooltip:SetOwner(affixButton, "ANCHOR_TOP")
            GameTooltip:SetText(name, 1, 1, 1);
            GameTooltip:AddLine(desc, nil, nil, nil, true)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("<Click to View Weekly Affixes>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
            GameTooltip:Show()
          end)
          affixButton:SetScript("OnLeave", function()
            GameTooltip:Hide()
          end)
        end
      end
      affixButton:SetScript("OnClick", function()
        self:ToggleWindow("Affixes")
      end)
    end
    winMain.TitleBar.SettingsButton = CreateFrame("Button", "$parentSettingsButton", winMain.TitleBar)
    winMain.TitleBar.SettingsButton:SetPoint("RIGHT", winMain.TitleBar.CloseButton, "LEFT", 0, 0)
    winMain.TitleBar.SettingsButton:SetSize(Constants.sizes.titlebar.height, Constants.sizes.titlebar.height)
    winMain.TitleBar.SettingsButton:RegisterForClicks("AnyUp")
    winMain.TitleBar.SettingsButton.HandlesGlobalMouseEvent = function()
      return true
    end
    winMain.TitleBar.SettingsButton:SetScript("OnClick", function()
      ToggleDropDownMenu(1, nil, winMain.TitleBar.SettingsButton.Dropdown)
    end)
    winMain.TitleBar.SettingsButton.Icon = winMain.TitleBar:CreateTexture(winMain.TitleBar.SettingsButton:GetName() .. "Icon", "ARTWORK")
    winMain.TitleBar.SettingsButton.Icon:SetPoint("CENTER", winMain.TitleBar.SettingsButton, "CENTER")
    winMain.TitleBar.SettingsButton.Icon:SetSize(12, 12)
    winMain.TitleBar.SettingsButton.Icon:SetTexture(Constants.media.IconSettings)
    winMain.TitleBar.SettingsButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    winMain.TitleBar.SettingsButton.Dropdown = CreateFrame("Frame", winMain.TitleBar.SettingsButton:GetName() .. "Dropdown", winMain.TitleBar, "UIDropDownMenuTemplate")
    winMain.TitleBar.SettingsButton.Dropdown:SetPoint("CENTER", winMain.TitleBar.SettingsButton, "CENTER", 0, -6)
    winMain.TitleBar.SettingsButton.Dropdown.Button:Hide()
    UIDropDownMenu_SetWidth(winMain.TitleBar.SettingsButton.Dropdown, Constants.sizes.titlebar.height)
    UIDropDownMenu_Initialize(
      winMain.TitleBar.SettingsButton.Dropdown,
      function(frame, level, subMenuName)
        if subMenuName == "raiddifficulties" then
          Utils:TableForEach(difficulties, function(difficulty)
            UIDropDownMenu_AddButton(
              {
                text = difficulty.name,
                value = difficulty.id,
                checked = Data.db.global.raids.hiddenDifficulties and not Data.db.global.raids.hiddenDifficulties[difficulty.id],
                keepShownOnClick = true,
                func = function(button, arg1, arg2, checked)
                  Data.db.global.raids.hiddenDifficulties[button.value] = not checked
                  self:UpdateUI()
                end
              },
              level
            )
          end)
        elseif subMenuName == "windowscale" then
          for i = 80, 200, 10 do
            UIDropDownMenu_AddButton(
              {
                text = i .. "%",
                value = i,
                checked = Data.db.global.interface.windowScale == i,
                keepShownOnClick = false,
                func = function(button)
                  Data.db.global.interface.windowScale = button.value
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
            checked = Data.db.global.showAffixHeader,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Show the weekly affixes",
            tooltipText = "The affixes will be shown at the top.",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              Data.db.global.showAffixHeader = checked
              self:UpdateUI()
            end
          })
          UIDropDownMenu_AddButton({
            text = "Show characters with zero rating",
            checked = Data.db.global.showZeroRatedCharacters,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Show characters with zero rating",
            tooltipText = "Too many alts?",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              Data.db.global.showZeroRatedCharacters = checked
              self:UpdateUI()
            end
          })
          UIDropDownMenu_AddButton({
            text = "Show realm names",
            checked = Data.db.global.showRealms,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Show realm names",
            tooltipText = "One big party!",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              Data.db.global.showRealms = checked
              self:UpdateUI()
            end
          })
          UIDropDownMenu_AddButton({
            text = "Use Raider.io rating colors",
            checked = Data.db.global.useRIOScoreColor,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Use Raider.io rating colors",
            tooltipText = "So many colors!",
            tooltipOnButton = true,
            disabled = type(_G.RaiderIO) == "nil",
            func = function(button, arg1, arg2, checked)
              Data.db.global.useRIOScoreColor = checked
              self:UpdateUI()
            end
          })
          UIDropDownMenu_AddButton({text = "Automatic Announcements", isTitle = true, notCheckable = true})
          UIDropDownMenu_AddButton({
            text = "Announce instance resets",
            checked = Data.db.global.announceResets,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Announce instance resets",
            tooltipText = "Let others in your group know when you've reset the instances.",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              Data.db.global.announceResets = checked
              self:UpdateUI()
            end
          })
          UIDropDownMenu_AddButton({
            text = "Announce new keystones (Party)",
            checked = Data.db.global.announceKeystones.autoParty,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "New keystones (Party)",
            tooltipText = "Announce to your party when you loot a new keystone.",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              Data.db.global.announceKeystones.autoParty = checked
              self:UpdateUI()
            end
          })
          UIDropDownMenu_AddButton({
            text = "Announce new keystones (Guild)",
            checked = Data.db.global.announceKeystones.autoGuild,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "New keystones (Guild)",
            tooltipText = "Announce to your guild when you loot a new keystone.",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              Data.db.global.announceKeystones.autoGuild = checked
              self:UpdateUI()
            end
          })
          UIDropDownMenu_AddButton({text = "Raids", isTitle = true, notCheckable = true})
          UIDropDownMenu_AddButton({
            text = "Show raid progress",
            checked = Data.db.global.raids and Data.db.global.raids.enabled,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Show raid progress",
            tooltipText = "Because Mythic Plus ain't enough!",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              Data.db.global.raids.enabled = checked
              self:UpdateUI()
            end,
            hasArrow = true,
            menuList = "raiddifficulties"
          })
          if seasonID == 12 then
            UIDropDownMenu_AddButton({
              text = "Show |cFF00FFFFAwakened|r raids only",
              checked = Data.db.global.raids and Data.db.global.raids.modifiedInstanceOnly,
              keepShownOnClick = true,
              isNotRadio = true,
              tooltipTitle = "Show |cFF00FFFFAwakened|r raids only",
              tooltipText = "It's time to move on!",
              tooltipOnButton = true,
              func = function(button, arg1, arg2, checked)
                Data.db.global.raids.modifiedInstanceOnly = checked
                self:UpdateUI()
              end
            })
          end
          UIDropDownMenu_AddButton({
            text = "Show difficulty colors",
            checked = Data.db.global.raids and Data.db.global.raids.colors,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Show difficulty colors",
            tooltipText = "Argharhggh! So much greeeen!",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              Data.db.global.raids.colors = checked
              self:UpdateUI()
            end
          })
          UIDropDownMenu_AddButton({text = "Dungeons", isTitle = true, notCheckable = true})
          UIDropDownMenu_AddButton({
            text = "Show timed icons",
            checked = Data.db.global.showTiers,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Show timed icons",
            tooltipText = "Show the timed icons (|A:Professions-ChatIcon-Quality-Tier1:16:16:0:-1|a |A:Professions-ChatIcon-Quality-Tier2:16:16:0:-1|a |A:Professions-ChatIcon-Quality-Tier3:16:16:0:-1|a).",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              Data.db.global.showTiers = checked
              self:UpdateUI()
            end
          })
          UIDropDownMenu_AddButton({
            text = "Show score colors",
            checked = Data.db.global.showAffixColors,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Show score colors",
            tooltipText = "Show some colors!",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              Data.db.global.showAffixColors = checked
              self:UpdateUI()
            end
          })
          UIDropDownMenu_AddButton({text = "PvP", isTitle = true, notCheckable = true})
          UIDropDownMenu_AddButton({
            text = "Show PvP progress",
            checked = Data.db.global.pvp and Data.db.global.pvp.enabled,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Show PvP progress",
            tooltipText = "Because Mythic Plus ain't enough!",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              Data.db.global.pvp.enabled = checked
              self:UpdateUI()
            end
          })
          UIDropDownMenu_AddButton({text = "Minimap", isTitle = true, notCheckable = true})
          UIDropDownMenu_AddButton({
            text = "Show the minimap button",
            checked = not Data.db.global.minimap.hide,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Show the minimap button",
            tooltipText = "It does get crowded around the minimap sometimes.",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              Data.db.global.minimap.hide = not checked
              self.Libs.LDBIcon:Refresh("AlterEgo", Data.db.global.minimap)
            end
          })
          UIDropDownMenu_AddButton({
            text = "Lock the minimap button",
            checked = Data.db.global.minimap.lock,
            keepShownOnClick = true,
            isNotRadio = true,
            tooltipTitle = "Lock the minimap button",
            tooltipText = "No more moving the button around accidentally!",
            tooltipOnButton = true,
            func = function(button, arg1, arg2, checked)
              Data.db.global.minimap.lock = checked
              self.Libs.LDBIcon:Refresh("AlterEgo", Data.db.global.minimap)
            end
          })
          UIDropDownMenu_AddButton({text = "Interface", isTitle = true, notCheckable = true})
          UIDropDownMenu_AddButton({
            text = "Window color",
            keepShownOnClick = false,
            notCheckable = true,
            hasColorSwatch = true,
            r = Data.db.global.interface.windowColor.r,
            g = Data.db.global.interface.windowColor.g,
            b = Data.db.global.interface.windowColor.b,
            -- notClickable = true,
            hasOpacity = false,
            func = UIDropDownMenuButton_OpenColorPicker,
            swatchFunc = function()
              local r, g, b = ColorPickerFrame:GetColorRGB();
              Data.db.global.interface.windowColor.r = r
              Data.db.global.interface.windowColor.g = g
              Data.db.global.interface.windowColor.b = b
              self:SetWindowBackgroundColor(Data.db.global.interface.windowColor)
              -- self:SetBackgroundColor(winMain, Data.db.global.interface.windowColor.r, Data.db.global.interface.windowColor.g, Data.db.global.interface.windowColor.b, Data.db.global.interface.windowColor.a)
            end,
            cancelFunc = function(color)
              Data.db.global.interface.windowColor.r = color.r
              Data.db.global.interface.windowColor.g = color.g
              Data.db.global.interface.windowColor.b = color.b
              self:SetWindowBackgroundColor(Data.db.global.interface.windowColor)
              -- self:SetBackgroundColor(winMain, Data.db.global.interface.windowColor.r, Data.db.global.interface.windowColor.g, Data.db.global.interface.windowColor.b, Data.db.global.interface.windowColor.a)
            end
          })
          UIDropDownMenu_AddButton({text = "Window scale", notCheckable = true, hasArrow = true, menuList = "windowscale"})
        end
      end,
      "MENU"
    )
    winMain.TitleBar.SettingsButton:SetScript("OnEnter", function()
      winMain.TitleBar.SettingsButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
      self:SetBackgroundColor(winMain.TitleBar.SettingsButton, 1, 1, 1, 0.05)
      GameTooltip:ClearAllPoints()
      GameTooltip:ClearLines()
      GameTooltip:SetOwner(winMain.TitleBar.SettingsButton, "ANCHOR_TOP")
      GameTooltip:SetText("Settings", 1, 1, 1, 1, true);
      GameTooltip:AddLine("Let's customize things a bit", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
      GameTooltip:Show()
    end)
    winMain.TitleBar.SettingsButton:SetScript("OnLeave", function()
      winMain.TitleBar.SettingsButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
      self:SetBackgroundColor(winMain.TitleBar.SettingsButton, 1, 1, 1, 0)
      GameTooltip:Hide()
    end)
    winMain.TitleBar.SortingButton = CreateFrame("Button", "$parentSorting", winMain.TitleBar)
    winMain.TitleBar.SortingButton:SetPoint("RIGHT", winMain.TitleBar.SettingsButton, "LEFT", 0, 0)
    winMain.TitleBar.SortingButton:SetSize(Constants.sizes.titlebar.height, Constants.sizes.titlebar.height)
    winMain.TitleBar.SortingButton.HandlesGlobalMouseEvent = function()
      return true
    end
    winMain.TitleBar.SortingButton:SetScript("OnClick", function()
      ToggleDropDownMenu(1, nil, winMain.TitleBar.SortingButton.Dropdown)
    end)
    winMain.TitleBar.SortingButton.Icon = winMain.TitleBar:CreateTexture(winMain.TitleBar.SortingButton:GetName() .. "Icon", "ARTWORK")
    winMain.TitleBar.SortingButton.Icon:SetPoint("CENTER", winMain.TitleBar.SortingButton, "CENTER")
    winMain.TitleBar.SortingButton.Icon:SetSize(16, 16)
    winMain.TitleBar.SortingButton.Icon:SetTexture(Constants.media.IconSorting)
    winMain.TitleBar.SortingButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    winMain.TitleBar.SortingButton.Dropdown = CreateFrame("Frame", winMain.TitleBar.SortingButton:GetName() .. "Dropdown", winMain.TitleBar.SortingButton, "UIDropDownMenuTemplate")
    winMain.TitleBar.SortingButton.Dropdown:SetPoint("CENTER", winMain.TitleBar.SortingButton, "CENTER", 0, -6)
    winMain.TitleBar.SortingButton.Dropdown.Button:Hide()
    UIDropDownMenu_SetWidth(winMain.TitleBar.SortingButton.Dropdown, Constants.sizes.titlebar.height)
    UIDropDownMenu_Initialize(
      winMain.TitleBar.SortingButton.Dropdown,
      function()
        for _, option in ipairs(Constants.sortingOptions) do
          UIDropDownMenu_AddButton({
            text = option.text,
            checked = Data.db.global.sorting == option.value,
            arg1 = option.value,
            func = function(button, arg1, arg2, checked)
              Data.db.global.sorting = arg1
              self:UpdateUI()
            end
          })
        end
      end,
      "MENU"
    )
    winMain.TitleBar.SortingButton:SetScript("OnEnter", function()
      winMain.TitleBar.SortingButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
      self:SetBackgroundColor(winMain.TitleBar.SortingButton, 1, 1, 1, 0.05)
      GameTooltip:ClearAllPoints()
      GameTooltip:ClearLines()
      GameTooltip:SetOwner(winMain.TitleBar.SortingButton, "ANCHOR_TOP")
      GameTooltip:SetText("Sorting", 1, 1, 1, 1, true);
      GameTooltip:AddLine("Sort your characters.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
      GameTooltip:Show()
    end)
    winMain.TitleBar.SortingButton:SetScript("OnLeave", function()
      winMain.TitleBar.SortingButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
      self:SetBackgroundColor(winMain.TitleBar.SortingButton, 1, 1, 1, 0)
      GameTooltip:Hide()
    end)
    winMain.TitleBar.CharactersButton = CreateFrame("Button", "$parentCharacters", winMain.TitleBar)
    winMain.TitleBar.CharactersButton:SetPoint("RIGHT", winMain.TitleBar.SortingButton, "LEFT", 0, 0)
    winMain.TitleBar.CharactersButton:SetSize(Constants.sizes.titlebar.height, Constants.sizes.titlebar.height)
    winMain.TitleBar.CharactersButton.HandlesGlobalMouseEvent = function()
      return true
    end
    winMain.TitleBar.CharactersButton:SetScript("OnClick", function()
      ToggleDropDownMenu(1, nil, winMain.TitleBar.CharactersButton.Dropdown)
    end)
    winMain.TitleBar.CharactersButton.Icon = winMain.TitleBar:CreateTexture(winMain.TitleBar.CharactersButton:GetName() .. "Icon", "ARTWORK")
    winMain.TitleBar.CharactersButton.Icon:SetPoint("CENTER", winMain.TitleBar.CharactersButton, "CENTER")
    winMain.TitleBar.CharactersButton.Icon:SetSize(14, 14)
    winMain.TitleBar.CharactersButton.Icon:SetTexture(Constants.media.IconCharacters)
    winMain.TitleBar.CharactersButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    winMain.TitleBar.CharactersButton.Dropdown = CreateFrame("Frame", winMain.TitleBar.CharactersButton:GetName() .. "Dropdown", winMain.TitleBar.CharactersButton, "UIDropDownMenuTemplate")
    winMain.TitleBar.CharactersButton.Dropdown:SetPoint("CENTER", winMain.TitleBar.CharactersButton, "CENTER", 0, -6)
    winMain.TitleBar.CharactersButton.Dropdown.Button:Hide()
    UIDropDownMenu_SetWidth(winMain.TitleBar.CharactersButton.Dropdown, Constants.sizes.titlebar.height)
    UIDropDownMenu_Initialize(
      winMain.TitleBar.CharactersButton.Dropdown,
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
            keepShownOnClick = true,
            arg1 = character.GUID,
            func = function(button, arg1, arg2, checked)
              Data.db.global.characters[arg1].enabled = checked
              self:UpdateUI()
            end
          })
        end
      end,
      "MENU"
    )
    winMain.TitleBar.CharactersButton:SetScript("OnEnter", function()
      winMain.TitleBar.CharactersButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
      self:SetBackgroundColor(winMain.TitleBar.CharactersButton, 1, 1, 1, 0.05)
      GameTooltip:ClearAllPoints()
      GameTooltip:ClearLines()
      GameTooltip:SetOwner(winMain.TitleBar.CharactersButton, "ANCHOR_TOP")
      GameTooltip:SetText("Characters", 1, 1, 1, 1, true);
      GameTooltip:AddLine("Enable/Disable your characters.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
      GameTooltip:Show()
    end)
    winMain.TitleBar.CharactersButton:SetScript("OnLeave", function()
      winMain.TitleBar.CharactersButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
      self:SetBackgroundColor(winMain.TitleBar.CharactersButton, 1, 1, 1, 0)
      GameTooltip:Hide()
    end)
    winMain.TitleBar.AnnounceButton = CreateFrame("Button", "$parentCharacters", winMain.TitleBar)
    winMain.TitleBar.AnnounceButton:SetPoint("RIGHT", winMain.TitleBar.CharactersButton, "LEFT", 0, 0)
    winMain.TitleBar.AnnounceButton:SetSize(Constants.sizes.titlebar.height, Constants.sizes.titlebar.height)
    winMain.TitleBar.AnnounceButton.HandlesGlobalMouseEvent = function()
      return true
    end
    winMain.TitleBar.AnnounceButton:SetScript("OnClick", function()
      ToggleDropDownMenu(1, nil, winMain.TitleBar.AnnounceButton.Dropdown)
    end)
    winMain.TitleBar.AnnounceButton.Icon = winMain.TitleBar:CreateTexture(
      winMain.TitleBar.AnnounceButton:GetName() .. "Icon", "ARTWORK")
    winMain.TitleBar.AnnounceButton.Icon:SetPoint("CENTER", winMain.TitleBar.AnnounceButton, "CENTER")
    winMain.TitleBar.AnnounceButton.Icon:SetSize(12, 12)
    winMain.TitleBar.AnnounceButton.Icon:SetTexture(Constants.media.IconAnnounce)
    winMain.TitleBar.AnnounceButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    winMain.TitleBar.AnnounceButton.Dropdown = CreateFrame("Frame", winMain.TitleBar.AnnounceButton:GetName() .. "Dropdown", winMain.TitleBar.AnnounceButton, "UIDropDownMenuTemplate")
    winMain.TitleBar.AnnounceButton.Dropdown:SetPoint("CENTER", winMain.TitleBar.AnnounceButton, "CENTER", 0, -6)
    winMain.TitleBar.AnnounceButton.Dropdown.Button:Hide()
    UIDropDownMenu_SetWidth(winMain.TitleBar.AnnounceButton.Dropdown, Constants.sizes.titlebar.height)
    UIDropDownMenu_Initialize(
      winMain.TitleBar.AnnounceButton.Dropdown,
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
            self:AnnounceKeystones("PARTY")
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
            self:AnnounceKeystones("GUILD")
          end
        })
        UIDropDownMenu_AddButton({text = "Settings", isTitle = true, notCheckable = true})
        UIDropDownMenu_AddButton({
          text = "Multiple chat messages",
          checked = Data.db.global.announceKeystones.multiline,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Announce keystones with multiple chat messages",
          tooltipText = "With too many alts it could get spammy though.",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            Data.db.global.announceKeystones.multiline = checked
          end
        })
        UIDropDownMenu_AddButton({
          text = "With character names",
          checked = Data.db.global.announceKeystones.multilineNames,
          keepShownOnClick = true,
          isNotRadio = true,
          tooltipTitle = "Add character names before each keystone",
          tooltipText = "Character names are only added if multiple chat messages is enabled.",
          tooltipOnButton = true,
          func = function(button, arg1, arg2, checked)
            Data.db.global.announceKeystones.multilineNames = checked
          end
        })
      end,
      "MENU"
    )
    winMain.TitleBar.AnnounceButton:SetScript("OnEnter", function()
      winMain.TitleBar.AnnounceButton.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
      self:SetBackgroundColor(winMain.TitleBar.AnnounceButton, 1, 1, 1, 0.05)
      GameTooltip:ClearAllPoints()
      GameTooltip:ClearLines()
      GameTooltip:SetOwner(winMain.TitleBar.AnnounceButton, "ANCHOR_TOP")
      GameTooltip:SetText("Announce Keystones", 1, 1, 1, 1, true);
      GameTooltip:AddLine("Sharing is caring.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
      GameTooltip:Show()
    end)
    winMain.TitleBar.AnnounceButton:SetScript("OnLeave", function()
      winMain.TitleBar.AnnounceButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
      self:SetBackgroundColor(winMain.TitleBar.AnnounceButton, 1, 1, 1, 0)
      GameTooltip:Hide()
    end)
  end


  do -- Sidebar
    winMain.Body.Sidebar = CreateFrame("Frame", "$parentSidebar", winMain.Body)
    winMain.Body.Sidebar:SetPoint("TOPLEFT", winMain.Body, "TOPLEFT")
    winMain.Body.Sidebar:SetPoint("BOTTOMLEFT", winMain.Body, "BOTTOMLEFT")
    winMain.Body.Sidebar:SetWidth(SIDEBAR_WIDTH)
    self:SetBackgroundColor(winMain.Body.Sidebar, 0, 0, 0, 0.3)
    anchorFrame = winMain.Body.Sidebar
  end

  do -- Character info
    for labelIndex, info in ipairs(labels) do
      local Label = CreateFrame("Frame", "$parentLabel" .. labelIndex, winMain.Body.Sidebar)
      if labelIndex > 1 then
        Label:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
        Label:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
      else
        Label:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT")
        Label:SetPoint("TOPRIGHT", anchorFrame, "TOPRIGHT")
      end
      Label:SetHeight(Constants.sizes.row)
      Label.Text = Label:CreateFontString(Label:GetName() .. "Text", "OVERLAY")
      Label.Text:SetPoint("LEFT", Label, "LEFT", Constants.sizes.padding, 0)
      Label.Text:SetPoint("RIGHT", Label, "RIGHT", -Constants.sizes.padding, 0)
      Label.Text:SetJustifyH("LEFT")
      Label.Text:SetFontObject("GameFontHighlight_NoShadow")
      Label.Text:SetText(info.label)
      Label.Text:SetVertexColor(1.0, 0.82, 0.0, 1)
      anchorFrame = Label
    end
  end

  do -- MythicPlus Label
    local Label = CreateFrame("Frame", "$parentMythicPlusLabel", winMain.Body.Sidebar)
    Label:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
    Label:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
    Label:SetHeight(Constants.sizes.row)
    Label.Text = Label:CreateFontString(Label:GetName() .. "Text", "OVERLAY")
    Label.Text:SetPoint("TOPLEFT", Label, "TOPLEFT", Constants.sizes.padding, 0)
    Label.Text:SetPoint("BOTTOMRIGHT", Label, "BOTTOMRIGHT", -Constants.sizes.padding, 0)
    Label.Text:SetFontObject("GameFontHighlight_NoShadow")
    Label.Text:SetJustifyH("LEFT")
    Label.Text:SetText("Mythic Plus")
    Label.Text:SetVertexColor(1.0, 0.82, 0.0, 1)
    anchorFrame = Label
  end

  do -- Dungeon Labels
    for dungeonIndex, dungeon in ipairs(dungeons) do
      local Label = CreateFrame("Button", "$parentDungeon" .. dungeonIndex, winMain.Body.Sidebar, "InsecureActionButtonTemplate")
      Label:SetPoint("TOPLEFT", anchorFrame:GetName(), "BOTTOMLEFT")
      Label:SetPoint("TOPRIGHT", anchorFrame:GetName(), "BOTTOMRIGHT")
      Label:SetHeight(Constants.sizes.row)
      Label.Icon = Label:CreateTexture(Label:GetName() .. "Icon", "ARTWORK")
      Label.Icon:SetSize(16, 16)
      Label.Icon:SetPoint("LEFT", Label:GetName(), "LEFT", Constants.sizes.padding, 0)
      Label.Icon:SetTexture(dungeon.icon)
      Label.Text = Label:CreateFontString(Label:GetName() .. "Text", "OVERLAY")
      Label.Text:SetPoint("TOPLEFT", Label:GetName(), "TOPLEFT", 16 + Constants.sizes.padding * 2, -3)
      Label.Text:SetPoint("BOTTOMRIGHT", Label:GetName(), "BOTTOMRIGHT", -Constants.sizes.padding, 3)
      Label.Text:SetJustifyH("LEFT")
      Label.Text:SetFontObject("GameFontHighlight_NoShadow")
      Label.Text:SetText(dungeon.short and dungeon.short or dungeon.name)
      anchorFrame = Label
    end
  end

  do -- Raids & Difficulties
    for raidIndex, raid in ipairs(raids) do
      local RaidFrame = CreateFrame("Frame", "$parentRaid" .. raidIndex, winMain.Body.Sidebar)
      RaidFrame:SetHeight(Constants.sizes.row)
      RaidFrame:SetPoint("TOPLEFT", anchorFrame:GetName(), "BOTTOMLEFT")
      RaidFrame:SetPoint("TOPRIGHT", anchorFrame:GetName(), "BOTTOMRIGHT")
      RaidFrame:SetScript("OnEnter", function()
        GameTooltip:ClearAllPoints()
        GameTooltip:ClearLines()
        GameTooltip:SetOwner(RaidFrame, "ANCHOR_RIGHT")
        GameTooltip:SetText(raid.name, 1, 1, 1);
        if raid.modifiedInstanceInfo then
          GameTooltip:AddLine(" ")
          GameTooltip:AddLine(raid.modifiedInstanceInfo.description)
        end
        GameTooltip:Show()
      end)
      RaidFrame:SetScript("OnLeave", function()
        GameTooltip:Hide()
      end)
      RaidFrame.Text = RaidFrame:CreateFontString(RaidFrame:GetName() .. "Text", "OVERLAY")
      RaidFrame.Text:SetPoint("LEFT", RaidFrame, "LEFT", Constants.sizes.padding, 0)
      RaidFrame.Text:SetFontObject("GameFontHighlight_NoShadow")
      RaidFrame.Text:SetJustifyH("LEFT")
      RaidFrame.Text:SetText(raid.short and raid.short or raid.name)
      RaidFrame.Text:SetWordWrap(false)
      RaidFrame.Text:SetVertexColor(1.0, 0.82, 0.0, 1)
      RaidFrame.ModifiedIcon = RaidFrame:CreateTexture("$parentModifiedIcon", "ARTWORK")
      RaidFrame.ModifiedIcon:SetSize(18, 18)
      RaidFrame.ModifiedIcon:SetPoint("RIGHT", RaidFrame, "RIGHT", -(Constants.sizes.padding / 2), 0)
      if raid.modifiedInstanceInfo then
        RaidFrame.ModifiedIcon:SetAtlas(GetFinalNameFromTextureKit("%s-small", raid.modifiedInstanceInfo.uiTextureKit))
        RaidFrame.ModifiedIcon:Show()
        RaidFrame.Text:SetPoint("RIGHT", RaidFrame.ModifiedIcon, "LEFT", -(Constants.sizes.padding / 2), 0)
      else
        RaidFrame.ModifiedIcon:Hide()
        RaidFrame.Text:SetPoint("RIGHT", RaidFrame, "RIGHT", -Constants.sizes.padding, 0)
      end
      anchorFrame = RaidFrame

      for difficultyIndex, difficulty in ipairs(difficulties) do
        local DifficultFrame = CreateFrame("Frame", "$parentDifficulty" .. difficultyIndex, RaidFrame)
        DifficultFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
        DifficultFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
        DifficultFrame:SetHeight(Constants.sizes.row)
        DifficultFrame:SetScript("OnEnter", function()
          GameTooltip:ClearAllPoints()
          GameTooltip:ClearLines()
          GameTooltip:SetOwner(DifficultFrame, "ANCHOR_RIGHT")
          GameTooltip:SetText(difficulty.name, 1, 1, 1);
          GameTooltip:Show()
        end)
        DifficultFrame:SetScript("OnLeave", function()
          GameTooltip:Hide()
        end)
        DifficultFrame.Text = DifficultFrame:CreateFontString(DifficultFrame:GetName() .. "Text", "OVERLAY")
        DifficultFrame.Text:SetPoint("TOPLEFT", DifficultFrame, "TOPLEFT", Constants.sizes.padding, -3)
        DifficultFrame.Text:SetPoint("BOTTOMRIGHT", DifficultFrame, "BOTTOMRIGHT", -Constants.sizes.padding, 3)
        DifficultFrame.Text:SetJustifyH("LEFT")
        DifficultFrame.Text:SetFontObject("GameFontHighlight_NoShadow")
        DifficultFrame.Text:SetText(difficulty.short and difficulty.short or difficulty.name)
        -- RaidLabel.Icon = RaidLabel:CreateTexture(RaidLabel:GetName() .. "Icon", "ARTWORK")
        -- RaidLabel.Icon:SetSize(16, 16)
        -- RaidLabel.Icon:SetPoint("LEFT", RaidLabel, "LEFT", Constants.sizes.padding, 0)
        -- RaidLabel.Icon:SetTexture(raid.icon)
        anchorFrame = DifficultFrame
      end
    end
  end

  winMain.Body.ScrollFrame = CreateFrame("ScrollFrame", "$parentScrollFrame", winMain.Body)
  winMain.Body.ScrollFrame:SetPoint("TOPLEFT", winMain.Body, "TOPLEFT", SIDEBAR_WIDTH, 0)
  winMain.Body.ScrollFrame:SetPoint("BOTTOMLEFT", winMain.Body, "BOTTOMLEFT", SIDEBAR_WIDTH, 0)
  winMain.Body.ScrollFrame:SetPoint("BOTTOMRIGHT", winMain.Body, "BOTTOMRIGHT")
  winMain.Body.ScrollFrame:SetPoint("TOPRIGHT", winMain.Body, "TOPRIGHT")
  winMain.Body.ScrollFrame.ScrollChild = CreateFrame("Frame", "$parentScrollChild", winMain.Body.ScrollFrame)
  winMain.Body.ScrollFrame:SetScrollChild(winMain.Body.ScrollFrame.ScrollChild)

  winMain.Footer = CreateFrame("Frame", "$parentFooter", winMain)
  winMain.Footer:SetHeight(Constants.sizes.footer.height)
  winMain.Footer:SetPoint("BOTTOMLEFT", winMain, "BOTTOMLEFT")
  winMain.Footer:SetPoint("BOTTOMRIGHT", winMain, "BOTTOMRIGHT")
  self:SetBackgroundColor(winMain.Footer, 0, 0, 0, .3)

  winMain.Footer.Scrollbar = CreateFrame("Slider", "$parentScrollbar", winMain.Footer, "UISliderTemplate")
  winMain.Footer.Scrollbar:SetPoint("TOPLEFT", winMain.Footer, "TOPLEFT", SIDEBAR_WIDTH, 0)
  winMain.Footer.Scrollbar:SetPoint("BOTTOMRIGHT", winMain.Footer, "BOTTOMRIGHT", -Constants.sizes.padding / 2, 0)
  winMain.Footer.Scrollbar:SetMinMaxValues(0, 100)
  winMain.Footer.Scrollbar:SetValue(0)
  winMain.Footer.Scrollbar:SetValueStep(1)
  winMain.Footer.Scrollbar:SetOrientation("HORIZONTAL")
  winMain.Footer.Scrollbar:SetObeyStepOnDrag(true)
  winMain.Footer.Scrollbar.NineSlice:Hide()
  winMain.Footer.Scrollbar.thumb = winMain.Footer.Scrollbar:GetThumbTexture()
  winMain.Footer.Scrollbar.thumb:SetPoint("CENTER")
  winMain.Footer.Scrollbar.thumb:SetColorTexture(1, 1, 1, 0.15)
  winMain.Footer.Scrollbar.thumb:SetHeight(Constants.sizes.footer.height - 10)
  winMain.Footer.Scrollbar:SetScript("OnValueChanged", function(_, value)
    winMain.Body.ScrollFrame:SetHorizontalScroll(value)
  end)
  winMain.Footer.Scrollbar:SetScript("OnEnter", function()
    winMain.Footer.Scrollbar.thumb:SetColorTexture(1, 1, 1, 0.2)
  end)
  winMain.Footer.Scrollbar:SetScript("OnLeave", function()
    winMain.Footer.Scrollbar.thumb:SetColorTexture(1, 1, 1, 0.15)
  end)
  winMain.Body.ScrollFrame:SetScript("OnMouseWheel", function(_, delta)
    winMain.Footer.Scrollbar:SetValue(winMain.Footer.Scrollbar:GetValue() - delta * ((winMain.Body.ScrollFrame.ScrollChild:GetWidth() - winMain.Body.ScrollFrame:GetWidth()) * 0.1))
  end)

  winMain.Body:SetPoint("BOTTOMLEFT", winMain.Footer, "TOPLEFT")
  winMain.Body:SetPoint("BOTTOMRIGHT", winMain.Footer, "TOPRIGHT")
  self:UpdateUI()
end

function Main:UpdateUI()
  local winMain = self:GetWindow("Main")
  if not winMain then
    return
  end

  local affixes = Data:GetAffixes(true)
  local currentAffixes = Data:GetCurrentAffixes();
  local characters = self:GetCharacters()
  local numCharacters = Utils:TableCount(characters)
  local dungeons = Data:GetDungeons()
  local raids = Data:GetRaids(true)
  local difficulties = Data:GetRaidDifficulties(true)
  local labels = Data:GetCharacterInfo()
  local anchorFrame


  self:SetWindowScale(Data.db.global.interface.windowScale / 100)
  self:SetWindowBackgroundColor(Data.db.global.interface.windowColor)
  -- winMain:SetScale(Data.db.global.interface.windowScale / 100)
  -- self:SetBackgroundColor(winMain, Data.db.global.interface.windowColor.r, Data.db.global.interface.windowColor.g, Data.db.global.interface.windowColor.b, Data.db.global.interface.windowColor.a)
  winMain.Body.ScrollFrame.ScrollChild:SetSize(numCharacters * CHARACTER_WIDTH, winMain.Body.ScrollFrame:GetHeight())

  if self:IsScrollbarNeeded() then
    winMain.Footer.Scrollbar:SetMinMaxValues(0, winMain.Body.ScrollFrame.ScrollChild:GetWidth() - winMain.Body.ScrollFrame:GetWidth())
    winMain.Footer.Scrollbar.thumb:SetWidth(winMain.Footer.Scrollbar:GetWidth() / 10)
    winMain.Body:SetPoint("BOTTOMLEFT", winMain.Footer, "TOPLEFT")
    winMain.Body:SetPoint("BOTTOMRIGHT", winMain.Footer, "TOPRIGHT")
    winMain.Footer:Show()
  else
    winMain.Body.ScrollFrame:SetHorizontalScroll(0)
    winMain.Body:SetPoint("BOTTOMLEFT", winMain, "BOTTOMLEFT")
    winMain.Body:SetPoint("BOTTOMRIGHT", winMain, "BOTTOMRIGHT")
    winMain.Footer:Hide()
  end

  do -- TitleBar
    anchorFrame = winMain.TitleBar
    if numCharacters == 1 then
      winMain.TitleBar.Text:Hide()
    else
      winMain.TitleBar.Text:Show()
    end
    if currentAffixes and Data.db.global.showAffixHeader then
      winMain.TitleBar.Affixes:Show()
    else
      winMain.TitleBar.Affixes:Hide()
    end

    for i = 1, 3 do
      local affixButton = _G[winMain.TitleBar.Affixes:GetName() .. i]
      if affixButton ~= nil then
        if i == 1 then
          affixButton:ClearAllPoints()
          if numCharacters == 1 then
            affixButton:SetPoint("LEFT", winMain.TitleBar.Icon, "RIGHT", 6, 0)
          else
            affixButton:SetPoint("CENTER", anchorFrame, "CENTER", -26, 0)
          end
        else
          affixButton:SetPoint("LEFT", anchorFrame, "RIGHT", 6, 0)
        end
        anchorFrame = affixButton
      end
    end
  end

  self:HideCharacterColumns()

  do -- Character Labels
    anchorFrame = winMain.Body.Sidebar
    for labelIndex, info in ipairs(labels) do
      local Label = _G[winMain.Body.Sidebar:GetName() .. "Label" .. labelIndex]
      if info.enabled ~= nil and info.enabled == false then
        Label:Hide()
      else
        if labelIndex > 1 then
          Label:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
          Label:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
        else
          Label:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT")
          Label:SetPoint("TOPRIGHT", anchorFrame, "TOPRIGHT")
        end
        Label:Show()
        anchorFrame = Label
      end
    end
  end

  do -- MythicPlus Label
    local Label = _G[winMain.Body.Sidebar:GetName() .. "MythicPlusLabel"]
    if Label then
      Label:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
      Label:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
      anchorFrame = Label
    end
  end

  do -- Dungeon Labels
    for dungeonIndex, dungeon in ipairs(dungeons) do
      local Label = _G[winMain.Body.Sidebar:GetName() .. "Dungeon" .. dungeonIndex]
      Label:SetPoint("TOPLEFT", anchorFrame:GetName(), "BOTTOMLEFT")
      Label:SetPoint("TOPRIGHT", anchorFrame:GetName(), "BOTTOMRIGHT")
      Label.Icon:SetTexture(dungeon.icon)
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
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("<Click to Teleport>", GREEN_FONT_COLOR.r, GREEN_FONT_COLOR.g, GREEN_FONT_COLOR.b)
            _G[GameTooltip:GetName() .. "TextLeft1"]:SetText(dungeon.name)
          else
            GameTooltip:AddLine("Time this dungeon on level 20 or above to unlock teleportation.", nil, nil, nil, true)
          end
        end
        GameTooltip:Show()
      end)
      Label:SetScript("OnLeave", function()
        GameTooltip:Hide()
      end)
      anchorFrame = Label
    end
  end

  do -- Raids & Difficulties
    for raidIndex, raid in ipairs(raids) do
      local RaidFrame = _G[winMain.Body.Sidebar:GetName() .. "Raid" .. raidIndex]
      if RaidFrame then
        if Data.db.global.raids.enabled and (not Data.db.global.raids.modifiedInstanceOnly or raid.modifiedInstanceInfo) then
          RaidFrame:Show()
          RaidFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
          RaidFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
          anchorFrame = RaidFrame
          for difficultyIndex, difficulty in ipairs(difficulties) do
            local DifficultyFrame = _G[RaidFrame:GetName() .. "Difficulty" .. difficultyIndex]
            if DifficultyFrame then
              if Data.db.global.raids.hiddenDifficulties and Data.db.global.raids.hiddenDifficulties[difficulty.id] then
                DifficultyFrame:Hide()
              else
                DifficultyFrame:Show()
                DifficultyFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
                DifficultyFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
                anchorFrame = DifficultyFrame
              end
            end
          end
        else
          RaidFrame:Hide()
        end
      end
    end
  end

  do -- Characters
    anchorFrame = winMain.Body.ScrollFrame.ScrollChild
    for characterIndex, character in ipairs(characters) do
      local CharacterColumn = self:GetCharacterColumn(winMain.Body.ScrollFrame.ScrollChild, characterIndex)
      if characterIndex > 1 then
        CharacterColumn:SetPoint("TOPLEFT", anchorFrame, "TOPRIGHT")
        CharacterColumn:SetPoint("BOTTOMLEFT", anchorFrame, "BOTTOMRIGHT")
      else
        CharacterColumn:SetPoint("TOPLEFT", anchorFrame, "TOPLEFT")
        CharacterColumn:SetPoint("BOTTOMLEFT", anchorFrame, "BOTTOMLEFT")
      end
      self:SetBackgroundColor(CharacterColumn, 1, 1, 1, characterIndex % 2 == 0 and 0.01 or 0)
      anchorFrame = CharacterColumn

      do -- Character info
        anchorFrame = CharacterColumn
        for labelIndex, info in ipairs(labels) do
          local CharacterFrame = _G[CharacterColumn:GetName() .. "Info" .. labelIndex]

          CharacterFrame.Text:SetText(info.value(character))
          if info.OnEnter then
            CharacterFrame:SetScript("OnEnter", function()
              GameTooltip:ClearAllPoints()
              GameTooltip:ClearLines()
              GameTooltip:SetOwner(CharacterFrame, "ANCHOR_RIGHT")
              info.OnEnter(character)
              GameTooltip:Show()
              if not info.backgroundColor then
                self:SetBackgroundColor(CharacterFrame, 1, 1, 1, 0.05)
              end
            end)
            CharacterFrame:SetScript("OnLeave", function()
              GameTooltip:Hide()
              if not info.backgroundColor then
                self:SetBackgroundColor(CharacterFrame, 1, 1, 1, 0)
              end
            end)
          else
            if not info.backgroundColor then
              CharacterFrame:SetScript("OnEnter", function()
                self:SetBackgroundColor(CharacterFrame, 1, 1, 1, 0.05)
              end)
              CharacterFrame:SetScript("OnLeave", function()
                self:SetBackgroundColor(CharacterFrame, 1, 1, 1, 0)
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

      do -- Affix header
        if CharacterColumn.AffixHeader then
          CharacterColumn.AffixHeader:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
          CharacterColumn.AffixHeader:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
          anchorFrame = CharacterColumn.AffixHeader
        end
      end

      do -- Affix header icons
        if currentAffixes then
          for affixIndex, affix in ipairs(affixes) do
            local active = false
            local AffixFrame = _G[CharacterColumn.AffixHeader:GetName() .. affixIndex]
            if AffixFrame then
              Utils:TableForEach(currentAffixes, function(currentAffix)
                if currentAffix.id == affix.id then
                  active = true
                end
              end)
            end
            if active then
              AffixFrame:SetAlpha(1)
            else
              AffixFrame:SetAlpha(0.2)
            end
          end
        end
      end

      do -- Dungeon rows
        -- Todo: Look into C_ChallengeMode.GetKeystoneLevelRarityColor(level)
        for dungeonIndex, dungeon in ipairs(dungeons) do
          local DungeonFrame = _G[CharacterColumn:GetName() .. "Dungeons" .. dungeonIndex]
          local characterDungeon = Utils:TableGet(character.mythicplus.dungeons, "challengeModeID", dungeon.challengeModeID)
          local overallScoreColor = HIGHLIGHT_FONT_COLOR
          if characterDungeon and characterDungeon.affixScores and Utils:TableCount(characterDungeon.affixScores) > 0 then
            if (characterDungeon.rating) then
              local color = C_ChallengeMode.GetSpecificDungeonOverallScoreRarityColor(characterDungeon.rating);
              if color ~= nil then
                overallScoreColor = color
              end
            end
          end
          DungeonFrame:SetScript("OnEnter", function()
            GameTooltip:ClearAllPoints()
            GameTooltip:ClearLines()
            GameTooltip:SetOwner(DungeonFrame, "ANCHOR_RIGHT")
            GameTooltip:SetText(dungeon.name, 1, 1, 1);
            if characterDungeon and characterDungeon.affixScores and Utils:TableCount(characterDungeon.affixScores) > 0 then
              if (characterDungeon.rating) then
                GameTooltip_AddNormalLine(GameTooltip, DUNGEON_SCORE_TOTAL_SCORE:format(overallScoreColor:WrapTextInColorCode(characterDungeon.rating)), GREEN_FONT_COLOR);
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
            self:SetBackgroundColor(DungeonFrame, 1, 1, 1, 0.05)
          end)
          DungeonFrame:SetScript("OnLeave", function()
            GameTooltip:Hide()
            self:SetBackgroundColor(DungeonFrame, 1, 1, 1, dungeonIndex % 2 == 0 and 0.01 or 0)
          end)

          for affixIndex, affix in ipairs(affixes) do
            local AffixFrame = _G[CharacterColumn:GetName() .. "Dungeons" .. dungeonIndex .. "Affix" .. affixIndex]
            if AffixFrame then
              local level = "-"
              local levelColor = "ffffffff"
              local tier = ""

              if characterDungeon == nil or characterDungeon.affixScores == nil then
                level = "-"
                levelColor = LIGHTGRAY_FONT_COLOR:GenerateHexColor()
              else
                local affixScore = Utils:TableGet(characterDungeon.affixScores, "id", affix.id)
                if affixScore then
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
                  elseif Data.db.global.showAffixColors then
                    local scoreColor = C_ChallengeMode.GetSpecificDungeonScoreRarityColor(affixScore.score)
                    if scoreColor ~= nil then
                      levelColor = scoreColor:GenerateHexColor()
                    else
                      levelColor = overallScoreColor:GenerateHexColor()
                    end
                  end
                end
              end

              AffixFrame.Text:SetText("|c" .. levelColor .. level .. "|r")
              AffixFrame.Tier:SetText(tier)
              if Data.db.global.showTiers then
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
          anchorFrame = DungeonFrame
        end
      end

      do -- Raid Rows
        for raidIndex, raid in ipairs(raids) do
          local RaidFrame = _G[CharacterColumn:GetName() .. "Raid" .. raidIndex]
          if Data.db.global.raids.enabled and (not Data.db.global.raids.modifiedInstanceOnly or raid.modifiedInstanceInfo) then
            RaidFrame:Show()
            RaidFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
            RaidFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
            anchorFrame = RaidFrame
            for difficultyIndex, difficulty in pairs(difficulties) do
              local DifficultyFrame = _G[RaidFrame:GetName() .. "Difficulty" .. difficultyIndex]
              if DifficultyFrame then
                if Data.db.global.raids.hiddenDifficulties and Data.db.global.raids.hiddenDifficulties[difficulty.id] then
                  DifficultyFrame:Hide()
                else
                  DifficultyFrame:Show()
                  DifficultyFrame:SetPoint("TOPLEFT", anchorFrame, "BOTTOMLEFT")
                  DifficultyFrame:SetPoint("TOPRIGHT", anchorFrame, "BOTTOMRIGHT")
                  anchorFrame = DifficultyFrame
                  DifficultyFrame:SetScript("OnEnter", function()
                    GameTooltip:ClearAllPoints()
                    GameTooltip:ClearLines()
                    GameTooltip:SetOwner(DifficultyFrame, "ANCHOR_RIGHT")
                    GameTooltip:SetText("Raid Progress", 1, 1, 1, 1, true);
                    GameTooltip:AddLine(format("Difficulty: |cffffffff%s|r", difficulty.short and difficulty.short or difficulty.name));
                    if character.raids.savedInstances ~= nil then
                      local savedInstance = Utils:TableFind(character.raids.savedInstances, function(savedInstance)
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
                        local savedInstance = Utils:TableFind(character.raids.savedInstances, function(savedInstance)
                          return savedInstance.difficultyID == difficulty.id and savedInstance.instanceID == raid.instanceID and savedInstance.expires > time()
                        end)
                        if savedInstance ~= nil then
                          local savedEncounter = Utils:TableFind(savedInstance.encounters, function(enc)
                            return enc.instanceEncounterID == encounter.instanceEncounterID and enc.killed == true
                          end)
                          if savedEncounter ~= nil then
                            color = GREEN_FONT_COLOR
                          end
                        end
                      end
                      GameTooltip:AddLine(encounter.name, color.r, color.g, color.b)
                    end
                    GameTooltip:Show()
                    self:SetBackgroundColor(DifficultyFrame, 1, 1, 1, 0.05)
                  end)
                  DifficultyFrame:SetScript("OnLeave", function()
                    GameTooltip:Hide()
                    self:SetBackgroundColor(DifficultyFrame, 1, 1, 1, 0)
                  end)
                  for encounterIndex, encounter in ipairs(raid.encounters) do
                    local color = {r = 1, g = 1, b = 1}
                    local alpha = 0.1
                    local EncounterFrame = _G[DifficultyFrame:GetName() .. "Encounter" .. encounterIndex]
                    if not EncounterFrame then
                      EncounterFrame = CreateFrame("Frame", "$parentEncounter" .. encounterIndex, DifficultyFrame)
                      local size = CHARACTER_WIDTH
                      size = size - Constants.sizes.padding      -- left/right cell padding
                      size = size - (raid.numEncounters - 1) * 4 -- gaps
                      size = size / raid.numEncounters           -- box sizes
                      EncounterFrame:SetPoint("LEFT", anchorFrame, encounterIndex > 1 and "RIGHT" or "LEFT", Constants.sizes.padding / 2, 0)
                      EncounterFrame:SetSize(size, Constants.sizes.row - 12)
                      self:SetBackgroundColor(EncounterFrame, 1, 1, 1, 0.1)
                    end
                    if character.raids.savedInstances then
                      local savedInstance = Utils:TableFind(character.raids.savedInstances, function(savedInstance)
                        return savedInstance.difficultyID == difficulty.id and savedInstance.instanceID == raid.instanceID and savedInstance.expires > time()
                      end)
                      if savedInstance ~= nil then
                        local savedEncounter = Utils:TableFind(savedInstance.encounters, function(enc)
                          return enc.instanceEncounterID == encounter.instanceEncounterID and enc.killed == true
                        end)
                        if savedEncounter ~= nil then
                          color = UNCOMMON_GREEN_COLOR
                          if Data.db.global.raids.colors then
                            color = difficulty.color
                          end
                          alpha = 0.5
                        end
                      end
                    end
                    self:SetBackgroundColor(EncounterFrame, color.r, color.g, color.b, alpha)
                    anchorFrame = EncounterFrame
                  end
                  anchorFrame = DifficultyFrame
                end
              end
            end
          else
            RaidFrame:Hide()
          end
        end
      end
      anchorFrame = CharacterColumn
    end
  end
end
