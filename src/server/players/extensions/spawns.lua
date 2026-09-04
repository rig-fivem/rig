--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @class Spawns
--- @file src/server/players/extensions/spawns.lua
--- @description Player spawn extension for managing spawn locations.

--- @section Imports

local _db = require("src.server.modules.database")

--- @section Initialisation

local Spawns = {}
Spawns.__index = Spawns

--- @section Factory

function Spawns.new(player)
    return setmetatable({
        player = player
    }, Spawns)
end

--- @section Internal Helpers

local function validate_spawn(spawn_data)
    if not spawn_data or type(spawn_data) ~= "table" then return nil end

    return {
        spawn_type = spawn_data.spawn_type,
        label = spawn_data.label or nil,
        x = tonumber(spawn_data.x) or 0,
        y = tonumber(spawn_data.y) or 0,
        z = tonumber(spawn_data.z) or 0,
        w = tonumber(spawn_data.w) or 0,
        updated_at = os.date("%Y-%m-%d %H:%M:%S")
    }
end

--- @section Lifecycle Hooks

function Spawns:on_load()
    local uid = self.player.unique_id

    local result = _db.query("SELECT * FROM player_spawns WHERE unique_id = ?", { uid })
    local spawns = {}

    if result and #result > 0 then
        for _, spawn in ipairs(result) do
            spawns[spawn.spawn_id] = {
                spawn_type = spawn.spawn_type,
                label = spawn.label,
                x = spawn.x,
                y = spawn.y,
                z = spawn.z,
                w = spawn.w,
                updated_at = spawn.updated_at
            }
        end
    end

    self.player:add_data("spawns", spawns, true)
end

function Spawns:on_save()
    if not self.player:is_playing() then return nil end

    self:save_last_location()

    local spawns = self.player:get_data("spawns")
    if not spawns then return {} end

    local queries = {}
    for spawn_id, spawn_data in pairs(spawns) do
        if spawn_data then
            queries[#queries + 1] = {
                query = [[
                    INSERT INTO player_spawns (unique_id, spawn_id, spawn_type, label, x, y, z, w)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                    ON DUPLICATE KEY UPDATE
                        spawn_type = VALUES(spawn_type),
                        label = VALUES(label),
                        x = VALUES(x),
                        y = VALUES(y),
                        z = VALUES(z),
                        w = VALUES(w)
                ]],
                values = {
                    self.player.unique_id,
                    spawn_id,
                    spawn_data.spawn_type,
                    spawn_data.label or nil,
                    spawn_data.x,
                    spawn_data.y,
                    spawn_data.z,
                    spawn_data.w
                }
            }
        end
    end

    return queries
end

--- @section Getters

function Spawns:get_spawns()
    return self.player:get_data("spawns")
end

function Spawns:get_spawn(spawn_id)
    local spawns = self.player:get_data("spawns")
    return spawns and spawns[spawn_id]
end

--- @section Setters

function Spawns:set_spawns(updates)
    if not updates or type(updates) ~= "table" then return false end

    local validated = {}
    for spawn_id, spawn_data in pairs(updates) do
        local v = validate_spawn(spawn_data)
        if not v then return false end
        validated[spawn_id] = v
    end

    return self.player:set_data("spawns", validated, true)
end

function Spawns:set_spawn(spawn_id, spawn_data)
    local v = validate_spawn(spawn_data)
    if not v then return false end

    return self.player:set_data("spawns", { [spawn_id] = v }, true)
end

--- @section Actions

function Spawns:spawn_player(coords)
    local player = self.player
    if player:is_playing() then return false end

    local ped = GetPlayerPed(player.source)
    if player.statuses and player.statuses:is_dead() then
        player.statuses:respawn()
    end

    FreezeEntityPosition(ped, true)
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    SetEntityHeading(ped, coords.w or 0.0)

    core.players:set_bucket(player.source, 0)
    player:set_playing(true)
    player:set_awaiting_spawn(true)

    TriggerClientEvent("rig:client:find_ground_and_spawn", player.source)
    return true
end

--- @section Clean Up

function Spawns:clear_spawns()
    local spawns = self.player:get_data("spawns") or {}
    local last_location = spawns.last_location
    return self.player:set_data("spawns", { last_location = last_location }, true)
end

function Spawns:clear_spawn(spawn_id)
    if spawn_id == "last_location" then return false end
    return self.player:set_data("spawns", { [spawn_id] = nil }, true)
end

--- @section Save Helpers

function Spawns:save_last_location()
    local player = self.player
    if not player or not player.source then return false end

    local ped = GetPlayerPed(player.source)
    if not DoesEntityExist(ped) then return false end

    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)

    return self:set_spawn("last_location", {
        spawn_type = "last_location",
        label = "Last Location",
        x = coords.x,
        y = coords.y,
        z = coords.z,
        w = heading
    })
end

return Spawns