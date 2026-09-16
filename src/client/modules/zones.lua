--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @module zones
--- @file src/client/modules/zones.lua
--- @description Straight forward zone creation system.

--- @section Guard

if rawget(_G, "__client_zones_module") then
    return _G.__client_zones_module
end

--- @section Imports

local _keys = require("src.client.modules.keys")
local _nui = require("src.client.modules.nui")

--- @section Initialisation

local m = {}
_G.__client_zones_module = m

--- @section Constants

local CONTROLS = {
    { key = "F", action = "Add Point" },
    { key = "X", action = "Undo Point" },
    { key = "ENTER", action = "Finish Zone" },
    { key = "G", action = "Toggle Debug" },
    { key = "BACKSPACE", action = "Exit" }
}

--- @section Variables

local is_active, is_typing, debug_mode = false, false, false
local current_zone, current_zone_state, all_zones, zone_index = {}, {}, {}, 1
local last_debug_text = ""
local last_pos = vector3(0, 0, 0)

--- @section Functions

local function draw_text_3d(x, y, z, text)
    local on_screen, _x, _y = World3dToScreen2d(x, y, z)
    if not on_screen then return end
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(_x, _y)
end

local function draw_zone(points, r, g, b)
    for i = 1, #points do
        local a = points[i]
        local bpt = points[i + 1] or points[1]
        DrawLine(a.x, a.y, a.z + 0.2, bpt.x, bpt.y, bpt.z + 0.2, r, g, b, 255)
        draw_text_3d(a.x, a.y, a.z + 0.25, tostring(i))
    end
end

