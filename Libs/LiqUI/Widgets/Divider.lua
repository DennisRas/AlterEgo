local C = LiqUI.Constants

local DividerDefaults = {
  lineColor = C.form.headerLineColor,
  lineHeight = 1,
  gapAfter = 20,
}

function LiqUI.Widgets.CreateDivider(parent, options)
  local frame = CreateFrame("Frame", nil, parent)
  local opts = LiqUI.Utils.PrepareOptions(DividerDefaults, options or {})
  frame.options = opts

  local line = frame:CreateTexture(nil, "OVERLAY")
  line:SetColorTexture(opts.lineColor:GetRGBA())
  line:SetHeight(opts.lineHeight)
  line:SetPoint("TOPLEFT")
  line:SetPoint("TOPRIGHT")
  frame.line = line

  local totalHeight = opts.lineHeight + opts.gapAfter
  frame:SetHeight(totalHeight)

  return frame
end
