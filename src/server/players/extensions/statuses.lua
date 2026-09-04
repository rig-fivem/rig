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
--- @description Player status management handling vitals, targeted body injuries, and active effects.

--- @section Imports

local _statuses_data = require("src.shared.data.statuses")
local _db = require("src.server.modules.database")

--- @section Constants

local DEFAULT_STATUSES = _statuses_data.statuses
local DEFAULT_INJURIES = _statuses_data.injuries

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

local function clamp_injury(value)
    local val = tonumber(value) or 0.0
    return math.max(0.0, math.min(100.0, val))
end

--- @section Lifecycle Hooks

function Statuses:on_load()
    local uid = self.player.unique_id

    --- Statuses
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

    --- Injuries
    local injury_res = _db.query("SELECT * FROM player_injuries WHERE unique_id = ?", { uid })
    local injuries = injury_res and injury_res[1]

    if not injuries then
        _db.insert([[
            INSERT INTO player_injuries (unique_id) VALUES (?)
        ]], { uid })

        injuries = {}
        for part in pairs(DEFAULT_INJURIES) do injuries[part] = 0.0 end
    else
        for part in pairs(DEFAULT_INJURIES) do injuries[part] = clamp_injury(injuries[part]) end
    end

    --- Effects
    local effects_res = _db.query("SELECT * FROM player_effects WHERE unique_id = ?", { uid })
    local effects = {}

    if effects_res and #effects_res > 0 then
        for _, eff in ipairs(effects_res) do
            effects[eff.effect_name] = {
                effect_type = eff.effect_type,
                effect_name = eff.effect_name,
                duration    = eff.duration,
                stacks      = eff.stacks or 1,
                applied_at  = eff.applied_at,
                expires_at  = eff.expires_at
            }
        end
    end

    vitals.injuries = injuries
    vitals.effects = effects
    self.player:add_data("statuses", vitals, true)
end

function Statuses:on_tick(dt)
    if not self.player:is_playing() then return end

    local data = self:get_all()
    if not data or data.health <= 0 then return end

    local current = {}
    for k, v in pairs(data) do current[k] = v end

    current.hunger  = current.hunger - (0.05 * dt)
    current.thirst  = current.thirst - (0.08 * dt)
    current.hygiene = current.hygiene - (0.01 * dt)
    current.fatigue = current.fatigue + (0.02 * dt)

    local now = os.time()
    if current.effects then
        for effect_name, effect in pairs(current.effects) do
            if effect.expires_at and now >= effect.expires_at then
                current.effects[effect_name] = nil
                self.player:emit("effect_expired", effect_name)
            end
        end
    end

    local total_limb_damage = 0.0
    if current.injuries then
        for part in pairs(DEFAULT_INJURIES) do
            total_limb_damage = total_limb_damage + (current.injuries[part] or 0.0)
        end
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
        if current.health <= 0 and data.health > 0 then
            current.health = 0
            self.player:emit("died")
        end
    end

    self:set_bulk(current)

    if current.health > 0 and current.health <= 20 and data.health > 20 then
        self:down_player()
    end
end

function Statuses:on_save()
    local data = self:get_all()
    if not data then return {} end

    local uid = self.player.unique_id
    local queries = {}

    --- Statuses
    queries[#queries + 1] = {
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

    --- Injuries
    local inj = data.injuries or {}
    queries[#queries + 1] = {
        query = [[
            UPDATE player_injuries SET
                head = ?, upper_torso = ?, lower_torso = ?, forearm_right = ?, forearm_left = ?,
                hand_right = ?, hand_left = ?, thigh_right = ?, thigh_left = ?, calf_right = ?,
                calf_left = ?, foot_right = ?, foot_left = ?
            WHERE unique_id = ?
        ]],
        values = {
            clamp_injury(inj.head), clamp_injury(inj.upper_torso), clamp_injury(inj.lower_torso),
            clamp_injury(inj.forearm_right), clamp_injury(inj.forearm_left), clamp_injury(inj.hand_right),
            clamp_injury(inj.hand_left), clamp_injury(inj.thigh_right), clamp_injury(inj.thigh_left),
            clamp_injury(inj.calf_right), clamp_injury(inj.calf_left), clamp_injury(inj.foot_right),
            clamp_injury(inj.foot_left), uid
        }
    }

    --- Effects
    queries[#queries + 1] = {
        query = "DELETE FROM player_effects WHERE unique_id = ?",
        values = { uid }
    }

    if data.effects then
        for effect_name, effect in pairs(data.effects) do
            queries[#queries + 1] = {
                query = [[
                    INSERT INTO player_effects (unique_id, effect_id, effect_type, effect_name, duration, stacks, applied_at, expires_at)
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)
                ]],
                values = {
                    uid, effect_name, effect.effect_type, effect.effect_name,
                    effect.duration, effect.stacks, effect.applied_at, effect.expires_at
                }
            }
        end
    end

    return queries
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

