--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @class Player
--- @file src/client/players/class.lua
--- @description Handles client player class nothing special just a data store.

--- @section Initialisation

local Player = {}
Player.__index = Player

--- @section Factory

function Player.new()
    log("debug", "Initialised client Player instance")
    return setmetatable({
        flags = {
            loaded = false,
            playing = false
        },
        data = {}
    }, Player)
end

--- @section Event Emit

function Player:emit(event, ...)
    TriggerEvent(("rig:client:player_%s"):format(event), ...)
end

--- @section State

function Player:has_loaded()
    return self.flags.loaded == true
end

function Player:set_loaded(state)
    local is_loaded = state == true
    if self.flags.loaded == is_loaded then return end

    self.flags.loaded = is_loaded
    log("info", ("Client player loaded state updated to: %s"):format(tostring(self.flags.loaded)))
    self:emit("loaded_state_changed", self.flags.loaded)
end

function Player:is_playing()
    return self.flags.playing == true
end

function Player:set_playing(state)
    local is_playing = state == true
    if self.flags.playing == is_playing then return end

    self.flags.playing = is_playing
    log("info", ("Client player playing state updated to: %s"):format(tostring(self.flags.playing)))
    self:emit("playing_changed", self.flags.playing)
end

--- @section Data

function Player:get_data(category)
    if category then
        log("debug", ("Fetching client player data for category '%s'"):format(tostring(category)))
        return self.data[category]
    end
    log("debug", "Fetching all client player data")
    return self.data
end

function Player:set_data(category, data)
    if type(category) ~= "string" or type(data) ~= "table" then
        log("warn", ("Invalid parameters provided to set_data (category: %s, data: %s)"):format(type(category), type(data)))
        return false
    end

    self.data[category] = data
    log("debug", ("Updated client player data for category '%s'"):format(category))
    self:emit("data_synced", category, data)
    return true
end

function Player:sync(payload)
    if type(payload) ~= "table" then
        log("warn", ("Invalid sync payload type received: %s"):format(type(payload)))
        return
    end

    log("info", "Syncing player data payload from server...")
    local count = 0
    for category, data in pairs(payload) do
        if type(category) == "string" and type(data) == "table" then
            if self:set_data(category, data) then
                count = count + 1
            end
        end
    end
    log("success", ("Successfully synced %d data categories from server"):format(count))
end

return Player