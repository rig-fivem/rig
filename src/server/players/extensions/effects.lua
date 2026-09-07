--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @class Effects
--- @file src/server/players/extensions/effects.lua
--- @description Player status effect management handling temporary buffs, debuffs, and timed conditions.

--- @section Imports

local _db = require("src.server.modules.database")

--- @section Initialisation

local Effects = {}
Effects.__index = Effects

--- @section Factory

function Effects.new(player)
    return setmetatable({
        player = player
    }, Effects)
end

--- @section Lifecycle Hooks

function Effects:on_load()
    local uid = self.player.unique_id

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

    self.player:add_data("effects", effects, true)
end

function Effects:on_tick(dt)
    if not self.player:is_playing() then return end

    local effects = self:get_all()
    if not effects then return end

    local now = os.time()
    local changed = false

    for effect_name, effect in pairs(effects) do
        if effect.expires_at and now >= effect.expires_at then
            effects[effect_name] = nil
            changed = true
            self.player:emit("effect_expired", effect_name)
        end
    end

    if changed then
        self.player:set_data("effects", effects, true)
    end
end

function Effects:on_save()
    local effects = self:get_all()
    local uid = self.player.unique_id
    local queries = {}

    queries[#queries + 1] = {
        query = "DELETE FROM player_effects WHERE unique_id = ?",
        values = { uid }
    }

    if effects then
        for effect_name, effect in pairs(effects) do
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

function Effects:get_all()
    return self.player:get_data("effects") or {}
end

function Effects:get(effect_name)
    local effects = self:get_all()
    return effects and effects[effect_name]
end

function Effects:add(effect_name, opts)
    if type(effect_name) ~= "string" or effect_name == "" then 
        return false 
    end

    opts = opts or {}
    if type(opts) ~= "table" then 
        return false 
    end

    local current = self:get_all()
    local now = os.time()
    local duration = tonumber(opts.duration) or -1
    local existing = current[effect_name]

    if existing then
        local add_stacks = tonumber(opts.stacks) or 1
        local max_stacks = tonumber(opts.max_stacks) or 99
        
        existing.stacks = math.min((existing.stacks or 1) + add_stacks, max_stacks)
        existing.duration = duration
        existing.expires_at = duration > 0 and (now + duration) or nil
    else
        current[effect_name] = {
            effect_type = type(opts.effect_type) == "string" and opts.effect_type or "status",
            effect_name = effect_name,
            duration = duration,
            stacks = tonumber(opts.stacks) or 1,
            applied_at = now,
            expires_at = duration > 0 and (now + duration) or nil
        }
    end

    self.player:set_data("effects", current, true)
    self.player:emit("effect_added", effect_name, current[effect_name])
    return true
end

function Effects:remove(effect_name)
    local current = self:get_all()
    if not current[effect_name] then return false end

    current[effect_name] = nil
    self.player:set_data("effects", current, true)
    self.player:emit("effect_removed", effect_name)
    return true
end

function Effects:clear_effects()
    self.player:set_data("effects", {}, true)
    return true
end

return Effects