---@class LiqUI
local LiqUI = _G.LiqUI
if not LiqUI then
  return
end

LiqUI.Widgets = LiqUI.Widgets or {}

local C = LiqUI.Constants

local BaseControlDefaults = {
  height = C.control.height,
  backdrop = C.control.backdrop,
  backdropNoBorder = C.control.backdropNoBorder,
  borderColor = C.control.borderColor,
  borderColorHighlight = C.control.borderColorHighlight,
  borderColorFocus = C.control.borderColorFocus,
  backgroundColor = C.control.backgroundColor,
  backgroundColorHover = C.control.backgroundColorHover,
  backgroundColorPressed = C.control.backgroundColorPressed,
}

LiqUI.Widgets.BaseMixin = {}

function LiqUI.Widgets.BaseMixin:SetBorderState(state)
  local opts = self.options or {}
  local color
  if state == "highlight" then
    color = opts.borderColorHighlight or BaseControlDefaults.borderColorHighlight
  elseif state == "focus" then
    color = opts.borderColorFocus or BaseControlDefaults.borderColorFocus
  else
    color = opts.borderColor or BaseControlDefaults.borderColor
  end
  self:SetBackdropBorderColor(color:GetRGBA())
end

local function applyBackdropColor(frame, color)
  if color and color.GetRGBA then
    frame:SetBackdropColor(color:GetRGBA())
  else
    local fallback = color or { 0.18, 0.18, 0.2, 1 }
    frame:SetBackdropColor(fallback[1], fallback[2], fallback[3], fallback[4] or 1)
  end
end

function LiqUI.Widgets.BaseMixin:SetBackgroundState(state)
  local opts = self.options or {}
  local color
  if state == "highlight" then
    color = opts.backgroundColorHover or BaseControlDefaults.backgroundColorHover
  elseif state == "pressed" then
    color = opts.backgroundColorPressed or BaseControlDefaults.backgroundColorPressed
  else
    color = opts.backgroundColor or BaseControlDefaults.backgroundColor
  end
  applyBackdropColor(self, color)
end

function LiqUI.Widgets.BaseMixin:Init(defaults, opts)
  opts = LiqUI.Utils.PrepareOptions(LiqUI.Utils.PrepareOptions(BaseControlDefaults, defaults or {}), opts)
  self.options = opts
  self:SetSize(opts.width or 100, opts.height)
  self.backdropInfo = (opts.border == false) and opts.backdropNoBorder or opts.backdrop or BaseControlDefaults.backdrop
  self:ApplyBackdrop()
  self:SetBackgroundState("normal")
  self:SetBorderState("normal")
  self:SetScript("OnEnter", function()
    self:SetBorderState("highlight")
  end)
  self:SetScript("OnLeave", function()
    self:SetBorderState("normal")
  end)
  return opts
end
