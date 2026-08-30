--- @module callbacks
--- @file src/client/modules/callbacks.lua
--- @description Simple standalone callback registration system.

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

    TriggerServerEvent("rig:server:request_avatar")
end

--- @section Exports

exports("shutdown_loadscreen", m.shutdown_loadscreen)

return m