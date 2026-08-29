--- @module commands
--- @file core/server/modules/commands.lua
--- @description ACE permission-based command registration with chat suggestion support.

--- @section Initialisation

local m = {}
local chat_suggestions = {}

--- @section Helpers

local function has_permission(source, required_ace)
    if not required_ace then return true end

    local aces = type(required_ace) == "table" and required_ace or { required_ace }

    for _, ace in ipairs(aces) do
        if IsPlayerAceAllowed(source, ace) then
            return true
        end
    end

    return false
end

local function register_chat_suggestion(command, help, params)
    chat_suggestions[#chat_suggestions + 1] = {
        name = "/" .. command,
        help = help,
        params = params
    }
end

--- @section Registration

function m.register(opts)
    if not opts or not opts.name or not opts.handler then
        print("[commands] Registration failed: missing name or handler")
        return false
    end

    if opts.help and opts.params then
        register_chat_suggestion(opts.name, opts.help, opts.params)
    end

    RegisterCommand(opts.name, function(source, args, raw)
        if has_permission(source, opts.ace) then
            opts.handler(source, args, raw)
        else
            TriggerClientEvent("chat:addMessage", source, {
                args = { "^1PERMISSION DENIED", "You don't have permission to use this command." }
            })
        end
    end, false)

    return true
end

--- @section Push

function m.push_suggestions(source)
    TriggerClientEvent("chat:addSuggestions", source, chat_suggestions)
end

return m