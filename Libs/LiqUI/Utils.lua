---@class LiqUI
local LiqUI = LibStub and LibStub("LiqUI-1.0", true)
if not LiqUI then
  return
end

---@class LiqUI_Utils
local Utils = {}
LiqUI.Utils = Utils

---Merge defaults with options; ensure parent (default UIParent).
function Utils.PrepareOptions(defaults, options)
  local opts = Utils.MergeDeep(defaults or {parent = UIParent}, options or {})
  opts.parent = opts.parent or UIParent
  return opts
end

---Create a font string with theme text color. anchor: { point, relativeTo, relativePoint, x, y }.
function Utils.CreateLabel(parent, text, anchor)
  local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  if anchor then
    fs:SetPoint(anchor.point or "LEFT", anchor.relativeTo or parent, anchor.relativePoint or "LEFT", anchor.x or 0, anchor.y or 0)
  end
  fs:SetText(text or "")
  fs:SetTextColor(LiqUI.Constants.text.defaultColor:GetRGBA())
  return fs
end

---Find a table item by callback
---@generic T
---@param tbl table<any, T>
---@param callback fun(value: T, index: any): boolean
---@return T|nil, any
function Utils.TableFind(tbl, callback)
  assert(type(tbl) == "table", "Must be a table!")
  for i, v in pairs(tbl) do
    if callback(v, i) then
      return v, i
    end
  end
  return nil, nil
end

---Find a table item by key and value
---@generic T
---@param tbl table<any, T>
---@param key string
---@param val any
---@return T|nil, any
function Utils.TableGet(tbl, key, val)
  return Utils.TableFind(tbl, function(elm, _)
    return elm[key] and elm[key] == val
  end)
end

---Create a new table containing all elements that pass truth test
---@generic T
---@param tbl table<any, T>
---@param callback fun(value: T, index: any): boolean
---@return T[]
function Utils.TableFilter(tbl, callback)
  assert(type(tbl) == "table", "Must be a table!")
  local t = {}
  for i, v in pairs(tbl) do
    if callback(v, i) then
      table.insert(t, v)
    end
  end
  return t
end

---Count table items
---@param tbl table<any, any>
---@return number
function Utils.TableCount(tbl)
  assert(type(tbl) == "table", "Must be a table!")
  local n = 0
  for _ in pairs(tbl) do
    n = n + 1
  end
  return n
end

---Deep merge overlay into base. Nested tables are merged recursively; overlay values override base. Returns new table.
---@param base table
---@param overlay table
---@return table
function Utils.MergeDeep(base, overlay)
  local result = Utils.TableCopy(base)
  for k, v in pairs(overlay) do
    if type(v) == "table" and type(result[k]) == "table" then
      result[k] = Utils.MergeDeep(result[k], v)
    else
      result[k] = v
    end
  end
  return result
end

---Deep copy a table
---@generic T
---@param tbl table<any, T>
---@param cache table?
---@return table<any, any>
function Utils.TableCopy(tbl, cache)
  assert(type(tbl) == "table", "Must be a table!")
  local t = {}
  cache = cache or {}
  cache[tbl] = t
  Utils.TableForEach(tbl, function(v, k)
    if type(v) == "table" then
      t[k] = cache[v] or Utils.TableCopy(v, cache)
    else
      t[k] = v
    end
  end)
  return t
end

---Map each item in a table
---@generic T, V
---@param tbl table<any, T>
---@param callback fun(value: T, index: any): V, any?
---@return table<any, V>
function Utils.TableMap(tbl, callback)
  assert(type(tbl) == "table", "Must be a table!")
  local t = {}
  Utils.TableForEach(tbl, function(v, k)
    local newv, newk = callback(v, k)
    t[newk and newk or k] = newv
  end)
  return t
end

---Run a callback on each table item
---@generic T
---@param tbl table<any, T>
---@param callback fun(value: T, index: any)
---@return table<any, T>
function Utils.TableForEach(tbl, callback)
  assert(type(tbl) == "table", "Must be a table!")
  for ik, iv in pairs(tbl) do
    callback(iv, ik)
  end
  return tbl
end

