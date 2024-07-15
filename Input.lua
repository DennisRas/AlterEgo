---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

local Utils = addon.Utils
local Constants = addon.Constants
local Window = addon.Window

local DROPDOWN_ITEM_HEIGHT = 20

---@class AE_Input
local Input = {}
addon.Input = Input

local BaseInputMixin = {}

function BaseInputMixin:Init()
  self.hover = false
  self:EnableMouse(true)
  self:SetScript("OnEnter", self.onEnterHandler)
  self:SetScript("OnLeave", self.onLeaveHandler)
  self:SetScript("OnClick", self.onClickHandler)
  self:SetScript("OnDisable", self.Update)
  self:SetScript("OnEnable", self.Update)
  Utils:SetBackgroundColor(self, 0.1, 0.1, 0.1, 1)
end

function BaseInputMixin:onEnterHandler()
  self.hover = true
  if self.border then
    Utils:SetBackgroundColor(self.border, 1, 1, 1, 0.3)
  end
  if self.config.onEnter then
    self.config.onEnter(self)
  end
  self:Update()
end

function BaseInputMixin:onLeaveHandler()
  self.hover = false
  if self.border then
    Utils:SetBackgroundColor(self.border, 1, 1, 1, 0.2)
  end
  if self.config.onLeave then
    self.config.onLeave(self)
  end
  self:Update()
end

function Input:CreateCheckbox(options)
  local defaultOptions = {
    checked = false,
    onEnter = false,
    onLeave = false,
    onClick = false,
    onChange = false,
    size = 16,
    sizeIcon = 11,
  }

  local input = CreateFromMixins(CreateFrame("Button", "Input"), BaseInputMixin)
  input:Init()
  input.config = CreateFromMixins(defaultOptions, options or {})
  input.checked = input.config.checked and true or false
  input:SetSize(input.config.size, input.config.size)

  input.icon = input:CreateTexture("$parentIcon", "ARTWORK")
  input.icon:SetPoint("CENTER", input, "CENTER")
  input.icon:SetSize(input.config.sizeIcon, input.config.sizeIcon)
  input.icon:SetTexture(Constants.media.IconCheckmark)
  input.icon:SetVertexColor(0.3, 0.7, 0.3, 1)
  input.icon:Hide()

  input.border = CreateFrame("Frame", "Border", input)
  input.border:SetFrameStrata("LOW")
  input.border:SetPoint("TOPLEFT", input, "TOPLEFT", -1, 1)
  input.border:SetPoint("TOPRIGHT", input, "TOPRIGHT", 1, 1)
  input.border:SetPoint("BOTTOMRIGHT", input, "BOTTOMRIGHT", 1, -1)
  input.border:SetPoint("BOTTOMLEFT", input, "BOTTOMLEFT", -1, -1)

  function input:SetChecked(state)
    input.checked = state and true or false
    if input.config.onChange then
      input.config.onChange(input.checked, input)
    end
    input:Update()
  end

  function input:GetChecked()
    return input.checked and true or false
  end

  function input:onClickHandler()
    self.checked = not self:GetChecked()
    if input.config.onClick then
      input.config.onClick(input)
    end
    input:Update()
  end

  function input:Update()
    if input:GetChecked() then
      input.icon:SetVertexColor(0.3, 0.7, 0.3, 1)
    else
      input.icon:SetVertexColor(1, 1, 1, 0.2)
    end

    if input:GetChecked() or (input.hover and input:IsEnabled()) then
      input.icon:Show()
    else
      input.icon:Hide()
    end

    if input:IsEnabled() then
      input:SetAlpha(1)
    else
      input:SetAlpha(0.3)
    end
  end

  input:Update()
  return input
end

