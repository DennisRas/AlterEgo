---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

local Core = addon.Core
local Window = addon.Window
local Utils = addon.Utils
local Constants = addon.Constants
local Data = addon.Data
local Input = addon.Input

local Module = Core:NewModule("Settings", "AceEvent-3.0")

local buttonHeight = 35
local bodyWidth = 500

function Module:OnEnable()
  self:Render()
end

---Set the active tab
---@param index number
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

---Create a Checkbox Widget
---@param options AE_WidgetOptionsCheckbox?
---@return Frame
local function CreateWidgetCheckbox(options)
  local widget = CreateFrame("Frame", "WidgetCheckbox")
  widget.config = Mixin(
    {
      checked = false,
      onChange = false,
      layout = "RIGHT",
      text = "",
      fontObject = "SystemFont_Med1",
      height = 20
    },
    options or {}
  )
  widget:EnableMouse(true)
  widget:SetHeight(widget.config.height)

  widget.text = widget:CreateFontString()
  widget.text:SetFontObject(widget.config.fontObject)
  widget.text:SetJustifyV("TOP")
  widget.text:SetJustifyH("LEFT")
  widget.text:SetSpacing(6)
  widget.text:SetTextColor(0.8, 0.8, 0.8)
  widget.text:SetText(widget.config.text)

  widget.input = Input:CreateCheckbox({
    parent = widget,
    onChange = function(value)
      if widget.config.onChange then
        widget.config.onChange(value)
      end
    end
  })
  -- widget.input:SetParent(widget)

  -- widget:SetScript("OnEnter", function()
  --   widget.input:onEnterHandler()
  -- end)
  -- widget:SetScript("OnLeave", function()
  --   widget.input:onLeaveHandler()
  -- end)
  -- widget:SetScript("OnClick", function()
  --   widget.input:onClickHandler()
  -- end)

  if widget.config.layout == "RIGHT" then
    widget.input:SetPoint("TOPRIGHT", widget, "TOPRIGHT", -5, 1)
    widget.text:SetPoint("TOPLEFT", widget, "TOPLEFT", 0, 0)
    widget.text:SetPoint("TOPRIGHT", widget.input, "TOPLEFT", -25, 0)
  else
    widget.input:SetPoint("TOPLEFT", widget, "TOPLEFT", 5, 1)
    widget.text:SetPoint("TOPLEFT", widget.input, "TOPRIGHT", 15, 0)
    widget.text:SetPoint("TOPRIGHT", widget, "TOPRIGHT", 0, 0)
  end

  -- widget:Refresh()
  return widget
end

---Create a ColorPicker widget
---@param options AE_WidgetOptionsColorPicker?
---@diagnostic disable-next-line: undefined-doc-name
---@return Button|InsecureActionButtonTemplate
local function CreateWidgetColorPicker(options)
  local widget = CreateFrame("Button", "Button", nil, "InsecureActionButtonTemplate")
  widget.config = Mixin(
    {
      value = CreateColor(0, 0, 0, 0),
      onChange = function(value) end,
      layout = "RIGHT",
      text = "",
      fontObject = "SystemFont_Med1",
      height = 20,
    },
    options or {}
  )
  widget:EnableMouse(true)
  widget:SetHeight(widget.config.height)

  widget.text = widget:CreateFontString()
  widget.text:SetFontObject(widget.config.fontObject)
  widget.text:SetJustifyV("TOP")
  widget.text:SetJustifyH("LEFT")
  widget.text:SetSpacing(6)
  widget.text:SetTextColor(0.8, 0.8, 0.8)
  widget.text:SetText(widget.config.text)

  widget.input = Input:CreateColorPicker({
    parent = widget,
    value = widget.config.value,
    onChange = function(value)
      if widget.config.onChange then
        widget.config.onChange(value)
      end
    end
  })

  widget:SetScript("OnEnter", function()
    widget.input:onEnterHandler()
  end)
  widget:SetScript("OnLeave", function()
    widget.input:onLeaveHandler()
  end)
  widget:SetScript("OnClick", function()
    widget.input:onClickHandler()
  end)

  if widget.config.layout == "RIGHT" then
    widget.input:SetPoint("TOPRIGHT", widget, "TOPRIGHT", -5, 1)
    widget.text:SetPoint("TOPLEFT", widget, "TOPLEFT", 0, 0)
    widget.text:SetPoint("TOPRIGHT", widget.input, "TOPLEFT", -25, 0)
  else
    widget.input:SetPoint("TOPLEFT", widget, "TOPLEFT", 5, 1)
    widget.text:SetPoint("TOPLEFT", widget.input, "TOPRIGHT", 15, 0)
    widget.text:SetPoint("TOPRIGHT", widget, "TOPRIGHT", 0, 0)
  end

  -- widget:Refresh()
  return widget
end

