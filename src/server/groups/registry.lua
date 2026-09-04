--- @class GroupRegistry
--- @file src/server/groups/registry.lua
--- @description Loads and manages player group memberships for RIG core. No knowledge of group/role definitions or permissions - that's owned by rig_groups.

--- @section Imports

local _db = require("src.server.modules.database")

--- @section Initialisation

local GroupRegistry = {}
GroupRegistry.__index = GroupRegistry

--- @section Factory

function GroupRegistry.new()
    log("debug", "Initialised GroupRegistry instance")
    return setmetatable({}, GroupRegistry)
end

--- @section Getter Methods

function GroupRegistry:get_member_groups(unique_id)
    local query = "SELECT * FROM player_groups WHERE unique_id = ?"
    return _db.query(query, { unique_id })
end

function GroupRegistry:get_member(unique_id, group_name)
    local query = "SELECT * FROM player_groups WHERE unique_id = ? AND group_name = ? LIMIT 1"
    local result = _db.query(query, { unique_id, group_name })
    return result and result[1]
end

--- @section Member Methods

function GroupRegistry:add_member(unique_id, group_name, role_name, opts)
    opts = opts or {}

    local query = [[
        INSERT INTO player_groups (unique_id, group_name, role_name, is_primary, metadata)
        VALUES (?, ?, ?, ?, ?)
        ON DUPLICATE KEY UPDATE
            role_name = VALUES(role_name),
            is_primary = VALUES(is_primary),
            metadata = VALUES(metadata)
    ]]

    local affected = _db.insert(query, {
        unique_id, group_name, role_name,
        opts.primary and 1 or 0,
        json.encode(opts.metadata or {})
    })

    return affected > 0
end

function GroupRegistry:remove_member(unique_id, group_name)
    local affected = _db.update("DELETE FROM player_groups WHERE unique_id = ? AND group_name = ?", { unique_id, group_name })
    return affected > 0
end

function GroupRegistry:set_member_role(unique_id, group_name, role_name)
    local affected = _db.update("UPDATE player_groups SET role_name = ? WHERE unique_id = ? AND group_name = ?", { role_name, unique_id, group_name })
    return affected > 0
end

return GroupRegistry