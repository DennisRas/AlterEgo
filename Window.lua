local addonName, AlterEgo = ...
local Utils = AlterEgo.Utils
local Constants = AlterEgo.Constants
local Window = {}
AlterEgo.Window = Window

local TITLEBAR_HEIGHT = 20
local FOOTER_HEIGHT = 16
local SIDEBAR_WIDTH = 150

local windows = {}
function Window:GetWindow(name)
  return windows[name]
end

function Window:SetWindowScale(scale)
  Utils:TableForEach(windows, function(window)
    window:SetScale(scale)
  end)
end

function Window:SetWindowBackgroundColor(color)
  Utils:TableForEach(windows, function(window)
    self:SetBackgroundColor(window, color.r, color.g, color.b, color.a)
  end)
end

function Window:SetHeight(name, height)
  if name == nil then name = "Main" end
  local window = self:GetWindow(name)
  if not window then return end
end

function Window:SetTitle(name, title)
  if name == nil then name = "Main" end
  local window = self:GetWindow(name)
  if not window then return end
  window.Titlebar.Title:SetText(title)
end

function Window:CreateWindow(config)
  local defaultConfig = {
    name = "",
    title = "",
    parent = UIParent,
    border = Constants.sizes.border,
    sidebar = false,
    titlebar = true
  }
  Mixin(defaultConfig, config or {})

  local window = self:GetWindow(defaultConfig.name)
  if window then
    return window
  end

  local frame = CreateFrame("Frame", "AlterEgo" .. defaultConfig.name, defaultConfig.parent)
  frame:SetFrameStrata("HIGH")
  frame:SetFrameLevel(1000 + 100 * (Utils:TableCount(windows) + 1))
  frame:SetClampedToScreen(true)
  frame:SetMovable(true)
  frame:SetUserPlaced(true)
  frame:SetPoint("CENTER")
  frame:SetSize(300, 300)
  self:SetBackgroundColor(frame, self.db.global.interface.windowColor.r, self.db.global.interface.windowColor.g, self.db.global.interface.windowColor.b, self.db.global.interface.windowColor.a)

  -- Border
  if defaultConfig.border > 0 then
    frame.border = CreateFrame("Frame", "$parentBorder", frame, "BackdropTemplate")
    frame.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -3, 3)
    frame.border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 3, -3)
    frame.border:SetBackdrop({edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 16, insets = {left = defaultConfig.border, right = defaultConfig.border, top = defaultConfig.border, bottom = defaultConfig.border}})
    frame.border:SetBackdropBorderColor(0, 0, 0, .5)
    frame.border:Show()
  end

  -- Titlebar
  if defaultConfig.titlebar then
    frame.titlebar = CreateFrame("Frame", "$parentTitleBar", frame)
    frame.titlebar:EnableMouse(true)
    frame.titlebar:RegisterForDrag("LeftButton")
    frame.titlebar:SetScript("OnDragStart", function() frame:StartMoving() end)
    frame.titlebar:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)
    frame.titlebar:SetPoint("TOPLEFT", frame, "TOPLEFT")
    frame.titlebar:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
    frame.titlebar:SetHeight(TITLEBAR_HEIGHT)
    self:SetBackgroundColor(frame.titlebar, 0, 0, 0, 0.5)
    frame.titlebar.icon = frame.titlebar:CreateTexture("$parentIcon", "ARTWORK")
    frame.titlebar.icon:SetPoint("LEFT", frame.titlebar, "LEFT", 6, 0)
    frame.titlebar.icon:SetSize(20, 20)
    frame.titlebar.icon:SetTexture(Constants.media.LogoTransparent)
    frame.titlebar.title = frame.titlebar:CreateFontString("$parentText", "OVERLAY")
    frame.titlebar.title:SetPoint("LEFT", frame.titlebar, "LEFT", 20 + Constants.sizes.padding, 0)
    frame.titlebar.title:SetFontObject("SystemFont_Med3")
    frame.titlebar.title:SetText(defaultConfig.title)
    frame.titlebar.CloseButton = CreateFrame("Button", "$parentCloseButton", frame.titlebar)
    frame.titlebar.CloseButton:SetPoint("RIGHT", frame.titlebar, "RIGHT", 0, 0)
    frame.titlebar.CloseButton:SetSize(TITLEBAR_HEIGHT, TITLEBAR_HEIGHT)
    frame.titlebar.CloseButton:RegisterForClicks("AnyUp")
    frame.titlebar.CloseButton:SetScript("OnClick", function() frame:Hide() end)
    frame.titlebar.CloseButton.Icon = frame.titlebar:CreateTexture("$parentIcon", "ARTWORK")
    frame.titlebar.CloseButton.Icon:SetPoint("CENTER", frame.titlebar.CloseButton, "CENTER")
    frame.titlebar.CloseButton.Icon:SetSize(10, 10)
    frame.titlebar.CloseButton.Icon:SetTexture(Constants.media.IconClose)
    frame.titlebar.CloseButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    frame.titlebar.CloseButton:SetScript("OnEnter", function()
      frame.titlebar.CloseButton.Icon:SetVertexColor(1, 1, 1, 1)
      self:SetBackgroundColor(frame.titlebar.CloseButton, 1, 0, 0, 0.2)
      GameTooltip:ClearAllPoints()
      GameTooltip:ClearLines()
      GameTooltip:SetOwner(frame.titlebar.CloseButton, "ANCHOR_TOP")
      GameTooltip:SetText("Close the window", 1, 1, 1, 1, true);
      GameTooltip:Show()
    end)
    frame.titlebar.CloseButton:SetScript("OnLeave", function()
      frame.titlebar.CloseButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
      self:SetBackgroundColor(frame.titlebar.CloseButton, 1, 1, 1, 0)
      GameTooltip:Hide()
    end)
  end

  local topOffset = 0
  local leftOffset = 0

  if defaultConfig.titlebar then
    topOffset = -TITLEBAR_HEIGHT
  end

  if defaultConfig.sidebar then
    leftOffset = SIDEBAR_WIDTH
  end

  -- Body
  frame.body = CreateFrame("Frame", "$parentBody", frame)
  frame.body:SetPoint("TOPLEFT", frame, "TOPLEFT", leftOffset, topOffset)
  frame.body:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, topOffset)
  frame.body:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", leftOffset, 0)
  frame.body:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  self:SetBackgroundColor(frame.body, 0, 0, 0, 0)

  -- Sidebar

  if defaultConfig.sidebar then
    frame.sidebar = CreateFrame("Frame", "$parentSidebar", frame)
    frame.sidebar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, topOffset)
    frame.sidebar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT")
    frame.sidebar:SetWidth(SIDEBAR_WIDTH)
    self:SetBackgroundColor(frame.sidebar, 0, 0, 0, 0.3)
    frame.sidebar:Show()
  end

  frame:Hide()
  table.insert(UISpecialFrames, defaultConfig.name)
  windows[defaultConfig.name] = frame
  return windows[defaultConfig.name]
end

function Window:GetMaxWindowWidth()
  return GetScreenWidth() - 100
end

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
