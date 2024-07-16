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

function Input:CreateCheckbox(options)
  local input = CreateFrame("Button", "Input")
  input.config = CreateFromMixins(
    {
      checked = false,
      onEnter = false,
      onLeave = false,
      onClick = false,
      onChange = false,
      size = 16,
      sizeIcon = 11,
    }, options or {}
  )
  input.hover = false
  input.checked = input.config.checked and true or false
  input:SetSize(input.config.size, input.config.size)
  input:EnableMouse(true)

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
    input.checked = not input:GetChecked()
    if input.config.onClick then
      input.config.onClick(input)
    end
    input:Update()
  end

  function input:onEnterHandler()
    input.hover = true
    if input.config.onEnter then
      input.config.onEnter(input)
    end
    input:Update()
  end

  function input:onLeaveHandler()
    input.hover = false
    if input.config.onLeave then
      input.config.onLeave(input)
    end
    input:Update()
  end

  function input:Update()
    Utils:SetBackgroundColor(input, 0.1, 0.1, 0.1, 1)

    if input:GetChecked() then
      input.icon:SetVertexColor(0.3, 0.7, 0.3, 1)
    else
      input.icon:SetVertexColor(1, 1, 1, 0.2)
    end

    if input.border then
      if input.hover then
        Utils:SetBackgroundColor(input.border, 1, 1, 1, 0.3)
      else
        Utils:SetBackgroundColor(input.border, 1, 1, 1, 0.2)
      end
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

  input:SetScript("OnClick", input.onClickHandler)
  input:SetScript("OnEnter", input.onEnterHandler)
  input:SetScript("OnLeave", input.onLeaveHandler)
  input:SetScript("OnDisable", input.Update)
  input:SetScript("OnEnable", input.Update)
  input:Update()
  return input
end

