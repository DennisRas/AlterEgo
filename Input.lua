---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

local DROPDOWN_ITEM_HEIGHT = 26

---@class AE_Input
local Input = {}
addon.Input = Input

-- Base input functionality mixin
local BaseInputMixin = {
    -- Common event handlers
    onEnterHandler = function(self)
        self.hover = true
        if self.config.onEnter then
            self.config.onEnter(self)
        end
        self:Update()
    end,

    onLeaveHandler = function(self)
        self.hover = false
        if self.config.onLeave then
            self.config.onLeave(self)
        end
        self:Update()
    end,

    -- Common update logic
    updateCommon = function(self)
        if self:IsEnabled() then
            self:SetAlpha(1)
        else
            self:SetAlpha(0.3)
        end
    end,

    -- Common script setup
    setupCommonScripts = function(self)
        self:SetScript("OnEnter", function() self:onEnterHandler() end)
        self:SetScript("OnLeave", function() self:onLeaveHandler() end)
        self:SetScript("OnDisable", function() self:Update() end)
        self:SetScript("OnEnable", function() self:Update() end)
    end
}

-- Apply mixin to a frame
local function ApplyMixin(frame, mixin)
    for key, value in pairs(mixin) do
        frame[key] = value
    end
end

-- Create base input with common functionality
local function CreateBaseInput(frameType, name, parent, config)
    local input = CreateFrame(frameType, name, parent)
    input.config = CreateFromMixins(config.defaults or {}, config or {})
    input.hover = false
    
    ApplyMixin(input, BaseInputMixin)
    input:setupCommonScripts()
    
    return input
end

---Create a button
---@param options AE_InputOptionsButton
---@return AE_Button
function Input:Button(options)
    local input = CreateBaseInput("Button", 
        options.parent and "$parentButton" or "Button", 
        options.parent or UIParent,
        {
            defaults = {
                parent = UIParent,
                onEnter = false,
                onLeave = false,
                onClick = false,
                text = "",
                width = 200,
                height = 26,
            },
            onClick = options.onClick
        }
    )
    
    input:EnableMouse(true)
    input:SetSize(input.config.width, input.config.height)
    input:SetScript("OnClick", function() input:onClickHandler() end)

    input.text = input:CreateFontString()
    input.text:SetFontObject("SystemFont_Med1")
    input.text:SetJustifyH("CENTER")
    input.text:SetWordWrap(false)
    input.text:SetVertexColor(1, 1, 1, 1)
    input.text:SetPoint("LEFT", input, "LEFT", 10, 0)
    input.text:SetPoint("RIGHT", input, "RIGHT", -10, 0)
    input.text:SetText(input.config.text)

    function input:onClickHandler()
        if input.config.onClick then
            input.config.onClick(input)
        end
        input:Update()
    end

    function input:Update()
        if input.hover then
            addon.Utils:SetBackgroundColor(input, addon.Constants.colors.primary.r, addon.Constants.colors.primary.g, addon.Constants.colors.primary.b, 0.2)
        else
            addon.Utils:SetBackgroundColor(input, addon.Constants.colors.primary.r, addon.Constants.colors.primary.g, addon.Constants.colors.primary.b, 0.1)
        end
        input:updateCommon()
    end

    input:Update()
    return input
end

---Create a textbox
---@param options AE_InputOptionsTextbox
---@return AE_Textbox
function Input:Textbox(options)
    local input = CreateBaseInput("EditBox",
        options.parent and "$parentTextbox" or "Textbox",
        options.parent or UIParent,
        {
            defaults = {
                parent = UIParent,
                onEnter = false,
                onLeave = false,
                onChange = false,
                width = 200,
                height = 30,
            },
            onChange = options.onChange,
            placeholder = options.placeholder
        }
    )
    
    input:EnableMouse(true)
    input:SetAutoFocus(false)
    input:SetFontObject("SystemFont_Med1")
    input:SetTextInsets(10, 10, 10, 10)
    input:SetSize(input.config.width, input.config.height)
    input:SetScript("OnEditFocusGained", function() input:Update() end)
    input:SetScript("OnEditFocusLost", function() input:Update() end)
    input:SetScript("OnEscapePressed", function() input:ClearFocus() end)
    input:SetScript("OnTextChanged", function() input:OnChange() end)

    input.border = CreateFrame("Frame", "$parentBorder", input)
    input.border:SetFrameLevel(input:GetFrameLevel() - 1)
    input.border:SetPoint("TOPLEFT", input, "TOPLEFT", -1, 1)
    input.border:SetPoint("TOPRIGHT", input, "TOPRIGHT", 1, 1)
    input.border:SetPoint("BOTTOMRIGHT", input, "BOTTOMRIGHT", 1, -1)
    input.border:SetPoint("BOTTOMLEFT", input, "BOTTOMLEFT", -1, -1)

    input.text = input:CreateFontString()
    input.text:SetFontObject("SystemFont_Med1")
    input.text:SetJustifyH("LEFT")
    input.text:SetWordWrap(false)
    input.text:SetVertexColor(1, 1, 1, 0.5)
    input.text:SetPoint("LEFT", input, "LEFT", 10, 0)
    input.text:SetPoint("RIGHT", input, "RIGHT", -10, 0)

    function input:OnChange()
        if input.config.onChange then
            input.config.onChange(input)
        end
        input:Update()
    end

    function input:Update()
        addon.Utils:SetBackgroundColor(input, addon.Constants.colors.titlebar.r, addon.Constants.colors.titlebar.g, addon.Constants.colors.titlebar.b, 1)

        if input.border then
            if input.hover or input:HasFocus() then
                addon.Utils:SetBackgroundColor(input.border, 0.5, 0.5, 0.5, 0.3)
            else
                addon.Utils:SetBackgroundColor(input.border, 0.5, 0.5, 0.5, 0.1)
            end
        end

        if input.config.placeholder then
            input.text:SetText(input.config.placeholder)
            if input:GetText() == "" then
                if input:HasFocus() then
                    input.text:Hide()
                else
                    input.text:Show()
                end
            end
        end

        input:updateCommon()
    end

    input:Update()
    return input
