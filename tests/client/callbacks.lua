--- @file tests/client/callbacks.lua
--- @description Test command to verify client-to-server callback pipeline

--- @section Imports

local callbacks = require("src.client.modules.callbacks")

--- @section Commands

RegisterCommand("testcallbacks", function()
    print("[testcallbacks] Sending test callback request to server...")

    callbacks.trigger_callback("rig:server:test_callback", {
        message = "Hello from client test command!"
    }, function(response)
        if not response then
            print("[testcallbacks] Received nil response from server")
            return
        end

        if not response.success then
            print(("[testcallbacks] Callback failed: %s"):format(response.error or "Unknown error"))
            return
        end

        print("========================================")
        print("[testcallbacks] Server Callback Success!")
        print(("- Player Source: %d"):format(response.source))
        print(("- Unique ID: %s"):format(response.unique_id))
        print(("- Ping: %d ms"):format(response.ping))
        print(("- Echoed Message: %s"):format(response.received_message))
        print(("- Server Timestamp: %d"):format(response.timestamp))
        print("========================================")
    end)
end, false)