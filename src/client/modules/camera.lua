--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @module camera
--- @file src/client/modules/camera.lua
--- @description Camera helper combining offset positioning and sky drop-ins.

--- @section Guard

if rawget(_G, "__client_camera_module") then
    return _G.__client_camera_module
end

--- @section Initialisation

local m = {}
_G.__client_camera_module = m

--- @section Variables

local active_cam = nil

--- @section Functions

function m.set_entity_cam(opts)
    opts = opts or {}

    local coords = opts.coords
    if not coords then return false end

    local entity = opts.entity
    if not entity or not DoesEntityExist(entity) then return false end

    local heading = (coords.w or opts.heading) or GetEntityHeading(entity)
    if not heading then return false end

    local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(entity, coords.x, coords.y, coords.z + (opts.height_adjustment or 0)))
    if not x or not y or not z then return false end

    if DoesCamExist(active_cam) then
        DestroyCam(active_cam, false)
    end

    active_cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    local rotation = opts.rotation or vector3(-10.0, 0.0, 180.0)

    SetCamActive(active_cam, true)
    SetCamCoord(active_cam, x, y, z)
    SetCamRot(active_cam, rotation.x, rotation.y, heading + rotation.z)
    RenderScriptCams(true, false, 0, true, true)

    return true
end

function m.set_sky_drop_cam(opts)
    opts = opts or {}

    local coords = opts.coords
    if not coords then return false end

    if DoesCamExist(active_cam) then
        DestroyCam(active_cam, false)
    end

    local start_z = coords.z + (opts.start_z or 500.0)
    local end_z = coords.z + (opts.end_z or 100.0)
    local duration = opts.duration or 2000

    active_cam = CreateCam(opts.type or "DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(active_cam, coords.x, coords.y, start_z)
    PointCamAtCoord(active_cam, coords.x, coords.y, coords.z)
    SetCamActive(active_cam, true)
    RenderScriptCams(true, false, 0, true, true)

    local start_time = GetGameTimer()
    while GetGameTimer() - start_time < duration do
        local progress = (GetGameTimer() - start_time) / duration
        SetCamCoord(active_cam, coords.x, coords.y, start_z + (end_z - start_z) * progress)
        Wait(0)
    end

    return true
end

function m.destroy_cam(opts)
    opts = opts or {}

    if DoesCamExist(active_cam) then
        DestroyCam(active_cam, false)
        RenderScriptCams(false, opts.ease or false, opts.ease_ms or 0, true, true)
        active_cam = nil
    end
end

function m.get_active_cam()
    return active_cam
end

--- @section Exports

exports("set_entity_cam", m.set_entity_cam)
exports("set_sky_drop_cam", m.set_sky_drop_cam)
exports("destroy_cam", m.destroy_cam)
exports("get_active_cam", m.get_active_cam)

return m