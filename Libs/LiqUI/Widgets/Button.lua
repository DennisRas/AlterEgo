local C = LiqUI.Constants

local ButtonDefaults = {
  width = C.control.buttonWidth,
  height = C.control.height,
  label = "Button",
  border = false,
  disabled = false,
  backgroundColor = C.primary.defaultColor,
  backgroundColorHover = C.primary.hoverColor,
  backgroundColorPressed = C.primary.pressedColor,
  OnClick = nil,
}

function LiqUI.Widgets.CreateButton(parent, options)
  local frame = CreateFrame("Button", nil, parent, "BackdropTemplate")
  Mixin(frame, LiqUI.Widgets.BaseMixin)
  frame.options = frame:Init(ButtonDefaults, options)
  frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  frame.text:SetAllPoints(frame)
  frame.text:SetJustifyH("CENTER")
  frame.text:SetJustifyV("MIDDLE")
  frame.text:SetText(frame.options.label)

  frame:SetScript("OnEnter", function()
    if not frame:IsEnabled() then return end
    frame:SetBorderState("highlight")
    frame:SetBackgroundState("highlight")
  end)
  frame:SetScript("OnLeave", function()
    if not frame:IsEnabled() then return end
    frame:SetBorderState("normal")
    frame:SetBackgroundState("normal")
  end)
  frame:SetScript("OnMouseDown", function()
    if not frame:IsEnabled() then return end
    frame:SetBackgroundState("pressed")
  end)
  frame:SetScript("OnMouseUp", function()
    if not frame:IsEnabled() then return end
    frame:SetBackgroundState("normal")
  end)
  frame:SetScript("OnClick", frame.options.OnClick or function() end)
  if frame.options.disabled then
    frame:Disable()
    frame:SetAlpha(0.5)
  else
    frame:SetBackdropColor(frame.options.backgroundColor:GetRGBA())
  end
  return frame
end
