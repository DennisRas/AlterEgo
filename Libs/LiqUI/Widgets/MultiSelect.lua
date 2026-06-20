---Multi-select dropdown: click to open list with checkboxes; multiple options can be selected.
local C = LiqUI.Constants

local MultiSelectDefaults = {
  width = C.control.dropdownWidth,
  height = C.control.dropdownItemHeight,
  padding = C.control.padding,
  dropdownItemHeight = C.control.dropdownItemHeight,
  dropdownListMaxHeight = C.control.dropdownListMaxHeight,
  checkSizeSmall = C.control.checkSizeSmall,
  textColor = C.text.defaultColor,
  disabled = false,
  values = {},
  get = nil,
  set = nil,
}

function LiqUI.Widgets.CreateMultiSelect(parent, options)
  local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  Mixin(frame, LiqUI.Widgets.BaseMixin)
  frame.options = frame:Init(MultiSelectDefaults, options)
  local opts = frame.options
  local values = opts.values or {}
  local width = opts.width
  local get, set = opts.get, opts.set

  local function updateSummary()
    local n = 0
    for k in pairs(values) do
      if get and get(k) then n = n + 1 end
    end
    frame.label:SetText(n > 0 and ("%d selected"):format(n) or "None")
  end

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
    list.child.rows = list.child.rows or {}
    for i, key in ipairs(keys) do
      local row = list.child.rows[i]
      if not row then
        row = CreateFrame("Frame", nil, list.child)
        row:SetHeight(opts.dropdownItemHeight - 2)
        local checkBox = CreateFrame("Frame", nil, row, "BackdropTemplate")
        checkBox:SetPoint("LEFT", row, "LEFT", 2, 0)
        checkBox:SetSize(opts.checkSizeSmall, opts.checkSizeSmall)
        Mixin(checkBox, LiqUI.Widgets.BaseMixin)
        checkBox.options = checkBox:Init({ width = opts.checkSizeSmall, height = opts.checkSizeSmall }, {})
        local check = CreateFrame("CheckButton", nil, checkBox)
        check:SetAllPoints(checkBox)
        check:SetScript("OnEnter", function() checkBox:SetBorderState("highlight") end)
        check:SetScript("OnLeave", function() checkBox:SetBorderState("normal") end)
        local tex = check:CreateTexture(nil, "OVERLAY")
        tex:SetPoint("CENTER")
        tex:SetSize(opts.checkSizeSmall - 4, opts.checkSizeSmall - 4)
        tex:SetTexture("Interface/Buttons/UI-CheckBox-Check")
        tex:SetVertexColor(1, 1, 1, 1)
        check.tex = tex
        check:SetScript("OnClick", function()
          local checked = check:GetChecked()
          tex:SetShown(checked)
          if set then set(key, checked) end
          updateSummary()
        end)
        row.check = check
        row.label = LiqUI.Utils.CreateLabel(row, nil, { point = "LEFT", relativeTo = checkBox, relativePoint = "RIGHT", x = 4, y = 0 })
        row.label:SetJustifyH("LEFT")
        table.insert(list.child.rows, row)
      end
      row:SetPoint("TOPLEFT", list.child, "TOPLEFT", 2, -(i - 1) * opts.dropdownItemHeight)
      row:SetPoint("TOPRIGHT", list.child, "TOPRIGHT", -2, -(i - 1) * opts.dropdownItemHeight)
      row.label:SetText(values[key])
      local checked = get and get(key)
      row.check:SetChecked(checked)
      row.check.tex:SetShown(checked)
      row:Show()
    end
    for i = numItems + 1, #list.child.rows do list.child.rows[i]:Hide() end
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

  function frame:Refresh()
    updateSummary()
  end
  function frame:TriggerFromLabel()
    triggerBtn:Click()
  end

  updateSummary()
  if opts.disabled then
    triggerBtn:Disable()
    frame:SetAlpha(0.5)
  end
  return frame
end
