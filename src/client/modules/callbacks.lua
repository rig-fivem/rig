--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @module callbacks
--- @file src/client/modules/callbacks.lua
--- @description Simple standalone callback registration system.

--- @section Guard

if rawget(_G, "__client_callbacks_module") then
    return _G.__client_callbacks_module
end

--- @section Initialisation

local m = {}
_G.__client_callbacks_module = m

local pending_callbacks = {}
local cb_id = 0

--- @section Functions

function m.trigger_callback(name, data, cb)
    if type(cb) ~= "function" then
        print(("[callbacks] Error: Trigger '%s' called without a valid callback function"):format(tostring(name)))
        return
    end

    cb_id = cb_id + 1
    pending_callbacks[cb_id] = cb

    TriggerServerEvent("rig:server:trigger_callback", name, data, cb_id)
end

--- @section Events

RegisterNetEvent("rig:client:callback_response")
AddEventHandler("rig:client:callback_response", function(id, response)
    local callback = pending_callbacks[id]

    if not callback then
        print(("[callbacks] Callback response received but ID not found: %s"):format(tostring(id)))
        return
    end

    pending_callbacks[id] = nil
    callback(response)
end)

--- @section Exports

exports("trigger_callback", m.trigger_callback)

return m