--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @module nui
--- @file src/client/modules/nui.lua
--- @description Handles core NUI stuff; notifications, modals, ui framework etc.


--- @section Guard

if rawget(_G, "__client_nui_module") then
    return _G.__client_nui_module
end

--- @section Initialisation

local m = {}
_G.__client_nui_module = m

local is_quickmenu_open = false
local is_radial_open = false
local functions = {}

--- @section Functions

function m.has_function(label)
    return functions[label] ~= nil
end

function m.register_function(label, func)
    functions[label] = func
end

function m.call_registered_function(label, data)
    if not label then
        log("error", "nui: label is required")
        return false
    end

    local func = functions[label]
    if not func then
        log("error", ("nui: no function registered for label '%s'"):format(label))
        return false
    end

    return func(data)
end

function m.sanitize(data, path)
    path = path or "root"
    local out = {}

    for k, v in pairs(data) do
        local p = ("%s_%s"):format(path, tostring(k)):gsub("[^%w_]", "")

        if (k == "on_action" or k == "on_increment" or k == "on_decrement" or k == "on_select") then
            m.register_function(p, v)
            out.action = p
        elseif type(v) == "table" then
            out[k] = m.sanitize(v, p)
        else
            out[k] = v
        end
    end

    return out
end

function m.send_nav(input)
    SendNUIMessage({ type = "qm_nav", input = input })
end

function m.start_nav_thread()
    local KEYS = {
        ["enter"] = 191,
        ["escape"] = 322,
        ["backspace"] = 177,
        ["arrowup"] = 172,
        ["arrowdown"] = 173,
    }

    CreateThread(function()
        while is_quickmenu_open do
            Wait(0)

            if IsControlJustPressed(0, KEYS["arrowup"]) then
                m.send_nav("up")
            elseif IsControlJustPressed(0, KEYS["arrowdown"]) then
                m.send_nav("down")
            elseif IsControlJustPressed(0, KEYS["enter"]) then
                m.send_nav("select")
            elseif IsControlJustPressed(0, KEYS["backspace"]) then
                m.send_nav("back")
            elseif IsControlJustPressed(0, KEYS["escape"]) then
                m.close_quickmenu()
            end
        end
    end)
end

--- @section Notify

function m.notify(opts)
    if not opts then
        log("error", "nui: notify called with missing opts")
        return
    end

    SendNUIMessage({
        func = "notify",
        payload = opts
    })
end

exports("notify", m.notify)

--- @section Modal

function m.build_modal(opts)
    if not opts then
        log("error", "nui: build_modal called with missing opts")
        return
    end

    local safe_opts = m.sanitize(opts, "modal")
    if not safe_opts then
        log("error", "nui: build_modal sanitize failed")
        return
    end

    SetNuiFocus(true, true)
    SendNUIMessage({
        func = "build_modal",
        payload = safe_opts
    })
end

function m.close_modal(container)
    SetNuiFocus(false, false)
    SendNUIMessage({
        func = "remove_modal",
        payload = { container = container }
    })
end

--- @section KeyValue Display

function m.set_kvp_display(title, controls, show)
    local payload = {}

    if type(title) == "table" then
        payload = title
    else
        payload = {
            title = title,
            controls = controls,
            show = show == nil and true or show
        }
    end

    SendNUIMessage({
        func = "set_kvp_display",
        payload = payload
    })
end

function m.show_kvp_display()
    SendNUIMessage({ func = "show_kvp_display" })
end

function m.hide_kvp_display()
    SendNUIMessage({ func = "hide_kvp_display" })
end

function m.toggle_kvp_display()
    SendNUIMessage({ func = "toggle_kvp_display" })
end

function m.destroy_kvp_display()
    SendNUIMessage({ func = "destroy_kvp_display" })
end

--- @section Progress Bar

function m.progress_bar(opts)
    if not opts then
        log("error", "nui: progress_bar called with missing opts")
        return
    end

    SendNUIMessage({
        func = "progress_bar",
        payload = opts
    })
end

function m.cancel_progress_bar()
    SendNUIMessage({ func = "cancel_progress_bar" })
end

--- @section Progress Circle

function m.progress_circle(opts)
    if not opts then
        log("error", "nui: progress_circle called with missing opts")
        return
    end

    SendNUIMessage({
        func = "progress_circle",
        payload = opts
    })
end

function m.cancel_progress_circle()
    SendNUIMessage({ func = "cancel_progress_circle" })
end

--- @section UI Framework