function Input:CreateDropdown(options)
  local defaultOptions = {
    checked = false,
    onEnter = false,
    onLeave = false,
    onClick = false,
    onChange = false,
    size = 200,
    sizeIcon = 11,
    items = {
      -- {value = "", text = "", icon = ""}
    },
    value = "",
    maxHeight = 100,
    placeholder = "Select option"
  }

  local input = CreateFromMixins(CreateFrame("Button", "Input"), BaseInputMixin)
  input:Init()
  input.config = CreateFromMixins(defaultOptions, options or {})
  input.items = {}
  input.value = input.config.value
  input.expanded = false
  input:SetSize(input.config.size, 16)

  input.text = input:CreateFontString("$parentText")
  input.text:SetFontObject("SystemFont_Med1")
  input.text:JustifyH("LEFT")
  input.text:SetPoint("LEFT", input, "LEFT", 5, 0)
  input.text:SetPoint("RIGHT", input, "RIGHT", -16, 0)

  input.icon = input:CreateTexture("$parentIcon", "ARTWORK")
  input.icon:SetPoint("RIGHT", input, "RIGHT", -5, 0)
  input.icon:SetSize(11, 11)
  input.icon:SetTexture(Constants.media.IconCheckmark)
  input.icon:SetVertexColor(1, 1, 1, 0.2)

  input.border = CreateFrame("Frame", "Border", input)
  input.border:SetFrameStrata("LOW")
  input.border:SetPoint("TOPLEFT", input, "TOPLEFT", -1, 1)
  input.border:SetPoint("TOPRIGHT", input, "TOPRIGHT", 1, 1)
  input.border:SetPoint("BOTTOMRIGHT", input, "BOTTOMRIGHT", 1, -1)
  input.border:SetPoint("BOTTOMLEFT", input, "BOTTOMLEFT", -1, -1)

  input.list = Window:CreateScrollFrame("$parentList", input)

  -- input.list = CreateFrame("Frame", "List", input)
  input.list:SetPoint("TOPLEFT", input, "BOTTOMLEFT")
  input.list:SetPoint("TOPRIGHT", input, "BOTTOMRIGHT")
  input.list:SetSize(input:GetSize())
  input.list:Hide()

  function input:ClearItems()
    wipe(input.items or {})
    input.value = 0
  end

  function input:SetItems(items)
    input:ClearItems()
    input.items = items
    input:Update()
  end

  function input:AddItem(item)
    table.insert(input.items, item)
    input:Update()
  end

  function input:RemoveItem(item)
    input.items = Utils:TableFilter(input.items, function(currentItem)
      return currentItem ~= item
    end)
    input:Update()
  end

  function input:onClickHandler()
    input.expanded = not input.expanded
    if input.config.onClick then
      input.config.onClick(input)
    end
    input:Update()
  end

  function input:SetExpanded(state)
    input.expanded = state and true or false
    input:Update()
  end

  function input:SetValue(value)
    input.value = value
    if input.config.onChange then
      input.config.onChange(value, input)
    end
    input:Update()
  end

  function input:GetValue()
    return input.value
  end

  function input:Update()
    local value = input:GetValue()

    if input.expanded then
      input.icon:SetVertexColor(0.3, 0.7, 0.3, 1)
      input.list:Show()
    else
      input.icon:SetVertexColor(1, 1, 1, 0.2)
      input.list:Hide()
    end

    if input:IsEnabled() then
      input:SetAlpha(1)
    else
      input:SetAlpha(0.3)
    end

    if not input.list.items then
      input.list.items = {}
    end

    if value == "" then
      input.text:SetText(input.config.placeholder)
    else
      input.text:SetText(tostring(value))
    end

    local height = 0
    Utils:TableForEach(input.list.items, function(itemButton) itemButton:Hide() end)
    Utils:TableForEach(input.items, function(item, index)
      local itemButton = input.list.items[index]
      if not itemButton then
        itemButton = CreateFrame("Button")
        itemButton:SetPoint("TOPLEFT", input.list.content, "TOPLEFT", -height, 0)
        itemButton:SetPoint("TOPRIGHT", input.list.content, "TOPRIGHT", -height, 0)
        itemButton:SetSize(input:GetWidth(), height)
        itemButton:SetScript("OnEnter", function() Utils:SetBackgroundColor(itemButton, 1, 1, 1, 0.1) end)
        itemButton:SetScript("OnLeave", function() Utils:SetBackgroundColor(itemButton, 1, 1, 1, 0) end)
        itemButton.text = itemButton:CreateFontString()
        itemButton.text:SetFontObject("SystemFont_Med1")
        itemButton.text:JustifyH("LEFT")
        itemButton.icon = itemButton:CreateTexture()
        itemButton.icon:SetPoint("LEFT", itemButton, "LEFT", 5, 0)
        itemButton.icon:SetSize(11, 11)
        itemButton.icon:SetTexture()
        itemButton.icon:SetVertexColor(0.3, 0.7, 0.3, 1)
        itemButton.icon:Hide()
        itemButton.iconCheck = itemButton:CreateTexture()
        itemButton.iconCheck:SetPoint("RIGHT", itemButton, "RIGHT", 5, 0)
        itemButton.iconCheck:SetSize(11, 11)
        itemButton.iconCheck:SetTexture(Constants.media.IconCheckmark)
        itemButton.iconCheck:SetVertexColor(0.3, 0.7, 0.3, 1)
        itemButton.iconCheck:Hide()
        input.list.items[index] = itemButton
      end
      itemButton.data = item
      itemButton.text:SetText(item.text)
      itemButton.text:SetPoint("LEFT", itemButton, "LEFT", item.icon and 16 or 5, 0)
      itemButton.text:SetPoint("RIGHT", itemButton, "RIGHT", -16, 0)
      itemButton:Show()

      if item.value == value then
        itemButton.iconCheck:Show()
      else
        itemButton.iconCheck:Hide()
      end

      itemButton:SetScript("OnClick", function()
        input:SetValue(item.value)
        input:SetExpanded(false)
      end)

      height = height + DROPDOWN_ITEM_HEIGHT
    end)

    input.list:SetSize(input:GetWidth(), math.min(height, input.config.maxHeight))
    input.list.content:SetSize(input:GetWidth(), height)
  end

  input:SetItems(input.config.items)
  input:Update()
  return input
