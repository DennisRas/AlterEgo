---@class LiqUI
local LiqUI = _G.LiqUI
if not LiqUI then
  return
end

LiqUI.Layout = LiqUI.Layout or {}

local C = LiqUI.Constants
local DEFAULTS = { parent = UIParent, label = "", description = "", widget = nil }

local FormRow = {}
LiqUI.Layout.FormRow = FormRow

---@param options { parent?: Frame, label?: string, description?: string, widget: Frame }
---@return Frame row
function FormRow:New(options)
  local opts = LiqUI.Utils.PrepareOptions(DEFAULTS, options)
  local parent = opts.parent
  local widget = opts.widget
  if not widget then
    return parent
  end
  local widgetWidth = (type(widget.GetWidth) == "function" and widget:GetWidth()) or 200
  local labelText = opts.label or ""
  local descText = opts.description or ""

  local row = CreateFrame("Frame", nil, parent)
  row:SetHeight(24)

  local parentWidth = (parent and type(parent.GetWidth) == "function" and parent:GetWidth()) or 400
  local rowWidth = parentWidth - 2 * C.control.padding
  local leftWidth = math.max(1, rowWidth - widgetWidth - C.form.rowGap)

  -- Control: right column, same vertical line as label (TOP)
  local widgetHeight = 24
  if type(widget.GetHeight) == "function" then
    widgetHeight = widget:GetHeight() or widgetHeight
  end
  widget:SetParent(row)
  widget:ClearAllPoints()
  widget:SetPoint("TOPLEFT", row, "TOPRIGHT", -widgetWidth, 0)
  widget:SetPoint("TOPRIGHT", row, "TOPRIGHT", 0, 0)

  -- Label: left column; push down slightly so vertically aligned with control
  local labelFontString = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  labelFontString:SetPoint("TOPLEFT", row, "TOPLEFT", 0, C.form.labelOffsetY)
  labelFontString:SetPoint("TOPRIGHT", row, "TOPRIGHT", -(widgetWidth + C.form.rowGap), C.form.labelOffsetY)
  labelFontString:SetJustifyH("LEFT")
  labelFontString:SetJustifyV("TOP")
  labelFontString:SetTextColor(C.text.defaultColor:GetRGBA())
  labelFontString:SetText(labelText)
  labelFontString:SetWordWrap(false)
  local labelHeight = labelFontString:GetStringHeight() or 16

  -- Description: below label only
  local descHeight = 0
  local descriptionFontString
  if descText and descText ~= "" then
    descriptionFontString = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    descriptionFontString:SetPoint("TOPLEFT", labelFontString, "BOTTOMLEFT", 0, -C.form.labelDescGap)
    descriptionFontString:SetPoint("RIGHT", row, "RIGHT", -(widgetWidth + C.form.rowGap), 0)
    descriptionFontString:SetJustifyH("LEFT")
    descriptionFontString:SetJustifyV("TOP")
    descriptionFontString:SetTextColor(C.text.mutedColor:GetRGBA())
    descriptionFontString:SetWordWrap(true)
    descriptionFontString:SetText(descText)
    descHeight = descriptionFontString:GetStringHeight() or 0
  end

  local leftHeight = (labelHeight + (C.form.labelOffsetY < 0 and -C.form.labelOffsetY or 0)) +
  (descHeight > 0 and (C.form.labelDescGap + descHeight) or 0)
  local rowHeight = math.max(widgetHeight, leftHeight)
  row:SetHeight(rowHeight)

  row.widget = widget
  row.label = labelFontString
  row.desc = descriptionFontString
  return row
end
