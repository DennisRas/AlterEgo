---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

-- Constants
local DROPDOWN_ITEM_HEIGHT = 26

---@class AE_Input
local Input = {}
addon.Input = Input

---Add common functionality to an input component
---@param input Frame The input frame to add functionality to
local function AddCommonFunctionality(input)
    function input:IsEnabled()
        return self.config.enabled ~= false
    end
    
    function input:updateCommon()
        if self:IsEnabled() then
            self:SetAlpha(1)
        else
            self:SetAlpha(0.3)
        end
    end
end

---Create a button
---@param options AE_InputOptionsButton
---@return AE_Button
function Input:Button(options)
    -- Set defaults
    local config = {
        parent = options.parent or UIParent,
        onEnter = options.onEnter,
        onLeave = options.onLeave,
        onClick = options.onClick,
        text = options.text or "",
        width = options.width or 200,
        height = options.height or 26,
    }
    
    -- Create the main frame
    local input = CreateFrame("Button", 
        config.parent and "$parentButton" or "Button",
        config.parent
    )
    
    -- Store config and initialize state
    input.config = config
    input.hover = false
    
    -- Set size and enable mouse
    input:SetSize(config.width, config.height)
    input:EnableMouse(true)
    
    -- Add common functionality
    function input:IsEnabled()
        return self.config.enabled ~= false
    end
    
    function input:updateCommon()
        if self:IsEnabled() then
            self:SetAlpha(1)
        else
            self:SetAlpha(0.3)
        end
    end
    
    -- Set up event handlers
    input:SetScript("OnClick", function() input:onClickHandler() end)
    input:SetScript("OnEnter", function() input:onEnterHandler() end)
    input:SetScript("OnLeave", function() input:onLeaveHandler() end)

    input.text = input:CreateFontString()
    input.text:SetFontObject("SystemFont_Med1")
    input.text:SetJustifyH("CENTER")
    input.text:SetWordWrap(false)
    input.text:SetVertexColor(1, 1, 1, 1)
    input.text:SetPoint("LEFT", input, "LEFT", 10, 0)
    input.text:SetPoint("RIGHT", input, "RIGHT", -10, 0)
    input.text:SetText(input.config.text)

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
    -- Set defaults
    local config = {
        parent = options.parent or UIParent,
        onEnter = options.onEnter,
        onLeave = options.onLeave,
        onChange = options.onChange,
        placeholder = options.placeholder,
        width = options.width or 200,
        height = options.height or 30,
    }
    
    -- Create the main frame
    local input = CreateFrame("EditBox",
        config.parent and "$parentTextbox" or "Textbox",
        config.parent
    )
    
    -- Store config and initialize state
    input.config = config
    input.hover = false
    
    -- Set up the edit box
    input:EnableMouse(true)
    input:SetAutoFocus(false)
    input:SetFontObject("SystemFont_Med1")
    input:SetTextInsets(10, 10, 10, 10)
    input:SetSize(config.width, config.height)
    
    -- Add common functionality
    AddCommonFunctionality(input)
    
    -- Set up event handlers
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
    -- Set defaults
    local config = {
        parent = options.parent or UIParent,
        onEnter = options.onEnter,
        onLeave = options.onLeave,
        onChange = options.onChange,
        checked = options.checked or false,
        text = options.text or "",
        width = options.width or 200,
        height = options.height or 26,
    }
    
    -- Create the main frame
    local input = CreateFrame("Button",
        config.parent and "$parentCheckbox" or "Checkbox",
        config.parent
    )
    
    -- Store config and initialize state
    input.config = config
    input.hover = false
    input.checked = config.checked
    
    -- Set size and enable mouse
    input:SetSize(config.width, config.height)
    input:EnableMouse(true)
    
    -- Add common functionality
    AddCommonFunctionality(input)
    
    -- Set up event handlers
    input:SetScript("OnClick", function() input:onClickHandler() end)
    input:SetScript("OnEnter", function() input:onEnterHandler() end)
    input:SetScript("OnLeave", function() input:onLeaveHandler() end)

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
    -- Set defaults
    local config = {
        parent = options.parent or UIParent,
        onEnter = options.onEnter,
        onLeave = options.onLeave,
        onChange = options.onChange,
        items = options.items or {},
        value = options.value,
        maxHeight = options.maxHeight or 200,
        size = options.size or 200,
        sizeIcon = options.sizeIcon or 11,
        placeholder = options.placeholder or "Select option"
    }
    
    -- Create the main frame
    local input = CreateFrame("Frame",
        config.parent and "$parentInputDropdown" or "InputDropdown",
        config.parent
    )
    
    -- Store config and initialize state
    input.config = config
    input.hover = false
    input.items = {}
    input.value = config.value
    input.expanded = false
    
    -- Set size and register events
    input:SetSize(config.size, 30)
    input:RegisterEvent("GLOBAL_MOUSE_DOWN")
    input:SetScript("OnEvent", function()
        if not MouseIsOver(input) and not MouseIsOver(input.list) then
            input:SetExpanded(false)
        end
    end)
    
    -- Add common functionality
    AddCommonFunctionality(input)

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

