--- @file src/server/gameplay.lua
--- @description Handles general server side gameplay rules, threads and setup.

--- @section Constants

local GAMEPLAY = core.settings.gameplay
local TICK_RATE = GAMEPLAY.tick_rate or 5000
local DELTA = TICK_RATE / 1000
local PLAYER_SAVE = (GAMEPLAY.save_interval or 5) * 60 * 1000

--- @section Player Tick

CreateThread(function()
    while true do
        for source, player in pairs(core.players:get_all()) do
            if player:has_loaded() then
                for _, name in ipairs(player:list_extensions()) do
                    local ext = player:get_extension(name)
                    if ext.on_tick then
                        local ok, err = pcall(ext.on_tick, ext, DELTA)
                        if not ok then player:emit("extension_error", name, "on_tick", err) end
                    end
                end
                player:emit("tick", DELTA)
            end
        end
        Wait(TICK_RATE)
    end
end)

--- @section Player Auto Save

CreateThread(function()
    while true do
        Wait(PLAYER_SAVE)
        core.players:save_all()
    end
end)