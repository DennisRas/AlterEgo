---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

local Utils = addon.Utils
local Constants = addon.Constants

---@type Frame[]
local WindowCollection = {}
local TITLEBAR_HEIGHT = 30
local FOOTER_HEIGHT = 16
local SIDEBAR_WIDTH = 150

---@class AE_WindowManager
local Window = {}
addon.Window = Window


---Create a window frame
---@param options table?
---@return AE_Window
function Window:New(options)
  ---@class AE_Window : Frame
  local window = CreateFrame("Frame", "AlterEgo" .. (options and options.name or ""))
  window.config = CreateFromMixins(
    {
      name = "",
      title = "",
      parent = UIParent,
      border = Constants.sizes.border,
      sidebar = false,
      titlebar = true,
      windowScale = 100,
      windowColor = {r = 0.11372549019, g = 0.14117647058, b = 0.16470588235, a = 1}
    },
    options or {}
  )
  window:SetFrameStrata("HIGH")
  -- frame:SetFrameLevel(1000 + 100 * (Utils:TableCount(WindowCollection) + 1))
  window:SetTopLevel(true)
  window:SetClampedToScreen(true)
  window:SetMovable(true)
  -- window:SetUserPlaced(true)
  window:SetPoint("CENTER")
  window:SetSize(300, 300)
  window:EnableMouse(true) -- Disable click-throughs
  window:SetParent(window.config.parent)
  Utils:SetBackgroundColor(window, window.config.windowColor.r, window.config.windowColor.g, window.config.windowColor.b, window.config.windowColor.a)

  ---Show or hide the window
  function window:Toggle()
    window:SetShown(not window:IsVisible())
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
      w = w + SIDEBAR_WIDTH
    end
    if window.config.titlebar then
      h = h + TITLEBAR_HEIGHT
    end
    window:SetSize(w, h)
  end

  -- Border
  if window.config.border > 0 then
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
    Utils:SetBackgroundColor(window.titlebar, 0, 0, 0, 0.5)
    window.titlebar.icon = window.titlebar:CreateTexture("$parentIcon", "ARTWORK")
    window.titlebar.icon:SetPoint("LEFT", window.titlebar, "LEFT", 6, 0)
    window.titlebar.icon:SetSize(20, 20)
    window.titlebar.icon:SetTexture(Constants.media.LogoTransparent)
    window.titlebar.title = window.titlebar:CreateFontString("$parentText", "OVERLAY")
    window.titlebar.title:SetPoint("LEFT", window.titlebar, "LEFT", 20 + Constants.sizes.padding, 0)
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
    window.titlebar.CloseButton.Icon:SetTexture(Constants.media.IconClose)
    window.titlebar.CloseButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
    window.titlebar.CloseButton:SetScript("OnEnter", function()
      window.titlebar.CloseButton.Icon:SetVertexColor(1, 1, 1, 1)
      Utils:SetBackgroundColor(window.titlebar.CloseButton, 1, 0, 0, 0.2)
      GameTooltip:ClearAllPoints()
      GameTooltip:ClearLines()
      GameTooltip:SetOwner(window.titlebar.CloseButton, "ANCHOR_TOP")
      GameTooltip:SetText("Close the window", 1, 1, 1, 1, true);
      GameTooltip:Show()
    end)
    window.titlebar.CloseButton:SetScript("OnLeave", function()
      window.titlebar.CloseButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
      Utils:SetBackgroundColor(window.titlebar.CloseButton, 1, 1, 1, 0)
      GameTooltip:Hide()
    end)
  end

  local topOffset = 0
  local leftOffset = 0

  if window.config.titlebar then
    topOffset = -TITLEBAR_HEIGHT
  end

  if window.config.sidebar then
    leftOffset = SIDEBAR_WIDTH
  end

  -- Body
  window.body = CreateFrame("Frame", "$parentBody", window)
  window.body:SetPoint("TOPLEFT", window, "TOPLEFT", leftOffset, topOffset)
  window.body:SetPoint("TOPRIGHT", window, "TOPRIGHT", 0, topOffset)
  window.body:SetPoint("BOTTOMLEFT", window, "BOTTOMLEFT", leftOffset, 0)
  window.body:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", 0, 0)
  Utils:SetBackgroundColor(window.body, 0, 0, 0, 0)

  -- Sidebar
  if window.config.sidebar then
    window.sidebar = CreateFrame("Frame", "$parentSidebar", window)
    window.sidebar:SetPoint("TOPLEFT", window, "TOPLEFT", 0, topOffset)
    window.sidebar:SetPoint("BOTTOMLEFT", window, "BOTTOMLEFT")
    window.sidebar:SetWidth(SIDEBAR_WIDTH)
    Utils:SetBackgroundColor(window.sidebar, 0, 0, 0, 0.3)
  end

  window:Hide()
  table.insert(UISpecialFrames, window.config.name)
  WindowCollection[window.config.name] = window
  return window
end

---Get a window by name
---@param name string
---@return Frame
function Window:GetWindow(name)
  return WindowCollection[name]
end

---Scale each window
---@param scale number
function Window:SetWindowScale(scale)
  Utils:TableForEach(WindowCollection, function(window)
    window:SetScale(scale)
  end)