function m.build_ui(ui, skip_focus)
    if not ui then
        log("error", "nui: build_ui called with missing ui")
        return
    end

    local safe_ui = m.sanitize(ui, "ui")
    if not safe_ui then
        log("error", "nui: build_ui sanitize failed")
        return
    end

    if not skip_focus then
        SetNuiFocus(true, true)
    end
    SendNUIMessage({ func = "build_ui", payload = safe_ui })
end

function m.close_ui()
    SendNUIMessage({ func = "close_ui" })
    SetNuiFocus(false, false)
end

function m.update_slots(items)
    if type(items) ~= "table" then
        log("warn", "update_slots: invalid items table")
        return
    end

    local safe_items = m.sanitize(items, "update_slots")

    SendNUIMessage({ func = "update_slots", items = safe_items })
end

function m.update_grid(items, section_key)
    if type(items) ~= "table" then
        log("warn", "update_grid: invalid items table")
        return
    end

    local safe_items = m.sanitize(items, "update_grid")

    SendNUIMessage({ func = "update_grid", items = safe_items, section_key = section_key })
end

function m.set_slot_move_handler(func)
    core.nui.slot_move_handler = func
end

function m.set_grid_move_handler(func)
    core.nui.grid_move_handler = func
end

--- @section Headshot

function m.get_player_headshot(player_ped)
    player_ped = player_ped or PlayerPedId()
    local headshot = RegisterPedheadshotTransparent(player_ped)
    if not (headshot and IsPedheadshotValid(headshot)) then
        return nil
    end

    local timeout, txd = 1000, nil
    while not IsPedheadshotReady(headshot) and timeout > 0 do
        Wait(10)
        timeout = timeout - 10
    end

    if IsPedheadshotReady(headshot) then
        txd = GetPedheadshotTxdString(headshot)
        SetTimeout(2000, function() UnregisterPedheadshot(headshot) end)
    else
        UnregisterPedheadshot(headshot)
    end

    return txd and ("https://nui-img/%s/%s?v=%d"):format(txd, txd, GetGameTimer())
end

--- @section Inventory

function m.build_hotbar(opts)
    if not opts then
        log("error", "nui: build_hotbar called with missing opts")
        return
    end

    local safe_opts = m.sanitize(opts, "hotbar")
    if not safe_opts then
        log("error", "nui: build_hotbar sanitize failed")
        return
    end

    SendNUIMessage({
        func = "build_hotbar",
        payload = safe_opts
    })
end

function m.destroy_hotbar()
    SendNUIMessage({
        func = "destroy_hotbar"
    })
end

function m.update_hotbar(items)
    if type(items) ~= "table" then
        log("warn", "update_hotbar: invalid items table")
        return
    end

    local safe_items = m.sanitize(items, "hotbar")

    SendNUIMessage({ func = "update_hotbar", items = safe_items })
end

function m.inventory_popup(data)
    if not data then return end
    SendNUIMessage({
        func = "inventory_popup",
        payload = data
    })
end

--- @section Menus

function m.open_quickmenu(payload)
    if type(payload) ~= "table" then
        log("error", "quickmenu: open() requires a table payload")
        return
    end

    if is_quickmenu_open then
        m.close_quickmenu()
    end

    local sanitized = m.sanitize(payload)

    is_quickmenu_open = true

    SendNUIMessage({ func = "build_quickmenu", payload = sanitized })

    m.start_nav_thread()
end

function m.close_quickmenu()
    if not is_quickmenu_open then return end

    is_quickmenu_open = false

    SendNUIMessage({ func = "close_quickmenu" })
end

function m.is_quickmenu_open()
    return is_quickmenu_open
end

function m.push_quickmenu_update(id, items, title)
    if not is_quickmenu_open then return end
    SendNUIMessage({ type = "qm_update", id = id, items = items, title = title })
end

function m.open_radial(sections)
    if is_radial_open then return end
    if not sections then
        log("error", "nui: open_radial called with missing sections")
        return
    end

    local safe_sections = m.sanitize({ sections = sections }, "radial")
    if not safe_sections then
        log("error", "nui: open_radial sanitize failed")
        return
    end

    is_radial_open = true
    SetNuiFocus(true, true)
    SetCursorLocation(0.5, 0.5)
    SendNUIMessage({ func = "open_radial", payload = safe_sections })
end

function m.close_radial()
    if not is_radial_open then return end

    is_radial_open = false
    SetNuiFocus(false, false)
    SendNUIMessage({ func = "close_radial" })
end

function m.is_radial_open()
    return is_radial_open
end

--- @section Utility

function m.copy_to_clipboard(string)
    if not string then return end
    SendNUIMessage({ func = "copy_to_clipboard", string = string })
end

--- @section NUI Callbacks

RegisterNUICallback("nui:remove_focus", function()
    log("info", "nui: focus cleared")
    SetNuiFocus(false, false)
end)

