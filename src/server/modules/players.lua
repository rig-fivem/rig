--- @module player
--- @file src/server/modules/player.lua
--- @description Server side handling for player objects.

--- @section Guard

if rawget(_G, "__server_players_module") then
    return _G.__server_players_module
end

--- @section Initialisation

local m = {}
_G.__server_players_module = m

--- @section Getters

-- Internal use only (same-runtime callers) — NOT exported.
-- Returns the raw Player object with live methods intact.
-- Exporting this would strip its metatable/methods on the way out.
function m.get_player(source)
    return rig.players:get(source)
end

function m.get_players()
    return rig.players:get_all()
end

function m.get_player_identifier(source, id_type)
    if not id_type then
        log("error", "Function: get_player_identifier failed | Reason: id_type parameter is missing.")
        return nil
    end

    return GetPlayerIdentifierByType(source, id_type)
end

function m.get_player_identifiers(source)
    local ids = {}
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if id:find("license") then ids.license = id end
        if id:find("discord") then ids.discord = id end
        if id:find("ip") then ids.ip = id end
    end
    return ids
end

--- @section Buckets

function m.get_player_bucket(source)
    return rig.players:get_bucket(source)
end

function m.set_player_bucket(source, bucket_id)
    if not bucket_id then
        log("error", "Function: set_player_bucket failed | Reason: bucket_id parameter is missing.")
        return false
    end

    return rig.players:set_bucket(source, bucket_id)
end

function m.assign_personal_bucket(source)
    return rig.players:assign_personal_bucket(source)
end

--- @section State

function m.has_player_loaded(source)
    local p = rig.players:get(source)
    return p ~= nil and p:has_loaded()
end

function m.is_player_playing(source)
    local p = rig.players:get(source)
    return p ~= nil and p:is_playing()
end

function m.set_player_playing(source, state)
    local p = rig.players:get(source)
    if not p then
        log("warn", ("Function: set_player_playing failed | Reason: no player instance for source %d"):format(source))
        return false
    end

    p:set_playing(state)
    return true
end

--- @section Data

function m.get_player_data(source, category)
    local p = rig.players:get(source)
    if not p then return nil end
    return p:get_data(category)
end

function m.has_player_data(source, category)
    local p = rig.players:get(source)
    return p ~= nil and p:has_data(category)
end

function m.add_player_data(source, category, value, replicate)
    local p = rig.players:get(source)
    if not p then
        log("warn", ("Function: add_player_data failed | Reason: no player instance for source %d"):format(source))
        return false
    end

    return p:add_data(category, value, replicate)
end

function m.set_player_data(source, category, updates, sync_data)
    local p = rig.players:get(source)
    if not p then
        log("warn", ("Function: set_player_data failed | Reason: no player instance for source %d"):format(source))
        return false
    end

    return p:set_data(category, updates, sync_data)
end

function m.replace_player_data(source, category, data, sync_data)
    local p = rig.players:get(source)
    if not p then
        log("warn", ("Function: replace_player_data failed | Reason: no player instance for source %d"):format(source))
        return false
    end

    return p:replace_data(category, data, sync_data)
end

function m.remove_player_data(source, category)
    local p = rig.players:get(source)
    if not p then
        log("warn", ("Function: remove_player_data failed | Reason: no player instance for source %d"):format(source))
        return false
    end

    return p:remove_data(category)
end

function m.sync_player_data(source, category)
    local p = rig.players:get(source)
    if not p then
        log("warn", ("Function: sync_player_data failed | Reason: no player instance for source %d"):format(source))
        return false
    end

    p:sync_data(category)
    return true
end

function m.save_player(source)
    local p = rig.players:get(source)
    if not p then
        log("warn", ("Function: save_player failed | Reason: no player instance for source %d"):format(source))
        return false
    end

    p:save()
    return true
end

--- @section Exports

exports("get_players", m.get_players)
exports("get_player_identifier", m.get_player_identifier)
exports("get_player_identifiers", m.get_player_identifiers)
exports("get_player_bucket", m.get_player_bucket)
exports("set_player_bucket", m.set_player_bucket)
exports("assign_personal_bucket", m.assign_personal_bucket)
exports("has_player_loaded", m.has_player_loaded)
exports("is_player_playing", m.is_player_playing)
exports("set_player_playing", m.set_player_playing)
exports("get_player_data", m.get_player_data)
exports("has_player_data", m.has_player_data)
exports("add_player_data", m.add_player_data)
exports("set_player_data", m.set_player_data)
exports("replace_player_data", m.replace_player_data)
exports("remove_player_data", m.remove_player_data)
exports("sync_player_data", m.sync_player_data)
exports("save_player", m.save_player)

return m