---@type string
local addonName = select(1, ...)
---@class AE_Addon
local addon = select(2, ...)

---@class AE_Utils
local Utils = {}
addon.Utils = Utils

---Set the background color for a parent frame
---@param parent Frame
---@param r number
---@param g number
---@param b number
---@param a number
function Utils:SetBackgroundColor(parent, r, g, b, a)
  if not parent.Background then
    parent.Background = parent:CreateTexture(parent:GetName() .. "Background", "BACKGROUND")
    parent.Background:SetTexture("Interface/BUTTONS/WHITE8X8")
    parent.Background:SetAllPoints()
  end

  parent.Background:SetVertexColor(r, g, b, a)
end

---Find a table item by callback
---@generic T
---@param tbl T[]
---@param callback fun(value: T, index: number): boolean
---@return T|nil, number|nil
function Utils:TableFind(tbl, callback)
  for i, v in ipairs(tbl) do
    if callback(v, i) then
      return v, i
    end
  end
  return nil, nil
end

---Find a table item by key and value
---@generic T
---@param tbl T[]
---@param key string
---@param val any
---@return T|nil
function Utils:TableGet(tbl, key, val)
  return Utils:TableFind(tbl, function(elm)
    return elm[key] and elm[key] == val
  end)
end

---Create a new table containing all elements that pass truth test
---@generic T
---@param tbl T[]
---@param callback fun(value: T, index: number): boolean
---@return T[]
function Utils:TableFilter(tbl, callback)
  local t = {}
  for i, v in ipairs(tbl) do
    if callback(v, i) then
      table.insert(t, v)
    end
  end
  return t
end

---Count table items
---@param tbl table
---@return number
function Utils:TableCount(tbl)
  local n = 0
  for _ in pairs(tbl) do
    n = n + 1
  end
  return n
end

---Deep copy a table
---@generic T
---@param tbl T[]
---@param cache table?
---@return T[]
function Utils:TableCopy(tbl, cache)
  local t = {}
  cache = cache or {}
  cache[tbl] = t
  self:TableForEach(tbl, function(v, k)
    if type(v) == "table" then
      t[k] = cache[v] or self:TableCopy(v, cache)
    else
      t[k] = v
    end
  end)
  return t
end

---Map each item in a table
---@generic T
---@param tbl T[]
---@param callback fun(value: T, index: number)
---@return T[]
function Utils:TableMap(tbl, callback)
  local t = {}
  self:TableForEach(tbl, function(v, k)
    local newv, newk = callback(v, k)
    t[newk and newk or k] = newv
  end)
  return t
end

---Run a callback on each table item
---@generic T
---@param tbl T[]
---@param callback fun(value: T, index: number)
---@return T[]
function Utils:TableForEach(tbl, callback)
  for ik, iv in pairs(tbl) do
    callback(iv, ik)
  end
  return tbl
end

---Get character activity progress
---@param character table
---@return table|nil, table|nil
function Utils:GetActivitiesProgress(character)
  local activities = Utils:TableFilter(character.vault.slots, function(slot) return slot.type == Enum.WeeklyRewardChestThresholdType.Activities end)
  table.sort(activities, function(left, right) return left.index < right.index; end);
  local lastCompletedIndex = 0;
  for i, activityInfo in ipairs(activities) do
    if activityInfo.progress >= activityInfo.threshold then
      lastCompletedIndex = i;
    end
  end

  if lastCompletedIndex == 0 then
    return nil, nil;
  end

  if lastCompletedIndex == #activities then
    local info = activities[lastCompletedIndex];
    return info, nil;
  end

  local nextInfo = activities[lastCompletedIndex + 1];
  return activities[lastCompletedIndex], nextInfo;
end

---Get the lowest keystone level completed from highest <numRuns> runs.
---Example: 4, 2, 2, 5, with numRuns = 2 would return 4
---@param character any
---@param numRuns number
---@return number|nil, number
function Utils:GetLowestLevelInTopDungeonRuns(character, numRuns)
  local lowestLevel;
  local lowestCount   = 0;
  local numHeroic     = 0;
  local numMythic     = 0;
  local numMythicPlus = 0;

  if character.mythicplus ~= nil and character.mythicplus.numCompletedDungeonRuns ~= nil then
    numHeroic = character.mythicplus.numCompletedDungeonRuns.heroic or 0
    numMythic = character.mythicplus.numCompletedDungeonRuns.mythic or 0
    numMythicPlus = character.mythicplus.numCompletedDungeonRuns.mythicPlus or 0
  end

  if numRuns > numMythicPlus and (numHeroic + numMythic) > 0 then
    if numRuns > numMythicPlus + numMythic and numHeroic > 0 then
      lowestLevel = WeeklyRewardsUtil.HeroicLevel;
      lowestCount = numRuns - numMythicPlus - numMythic;
    else
      lowestLevel = WeeklyRewardsUtil.MythicLevel;
      lowestCount = numRuns - numMythicPlus;
    end
    return lowestLevel, lowestCount;
  end

  local runHistory = Utils:TableFilter(character.mythicplus.runHistory, function(run) return run.thisWeek == true end);
  table.sort(runHistory, function(left, right) return left.level > right.level; end);
  for i = math.min(numRuns, #runHistory), 1, -1 do
    local run = runHistory[i];
    if not lowestLevel then
      lowestLevel = run.level;
    end
    if lowestLevel == run.level then
      lowestCount = lowestCount + 1;
    else
      break;
    end
  end
  return lowestLevel, lowestCount;
end

---Get the group type
---@return string|nil
function Utils:GetGroupChannel()
  if IsInRaid() then
    return "RAID"
  end
  if IsInGroup() then
    return "PARTY"
  end
  return nil
end

---Get a rating color
---@param rating number
---@param useRIOScoreColor boolean
---@param isPreviousSeason boolean
---@return ColorMixin|nil
function Utils:GetRatingColor(rating, useRIOScoreColor, isPreviousSeason)
  local color
  local RIO = _G["RaiderIO"]
  if useRIOScoreColor and RIO then
    color = CreateColor(RIO.GetScoreColor(rating, isPreviousSeason or false))
  else
    color = C_ChallengeMode.GetDungeonScoreRarityColor(rating)
  end
  return color
end
