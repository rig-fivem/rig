--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @module avatars
--- @file src/server/modules/avatars.lua
--- @description Server side handling for player avatar system.

--- @section Guard

if rawget(_G, "__server_avatars_module") then
    return _G.__server_avatars_module
end

--- @section Initialisation

local m = {}
_G.__server_avatars_module = m

--- @section Functions 

function m.request_avatar(source)
    if not source then 
        log("error", "Source missing.") 
        return nil 
    end

    local player = core.players:get(source)
    if not player or not player.avatar then 
        log("error", ("Player or player avatar missing for source %s"):format(tostring(source)))
        return nil 
    end

    return player.avatar:get_data()
end

function m.customise_avatar(source, data)
    if not source or type(data) ~= "table" then 
        log("error", "Source or customization data missing.") 
        return false 
    end

    local player = core.players:get(source)
    if not player or not player.avatar then 
        log("error", ("Player or player avatar missing for source %s"):format(tostring(source)))
        return false 
    end

    player.avatar:set_all(data)
    player.avatar:set_has_customised(true)

    return true
end

--- @section Events

RegisterServerEvent("rig:server:request_avatar")
AddEventHandler("rig:server:request_avatar", function()
    local _src = source
    if not _src then return end

    local avatar = m.request_avatar(_src)

    if not avatar then
        log("error", ("Failed to fetch avatar for source %s"):format(_src))
        return
    end

    TriggerEvent("rig:server:request_avatar_response", _src, avatar)
end)

--- @section Exports

exports("request_avatar", m.request_avatar)
exports("customise_avatar", m.customise_avatar)

return m