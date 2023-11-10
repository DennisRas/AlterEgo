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
        table[k] = type(v) == 'table' and AE_table_copy(v, nil, recursion_check) or v
    end
    return table
end

function AE_table_map(tbl, callback)
    local t = {}
    for ik, iv in pairs(tbl) do
        local fv, fk = callback(iv, ik)
        t[fk and fk or ik] = fv
    end
    return t
end