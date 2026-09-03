--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @file src/client/gameplay.lua
--- @description Handles general client side gameplay rules, threads and setup.

--- @section Helper Functions

local function split_ids(str)
    local out = {}
    for id in str:gmatch("[^,]+") do
        out[#out + 1] = tonumber(id)
    end
    return out
end

--- @section Constants

local GAMEPLAY = core.settings.gameplay
local HUD_COMPONENTS = split_ids(GAMEPLAY.hud_components)
local DISABLED_CONTROLS = split_ids(GAMEPLAY.disabled_controls)
local player_id = PlayerId()

--- @section Gameplay Setup

if GAMEPLAY.disable_dispatch then
    for i = 1, 15 do EnableDispatchService(i, false) end
end

if GAMEPLAY.disable_police_scanner then
    SetAudioFlag("PoliceScannerDisabled", true)
end

if GAMEPLAY.disable_garbage_trucks then
    SetGarbageTrucks(false)
end

if GAMEPLAY.disable_random_cops then
    SetCreateRandomCops(false)
    SetCreateRandomCopsNotOnScenarios(false)
    SetCreateRandomCopsOnScenarios(false)
end

if GAMEPLAY.disable_weapon_autoreload then
    SetWeaponsNoAutoreload(true)
end

if GAMEPLAY.disable_weapon_autoswap then
    SetWeaponsNoAutoswap(true)
end

if GAMEPLAY.hide_hud_components or GAMEPLAY.DISABLED_CONTROLS or GAMEPLAY.hide_ammo or GAMEPLAY.invalidate_idle_cam then
    CreateThread(function()
        while true do
            if GAMEPLAY.hide_hud_components then
                for i = 1, #HUD_COMPONENTS do HideHudComponentThisFrame(HUD_COMPONENTS[i]) end
            end
            if GAMEPLAY.DISABLED_CONTROLS then
                for i = 1, #DISABLED_CONTROLS do DisableControlAction(0, DISABLED_CONTROLS[i], true) end
            end
            if GAMEPLAY.hide_ammo then
                DisplayAmmoThisFrame(false)
            end
            if GAMEPLAY.invalidate_idle_cam then
                InvalidateIdleCam()
                InvalidateVehicleIdleCam()
            end
            Wait(0)
        end
    end)
end

if GAMEPLAY.disable_wanted or GAMEPLAY.artificial_lights then
    CreateThread(function()
        while true do
            if GAMEPLAY.disable_wanted then
                ClearPlayerWantedLevel(player_id)
            end
            if GAMEPLAY.artificial_lights then
                SetArtificialLightsState(true)
                SetArtificialLightsStateAffectsVehicles(true)
            end
            Wait(100)
        end
    end)
end