local function draw_zone_debug_text(text)
    local lines = {}
    for line in string.gmatch(text or "", "[^\n]+") do
        lines[#lines + 1] = line
    end

    local start_x, start_y = 0.015, 0.025
    local line_height = 0.022
    local padding_x, padding_y = 0.006, 0.008
    local header_height = 0.028
    local max_width = 0.25
    local box_width = 0.12 + (math.min(#text, 35) * 0.0018)
    box_width = math.min(box_width, max_width)

    local box_height = (#lines * line_height) + (padding_y * 2) + header_height
    local center_x = start_x + (box_width / 2)
    local center_y = start_y + (box_height / 2)

    DrawRect(center_x, center_y + 0.01, box_width, box_height, 0, 0, 0, 170)
    DrawRect(center_x, center_y + 0.01, box_width - 0.002, box_height - 0.002, 255, 255, 255, 20)

    local header_center_y = start_y + (header_height / 2)
    DrawRect(center_x, header_center_y + 0.01, box_width, header_height, 0, 0, 0, 255)

    SetTextFont(4)
    SetTextScale(0.36, 0.36)
    SetTextColour(255, 255, 255, 255)
    SetTextCentre(1)
    SetTextEntry("STRING")
    AddTextComponentString("ZONE DEBUG")
    DrawText(center_x, header_center_y - 0.004)

    for i = 1, #lines do
        SetTextFont(0)
        SetTextScale(0.32, 0.32)
        SetTextColour(255, 255, 255, 230)
        SetTextEntry("STRING")
        AddTextComponentString(lines[i])
        DrawText(start_x + padding_x, start_y + (header_height - 0.008) + (i * line_height))
    end
end

local function is_point_in_convex_polygon(p, poly)
    local sign = nil
    for i = 1, #poly do
        local dx1 = poly[i].x - p.x
        local dy1 = poly[i].y - p.y
        local dx2 = poly[(i % #poly) + 1].x - p.x
        local dy2 = poly[(i % #poly) + 1].y - p.y
        local cross = dx1 * dy2 - dx2 * dy1
        if i == 1 then sign = cross > 0
        elseif sign ~= (cross > 0) then return false end
    end
    return true
end

local function prompt_zone_name(default_name)
    is_typing = true
    AddTextEntry("ZONE_NAME_PROMPT", "Enter a name for this zone:")
    DisplayOnscreenKeyboard(1, "ZONE_NAME_PROMPT", "", default_name, "", "", "", 25)

    while UpdateOnscreenKeyboard() == 0 do
        Wait(0)
    end

    local status = UpdateOnscreenKeyboard()
    is_typing = false

    if status == 1 then
        local result = GetOnscreenKeyboardResult()
        if result and result ~= "" then
            return result
        end
    end
    return nil
end

--- @section Zone Creator

local function zone_creator_tick()
    while is_active do
        Wait(0)

        if debug_mode then
            for _, zone in ipairs(all_zones) do
                draw_zone(zone.coords, 255, 0, 0)
            end
        end

        draw_zone(current_zone, 255, 255, 0)

        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        DrawMarker(28, pos.x, pos.y, pos.z - 0.9, 0, 0, 0, 0, 0, 0, 0.3, 0.3, 0.3, 0, 200, 0, 150, false, false, 2, false)
    end
end

local function zone_creator_controls()
    while is_active do
        Wait(0)

        if not is_typing then
            if IsControlJustPressed(0, _keys.get_key("f")) then
                local ped = PlayerPedId()
                local pos = GetEntityCoords(ped)
                current_zone[#current_zone + 1] = pos
                print(("Added point #%d: %.2f %.2f %.2f"):format(#current_zone, pos.x, pos.y, pos.z))

            elseif IsControlJustPressed(0, _keys.get_key("x")) then
                if #current_zone > 0 then
                    current_zone[#current_zone] = nil
                    print("Removed last point.")
                end

            elseif IsControlJustPressed(0, _keys.get_key("enter")) then
                if #current_zone >= 3 then
                    local default_name = ("zone_%d"):format(zone_index)
                    local custom_name = prompt_zone_name(default_name) or default_name
                    local poly2d = {}
                    for i = 1, #current_zone do
                        poly2d[i] = vector2(current_zone[i].x, current_zone[i].y)
                    end

                    all_zones[#all_zones + 1] = { name = custom_name, coords = current_zone, poly2d = poly2d }

                    TriggerEvent("rig:client:zone_created", {
                        name = custom_name,
                        zone = current_zone,
                        player = {
                            source = GetPlayerServerId(PlayerId()),
                            name = GetPlayerName(PlayerId())
                        }
                    })
                    print(("Saved zone '%s' with %d points."):format(custom_name, #current_zone))

                    current_zone = {}
                    zone_index = zone_index + 1
                else
                    print("Need at least 3 points to save zone.")
                end

            elseif IsControlJustPressed(0, _keys.get_key("backspace")) then
                m.stop_zone_creator()
            elseif IsControlJustPressed(0, _keys.get_key("g")) then
                debug_mode = not debug_mode
                print("Debug mode: " .. tostring(debug_mode))
            end
        end
    end
end

function m.start_zone_creator()
    if is_active then
        m.stop_zone_creator()
        return
    end

    current_zone = {}
    is_active = true

    _nui.set_kvp_display("CONTROLS", CONTROLS)
    _nui.show_kvp_display()

    CreateThread(zone_creator_tick)
    CreateThread(zone_creator_controls)
end

function m.stop_zone_creator()
    is_active = false
    _nui.destroy_kvp_display()
end

function m.toggle_debug()
    debug_mode = not debug_mode
end

function m.get_zones()
    return all_zones
end

function m.is_in_zone(name)
    return current_zone_state[name] or false
end

--- @section Threads

function m.start_zone_debug_thread()
    CreateThread(function()
        while true do
            if debug_mode or is_active then
                Wait(0)
                if debug_mode then
                    for _, zone in ipairs(all_zones) do
                        draw_zone(zone.coords, 255, 0, 0)
                    end

                    if last_debug_text ~= "" then
                        draw_zone_debug_text(last_debug_text)
                    end
                end
            else
                Wait(500)
            end
        end
    end)
end

function m.start_zone_state_thread()
    CreateThread(function()
        while true do
            if #all_zones == 0 then
                Wait(1000)
            else
                Wait(250)

                local ped = PlayerPedId()
                local pos = GetEntityCoords(ped)
                local moved = #(pos - last_pos) >= 0.5
                if moved then
                    last_pos = pos
                    local lines = {}

                    for _, zone in ipairs(all_zones) do
                        local name, poly2d = zone.name, zone.poly2d
                        local inside = is_point_in_convex_polygon(vector2(pos.x, pos.y), poly2d)
                        local was_inside = current_zone_state[name] or false

                        if inside and not was_inside then
                            current_zone_state[name] = true
                            TriggerEvent("rig:client:entered_zone", name)
                            if debug_mode then table.insert(lines, "Entered zone: " .. name) end

                        elseif not inside and was_inside then
                            current_zone_state[name] = false
                            TriggerEvent("rig:client:left_zone", name)
                            if debug_mode then table.insert(lines, "Left zone: " .. name) end

                        elseif inside then
                            TriggerEvent("rig:client:inside_zone", name)
                            if debug_mode then table.insert(lines, "Inside zone: " .. name) end
                        end
                    end

                    if debug_mode then
                        last_debug_text = #lines > 0 and table.concat(lines, "\n") or "Outside all zones"
                    end
                end
            end
        end
    end)
end

--- @section Events

RegisterNetEvent("rig:client:create_zone", function()
    m.start_zone_creator()
end)

RegisterNetEvent("rig:client:toggle_debug_zones", function()
    m.toggle_debug()
end)

--- @section Clean Up

AddEventHandler("onResourceStop", function(res)
    if GetCurrentResourceName() == res then
        m.stop_zone_creator()
    end
end)

--- @section Exports

exports("start_zone_creator", m.start_zone_creator)
exports("stop_zone_creator", m.stop_zone_creator)
exports("toggle_debug_zones", m.toggle_debug)
exports("get_zones", m.get_zones)
exports("is_in_zone", m.is_in_zone)

--- @section Test Commands

RegisterCommand("testzonecreator", function()
    m.start_zone_creator()
end)

RegisterCommand("teststopzonecreator", function()
    m.stop_zone_creator()
end)

RegisterCommand("testzonedebug", function()
    m.toggle_debug()
end)

RegisterCommand("testgetzones", function()
    local zones = m.get_zones()
    print(("[test] %d zone(s) currently created"):format(#zones))
    for _, zone in ipairs(zones) do
        print(("  - %s (%d points)"):format(zone.name, #zone.coords))
    end
end)

RegisterCommand("testinzone", function(_, args)
    local name = args[1]
    if not name then
        print("[test] usage: testinzone <zone_name>")
        return
    end
    print(("[test] in zone '%s': %s"):format(name, tostring(m.is_in_zone(name))))
end)

RegisterCommand("testzonethreads", function()
    m.start_zone_debug_thread()
    m.start_zone_state_thread()
    print("[test] zone debug + state threads started manually")
end)

return m