end

function Input:CreateColorPicker(options)
  local defaultOptions = {
    onEnter = false,
    onLeave = false,
    onClick = false,
    onChange = false,
    size = 16,
    value = BLUE_FONT_COLOR
  }

  local input = CreateFromMixins(CreateFrame("Button", "Input"), BaseInputMixin)
  input:Init()
  input.config = CreateFromMixins(defaultOptions, options or {})
  input.value = input.config.value
  input:SetSize(input.config.size, input.config.size)

  input.border = CreateFrame("Frame", "Border", input)
  input.border:SetFrameStrata("LOW")
  input.border:SetPoint("TOPLEFT", input, "TOPLEFT", -1, 1)
  input.border:SetPoint("TOPRIGHT", input, "TOPRIGHT", 1, 1)
  input.border:SetPoint("BOTTOMRIGHT", input, "BOTTOMRIGHT", 1, -1)
  input.border:SetPoint("BOTTOMLEFT", input, "BOTTOMLEFT", -1, -1)

  function input:SetValue(value)
    input.value = value
    if input.config.onChange then
      input.config.onChange(value, input)
    end
    input:Update()
  end

  function input:GetValue()
    return input.value
  end

  function input:onClickHandler()
    local prevR, prevG, prevB, prevA = self.value:GetRGBA()
    ColorPickerFrame:SetupColorPickerAndShow({
      swatchFun = function()
        local r, g, b = ColorPickerFrame:GetColorRGB()
        local a = 1 - OpacitySliderFrame:GetValue()
        input:SetValue(CreateColor(r, g, b, a))
      end,
      opacityFunc = function()
        local r, g, b = ColorPickerFrame:GetColorRGB()
        local a = 1 - OpacitySliderFrame:GetValue()
        input:SetValue(CreateColor(r, g, b, a))
      end,
      cancelFunc = function()
        input:SetValue(CreateColor(ColorPickerFrame:GetPreviousValues()))
      end,
      hasOpacity = true,
      opacity = prevA,
      -- extraInfo = "What?",
      r = prevR,
      g = prevG,
      b = prevB
    })
    if self.config.onClick then
      self.config.onClick(self)
    end
    self:Update()
  end

  function input:Update()
    local value = self:GetValue()
    if value then
      Utils:SetBackgroundColor(self, value.r, value.g, value.b, value.a)
    end

    if self:IsEnabled() then
      self:SetAlpha(1)
    else
      self:SetAlpha(0.3)
    end
  end

  input:Update()
  return input
end
