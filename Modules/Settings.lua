---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

local Core = addon.Core
local Window = addon.Window
local Utils = addon.Utils
local Constants = addon.Constants

local Module = Core:NewModule("Settings", "AceEvent-3.0")

local buttonHeight = 35

function Module:OnEnable()
  self:Render()
end

function Module:Render()
  if not self.window then
    self.window = Window:New({
      name = "Settings",
      title = "Settings",
      sidebar = true
    })
    self.window.body.tabs = {}
    self.window.sidebar.tabs = {}
    self.window.selectedTab = 1
    self.window:SetBodySize(500, 400)

    local frameGeneral = CreateFrame("Frame", nil, self.window.body)
    frameGeneral.title = frameGeneral:CreateFontString()
    frameGeneral.title:SetPoint("TOPLEFT", frameGeneral, "TOPLEFT", 15, -15)
    frameGeneral.title:SetFontObject("SystemFont_Med3")
    frameGeneral.title:SetText("General")
    table.insert(self.window.body.tabs, {
      text = "General",
      frame = frameGeneral
    })

    local frameCharacters = CreateFrame("Frame", nil, self.window.body)
    frameCharacters.title = frameCharacters:CreateFontString()
    frameCharacters.title:SetPoint("TOPLEFT", frameCharacters, "TOPLEFT", 15, -15)
    frameCharacters.title:SetFontObject("SystemFont_Med3")
    frameCharacters.title:SetText("Characters")
    table.insert(self.window.body.tabs, {
      text = "Characters",
      frame = frameCharacters
    })

    local frameDungeons = CreateFrame("Frame", nil, self.window.body)
    frameDungeons.title = frameDungeons:CreateFontString()
    frameDungeons.title:SetPoint("TOPLEFT", frameDungeons, "TOPLEFT", 15, -15)
    frameDungeons.title:SetFontObject("SystemFont_Med3")
    frameDungeons.title:SetText("Dungeons")
    table.insert(self.window.body.tabs, {
      text = "Dungeons",
      frame = frameDungeons
    })

    local frameRaids = CreateFrame("Frame", nil, self.window.body)
    frameRaids.title = frameRaids:CreateFontString()
    frameRaids.title:SetPoint("TOPLEFT", frameRaids, "TOPLEFT", 15, -15)
    frameRaids.title:SetFontObject("SystemFont_Med3")
    frameRaids.title:SetText("Raids")
    table.insert(self.window.body.tabs, {
      text = "Raids",
      frame = frameRaids
    })

    local framePvP = CreateFrame("Frame", nil, self.window.body)
    framePvP.title = framePvP:CreateFontString()
    framePvP.title:SetPoint("TOPLEFT", framePvP, "TOPLEFT", 15, -15)
    framePvP.title:SetFontObject("SystemFont_Med3")
    framePvP.title:SetText("PvP")
    table.insert(self.window.body.tabs, {
      text = "PvP",
      frame = framePvP
    })

    local frameDungeonTimer = CreateFrame("Frame", nil, self.window.body)
    frameDungeonTimer.title = frameDungeonTimer:CreateFontString()
    frameDungeonTimer.title:SetPoint("TOPLEFT", frameDungeonTimer, "TOPLEFT", 15, -15)
    frameDungeonTimer.title:SetFontObject("SystemFont_Med3")
    frameDungeonTimer.title:SetText("Dungeon Timer")
    table.insert(self.window.body.tabs, {
      text = "Dungeon Timer",
      frame = frameDungeonTimer
    })

    local frameRunHistory = CreateFrame("Frame", nil, self.window.body)
    frameRunHistory.title = frameRunHistory:CreateFontString()
    frameRunHistory.title:SetPoint("TOPLEFT", frameRunHistory, "TOPLEFT", 15, -15)
    frameRunHistory.title:SetFontObject("SystemFont_Med3")
    frameRunHistory.title:SetText("Run History")
    table.insert(self.window.body.tabs, {
      text = "Run History",
      frame = frameRunHistory
    })

    local frameKeyManager = CreateFrame("Frame", nil, self.window.body)
    frameKeyManager.title = frameKeyManager:CreateFontString()
    frameKeyManager.title:SetPoint("TOPLEFT", frameKeyManager, "TOPLEFT", 15, -15)
    frameKeyManager.title:SetFontObject("SystemFont_Med3")
    frameKeyManager.title:SetText("Key Manager")
    table.insert(self.window.body.tabs, {
      text = "Key Manager",
      frame = frameKeyManager
    })

    local frameAnnouncements = CreateFrame("Frame", nil, self.window.body)
    frameAnnouncements.title = frameAnnouncements:CreateFontString()
    frameAnnouncements.title:SetPoint("TOPLEFT", frameAnnouncements, "TOPLEFT", 15, -15)
    frameAnnouncements.title:SetFontObject("SystemFont_Med3")
    frameAnnouncements.title:SetText("Announcements")
    table.insert(self.window.body.tabs, {
      text = "Announcements",
      frame = frameAnnouncements
    })

    local frameThemes = CreateFrame("Frame", nil, self.window.body)
    frameThemes.title = frameThemes:CreateFontString()
    frameThemes.title:SetPoint("TOPLEFT", frameThemes, "TOPLEFT", 15, -15)
    frameThemes.title:SetFontObject("SystemFont_Med3")
    frameThemes.title:SetText("Fonts & Colors")
    table.insert(self.window.body.tabs, {
      text = "Fonts & Colors",
      frame = frameThemes
    })

    local frameChangelog = CreateFrame("Frame", nil, self.window.body)
    frameChangelog.title = frameChangelog:CreateFontString()
    frameChangelog.title:SetPoint("TOPLEFT", frameChangelog, "TOPLEFT", 15, -15)
    frameChangelog.title:SetFontObject("SystemFont_Med3")
    frameChangelog.title:SetText("Changelog")
    table.insert(self.window.body.tabs, {
      text = "Changelog",
      frame = frameChangelog
    })

    local frameAbout = CreateFrame("Frame", nil, self.window.body)
    frameAbout.title = frameAbout:CreateFontString()
    frameAbout.title:SetPoint("TOPLEFT", frameAbout, "TOPLEFT", 15, -15)
    frameAbout.title:SetFontObject("SystemFont_Med3")
    frameAbout.title:SetText("About")
    table.insert(self.window.body.tabs, {
      text = "About",
      frame = frameAbout
    })


    local offsetY = 0
    local offsetX = 0
    Utils:TableForEach(self.window.body.tabs, function(tab, i)
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
        if self.window.selectedTab == i then return end
        Utils:SetBackgroundColor(tabButton, 1, 1, 1, 0.02)
      end)
      tabButton:SetScript("OnLeave", function()
        if self.window.selectedTab == i then return end
        Utils:SetBackgroundColor(tabButton, 1, 1, 1, 0)
      end)
      tabButton:SetScript("OnClick", function()
        self.window.selectedTab = i
        self:Render()
      end)
      table.insert(self.window.sidebar.tabs, tabButton)
      offsetY = offsetY + buttonHeight
    end)
  end

  Utils:TableForEach(self.window.body.tabs, function(tab, i)
    tab.frame:Hide()
    if self.window.selectedTab == i then
      tab.frame:Show()
    end
  end)
  Utils:TableForEach(self.window.sidebar.tabs, function(tabButton, i)
    Utils:SetBackgroundColor(tabButton, 1, 1, 1, 0)
    tabButton.text:SetTextColor(1, 1, 1, 0.8)
    tabButton.border:Hide()
    if self.window.selectedTab == i then
      Utils:SetBackgroundColor(tabButton, 1, 1, 1, 0.06)
      tabButton.text:SetTextColor(1, 1, 1, 1)
      tabButton.border:Show()
    end
  end)

  self.window:SetBodySize(500, buttonHeight * Utils:TableCount(self.window.sidebar.tabs))
  self.window:Show()
end
