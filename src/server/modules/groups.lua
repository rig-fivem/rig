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
--- @description Server side handling for global group definitions and player memberships (Developer API Layer).

--- @section Guard

if rawget(_G, "__server_groups_module") then
    return _G.__server_groups_module
end

--- @section Initialisation

local m = {}
_G.__server_groups_module = m

--- @section Helpers

local function get_global_groups()
    if not core or not core.groups then
        log("error", "Groups registry is missing or core is not initialized.")
        return nil
    end
    return core.groups
end

local function get_player_groups_interface(source, action_name)
    if not source then 
        log("error", ("Source missing for action: %s"):format(action_name)) 
        return nil 
    end

    local player = core.players:get(source)
    if not player or not player.groups then 
        log("error", ("Player or player groups missing for source %s during %s"):format(tostring(source), action_name))
        return nil 
    end

    return player.groups
end

--- @section Group Functions

function m.create_group(group_data)
    if not group_data or not group_data.name or not group_data.label then
        log("error", "Group data, name, or label missing.")
        return false
    end

    local groups_reg = get_global_groups()
    if not groups_reg then return false end

    return groups_reg:create_group(group_data)
end

function m.delete_group(group_name)
    if not group_name then
        log("error", "Group name missing.")
        return false
    end

    local groups_reg = get_global_groups()
    if not groups_reg then return false end

    return groups_reg:delete_group(group_name)
end

function m.add_group_role(group_name, role_data)
    if not group_name or not role_data or not role_data.name then
        log("error", "Group name or role data missing.")
        return false 
    end

    local groups_reg = get_global_groups()
    if not groups_reg then return false end

    return groups_reg:add_group_role(group_name, role_data)
end

function m.remove_group_role(group_name, role_name)
    if not group_name or not role_name then
        log("error", "Group name or role name missing.")
        return false 
    end

    local groups_reg = get_global_groups()
    if not groups_reg then return false end

    return groups_reg:remove_group_role(group_name, role_name)
end

--- @section Player Functions

function m.get_player_groups(source)
    local p_groups = get_player_groups_interface(source, "get_player_groups")
    if not p_groups then return {} end

    return p_groups:get_all()
end

function m.has_player_group(source, group_name)
    if not group_name then return false end
    
    local p_groups = get_player_groups_interface(source, "has_player_group")
    if not p_groups then return false end

    return p_groups:has_group(group_name)
end

function m.has_player_permission(source, permission)
    if not permission then return false end

    local p_groups = get_player_groups_interface(source, "has_player_permission")
    if not p_groups then return false end

    return p_groups:has_permission(permission)
end

function m.add_player_to_group(source, group_name, role_name, opts)
    if not group_name or not role_name then 
        log("error", "Group name or role name missing.") 
        return false 
    end

    local p_groups = get_player_groups_interface(source, "add_player_to_group")
    if not p_groups then return false end

    return p_groups:add_group(group_name, role_name, opts)
end

function m.remove_player_from_group(source, group_name)
    if not group_name then 
        log("error", "Group name missing.") 
        return false 
    end

    local p_groups = get_player_groups_interface(source, "remove_player_from_group")
    if not p_groups then return false end

    return p_groups:remove_group(group_name)
end

--- @section Events

RegisterServerEvent("rig:server:request_groups")
AddEventHandler("rig:server:request_groups", function()
    local _src = source
    if not _src then return end

    local groups = m.get_player_groups(_src)
    TriggerEvent("rig:server:request_groups_response", _src, groups)
end)

--- @section Exports

exports("create_group", m.create_group)
exports("delete_group", m.delete_group)
exports("add_group_role", m.add_group_role)
exports("remove_group_role", m.remove_group_role)

exports("get_player_groups", m.get_player_groups)
exports("has_player_group", m.has_player_group)
exports("has_player_permission", m.has_player_permission)
exports("add_player_to_group", m.add_player_to_group)
exports("remove_player_from_group", m.remove_player_from_group)

return m