---@class LiqUI_LoggerDB
---@field enabled boolean
---@field autoScroll boolean
---@field autoShow boolean
---@field lines string[]

---@class LiqUI_LoggerOptions
---@field name string?
---@field title string?
---@field width number?
---@field height number?
---@field bodyPadding number?
---@field linesMax number?
---@field clearIcon string?
---@field clearIconSize number?
---@field fontObject string?
---@field onWindowShow function?

---@class LiqUI_Logger
---@field embed LiqUI_Instance
---@field instances table<string, LiqUI_LoggerInstance>

---@class LiqUI_LoggerInstance
---@field embed LiqUI_Instance
---@field db LiqUI_LoggerDB
---@field options LiqUI_LoggerOptions
---@field window LiqUI_WindowInstance|nil
---@field refreshPending boolean
