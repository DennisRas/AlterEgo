---Single-select dropdown. Click to open list; choose one option.
local C = LiqUI.Constants

local DropdownDefaults = {
  width = C.control.dropdownWidth,
  height = C.control.dropdownItemHeight,
  padding = C.control.padding,
  dropdownItemHeight = C.control.dropdownItemHeight,
  dropdownListMaxHeight = C.control.dropdownListMaxHeight,
  textColor = C.text.defaultColor,
  disabled = false,
  values = {},
  value = nil,
  OnValueChanged = nil,
}

function LiqUI.Widgets.CreateDropdown(parent, options)
  local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  Mixin(frame, LiqUI.Widgets.BaseMixin)
  frame.options = frame:Init(DropdownDefaults, options)
  local opts = frame.options
  local values = opts.values or {}
  local width = opts.width
  local current = opts.value

  local triggerBtn = CreateFrame("Button", nil, frame)
  triggerBtn:SetAllPoints(frame)
  triggerBtn:SetScript("OnEnter", function()
    frame:SetBorderState("highlight")
  end)
  triggerBtn:SetScript("OnLeave", function()
    if not frame.listFrame or not frame.listFrame:IsShown() then
      frame:SetBorderState("normal")
    end
  end)
  triggerBtn:SetScript("OnClick", function()
    if frame.listFrame and frame.listFrame:IsShown() then
      frame.listFrame:Hide()
      frame:SetBorderState("normal")
      return
    end
    local list = frame.listFrame
    if not list then
      list = CreateFrame("Frame", nil, frame, "BackdropTemplate")
      list:SetSize(width, opts.dropdownListMaxHeight)
      list:SetFrameStrata("TOOLTIP")
      Mixin(list, LiqUI.Widgets.BaseMixin)
      list.options = list:Init({}, { width = width, height = opts.dropdownListMaxHeight })
      list:SetClampedToScreen(true)
      list.scroll = CreateFrame("ScrollFrame", nil, list, "UIPanelScrollFrameTemplate")
      list.scroll:SetPoint("TOPLEFT", list, "TOPLEFT", 2, -2)
      list.scroll:SetPoint("BOTTOMRIGHT", list, "BOTTOMRIGHT", -2, 2)
      list.child = CreateFrame("Frame", nil, list.scroll)
      list.child:SetWidth(width - 8)
      list.scroll:SetScrollChild(list.child)
      frame.listFrame = list
    end
    list:ClearAllPoints()
    list:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -2)
    list:SetWidth(width)
    local keys = {}
    for k in pairs(values) do keys[#keys + 1] = k end
    table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
    local numItems = #keys
    local listHeight = math.min(opts.dropdownListMaxHeight, numItems * opts.dropdownItemHeight + 4)
    list:SetHeight(listHeight)
    list.child:SetHeight(numItems * opts.dropdownItemHeight)
    list.child:SetWidth(width - 8)
    for _, c in ipairs(list.child.buttons or {}) do c:Hide() end
    list.child.buttons = list.child.buttons or {}
    local idx = 0
    for _, key in ipairs(keys) do
      idx = idx + 1
      local itemBtn = list.child.buttons[idx]
      if not itemBtn then
        itemBtn = CreateFrame("Button", nil, list.child, "BackdropTemplate")
        Mixin(itemBtn, LiqUI.Widgets.BaseMixin)
        itemBtn.options = itemBtn:Init({ width = width - 8, height = opts.dropdownItemHeight - 2 }, {})
        itemBtn.label = LiqUI.Utils.CreateLabel(itemBtn, nil, { point = "LEFT", relativeTo = itemBtn, relativePoint = "LEFT", x = opts.padding, y = 0 })
        itemBtn.label:SetJustifyH("LEFT")
        table.insert(list.child.buttons, itemBtn)
      end
      itemBtn:SetPoint("TOPLEFT", list.child, "TOPLEFT", 2, -(idx - 1) * opts.dropdownItemHeight)
      itemBtn:SetPoint("TOPRIGHT", list.child, "TOPRIGHT", -2, -(idx - 1) * opts.dropdownItemHeight)
      itemBtn.label:SetText(values[key])
      itemBtn.key = key
      itemBtn:SetScript("OnClick", function()
        frame:SetValue(key)
        list:Hide()
        frame:SetBorderState("normal")
        if opts.OnValueChanged then opts.OnValueChanged(key) end
      end)
      itemBtn:Show()
    end
    for i = idx + 1, #list.child.buttons do list.child.buttons[i]:Hide() end
    list:Show()
    frame:SetBorderState("highlight")
  end)

  frame.label = LiqUI.Utils.CreateLabel(frame, nil, { point = "LEFT", relativeTo = frame, relativePoint = "LEFT", x = opts.padding, y = 0 })
  frame.label:SetPoint("RIGHT", frame, "RIGHT", -24, 0)
  frame.label:SetJustifyH("LEFT")

  local arrow = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  arrow:SetPoint("RIGHT", frame, "RIGHT", -opts.padding, 0)
  arrow:SetText("▼")
  arrow:SetTextColor(opts.textColor:GetRGBA())

  function frame:GetValue()
    return current
  end
  function frame:SetValue(val)
    current = val
    local display = values[val]
    self.label:SetText(display and tostring(display) or tostring(val))
  end
  function frame:TriggerFromLabel()
    triggerBtn:Click()
  end

  frame:SetValue(current)
  if opts.disabled then
    triggerBtn:Disable()
    frame:SetAlpha(0.5)
  end
  return frame
end
