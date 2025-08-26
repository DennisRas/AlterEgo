# Data Management Documentation

## Addon-Specific Data Rules

### Global Data Usage
**Most data in the addon is stored globally using `self.db.global`:**
- Character profiles and settings
- Addon configuration
- Shared preferences across characters

### Data Validation
Always validate data before use:
```lua
local function validateData(data)
    if not data or type(data) ~= "table" then
        error("Invalid data format: expected table")
    end
    -- Additional validation as needed
end
```

## Error Handling
- Always check for nil values before accessing nested properties
- Provide meaningful error messages for data validation failures
- Use default values when appropriate
