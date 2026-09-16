--- @file src/server/commands.lua
--- @description Handles all server side core commands

--- @section Imports

local _nui = require("src.server.modules.nui")
local _cmds = require("src.server.modules.commands")

--- @section Public Commands

_cmds.register_command({
    name = "id",
    help = "Sends a notification containing your source id.",
    handler = function(source)
        _nui.notify(source, {
            type = "info",
            icon = "fa-solid fa-exclamation-circle",
            header = "SYSTEM",
            message = ("Your current ID: { %d }"):format(source),
            duration = 5500
        })
    end
})

--- @section Admin Commands

_cmds.register_command({
    ace = { "rig.dev", "rig.admin" },
    name = "rig:copycoords",
    help = "Copy your coordinates [v2, v3, v4]",
    params = {
        { name = "type", help = "[v2], [v3], [v4]" }
    },
    handler = function(source, args)
        local coord_type = args[1] or "v4"
        local ped = GetPlayerPed(source)
        if not DoesEntityExist(ped) then return false end

        local coords = GetEntityCoords(ped)
        local heading = GetEntityHeading(ped)

        local string
        if coord_type == "v2" then
            string = ("vector2(%.2f, %.2f)"):format(coords.x, coords.y)
        elseif coord_type == "v3" then
            string = ("vector3(%.2f, %.2f, %.2f)"):format(coords.x, coords.y, coords.z)
        elseif coord_type == "v4" then
            string = ("vector4(%.2f, %.2f, %.2f, %.2f)"):format(coords.x, coords.y, coords.z, heading)
        else
            return _nui.notify(source, {
                type = "error",
                header = "ADMIN",
                message = ("Unknown coordinate type: %s"):format(coord_type),
                duration = 4500
            })
        end

        _nui.notify(source, {
            type = "info",
            header = "ADMIN",
            message = ("Copied %s coordinates to clipboard"):format(coord_type),
            duration = 4500
        })

        TriggerClientEvent("rig:client:copy_to_clipboard", source, string)
    end
})

_cmds.register_command({
    ace = { "rig.dev", "rig.admin" },
    name = "rig:revive",
    help = "Revive yourself or a player.",
    params = {
        { name = "id", help = "Players server ID (optional)" }
    },
    handler = function(source, args)
        local target = tonumber(args[1]) or source
        local player = core.players:get(target)
        if not player then
            _nui.notify(source, {
                type = "error",
                icon = "fa-solid fa-times-circle",
                header = "SYSTEM",
                message = locale("server.statuses.commands.player_not_found"),
                duration = 5000
            })
            return
        end
        player.statuses:revive_player()
        player:sync_data()
        _nui.notify(source, {
            type = "success",
            header = "SYSTEM",
            message = locale("server.statuses.commands.player_revived", target),
            duration = 5000
        })
    end
})

_cmds.register_command({
    ace = { "rig.dev", "rig.admin" },
    name = "rig:kill",
    help = "Kill yourself or a player.",
    params = {
        { name = "id", help = "Player server ID (optional)" }
    },
    handler = function(source, args)
        local target = tonumber(args[1]) or source
        local player = core.players:get(target)
        if not player then
            _nui.notify(source, {
                type = "error",
                icon = "fa-solid fa-times-circle",
                header = locale("statuses.notify_header"),
                message = locale("server.statuses.commands.player_not_found"),
                duration = 5000
            })
            return
        end
        player.statuses:kill_player()
        player:sync_data()
        _nui.notify(source, {
            type = "success",
            icon = "fa-solid fa-check-circle",
            header = "SYSTEM",
            message = locale("server.statuses.commands.player_killed", target),
            duration = 5000
        })
    end
})

_cmds.register_command({
    ace = { "rig.dev", "rig.admin" },
    name = "rig:down",
    help = "Down yourself or a player.",
    params = {
        { name = "id", help = "Player server ID (optional)" }
    },
    handler = function(source, args)
        local target = tonumber(args[1]) or source
        local player = core.players:get(target)
        if not player then
            _nui.notify(source, {
                type = "error",
                header = "SYSTEM",
                message = locale("server.statuses.commands.player_not_found"),
                duration = 5000
            })
            return
        end
        player.statuses:down_player()
        player:sync_data()
        _nui.notify(source, {
            type = "success",
            header = "SYSTEM",
            message = locale("server.statuses.commands.player_downed", target),
            duration = 5000
        })
    end
})