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

function m.build_ui(ui)
    if not ui then
        log("error", "nui: build_ui called with missing ui")
        return
    end

    local safe_ui = m.sanitize(ui, "ui")
    if not safe_ui then
        log("error", "nui: build_ui sanitize failed")
        return
    end

    SetNuiFocus(true, true)
    SendNUIMessage({ func = "build_ui", payload = safe_ui })
end

function m.close_ui()
    SendNUIMessage({ func = "close_ui" })
    SetNuiFocus(false, false)
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

--- @section HUD

function m.send_headshot()
    local src = m.get_player_headshot()
    SendNUIMessage({ func = "set_status_headshot", payload = { src = src } })
end

function m.show_status_hud()
    SendNUIMessage({ func = "show_status_hud" })
end

function m.hide_status_hud()
    SendNUIMessage({ func = "hide_status_hud" })
end

function m.update_status_hud(data)
    if not data then return end
    SendNUIMessage({ func = "update_status_hud", payload = data })
end

function m.destroy_status_hud()
    SendNUIMessage({ func = "destroy_status_hud" })
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

    if m.has_function(data.action) then
        local success, result = pcall(m.call_registered_function, data.action, data)
        if not success then
            log("error", ("nui: handler failed for action '%s': %s"):format(data.action, result))
        end
    else
        TriggerServerEvent("rig:server:nui_handler", data)
    end

    if data.should_close then
        SetNuiFocus(false, false)
    end

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

return m