function Statuses:get_injury(part)
    local data = self:get_all()
    return data.injuries and data.injuries[part] or 0.0
end

function Statuses:set_injury(part, damage)
    local current = self:get_all()
    current.injuries = current.injuries or {}
    current.injuries[part] = clamp_injury(damage)
    return self.player:set_data("statuses", current, true)
end

function Statuses:modify_injury(part, delta)
    local current_val = self:get_injury(part)
    return self:set_injury(part, current_val + delta)
end

function Statuses:set_bulk(status_table)
    if type(status_table) ~= "table" then return false end
    local current = self:get_all()

    for k, v in pairs(status_table) do
        if STATUS_RANGES[k] then
            current[k] = clamp_status(k, v)
        elseif k == "injuries" or k == "effects" then
            current[k] = v
        end
    end

    return self.player:set_data("statuses", current, true)
end

--- @section State Checks

function Statuses:is_dead()
    return self:get("health") <= 0
end

function Statuses:is_downed()
    local health = self:get("health")
    return health > 0 and health <= 20
end

--- @section Effects

function Statuses:add_effect(effect_name, opts)
    if type(effect_name) ~= "string" or effect_name == "" then 
        return false 
    end

    opts = opts or {}
    if type(opts) ~= "table" then 
        return false 
    end

    local current = self:get_all()
    current.effects = current.effects or {}

    local now = os.time()
    local duration = tonumber(opts.duration) or -1
    local existing = current.effects[effect_name]

    if existing then
        local add_stacks = tonumber(opts.stacks) or 1
        local max_stacks = tonumber(opts.max_stacks) or 99
        
        existing.stacks = math.min((existing.stacks or 1) + add_stacks, max_stacks)
        existing.duration = duration
        existing.expires_at = duration > 0 and (now + duration) or nil
    else
        current.effects[effect_name] = {
            effect_type = type(opts.effect_type) == "string" and opts.effect_type or "status",
            effect_name = effect_name,
            duration = duration,
            stacks = tonumber(opts.stacks) or 1,
            applied_at = now,
            expires_at = duration > 0 and (now + duration) or nil
        }
    end

    self.player:set_data("statuses", current, true)
    self.player:emit("effect_added", effect_name, current.effects[effect_name])
    return true
end

function Statuses:remove_effect(effect_name)
    local current = self:get_all()
    if not current.effects or not current.effects[effect_name] then return false end

    current.effects[effect_name] = nil
    self.player:set_data("statuses", current, true)
    self.player:emit("effect_removed", effect_name)
    return true
end

function Statuses:clear_effects()
    local current = self:get_all()
    current.effects = {}
    return self.player:set_data("statuses", current, true)
end

function Statuses:get_effect(effect_name)
    local data = self:get_all()
    return data.effects and data.effects[effect_name]
end

--- @section Actions

function Statuses:respawn()
    local current = self:get_all()

    for k, default in pairs(DEFAULT_STATUSES) do current[k] = default end

    current.injuries = current.injuries or {}
    for part in pairs(DEFAULT_INJURIES) do current.injuries[part] = 0.0 end

    current.effects = {}

    self.player:set_data("statuses", current, true)
    self.player:emit("respawned")
end

function Statuses:down_player()
    local health = self:get("health")
    if not health or health <= 0 then return end

    local total_time = 20000
    local steps = 12
    local interval = total_time / steps
    local drain_per_step = (health - 1) / steps
    local step = 0

    self.player:emit("downed")
    TriggerClientEvent("rig:client:player_downed", self.player.source, { duration = total_time })

    local function bleed_out()
        step = step + 1
        local current = self:get("health")
        if not current or current > 20 then return end

        local new_health = math.max(0, current - drain_per_step)
        self:set("health", new_health)

        if new_health <= 0 or step >= steps then
            self:kill_player()
            return
        end

        SetTimeout(interval, bleed_out)
    end

    SetTimeout(interval, bleed_out)
end

function Statuses:kill_player()
    self:set("health", 0)

    local ped = GetPlayerPed(self.player.source)
    SetPedArmour(ped, 0)

    self.player:emit("died")
    TriggerClientEvent("rig:client:player_died", self.player.source)
end

function Statuses:pickup_player()
    local health = self:get("health")
    if not health or health > 30 then return false end

    self:set("health", 35)
    self.player:set_data("statuses", { pending_revive = true }, true)

    TriggerClientEvent("rig:client:player_picked_up", self.player.source)
    self.player:emit("picked_up")
    return true
end

function Statuses:revive_player()
    self:respawn()
    self.player:set_data("statuses", { pending_revive = false }, true)

    TriggerClientEvent("rig:client:revive_player", self.player.source)
    self.player:emit("revived")
end

function Statuses:begin_respawn()
    core.players:assign_personal_bucket(self.player.source)
    self.player:set_playing(false)

    TriggerClientEvent("rig:client:respawn_player", self.player.source)
    self.player:emit("respawn_started")
end

return Statuses