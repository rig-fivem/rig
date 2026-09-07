--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @class Statuses
--- @file src/server/players/extensions/statuses.lua
--- @description Player status management handling vitals and health state transitions.

--- @section Imports

local _statuses_data = require("src.shared.data.statuses")
local _db = require("src.server.modules.database")

--- @section Constants

local DEFAULT_STATUSES = _statuses_data.statuses

local STATUS_RANGES = {
    health = { min = 0.0, max = 200.0 },
    armour = { min = 0.0, max = 100.0 },
    hunger = { min = 0.0, max = 100.0 },
    thirst = { min = 0.0, max = 100.0 },
    hygiene = { min = 0.0, max = 100.0 },
    fatigue = { min = 0.0, max = 100.0 },
    stress = { min = 0.0, max = 100.0 },
    temperature = { min = 20.0, max = 45.0 },
    bleeding = { min = 0.0, max = 100.0 },
    radiation = { min = 0.0, max = 100.0 },
    infection = { min = 0.0, max = 100.0 },
    poison = { min = 0.0, max = 100.0 }
}

--- @section Initialisation

local Statuses = {}
Statuses.__index = Statuses

--- @section Factory

function Statuses.new(player)
    return setmetatable({
        player = player
    }, Statuses)
end

--- @section Internal Helpers

local function clamp_status(key, value)
    local range = STATUS_RANGES[key]
    if not range then return value end
    local val = tonumber(value) or DEFAULT_STATUSES[key]
    return math.max(range.min, math.min(range.max, val))
end

--- @section Lifecycle Hooks

function Statuses:on_load()
    local uid = self.player.unique_id

    local status_res = _db.query("SELECT * FROM player_statuses WHERE unique_id = ?", { uid })
    local vitals = status_res and status_res[1]

    if not vitals then
        _db.insert([[
            INSERT INTO player_statuses (unique_id) VALUES (?)
        ]], { uid })

        vitals = {}
        for k, default in pairs(DEFAULT_STATUSES) do vitals[k] = default end
    else
        for k in pairs(DEFAULT_STATUSES) do vitals[k] = clamp_status(k, vitals[k]) end
    end

    vitals.is_pending_revive = false
    vitals.is_bleeding_out = false
    vitals.is_respawning = false
    self.player:add_data("statuses", vitals, true)
end

function Statuses:on_tick(dt)
    if not self.player:is_playing() then return end

    local data = self:get_all()
    local health = tonumber(data and data.health) or 0.0

    if not data or health <= 20.0 then return end

    local current = {}
    for k, v in pairs(data) do current[k] = v end

    current.hunger = current.hunger - (0.05 * dt)
    current.thirst = current.thirst - (0.08 * dt)
    current.hygiene = current.hygiene - (0.01 * dt)
    current.fatigue = current.fatigue + (0.02 * dt)

    local total_limb_damage = 0.0
    if self.player.injuries then
        total_limb_damage = self.player.injuries:get_total_damage()
    end

    if total_limb_damage > 150.0 then
        current.bleeding = math.min(100.0, current.bleeding + (0.05 * dt))
    end

    local health_damage = 0.0

    if current.hunger <= 0 then health_damage = health_damage + (0.2 * dt) end
    if current.thirst <= 0 then health_damage = health_damage + (0.4 * dt) end

    if current.bleeding > 0 then health_damage = health_damage + ((current.bleeding / 100) * 0.5 * dt) end
    if current.poison > 0 then health_damage = health_damage + ((current.poison / 100) * 0.4 * dt) end
    if current.radiation > 0 then health_damage = health_damage + ((current.radiation / 100) * 0.3 * dt) end
    if current.infection > 50 then health_damage = health_damage + (0.1 * dt) end

    if current.temperature < 32.0 or current.temperature > 41.0 then
        health_damage = health_damage + (0.3 * dt)
    end

    if health_damage > 0 then
        current.health = current.health - health_damage
        if current.health <= 20.0 then
            self:set_bulk(current)
            self:down_player()
            return
        end
    end

    self:set_bulk(current)
end

