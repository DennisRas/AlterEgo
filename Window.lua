---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

local TITLEBAR_HEIGHT = 30
local FOOTER_HEIGHT = 16
-- local SIDEBAR_WIDTH = 150

---@class AE_WindowManager
local Window = {}
addon.Window = Window
Window.windows = {}

---Create a window frame
---@param options AE_WindowOptions
---@return AE_Window
function Window:New(options)
  ---@type AE_Window
  local window = CreateFrame("Frame", addonName .. "Window" .. (options and options.name or addon.Utils:TableCount(self.windows) + 1), options.parent or UIParent)
  ---@type AE_WindowOptions
  local defaultWindowOptions = {
    parent = UIParent,
    name = "",
    title = "",
    border = addon.Constants.sizes.border,
    titlebar = true,
    windowScale = 100,
    windowColor = {r = 0.11372549019, g = 0.14117647058, b = 0.16470588235, a = 1},
    point = {"CENTER"},
  }
  local mergedWindowOptions = {}
  addon.Utils:TableMergeConfig(mergedWindowOptions, defaultWindowOptions)
  addon.Utils:TableMergeConfig(mergedWindowOptions, options or {})
  window.config = mergedWindowOptions
  window:SetFrameStrata("MEDIUM")
  window:SetFrameLevel(3000)
  window:SetToplevel(true)
  window:SetMovable(true)
  window:SetPoint(unpack(window.config.point))
  window:SetSize(window.config.width or 300, window.config.height or 300)
  window:EnableMouse(true) -- Disable click-throughs
  window:SetParent(window.config.parent)
  window:SetClampedToScreen(true)
  window:SetClampRectInsets(window:GetWidth() / 2, window:GetWidth() / -2, 0, window:GetHeight() / 2)
  window:SetScript("OnSizeChanged", function()
    window:SetClampRectInsets(window:GetWidth() / 2, window:GetWidth() / -2, 0, window:GetHeight() / 2)
  end)
  addon.Utils:SetBackgroundColor(window, window.config.windowColor.r, window.config.windowColor.g, window.config.windowColor.b, window.config.windowColor.a)

  ---Show or hide the window
  ---@param state boolean?
  function window:Toggle(state)
    if state == nil then
      state = not window:IsVisible()
    end
    window:SetShown(state)
  end

  ---Set the title of the window
  ---@param title string
  function window:SetTitle(title)
    if not window.config.titlebar then return end
    window.titlebar.title:SetText(title)
  end

  ---Set body size and adjust window size
  ---@param width number
  ---@param height number
  function window:SetBodySize(width, height)
    local w = width
    local h = height
    if window.config.sidebar then
      w = w + window.config.sidebar
    end
    if window.config.titlebar then
      h = h + TITLEBAR_HEIGHT
    end
    window:SetSize(w, h)
  end

  if window.config.width and window.config.height then
    window:SetBodySize(window.config.width, window.config.height)
  end

  ---Add a button to the titlebar
  ---@param buttonConfig AE_TitlebarButton
  ---@return Frame
  function window:AddTitlebarButton(buttonConfig)
    if not window.titlebar then
      error("Cannot add titlebar button: window has no titlebar")
    end

    local buttonName = buttonConfig.name
    if window.titlebarButtons[buttonName] then
      error("Button with name '" .. buttonName .. "' already exists")
    end

    local buttonSize = buttonConfig.size or TITLEBAR_HEIGHT
    local iconSize = buttonConfig.iconSize or 12
    local isEnabled = buttonConfig.enabled ~= false

    -- Create the button frame
    local button
    if buttonConfig.setupMenu then
      -- Create dropdown button
      button = CreateFrame("DropdownButton", "$parent" .. buttonName, window.titlebar)
      button:SetupMenu(buttonConfig.setupMenu)
    else
      -- Create regular button
      button = CreateFrame("Button", "$parent" .. buttonName, window.titlebar)
      button:RegisterForClicks("AnyUp")
      if buttonConfig.onClick then
        button:SetScript("OnClick", buttonConfig.onClick)
      end
    end

    -- Create the icon
    button.Icon = window.titlebar:CreateTexture(button:GetName() .. "Icon", "ARTWORK")
    button.Icon:SetPoint("CENTER", button, "CENTER")
    button.Icon:SetSize(iconSize, iconSize)
    button.Icon:SetTexture(buttonConfig.icon)
    button.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)

    -- Set up tooltip
    if buttonConfig.tooltipTitle then
      button:SetScript("OnEnter", function()
        button.Icon:SetVertexColor(0.9, 0.9, 0.9, 1)
        addon.Utils:SetBackgroundColor(button, 1, 1, 1, 0.05)
        GameTooltip:SetOwner(button, "ANCHOR_TOP")
        GameTooltip:SetText(buttonConfig.tooltipTitle, 1, 1, 1, 1, true)
        if buttonConfig.tooltipDescription then
          GameTooltip:AddLine(buttonConfig.tooltipDescription, NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b, true)
        end
        GameTooltip:Show()
      end)

      button:SetScript("OnLeave", function()
        button.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
        addon.Utils:SetBackgroundColor(button, 1, 1, 1, 0)
        GameTooltip:Hide()
      end)
    end

    button:SetSize(buttonSize, buttonSize)
    button:SetEnabled(isEnabled)
    button:Show()

    -- Store the button
    table.insert(window.titlebarButtons, button)

    -- Reposition all the buttons from right to left
    local anchorFrame = window.titlebar.CloseButton
    if window.titlebarButtons then
      for _, titlebarButton in ipairs(window.titlebarButtons) do
        titlebarButton:SetPoint("RIGHT", anchorFrame, "LEFT", 0, 0)
        anchorFrame = titlebarButton
      end
    end

    return button
  end

  ---Remove a button from the titlebar
  ---@param buttonName string
  function window:RemoveTitlebarButton(buttonName)
    local button = addon.Utils:TableFind(window.titlebarButtons, function(button) return button:GetName() == buttonName end)
    if not button then
      error("Button with name '" .. buttonName .. "' does not exist")
    end

    -- Remove the button
    button:Hide()
    button:SetParent(nil)
    window.titlebarButtons = addon.Utils:TableFilter(window.titlebarButtons, function(btn) return btn:GetName() ~= buttonName end)

    -- Reposition all the buttons from right to left
    local anchorFrame = window.titlebar.CloseButton
    if window.titlebarButtons then
      for _, titlebarButton in ipairs(window.titlebarButtons) do
        titlebarButton:SetPoint("RIGHT", anchorFrame, "LEFT", 0, 0)
        anchorFrame = titlebarButton
      end
    end
  end

  ---Get a titlebar button by name
  ---@param buttonName string
  ---@return AE_TitlebarButton?
  function window:GetTitlebarButton(buttonName)
    return addon.Utils:TableFind(window.titlebarButtons, function(button) return button:GetName() == buttonName end)
  end

  -- Border
  if window.config.border > 0 then
    ---@diagnostic disable-next-line: assign-type-mismatch
    window.border = CreateFrame("Frame", "$parentBorder", window, "BackdropTemplate")
    window.border:SetPoint("TOPLEFT", window, "TOPLEFT", -3, 3)
    window.border:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", 3, -3)
    window.border:SetBackdrop({edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 16, insets = {left = window.config.border, right = window.config.border, top = window.config.border, bottom = window.config.border}})
    window.border:SetBackdropBorderColor(0, 0, 0, .5)
    window.border:Show()
  end

  -- Titlebar
  if window.config.titlebar then
    window.titlebar = CreateFrame("Frame", "$parentTitleBar", window)
    window.titlebar:EnableMouse(true)
    window.titlebar:RegisterForDrag("LeftButton")
    window.titlebar:SetScript("OnDragStart", function() window:StartMoving() end)
    window.titlebar:SetScript("OnDragStop", function() window:StopMovingOrSizing() end)
    window.titlebar:SetPoint("TOPLEFT", window, "TOPLEFT")
    window.titlebar:SetPoint("TOPRIGHT", window, "TOPRIGHT")
    window.titlebar:SetHeight(TITLEBAR_HEIGHT)
    addon.Utils:SetBackgroundColor(window.titlebar, 0, 0, 0, 0.5)
    window.titlebar.icon = window.titlebar:CreateTexture("$parentIcon", "ARTWORK")
    window.titlebar.icon:SetPoint("LEFT", window.titlebar, "LEFT", 6, 0)
    window.titlebar.icon:SetSize(20, 20)
    window.titlebar.icon:SetTexture(addon.Constants.media.LogoTransparent)
    window.titlebar.title = window.titlebar:CreateFontString("$parentText", "OVERLAY")
    window.titlebar.title:SetPoint("LEFT", window.titlebar, "LEFT", 20 + addon.Constants.sizes.padding, 0)
    window.titlebar.title:SetFontObject("SystemFont_Med3")
    window.titlebar.title:SetText(window.config.title or window.config.name)
    window.titlebar.CloseButton = CreateFrame("Button", "$parentCloseButton", window.titlebar)
    window.titlebar.CloseButton:SetPoint("RIGHT", window.titlebar, "RIGHT", 0, 0)
    window.titlebar.CloseButton:SetSize(TITLEBAR_HEIGHT, TITLEBAR_HEIGHT)
    window.titlebar.CloseButton:RegisterForClicks("AnyUp")
    window.titlebar.CloseButton:SetScript("OnClick", function() window:Hide() end)
    window.titlebar.CloseButton.Icon = window.titlebar:CreateTexture("$parentIcon", "ARTWORK")
    window.titlebar.CloseButton.Icon:SetPoint("CENTER", window.titlebar.CloseButton, "CENTER")
    window.titlebar.CloseButton.Icon:SetSize(10, 10)
    window.titlebar.CloseButton.Icon:SetTexture(addon.Constants.media.IconClose)
    window.titlebar.CloseButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    window.titlebar.CloseButton:SetScript("OnEnter", function()
      window.titlebar.CloseButton.Icon:SetVertexColor(1, 1, 1, 1)
      addon.Utils:SetBackgroundColor(window.titlebar.CloseButton, 1, 0, 0, 0.2)
      GameTooltip:ClearAllPoints()
      GameTooltip:ClearLines()
      GameTooltip:SetOwner(window.titlebar.CloseButton, "ANCHOR_TOP")
      GameTooltip:SetText("Close the window", 1, 1, 1, 1, true)
      GameTooltip:Show()
    end)
    window.titlebar.CloseButton:SetScript("OnLeave", function()
      window.titlebar.CloseButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
      addon.Utils:SetBackgroundColor(window.titlebar.CloseButton, 1, 1, 1, 0)
      GameTooltip:Hide()
    end)
  end

  local topOffset = 0
  local leftOffset = 0

  if window.config.titlebar then
    topOffset = -TITLEBAR_HEIGHT
  end

  if window.config.sidebar then
    leftOffset = window.config.sidebar
  end

  -- Body
  window.body = CreateFrame("Frame", "$parentBody", window)
  window.body:SetPoint("TOPLEFT", window, "TOPLEFT", leftOffset, topOffset)
  window.body:SetPoint("TOPRIGHT", window, "TOPRIGHT", 0, topOffset)
  window.body:SetPoint("BOTTOMLEFT", window, "BOTTOMLEFT", leftOffset, 0)
  window.body:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", 0, 0)
  addon.Utils:SetBackgroundColor(window.body, 0, 0, 0, 0)

  -- Sidebar
  if window.config.sidebar then
    window.sidebar = CreateFrame("Frame", "$parentSidebar", window)
    window.sidebar:SetPoint("TOPLEFT", window, "TOPLEFT", 0, topOffset)
    window.sidebar:SetPoint("BOTTOMLEFT", window, "BOTTOMLEFT")
    window.sidebar:SetWidth(window.config.sidebar)
    addon.Utils:SetBackgroundColor(window.sidebar, 0, 0, 0, 0.3)
  end

  -- Initialize titlebar buttons table
  window.titlebarButtons = {}

  -- Add titlebar buttons if provided
  if window.config.titlebarButtons then
    for _, buttonConfig in ipairs(window.config.titlebarButtons) do
      window:AddTitlebarButton(buttonConfig)
    end
  end

  window:Hide()
  table.insert(UISpecialFrames, window:GetName())
  self.windows[window.config.name] = window
  return window
end

---Get a window by name
---@param name string
---@return AE_Window?
function Window:GetWindow(name)
  return self.windows[name]
end

---Scale each window
---@param scale number
function Window:SetWindowScale(scale)
  addon.Utils:TableForEach(self.windows, function(window)
    window:SetScale(scale)
  end)
end

---Set background color to each window
---@param color ColorTable
function Window:SetWindowBackgroundColor(color)
  addon.Utils:TableForEach(self.windows, function(window)
    addon.Utils:SetBackgroundColor(window, color.r, color.g, color.b, color.a)
  end)
end

---Get the maximum window width based on current screen width
---@return number
function Window:GetMaxWindowWidth()
  return GetScreenWidth() - 100
end

---Toggle a window by name (defaults to "Main")
---@param name string?
function Window:ToggleWindow(name)
  if name == nil or name == "" then name = "Main" end
  local window = self:GetWindow(name)
  if not window then return end
  if window:IsVisible() then
    window:Hide()
  else
    window:Show()
  end
end
