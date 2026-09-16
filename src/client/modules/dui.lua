--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @module dui
--- @file src/client/modules/dui.lua
--- @description Handles DUI sprite interactions, drawn in the game world via DrawInteractiveSprite.

--- @section Guard

if rawget(_G, "__client_dui_module") then
    return _G.__client_dui_module
end

--- @section Imports

local _keys = require("src.client.modules.keys")

--- @section Initialisation

local m = {}
_G.__client_dui_module = m

--- @section Constants

local KEYS = _keys.keys
local DUI_RANGE = 1.5
local DUI_RANGE_SQUARED = DUI_RANGE * DUI_RANGE

--- @section Native Localization

local GetActiveScreenResolution = GetActiveScreenResolution
local CreateDui = CreateDui
local CreateRuntimeTxd = CreateRuntimeTxd
local CreateRuntimeTextureFromDuiHandle = CreateRuntimeTextureFromDuiHandle
local GetDuiHandle = GetDuiHandle
local IsControlJustReleased = IsControlJustReleased
local TriggerEvent = TriggerEvent
local TriggerServerEvent = TriggerServerEvent
local SetDrawOrigin = SetDrawOrigin
local HasStreamedTextureDictLoaded = HasStreamedTextureDictLoaded
local GetClosestObjectOfType = GetClosestObjectOfType
local GetHashKey = GetHashKey
local DrawInteractiveSprite = DrawInteractiveSprite
local SendDuiMessage = SendDuiMessage
local DoesEntityExist = DoesEntityExist
local SetEntityDrawOutline = SetEntityDrawOutline
local SetEntityDrawOutlineColor = SetEntityDrawOutlineColor
local SetEntityDrawOutlineShader = SetEntityDrawOutlineShader
local Wait = Wait
local GetEntityCoords = GetEntityCoords
local ClearDrawOrigin = ClearDrawOrigin

--- @section Tables

local dui_locations = {}

--- @section Functions

local function create_dui_sprite(location_id)
    local txd_name, txt_name = location_id, location_id
    local dui_url = "https://cfx-nui-rig/ui/dui/sprite.html"
    local screen_width, screen_height = GetActiveScreenResolution()
    local dui_object = CreateDui(dui_url, screen_width, screen_height)
    local txd = CreateRuntimeTxd(txd_name)
    CreateRuntimeTextureFromDuiHandle(txd, txt_name, GetDuiHandle(dui_object))

    return {
        dui_object = dui_object,
        txd_name = txd_name,
        txt_name = txt_name,
        initialized_at = GetGameTimer() + 250
    }
end

