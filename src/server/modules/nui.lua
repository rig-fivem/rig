--- @module nui
--- @file src/server/modules/nui.lua
--- @description Handles core NUI stuff; notifications, modals, ui framework etc.

--- @section Guard

if rawget(_G, "__server_nui_module") then
    return _G.__server_nui_module
end

--- @section Initialisation

local m = {}
_G.__server_nui_module = m

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
        log("error", "gui: label is required")
        return false
    end

    local func = functions[label]
    if not func then
        log("error", ("gui: no function registered for label '%s'"):format(label))
        return false
    end

    return func(data)
end

function m.sanitize(data, path)
    path = path or "root"
    local action_keys = { on_action = "action", on_increment = "on_increment", on_decrement = "on_decrement", on_select = "on_select" }
    local out = {}

    for k, v in pairs(data) do
        local p = ("%s_%s"):format(path, tostring(k)):gsub("[^%w_]", "")

        local out_key = action_keys[k]
        if out_key then
            m.register_function(p, v)
            out[out_key] = p
        elseif type(v) == "table" then
            out[k] = m.sanitize(v, p)
        else
            out[k] = v
        end
    end

    return out
end

--- @section Notify

function m.notify(source, opts)
    if not source or not opts then
        log("error", "gui: notify called with missing source or opts")
        return
    end

    TriggerClientEvent("rig:client:notify", source, opts)
end

--- @section Modal

function m.build_modal(source, opts)
    if not source or not opts then
        log("error", "gui: build_modal called with missing source or opts")
        return
    end

    TriggerClientEvent("rig:client:build_modal", source, opts)
end

function m.close_modal(source, container)
    if not source then
        log("error", "gui: close_modal called with missing source")
        return
    end

    TriggerClientEvent("rig:client:close_modal", source, container)
end

--- @section KeyValue Display

function m.set_kvp_display(source, title, controls, show)
    if not source then
        log("error", "gui: set_kvp_display called with missing source")
        return
    end

    TriggerClientEvent("rig:client:set_kvp_display", source, title, controls, show)
end

function m.show_kvp_display(source)
    if not source then
        log("error", "gui: show_kvp_display called with missing source")
        return
    end

    TriggerClientEvent("rig:client:show_kvp_display", source)
end

function m.hide_kvp_display(source)
    if not source then
        log("error", "gui: hide_kvp_display called with missing source")
        return
    end

    TriggerClientEvent("rig:client:hide_kvp_display", source)
end

function m.toggle_kvp_display(source)
    if not source then
        log("error", "gui: toggle_kvp_display called with missing source")
        return
    end

    TriggerClientEvent("rig:client:toggle_kvp_display", source)
end

function m.destroy_kvp_display(source)
    if not source then
        log("error", "gui: destroy_kvp_display called with missing source")
        return
    end

    TriggerClientEvent("rig:client:destroy_kvp_display", source)
end

--- @section Progress Bar

function m.progress_bar(source, opts)
    if not source or not opts then
        log("error", "gui: progress_bar called with missing source or opts")
        return
    end

    TriggerClientEvent("rig:client:progress_bar", source, opts)
end

function m.cancel_progress_bar(source)
    if not source then
        log("error", "gui: cancel_progress_bar called with missing source")
        return
    end

    TriggerClientEvent("rig:client:cancel_progress_bar", source)
end

--- @section Progress Circle

function m.progress_circle(source, opts)
    if not source or not opts then
        log("error", "gui: progress_circle called with missing source or opts")
        return
    end

    TriggerClientEvent("rig:client:progress_circle", source, opts)
end

function m.cancel_progress_circle(source)
    if not source then
        log("error", "gui: cancel_progress_circle called with missing source")
        return
    end

    TriggerClientEvent("rig:client:cancel_progress_circle", source)
end

--- @section UI Framework

function m.build_ui(source, ui)
    if not source or not ui then
        log("error", "gui: build_ui called with missing source or ui")
        return
    end

    TriggerClientEvent("rig:client:build_ui", source, ui)
end

function m.close_ui(source)
    if not source then
        log("error", "gui: close_ui called with missing source")
        return
    end

    TriggerClientEvent("rig:client:close_ui", source)
end

--- @section HUD

function m.show_status_hud(source)
    if not source then
        log("error", "gui: show_status_hud called with missing source")
        return
    end

    TriggerClientEvent("rig:client:show_status_hud", source)
end

function m.hide_status_hud(source)
    if not source then
        log("error", "gui: hide_status_hud called with missing source")
        return
    end

    TriggerClientEvent("rig:client:hide_status_hud", source)
end

function m.update_status_hud(source, data)
    if not source or not data then
        log("error", "gui: update_status_hud called with missing source or data")
        return
    end

    TriggerClientEvent("rig:client:update_status_hud", source, data)
end

function m.destroy_status_hud(source)
    if not source then
        log("error", "gui: destroy_status_hud called with missing source")
        return
    end

    TriggerClientEvent("rig:client:destroy_status_hud", source)
end

--- @section Events

RegisterServerEvent("rig:server:nui_handler")
AddEventHandler("rig:server:nui_handler", function(data)
    local src = source

    if not data or not data.action then
        log("error", ("gui: nui_handler called with missing action (source %s)"):format(src))
        return
    end

    local success, result = pcall(m.call_registered_function, data.action, data)
    if not success then
        log("error", ("gui: function call '%s' failed for source %s: %s"):format(data.action, src, result))
    end

    if data.should_close then
        TriggerClientEvent("rig:client:remove_focus", source)
    end
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

exports("show_status_hud", m.show_status_hud)
exports("hide_status_hud", m.hide_status_hud)
exports("update_status_hud", m.update_status_hud)
exports("destroy_status_hud", m.destroy_status_hud)

return m