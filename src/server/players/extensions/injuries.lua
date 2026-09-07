--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @class Injuries
--- @file src/server/players/extensions/injuries.lua
--- @description Player injury management handling targeted body part damage.

--- @section Imports

local _statuses_data = require("src.shared.data.statuses")
local _db = require("src.server.modules.database")

--- @section Constants

local DEFAULT_INJURIES = _statuses_data.injuries

--- @section Initialisation

local Injuries = {}
Injuries.__index = Injuries

--- @section Factory

function Injuries.new(player)
    return setmetatable({
        player = player
    }, Injuries)
end

--- @section Internal Helpers

local function clamp_injury(value)
    local val = tonumber(value) or 0.0
    return math.max(0.0, math.min(100.0, val))
end

--- @section Lifecycle Hooks

function Injuries:on_load()
    local uid = self.player.unique_id

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

    self.player:add_data("injuries", injuries, true)
end

function Injuries:on_save()
    local data = self:get_all()
    if not data then return {} end

    local uid = self.player.unique_id

    return {
        {
            query = [[
                UPDATE player_injuries SET
                    head = ?, upper_torso = ?, lower_torso = ?, forearm_right = ?, forearm_left = ?,
                    hand_right = ?, hand_left = ?, thigh_right = ?, thigh_left = ?, calf_right = ?,
                    calf_left = ?, foot_right = ?, foot_left = ?
                WHERE unique_id = ?
            ]],
            values = {
                clamp_injury(data.head), clamp_injury(data.upper_torso), clamp_injury(data.lower_torso),
                clamp_injury(data.forearm_right), clamp_injury(data.forearm_left), clamp_injury(data.hand_right),
                clamp_injury(data.hand_left), clamp_injury(data.thigh_right), clamp_injury(data.thigh_left),
                clamp_injury(data.calf_right), clamp_injury(data.calf_left), clamp_injury(data.foot_right),
                clamp_injury(data.foot_left), uid
            }
        }
    }
end

--- @section Getters & Modifiers

function Injuries:get_all()
    return self.player:get_data("injuries") or {}
end

function Injuries:get(part)
    local data = self:get_all()
    return data and data[part] or 0.0
end

function Injuries:set(part, damage)
    local current = self:get_all()
    current[part] = clamp_injury(damage)
    return self.player:set_data("injuries", current, true)
end

function Injuries:modify(part, delta)
    local current_val = self:get(part)
    return self:set(part, current_val + delta)
end

function Injuries:get_total_damage()
    local current = self:get_all()
    local total = 0.0
    for part in pairs(DEFAULT_INJURIES) do
        total = total + (current[part] or 0.0)
    end
    return total
end

function Injuries:clear_injuries()
    local current = self:get_all()
    for part in pairs(DEFAULT_INJURIES) do
        current[part] = 0.0
    end
    return self.player:set_data("injuries", current, true)
end

return Injuries