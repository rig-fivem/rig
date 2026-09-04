--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @class Groups
--- @file src/server/players/extensions/groups.lua
--- @description Player groups extension managing raw membership rows.

local Groups = {}
Groups.__index = Groups

function Groups.new(player)
    local self = setmetatable({ player = player }, Groups)
    return self
end

--- @section Lifecycle Hooks

function Groups:on_load()
    if not core or not core.groups then return end

    local unique_id = self.player.unique_id
    local rows = core.groups:get_member_groups(unique_id)
    local memberships = {}

    if rows then
        for _, row in ipairs(rows) do
            memberships[row.group_name] = {
                group_name = row.group_name,
                role_name = row.role_name,
                is_primary = (row.is_primary == 1 or row.is_primary == true),
                metadata = type(row.metadata) == "string" and json.decode(row.metadata) or (row.metadata or {})
            }
        end
    end

    self.player:add_data("groups", memberships, true)
    log("debug", ("[Groups] Loaded memberships for source %d (UID: %s)"):format(self.player.source, unique_id))
end

--- @section Getters

function Groups:get_data()
    return self.player:get_data("groups") or {}
end

function Groups:get_all()
    return self:get_data()
end

function Groups:get_membership(group_name)
    return self:get_data()[group_name]
end

function Groups:has_group(group_name)
    return self:get_membership(group_name) ~= nil
end

--- @section Actions

function Groups:add_group(group_name, role_name, opts)
    opts = opts or {}
    if not core or not core.groups then return false, "groups_registry_missing" end

    local unique_id = self.player.unique_id
    local success, err = core.groups:add_member(unique_id, group_name, role_name, opts)
    if not success then return false, err end

    local membership = {
        group_name = group_name,
        role_name = role_name,
        is_primary = opts.primary and true or false,
        metadata = opts.metadata or {}
    }

    self.player:set_data("groups", { [group_name] = membership }, true)
    self.player:emit("added_to_group", group_name, role_name, opts)

    return true
end

function Groups:remove_group(group_name)
    if not core or not core.groups then return false end

    local unique_id = self.player.unique_id
    local success, err = core.groups:remove_member(unique_id, group_name)
    if not success then return false, err end

    local memberships = self:get_data()
    memberships[group_name] = nil

    self.player:emit("data_changed", "groups", { removed = group_name })
    self.player:emit("removed_from_group", group_name)

    return true
end

return Groups