--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @file src/client/players/events.lua
--- @description Handles client player events.

--- @section Imports

local _cam = require("src.client.modules.camera")

--- @section Player States

RegisterNetEvent("rig:client:player_loaded")
AddEventHandler("rig:client:player_loaded", function(player)
    if type(player) ~= "table" or not player.source then
        log("error", "player_loaded event fired with missing or invalid player table")
        return
    end

    if not core.client_player then
        log("error", "Cannot set loaded state: core.client_player is nil")
        return
    end

    core.client_player:set_loaded(true)
    log("info", ("Player loaded: %s (source %d)"):format(tostring(player.username), player.source))
end)

RegisterNetEvent("rig:client:player_playing_state_changed")
AddEventHandler("rig:client:player_playing_state_changed", function(state)
    if state == nil then
        log("error", "player_playing_state_changed event fired with missing state")
        return
    end

    if not core.client_player then
        log("error", "Cannot set playing state: core.client_player is nil")
        return
    end

    core.client_player:set_playing(state)
    log("info", ("Player playing state changed: %s"):format(core.client_player:is_playing() and "playing" or "not playing"))
end)

--- @section Data Sync

RegisterNetEvent("rig:client:sync_player_data")
AddEventHandler("rig:client:sync_player_data", function(payload)
    if type(payload) ~= "table" then
        log("warn", "Received non-table payload in rig:client:sync_player_data")
        return
    end

    if not core.client_player then
        log("error", "Cannot sync player data: core.client_player is nil")
        return
    end

    core.client_player:sync(payload)
end)

--- @section Spawns

RegisterNetEvent("rig:client:find_ground_and_spawn", function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)

    Wait(100)

    RequestCollisionAtCoord(coords.x, coords.y, coords.z)
    local attempts = 0
    repeat
        Wait(100)
        attempts = attempts + 1
    until HasCollisionLoadedAroundEntity(ped) or attempts >= 30

    local found, ground_z
    attempts = 0
    repeat
        found, ground_z = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
        attempts = attempts + 1
        Wait(100)
    until found or attempts >= 20

    if found then
        SetEntityCoords(ped, coords.x, coords.y, ground_z + 0.5, false, false, false, false)
    end

    FreezeEntityPosition(ped, false)
    SetEntityVisible(ped, true)

    _cam.destroy_cam()

    if IsScreenFadedOut() then DoScreenFadeIn(1000) end
end)