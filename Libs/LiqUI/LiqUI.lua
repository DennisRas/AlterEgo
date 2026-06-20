assert(LibStub, "LiqUI requires LibStub")

local MAJOR, MINOR = "LiqUI-1.0", 1
---@class LiqUI
local LiqUI = LibStub:NewLibrary(MAJOR, MINOR)
if not LiqUI then
  return
end

LiqUI.minor = MINOR

_G.LiqUI = LiqUI

---@param instance LiqUI_Instance
---@param prototype table
---@param state table?
---@return table
function LiqUI.BindManager(instance, prototype, state)
  local manager = state or {}
  manager.embed = instance
  setmetatable(manager, {
    __index = function(_, key)
      local value = prototype[key]
      if value ~= nil then
        return value
      end
      return instance[key]
    end,
  })
  return manager
end

---@param options LiqUI_NewOptions
---@return LiqUI_Instance
function LiqUI:New(options)
  if not options or not options.name or options.name == "" then
    error("LiqUI:New requires name", 2)
  end
  if type(options.db) ~= "table" then
    error("LiqUI:New requires db", 2)
  end
  if type(options.db.windows) ~= "table" then
    error("LiqUI:New requires db.windows", 2)
  end
  if type(options.db.tables) ~= "table" then
    error("LiqUI:New requires db.tables", 2)
  end
  if type(options.db.loggers) ~= "table" then
    error("LiqUI:New requires db.loggers", 2)
  end

  local db = options.db

  LiqUI.instances = LiqUI.instances or {}
  local existing = LiqUI.instances[options.name]
  if existing then
    existing.db = db
    return existing
  end

  ---@type LiqUI_Instance
  local instance = {
    name = options.name,
    db = db,
  }

  for key, mod in pairs(LiqUI) do
    if type(mod) == "table" and mod.Embed then
      mod:Embed(instance)
    end
  end

  setmetatable(instance, { __index = LiqUI })
  LiqUI.instances[options.name] = instance
  return instance
end
