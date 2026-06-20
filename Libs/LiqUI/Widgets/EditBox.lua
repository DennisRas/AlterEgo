local C = LiqUI.Constants

local EditBoxDefaults = {
  width = C.control.editBoxWidth,
  height = C.control.height,
  label = "",
  value = "",
  inputType = "text",
  disabled = false,
  editBoxTextPaddingH = C.control.editBoxTextPaddingH,
  textColor = C.text.defaultColor,
  backdropInsetLeft = (C.control.backdrop.insets and C.control.backdrop.insets.left) or 1,
  OnValueChanged = nil,
}

function LiqUI.Widgets.CreateEditBox(parent, options)
  local frame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
  Mixin(frame, LiqUI.Widgets.BaseMixin)
  frame.options = frame:Init(EditBoxDefaults, options)

  if frame.options.label and frame.options.label ~= "" then
    frame:SetHeight(frame.options.height * 2)
  end

  -- Label
  if frame.options.label and frame.options.label ~= "" then
    frame.label = LiqUI.Utils.CreateLabel(frame, frame.options.label,
      { point = "LEFT", relativeTo = frame, relativePoint = "LEFT", x = 0, y = 0 })
  end
  -- EditBox
  local editBox = CreateFrame("EditBox", "$parentEditBox", frame)
  editBox:SetSize(frame.options.width - frame.options.backdropInsetLeft * 4,
    frame.options.height - frame.options.backdropInsetLeft * 2)
  if frame.label then
    editBox:SetPoint("TOPLEFT", frame.label, "BOTTOMLEFT", frame.options.backdropInsetLeft, -2)
  else
    editBox:SetPoint("LEFT", frame, "LEFT", frame.options.backdropInsetLeft, 0)
  end
  editBox:SetAutoFocus(false)
  editBox:SetFontObject("GameFontHighlight")
  editBox:SetTextColor(frame.options.textColor:GetRGBA())
  editBox:SetTextInsets(frame.options.editBoxTextPaddingH, frame.options.editBoxTextPaddingH, 0, 0)
  editBox:SetText(tostring(frame.options.value or ""))
  frame.editBox = editBox

  local function updateBorderHover()
    if editBox:HasFocus() then return end
    frame:SetBorderState((frame:IsMouseOver() or editBox:IsMouseOver()) and "highlight" or "normal")
  end
  editBox:SetScript("OnEditFocusGained", function() frame:SetBorderState("focus") end)
  editBox:SetScript("OnEditFocusLost", function() updateBorderHover() end)
  frame:SetScript("OnEnter", function() if not editBox:HasFocus() then frame:SetBorderState("highlight") end end)
  frame:SetScript("OnLeave", function() if not editBox:HasFocus() then updateBorderHover() end end)
  editBox:SetScript("OnEnter", function() if not editBox:HasFocus() then frame:SetBorderState("highlight") end end)
  editBox:SetScript("OnLeave", function() if not editBox:HasFocus() then updateBorderHover() end end)

  if frame.options.OnValueChanged then
    editBox:SetScript("OnEnterPressed", function()
      frame.options.OnValueChanged(editBox:GetText())
      editBox:ClearFocus()
    end)
    editBox:SetScript("OnEscapePressed", function()
      editBox:SetText(tostring(frame.options.value or ""))
      editBox:ClearFocus()
    end)
  end

  function frame:GetValue()
    return editBox:GetText()
  end

  function frame:SetValue(val)
    editBox:SetText(tostring(val or ""))
  end

  if frame.options.disabled then
    editBox:Disable()
    frame:SetAlpha(0.5)
  end
  return frame
end
