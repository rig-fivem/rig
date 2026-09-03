--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @file src/server/main.lua
--- @description Server side initialisation file.

--- @section Imports

local UserRegistry = require("src.server.users.registry")
local PlayerRegistry = require("src.server.players.registry")
local GroupRegistry = require("src.server.groups.registry")

local _cmds = require("src.server.modules.commands")
local _utils = require("src.server.modules.utils")

--- @section Registries

core.users = UserRegistry.new()
core.players = PlayerRegistry.new()
core.groups = GroupRegistry.new()

--- @section FiveM Events

AddEventHandler("playerConnecting", function(name, kick, deferrals)
    local _src = source
    core.users:request_connection(_src, name, deferrals)
end)

AddEventHandler("playerJoining", function()
    local _src = source
    local ids = _utils.get_identifiers(_src)

    if ids.license then
        if core.users:activate(_src, ids.license) then
            core.players:create(_src)
            core.players:assign_personal_bucket(_src)

            local p = core.players:get(_src)
            p:emit("loaded")

            _cmds.push_command_suggestion(_src)
        end
    end
end)

AddEventHandler("playerDropped", function(reason)
    local _src = source
    local player = core.players:get(_src)
    if player then
        player:save()
    end

    core.players:remove(_src)
    core.users:remove(_src)
end)

AddEventHandler("onResourceStart", function(res)
    if res ~= GetCurrentResourceName() then return end

    local base_path = "src.server.players.extensions"
    local extensions = {
        { name = "avatar", priority = 100 },
        { name = "statuses", priority = 99 },
        { name = "spawns", priority = 98 },
        { name = "inventory", priority = 97 }
    }

    for _, ext in ipairs(extensions) do
        local full_path = ("%s.%s"):format(base_path, ext.name)
        local ok, Class = pcall(require, full_path)

        if ok and type(Class) == "table" then
            core.players:register_extension(ext.name, function(player)
                if type(Class.new) == "function" then
                    return Class.new(player)
                end
                return setmetatable({ player = player }, Class)
            end, ext.priority or 100)

            log("info", ("[Extensions] Registered '%s' (Priority: %d)"):format(ext.name, ext.priority or 100))
        else
            log("error", ("[Extensions] Failed to require extension '%s' at '%s': %s"):format(ext.name, full_path, tostring(Class)))
        end
    end
end)

AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end
    core.players:save_all()
end)