---Iterate table keys sorted by optional order field (AceConfig-style). Yields key.
---@param tbl table
---@return fun(): string?, any
function Utils.SortedPairs(tbl)
  local keys = {}
  for k in pairs(tbl) do
    keys[#keys + 1] = k
  end
  local orderVal = function(k)
    local v = tbl[k]
    if type(v) == "table" and type(v.order) == "number" then
      return v.order
    end
    return 100
  end
  table.sort(keys, function(a, b) return orderVal(a) < orderVal(b) end)
  local i = 0
  return function()
    i = i + 1
    return keys[i]
  end
end

---Highlight mixin: overlay for hover/selection. Use Mixin(frame, LiqUI.Mixins.Highlight).
---Call SetVertexColor(r,g,b,a) then ShowHighlight() / HideHighlight(); does not override frame Show/Hide.
---@class LiqUI_HighlightMixin
LiqUI.Mixins = {}
LiqUI.Mixins.Highlight = {}
local Highlight = LiqUI.Mixins.Highlight

function Highlight:SetHighlightColor(r, g, b, a)
  if not self.Highlight then
    self.Highlight = self:CreateTexture("Highlight", "OVERLAY")
    self.Highlight:SetTexture("Interface/BUTTONS/WHITE8X8")
    self.Highlight:SetAllPoints()
    self.Highlight:Hide()
  end
  r = r or 1
  g = g or 1
  b = b or 1
  a = a or 0.05
  self.Highlight:SetVertexColor(r, g, b, a)
end

function Highlight:ShowHighlight(r, g, b, a)
  if not self.Highlight then
    self:SetHighlightColor(r, g, b, a)
  elseif r then
    self:SetHighlightColor(r, g, b, a)
  end
  self.Highlight:Show()
end

function Highlight:HideHighlight()
  if not self.Highlight then
    return
  end
  self.Highlight:Hide()
end

---@param parent Frame
---@param r number|ColorTable?
---@param g number?
---@param b number?
---@param a number?
function Utils.SetBackgroundColor(parent, r, g, b, a)
  if not parent.Background then
    parent.Background = parent:CreateTexture("Background", "BACKGROUND")
    parent.Background:SetTexture("Interface/BUTTONS/WHITE8X8")
    parent.Background:SetAllPoints()
  end

  if type(r) == "table" then
    r, g, b, a = r.r, r.g, r.b, r.a
  end

  if type(r) == "nil" then
    r, g, b, a = 0, 0, 0, 0.1
  end

  parent.Background:SetVertexColor(r, g, b, a)
end

---@param parent Frame
---@param r number|ColorTable?
---@param g number?
---@param b number?
---@param a number?
function Utils.SetHighlightColor(parent, r, g, b, a)
  if not parent.Highlight then
    parent.Highlight = parent:CreateTexture("Highlight", "OVERLAY")
    parent.Highlight:SetTexture("Interface/BUTTONS/WHITE8X8")
    parent.Highlight:SetAllPoints()
  end

  if type(r) == "table" then
    r, g, b, a = r.r, r.g, r.b, r.a
  end

  if r == nil then
    r = 1
  end
  if g == nil then
    g = 1
  end
  if b == nil then
    b = 1
  end
  if a == nil then
    a = 0.05
  end
  parent.Highlight:SetVertexColor(r, g, b, a)
end

---Merge two table arrays
---@generic T
---@param tbl1 T[]
---@param tbl2 T[]
---@param preserveKeys boolean?
---@return T[]
function Utils.TableMerge(tbl1, tbl2, preserveKeys)
  assert(type(tbl1) == "table", "Must be a table!")
  assert(type(tbl2) == "table", "Must be a table!")
  Utils.TableForEach(tbl2, function(v, k)
    if preserveKeys then
      tbl1[k] = v
    else
      table.insert(tbl1, v)
    end
  end)
  return tbl1
end

---Check if a table contains a specific value
---@generic T
---@param tbl T[]
---@param value T
---@return boolean
function Utils.TableContains(tbl, value)
  assert(type(tbl) == "table", "Must be a table!")
  for _, v in pairs(tbl) do
    if v == value then
      return true
    end
  end
  return false
end

---Toggle a value in a table
---@generic T
---@param tbl T[]
---@param value T
---@return T[]
function Utils.TableToggle(tbl, value)
  if Utils.TableContains(tbl, value) then
    return Utils.TableFilter(tbl, function(v)
      return v ~= value
    end)
  end
  return Utils.TableMerge(tbl, {value})
end

---Remove duplicates from a table
---@generic T
---@param tbl T[]
---@return T[]
function Utils.TableUnique(tbl)
  assert(type(tbl) == "table", "Must be a table!")
  local seen = {}
  for _, v in pairs(tbl) do
    seen[v] = true
  end

  local unique = {}
  for v in pairs(seen) do
    table.insert(unique, v)
  end
  return unique
end

local scrollAreaCounter = 0

local SCROLLBAR_TRACK_BACKGROUND_ALPHA = 0.2

---@param scrollBar EventFrame
local function hideScrollBarBackground(scrollBar)
  if not scrollBar.Background then
    return
  end
  if scrollBar.Background.Begin then
    scrollBar.Background.Begin:Hide()
  end
  if scrollBar.Background.Middle then
    scrollBar.Background.Middle:Hide()
  end
  if scrollBar.Background.End then
    scrollBar.Background.End:Hide()
  end
  scrollBar.Background:Hide()
end

---@param scrollBar EventFrame
---@param track Frame
local function styleScrollBarTrack(scrollBar, track)
  if track.Begin then
    track.Begin:Hide()
  end
  if track.Middle then
    track.Middle:Hide()
  end
  if track.End then
    track.End:Hide()
  end
  track:ClearAllPoints()
  track:SetPoint("TOPLEFT", scrollBar, "TOPLEFT", 0, 0)
  track:SetPoint("BOTTOMRIGHT", scrollBar, "BOTTOMRIGHT", 0, 0)

  if not track.styledBackground then
    local trackBackground = track:CreateTexture(nil, "BACKGROUND")
    track.styledBackground = trackBackground
    trackBackground:SetAllPoints()
    trackBackground:SetColorTexture(0, 0, 0, SCROLLBAR_TRACK_BACKGROUND_ALPHA)
  end
end

---@param thumb Frame
---@param crossAxisSize number
---@param isHorizontal boolean
local function styleScrollBarThumb(thumb, crossAxisSize, isHorizontal)
  if thumb.styledOverlay then
    if isHorizontal then
      thumb:SetHeight(crossAxisSize)
    else
      thumb:SetWidth(crossAxisSize)
    end
    return
  end
  thumb.styledOverlay = true
  if thumb.Begin then
    thumb.Begin:Hide()
  end
  if thumb.Middle then
    thumb.Middle:Hide()
  end
  if thumb.End then
    thumb.End:Hide()
  end

  local thumbColor = thumb:CreateTexture(nil, "ARTWORK")
  thumbColor:SetAllPoints()
  thumbColor:SetColorTexture(1, 1, 1, 0.15)

  thumb:HookScript("OnEnter", function()
    thumbColor:SetColorTexture(1, 1, 1, 0.2)
  end)
  thumb:HookScript("OnLeave", function()
    thumbColor:SetColorTexture(1, 1, 1, 0.15)
  end)

  if isHorizontal then
    thumb:SetHeight(crossAxisSize)
  else
    thumb:SetWidth(crossAxisSize)
  end
end

---@param scrollBar EventFrame
function Utils.StyleVerticalScrollBar(scrollBar)
  local scrollbarThickness = LiqUI.Constants.layout.sizes.scrollbar.thickness
  scrollBar:SetWidth(scrollbarThickness)

  scrollBar:GetBackStepper():Hide()
  scrollBar:GetForwardStepper():Hide()
  hideScrollBarBackground(scrollBar)
  styleScrollBarTrack(scrollBar, scrollBar:GetTrack())
  styleScrollBarThumb(scrollBar:GetThumb(), scrollbarThickness, false)
end

---@param scrollBar EventFrame
function Utils.StyleHorizontalScrollBar(scrollBar)
  local scrollbarThickness = LiqUI.Constants.layout.sizes.scrollbar.thickness
  scrollBar:SetHeight(scrollbarThickness)

  scrollBar:GetBackStepper():Hide()
  scrollBar:GetForwardStepper():Hide()
  hideScrollBarBackground(scrollBar)
  styleScrollBarTrack(scrollBar, scrollBar:GetTrack())
  styleScrollBarThumb(scrollBar:GetThumb(), scrollbarThickness, true)
end

---Wheel hits row/column buttons, not the scroll box. Forward to Blizzard scroll APIs on the outer box.
---@param frame Frame
---@param scrollBox Frame
function Utils.BindScrollBoxMouseWheel(frame, scrollBox)
  frame:EnableMouseWheel(true)
  frame:SetScript("OnMouseWheel", function(_, delta)
    if delta < 0 then
      scrollBox:ScrollIncrease(1)
    else
      scrollBox:ScrollDecrease(1)
    end
  end)
end

---@param scrollBox Frame
---@param panExtent number
local function applyOuterWheelPanExtent(scrollBox, panExtent)
  if panExtent > 0 then
    scrollBox:SetPanExtent(panExtent)
  end
end

---@param scrollBox Frame
local function hideScrollBoxShadows(scrollBox)
  if scrollBox.Shadows then
    scrollBox.Shadows:Hide()
  end
end

---@param scrollArea LiqUI_ScrollArea
---@param contentWidth number|nil
---@param contentHeight number|nil
local function updateScrollAreaLayout(scrollArea, contentWidth, contentHeight)
  local overflowTolerance = LiqUI.Constants.layout.sizes.scrollbar.overflowTolerance

  contentWidth = contentWidth or scrollArea.content:GetWidth()
  contentHeight = contentHeight or scrollArea.content:GetHeight()

  local containerWidth = scrollArea.container:GetWidth()
  local containerHeight = scrollArea.container:GetHeight()
  if containerWidth <= 0 or containerHeight <= 0 then
    return
  end

  local layoutContentWidth = contentWidth
  local layoutContentHeight = contentHeight
  if scrollArea.vertical and contentHeight <= containerHeight + overflowTolerance then
    layoutContentHeight = containerHeight
  end
  if scrollArea.horizontal and contentWidth <= containerWidth + overflowTolerance then
    layoutContentWidth = containerWidth
  end
  scrollArea.content:SetSize(layoutContentWidth, layoutContentHeight)

  if scrollArea.verticalScrollBox then
    scrollArea.verticalScrollBox:ClearAllPoints()
    scrollArea.verticalScrollBox:SetPoint("TOPLEFT", scrollArea.container, "TOPLEFT", 0, 0)
    scrollArea.verticalScrollBox:SetPoint("BOTTOMRIGHT", scrollArea.container, "BOTTOMRIGHT", 0, 0)
  end

  if scrollArea.horizontalScrollBox then
    scrollArea.horizontalScrollBox:ClearAllPoints()
    if scrollArea.horizontal and scrollArea.vertical then
      scrollArea.horizontalScrollBox:SetWidth(containerWidth)
      scrollArea.horizontalScrollBox:SetHeight(contentHeight)
    else
      scrollArea.horizontalScrollBox:SetPoint("TOPLEFT", scrollArea.container, "TOPLEFT", 0, 0)
      scrollArea.horizontalScrollBox:SetPoint("BOTTOMRIGHT", scrollArea.container, "BOTTOMRIGHT", 0, 0)
    end
  end

  if scrollArea.horizontal and scrollArea.vertical then
    scrollArea.horizontalScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
    scrollArea.verticalScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
  elseif scrollArea.vertical then
    scrollArea.verticalScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
  elseif scrollArea.horizontal then
    scrollArea.horizontalScrollBox:FullUpdate(ScrollBoxConstants.UpdateImmediately)
  end

  local showVertical = false
  if scrollArea.vertical and scrollArea.verticalScrollBox then
    if contentHeight > containerHeight + overflowTolerance then
      local scrollRange = scrollArea.verticalScrollBox:GetDerivedScrollRange()
      if scrollRange > overflowTolerance and scrollArea.verticalScrollBox:HasScrollableExtent() then
        showVertical = true
      else
        scrollArea.verticalScrollBox:ScrollToBegin()
      end
    else
      scrollArea.verticalScrollBox:ScrollToBegin()
    end
  end

  local showHorizontal = false
  if scrollArea.horizontal and scrollArea.horizontalScrollBox then
    if contentWidth > containerWidth + overflowTolerance then
      local scrollRange = scrollArea.horizontalScrollBox:GetDerivedScrollRange()
      if scrollRange > overflowTolerance and scrollArea.horizontalScrollBox:HasScrollableExtent() then
        showHorizontal = true
      else
        scrollArea.horizontalScrollBox:ScrollToBegin()
      end
    else
      scrollArea.horizontalScrollBox:ScrollToBegin()
    end
  end

  local wheelScrollBox = scrollArea:GetWheelScrollBox()
  if wheelScrollBox then
    applyOuterWheelPanExtent(wheelScrollBox, scrollArea.wheelPanExtent)
  end

  if scrollArea.verticalScrollBar then
    scrollArea.verticalScrollBar:SetShown(showVertical)
    scrollArea.verticalScrollBar:SetHideIfUnscrollable(true)
    scrollArea.verticalScrollBar:ClearAllPoints()
    scrollArea.verticalScrollBar:SetPoint("TOPRIGHT", scrollArea.container, "TOPRIGHT", 0, 0)
    scrollArea.verticalScrollBar:SetPoint("BOTTOMRIGHT", scrollArea.container, "BOTTOMRIGHT", 0, 0)
  end

  if scrollArea.horizontalScrollBar then
    scrollArea.horizontalScrollBar:SetShown(showHorizontal)
    scrollArea.horizontalScrollBar:SetHideIfUnscrollable(true)
    scrollArea.horizontalScrollBar:SetHeight(LiqUI.Constants.layout.sizes.scrollbar.thickness)
    scrollArea.horizontalScrollBar:ClearAllPoints()
    scrollArea.horizontalScrollBar:SetPoint("BOTTOMLEFT", scrollArea.container, "BOTTOMLEFT", 0, 0)
    scrollArea.horizontalScrollBar:SetPoint("BOTTOMRIGHT", scrollArea.container, "BOTTOMRIGHT", 0, 0)
  end

  if not showVertical and scrollArea.verticalScrollBox then
    scrollArea.verticalScrollBox:ScrollToBegin()
  end
  if not showHorizontal and scrollArea.horizontalScrollBox then
    scrollArea.horizontalScrollBox:ScrollToBegin()
  end
end

---WowScrollBox viewport with optional horizontal and/or vertical scrolling.
---@param parent Frame
---@param options LiqUI_ScrollAreaOptions?
---@return LiqUI_ScrollArea
function Utils.CreateScrollArea(parent, options)
  local horizontal = options and options.horizontal or false
  local vertical = options and options.vertical or false
  if not horizontal and not vertical then
    error("LiqUI scroll area requires horizontal and/or vertical", 2)
  end

  local containerName = options and options.name
  if not containerName then
    scrollAreaCounter = scrollAreaCounter + 1
    containerName = "LiqUIScrollArea" .. scrollAreaCounter
  end

  local containerFrame = CreateFrame("Frame", containerName, parent)
  local contentFrame = CreateFrame("Frame", "$parentContent", containerFrame)
  contentFrame.scrollable = true

  local verticalScrollBox
  local verticalScrollBar
  local verticalView
  local horizontalScrollBox
  local horizontalScrollBar
  local horizontalView

  if vertical then
    verticalScrollBox = CreateFrame("Frame", "$parentVerticalScrollBox", containerFrame, "WowScrollBox")
    verticalScrollBar = CreateFrame("EventFrame", "$parentVerticalScrollBar", containerFrame, "MinimalScrollBar")
    Utils.StyleVerticalScrollBar(verticalScrollBar)
    hideScrollBoxShadows(verticalScrollBox)
    verticalView = CreateScrollBoxLinearView()
  end

  if horizontal then
    horizontalScrollBox = CreateFrame("Frame", "$parentHorizontalScrollBox", containerFrame, "WowScrollBox")
    horizontalScrollBar = CreateFrame("EventFrame", "$parentHorizontalScrollBar", containerFrame, "WowTrimHorizontalScrollBar")
    Utils.StyleHorizontalScrollBar(horizontalScrollBar)
    hideScrollBoxShadows(horizontalScrollBox)
    horizontalView = CreateScrollBoxLinearView()
    horizontalView:SetHorizontal(true)
  end

  if horizontal and vertical then
    horizontalScrollBox.scrollable = true
    horizontalScrollBox:SetParent(verticalScrollBox)
    contentFrame:SetParent(horizontalScrollBox)
    ScrollUtil.InitScrollBoxWithScrollBar(horizontalScrollBox, horizontalScrollBar, horizontalView)
    ScrollUtil.InitDefaultLinearDragBehavior(horizontalScrollBox)
    ScrollUtil.InitScrollBoxWithScrollBar(verticalScrollBox, verticalScrollBar, verticalView)
    ScrollUtil.InitDefaultLinearDragBehavior(verticalScrollBox)
  elseif vertical then
    contentFrame:SetParent(verticalScrollBox)
    ScrollUtil.InitScrollBoxWithScrollBar(verticalScrollBox, verticalScrollBar, verticalView)
    ScrollUtil.InitDefaultLinearDragBehavior(verticalScrollBox)
  else
    contentFrame:SetParent(horizontalScrollBox)
    ScrollUtil.InitScrollBoxWithScrollBar(horizontalScrollBox, horizontalScrollBar, horizontalView)
    ScrollUtil.InitDefaultLinearDragBehavior(horizontalScrollBox)
  end

  local defaultPanExtent = vertical and LiqUI.Constants.layout.sizes.row or
    LiqUI.Constants.layout.sizes.scrollbar.horizontalWheelPanExtent
  local wheelPanExtent = (options and options.wheelPanExtent) or defaultPanExtent

  ---@type LiqUI_ScrollArea
  local scrollArea = {
    container = containerFrame,
    content = contentFrame,
    horizontal = horizontal,
    vertical = vertical,
    verticalScrollBox = verticalScrollBox,
    verticalScrollBar = verticalScrollBar,
    horizontalScrollBox = horizontalScrollBox,
    horizontalScrollBar = horizontalScrollBar,
    wheelPanExtent = wheelPanExtent,
  }

  ---@return Frame
  function scrollArea:GetWheelScrollBox()
    if self.verticalScrollBox then
      return self.verticalScrollBox
    end
    return self.horizontalScrollBox
  end

  function scrollArea:SetParent(...)
    return self.container:SetParent(...)
  end

  function scrollArea:SetPoint(...)
    return self.container:SetPoint(...)
  end

  function scrollArea:SetAllPoints(...)
    return self.container:SetAllPoints(...)
  end

  function scrollArea:ClearAllPoints()
    return self.container:ClearAllPoints()
  end

  function scrollArea:HookScript(...)
    return self.container:HookScript(...)
  end

  function scrollArea:GetWidth()
    return self.container:GetWidth()
  end

  function scrollArea:GetHeight()
    return self.container:GetHeight()
  end

  function scrollArea:UpdateLayout(contentWidth, contentHeight)
    updateScrollAreaLayout(self, contentWidth, contentHeight)
  end

  function scrollArea:ScrollToTop()
    self:UpdateLayout()
    local wheelScrollBox = self:GetWheelScrollBox()
    if wheelScrollBox then
      wheelScrollBox:ScrollToBegin()
    end
  end

  ---@param pixels number
  function scrollArea:SetWheelPanExtent(pixels)
    self.wheelPanExtent = pixels
    local wheelScrollBox = self:GetWheelScrollBox()
    if wheelScrollBox then
      applyOuterWheelPanExtent(wheelScrollBox, pixels)
    end
  end

  local wheelScrollBox = scrollArea:GetWheelScrollBox()
  if wheelScrollBox then
    applyOuterWheelPanExtent(wheelScrollBox, wheelPanExtent)
    Utils.BindScrollBoxMouseWheel(containerFrame, wheelScrollBox)
  end

  if verticalScrollBar then
    verticalScrollBar:SetFrameLevel(containerFrame:GetFrameLevel() + 10)
  end
  if horizontalScrollBar then
    horizontalScrollBar:SetFrameLevel(containerFrame:GetFrameLevel() + 10)
  end

  containerFrame:SetScript("OnSizeChanged", function()
    scrollArea:UpdateLayout()
  end)
  contentFrame:SetScript("OnSizeChanged", function()
    scrollArea:UpdateLayout()
  end)

  scrollArea:UpdateLayout(1, 1)
  return scrollArea
end

---Read-only scrolling text host (logger pattern). Text and bar share the same body inset; bar sits in the right padding gutter.
---@param parent Frame
---@param bodyPadding number?
---@return LiqUI_ScrollingEditBoxHost
function Utils.CreateScrollingEditBox(parent, bodyPadding)
  bodyPadding = bodyPadding or LiqUI.Constants.layout.sizes.padding
  local scrollbarThickness = LiqUI.Constants.layout.sizes.scrollbar.thickness

  local textBox = CreateFrame("Frame", "$parentTextBox", parent, "ScrollingEditBoxTemplate")
  textBox:SetPoint("TOPLEFT", parent, "TOPLEFT", bodyPadding, -bodyPadding)
  textBox:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -(bodyPadding + scrollbarThickness), bodyPadding)

  local scrollBar = CreateFrame("EventFrame", "$parentScrollBar", parent, "MinimalScrollBar")
  scrollBar:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -bodyPadding, -bodyPadding)
  scrollBar:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -bodyPadding, bodyPadding)
  Utils.StyleVerticalScrollBar(scrollBar)
  scrollBar:SetHideIfUnscrollable(true)

  local scrollBox = textBox:GetScrollBox()
  ScrollUtil.RegisterScrollBoxWithScrollBar(scrollBox, scrollBar)

  scrollBar:SetFrameLevel(textBox:GetFrameLevel() + 10)

  ---@type LiqUI_ScrollingEditBoxHost
  return {
    textBox = textBox,
    scrollBar = scrollBar,
  }
