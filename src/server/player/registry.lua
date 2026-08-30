--- @class PlayerRegistry
--- @file src/server/player/registry.lua
--- @description Manages player objects for connected players.

--- @section Imports

local Player = require("src.server.player.class")

--- @section Constants

local BUCKET_AUTO_ID = 10000

--- @section Initialisation

local PlayerRegistry = {}
PlayerRegistry.__index = PlayerRegistry

--- @section Factory

function PlayerRegistry.new()
    log("debug", "Initialised PlayerRegistry instance")
    return setmetatable({
        players = {},
        extensions = {},
        player_buckets = {},
        next_bucket_id = BUCKET_AUTO_ID
    }, PlayerRegistry)
end

--- @section Routing

function PlayerRegistry:assign_personal_bucket(source)
    local bucket_id = self.next_bucket_id
    self.next_bucket_id = bucket_id + 1

    self.player_buckets[source] = bucket_id
    SetRoutingBucketPopulationEnabled(bucket_id, false)
    SetPlayerRoutingBucket(source, bucket_id)
    log("debug", ("Assigned personal routing bucket %d to source %d"):format(bucket_id, source))
    return bucket_id
end

function PlayerRegistry:set_bucket(source, bucket_id)
    self.player_buckets[source] = bucket_id
    SetPlayerRoutingBucket(source, bucket_id)
    log("debug", ("Set routing bucket %d for source %d"):format(bucket_id, source))
    return true
end

function PlayerRegistry:get_bucket(source)
    return self.player_buckets[source]
end

--- @section Extensions

function PlayerRegistry:register_extension(name, factory, priority)
    local prio = priority or 100
    self.extensions[name] = { name = name, factory = factory, priority = prio }

    self.sorted_extensions = {}
    for _, ext in pairs(self.extensions) do
        table.insert(self.sorted_extensions, ext)
    end
    table.sort(self.sorted_extensions, function(a, b) return a.priority > b.priority end)

    log("debug", ("Registered player extension '%s' with priority %d"):format(name, prio))
end

--- @section Players

function PlayerRegistry:create(source)
    local user = rig.users:get(source)
    if not user then
        log("warn", ("Failed to create player instance for source %d: user record not found in registry"):format(source))
        return nil
    end

    local p = Player.new(source, user)
    if not p then
        log("error", ("Failed to instantiate Player class for source %d"):format(source))
        return nil
    end

    for _, ext in ipairs(self.sorted_extensions or {}) do
        local ok, err = pcall(function()
            p:add_extension(ext.name, ext.factory(p))
        end)
        if not ok then
            log("error", ("Extension '%s' failed for source %d: %s"):format(ext.name, source, tostring(err)))
        end
    end

    p:load()
    self.players[source] = p
    log("success", ("Successfully created and loaded player instance for source %d"):format(source))
    return p
end

function PlayerRegistry:get(source)
    return self.players[source]
end

function PlayerRegistry:get_all()
    return self.players
end

function PlayerRegistry:remove(source)
    local p = self.players[source]
    if p then
        p:unload()
        log("info", ("Unloaded player instance for source %d"):format(source))
    end

    self:set_bucket(source, 0)
    self.player_buckets[source] = nil
    self.players[source] = nil
    log("debug", ("Cleaned up registry entries and bucket for source %d"):format(source))
end

function PlayerRegistry:save_all()
    log("info", "Saving all active player instances...")
    local count = 0
    for _, p in pairs(self.players) do
        if getmetatable(p) then
            p:save()
            count = count + 1
        end
    end
    log("success", ("Successfully saved %d player instances"):format(count))
end

return PlayerRegistry