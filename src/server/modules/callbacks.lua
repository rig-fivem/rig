--- @module callbacks
--- @file src/server/modules/callbacks.lua
--- @description Simple standalone callback registration system.

--- @section Guard

if rawget(_G, "__server_callbacks_module") then
    return _G.__server_callbacks_module
end

--- @section Initialisation

local m = {}
_G.__server_callbacks_module = m

local callbacks = {}

--- @section Functions

function m.register_callback(name, cb)
    if not name or type(cb) ~= "function" then
        print(("[callbacks] Failed to register callback: %s"):format(name or "nil"))
        return
    end

    if callbacks[name] then
        print(("[callbacks] Overwriting existing callback: %s"):format(name))
    end

    callbacks[name] = cb
end

--- @section Events

RegisterServerEvent("rig:server:trigger_callback")
AddEventHandler("rig:server:trigger_callback", function(name, data, cb_id)
    local _src = source
    local callback = callbacks[name]

    if not callback then
        print(("[callbacks] Callback not found: %s"):format(name))
        TriggerClientEvent("rig:client:callback_response", _src, cb_id, nil)
        return
    end

    callback(_src, data, function(response)
        TriggerClientEvent("rig:client:callback_response", _src, cb_id, response)
    end)
end)

--- @section Exports

exports("register_callback", m.register_callback)

return m