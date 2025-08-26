# AlterEgo Addon - AI Development Rules

## Project Overview
AlterEgo is a World of Warcraft addon that provides character management and utility features. The addon uses the Ace3 framework and follows a modular architecture with a factory pattern for UI creation.

## Core Architecture
- **Core.lua**: Main addon initialization and core functionality
- **Window.lua**: Factory for creating window-like frames with dynamic titlebar buttons
- **Types.lua**: All type definitions using LuaDoc annotations
- **Modules/**: Individual feature modules (Main, Equipment, WeeklyAffixes)
- **Libs/**: Ace3 framework libraries and dependencies

## AI Development Rules

### 1. README.md File
**DO NOT modify the README.md file unless explicitly instructed.** 
- The README.md is intended for end-users (players), not developers
- It contains user-facing documentation and should remain stable
- Any technical documentation should go in the `/docs` folder instead

### 2. Type Definitions
**All type definitions MUST be written in the Types.lua file.**
- Use LuaDoc annotations (`---@class`, `---@field`, etc.)
- Keep all type definitions centralized in one location
- Follow the existing naming convention: `AE_` prefix for addon-specific types

### 3. Code Style and Patterns
- Follow existing Lua coding conventions in the codebase
- Use the Ace3 framework patterns established in the project
- Maintain the factory pattern for UI creation in Window.lua
- Use descriptive variable and function names

### 4. File Organization
- Keep modules in the `Modules/` directory
- Store media assets in the `Media/` directory
- Place documentation in the `ai-docs/` directory
- Maintain the existing library structure in `Libs/`
- Do NOT modify files under `Libs/` (locked down; only developers add/remove/update)

### 4.1. Documentation Structure
- Update documentation files after every major change
- Documentation is for project developers, not players
- Create separate documentation files for different categories (data, UI, etc.)
- If README.md should be updated for new features, make suggestions and confirm first

### 5. Dynamic UI System
- The Window.lua factory supports dynamic titlebar button creation
- Use the `AE_TitlebarButton` type for button configuration
- Buttons can be added/removed programmatically at runtime
- Follow the established pattern for button positioning and event handling

### 6. Error Handling
- Use proper error checking for WoW API calls
- Validate input parameters in public functions
- Provide meaningful error messages for debugging
- Add English error messages whenever you see fit for checking invalid arguments and similar validation

### 7. Performance Considerations
- Minimize unnecessary UI updates
- Use event-driven programming patterns
- Avoid creating excessive frames or textures

### 8. Module Class Annotation Pattern
- Each module file defines its main table object and includes a class annotation above it for better cross-file IntelliSense
- The full class shape (fields/methods) belongs in `Types.lua`; per-file class lines are only for identification and inference
- Pattern (first ~10 lines of a module):
```lua
---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)
---@class AE_Module_<Name> : AceModule
local Module = addon.Core:NewModule("<Name>", ...)
addon.Module_<Name> = Module
```
- Everywhere else, prefer `---@type` for local variables/values that need type validation

## Common Patterns
- Window creation: `addon.Window:New(options)`
- Database access: `self.db.global` (most data is global)

## Questions and Clarifications
If you're unsure about any aspect of the codebase or need clarification on implementation details, ask for specific guidance rather than making assumptions.
