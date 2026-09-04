--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @class Inventory
--- @file src/server/players/extensions/inventory.lua
--- @description Player inventory extension managing item storage.

--- @section Imports

local _db = require("src.server.modules.database")

--- @section Initialisation

local Inventory = {}
Inventory.__index = Inventory

--- @section Factory

function Inventory.new(player)
    local self = setmetatable({
        player = player
    }, Inventory)
    return self
end

--- @section Lifecycle Hooks

function Inventory:on_load()
    local unique_id = self.player.unique_id
    local identifier = "player_" .. unique_id

    local row = _db.single("SELECT * FROM inventories WHERE identifier = ?", { identifier })

    if not row then
        log("info", ("[Inventory] No inventory record found for identifier: %s. Creating default..."):format(identifier))

        _db.insert([[
            INSERT INTO inventories (identifier, owner, inventory_type, items, metadata)
            VALUES (?, ?, 'player', JSON_OBJECT(), JSON_OBJECT())
        ]], { identifier, unique_id })

        row = {
            identifier = identifier,
            owner = unique_id,
            inventory_type = "player",
            inventory_subtype = nil,
            items = {},
            metadata = {}
        }
    else
        row.items = type(row.items) == "string" and json.decode(row.items) or (row.items or {})
        row.metadata = type(row.metadata) == "string" and json.decode(row.metadata) or (row.metadata or {})
    end

    self.player:add_data("inventory", {
        identifier = row.identifier,
        owner = row.owner,
        inventory_type = row.inventory_type,
        inventory_subtype = row.inventory_subtype,
        items = row.items,
        metadata = row.metadata
    }, true)

    log("debug", ("[Inventory] Loaded inventory data for source %d (UID: %s)"):format(self.player.source, unique_id))
end

function Inventory:on_save()
    local data = self.player:get_data("inventory")
    if not data then return {} end

    return {
        {
            query = [[
                UPDATE inventories
                SET items = ?, metadata = ?
                WHERE identifier = ?
            ]],
            values = {
                json.encode(data.items or {}),
                json.encode(data.metadata or {}),
                data.identifier
            }
        }
    }
end

--- @section Getters

function Inventory:get_inventory()
    return self.player:get_data("inventory")
end

--- @section Mutations

function Inventory:set_slots(changes)
    if type(changes) ~= "table" then return false end

    local inv = self:get_inventory()
    if not inv then return false end

    inv.items = inv.items or {}

    for _, change in ipairs(changes) do
        local group_id, key, item = change.group_id, change.key, change.item
        if not group_id or not key then return false end

        inv.items[group_id] = inv.items[group_id] or {}
        inv.items[group_id][key] = item
    end

    return self.player:set_data("inventory", inv, true)
end

function Inventory:set_metadata(metadata, merge)
    if type(metadata) ~= "table" then return false end

    local inv = self:get_inventory()
    if not inv then return false end

    if merge then
        inv.metadata = inv.metadata or {}
        for k, v in pairs(metadata) do inv.metadata[k] = v end
    else
        inv.metadata = metadata
    end

    return self.player:set_data("inventory", inv, true)
end

function Inventory:set_item_metadata(group_id, key, metadata, merge)
    if type(metadata) ~= "table" then return false end

    local inv = self:get_inventory()
    if not inv or not inv.items or not inv.items[group_id] then return false end

    local item = inv.items[group_id][key]
    if not item then return false end

    if merge then
        item.metadata = item.metadata or {}
        for k, v in pairs(metadata) do item.metadata[k] = v end
    else
        item.metadata = metadata
    end

    return self.player:set_data("inventory", inv, true)
end

function Inventory:add_group(group_id, initial_items)
    if not group_id then return false end

    local inv = self:get_inventory()
    if not inv then return false end

    inv.items = inv.items or {}
    inv.items[group_id] = initial_items or {}

    return self.player:set_data("inventory", inv, true)
end

function Inventory:remove_group(group_id)
    if not group_id then return nil end

    local inv = self:get_inventory()
    if not inv or not inv.items then return nil end

    local group_items = inv.items[group_id]
    inv.items[group_id] = nil
    self.player:set_data("inventory", inv, true)

    return group_items or {}
end

function Inventory:clear_groups(group_ids)
    if type(group_ids) ~= "table" then return false end

    local inv = self:get_inventory()
    if not inv or not inv.items then return false end

    for _, group_id in ipairs(group_ids) do
        inv.items[group_id] = {}
    end

    return self.player:set_data("inventory", inv, true)
end

return Inventory