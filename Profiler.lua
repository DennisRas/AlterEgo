---@class AE_Addon
local addon = select(2, ...)

---Lightweight timing instrumentation. Use /aeprof to print results.
---@class AE_Profiler
local Profiler = {}
addon.Profiler = Profiler

local debugprofilestop = debugprofilestop

local HITCH_THRESHOLD_MS = 100
local WATCH_DURATION_SEC = 60
local LOG_SINGLE_CALL_MS = 50

local loadTime = GetTime()
local stats = {}
local hitches = {}
local depth = 0
local frameWork = 0
local frameLabels = {}

---@return number
function Profiler.Start()
  depth = depth + 1
  return debugprofilestop()
end

---@param label string
---@param start number
function Profiler.Stop(label, start)
  local elapsed = debugprofilestop() - start
  depth = depth - 1
  local stat = stats[label]
  if not stat then
    stat = {count = 0, total = 0, max = 0}
    stats[label] = stat
  end
  stat.count = stat.count + 1
  stat.total = stat.total + elapsed
  if elapsed > stat.max then
    stat.max = elapsed
  end
  if depth == 0 then
    frameWork = frameWork + elapsed
    if elapsed >= 1 then
      frameLabels[#frameLabels + 1] = format("%s %.0fms", label, elapsed)
    end
  end
  if elapsed >= LOG_SINGLE_CALL_MS then
    print(format("|cffff8800AlterEgo profiler:|r %s took %.1fms", label, elapsed))
  end
end

do -- Detect long frames shortly after load and attribute AlterEgo's share
  local watcher = CreateFrame("Frame")
  watcher:SetScript("OnUpdate", function(self, elapsed)
    local ms = elapsed * 1000
    if ms >= HITCH_THRESHOLD_MS then
      hitches[#hitches + 1] = {
        at = GetTime() - loadTime,
        ms = ms,
        work = frameWork,
        labels = table.concat(frameLabels, ", "),
      }
    end
    frameWork = 0
    wipe(frameLabels)
    if GetTime() - loadTime > WATCH_DURATION_SEC then
      self:SetScript("OnUpdate", nil)
    end
  end)
end

function Profiler.Print()
  print("|cffff8800AlterEgo profiler|r")

  if C_AddOnProfiler and C_AddOnProfiler.GetAddOnMetric and Enum.AddOnProfilerMetric then
    local peak = C_AddOnProfiler.GetAddOnMetric(addon.name, Enum.AddOnProfilerMetric.PeakTime)
    local avg = C_AddOnProfiler.GetAddOnMetric(addon.name, Enum.AddOnProfilerMetric.SessionAverageTime)
    if peak then
      print(format("Blizzard profiler: peak %.1fms, session avg %.3fms/frame", peak, avg or 0))
    end
  end

  print(format("Long frames (>=%dms) in the first %ds:", HITCH_THRESHOLD_MS, WATCH_DURATION_SEC))
  if #hitches == 0 then
    print("  none")
  end
  for _, hitch in ipairs(hitches) do
    print(format("  t=%.1fs frame %.0fms, AlterEgo %.1fms %s", hitch.at, hitch.ms, hitch.work, hitch.labels ~= "" and ("(" .. hitch.labels .. ")") or ""))
  end

  local list = {}
  for label, stat in pairs(stats) do
    list[#list + 1] = {label = label, stat = stat}
  end
  table.sort(list, function(a, b) return a.stat.max > b.stat.max end)
  print("Slowest calls (max / total / count):")
  for i = 1, math.min(20, #list) do
    local entry = list[i]
    print(format("  %s: %.1fms / %.1fms / %d", entry.label, entry.stat.max, entry.stat.total, entry.stat.count))
  end
end

SLASH_ALTEREGOPROFILE1 = "/aeprof"
SlashCmdList["ALTEREGOPROFILE"] = Profiler.Print
