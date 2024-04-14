local windows = {}
function AlterEgo:GetWindow(name)
  name = "AlterEgo" .. name
  return windows[name]
end

function AlterEgo:SetWindowScale(scale)
  AE_table_foreach(windows, function(window)
    window:SetScale(scale)
  end)
end

function AlterEgo:SetWindowBackgroundColor(color)
  AE_table_foreach(windows, function(window)
    self:SetBackgroundColor(window, color.r, color.g, color.b, color.a)
  end)
end

function AlterEgo:SetHeight(name, height)
  if name == nil then name = "Main" end
  local window = self:GetWindow(name)
  if not window then return end
end

function AlterEgo:SetTitle(name, title)
  if name == nil then name = "Main" end
  local window = self:GetWindow(name)
  if not window then return end
  window.Titlebar.Text:SetText(title)
end

function AlterEgo:CreateWindow(name, title, parent)
  name = "AlterEgo" .. name
  local window = self:GetWindow(name)
  if window then
    return window
  end

  if parent == nil then parent = UIParent end
  if title == nil then title = "" end

  local windowFrame = CreateFrame("Frame", name, parent)
  windowFrame:SetFrameStrata("HIGH")
  windowFrame:SetFrameLevel(1000 + 100 * (AE_table_count(windows) + 1))
  windowFrame:SetClampedToScreen(true)
  windowFrame:SetMovable(true)
  windowFrame:SetUserPlaced(true)
  windowFrame:SetPoint("CENTER")
  windowFrame:SetSize(300, 300)
  self:SetBackgroundColor(windowFrame, self.db.global.interface.windowColor.r, self.db.global.interface.windowColor.g, self.db.global.interface.windowColor.b, self.db.global.interface.windowColor.a)

  do -- Border
    windowFrame.Border = CreateFrame("Frame", "$parentBorder", windowFrame, "BackdropTemplate")
    windowFrame.Border:SetPoint("TOPLEFT", windowFrame, "TOPLEFT", -3, 3)
    windowFrame.Border:SetPoint("BOTTOMRIGHT", windowFrame, "BOTTOMRIGHT", 3, -3)
    windowFrame.Border:SetBackdrop({edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 16, insets = {left = self.constants.sizes.border, right = self.constants.sizes.border, top = self.constants.sizes.border, bottom = self.constants.sizes.border}})
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
    windowFrame.TitleBar:SetHeight(self.constants.sizes.titlebar.height)
    self:SetBackgroundColor(windowFrame.TitleBar, 0, 0, 0, 0.5)
    windowFrame.TitleBar.Icon = windowFrame.TitleBar:CreateTexture("$parentIcon", "ARTWORK")
    windowFrame.TitleBar.Icon:SetPoint("LEFT", windowFrame.TitleBar, "LEFT", 6, 0)
    windowFrame.TitleBar.Icon:SetSize(20, 20)
    windowFrame.TitleBar.Icon:SetTexture(self.constants.media.LogoTransparent)
    windowFrame.TitleBar.Text = windowFrame.TitleBar:CreateFontString("$parentText", "OVERLAY")
    windowFrame.TitleBar.Text:SetPoint("LEFT", windowFrame.TitleBar, "LEFT", 20 + self.constants.sizes.padding, 0)
    windowFrame.TitleBar.Text:SetFontObject("SystemFont_Med3")
    windowFrame.TitleBar.Text:SetText(title)
    windowFrame.TitleBar.CloseButton = CreateFrame("Button", "$parentCloseButton", windowFrame.TitleBar)
    windowFrame.TitleBar.CloseButton:SetPoint("RIGHT", windowFrame.TitleBar, "RIGHT", 0, 0)
    windowFrame.TitleBar.CloseButton:SetSize(self.constants.sizes.titlebar.height, self.constants.sizes.titlebar.height)
    windowFrame.TitleBar.CloseButton:RegisterForClicks("AnyUp")
    windowFrame.TitleBar.CloseButton:SetScript("OnClick", function() windowFrame:Hide() end)
    windowFrame.TitleBar.CloseButton.Icon = windowFrame.TitleBar:CreateTexture("$parentIcon", "ARTWORK")
    windowFrame.TitleBar.CloseButton.Icon:SetPoint("CENTER", windowFrame.TitleBar.CloseButton, "CENTER")
    windowFrame.TitleBar.CloseButton.Icon:SetSize(10, 10)
    windowFrame.TitleBar.CloseButton.Icon:SetTexture(self.constants.media.IconClose)
    windowFrame.TitleBar.CloseButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    windowFrame.TitleBar.CloseButton:SetScript("OnEnter", function()
      windowFrame.TitleBar.CloseButton.Icon:SetVertexColor(1, 1, 1, 1)
      self:SetBackgroundColor(windowFrame.TitleBar.CloseButton, 1, 0, 0, 0.2)
      GameTooltip:ClearAllPoints()
      GameTooltip:ClearLines()
      GameTooltip:SetOwner(windowFrame.TitleBar.CloseButton, "ANCHOR_TOP")
      GameTooltip:SetText("Close the window", 1, 1, 1, 1, true);
      -- GameTooltip:AddLine("Click to close the window.", NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
      GameTooltip:Show()
    end)
    windowFrame.TitleBar.CloseButton:SetScript("OnLeave", function()
      windowFrame.TitleBar.CloseButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
      self:SetBackgroundColor(windowFrame.TitleBar.CloseButton, 1, 1, 1, 0)
      GameTooltip:Hide()
    end)
  end

  do -- Body
    windowFrame.Body = CreateFrame("Frame", "$parentBody", windowFrame)
    windowFrame.Body:SetPoint("TOPLEFT", windowFrame.TitleBar, "BOTTOMLEFT")
    windowFrame.Body:SetPoint("TOPRIGHT", windowFrame.TitleBar, "BOTTOMRIGHT")
    windowFrame.Body:SetPoint("BOTTOMLEFT", windowFrame, "BOTTOMLEFT")
    windowFrame.Body:SetPoint("BOTTOMRIGHT", windowFrame, "BOTTOMRIGHT")
    self:SetBackgroundColor(windowFrame.Body, 0, 0, 0, 0)
  end

  windowFrame:Hide()
  table.insert(UISpecialFrames, name)
  windows[name] = windowFrame
  return windows[name]
end

function AlterEgo:GetMaxWindowWidth()
  return GetScreenWidth() - 100
end

function AlterEgo:ToggleWindow(name)
  if name == nil or name == "" then name = "Main" end
  local window = self:GetWindow(name)
  if not window then return end
  if window:IsVisible() then
    window:Hide()
  else
    window:Show()
  end
end