function m.add_dui_sprite(options)
    if not options.id or not options.coords or not options.header then return end

    local valid_keys = {}

    for _, key_data in ipairs(options.keys or {}) do
        local key_control = KEYS[string.lower(key_data.key)]
        if key_control then
            key_data.key_control = key_control
            valid_keys[#valid_keys + 1] = key_data
        end
    end

    local entity = nil
    if options.entity and options.model then
        entity = GetClosestObjectOfType(options.coords.x, options.coords.y, options.coords.z, 1.0, GetHashKey(options.model), false, false, false)
    end

    dui_locations[options.id] = {
        _state_dirty = true,
        _last_outline_state = nil,
        _last_access_check = 0,
        _last_access_result = true,
        id = options.id,
        model = options.model,
        entity = entity or nil,
        coords = vector3(options.coords.x + 0.025, options.coords.y + 0.025, options.coords.z),
        header = options.header,
        icon = options.icon or "",
        image = options.image or nil,
        keys = valid_keys,
        outline = options.outline,
        can_access = options.can_access,
        dui_object = create_dui_sprite(options.id),
        in_proximity = false,
        is_destroyed = false,
        is_hidden = false,
        additional = options.additional or {}
    }
end

function m.remove_dui_sprite(id)
    local data = dui_locations[id]
    if not data then return end

    if data.dui_object and data.dui_object.dui_object then
        DestroyDui(data.dui_object.dui_object)
    end

    dui_locations[id] = nil
end

local function handle_key_presses(location)
    for i = 1, #location.keys do
        local key_data = location.keys[i]
        if IsControlJustReleased(0, key_data.key_control) then
            key_data.on_action()
        end
    end
end

local function toggle_outline(location, state)
    if location._last_outline_state == state then return end
    location._last_outline_state = state

    local entity = location.entity
    if not entity or not DoesEntityExist(entity) then return end

    SetEntityDrawOutline(entity, state)
    if state then
        SetEntityDrawOutlineColor(255, 255, 255, 255)
        SetEntityDrawOutlineShader(1)
    end
end

local function render_dui(location, player_coords)
    if location.is_hidden then return end
    if GetGameTimer() < (location.dui_object.initialized_at or 0) then return end

    local dui = location.dui_object
    if not dui then return end

    if HasStreamedTextureDictLoaded(dui.txd_name) then
        SetDrawOrigin(location.coords.x, location.coords.y, player_coords.z + 0.5)
        DrawInteractiveSprite(dui.txd_name, dui.txt_name, 0, 0, 0.7, 0.7, 0.0, 255, 255, 255, 255)
        ClearDrawOrigin()
    end

    if location._state_dirty then
        location._state_dirty = false
        local safe_keys = {}
        for i = 1, #location.keys do
            local k = location.keys[i]
            safe_keys[i] = { key = k.key, label = k.label, key_control = k.key_control }
        end
        SendDuiMessage(dui.dui_object, json.encode({
            func = "show_dui",
            payload = {
                image = location.image,
                header = location.header,
                model = location.model,
                icon = location.icon,
                keys = safe_keys,
                outline = location.outline,
                is_destroyed = location.is_destroyed,
                is_hidden = location.is_hidden,
                additional = location.additional
            }
        }))
    end
end

function m.update_dui_sprite(id, update_data)
    local location = dui_locations[id]
    if not location then return end

    for key, value in pairs(update_data) do
        if key == "keys" and type(value) == "table" then
            local valid_keys = {}
            for _, key_data in ipairs(value) do
                local key_name = string.lower(key_data.key or "")
                local key_control = KEYS[key_name]
                if key_control then
                    key_data.key_control = key_control
                    valid_keys[#valid_keys + 1] = key_data
                end
            end
            location[key] = valid_keys
        else
            location[key] = value
        end
    end

    location._state_dirty = true
end

--- @section Events

RegisterNetEvent("rig:client:update_dui_sprite", function(id, updated_data)
    if not id or not updated_data then return end
    m.update_dui_sprite(id, updated_data)
end)

RegisterNetEvent("rig:client:add_dui_sprite", function(options)
    if not options then return end
    m.add_dui_sprite(options)
end)

RegisterNetEvent("rig:client:remove_dui_sprite", function(id)
    if not id then return end
    m.remove_dui_sprite(id)
end)

--- @section Threads

--- @section Threads

function m.start_proximity_thread()
    CreateThread(function()
        while true do
            local player_ped = PlayerPedId()
            local player_coords = GetEntityCoords(player_ped)
            local now = GetGameTimer()

            for _, location in pairs(dui_locations) do
                if location.is_destroyed then
                    m.remove_dui_sprite(location.id)
                else
                    local should_show = true

                    if location.can_access then
                        if now - location._last_access_check > 2000 then
                            location._last_access_check = now
                            local ok, result = pcall(location.can_access)
                            location._last_access_result = ok and result == true
                        end
                        should_show = location._last_access_result
                    end

                    if should_show and not location.is_hidden then
                        local dx = player_coords.x - location.coords.x
                        local dy = player_coords.y - location.coords.y
                        local dz = player_coords.z - location.coords.z
                        local distance_squared = dx * dx + dy * dy + dz * dz

                        if distance_squared <= DUI_RANGE_SQUARED then
                            location.in_proximity = true
                            if location.outline and location.entity then
                                toggle_outline(location, true)
                            end
                        else
                            if location.in_proximity then
                                location.in_proximity = false
                                if location.outline and location.entity then
                                    toggle_outline(location, false)
                                end
                            end
                        end
                    else
                        if location.in_proximity then
                            location.in_proximity = false
                            if location.outline and location.entity then
                                toggle_outline(location, false)
                            end
                        end
                    end
                end
            end

            Wait(250)
        end
    end)
end

function m.start_render_thread()
    CreateThread(function()
        while true do
            local player_ped = PlayerPedId()
            local player_coords = GetEntityCoords(player_ped)
            local any_nearby = false

            for _, location in pairs(dui_locations) do
                if location.in_proximity and not location.is_hidden and not location.is_destroyed then
                    render_dui(location, player_coords)
                    handle_key_presses(location)
                    any_nearby = true
                end
            end

            Wait(any_nearby and 0 or 250)
        end
    end)
end

--- @section Exports

exports("add_dui_sprite", m.add_dui_sprite)
exports("remove_dui_sprite", m.remove_dui_sprite)
exports("update_dui_sprite", m.update_dui_sprite)

--- @section Test Commands

RegisterCommand("testdui", function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local offsets = {
        { x = 2.0,  y = 0.0  },
        { x = -2.0, y = 0.0  },
        { x = 0.0,  y = 2.0  },
        { x = 0.0,  y = -2.0 },
        { x = 2.0,  y = 2.0  },
    }

    for i, offset in ipairs(offsets) do
        m.add_dui_sprite({
            id = ("test_zone_%d"):format(i),
            coords = { x = coords.x + offset.x, y = coords.y + offset.y, z = coords.z },
            header = ("Test Zone %d"):format(i),
            icon = "fa-solid fa-star",
            keys = {
                { key = "e", label = "Interact", on_action = function()
                    print(("Zone %d interact pressed"):format(i))
                end }
            }
        })
    end

    print("^2[testdui] 5 zones spawned around player")
end, false)

RegisterCommand("cleardui", function()
    for i = 1, 5 do
        m.remove_dui_sprite(("test_zone_%d"):format(i))
    end
    print("^2[cleardui] zones cleared")
end, false)

return m