end

---Create a scrollable content area using Blizzard WowScrollBox + CreateScrollBoxLinearView + MinimalScrollBar.
---Parent content to .scrollChild and set its height; after content size changes call :FullUpdate(true).
---@param parent Frame
---@param name string?
---@param options { barWidth?: number }?
---@return Frame scrollBox WowScrollBox with .scrollChild, :FullUpdate(), :ScrollToBegin()
function Utils.CreateScrollBox(parent, name, options)
  options = options or {}
  local barWidth = options.barWidth or 12

  if not ScrollUtil or not CreateScrollBoxLinearView then
    error("LiqUI.CreateScrollBox requires Blizzard_SharedXML (ScrollUtil, CreateScrollBoxLinearView). Ensure UI is loaded.")
  end

  local scrollBox = CreateFrame("Frame", name, parent, "WowScrollBox")
  local scrollBar = CreateFrame("EventFrame", nil, parent, "MinimalScrollBar")
  scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 0, 0)
  scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT", 0, 0)
  scrollBar:SetWidth(barWidth)

  local scrollArea = CreateFrame("Frame", nil, scrollBox)
  scrollArea.scrollable = true
  scrollArea:SetSize(1, 1)

  local inset = 0
  local view = CreateScrollBoxLinearView(inset, inset, inset, inset, 0)
  view:SetPanExtent(50)
  ScrollUtil.InitScrollBoxWithScrollBar(scrollBox, scrollBar, view)
  scrollBar:SetHideIfUnscrollable(true)

  scrollBox.scrollChild = scrollArea
  scrollBox.ScrollBar = scrollBar

  scrollBox:SetScript("OnSizeChanged", function()
    local width = scrollBox:GetWidth()
    if width and width > 0 then
      scrollArea:SetWidth(width)
    end
  end)

  return scrollBox
end

---@param value any
---@return boolean
local function isRegionObject(value)
  return type(value) == "table" and type(value.IsObjectType) == "function"
end

---Merge keys from source into destination; nested plain tables are merged recursively.
---@param destination table
---@param source table?
---@return table
function Utils.TableMergeOptions(destination, source)
  if not source then
    return destination
  end
  for key, value in pairs(source) do
    if type(value) == "table" and not isRegionObject(value) then
      local existing = destination[key]
      if type(existing) == "table" and not isRegionObject(existing) then
        Utils.TableMergeOptions(existing, value)
      else
        destination[key] = {}
        Utils.TableMergeOptions(destination[key], value)
      end
    else
      destination[key] = value
    end
  end
  return destination
end
