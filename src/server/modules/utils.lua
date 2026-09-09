--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @module utils
--- @file src/server/modules/utils.lua
--- @description Handles all server side utility functions.

--- @section Guard

if rawget(_G, "__server_utils_module") then
    return _G.__server_utils_module
end

--- @section Initialisation

local m = {}
_G.__server_utils_module = m

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

--- @section Exports

exports("get_identifiers", m.get_identifiers)

return m