# UI System Documentation

## Window Factory System
The `Window.lua` file provides a factory pattern for creating window-like frames with consistent behavior and styling.

### Window Creation
```lua
local window = addon.Window:New({
    name = "WindowName",
    title = "Window Title",
    sidebar = 150,  -- Optional sidebar width
    titlebar = true, -- Show titlebar (default: true)
    border = 1,     -- Border thickness
    windowScale = 1.0,
    windowColor = {r=0.1, g=0.1, b=0.1, a=0.9},
    titlebarButtons = {
        -- Array of button configurations
    }
})
```

### Window Components
- **Titlebar**: Contains title text and control buttons
- **Body**: Main content area
- **Sidebar**: Optional left panel
- **Border**: Configurable border around the window

## Dynamic Titlebar Button System

### Button Configuration
Buttons are defined using the `AE_TitlebarButton` type:
```lua
{
    name = "ButtonName",
    icon = "Interface\\Icons\\icon_name",
    tooltipTitle = "Button Tooltip",
    tooltipDescription = "Detailed description",
    onClick = function() 
        -- Click handler
    end,
    size = 24,           -- Optional: button size
    iconSize = 12,       -- Optional: icon size
    enabled = true,      -- Optional: button state
    setupMenu = function(button) -- Optional: for dropdown buttons
        -- Menu setup logic
    end
}
```

### Button Management
```lua
-- Add a button dynamically
window:AddTitlebarButton(buttonConfig)

-- Remove a button
window:RemoveTitlebarButton("ButtonName")

-- Get button reference
local button = window:GetTitlebarButton("ButtonName")
```

### Button Positioning
- Buttons are automatically positioned from right to left
- Each button anchors to the previous button or the close button
- Positioning is handled automatically when adding/removing buttons

## Error Handling
- Validate all UI element parameters before creation
- Check for nil parent frames
- Provide meaningful error messages for invalid configurations
- Handle missing textures and icons gracefully
