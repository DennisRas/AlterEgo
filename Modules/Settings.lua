---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

local Core = addon.Core
local Window = addon.Window
local Utils = addon.Utils
local Constants = addon.Constants
local Data = addon.Data

local Module = Core:NewModule("Settings", "AceEvent-3.0")

local buttonHeight = 35
local bodyWidth = 500

function Module:OnEnable()
  self:Render()
end

function Module:SetTab(index)
  self.tabSelected = index
  Utils:TableForEach(self.tabs, function(tab, i)
    tab.frame:Hide()
    Utils:SetBackgroundColor(tab.button, 1, 1, 1, 0)
    tab.button.text:SetTextColor(1, 1, 1, 0.8)
    tab.button.border:Hide()

    if self.tabSelected == i then
      tab.frame:Show()
      tab.button.text:SetTextColor(1, 1, 1, 1)
      tab.button.border:Show()
      Utils:SetBackgroundColor(tab.button, 1, 1, 1, 0.06)
    end
  end)
  self:Render()
end

local function CreateCheckbox(options)
  local defaultOptions = {
    layout = "RIGHT",
    text = "",
    checked = false,
    onChange = false
  }
  options = Mixin(defaultOptions, options)

  local widget = CreateFrame("Button", options.parent and "$parentCheckbox" or nil, options.parent or UIParent, "InsecureActionButtonTemplate")
  widget:RegisterForClicks("AnyUp")
  widget:EnableMouse(true)
  widget.options = options
  widget.text = widget:CreateFontString()
  widget.text:SetFontObject("SystemFont_Med1")
  widget.text:SetJustifyV("TOP")
  widget.text:SetJustifyH("LEFT")
  widget.text:SetSpacing(6)
  widget.text:SetTextColor(0.8, 0.8, 0.8)
  widget.text:SetText(options.text)
  widget.input = CreateFrame("Frame", "Input", widget)
  widget.input:SetSize(20, 20)

  widget.input.border = CreateFrame("Frame", "Border", widget)
  widget.input.border:SetFrameStrata("LOW")
  widget.input.border:SetPoint("TOPLEFT", widget.input, "TOPLEFT", -1, 1)
  widget.input.border:SetPoint("TOPRIGHT", widget.input, "TOPRIGHT", 1, 1)
  widget.input.border:SetPoint("BOTTOMRIGHT", widget.input, "BOTTOMRIGHT", 1, -1)
  widget.input.border:SetPoint("BOTTOMLEFT", widget.input, "BOTTOMLEFT", -1, -1)

  Utils:SetBackgroundColor(widget.input, 0.1, 0.1, 0.1, 1)
  Utils:SetBackgroundColor(widget.input.border, 1, 1, 1, 0.2)

  widget:SetScript("OnEnter", function()
    Utils:SetBackgroundColor(widget.input.border, 1, 1, 1, 0.3)
    if widget.options.checked then return end
    -- Utils:SetBackgroundColor(widget.input, 0.15, 0.15, 0.15, 1)
  end)
  widget:SetScript("OnLeave", function()
    Utils:SetBackgroundColor(widget.input.border, 1, 1, 1, 0.2)
    if widget.options.checked then return end
    -- Utils:SetBackgroundColor(widget.input, 0.1, 0.1, 0.1, 1)
  end)
  widget:SetScript("OnClick", function()
    widget.options.checked = not widget.options.checked
    if widget.options.onChange then
      widget.options.onChange(widget.options.checked)
    end
    widget:Refresh()
  end)

  if options.layout == "RIGHT" then
    widget.input:SetPoint("TOPRIGHT", widget, "TOPRIGHT", -5, 0)
    widget.text:SetPoint("TOPLEFT", widget, "TOPLEFT", 0, 0)
    widget.text:SetPoint("TOPRIGHT", widget.input, "TOPLEFT", -25, 0)
  else
    widget.input:SetPoint("TOPLEFT", widget, "TOPLEFT", 5, 0)
    widget.text:SetPoint("TOPLEFT", widget.input, "TOPRIGHT", 15, 0)
    widget.text:SetPoint("TOPRIGHT", widget, "TOPRIGHT", 0, 0)
  end

  function widget:Refresh()
    if widget.options.checked then
      Utils:SetBackgroundColor(widget.input, 0, 0.3, 0, 1)
    else
      Utils:SetBackgroundColor(widget.input, 0.1, 0.1, 0.1, 1)
      -- Utils:SetBackgroundColor(widget.input, 0.15, 0.15, 0.15, 1)
    end
  end

  widget:SetHeight(60)
  widget:Refresh()
  return widget
