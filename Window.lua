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

---@class AE_Window
local Window = {}
addon.Window = Window


---Create a window frame
---@param options table?
---@return Frame
function Window:New(options)
  options = Mixin(
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

  ---@class AE_Window : Frame
  local frame = CreateFrame("Frame", "AlterEgo" .. options.name, options.parent)
  frame:SetFrameStrata("HIGH")
  frame:SetFrameLevel(1000 + 100 * (Utils:TableCount(WindowCollection) + 1))
  frame:SetClampedToScreen(true)
  frame:SetMovable(true)
  frame:SetUserPlaced(true)
  frame:SetPoint("CENTER")
  frame:SetSize(300, 300)
  Utils:SetBackgroundColor(frame, options.windowColor.r, options.windowColor.g, options.windowColor.b, options.windowColor.a)

  ---Show or hide the window
  function frame:Toggle()
    frame:SetShown(not frame:IsVisible())
  end

  ---Set the title of the window
  ---@param title string
  function frame:SetTitle(title)
    if not options.titlebar then return end
    frame.titlebar.title:SetText(title)
  end

  ---Set body size and adjust window size
  ---@param width number
  ---@param height number
  function frame:SetBodySize(width, height)
    local w = width
    local h = height
    if options.sidebar then
      w = w + SIDEBAR_WIDTH
    end
    if options.titlebar then
      h = h + TITLEBAR_HEIGHT
    end
    frame:SetSize(w, h)
  end

  -- Border
  if options.border > 0 then
    frame.border = CreateFrame("Frame", "$parentBorder", frame, "BackdropTemplate")
    frame.border:SetPoint("TOPLEFT", frame, "TOPLEFT", -3, 3)
    frame.border:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 3, -3)
    frame.border:SetBackdrop({edgeFile = "Interface/Tooltips/UI-Tooltip-Border", edgeSize = 16, insets = {left = options.border, right = options.border, top = options.border, bottom = options.border}})
    frame.border:SetBackdropBorderColor(0, 0, 0, .5)
    frame.border:Show()
  end

  -- Titlebar
  if options.titlebar then
    frame.titlebar = CreateFrame("Frame", "$parentTitleBar", frame)
    frame.titlebar:EnableMouse(true)
    frame.titlebar:RegisterForDrag("LeftButton")
    frame.titlebar:SetScript("OnDragStart", function() frame:StartMoving() end)
    frame.titlebar:SetScript("OnDragStop", function() frame:StopMovingOrSizing() end)
    frame.titlebar:SetPoint("TOPLEFT", frame, "TOPLEFT")
    frame.titlebar:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
    frame.titlebar:SetHeight(TITLEBAR_HEIGHT)
    Utils:SetBackgroundColor(frame.titlebar, 0, 0, 0, 0.5)
    frame.titlebar.icon = frame.titlebar:CreateTexture("$parentIcon", "ARTWORK")
    frame.titlebar.icon:SetPoint("LEFT", frame.titlebar, "LEFT", 6, 0)
    frame.titlebar.icon:SetSize(20, 20)
    frame.titlebar.icon:SetTexture(Constants.media.LogoTransparent)
    frame.titlebar.title = frame.titlebar:CreateFontString("$parentText", "OVERLAY")
    frame.titlebar.title:SetPoint("LEFT", frame.titlebar, "LEFT", 20 + Constants.sizes.padding, 0)
    frame.titlebar.title:SetFontObject("SystemFont_Med3")
    frame.titlebar.title:SetText(options.title or options.name)
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
      Utils:SetBackgroundColor(frame.titlebar.CloseButton, 1, 0, 0, 0.2)
      GameTooltip:ClearAllPoints()
      GameTooltip:ClearLines()
      GameTooltip:SetOwner(frame.titlebar.CloseButton, "ANCHOR_TOP")
      GameTooltip:SetText("Close the window", 1, 1, 1, 1, true);
      GameTooltip:Show()
    end)
    frame.titlebar.CloseButton:SetScript("OnLeave", function()
      frame.titlebar.CloseButton.Icon:SetVertexColor(0.7, 0.7, 0.7, 1)
      Utils:SetBackgroundColor(frame.titlebar.CloseButton, 1, 1, 1, 0)
      GameTooltip:Hide()
    end)
  end

  local topOffset = 0
  local leftOffset = 0

  if options.titlebar then
    topOffset = -TITLEBAR_HEIGHT
  end

  if options.sidebar then
    leftOffset = SIDEBAR_WIDTH
  end

  -- Body
  frame.body = CreateFrame("Frame", "$parentBody", frame)
  frame.body:SetPoint("TOPLEFT", frame, "TOPLEFT", leftOffset, topOffset)
  frame.body:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, topOffset)
  frame.body:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", leftOffset, 0)
  frame.body:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
  Utils:SetBackgroundColor(frame.body, 0, 0, 0, 0)

  -- Sidebar
  if options.sidebar then
    frame.sidebar = CreateFrame("Frame", "$parentSidebar", frame)
    frame.sidebar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, topOffset)
    frame.sidebar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT")
    frame.sidebar:SetWidth(SIDEBAR_WIDTH)
    Utils:SetBackgroundColor(frame.sidebar, 0, 0, 0, 0.3)
  end

  frame.options = options;
  frame:Hide()
  table.insert(UISpecialFrames, options.name)
  WindowCollection[options.name] = frame
  return frame
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
