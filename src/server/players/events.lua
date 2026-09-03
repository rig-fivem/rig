--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @file src/server/players/events.lua
--- @description Handles all player specific server events.

--- @section Events

RegisterServerEvent("rig:server:disconnect", function()
    local _src = source
    local msg = locale and locale("server.players.disconnected") or "Disconnected."
    DropPlayer(_src, msg)
end)

RegisterServerEvent("rig:server:confirm_ground_snap", function()
    local _src = source
    local player = core.players:get(_src)
    if not player or not player:is_awaiting_spawn() then return end

    player:set_awaiting_spawn(false)

    local ped = GetPlayerPed(_src)
    FreezeEntityPosition(ped, false)
    TriggerClientEvent("rig:client:player_spawned", _src)
end)