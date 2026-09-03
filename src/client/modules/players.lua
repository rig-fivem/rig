--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @module players
--- @file src/client/modules/players.lua
--- @description Client side player data handling.

--- @section Guard

if rawget(_G, "__client_players_module") then
    return _G.__client_players_module
end

--- @section Initialisation

local m = {}
_G.__client_players_module = m

--- @section Getters

function m.get_player_data(category)
    return core.client_player:get_data(category)
end

function m.has_loaded()
    return core.client_player:has_loaded()
end

function m.is_playing()
    return core.client_player:is_playing()
end

--- @section Exports

exports("get_player_data", m.get_player_data)
exports("has_loaded", m.has_loaded)
exports("is_playing", m.is_playing)

return m