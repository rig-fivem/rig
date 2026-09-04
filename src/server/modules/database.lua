--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @module database
--- @file src/server/modules/database.lua
--- @description Driver-agnostic database interface. All other modules/extensions should call through here, never exports.oxmysql directly.

--- @section Initialisation

local m = {}

--- @section Driver

-- swap this single block to change database backends (oxmysql, postgres wrapper, etc)
local driver = {
    query = function(query, params) return exports.oxmysql:query_async(query, params) end,
    insert = function(query, params) return exports.oxmysql:insert_async(query, params) end,
    update = function(query, params) return exports.oxmysql:update_async(query, params) end,
    single = function(query, params) return exports.oxmysql:single_async(query, params) end,
    transaction = function(queries) return exports.oxmysql:transaction_async(queries) end,
}

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
    local query = json_path
        and string.format("SELECT COUNT(*) as count FROM %s WHERE JSON_EXTRACT(%s, '$.%s') = ?", table_name, column, json_path)
        or string.format("SELECT COUNT(*) as count FROM %s WHERE %s = ?", table_name, column)

    local result = m.query(query, { new_id })
    return result and result[1] and result[1].count > 0
end

--- @section Core Query Functions

function m.query(query, params)
    return driver.query(query, params or {})
end

function m.insert(query, params)
    return driver.insert(query, params or {})
end

function m.update(query, params)
    return driver.update(query, params or {})
end

function m.single(query, params)
    return driver.single(query, params or {})
end

function m.transaction(queries)
    return driver.transaction(queries)
end

--- @section Functions

function m.value_exists_in_database(table_name, column, value, extra_where, extra_params)
    local query = string.format("SELECT COUNT(*) as count FROM %s WHERE %s = ?", table_name, column)
    local params = { value }

    if extra_where then
        query = query .. " AND " .. extra_where
        for _, p in ipairs(extra_params or {}) do
            params[#params + 1] = p
        end
    end

    local result = m.query(query, params)
    return result and result[1] and result[1].count > 0
end

function m.generate_unique_id(length, table_name, column, json_path)
    local id
    repeat
        id = create_id(length)
    until not id_exists(table_name, column, json_path, id)
    return id
end

--- @section Exports

exports("query", m.query)
exports("insert", m.insert)
exports("update", m.update)
exports("single", m.single)
exports("transaction", m.transaction)
exports("value_exists_in_database", m.value_exists_in_database)
exports("generate_unique_id", m.generate_unique_id)

return m