---Create a Dropdown widget
---@param options AE_WidgetOptionsDropdown?
---@diagnostic disable-next-line: undefined-doc-name
---@return Button|InsecureActionButtonTemplate
local function CreateWidgetDropdown(options)
  local widget = CreateFrame("Button", "Button", nil, "InsecureActionButtonTemplate")
  widget.config = Mixin(
    {
      items = {},
      value = "",
      onChange = false,
      text = "",
      fontObject = "SystemFont_Med1",
      height = 50
    },
    options or {}
  )
  widget:EnableMouse(true)
  widget:SetHeight(widget.config.height)

  widget.text = widget:CreateFontString()
  widget.text:SetFontObject(widget.config.fontObject)
  widget.text:SetJustifyV("TOP")
  widget.text:SetJustifyH("LEFT")
  widget.text:SetSpacing(6)
  widget.text:SetTextColor(0.8, 0.8, 0.8)
  widget.text:SetText(widget.config.text)
  widget.text:SetPoint("TOPLEFT", widget, "TOPLEFT", 0, 0)
  widget.text:SetPoint("TOPRIGHT", widget, "TOPRIGHT", 0, 0)

  widget.input = Input:CreateDropdown({
    parent = widget,
    placeholder = "You know what...",
    value = widget.config.value,
    items = widget.config.items,
    onChange = function(value)
      if widget.config.onChange then
        widget.config.onChange(value)
      end
    end
  })
  widget.input:SetPoint("TOPLEFT", widget.text, "BOTTOMLEFT", 5, -10)
  widget.input:SetPoint("TOPRIGHT", widget.text, "BOTTOMRIGHT", -5, -10)

  -- widget:SetScript("OnEnter", function()
  --   widget.input:onEnterHandler()
  -- end)
  -- widget:SetScript("OnLeave", function()
  --   widget.input:onLeaveHandler()
  -- end)
  -- widget:SetScript("OnClick", function()
  --   widget.input:onClickHandler()
  -- end)

  return widget
end

---Create a title widget
---@param options AE_WidgetOptionsTitle?
---@return Frame
local function CreateWidgetTitle(options)
  local widget = CreateFrame("Frame", "Title")
  widget.config = Mixin(
    {
      text = "",
      fontObject = "SystemFont_Huge1",
      underline = false,
      height = 20
    }, options or {}
  )
  widget:SetHeight(widget.config.height)

  widget.text = widget:CreateFontString()
  widget.text:SetPoint("TOPLEFT", widget, "TOPLEFT")
  widget.text:SetPoint("TOPRIGHT", widget, "TOPRIGHT")
  widget.text:SetFontObject(widget.config.fontObject)
  widget.text:SetFontObject(widget.config.fontObject)
  widget.text:SetText(widget.config.text)
  widget.text:SetJustifyV("TOP")
  widget.text:SetJustifyH("LEFT")

  if widget.config.underline then
    widget.line = CreateFrame("Frame", nil, widget)
    widget.line:SetPoint("BOTTOMLEFT", widget, "BOTTOMLEFT")
    widget.line:SetPoint("BOTTOMRIGHT", widget, "BOTTOMRIGHT")
    widget.line:SetHeight(1)
    Utils:SetBackgroundColor(widget.line, 1, 1, 1, 0.3)
  end

  return widget
end

---Create a Paragraph widget
---@param options AE_WidgetOptionsParagraph?
---@return Frame
local function CreateWidgetParagraph(options)
  local widget = CreateFrame("Frame", "Paragraph")
  widget.config = Mixin(
    {
      text = "",
      fontObject = "SystemFont_Med1",
      height = 20
    }, options or {}
  )
  widget:SetHeight(widget.config.height)

  widget.text = widget:CreateFontString()
  widget.text:SetPoint("TOPLEFT", widget, "TOPLEFT")
  widget.text:SetPoint("TOPRIGHT", widget, "TOPRIGHT")
  widget.text:SetFontObject(widget.config.fontObject)
  widget.text:SetText(widget.config.text)
  widget.text:SetJustifyV("TOP")
  widget.text:SetJustifyH("LEFT")
  widget.text:SetSpacing(6)
  widget.text:SetTextColor(0.8, 0.8, 0.8)

  return widget
end

---Create a Line widget
---@param options AE_WidgetOptionsLine?
---@return Frame
local function CreateWidgetLine(options)
  local widget = CreateFrame("Frame", "Line")
  widget.config = Mixin(
    {
      height = 1,
      padding = 10,
    }, options or {}
  )
  widget:SetHeight(widget.config.padding * 2)

  widget.line = CreateFrame("Frame", nil, widget)
  widget.line:SetPoint("LEFT", widget, "LEFT")
  widget.line:SetPoint("RIGHT", widget, "RIGHT")
  widget.line:SetHeight(widget.config.height)
  Utils:SetBackgroundColor(widget.line, 1, 1, 1, 0.3)

  return widget
end

