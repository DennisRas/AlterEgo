---@class AE_Addon
local addon = select(2, ...)

---@class AE_Events
local Events = {}
addon.Events = Events
Events.handlers = {}
Events.runtime = {pendingByCallback = {}}
Events.frame = CreateFrame("Frame", addon.name .. "EventsFrame")

---@type number
local BUCKET_INTERVAL_SEC = 2

---Events that fire for every unit but only matter for the player
local PLAYER_ONLY_EVENTS = {
  UNIT_INVENTORY_CHANGED = true,
}

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

  -- Bucket per callback, so a callback registered for several events runs once per burst
  local pendingByCallback = Events.runtime.pendingByCallback
  for i = 1, #list do
    local entry = list[i]
    if not entry.runsImmediately then
      local fn = entry.fn
      local bucket = pendingByCallback[fn]
      if not bucket then
        bucket = {event = event, packedVarargs = packedVarargs}
        pendingByCallback[fn] = bucket
        bucket.timer = C_Timer.NewTimer(BUCKET_INTERVAL_SEC, function()
          pendingByCallback[fn] = nil
          if Events:IsRegistered(bucket.event, fn) then
            fn(frame, bucket.event, unpackEventVarargs(bucket.packedVarargs))
          end
        end)
      else
        bucket.event = event
        bucket.packedVarargs = packedVarargs
      end
    end
  end
end)

---@param event string
---@param callback function
---@return boolean
function Events:IsRegistered(event, callback)
  local list = self.handlers[event]
  if not list then
    return false
  end
  for i = 1, #list do
    if list[i].fn == callback then
      return true
    end
  end
  return false
end

---Cancel a pending bucketed run of a callback
---@param callback function
local function cancelPending(callback)
  local pendingByCallback = Events.runtime.pendingByCallback
  local bucket = pendingByCallback[callback]
  if bucket and bucket.timer then
    bucket.timer:Cancel()
  end
  pendingByCallback[callback] = nil
end

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
    if PLAYER_ONLY_EVENTS[event] then
      self.frame:RegisterUnitEvent(event, "player")
    else
      self.frame:RegisterEvent(event)
    end
  end
  if self:IsRegistered(event, callback) then
    return
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
        cancelPending(callback)
      end
    end
    if #list == 0 then
      self.handlers[event] = nil
      self.frame:UnregisterEvent(event)
    end
  else
    for i = 1, #list do
      cancelPending(list[i].fn)
    end
    self.handlers[event] = nil
    self.frame:UnregisterEvent(event)
  end
end
