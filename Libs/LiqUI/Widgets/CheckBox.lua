local C = LiqUI.Constants

local CheckBoxDefaults = {
  width = C.control.checkSize,
  height = C.control.checkSize,
  padding = C.control.padding,
  label = nil,
  checked = false,
  disabled = false,
  checkedColor = C.primary.defaultColor,
  hoverColor = C.text.mutedColor,
  OnValueChanged = nil,
}

function LiqUI.Widgets.CreateCheckBox(parent, options)
  local frame = CreateFrame("Button", nil, parent, "BackdropTemplate")
  Mixin(frame, LiqUI.Widgets.BaseMixin)
  frame.options = frame:Init(CheckBoxDefaults, options)

  local innerSize = math.max(2, frame.options.width / 2)
  local checkedTexture = frame:CreateTexture(nil, "OVERLAY")
  checkedTexture:SetPoint("CENTER")
  checkedTexture:SetSize(innerSize, innerSize)
  frame.checkedTexture = checkedTexture

  local checked = frame.options.checked and true or false
  local hovered = false
  local opts = frame.options
  local function UpdateVisual()
    if checked then
      checkedTexture:SetColorTexture(opts.checkedColor:GetRGBA())
      checkedTexture:Show()
    elseif frame:IsEnabled() and hovered then
      checkedTexture:SetColorTexture(opts.hoverColor:GetRGBA())
      checkedTexture:Show()
    else
      checkedTexture:Hide()
    end
  end
  UpdateVisual()

  frame:SetScript("OnEnter", function()
    hovered = true
    frame:SetBorderState("highlight")
    UpdateVisual()
  end)
  frame:SetScript("OnLeave", function()
    hovered = false
    frame:SetBorderState("normal")
    UpdateVisual()
  end)

  if frame.options.label and frame.options.label ~= "" then
    frame.label = LiqUI.Utils.CreateLabel(parent, frame.options.label,
      { point = "RIGHT", relativeTo = frame, relativePoint = "LEFT", x = -frame.options.padding, y = 0 })
    frame.label:SetJustifyH("RIGHT")
  end

  frame:SetScript("OnClick", function()
    checked = not checked
    UpdateVisual()
    if frame.options.OnValueChanged then frame.options.OnValueChanged(checked) end
  end)

  function frame:GetValue()
    return checked
  end

  function frame:SetValue(val)
    checked = val and true or false
    UpdateVisual()
  end

  if frame.options.disabled then
    frame:Disable()
    frame:SetAlpha(0.5)
  end
  return frame
end
