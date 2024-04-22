local addonName, AlterEgo = ...
local Utils = {}
AlterEgo.Utils = Utils

--- Set the background color for a parent frame
---@param parent table
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

--- Find a table item by callback
---@param tbl table
---@param callback function
---@return table|nil, number|nil
function Utils:TableFind(tbl, callback)
  for i, v in ipairs(tbl) do
    if callback(v, i) then
      return v, i
    end
  end
  return nil, nil
end

--- Find a table item by key and value
---@param tbl table
---@param key string
---@param val any
---@return table|nil
function Utils:TableGet(tbl, key, val)
  return Utils:TableFind(tbl, function(elm)
    return elm[key] and elm[key] == val
  end)
end

--- Create a new table containing all elements that pass truth test
---@param tbl table
---@param callback function
---@return table
function Utils:TableFilter(tbl, callback)
  local t = {}
  for i, v in ipairs(tbl) do
    if callback(v, i) then
      table.insert(t, v)
    end
  end
  return t
end

--- Count table items
---@param tbl table
---@return number
function Utils:TableCount(tbl)
  local n = 0
  for _ in pairs(tbl) do
    n = n + 1
  end
  return n
end

--- Deep copy a table
---@param from table
---@param to table|nil
---@param recursion_check table|nil
---@return table|nil|string
function Utils:TableCopy(from, to, recursion_check)
  local table = to
  if to == nil then
    table = {}
  end
  if not recursion_check then
    recursion_check = {}
  end
  if recursion_check[from] then
    return "<recursion>"
  end
  recursion_check[from] = true
  for k, v in pairs(from) do
    table[k] = type(v) == "table" and Utils:TableCopy(v, nil, recursion_check) or v
  end
  return table
end

--- Map each item in a table
---@param tbl table
---@param callback function
---@return table
function Utils:TableMap(tbl, callback)
  local t = {}
  for ik, iv in pairs(tbl) do
    local fv, fk = callback(iv, ik)
    t[fk and fk or ik] = fv
  end
  return t
end

--- Run a callback on each table item
---@param tbl table
---@param callback function
---@return table
function Utils:TableForEach(tbl, callback)
  for ik, iv in pairs(tbl) do
    callback(iv, ik)
  end
  return tbl
end

--- Get character activity progress
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

--- Get the group type
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

--- Get a rating color
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
