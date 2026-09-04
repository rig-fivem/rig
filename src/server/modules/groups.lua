--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @module groups
--- @file src/server/modules/groups.lua
--- @description Server side API wrapper for raw player group membership.

if rawget(_G, "__server_groups_module") then
    return _G.__server_groups_module
end

local m = {}
_G.__server_groups_module = m

--- @section Player Functions

function m.get_player_groups(source)
    local p = core.players:get(source)
    if not p then return {} end

    return p.groups:get_all()
end

function m.has_player_group(source, group_name)
    local p = core.players:get(source)
    if not p then return false end

    return p.groups:has_group(group_name)
end

function m.add_player_to_group(source, group_name, role_name, opts)
    local p = core.players:get(source)
    if not p then return false end

    return p.groups:add_group(group_name, role_name, opts)
end

function m.remove_player_from_group(source, group_name)
    local p = core.players:get(source)
    if not p then return false end

    return p.groups:remove_group(group_name)
end

--- @section Events

RegisterServerEvent("rig:server:request_groups")
AddEventHandler("rig:server:request_groups", function()
    local _src = source
    if not _src then return end

    TriggerEvent("rig:server:request_groups_response", _src, m.get_player_groups(_src))
end)

--- @section Exports

exports("get_player_groups", m.get_player_groups)
exports("has_player_group", m.has_player_group)
exports("add_player_to_group", m.add_player_to_group)
exports("remove_player_from_group", m.remove_player_from_group)

return m