end

---Create a checkbox
---@param options AE_InputOptionsCheckbox
---@return AE_Checkbox
function Input:CreateCheckbox(options)
    local input = CreateBaseInput("Button",
        options.parent and "$parentCheckbox" or "Checkbox",
        options.parent or UIParent,
        {
            defaults = {
                parent = UIParent,
                onEnter = false,
                onLeave = false,
                onChange = false,
                checked = false,
                text = "",
                width = 200,
                height = 26,
            },
            onChange = options.onChange
        }
    )
    
    input.checked = input.config.checked
    input:EnableMouse(true)
    input:SetSize(input.config.width, input.config.height)
    input:SetScript("OnClick", function() input:onClickHandler() end)

    input.checkbox = CreateFrame("Button", "$parentCheckbox", input)
    input.checkbox:SetSize(16, 16)
    input.checkbox:SetPoint("LEFT", input, "LEFT", 5, 0)

    input.checkbox.texture = input.checkbox:CreateTexture("$parentTexture", "ARTWORK")
    input.checkbox.texture:SetAllPoints()
    input.checkbox.texture:SetTexture("Interface\\Buttons\\UI-CheckBox-Up")

    input.text = input:CreateFontString()
    input.text:SetFontObject("SystemFont_Med1")
    input.text:SetJustifyH("LEFT")
    input.text:SetWordWrap(false)
    input.text:SetVertexColor(1, 1, 1, 1)
    input.text:SetPoint("LEFT", input.checkbox, "RIGHT", 5, 0)
    input.text:SetPoint("RIGHT", input, "RIGHT", -5, 0)
    input.text:SetText(input.config.text)

    function input:onClickHandler()
        input.checked = not input.checked
        if input.config.onChange then
            input.config.onChange(input, input.checked)
        end
        input:Update()
    end

    function input:Update()
        if input.checked then
            input.checkbox.texture:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
        else
            input.checkbox.texture:SetTexture("Interface\\Buttons\\UI-CheckBox-Up")
        end

        if input.hover then
            addon.Utils:SetBackgroundColor(input, addon.Constants.colors.primary.r, addon.Constants.colors.primary.g, addon.Constants.colors.primary.b, 0.1)
        else
            addon.Utils:SetBackgroundColor(input, 0, 0, 0, 0)
        end

        input:updateCommon()
    end

    input:Update()
    return input
end