end

function Module:Render()
  if not self.window then
    self.window = Window:New({
      name = "Settings",
      title = "Settings",
      sidebar = true
    })

    self.tabs = {}
    self.window.sidebar.tabs = {}
    self.tabSelected = 1

    do
      local frameGeneral = Window:CreateScrollFrame("$parentTabGeneral", self.window.body)
      frameGeneral.content:SetSize(bodyWidth, 530)
      local title = frameGeneral.content:CreateFontString()
      title:SetPoint("TOPLEFT", frameGeneral.content, "TOPLEFT", 15, -15)
      title:SetPoint("TOPRIGHT", frameGeneral.content, "TOPRIGHT", -15, -15)
      title:SetFontObject("SystemFont_Huge1")
      title:SetText("General")
      title:SetJustifyV("TOP")
      title:SetJustifyH("LEFT")
      local introduction = frameGeneral.content:CreateFontString()
      introduction:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -15)
      introduction:SetPoint("TOPRIGHT", title, "BOTTOMRIGHT", 0, -15)
      introduction:SetFontObject("SystemFont_Med1")
      introduction:SetText("Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed facilisis id eros ac lacinia. Morbi non consequat magna. Nam consequat placerat orci nec vestibulum.")
      introduction:SetJustifyV("TOP")
      introduction:SetJustifyH("LEFT")
      introduction:SetSpacing(6)
      introduction:SetTextColor(0.8, 0.8, 0.8)
      local line = CreateFrame("Frame", nil, frameGeneral.content)
      line:SetPoint("TOPLEFT", introduction, "BOTTOMLEFT", 0, -30)
      line:SetPoint("TOPRIGHT", introduction, "BOTTOMRIGHT", 0, -30)
      line:SetHeight(1)
      Utils:SetBackgroundColor(line, 1, 1, 1, 0.3)
      local weeklyAffixesTitle = frameGeneral.content:CreateFontString()
      weeklyAffixesTitle:SetPoint("TOPLEFT", line, "BOTTOMLEFT", 0, -30)
      weeklyAffixesTitle:SetPoint("TOPRIGHT", line, "BOTTOMRIGHT", 0, -30)
      weeklyAffixesTitle:SetFontObject("SystemFont_Med2")
      weeklyAffixesTitle:SetText("Show Weekly AFfixes")
      weeklyAffixesTitle:SetJustifyV("TOP")
      weeklyAffixesTitle:SetJustifyH("LEFT")
      weeklyAffixesTitle:SetSpacing(6)
      -- local weeklyAffixesDescription = frameGeneral.content:CreateFontString()
      -- weeklyAffixesDescription:SetPoint("TOPLEFT", weeklyAffixesTitle, "BOTTOMLEFT", 0, -15)
      -- weeklyAffixesDescription:SetPoint("TOPRIGHT", weeklyAffixesTitle, "BOTTOMRIGHT", 0, -15)
      -- weeklyAffixesDescription:SetFontObject("SystemFont_Med1")
      -- weeklyAffixesDescription:SetText("The weekly affixes will be shown at the top of the main window. Sed facilisis id eros ac lacinia. Morbi non consequat magna. Nam consequat placerat orci nec vestibulum.")
      -- weeklyAffixesDescription:SetJustifyV("TOP")
      -- weeklyAffixesDescription:SetJustifyH("LEFT")
      -- weeklyAffixesDescription:SetSpacing(6)
      -- weeklyAffixesDescription:SetTextColor(0.8, 0.8, 0.8)
      -- local weeklyAffixesCheckbox = CreateFrame("CheckButton", nil, frameGeneral.content, "ChatConfigCheckButtonTemplate")
      -- weeklyAffixesCheckbox:SetPoint("TOPRIGHT", weeklyAffixesTitle, "TOPRIGHT", 0, 0)
      -- weeklyAffixesCheckbox.Text:SetText("CheckBox Name")
      -- weeklyAffixesCheckbox.tooltip = "This is where you place MouseOver Text."
      local weeklyAffixesOption = CreateCheckbox({
        parent = frameGeneral.content,
        checked = Data.db.global.showAffixHeader,
        onChange = function(checked)
          Data.db.global.showAffixHeader = checked
          Module:SendMessage("AE_SETTINGS_UPDATED")
        end,
        text = "The weekly affixes will be shown at the top of the main window. Sed facilisis id eros ac lacinia. Morbi non consequat magna. Nam consequat placerat orci nec vestibulum."
      })
      weeklyAffixesOption:SetPoint("TOPLEFT", weeklyAffixesTitle, "BOTTOMLEFT", 0, -15)
      weeklyAffixesOption:SetPoint("TOPRIGHT", weeklyAffixesTitle, "BOTTOMRIGHT", 0, -15)
      local showCharacters = CreateCheckbox({
        parent = frameGeneral.content,
        checked = false,
        onChange = function(checked)
          Module:SendMessage("AE_SETTINGS_UPDATED")
        end,
        text = "Phasellus tincidunt felis quam, vitae elementum odio porttitor vel. Etiam ut nisl mi. Proin dignissim rutrum nunc, at lobortis enim. Sed mi lectus, pharetra ac scelerisque at, faucibus non neque."
      })
      showCharacters:SetPoint("TOPLEFT", weeklyAffixesOption, "BOTTOMLEFT", 0, -15)
      showCharacters:SetPoint("TOPRIGHT", weeklyAffixesOption, "BOTTOMRIGHT", 0, -15)

      local anotherTitle = frameGeneral.content:CreateFontString()
      anotherTitle:SetPoint("TOPLEFT", showCharacters, "BOTTOMLEFT", 0, -15)
      anotherTitle:SetPoint("TOPRIGHT", showCharacters, "BOTTOMRIGHT", 0, -15)
      anotherTitle:SetFontObject("SystemFont_Med2")
      anotherTitle:SetText("Another feature here")
      anotherTitle:SetJustifyV("TOP")
      anotherTitle:SetJustifyH("LEFT")
      anotherTitle:SetSpacing(6)
      local second = CreateCheckbox({
        parent = frameGeneral.content,
        checked = false,
        layout = "LEFT",
        onChange = function(checked)
          Module:SendMessage("AE_SETTINGS_UPDATED")
        end,
        text = "Phasellus tincidunt felis quam, vitae elementum odio porttitor vel. Etiam ut nisl mi. Proin dignissim rutrum nunc, at lobortis enim. Sed mi lectus, pharetra ac scelerisque at, faucibus non neque."
      })
      second:SetPoint("TOPLEFT", anotherTitle, "BOTTOMLEFT", 0, -15)
      second:SetPoint("TOPRIGHT", anotherTitle, "BOTTOMRIGHT", 0, -15)
      local third = CreateCheckbox({
        parent = frameGeneral.content,
        checked = false,
        layout = "LEFT",
        onChange = function(checked)
          Module:SendMessage("AE_SETTINGS_UPDATED")
        end,
        text = "Mauris condimentum gravida odio, quis fermentum nulla facilisis quis. Integer in sem eget mauris maximus euismod. Aenean sed ante et dolor maximus."
      })
      third:SetPoint("TOPLEFT", second, "BOTTOMLEFT", 0, -15)
      third:SetPoint("TOPRIGHT", second, "BOTTOMRIGHT", 0, -15)

      table.insert(self.tabs, {
        text = "General",
        frame = frameGeneral
      })
    end

    local frameCharacters = CreateFrame("Frame", nil, self.window.body)
    frameCharacters.title = frameCharacters:CreateFontString()
    frameCharacters.title:SetPoint("TOPLEFT", frameCharacters, "TOPLEFT", 15, -15)
    frameCharacters.title:SetFontObject("SystemFont_Med3")
    frameCharacters.title:SetText("Characters")
    frameCharacters.title:SetJustifyH("LEFT")
    table.insert(self.tabs, {
      text = "Characters",
      frame = frameCharacters
    })

    local frameDungeons = CreateFrame("Frame", nil, self.window.body)
    frameDungeons.title = frameDungeons:CreateFontString()
    frameDungeons.title:SetPoint("TOPLEFT", frameDungeons, "TOPLEFT", 15, -15)
    frameDungeons.title:SetPoint("TOPRIGHT", frameDungeons, "TOPRIGHT", -15, -15)
    frameDungeons.title:SetHeight(50)
    frameDungeons.title:SetFontObject("SystemFont_Med3")
    frameDungeons.title:SetText("Dungeons")
    frameDungeons.title:SetJustifyH("LEFT")
    table.insert(self.tabs, {
      text = "Dungeons",
      frame = frameDungeons
    })

    local frameRaids = CreateFrame("Frame", nil, self.window.body)
    frameRaids.title = frameRaids:CreateFontString()
    frameRaids.title:SetPoint("TOPLEFT", frameRaids, "TOPLEFT", 15, -15)
    frameRaids.title:SetFontObject("SystemFont_Med3")
    frameRaids.title:SetText("Raids")
    frameRaids.title:SetJustifyH("LEFT")
    table.insert(self.tabs, {
      text = "Raids",
      frame = frameRaids
    })

    local framePvP = CreateFrame("Frame", nil, self.window.body)
    framePvP.title = framePvP:CreateFontString()
    framePvP.title:SetPoint("TOPLEFT", framePvP, "TOPLEFT", 15, -15)
    framePvP.title:SetFontObject("SystemFont_Med3")
    framePvP.title:SetText("PvP")
    framePvP.title:SetJustifyH("LEFT")
    table.insert(self.tabs, {
      text = "PvP",
      frame = framePvP
    })

    local frameDungeonTimer = CreateFrame("Frame", nil, self.window.body)
    frameDungeonTimer.title = frameDungeonTimer:CreateFontString()
    frameDungeonTimer.title:SetPoint("TOPLEFT", frameDungeonTimer, "TOPLEFT", 15, -15)
    frameDungeonTimer.title:SetFontObject("SystemFont_Med3")
    frameDungeonTimer.title:SetText("Dungeon Timer")
    frameDungeonTimer.title:SetJustifyH("LEFT")
    table.insert(self.tabs, {
      text = "Dungeon Timer",
      frame = frameDungeonTimer
    })

    local frameRunHistory = CreateFrame("Frame", nil, self.window.body)
    frameRunHistory.title = frameRunHistory:CreateFontString()
    frameRunHistory.title:SetPoint("TOPLEFT", frameRunHistory, "TOPLEFT", 15, -15)
    frameRunHistory.title:SetFontObject("SystemFont_Med3")
    frameRunHistory.title:SetText("Run History")
    frameRunHistory.title:SetJustifyH("LEFT")
    table.insert(self.tabs, {
      text = "Run History",
      frame = frameRunHistory
    })

    local frameKeyManager = CreateFrame("Frame", nil, self.window.body)
    frameKeyManager.title = frameKeyManager:CreateFontString()
    frameKeyManager.title:SetPoint("TOPLEFT", frameKeyManager, "TOPLEFT", 15, -15)
    frameKeyManager.title:SetFontObject("SystemFont_Med3")
    frameKeyManager.title:SetText("Key Manager")
    frameKeyManager.title:SetJustifyH("LEFT")
    table.insert(self.tabs, {
      text = "Key Manager",
      frame = frameKeyManager
    })

    local frameAnnouncements = CreateFrame("Frame", nil, self.window.body)
    frameAnnouncements.title = frameAnnouncements:CreateFontString()
    frameAnnouncements.title:SetPoint("TOPLEFT", frameAnnouncements, "TOPLEFT", 15, -15)
    frameAnnouncements.title:SetFontObject("SystemFont_Med3")
    frameAnnouncements.title:SetText("Announcements")
    frameAnnouncements.title:SetJustifyH("LEFT")
    table.insert(self.tabs, {
      text = "Announcements",
      frame = frameAnnouncements
    })

    local frameThemes = CreateFrame("Frame", nil, self.window.body)
    frameThemes.title = frameThemes:CreateFontString()
    frameThemes.title:SetPoint("TOPLEFT", frameThemes, "TOPLEFT", 15, -15)
    frameThemes.title:SetFontObject("SystemFont_Med3")
    frameThemes.title:SetText("Fonts & Colors")
    frameThemes.title:SetJustifyH("LEFT")
    table.insert(self.tabs, {
      text = "Fonts & Colors",
      frame = frameThemes
    })

    local frameChangelog = CreateFrame("Frame", nil, self.window.body)
    frameChangelog.title = frameChangelog:CreateFontString()
    frameChangelog.title:SetPoint("TOPLEFT", frameChangelog, "TOPLEFT", 15, -15)
    frameChangelog.title:SetFontObject("SystemFont_Med3")
    frameChangelog.title:SetText("Changelog")
    frameChangelog.title:SetJustifyH("LEFT")
    table.insert(self.tabs, {
      text = "Changelog",
      frame = frameChangelog
    })

    local frameAbout = CreateFrame("Frame", nil, self.window.body)
    frameAbout.title = frameAbout:CreateFontString()
    frameAbout.title:SetPoint("TOPLEFT", frameAbout, "TOPLEFT", 15, -15)
    frameAbout.title:SetFontObject("SystemFont_Med3")
    frameAbout.title:SetText("About")
    frameAbout.title:SetJustifyH("LEFT")
    table.insert(self.tabs, {
      text = "About",
      frame = frameAbout
    })


    local offsetY = 0
    local offsetX = 0
    Utils:TableForEach(self.tabs, function(tab, i)
      local tabButton = CreateFrame("Button", "$parentTab" .. i, self.window.sidebar, "InsecureActionButtonTemplate")
      tabButton:RegisterForClicks("AnyUp", "AnyDown")
      tabButton:EnableMouse(true)
      tabButton:SetPoint("TOPLEFT", self.window.sidebar, "TOPLEFT", offsetX, -offsetY)
      tabButton:SetPoint("TOPRIGHT", self.window.sidebar, "TOPRIGHT", -offsetX, -offsetY)
      tabButton:SetHeight(buttonHeight)
      tabButton.text = tabButton:CreateFontString(tabButton:GetName() .. "Text", "OVERLAY")
      tabButton.text:SetPoint("LEFT", tabButton, "LEFT", Constants.sizes.padding * 1.5, 0)
      tabButton.text:SetJustifyH("LEFT")
      tabButton.text:SetFontObject("GameFontHighlight_NoShadow")
      tabButton.text:SetText(tab.text)
      tabButton.border = CreateFrame("Frame", "$parentBorder", tabButton)
      tabButton.border:SetPoint("TOPLEFT", tabButton, "TOPLEFT", 0, 0)
      tabButton.border:SetPoint("BOTTOMLEFT", tabButton, "BOTTOMLEFT", 0, 0)
      tabButton.border:SetWidth(Constants.sizes.padding / 3)
      tabButton.border:Hide()
      Utils:SetBackgroundColor(tabButton.border, Constants.colors.primary.r, Constants.colors.primary.g, Constants.colors.primary.b, 0.6)
      tabButton:SetScript("OnEnter", function()
        if self.tabSelected == i then return end
        Utils:SetBackgroundColor(tabButton, 1, 1, 1, 0.02)
      end)
      tabButton:SetScript("OnLeave", function()
        if self.tabSelected == i then return end
        Utils:SetBackgroundColor(tabButton, 1, 1, 1, 0)
      end)
      tabButton:SetScript("OnClick", function()
        self:SetTab(i)
      end)
      self.tabs[i].button = tabButton
      -- table.insert(self.window.sidebar.tabs, tabButton)
      offsetY = offsetY + buttonHeight
    end)

    self:SetTab(1)
  end

  self.window:SetBodySize(bodyWidth, buttonHeight * Utils:TableCount(self.tabs))
  self.window:Show()
end
