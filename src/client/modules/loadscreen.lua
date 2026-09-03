--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @module loadscreen
--- @file src/client/modules/loadscreen.lua
--- @description Handles shutting down loadscreen / triggering request.

--- @section Guard

if rawget(_G, "__client_loadscreen_module") then
    return _G.__client_loadscreen_module
end

--- @section Initialisation

local m = {}
_G.__client_loadscreen_module = m

--- @section Functions

function m.shutdown_loadscreen()
    DoScreenFadeOut(500)
    while not IsScreenFadedOut() do Wait(50) end

    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    Wait(350)

    -- @todo replace with a config export or something?
    -- so people dont have to modify core if replacing avatar system
    TriggerServerEvent("rig:server:request_avatar")
end

--- @section Exports

exports("shutdown_loadscreen", m.shutdown_loadscreen)

return m