function Input:CreateDropdown(options)
  local input = CreateFrame("Frame", "Input")
  input.config = CreateFromMixins(
    {
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
      maxHeight = 200,
      placeholder = "Select option"
    }, options or {}
  )
  input.hover = false
  input.items = {}
  input.value = input.config.value
  input.expanded = false
  input:SetSize(input.config.size, 30)
  input:RegisterEvent("GLOBAL_MOUSE_DOWN")
  input:SetScript("OnEvent", function()
    if not MouseIsOver(input) and not MouseIsOver(input.list) then
      input:SetExpanded(false)
    end
  end)

  input.button = CreateFrame("Button", "Button", input)
  input.button:SetPoint("TOPLEFT", input, "TOPLEFT")

  input.button.text = input.button:CreateFontString()
  input.button.text:SetFontObject("SystemFont_Med1")
  input.button.text:SetJustifyH("LEFT")
  input.button.text:SetPoint("LEFT", input.button, "LEFT", 10, 0)
  input.button.text:SetPoint("RIGHT", input.button, "RIGHT", -21, 0)

  input.button.icon = input.button:CreateTexture("$parentIcon", "ARTWORK")
  input.button.icon:SetPoint("RIGHT", input.button, "RIGHT", -10, 0)
  input.button.icon:SetSize(11, 11)
  input.button.icon:SetTexture(Constants.media.IconCaretDown)
  input.button.icon:SetVertexColor(1, 1, 1, 0.8)

  input.border = CreateFrame("Frame", "Border", input)
  input.border:SetFrameStrata("LOW")
  input.border:SetPoint("TOPLEFT", input, "TOPLEFT", -1, 1)
  input.border:SetPoint("TOPRIGHT", input, "TOPRIGHT", 1, 1)
  input.border:SetPoint("BOTTOMRIGHT", input, "BOTTOMRIGHT", 1, -1)
  input.border:SetPoint("BOTTOMLEFT", input, "BOTTOMLEFT", -1, -1)

  input.list = Utils:CreateScrollFrame(input:GetName() .. "List", UIParent)
  input.list:SetFrameStrata("FULLSCREEN_DIALOG")
  input.list:SetFrameLevel(200)
  input.list:ClearAllPoints()
  input.list:SetPoint("TOPLEFT", input.button, "BOTTOMLEFT")
  input.list:SetPoint("TOPRIGHT", input.button, "BOTTOMRIGHT")
  input.list:Hide()

  input.list.border = CreateFrame("Frame", "Border", input.list)
  input.list.border:SetFrameLevel(199)
  input.list.border:SetPoint("TOPLEFT", input.list, "TOPLEFT", -1, 1)
  input.list.border:SetPoint("TOPRIGHT", input.list, "TOPRIGHT", 1, 1)
  input.list.border:SetPoint("BOTTOMRIGHT", input.list, "BOTTOMRIGHT", 1, -1)
  input.list.border:SetPoint("BOTTOMLEFT", input.list, "BOTTOMLEFT", -1, -1)

  function input:ClearItems()
    wipe(input.items or {})
    input.value = ""
    input:Update()
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

  function input:GetValueText()
    if not input.value then return "" end
    local item = Utils:TableGet(input.items, "value", input.value)
    return item and item.text or ""
  end

  function input:onClickHandler()
    input.expanded = not input.expanded
    if input.config.onClick then
      input.config.onClick(input)
    end
    input:Update()
  end

  function input:onEnterHandler()
    input.hover = true
    if input.config.onEnter then
      input.config.onEnter(input)
    end
    input:Update()
  end

  function input:onLeaveHandler()
    input.hover = false
    if input.config.onLeave then
      input.config.onLeave(input)
    end
    input:Update()
  end

  function input:Update()
    Utils:SetBackgroundColor(input, 0.1, 0.1, 0.1, 1)
    Utils:SetBackgroundColor(input.list, 0.1, 0.1, 0.1, 1)
    Utils:SetBackgroundColor(input.list.border, 1, 1, 1, 0.3)
    input.button:SetSize(input:GetWidth(), 30)

    local value = input:GetValue()
    local valueText = input:GetValueText()

    if input.expanded then
      input.button.icon:SetVertexColor(1, 1, 1, 0.9)
      input.list:Show()
    else
      if input.hover then
        input.button.icon:SetVertexColor(1, 1, 1, 0.7)
      else
        input.button.icon:SetVertexColor(1, 1, 1, 0.5)
      end
      input.list:Hide()
    end

    if input.border then
      if input.hover or input.expanded then
        Utils:SetBackgroundColor(input.border, 1, 1, 1, 0.3)
      else
        Utils:SetBackgroundColor(input.border, 1, 1, 1, 0.2)
      end
    end

    if input.button:IsEnabled() then
      input:SetAlpha(1)
    else
      input:SetAlpha(0.3)
    end

    if value == "" then
      input.button.text:SetText(input.config.placeholder)
    else
      input.button.text:SetText(tostring(valueText))
    end

    local height = 5
    if not input.list.content.items then input.list.content.items = {} end
    Utils:TableForEach(input.list.content.items, function(itemButton) itemButton:Hide() end)
    Utils:TableForEach(input.items, function(item, index)
      local itemButton = input.list.content.items[index]
      if not itemButton then
        itemButton = CreateFrame("Button", "ListItem", input.list.content)
        itemButton.text = itemButton:CreateFontString()
        itemButton.text:SetFontObject("SystemFont_Small2")
        itemButton.text:SetJustifyH("LEFT")
        itemButton.icon = itemButton:CreateTexture()
        itemButton.icon:SetPoint("LEFT", itemButton, "LEFT", 5, 0)
        itemButton.icon:SetSize(11, 11)
        -- itemButton.icon:SetVertexColor(0.3, 0.7, 0.3, 1)
        -- itemButton.icon:Hide()
        itemButton.iconCheck = itemButton:CreateTexture()
        itemButton.iconCheck:SetPoint("RIGHT", itemButton, "RIGHT", -5, 0)
        itemButton.iconCheck:SetSize(11, 11)
        itemButton.iconCheck:SetTexture(Constants.media.IconCheckmark)
        itemButton.iconCheck:SetVertexColor(0.3, 0.7, 0.3, 1)
        itemButton.iconCheck:Hide()
        input.list.content.items[index] = itemButton
      end
      itemButton.data = item
      itemButton:SetSize(input.list:GetWidth(), DROPDOWN_ITEM_HEIGHT)
      itemButton:SetPoint("TOPLEFT", input.list.content, "TOPLEFT", 5, -height)
      itemButton:SetPoint("TOPRIGHT", input.list.content, "TOPRIGHT", -5, -height)
      itemButton:Show()
      itemButton.icon:SetTexture(item.icon)
      itemButton.text:SetText(item.text)
      itemButton.text:SetPoint("LEFT", itemButton, "LEFT", item.icon and 21 or 5, 0)
      itemButton.text:SetPoint("RIGHT", itemButton, "RIGHT", -21, 0)

      itemButton:SetScript("OnEnter", function()
        if item.value == value then return end
        Utils:SetBackgroundColor(itemButton, 1, 1, 1, 0.05)
      end)
      itemButton:SetScript("OnLeave", function()
        if item.value == value then return end
        Utils:SetBackgroundColor(itemButton, 1, 1, 1, 0)
      end)

      if item.value == value then
        Utils:SetBackgroundColor(itemButton, 1, 1, 1, 0.1)
        itemButton.iconCheck:Show()
      else
        Utils:SetBackgroundColor(itemButton, 1, 1, 1, 0)
        itemButton.iconCheck:Hide()
      end

      itemButton:SetScript("OnClick", function()
        input:SetValue(item.value)
        input:SetExpanded(false)
      end)

      height = height + DROPDOWN_ITEM_HEIGHT
    end)
    height = height + 5
    input.list:SetSize(input:GetWidth(), math.min(height, input.config.maxHeight))
    input.list.content:SetSize(input:GetWidth(), height)
  end

  input.button:SetScript("OnClick", input.onClickHandler)
  input.button:SetScript("OnEnter", input.onEnterHandler)
  input.button:SetScript("OnLeave", input.onLeaveHandler)
  input.button:SetScript("OnDisable", input.Update)
  input.button:SetScript("OnEnable", input.Update)
  input:SetItems(input.config.items)
  input:Update()
  return input
