--- @module inventory
--- @file src/server/modules/inventory.lua
--- @description Server side API wrapper for the player inventory system.

--- @section Guard

if rawget(_G, "__server_inventory_module") then
    return _G.__server_inventory_module
end

--- @section Initialisation

local m = {}
_G.__server_inventory_module = m

--- @section Functions

function m.get_inventory(source)
    local p = core.players:get(source)
    if not p then return nil end

    return p.inventory:get_inventory()
end

function m.set_inventory_slots(source, changes)
    local p = core.players:get(source)
    if not p then return false end

    return p.inventory:set_slots(changes)
end

function m.set_inventory_metadata(source, metadata, merge)
    local p = core.players:get(source)
    if not p then return false end

    return p.inventory:set_metadata(metadata, merge)
end

function m.set_item_metadata(source, group_id, key, metadata, merge)
    local p = core.players:get(source)
    if not p then return false end

    return p.inventory:set_item_metadata(group_id, key, metadata, merge)
end

function m.add_inventory_group(source, group_id, initial_items)
    local p = core.players:get(source)
    if not p then return false end

    return p.inventory:add_group(group_id, initial_items)
end

function m.remove_inventory_group(source, group_id)
    local p = core.players:get(source)
    if not p then return nil end

    return p.inventory:remove_group(group_id)
end

function m.clear_inventory_groups(source, group_ids)
    local p = core.players:get(source)
    if not p then return false end

    return p.inventory:clear_groups(group_ids)
end

--- @section Exports

exports("get_inventory", m.get_inventory)
exports("set_inventory_slots", m.set_inventory_slots)
exports("set_inventory_metadata", m.set_inventory_metadata)
exports("set_item_metadata", m.set_item_metadata)
exports("add_inventory_group", m.add_inventory_group)
exports("remove_inventory_group", m.remove_inventory_group)
exports("clear_inventory_groups", m.clear_inventory_groups)

return m