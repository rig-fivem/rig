--- @module spawns
--- @file src/server/modules/spawns.lua
--- @description Server side handling for player spawn locations.

--- @section Guard

if rawget(_G, "__server_spawns_module") then
    return _G.__server_spawns_module
end

--- @section Initialisation

local m = {}
_G.__server_spawns_module = m

--- @section Functions

function m.request_spawns(source)
    if not source then
        log("error", "Source missing.")
        return nil
    end

    local player = core.players:get(source)
    if not player or not player.spawns then
        log("error", ("Player or player spawn extension missing for source %s"):format(tostring(source)))
        return nil
    end

    return player.spawns:get_spawns()
end

function m.spawn_player(source, coords)
    if not source or type(coords) ~= "table" then
        log("error", "Source or coords missing.")
        return false
    end

    local player = core.players:get(source)
    if not player or not player.spawns then
        log("error", ("Player or player spawn extension missing for source %s"):format(tostring(source)))
        return false
    end

    player.spawns:spawn_player(coords)
    return true
end

--- @section Events

RegisterServerEvent("rig:server:request_spawn")
AddEventHandler("rig:server:request_spawn", function()
    local _src = source
    if not _src then return end

    local spawns = m.request_spawns(_src)
    if not spawns then
        log("error", ("Failed to fetch spawns for source %s"):format(_src))
        return
    end

    TriggerEvent("rig:server:request_spawn_response", _src, spawns)
end)

--- @section Exports

exports("request_spawns", m.request_spawns)
exports("spawn_player", m.spawn_player)

return m