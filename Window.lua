---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

---@class AE_Window
local Window = {}
addon.Window = Window

local windows = {}
function Window:GetWindow(name)
  name = "AlterEgo" .. name
  return windows[name]
end

function Window:SetWindowScale(scale)
  addon.Utils:TableForEach(windows, function(window)
    window:SetScale(scale)
  end)
end

function Window:SetWindowBackgroundColor(color)
  addon.Utils:TableForEach(windows, function(window)
    addon.Utils:SetBackgroundColor(window, color.r, color.g, color.b, color.a)
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
  window.Titlebar.Text:SetText(title)
end

function Window:CreateWindow(name, title, parent, color)
  name = "AlterEgo" .. name
  local window = self:GetWindow(name)
  if window then
    return window
  end

  if parent == nil then parent = UIParent end
  if title == nil then title = "" end

  local windowFrame = CreateFrame("Frame", name, parent)
  windowFrame:SetFrameStrata("HIGH")
  windowFrame:SetFrameLevel(1000 + 100 * (addon.Utils:TableCount(windows) + 1))
  windowFrame:SetClampedToScreen(true)
  windowFrame:SetMovable(true)
  windowFrame:SetUserPlaced(true)
  windowFrame:SetPoint("CENTER")
  windowFrame:SetSize(300, 300)
  addon.Utils:SetBackgroundColor(windowFrame, color.r, color.g, color.b, color.a)

  do -- Border
    windowFrame.Border = CreateFrame("Frame", "$parentBorder", windowFrame, "BackdropTemplate")
    windowFrame.Border:SetPoint("TOPLEFT", windowFrame, "TOPLEFT", -3, 3)
    windowFrame.Border:SetPoint("BOTTOMRIGHT", windowFrame, "BOTTOMRIGHT", 3, -3)
    windowFrame.Border:SetBackdrop({edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 16, insets = {left = addon.Constants.sizes.border, right = addon.Constants.sizes.border, top = addon.Constants.sizes.border, bottom = addon.Constants.sizes.border}})
    windowFrame.Border:SetBackdropBorderColor(0, 0, 0, .5)
    windowFrame.Border:Show()
  end

  do -- Titlebar
    windowFrame.TitleBar = CreateFrame("Frame", "$parentTitleBar", windowFrame)
    windowFrame.TitleBar:EnableMouse(true)
    windowFrame.TitleBar:RegisterForDrag("LeftButton")
    windowFrame.TitleBar:SetScript("OnDragStart", function() windowFrame:StartMoving() end)
    windowFrame.TitleBar:SetScript("OnDragStop", function() windowFrame:StopMovingOrSizing() end)
    windowFrame.TitleBar:SetPoint("TOPLEFT", windowFrame, "TOPLEFT")
    windowFrame.TitleBar:SetPoint("TOPRIGHT", windowFrame, "TOPRIGHT")
    windowFrame.TitleBar:SetHeight(addon.Constants.sizes.titlebar.height)
    addon.Utils:SetBackgroundColor(windowFrame.TitleBar, 0, 0, 0, 0.5)
    windowFrame.TitleBar.Icon = windowFrame.TitleBar:CreateTexture("$parentIcon", "ARTWORK")
    windowFrame.TitleBar.Icon:SetPoint("LEFT", windowFrame.TitleBar, "LEFT", 6, 0)
    windowFrame.TitleBar.Icon:SetSize(20, 20)
    windowFrame.TitleBar.Icon:SetTexture(addon.Constants.media.LogoTransparent)
    windowFrame.TitleBar.Text = windowFrame.TitleBar:CreateFontString("$parentText", "OVERLAY")
    windowFrame.TitleBar.Text:SetPoint("LEFT", windowFrame.TitleBar, "LEFT", 20 + addon.Constants.sizes.padding, 0)
    windowFrame.TitleBar.Text:SetFontObject("SystemFont_Med3")
    windowFrame.TitleBar.Text:SetText(title)
    windowFrame.TitleBar.CloseButton = CreateFrame("Button", "$parentCloseButton", windowFrame.TitleBar)
    windowFrame.TitleBar.CloseButton:SetPoint("RIGHT", windowFrame.TitleBar, "RIGHT", 0, 0)
    windowFrame.TitleBar.CloseButton:SetSize(addon.Constants.sizes.titlebar.height, addon.Constants.sizes.titlebar.height)
    windowFrame.TitleBar.CloseButton:RegisterForClicks("AnyUp")
    windowFrame.TitleBar.CloseButton:SetScript("OnClick", function() windowFrame:Hide() end)
    windowFrame.TitleBar.CloseButton.Icon = windowFrame.TitleBar:CreateTexture("$parentIcon", "ARTWORK")
    windowFrame.TitleBar.CloseButton.Icon:SetPoint("CENTER", windowFrame.TitleBar.CloseButton, "CENTER")
    windowFrame.TitleBar.CloseButton.Icon:SetSize(10, 10)
    windowFrame.TitleBar.CloseButton.Icon:SetTexture(addon.Constants.media.IconClose)
    windowFrame.TitleBar.CloseButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    windowFrame.TitleBar.CloseButton:SetScript("OnEnter", function()
      windowFrame.TitleBar.CloseButton.Icon:SetVertexColor(1, 1, 1, 1)
      addon.Utils:SetBackgroundColor(windowFrame.TitleBar.CloseButton, 1, 0, 0, 0.2)
      GameTooltip:ClearAllPoints()
      GameTooltip:ClearLines()
      GameTooltip:SetOwner(windowFrame.TitleBar.CloseButton, "ANCHOR_TOP")
      GameTooltip:SetText("Close the window", 1, 1, 1, 1, true);
      -- GameTooltip:AddLine("Click to close the window.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
      GameTooltip:Show()
    end)
    windowFrame.TitleBar.CloseButton:SetScript("OnLeave", function()
      windowFrame.TitleBar.CloseButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
      addon.Utils:SetBackgroundColor(windowFrame.TitleBar.CloseButton, 1, 1, 1, 0)
      GameTooltip:Hide()
    end)
  end

  do -- Body
    windowFrame.Body = CreateFrame("Frame", "$parentBody", windowFrame)
    windowFrame.Body:SetPoint("TOPLEFT", windowFrame.TitleBar, "BOTTOMLEFT")
    windowFrame.Body:SetPoint("TOPRIGHT", windowFrame.TitleBar, "BOTTOMRIGHT")
    windowFrame.Body:SetPoint("BOTTOMLEFT", windowFrame, "BOTTOMLEFT")
    windowFrame.Body:SetPoint("BOTTOMRIGHT", windowFrame, "BOTTOMRIGHT")
    addon.Utils:SetBackgroundColor(windowFrame.Body, 0, 0, 0, 0)
  end

  windowFrame:Hide()
  table.insert(UISpecialFrames, name)
  windows[name] = windowFrame
  return windows[name]
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