function Statuses:on_save()
    local data = self:get_all()
    if not data then return {} end

    local uid = self.player.unique_id

    return {
        {
            query = [[
                UPDATE player_statuses SET
                    health = ?, armour = ?, hunger = ?, thirst = ?, hygiene = ?,
                    fatigue = ?, stress = ?, temperature = ?, bleeding = ?,
                    radiation = ?, infection = ?, poison = ?
                WHERE unique_id = ?
            ]],
            values = {
                clamp_status("health", data.health), clamp_status("armour", data.armour),
                clamp_status("hunger", data.hunger), clamp_status("thirst", data.thirst),
                clamp_status("hygiene", data.hygiene), clamp_status("fatigue", data.fatigue),
                clamp_status("stress", data.stress), clamp_status("temperature", data.temperature),
                clamp_status("bleeding", data.bleeding), clamp_status("radiation", data.radiation),
                clamp_status("infection", data.infection), clamp_status("poison", data.poison),
                uid
            }
        }
    }
end

--- @section Getters & Modifiers

function Statuses:get_all()
    return self.player:get_data("statuses") or {}
end

function Statuses:get(key)
    return self:get_all()[key]
end

function Statuses:set(key, value)
    return self:set_bulk({ [key] = value })
end

function Statuses:set_bulk(status_table)
    if type(status_table) ~= "table" then return false end
    local current = self:get_all()

    for k, v in pairs(status_table) do
        if STATUS_RANGES[k] then
            current[k] = clamp_status(k, v)
        elseif k == "is_pending_revive" or k == "is_bleeding_out" or k == "is_respawning" then
            current[k] = v
        end
    end

    return self.player:set_data("statuses", current, true)
end

--- @section State Checks

function Statuses:is_dead()
    local health = tonumber(self:get("health")) or 0.0
    return health <= 0
end

function Statuses:is_downed()
    local health = tonumber(self:get("health")) or 0.0
    return health > 0 and health <= 20
end

--- @section Helpers

function Statuses:reset_statuses()
    local current = {}
    
    for k in pairs(STATUS_RANGES) do
        local default_val = DEFAULT_STATUSES[k]
        local clamped = clamp_status(k, default_val)
        current[k] = clamped
    end

    current.is_pending_revive = false
    current.is_bleeding_out = false
    current.is_respawning = false

    local result = self.player:set_data("statuses", current, true)
    return result
end

--- @section Actions

function Statuses:down_player()
    local health = tonumber(self:get("health")) or 0.0
    if health <= 0 or self:get("is_bleeding_out") then return end

    local downed_health = 19.0

    local total_time = 20000
    local steps = 12
    local interval = math.floor(total_time / steps)
    local drain_per_step = (downed_health - 1.0) / steps
    local step = 0

    self:set_bulk({ health = downed_health, is_bleeding_out = true })
    self.player:emit("downed", { duration = total_time })

    local function bleed_out()
        step = step + 1
        local current_health = tonumber(self:get("health")) or 0.0

        if current_health > 20 or current_health <= 0 or not self:get("is_bleeding_out") then
            self:set("is_bleeding_out", false)
            return
        end

        local new_health = math.max(0.0, current_health - drain_per_step)
        self:set("health", new_health)

        if new_health <= 0 or step >= steps then
            self:set("is_bleeding_out", false)
            self:kill_player()
            return
        end

        SetTimeout(interval, bleed_out)
    end

    SetTimeout(interval, bleed_out)
end

function Statuses:kill_player()
    self:set_bulk({
        health = 0.0,
        armour = 0.0,
        is_pending_revive = false,
        is_bleeding_out = false
    })

    if self.player.effects then
        self.player.effects:clear_effects()
    end

    local ped = GetPlayerPed(self.player.source)
    if ped and ped ~= 0 then
        SetPedArmour(ped, 0)
    end

    self.player:emit("died")
end

function Statuses:pickup_player()
    local health = tonumber(self:get("health")) or 0.0
    if health > 30 then return false end

    self:set_bulk({
        health = 35.0,
        is_bleeding_out = false,
        is_pending_revive = false
    })

    self.player:emit("picked_up")
    return true
end

function Statuses:revive_player()
    self:set("is_bleeding_out", false)
    self:reset_statuses()

    if self.player.injuries then
        self.player.injuries:clear_injuries()
    end

    if self.player.effects then
        self.player.effects:clear_effects()
    end

    self.player:emit("revived")
end

function Statuses:respawn_player()
    self:reset_statuses()

    if self.player.injuries then
        self.player.injuries:clear_injuries()
    end

    if self.player.effects then
        self.player.effects:clear_effects()
    end

    self.player:emit("respawned")
end

function Statuses:begin_respawn()
    self:set("is_respawning", true)

    if core and core.players then
        core.players:assign_personal_bucket(self.player.source)
    end

    self.player:set_playing(false)
    self.player:emit("respawn_started")
end

return Statuses