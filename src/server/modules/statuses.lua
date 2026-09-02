--- @module statuses
--- @file src/server/modules/statuses.lua
--- @description Server side handling for player status, injuries, and effects.

--- @section Guard

if rawget(_G, "__server_statuses_module") then
    return _G.__server_statuses_module
end

--- @section Initialisation

local m = {}
_G.__server_statuses_module = m

--- @section Getters

function m.get_player_statuses(source)
    local p = core.players:get(source)
    if not p or not p.statuses then return nil end
    return p.statuses:get_all()
end

function m.get_player_status(source, key)
    local p = core.players:get(source)
    if not p or not p.statuses then return nil end
    return p.statuses:get(key)
end

function m.get_player_injury(source, part)
    local p = core.players:get(source)
    if not p or not p.statuses then return nil end
    return p.statuses:get_injury(part)
end

function m.get_player_effect(source, effect_name)
    local p = core.players:get(source)
    if not p or not p.statuses then return nil end
    return p.statuses:get_effect(effect_name)
end

--- @section State Checks

function m.is_player_dead(source)
    local p = core.players:get(source)
    return p ~= nil and p.statuses ~= nil and p.statuses:is_dead()
end

function m.is_player_downed(source)
    local p = core.players:get(source)
    return p ~= nil and p.statuses ~= nil and p.statuses:is_downed()
end

--- @section Setters

function m.set_player_status(source, key, value)
    local p = core.players:get(source)
    if not p or not p.statuses then
        log("warn", ("Function: set_player_status failed | Reason: no player/statuses instance for source %d"):format(source))
        return false
    end

    return p.statuses:set(key, value)
end

function m.set_player_statuses_bulk(source, status_table)
    local p = core.players:get(source)
    if not p or not p.statuses then
        log("warn", ("Function: set_player_statuses_bulk failed | Reason: no player/statuses instance for source %d"):format(source))
        return false
    end

    return p.statuses:set_bulk(status_table)
end

function m.set_player_injury(source, part, damage)
    local p = core.players:get(source)
    if not p or not p.statuses then
        log("warn", ("Function: set_player_injury failed | Reason: no player/statuses instance for source %d"):format(source))
        return false
    end

    return p.statuses:set_injury(part, damage)
end

function m.modify_player_injury(source, part, delta)
    local p = core.players:get(source)
    if not p or not p.statuses then
        log("warn", ("Function: modify_player_injury failed | Reason: no player/statuses instance for source %d"):format(source))
        return false
    end

    return p.statuses:modify_injury(part, delta)
end

--- @section Effects

function m.apply_player_status_effect(source, effect_name, opts)
    local p = core.players:get(source)
    if not p or not p.statuses then
        log("warn", ("Function: apply_player_status_effect failed | Reason: no player/statuses instance for source %d"):format(source))
        return false
    end

    return p.statuses:add_effect(effect_name, opts)
end

function m.remove_player_status_effect(source, effect_name)
    local p = core.players:get(source)
    if not p or not p.statuses then
        log("warn", ("Function: remove_player_status_effect failed | Reason: no player/statuses instance for source %d"):format(source))
        return false
    end

    return p.statuses:remove_effect(effect_name)
end

function m.clear_player_status_effects(source)
    local p = core.players:get(source)
    if not p or not p.statuses then
        log("warn", ("Function: clear_player_status_effects failed | Reason: no player/statuses instance for source %d"):format(source))
        return false
    end

    return p.statuses:clear_effects()
end

--- @section Actions

function m.respawn_player(source)
    local p = core.players:get(source)
    if not p or not p.statuses then
        log("warn", ("Function: respawn_player failed | Reason: no player/statuses instance for source %d"):format(source))
        return false
    end

    p.statuses:respawn()
    return true
end

function m.down_player(source)
    local p = core.players:get(source)
    if not p or not p.statuses then
        log("warn", ("Function: down_player failed | Reason: no player/statuses instance for source %d"):format(source))
        return false
    end

    p.statuses:down_player()
    return true
end

function m.kill_player(source)
    local p = core.players:get(source)
    if not p or not p.statuses then
        log("warn", ("Function: kill_player failed | Reason: no player/statuses instance for source %d"):format(source))
        return false
    end

    p.statuses:kill_player()
    return true
end

function m.pickup_player(source)
    local p = core.players:get(source)
    if not p or not p.statuses then
        log("warn", ("Function: pickup_player failed | Reason: no player/statuses instance for source %d"):format(source))
        return false
    end

    return p.statuses:pickup_player()
end

function m.revive_player(source)
    local p = core.players:get(source)
    if not p or not p.statuses then
        log("warn", ("Function: revive_player failed | Reason: no player/statuses instance for source %d"):format(source))
        return false
    end

    p.statuses:revive_player()
    return true
end

function m.begin_player_respawn(source)
    local p = core.players:get(source)
    if not p or not p.statuses then
        log("warn", ("Function: begin_player_respawn failed | Reason: no player/statuses instance for source %d"):format(source))
        return false
    end

    p.statuses:begin_respawn()
    return true
end

--- @section Exports

exports("get_player_statuses", m.get_player_statuses)
exports("get_player_status", m.get_player_status)
exports("get_player_injury", m.get_player_injury)
exports("get_player_effect", m.get_player_effect)
exports("is_player_dead", m.is_player_dead)
exports("is_player_downed", m.is_player_downed)
exports("set_player_status", m.set_player_status)
exports("set_player_statuses_bulk", m.set_player_statuses_bulk)
exports("set_player_injury", m.set_player_injury)
exports("modify_player_injury", m.modify_player_injury)
exports("apply_player_status_effect", m.apply_player_status_effect)
exports("remove_player_status_effect", m.remove_player_status_effect)
exports("clear_player_status_effects", m.clear_player_status_effects)
exports("respawn_player", m.respawn_player)
exports("down_player", m.down_player)
exports("kill_player", m.kill_player)
exports("pickup_player", m.pickup_player)
exports("revive_player", m.revive_player)
exports("begin_player_respawn", m.begin_player_respawn)

return m