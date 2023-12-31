--- Find a table item by callback
---@param tbl table
---@param callback function
---@return table|nil, number|nil
function AE_table_find(tbl, callback)
    for i, v in ipairs(tbl) do
        if callback(v, i) then return v, i end
    end
    return nil, nil
end

--- Find a table item by key and value
---@param tbl table
---@param key string
---@param val any
---@return table|nil
function AE_table_get(tbl, key, val)
    return AE_table_find(tbl, function(elm)
        return elm[key] and elm[key] == val
    end)
end

--- Create a new table containing all elements that pass truth test
---@param tbl table
---@param callback function
---@return table
function AE_table_filter(tbl, callback)
    local t = {}
    for i, v in ipairs(tbl) do
        if callback(v, i) then table.insert(t, v) end
    end
    return t
end

--- Count table items
---@param tbl table
---@return number
function AE_table_count(tbl)
    local n = 0
    for _ in pairs(tbl) do n = n + 1 end
    return n
end

--- Deep copy a table
---@param from table
---@param to table|nil
---@param recursion_check table|nil
function AE_table_copy(from, to, recursion_check)
    local table = (to == nil) and {} or to
    if not recursion_check then recursion_check = {} end
    if recursion_check[from] then return "<recursion>" end
    recursion_check[from] = true
    for k, v in pairs(from) do
        table[k] = type(v) == "table" and AE_table_copy(v, nil, recursion_check) or v
    end
    return table
end

--- Map each item in a table
---@param tbl table
---@param callback function
function AE_table_map(tbl, callback)
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
function AE_table_foreach(tbl, callback)
    for ik, iv in pairs(tbl) do
        callback(iv, ik)
    end
    return tbl
end

function AE_GetActivitiesProgress(character)
    local activities = AE_table_filter(character.vault.slots, function(slot) return slot.type == Enum.WeeklyRewardChestThresholdType.Activities end)
    table.sort(activities, function(left, right) return left.index < right.index; end);
    local lastCompletedIndex = 0;
    for i, activityInfo in ipairs(activities) do
        if activityInfo.progress >= activityInfo.threshold then
            lastCompletedIndex = i;
        end
    end
    if lastCompletedIndex == 0 then
        return nil, nil;
    else
        if lastCompletedIndex == #activities then
            local info = activities[lastCompletedIndex];
            return info, nil;
        else
            local nextInfo = activities[lastCompletedIndex + 1];
            return activities[lastCompletedIndex], nextInfo;
        end
    end
end

function AE_GetLowestLevelInTopDungeonRuns(character, numRuns)
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

    local runHistory = AE_table_filter(character.mythicplus.runHistory, function(run) return run.thisWeek == true end);
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

function AE_GetGroupChannel()
    if IsInRaid() then
        return "RAID"
    elseif IsInGroup() then
        return "PARTY"
    else
        return nil
    end
end