local function CreateWidgetLayout(options)
  local container = CreateFrame("Frame", "WidgetContainer")
  container.config = Mixin(
    {}, options or {}
  )
  container.widgets = {}

  function container:Update()
    local height = 0
    Utils:TableForEach(container.widgets, function(widget, i)
      widget:SetParent(container)
      widget:SetPoint("TOPLEFT", container, "TOPLEFT", 0, -height)
      widget:SetPoint("TOPRIGHT", container, "TOPRIGHT", 0, -height)
      -- Utils:SetBackgroundColor(widget, math.random(1, 255) / 255, math.random(1, 255) / 255, math.random(1, 255) / 255, 0.2)
      -- if widget.text then
      --   widget:SetHeight(math.max(widget.text:GetHeight(), 20))
      -- end
      height = height + widget:GetHeight() + 15
    end)
    container:SetHeight(height)
  end

  -- C_Timer.After(0, function()
  --   widgetLayout:Update()
  --   scrollFrame.content:SetHeight(widgetLayout:GetHeight() + 15)
  -- end)

  function container:AddWidget(widget)
    table.insert(container.widgets, widget)
    container:Update()
  end

  return container
end

function Module:Render()
  if not self.window then
    self.window = Window:New({
      name = "Settings",
      title = "Settings",
      sidebar = 150,
    })

    self.tabs = {}
    self.window.sidebar.tabs = {}
    self.tabSelected = 1

    do
      local scrollFrame = Utils:CreateScrollFrame("$parentTabGeneral", self.window.body)
      scrollFrame.content:SetSize(scrollFrame:GetSize())
      scrollFrame.content.widgetLayout = CreateWidgetLayout()
      scrollFrame.content.widgetLayout:SetParent(scrollFrame.content)
      scrollFrame.content.widgetLayout:SetPoint("TOPLEFT", scrollFrame.content, "TOPLEFT", 15, -15)
      scrollFrame.content.widgetLayout:SetPoint("TOPRIGHT", scrollFrame.content, "TOPRIGHT", -15, -15)
      scrollFrame.content.widgetLayout:AddWidget(CreateWidgetTitle({
        text = "General",
      }))
      scrollFrame.content.widgetLayout:AddWidget(CreateWidgetTitle({
        text = "Show Weekly AFfixes",
        fontObject = "SystemFont_Med2",
        height = 15,
      }))
      scrollFrame.content.widgetLayout:AddWidget(CreateWidgetCheckbox({
        text = "The weekly affixes will be shown at the top of the main window.",
        checked = Data.db.global.showAffixHeader,
        onChange = function(checked)
          Data.db.global.showAffixHeader = checked
          Module:SendMessage("AE_SETTINGS_UPDATED")
        end,
      }))
      scrollFrame.content.widgetLayout:AddWidget(CreateWidgetColorPicker({
        text = "Sed cursus justo sit amet ante pulvinar volutpat. Nullam mauris purus, varius ut facilisis nec",
        height = 35,
        onChange = function(checked)
          Module:SendMessage("AE_SETTINGS_UPDATED")
        end,
      }))
      local items = {}
      for i = 1, 20 do
        table.insert(items, {
          value = i,
          text = "Option " .. i,
          icon = i > 2 and i < 10 and 626000 + (i - 5) or nil
        })
      end
      scrollFrame.content.widgetLayout:AddWidget(CreateWidgetDropdown({
        text = "Hello there!",
        items = items,
        onChange = function(value)
          Module:SendMessage("AE_SETTINGS_UPDATED")
        end
      }))
      scrollFrame.content.widgetLayout:AddWidget(CreateWidgetLine())
      scrollFrame.content.widgetLayout:AddWidget(CreateWidgetParagraph({
        text = "Maecenas non scelerisque felis. In quam diam, pretium molestie tristique sed, molestie at ex. Maecenas tempus, enim eu finibus tincidunt, ex purus varius nulla, a ornare risus enim in augue. Maecenas blandit, odio vitae tempus gravida, nunc enim venenatis lacus, non luctus lorem turpis blandit diam. Aliquam erat volutpat. Sed porta sodales luctus. Suspendisse hendrerit pharetra urna nec convallis.",
        height = 115,
      }))
      scrollFrame.content.widgetLayout:AddWidget(CreateWidgetParagraph({
        text = "Sed cursus justo sit amet ante pulvinar volutpat. Nullam mauris purus, varius ut facilisis nec, facilisis ut tortor. Morbi eget hendrerit lorem, non luctus tellus. Nullam dictum auctor ultricies. Sed sit amet augue dapibus, eleifend massa ac, aliquet tellus. Nullam et volutpat purus, in pellentesque urna. Cras at nibh fringilla, efficitur lacus ut, finibus nunc. Maecenas facilisis volutpat ligula ut vestibulum. Fusce eu urna gravida, elementum neque at, luctus diam. Maecenas et pulvinar ipsum. Sed vitae velit elit. Nulla rutrum condimentum est. Duis vitae purus eget elit suscipit posuere. Curabitur quis urna diam. Proin dapibus sapien ipsum, vitae rutrum ligula bibendum sit amet.",
        height = 150,
      }))

      scrollFrame.content.widgetLayout:SetScript("OnSizeChanged", function()
        scrollFrame.content:SetHeight(scrollFrame.content.widgetLayout:GetHeight() + 15)
      end)
      table.insert(self.tabs, {
        text = "General",
        frame = scrollFrame
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
