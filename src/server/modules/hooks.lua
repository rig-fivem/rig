--- @module hooks
--- @file src/server/modules/hooks.lua
--- @description Server side generic hook registry.

--- @section Guard

if rawget(_G, "__server_hooks_module") then
    return _G.__server_hooks_module
end

--- @section Initialisation

local m = {}
_G.__server_hooks_module = m

local hooks = {}

--- @section Hook Functions

function m.register_hook(hook_name, cb)
    if not hook_name or type(hook_name) ~= "string" then
        log("error", ("register_hook: invalid args for '%s'"):format(tostring(hook_name)))
        return false
    end

    if type(cb) ~= "function" and type(cb) ~= "table" then
        log("error", "cb is not function or table")
        return false
    end

    if hooks[hook_name] then
        log("error", ("register_hook: '%s' is already registered"):format(hook_name))
        return false
    end
    hooks[hook_name] = cb
    return true
end

function m.run_hook(hook_name, ...)
    local cb = hooks[hook_name]
    if not cb then
        log("error", ("run_hook: '%s' is not registered"):format(hook_name))
        return false
    end

    cb(...)
    return true
end

--- @section Exports

exports("register_hook", m.register_hook)
exports("run_hook", m.run_hook)

return m