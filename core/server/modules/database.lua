--- @file src/server/modules/database.lua
--- @description Handles general database functions

--- @section Initialisation

local m = {}

--- @section Helpers

local function create_id(length)
    local charset = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local id = ""
    for i = 1, length do
        local idx = math.random(1, #charset)
        id = id .. charset:sub(idx, idx)
    end
    return id
end

local function id_exists(table_name, column, json_path, new_id)
    local query = json_path and string.format("SELECT COUNT(*) as count FROM %s WHERE JSON_EXTRACT(%s, '$.%s') = ?", table_name, column, json_path) or string.format("SELECT COUNT(*) as count FROM %s WHERE %s = ?", table_name, column)
    local result = exports.oxmysql:query_async(query, { new_id })
    return result and result[1] and result[1].count > 0
end

--- @section Lookups

function m.value_exists(table_name, column, value, extra_where, extra_params)
    local query = string.format("SELECT COUNT(*) as count FROM %s WHERE %s = ?", table_name, column)
    local params = { value }

    if extra_where then
        query = query .. " AND " .. extra_where
        for _, p in ipairs(extra_params or {}) do
            params[#params + 1] = p
        end
    end

    local result = exports.oxmysql:query_async(query, params)
    return result and result[1] and result[1].count > 0
end

--- @section Generation

function m.generate_unique_id(length, table_name, column, json_path)
    local id
    repeat
        id = create_id(length)
    until not id_exists(table_name, column, json_path, id)
    return id
end

return m