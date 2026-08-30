--- @file tests/server/callbacks.lua
--- @description Basic player class and registry creation test commands

--- @section Imports

local callbacks = require("src.server.modules.callbacks")

--- @section Callbacks

callbacks.register_callback("rig:server:test_callback", function(source, data, cb)
    local player = rig.players:get(source)
    if not player then
        return cb({
            success = false,
            error = "Player instance not found"
        })
    end

    local ping = GetPlayerPing(source)
    local message = data and data.message or "No message sent"

    log("info", ("[callback] test_callback triggered by source %d (%s)"):format(source, player.unique_id))

    cb({
        success = true,
        source = source,
        unique_id = player.unique_id,
        ping = ping,
        received_message = message,
        timestamp = os.time()
    })
end)