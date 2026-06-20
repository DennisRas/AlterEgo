local C = LiqUI.Constants

local HeaderDefaults = {
  text = "",
  fontObject = "GameFontNormalLarge",
  textColor = C.text.defaultColor,
}

function LiqUI.Widgets.CreateHeader(parent, options)
  local frame = CreateFrame("Frame", nil, parent)
  local opts = LiqUI.Utils.PrepareOptions(HeaderDefaults, options or {})
  frame.options = opts

  local fontString = frame:CreateFontString(nil, "OVERLAY", opts.fontObject)
  fontString:SetPoint("TOPLEFT")
  fontString:SetPoint("TOPRIGHT")
  fontString:SetWordWrap(true)
  fontString:SetJustifyH("LEFT")
  fontString:SetText(opts.text or "")
  fontString:SetTextColor(opts.textColor:GetRGBA())
  frame.fontString = fontString

  frame:SetHeight(math.max(20, fontString:GetStringHeight()))
  frame:SetScript("OnSizeChanged", function(self)
    self:SetHeight(math.max(20, fontString:GetStringHeight()))
  end)

  function frame:SetText(t)
    fontString:SetText(t or "")
    frame:SetHeight(math.max(20, fontString:GetStringHeight()))
  end

  return frame
end