end

function Input:CreateColorPicker(options)
  local input = CreateFrame("Button", "Input")
  input.config = CreateFromMixins(
    {
      onEnter = false,
      onLeave = false,
      onClick = false,
      onChange = false,
      size = 16,
      value = Constants.colors.primary
    }, options or {}
  )
  input.value = input.config.value
  input:SetSize(input.config.size, input.config.size)

  input.checkers = input:CreateTexture("$parentBackground")
  input.checkers:SetAllPoints()
  input.checkers:SetTexture(188523)
  input.checkers:SetTexCoord(.25, 0, 0.5, .25)
  input.checkers:SetDesaturated(true)

  input.color = input:CreateTexture("$parentColor", "OVERLAY")
  input.color:SetAllPoints()
  input.color:SetTexture("Interface/BUTTONS/WHITE8X8")
  input.color:SetVertexColor(input.value.r, input.value.g, input.value.b, input.value.a)
  -- input.color:SetPoint("TOPLEFT", input, "TOPLEFT", 1, -1)
  -- input.color:SetPoint("TOPRIGHT", input, "TOPRIGHT", -1, -1)
  -- input.color:SetPoint("BOTTOMRIGHT", input, "BOTTOMRIGHT", -1, 1)
  -- input.color:SetPoint("BOTTOMLEFT", input, "BOTTOMLEFT", 1, 1)

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
    local prevR, prevG, prevB, prevA = input.value:GetRGBA()
    ColorPickerFrame:SetupColorPickerAndShow({
      swatchFunc = function()
        local r, g, b = ColorPickerFrame:GetColorRGB()
        local a = ColorPickerFrame:GetColorAlpha()
        input:SetValue(CreateColor(r, g, b, a))
      end,
      opacityFunc = function()
        local r, g, b = ColorPickerFrame:GetColorRGB()
        local a = ColorPickerFrame:GetColorAlpha()
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
    if input.config.onClick then
      input.config.onClick(input)
    end
    input:Update()
  end

  function input:onEnterHandler()
    input.hover = true
    if input.config.onEnter then
      input.config.onEnter(input)
    end
    input:Update()
  end

  function input:onLeaveHandler()
    input.hover = false
    if input.config.onLeave then
      input.config.onLeave(input)
    end
    input:Update()
  end

  function input:Update()
    Utils:SetBackgroundColor(input, 1, 1, 1, 1)

    local value = input:GetValue()
    if value then
      input.color:SetVertexColor(value.r, value.g, value.b, value.a)
    end

    if input.border then
      if input.hover then
        Utils:SetBackgroundColor(input.border, 1, 1, 1, 0.3)
      else
        Utils:SetBackgroundColor(input.border, 1, 1, 1, 0.2)
      end
    end

    if input:IsEnabled() then
      input:SetAlpha(1)
    else
      input:SetAlpha(0.3)
    end
  end

  input:SetScript("OnClick", input.onClickHandler)
  input:SetScript("OnEnter", input.onEnterHandler)
  input:SetScript("OnLeave", input.onLeaveHandler)
  input:SetScript("OnDisable", input.Update)
  input:SetScript("OnEnable", input.Update)
  input:Update()
  return input
end
