--[[
----------------------------------------
RIG Framework (built for CFX Platforms)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-framework/rig-cfx
License: https://github.com/rig-framework/rig-cfx/blob/main/LICENSE
----------------------------------------
]]

--- @class Group
--- @file extensions/server/groups/class.lua
--- @description Groups extension built for RIG.

--- @section Initialisation

local Group = {}
Group.__index = Group

--- @section Factory

function Group.new(data)
    local self = setmetatable({
        name = data.name,
        label = data.label,
        type = data.type or "group",
        parent_name = data.parent_name,
        metadata = type(data.metadata) == "string" and json.decode(data.metadata) or (data.metadata or {}),
        roles = {}
    }, Group)

    return self
end

--- @section Roles Methods

function Group:add_role(role_data)
    self.roles[role_data.name] = {
        name = role_data.name,
        label = role_data.label,
        grade = role_data.grade or 0,
        permissions = type(role_data.permissions) == "string" and json.decode(role_data.permissions) or (role_data.permissions or {})
    }
end

function Group:remove_role(role_name)
    self.roles[role_name] = nil
end

function Group:get_role(role_name)
    return self.roles[role_name]
end

--- @section Permission Methods

function Group:has_permission(role_name, permission)
    local role = self.roles[role_name]
    if not role or not role.permissions then return false end

    for _, perm in ipairs(role.permissions) do
        if perm == "*" or perm == permission then
            return true
        end
    end

    return false
end

--- @section Rank Methods

function Group:role_outranks(role_name_a, role_name_b)
    local a = self.roles[role_name_a]
    local b = self.roles[role_name_b]
    if not a or not b then return false end
    return a.grade > b.grade
end

return Group