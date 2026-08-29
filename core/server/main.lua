--- @file core/server/main.lua
--- @description Server side initialisation file.

--- @section Imports

local UserRegistry = require("core.server.user.registry")
local PlayerRegistry = require("core.server.player.registry")
local User = require("core.server.user.class")
local commands = require("core.server.modules.commands")

--- @section Constants

local TICK_RATE = rig.settings.gameplay and rig.settings.gameplay.tick_rate or 5000
local DELTA = TICK_RATE / 1000
local PLAYER_SAVE = (rig.settings.gameplay and rig.settings.gameplay.save_interval or 5) * 60 * 1000

--- @section Registries

rig.users = UserRegistry.new()
rig.players = PlayerRegistry.new()

--- @section Player Extensions

--[[
rig.players:register_extension("avatar", function(player)
    return Avatar.new(player)
end)
]]

--- @section CFX Event Handlers

AddEventHandler("playerConnecting", function(name, kick, deferrals)
    local _src = source
    rig.users:request_connection(_src, name, deferrals)
end)

AddEventHandler("playerJoining", function()
    local _src = source
    local ids = User:get_identifiers(_src)

    if ids.license then
        if rig.users:activate(_src, ids.license) then
            rig.players:assign_personal_bucket(_src)
            commands.push_suggestions(_src)
        end
    end
end)

AddEventHandler("playerDropped", function(reason)
    local _src = source
    local player = rig.players:get(_src)
    if player then
        player:save()
    end

    rig.players:remove(_src)
    rig.users:remove(_src)
end)

AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end
    rig.players:save_all()
end)

--- @section Threads

CreateThread(function()
    while true do
        for source, player in pairs(rig.players:get_all()) do
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

CreateThread(function()
    while true do
        Wait(PLAYER_SAVE)
        rig.players:save_all()
    end
end)