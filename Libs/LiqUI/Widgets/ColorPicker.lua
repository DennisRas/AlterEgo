local C = LiqUI.Constants

local ColorPickerDefaults = {
  width = C.control.colorPickerSwatchSize * 2,
  height = C.control.colorPickerSwatchSize,
  border = true,
  disabled = false,
  r = 1,
  g = 1,
  b = 1,
  a = 1,
  hasAlpha = nil,
  OnValueChanged = nil
}

function LiqUI.Widgets.CreateColorPicker(parent, options)
  local frame = CreateFrame("Button", nil, parent, "BackdropTemplate")
  Mixin(frame, LiqUI.Widgets.BaseMixin)
  frame.options = frame:Init(ColorPickerDefaults, options)
  local opts = frame.options
  local r, g, b, a = opts.r, opts.g, opts.b, opts.a
  frame:SetBackdropColor(r, g, b, a)

  frame:SetScript("OnClick", function()
    local previous = { r = r, g = g, b = b, a = a }
    ColorPickerFrame:SetupColorPickerAndShow({
      r = r,
      g = g,
      b = b,
      opacity = a,
      hasOpacity = opts.hasAlpha,
      swatchFunc = function()
        local nr, ng, nb = ColorPickerFrame:GetColorRGB()
        local na = opts.hasAlpha and ColorPickerFrame:GetColorAlpha() or 1
        frame:SetValue(nr, ng, nb, na)
        if opts.OnValueChanged then opts.OnValueChanged(nr, ng, nb, na) end
      end,
      cancelFunc = function()
        frame:SetValue(previous.r, previous.g, previous.b, previous.a)
      end,
    })
  end)

  function frame:GetValue()
    return r, g, b, a
  end

  function frame:SetValue(nr, ng, nb, na)
    r, g, b = nr or r, ng or g, nb or b
    a = (na ~= nil) and na or a
    self:SetBackdropColor(r, g, b, a)
  end

  if opts.disabled then
    frame:Disable()
    frame:SetAlpha(0.5)
  end
  return frame
end