end

---Set background color to each window
---@param color ColorMixin
function Window:SetWindowBackgroundColor(color)
  Utils:TableForEach(WindowCollection, function(window)
    -- Utils:SetBackgroundColor(window, color.r, color.g, color.b, color.a)
  end)
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

function Window:CreateScrollFrame(name, parent)
  local frame = CreateFrame("ScrollFrame", name, parent)
  frame.content = CreateFrame("Frame", "$parentContent", frame)
  frame.scrollbarH = CreateFrame("Slider", "$parentScrollbarH", frame, "UISliderTemplate")
  frame.scrollbarV = CreateFrame("Slider", "$parentScrollbarV", frame, "UISliderTemplate")

  frame:SetAllPoints()
  frame:SetScript("OnMouseWheel", function(_, delta)
    if IsModifierKeyDown() or not frame.scrollbarV:IsVisible() then
      frame.scrollbarH:SetValue(frame.scrollbarH:GetValue() - delta * ((frame.content:GetWidth() - frame:GetWidth()) * 0.1))
    else
      frame.scrollbarV:SetValue(frame.scrollbarV:GetValue() - delta * ((frame.content:GetHeight() - frame:GetHeight()) * 0.1))
    end
  end)
  frame:SetScript("OnSizeChanged", function() frame:Refresh() end)
  frame:SetScrollChild(frame.content)
  frame.content:SetScript("OnSizeChanged", function() frame:Refresh() end)

  frame.scrollbarH:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 0, 0)
  frame.scrollbarH:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  frame.scrollbarH:SetHeight(6)
  frame.scrollbarH:SetMinMaxValues(0, 100)
  frame.scrollbarH:SetValue(0)
  frame.scrollbarH:SetValueStep(1)
  frame.scrollbarH:SetOrientation("HORIZONTAL")
  frame.scrollbarH:SetObeyStepOnDrag(true)
  frame.scrollbarH.thumb = frame.scrollbarH:GetThumbTexture()
  frame.scrollbarH.thumb:SetPoint("CENTER")
  frame.scrollbarH.thumb:SetColorTexture(1, 1, 1, 0.15)
  frame.scrollbarH.thumb:SetHeight(10)
  frame.scrollbarH:SetScript("OnValueChanged", function(_, value) frame:SetHorizontalScroll(value) end)
  frame.scrollbarH:SetScript("OnEnter", function() frame.scrollbarH.thumb:SetColorTexture(1, 1, 1, 0.2) end)
  frame.scrollbarH:SetScript("OnLeave", function() frame.scrollbarH.thumb:SetColorTexture(1, 1, 1, 0.15) end)

  frame.scrollbarV:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  frame.scrollbarV:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
  frame.scrollbarV:SetWidth(6)
  frame.scrollbarV:SetMinMaxValues(0, 100)
  frame.scrollbarV:SetValue(0)
  frame.scrollbarV:SetValueStep(1)
  frame.scrollbarV:SetOrientation("VERTICAL")
  frame.scrollbarV:SetObeyStepOnDrag(true)
  frame.scrollbarV.thumb = frame.scrollbarV:GetThumbTexture()
  frame.scrollbarV.thumb:SetPoint("CENTER")
  frame.scrollbarV.thumb:SetColorTexture(1, 1, 1, 0.15)
  frame.scrollbarV.thumb:SetWidth(10)
  frame.scrollbarV:SetScript("OnValueChanged", function(_, value) frame:SetVerticalScroll(value) end)
  frame.scrollbarV:SetScript("OnEnter", function() frame.scrollbarV.thumb:SetColorTexture(1, 1, 1, 0.2) end)
  frame.scrollbarV:SetScript("OnLeave", function() frame.scrollbarV.thumb:SetColorTexture(1, 1, 1, 0.15) end)

  if frame.scrollbarH.NineSlice then frame.scrollbarH.NineSlice:Hide() end
  if frame.scrollbarV.NineSlice then frame.scrollbarV.NineSlice:Hide() end

  function frame:Refresh()
    if math.floor(frame.content:GetWidth()) > math.floor(frame:GetWidth()) then
      frame.scrollbarH:SetMinMaxValues(0, frame.content:GetWidth() - frame:GetWidth())
      frame.scrollbarH.thumb:SetWidth(frame.scrollbarH:GetWidth() / 10)
      frame.scrollbarH.thumb:SetHeight(frame.scrollbarH:GetHeight())
      frame.scrollbarH:Show()
    else
      frame:SetHorizontalScroll(0)
      frame.scrollbarH:Hide()
    end
    if math.floor(frame.content:GetHeight()) > math.floor(frame:GetHeight()) then
      frame.scrollbarV:SetMinMaxValues(0, frame.content:GetHeight() - frame:GetHeight())
      frame.scrollbarV.thumb:SetHeight(frame.scrollbarV:GetHeight() / 10)
      frame.scrollbarV.thumb:SetWidth(frame.scrollbarV:GetWidth())
      frame.scrollbarV:Show()
    else
      frame:SetVerticalScroll(0)
      frame.scrollbarV:Hide()
    end
  end

  frame:Refresh()
  return frame
end
