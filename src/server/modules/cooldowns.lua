--- @module cooldowns
--- @file src/server/modules/cooldowns.lua
--- @description Cooldown tracking and enforcement for player, global, and resource-based actions.

--- @section Initialisation

local m = {}

local player_cooldowns = {}
local global_cooldowns = {}
local resource_cooldowns = {}

--- @section Functions

function m.add_cooldown(source, cooldown_type, duration, is_global)
    local expires = os.time() + duration
    local resource = GetInvokingResource() or "unknown"
    local info = { end_time = expires, resource = resource }

    if is_global then
        global_cooldowns[cooldown_type] = info
    else
        player_cooldowns[source] = player_cooldowns[source] or {}
        player_cooldowns[source][cooldown_type] = info
    end

    resource_cooldowns[resource] = resource_cooldowns[resource] or {}
    table.insert(resource_cooldowns[resource], { source = source, cooldown_type = cooldown_type, is_global = is_global })
end

function m.check_cooldown(source, cooldown_type, is_global)
    local now = os.time()
    if is_global then
        return global_cooldowns[cooldown_type] and now < global_cooldowns[cooldown_type].end_time
    end
    return player_cooldowns[source] and player_cooldowns[source][cooldown_type] and now < player_cooldowns[source][cooldown_type].end_time
end

function m.clear_cooldown(source, cooldown_type, is_global)
    if is_global then
        global_cooldowns[cooldown_type] = nil
        GlobalState["cooldown_" .. cooldown_type] = nil
    elseif player_cooldowns[source] then
        player_cooldowns[source][cooldown_type] = nil
    end
end

function m.clear_all_cooldowns()
    local now = os.time()

    for id, cd in pairs(player_cooldowns) do
        for action, info in pairs(cd) do
            if now >= info.end_time then
                cd[action] = nil
            end
        end
        if not next(cd) then player_cooldowns[id] = nil end
    end

    for action, info in pairs(global_cooldowns) do
        if now >= info.end_time then
            global_cooldowns[action] = nil
            GlobalState["cooldown_" .. action] = nil
        end
    end
end

function m.clear_resource_cooldowns(resource)
    local list = resource_cooldowns[resource]
    if not list then return end

    for _, entry in ipairs(list) do
        if entry.is_global then
            global_cooldowns[entry.cooldown_type] = nil
        elseif player_cooldowns[entry.source] then
            player_cooldowns[entry.source][entry.cooldown_type] = nil
        end
    end

    resource_cooldowns[resource] = nil
end

--- @section Events & Handlers

AddEventHandler("onResourceStop", function(resource)
    m.clear_resource_cooldowns(resource)
end)

AddEventHandler("playerDropped", function()
    local _src = source
    player_cooldowns[_src] = nil
end)

--- @section Exports

exports("add_cooldown", m.add_cooldown)
exports("check_cooldown", m.check_cooldown)
exports("clear_cooldown", m.clear_cooldown)
exports("clear_all_cooldowns", m.clear_all_cooldowns)
exports("clear_resource_cooldowns", m.clear_resource_cooldowns)

return m