---Create a Dropdown
---@param options AE_InputOptionsDropdown
---@return AE_Dropdown
function Input:CreateDropdown(options)
    local input = CreateBaseInput("Frame",
        options.parent and "$parentInputDropdown" or "InputDropdown",
        options.parent or UIParent,
        {
            defaults = {
                parent = UIParent,
                items = {},
                value = nil,
                maxHeight = 200,
                size = 200,
                sizeIcon = 11,
                placeholder = "Select option"
            },
            onChange = options.onChange
        }
    )
    
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

    input.button = CreateFrame("Button", "$parentButton", input)
    input.button:SetPoint("TOPLEFT", input, "TOPLEFT")

    input.button.text = input.button:CreateFontString()
    input.button.text:SetFontObject("SystemFont_Med1")
    input.button.text:SetJustifyH("LEFT")
    input.button.text:SetWordWrap(false)
    input.button.text:SetPoint("LEFT", input.button, "LEFT", 10, 0)
    input.button.text:SetPoint("RIGHT", input.button, "RIGHT", -21, 0)

    input.button.icon = input.button:CreateTexture("$parentIcon", "ARTWORK")
    input.button.icon:SetPoint("RIGHT", input.button, "RIGHT", -10, 0)
    input.button.icon:SetSize(11, 11)
    input.button.icon:SetTexture("Interface\\Buttons\\UI-SortArrow")
    input.button.icon:SetVertexColor(1, 1, 1, 0.8)

    input.border = CreateFrame("Frame", "$parentBorder", input)
    input.border:SetFrameLevel(input:GetFrameLevel() - 1)
    input.border:SetPoint("TOPLEFT", input, "TOPLEFT", -1, 1)
    input.border:SetPoint("TOPRIGHT", input, "TOPRIGHT", 1, 1)
    input.border:SetPoint("BOTTOMRIGHT", input, "BOTTOMRIGHT", 1, -1)
    input.border:SetPoint("BOTTOMLEFT", input, "BOTTOMLEFT", -1, -1)

    input.list = addon.Utils:CreateScrollFrame({ name = input:GetName() .. "List", parent = UIParent })
    input.list:SetFrameStrata("FULLSCREEN_DIALOG")
    input.list:SetFrameLevel(200)
    input.list:ClearAllPoints()
    input.list:SetPoint("TOPLEFT", input.button, "BOTTOMLEFT", 0, -1)
    input.list:SetPoint("TOPRIGHT", input.button, "BOTTOMRIGHT", 0, -1)
    input.list:Hide()

    input.list.border = CreateFrame("Frame", "$parentListBorder", input.list)
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
        input.items = addon.Utils:TableFilter(input.items, function(currentItem)
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
            input.config.onChange(input, value)
        end
        input:Update()
    end

    function input:GetValue()
        return input.value
    end

    function input:onClickHandler()
        input:SetExpanded(not input.expanded)
    end

    function input:Update()
        addon.Utils:SetBackgroundColor(input, addon.Constants.colors.titlebar.r, addon.Constants.colors.titlebar.g, addon.Constants.colors.titlebar.b, 1)

        if input.border then
            if input.hover or input.expanded then
                addon.Utils:SetBackgroundColor(input.border, 0.5, 0.5, 0.5, 0.3)
            else
                addon.Utils:SetBackgroundColor(input.border, 0.5, 0.5, 0.5, 0.1)
            end
        end

        if input.expanded then
            input.button.icon:SetRotation(3.14159)
            input.list:Show()
            input:UpdateList()
        else
            input.button.icon:SetRotation(0)
            input.list:Hide()
        end

        local selectedItem = addon.Utils:TableGet(input.items, "value", input.value)
        if selectedItem then
            input.button.text:SetText(selectedItem.text)
        else
            input.button.text:SetText(input.config.placeholder)
        end

        input:updateCommon()
    end

    function input:UpdateList()
        input.list.content:ClearAllPoints()
        input.list.content:SetPoint("TOPLEFT", input.list, "TOPLEFT", 0, 0)
        input.list.content:SetPoint("TOPRIGHT", input.list, "TOPRIGHT", 0, 0)

        local height = 0
        for i, item in ipairs(input.items) do
            local itemFrame = input.list.content["item" .. i]
            if not itemFrame then
                itemFrame = CreateFrame("Button", "$parentItem" .. i, input.list.content)
                itemFrame:SetHeight(DROPDOWN_ITEM_HEIGHT)
                itemFrame:SetPoint("TOPLEFT", input.list.content, "TOPLEFT", 0, -height)
                itemFrame:SetPoint("TOPRIGHT", input.list.content, "TOPRIGHT", 0, -height)

                itemFrame.text = itemFrame:CreateFontString()
                itemFrame.text:SetFontObject("SystemFont_Med1")
                itemFrame.text:SetJustifyH("LEFT")
                itemFrame.text:SetPoint("LEFT", itemFrame, "LEFT", 10, 0)
                itemFrame.text:SetPoint("RIGHT", itemFrame, "RIGHT", -10, 0)

                itemFrame:SetScript("OnClick", function()
                    input:SetValue(item.value)
                    input:SetExpanded(false)
                end)

                itemFrame:SetScript("OnEnter", function()
                    addon.Utils:SetBackgroundColor(itemFrame, addon.Constants.colors.primary.r, addon.Constants.colors.primary.g, addon.Constants.colors.primary.b, 0.2)
                end)

                itemFrame:SetScript("OnLeave", function()
                    addon.Utils:SetBackgroundColor(itemFrame, 0, 0, 0, 0)
                end)

                input.list.content["item" .. i] = itemFrame
            end

            itemFrame.text:SetText(item.text)
            itemFrame:Show()
            height = height + DROPDOWN_ITEM_HEIGHT
        end

        for i = #input.items + 1, 100 do
            local itemFrame = input.list.content["item" .. i]
            if itemFrame then
                itemFrame:Hide()
            end
        end

        input.list.content:SetHeight(height)
        input.list:SetHeight(math.min(height, input.config.maxHeight))
    end

    input.button:SetScript("OnClick", function() input:onClickHandler() end)
    input.button:SetScript("OnEnter", function() input:onEnterHandler() end)
    input.button:SetScript("OnLeave", function() input:onLeaveHandler() end)

    input:Update()
    return input
end
