---@class LiqUI
local LiqUI = LibStub and LibStub("LiqUI-1.0", true)
if not LiqUI then
  return
end

---@class LiqUI_Logger
local Logger = {}
LiqUI.Logger = Logger

local TableMergeOptions = LiqUI.Utils.TableMergeOptions
local CreateScrollingEditBox = LiqUI.Utils.CreateScrollingEditBox

local LoggerInstance = {}

---@param instance LiqUI_Instance
function Logger:Embed(instance)
  instance.Logger = LiqUI.BindManager(instance, self, { instances = {} })
end

---@param textBox Frame
---@param text string
---@param scrollToEnd boolean|nil
local function applyLogText(textBox, text, scrollToEnd)
  local editBox = textBox:GetEditBox()
  if editBox.logText ~= text then
    editBox.logText = text
    textBox:SetText(text)
  end
  if scrollToEnd then
    C_Timer.After(0, function()
      local scrollBox = textBox:GetScrollBox()
      if scrollBox then
        scrollBox:ScrollToEnd()
      end
    end)
  end
end

---@param logger LiqUI_LoggerInstance
local function trimLoggerLines(logger)
  local linesMax = logger.options.linesMax or 200
  while #logger.db.lines > linesMax do
    table.remove(logger.db.lines, 1)
  end
end

---@param options LiqUI_LoggerOptions?
---@return LiqUI_LoggerInstance
function Logger:New(options)
  if not self.db then
    error("LiqUI.Logger:New requires a LiqUI instance", 2)
  end

  ---@type LiqUI_LoggerOptions
  local defaultOptions = {
    name = "Logger",
    title = "Log",
    width = 1200,
    height = 600,
    bodyPadding = LiqUI.Constants.layout.sizes.padding,
    linesMax = 200,
    clearIconSize = 12,
    fontObject = "ChatFontSmall",
  }
  ---@type LiqUI_LoggerOptions
  local mergedOptions = {}
  TableMergeOptions(mergedOptions, defaultOptions)
  TableMergeOptions(mergedOptions, options or {})

  local loggerName = mergedOptions.name or "Logger"
  if loggerName == "" then
    error("LiqUI Logger: options.name is required", 2)
  end

  if not self.db.loggers[loggerName] then
    ---@type LiqUI_LoggerDB
    self.db.loggers[loggerName] = {
      enabled = false,
      autoScroll = true,
      autoShow = false,
      lines = {},
    }
  end

  ---@type LiqUI_LoggerInstance
  local logger = setmetatable({
    embed = self.embed,
    db = self.db.loggers[loggerName],
    options = mergedOptions,
    refreshPending = false,
    window = nil,
  }, { __index = LoggerInstance })
  self.instances[loggerName] = logger
  return logger
end

function LoggerInstance:Initialize()
  self:Render()
end

function LoggerInstance:SetEnabled(enabled)
  self.db.enabled = enabled
end

---@return boolean
function LoggerInstance:IsEnabled()
  return self.db.enabled or false
end

function LoggerInstance:LogSession()
  table.insert(
    self.db.lines,
    format("[%s] [Session] ---------- %s ----------", date("%H:%M:%S"), date("%Y-%m-%d %H:%M:%S"))
  )
  trimLoggerLines(self)
  self:QueueRefresh()
end

function LoggerInstance:Render()
  if not self.window then
    local options = self.options
    ---@type LiqUI_WindowOptions
    local windowOptions = {
      name = options.name,
      title = options.title,
      width = options.width,
      height = options.height,
      titlebarButtons = {
        {
          name = "ClearButton",
          icon = options.clearIcon,
          tooltipTitle = "Clear log",
          tooltipDescription = "Remove all lines from the log window.",
          onClick = function()
            self:Clear()
          end,
          iconSize = options.clearIconSize,
        },
      },
    }
    local window = self.embed.Window:New(windowOptions)
    window:SetScript("OnShow", function()
      if options.onWindowShow then
        options.onWindowShow(window)
      end
      self:Render()
    end)

    local scrollHost = CreateScrollingEditBox(window.body, options.bodyPadding)
    local textBox = scrollHost.textBox
    textBox:SetFontObject(options.fontObject or "ChatFontSmall")

    local editBox = textBox:GetEditBox()
    editBox.logText = ""
    editBox:SetScript("OnChar", function()
    end)
    editBox:SetScript("OnKeyDown", function(_, key)
      if IsControlKeyDown() then
        return
      end
      if key == "ESCAPE" then
        textBox:ClearFocus()
      end
    end)

    window.body.textBox = textBox
    window.body.scrollBar = scrollHost.scrollBar
    self.window = window
  end

  local textBox = self.window.body.textBox
  if not textBox then
    return
  end

  if not self.window:IsVisible() then
    return
  end

  local text = table.concat(self.db.lines, "\n")
  local editBox = textBox:GetEditBox()
  if editBox.logText ~= text then
    applyLogText(textBox, text, self.db.autoScroll)
  end
end

function LoggerInstance:QueueRefresh()
  if self.refreshPending then
    return
  end
  self.refreshPending = true
  C_Timer.After(0, function()
    self.refreshPending = false
    self:Render()
  end)
end

---@param state boolean|nil
function LoggerInstance:Toggle(state)
  if not self.window then
    return
  end
  self.window:Toggle(state)
  if self.window:IsVisible() then
    self:Render()
  end
end

function LoggerInstance:Clear()
  wipe(self.db.lines)
  self:QueueRefresh()
end

---@param prefix string
---@param message string
function LoggerInstance:Log(prefix, message)
  if not self.db.enabled then
    return
  end

  local lineText = format("[%s] [%s] %s", date("%H:%M:%S"), prefix, message)
  table.insert(self.db.lines, lineText)
  trimLoggerLines(self)

  if self.db.autoShow then
    self:Show()
  end
  self:QueueRefresh()
end

function LoggerInstance:Show()
  self:Toggle(true)
end

function LoggerInstance:Hide()
  self:Toggle(false)
end
