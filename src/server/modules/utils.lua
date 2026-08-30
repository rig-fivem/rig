--- @module utils
--- @file src/server/modules/utils.lua
--- @description Handles all server side utility functions.

--- @section Initialisation

local m = {}

--- @section Player Functions

function m.get_identifiers(source)
    local ids = {}
    for _, id in ipairs(GetPlayerIdentifiers(source)) do
        if id:find("license") then ids.license = id end
        if id:find("discord") then ids.discord = id end
        if id:find("ip") then ids.ip = id end
    end
    return ids
end

return m