RegisterNUICallback("nui:handler", function(data, cb)
    log("info", ("nui: handler invoked with %s"):format(json.encode(data)))

    if not data or not data.action then
        if cb then cb(false) end
        return
    end

    if data.action == "slots_moved_item" then
        if core.nui.slot_move_handler then
            core.nui.slot_move_handler(data.dataset)
        else
            log("warn", "No slot_move_handler set, skipping")
        end
        if cb then cb({ success = true }) end
        return
    end

    if data.action == "grid_moved_item" then
        if core.nui.grid_move_handler then
            core.nui.grid_move_handler(data.dataset)
        else
            log("warn", "No grid_move_handler set, skipping")
        end
        if cb then cb({ success = true }) end
        return
    end

    if m.has_function(data.action) then
        local success, result = pcall(m.call_registered_function, data.action, data)
        if not success then
            log("error", ("nui: handler failed for action '%s': %s"):format(data.action, result))
        end
    else
        TriggerServerEvent("rig:server:nui_handler", data)
    end

    if data.should_close then

        if is_quickmenu_open then
            m.close_quickmenu()
        end

        if is_radial_open then
            m.close_radial()
        end

        SetNuiFocus(false, false)
    end

    if cb then cb(true) end
end)

RegisterNUICallback("nui:close_radial", function(data, cb)
    is_radial_open = false
    SetNuiFocus(false, false)
    if cb then cb(true) end
end)

--- @section Events

RegisterNetEvent("rig:client:remove_focus", function()
    SetNuiFocus(false, false)
end)

RegisterNetEvent("rig:client:notify", function(opts)
    if not opts then return log("error", "nui: notify event missing opts") end

    m.notify(opts)
end)

RegisterNetEvent("rig:client:build_modal", function(opts)
    if not opts then return log("error", "nui: build_modal event missing opts") end

    m.build_modal(opts)
end)

RegisterNetEvent("rig:client:close_modal", function(container)
    if not container then container = "#ui_focus" end
    m.close_modal(container)
end)

RegisterNetEvent("rig:client:build_ui", function(opts)
    if not opts then return log("error", "nui: build_ui event missing opts") end

    m.build_ui(opts)
end)

RegisterNetEvent("rig:client:close_ui", function()
    m.close_ui()
end)

RegisterNetEvent("rig:client:open_quickmenu", function(menu_data)
    if not menu_data then return end
    m.open_quickmenu(menu_data)
end)

RegisterNetEvent("rig:client:close_quickmenu", function()
    m.close_quickmenu()
end)

RegisterNetEvent("rig:client:push_quickmenu_update", function(id, items, title)
    if not id or not items or not title then return end
    m.push_quickmenu_update()
end)

RegisterNetEvent("rig:client:build_radial", function(sections)
    if not sections then return end
    m.build_radial(sections)
end)

RegisterNetEvent("rig:client:open_radial", function()
    m.open_radial()
end)

RegisterNetEvent("rig:client:close_radial", function()
    m.close_radial()
end)

RegisterNetEvent("rig:client:copy_to_clipboard", function(string)
    if not string then return end
    m.copy_to_clipboard(string)
end)

--- @section Exports

exports("notify", m.notify)
exports("build_modal", m.build_modal)
exports("close_modal", m.close_modal)

exports("set_kvp_display", m.set_kvp_display)
exports("show_kvp_display", m.show_kvp_display)
exports("hide_kvp_display", m.hide_kvp_display)
exports("toggle_kvp_display", m.toggle_kvp_display)
exports("destroy_kvp_display", m.destroy_kvp_display)

exports("progress_bar", m.progress_bar)
exports("cancel_progress_bar", m.cancel_progress_bar)
exports("progress_circle", m.progress_circle)
exports("cancel_progress_circle", m.cancel_progress_circle)

exports("build_ui", m.build_ui)
exports("close_ui", m.close_ui)
exports("build_hotbar", m.build_hotbar)
exports("update_hotbar", m.update_hotbar)
exports("update_grid", m.update_grid)
exports("update_slots", m.update_slots)
exports("set_slot_move_handler", m.set_slot_move_handler)
exports("set_grid_move_handler", m.set_grid_move_handler)

exports("get_player_headshot", m.get_player_headshot)

exports("open_quickmenu", m.open_quickmenu)
exports("close_quickmenu", m.close_quickmenu)
exports("push_quickmenu_update", m.push_quickmenu_update)
exports("copy_to_clipboard", m.copy_to_clipboard)

exports("build_radial", m.build_radial)
exports("open_radial", m.open_radial)
exports("close_radial", m.close_radial)
exports("is_radial_open", m.is_radial_open)

return m