---Create a status bar
---@param options AE_InputOptionsStatusBar
---@return AE_StatusBar
function Input:CreateStatusBar(options)
    -- Set defaults
    local config = {
        parent = options.parent or UIParent,
        text = options.text or "Ready",
        value = options.value or 0,
        maxValue = options.maxValue or 100,
        width = options.width or 200,
        height = options.height or 20,
        progressColor = options.progressColor or {r = 0.2, g = 0.6, b = 1.0, a = 1.0},
    }
    
    -- Create the main frame
    local input = CreateFrame("Frame", 
        config.parent and "$parentStatusBar" or "StatusBar",
        config.parent
    )
    
    -- Store config and initialize state
    input.config = config
    input.hover = false
    input.value = config.value
    input.maxValue = config.maxValue
    input.progressColor = config.progressColor
    
    -- Set size
    input:SetSize(config.width, config.height)
    
    -- Add common functionality
    AddCommonFunctionality(input)
    
    -- Create background frame
    input.background = CreateFrame("Frame", "$parentBackground", input)
    input.background:SetFrameLevel(input:GetFrameLevel() - 2)
    input.background:SetAllPoints()
    
    -- Create border frame with thicker border
    input.border = CreateFrame("Frame", "$parentBorder", input)
    input.border:SetFrameLevel(input:GetFrameLevel() - 1)
    input.border:SetPoint("TOPLEFT", input, "TOPLEFT", -2, 2)
    input.border:SetPoint("TOPRIGHT", input, "TOPRIGHT", 2, 2)
    input.border:SetPoint("BOTTOMRIGHT", input, "BOTTOMRIGHT", 2, -2)
    input.border:SetPoint("BOTTOMLEFT", input, "BOTTOMLEFT", -2, -2)
    
    -- Create progress frame
    input.progress = CreateFrame("Frame", "$parentProgress", input)
    input.progress:SetFrameLevel(input:GetFrameLevel() - 1)
    input.progress:SetPoint("TOPLEFT", input, "TOPLEFT", 2, -2)
    input.progress:SetPoint("BOTTOMLEFT", input, "BOTTOMLEFT", 2, 2)
    input.progress:SetWidth(0) -- Will be updated based on progress
    
    -- Create text with better styling for progress bar
    input.text = input:CreateFontString("$parentText", "OVERLAY", "GameFontNormalLarge")
    input.text:SetPoint("LEFT", input, "LEFT", 15, 0) -- More padding for taller bar
    input.text:SetPoint("RIGHT", input, "RIGHT", -15, 0) -- Right padding to prevent overflow
    input.text:SetText(input.config.text)
    -- Set text color to white with shadow for better readability
    input.text:SetTextColor(1, 1, 1, 1)
    input.text:SetShadowColor(0, 0, 0, 1)
    input.text:SetShadowOffset(1, -1)
    
    -- Set initial values
    input.value = input.config.value or 0
    input.maxValue = input.config.maxValue or 100
    input.progressColor = input.config.progressColor or {r = 0.2, g = 0.6, b = 1.0, a = 1.0}
    
    function input:SetText(text)
        input.text:SetText(text or "Ready")
    end
    
    function input:SetValue(value)
        input.value = value or 0
        input:UpdateProgress()
    end
    
    function input:SetMaxValue(maxValue)
        input.maxValue = maxValue or 100
        input:UpdateProgress()
    end
    
    function input:SetMinMaxValues(minValue, maxValue)
        input.maxValue = maxValue or 100
        input:UpdateProgress()
    end
    
    function input:GetValue()
        return input.value
    end
    
    function input:GetMaxValue()
        return input.maxValue
    end
    
    function input:UpdateProgress()
        local progress = 0
        if input.maxValue > 0 then
            progress = math.min(input.value / input.maxValue, 1.0)
        end
        
        local progressWidth = (input:GetWidth() - 4) * progress -- Account for thicker border
        input.progress:SetWidth(progressWidth)
    end
    
    function input:Update()
        -- Set background color (using titlebar color like other inputs)
        addon.Utils:SetBackgroundColor(input.background, addon.Constants.colors.titlebar.r, addon.Constants.colors.titlebar.g, addon.Constants.colors.titlebar.b, 1)
        
        -- Set border color (more visible for progress bar)
        addon.Utils:SetBackgroundColor(input.border, 0.5, 0.5, 0.5, 0.3)
        
        -- Set progress color
        addon.Utils:SetBackgroundColor(input.progress, input.progressColor.r, input.progressColor.g, input.progressColor.b, input.progressColor.a)
        
        -- Update progress width
        input:UpdateProgress()
        
        input:updateCommon()
    end
    
    input:Update()
    return input
end
