--- @file tests/server/player.lua
--- @description Basic player class and registry creation test commands

--- @section Imports

local commands = require("src.server.modules.commands")

--- @section Commands

commands.register_command({
    name = "testplayer",
    help = "Test creation, data management, and method attachment on a Player object",
    handler = function(source)
        local user = rig.users:get(source)
        if not user then
            log("error", ("[testplayer] User session missing for source %d. Run /testjoin first!"):format(source))
            return
        end

        if rig.players:get(source) then
            log("warn", ("[testplayer] Player object already exists for source %d"):format(source))
            return
        end

        local player = rig.players:create(source)
        if not player then
            log("error", ("[testplayer] Player creation failed for source %d"):format(source))
            return
        end

        player:add_data("metadata", {
            level = 1,
            cash = 500,
            job = "unemployed"
        }, true)

        local metadata = player:get_data("metadata")

        player:add_method("get_summary", function(self_ref)
            local data = self_ref:get_data("metadata") or {}
            return ("Level: %d | Cash: $%d | Job: %s"):format(data.level or 0, data.cash or 0, data.job or "none")
        end)

        local summary = player:get_summary()

        log("success", ("========================================"))
        log("success", ("[testplayer] Player created and tested successfully!"))
        log("success", ("- Source: %d"):format(player.source))
        log("success", ("- Unique ID: %s"):format(player.unique_id))
        log("success", ("- Loaded: %s"):format(tostring(player:has_loaded())))
        log("success", ("- Metadata: level=%d, cash=%d, job=%s"):format(
            metadata and metadata.level or 0,
            metadata and metadata.cash or 0,
            metadata and metadata.job or "nil"
        ))
        log("success", ("- Summary Method Output: %s"):format(tostring(summary)))
        log("success", ("- Active Extensions: %s"):format(table.concat(player:list_extensions(), ", ")))
        log("success", ("========================================"))
    end
})

commands.register_command({
    name = "removeplayer",
    help = "Test cleanup and unloading of a Player object",
    handler = function(source)
        local player = rig.players:get(source)
        if not player then
            log("warn", ("[removeplayer] No active player object found for source %d"):format(source))
            return
        end

        rig.players:remove(source)
        log("success", ("[removeplayer] Successfully removed player instance for source %d"):format(source))
    end
})