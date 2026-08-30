--- @file src/server/main.lua
--- @description Server side initialisation file.

--- @section Imports

local UserRegistry = require("src.server.user.registry")
local PlayerRegistry = require("src.server.player.registry")
local _cmds = require("src.server.modules.commands")
local _utils = require("src.server.modules.utils")

--- @section Registries

rig.users = UserRegistry.new()
rig.players = PlayerRegistry.new()

--- @section Events

RegisterServerEvent("rig:server:disconnect", function()
    local _src = source
    local msg = locale and locale("server.player.disconnected") or "Disconnected."
    DropPlayer(_src, msg)
end)

--- @section FiveM Events

AddEventHandler("playerConnecting", function(name, kick, deferrals)
    local _src = source
    rig.users:request_connection(_src, name, deferrals)
end)

AddEventHandler("playerJoining", function()
    local _src = source
    local ids = _utils.get_identifiers(_src)

    if ids.license then
        if rig.users:activate(_src, ids.license) then
            rig.players:create(_src)
            rig.players:assign_personal_bucket(_src)
            _cmds.push_command_suggestion(_src)
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

AddEventHandler("onResourceStart", function(res)
    if res ~= GetCurrentResourceName() then return end

    local base_path = "src.server.player.extensions"
    local extensions = {
        { name = "avatar", priority = 100 },
        { name = "statuses", priority = 99 }
    }

    for _, ext in ipairs(extensions) do
        local full_path = ("%s.%s"):format(base_path, ext.name)
        local ok, Class = pcall(require, full_path)

        if ok and type(Class) == "table" then
            rig.players:register_extension(ext.name, function(player)
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
    rig.players:save_all()
end)