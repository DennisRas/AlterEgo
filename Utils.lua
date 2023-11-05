--- Find a table item by callback
---@param tbl table
---@param fnc function
---@return table|nil, number|nil
function AE_table_find(tbl, fnc)
    for i, v in ipairs(tbl) do
        if fnc(v, i) then return v, i end
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
---@param fnc function
---@return table
function AE_table_filter(tbl, fnc)
    local t = {}
    for i, v in ipairs(tbl) do
        if fnc(v, i) then t.insert(v) end
    end
    return t
end

--- Count table items
---@param table table
---@return number
function AE_table_count(table)
    local n = 0
    for _ in pairs(table) do n = n + 1 end
    return n
end