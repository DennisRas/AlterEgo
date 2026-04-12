---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

---@class AE_Events
local Events = {}
addon.Events = Events
Events.handlers = {}
Events.runtime = {pendingByEventName = {}}
Events.frame = CreateFrame("Frame", addonName .. "EventsFrame")

---@type number
local BUCKET_INTERVAL_SEC = 2

---@param ... any
---@return AE_EventPackedVarargs
local function packEventVarargs(...)
  local n = select("#", ...)
  local t = {n = n}
  for i = 1, n do
    t[i] = select(i, ...)
  end
  return t
end

---@param packed AE_EventPackedVarargs
---@return any ...
local function unpackEventVarargs(packed)
  if not packed or (packed.n or 0) == 0 then
    return
  end
  return unpack(packed, 1, packed.n)
end


Events.frame:SetScript("OnEvent", function(frame, event, ...)
  local list = Events.handlers[event]
  if not list then
    return
  end

  local packedVarargs = packEventVarargs(...)

  for i = 1, #list do
    local entry = list[i]
    if entry.runsImmediately then
      entry.fn(frame, event, unpackEventVarargs(packedVarargs))
    end
  end

  local hasBucketed = false
  for i = 1, #list do
    if not list[i].runsImmediately then
      hasBucketed = true
      break
    end
  end
  if not hasBucketed then
    return
  end

  local pendingByEventName = Events.runtime.pendingByEventName
  local bucket = pendingByEventName[event]
  if not bucket or not bucket.timer then
    bucket = {packedVarargs = packedVarargs}
    pendingByEventName[event] = bucket
    bucket.timer = C_Timer.NewTimer(BUCKET_INTERVAL_SEC, function()
      local snapshot = bucket.packedVarargs
      bucket.timer = nil
      pendingByEventName[event] = nil
      local currentList = Events.handlers[event]
      if not currentList then
        return
      end
      for j = 1, #currentList do
        local entry = currentList[j]
        if not entry.runsImmediately then
          entry.fn(frame, event, unpackEventVarargs(snapshot))
        end
      end
    end)
  else
    bucket.packedVarargs = packedVarargs
  end
end)

---@param event string|string[]
---@param callback AE_EventCallback
---@param runsImmediately boolean|nil
function Events:RegisterEvent(event, callback, runsImmediately)
  if type(event) == "table" then
    for _, eventName in ipairs(event) do
      self:RegisterEvent(eventName, callback, runsImmediately)
    end
    return
  end
  local list = self.handlers[event]
  if not list then
    list = {}
    self.handlers[event] = list
    self.frame:RegisterEvent(event)
  end
  list[#list + 1] = {fn = callback, runsImmediately = runsImmediately == true}
end

---@param event string|string[]
---@param callback function|nil
function Events:UnregisterEvent(event, callback)
  if type(event) == "table" then
    for _, eventName in ipairs(event) do
      self:UnregisterEvent(eventName, callback)
    end
    return
  end
  local list = self.handlers[event]
  if not list then
    return
  end
  if callback then
    for i = #list, 1, -1 do
      if list[i].fn == callback then
        table.remove(list, i)
      end
    end
    if #list == 0 then
      self.handlers[event] = nil
      local pendingByEventName = self.runtime.pendingByEventName
      local bucket = pendingByEventName[event]
      if bucket and bucket.timer then
        bucket.timer:Cancel()
      end
      pendingByEventName[event] = nil
      self.frame:UnregisterEvent(event)
    end
  else
    self.handlers[event] = nil
    local pendingByEventName = self.runtime.pendingByEventName
    local bucket = pendingByEventName[event]
    if bucket and bucket.timer then
      bucket.timer:Cancel()
    end
    pendingByEventName[event] = nil
    self.frame:UnregisterEvent(event)
  end
end
