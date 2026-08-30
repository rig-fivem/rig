--- @section Initialisation

local Player = {}
Player.__index = Player
Player.__metatable = false

local private = {}

--- @section Helpers

local function priv_of(self)
    return private[self]
end

--- @section Factory

function Player.new(source, user)
    if not source or not user then
        log("warn", ("Failed to instantiate Player: missing source (%s) or user (%s)"):format(tostring(source), tostring(user)))
        return nil
    end

    local self = setmetatable({
        source = source,
        unique_id = user.unique_id
    }, Player)

    private[self] = {
        loaded = false,
        playing = false,
        data = {},
        replicated = {},
        extensions = {}
    }

    log("debug", ("Instantiated Player object for source %d (UID: %s)"):format(source, tostring(user.unique_id)))
    return self
end

--- @section Event

function Player:emit(event, ...)
    TriggerEvent(("rig:server:player_%s"):format(event), self.source, ...)
end

--- @section Lifecycle

function Player:load()
    local priv = priv_of(self)
    if not priv then
        log("error", ("Failed to load player source %d: private instance not found"):format(self.source))
        return false
    end

    log("debug", ("Loading player instance for source %d..."):format(self.source))

    for name, ext in pairs(priv.extensions) do
        if ext.on_load then
            local ok, err = pcall(ext.on_load, ext)
            if not ok then
                log("error", ("Extension '%s' failed on_load for source %d: %s"):format(name, self.source, tostring(err)))
                self:emit("extension_error", name, "on_load", err)
            end
        end
    end

    priv.loaded = true
    self:emit("loaded")
    log("success", ("Player instance for source %d loaded successfully"):format(self.source))
    return true
end

function Player:unload()
    local priv = priv_of(self)
    if not priv then
        log("error", ("Failed to unload player source %d: private instance not found"):format(self.source))
        return false
    end

    log("debug", ("Unloading player instance for source %d..."):format(self.source))

    for name, ext in pairs(priv.extensions) do
        if ext.on_unload then
            local ok, err = pcall(ext.on_unload, ext)
            if not ok then
                log("error", ("Extension '%s' failed on_unload for source %d: %s"):format(name, self.source, tostring(err)))
                self:emit("extension_error", name, "on_unload", err)
            end
        end
    end

    self:emit("unloaded")
    private[self] = nil
    log("info", ("Player instance for source %d unloaded"):format(self.source))
    return true
end

function Player:save()
    local priv = priv_of(self)
    if not priv then
        log("error", ("Failed to save player source %d: private instance not found"):format(self.source))
        return false
    end

    log("debug", ("Saving player data for source %d..."):format(self.source))

    local queries = {}
    for name, ext in pairs(priv.extensions) do
        if ext.on_save then
            local ok, res = pcall(ext.on_save, ext)
            if ok and res then
                for _, q in ipairs(res) do queries[#queries + 1] = q end
            elseif not ok then
                log("error", ("Extension '%s' failed on_save for source %d: %s"):format(name, self.source, tostring(res)))
                self:emit("extension_error", name, "on_save", res)
            end
        end
    end

    self:emit("before_save", queries)
    if #queries > 0 then
        exports.oxmysql:transaction_async(queries)
        log("debug", ("Executed %d save queries for source %d"):format(#queries, self.source))
    end
    self:emit("saved")
    log("success", ("Saved player instance for source %d"):format(self.source))
    return true
end

--- @section State

function Player:has_loaded()
    local priv = priv_of(self)
    return priv ~= nil and priv.loaded == true
end

function Player:is_playing()
    local priv = priv_of(self)
    return priv ~= nil and priv.playing == true
end

function Player:set_playing(state)
    local priv = priv_of(self)
    if not priv then return end
    priv.playing = state
    TriggerClientEvent("rig:client:player_playing_state_changed", self.source, state)
    self:emit("playing_state_changed", state)
end

--- @section Data

function Player:add_data(category, value, replicate)
    local priv = priv_of(self)
    if not priv then return false end
    priv.data[category] = value
    if replicate then priv.replicated[category] = true end
    log("debug", ("Added data category '%s' for source %d (replicated: %s)"):format(category, self.source, tostring(replicate or false)))
    self:emit("data_added", category, value, replicate)
    return true
end

function Player:get_data(category)
    local priv = priv_of(self)
    if not priv then return nil end
    if category == nil then return priv.data end
    return priv.data[category]
end

function Player:has_data(category)
    local priv = priv_of(self)
    return priv ~= nil and priv.data[category] ~= nil
end

function Player:set_data(category, updates, sync_data)
    local priv = priv_of(self)
    if not priv then return false end
    local target = priv.data[category]
    if type(target) == "table" and type(updates) == "table" then
        for k, v in pairs(updates) do target[k] = v end
        log("debug", ("Updated data category '%s' for source %d"):format(category, self.source))
        if sync_data then self:sync_data(category) end
        self:emit("data_changed", category, updates)
    end
    return true
end

function Player:replace_data(category, data, sync_data)
    local priv = priv_of(self)
    if not priv or priv.data[category] == nil then return false end
    priv.data[category] = type(data) == "table" and data or {}
    log("debug", ("Replaced data category '%s' for source %d"):format(category, self.source))
    if sync_data then self:sync_data(category) end
    self:emit("data_replaced", category, data)
    return true
end

function Player:remove_data(category)
    local priv = priv_of(self)
    if not priv or priv.data[category] == nil then return false end
    priv.data[category] = nil
    log("debug", ("Removed data category '%s' for source %d"):format(category, self.source))
    self:sync_data(category)
    self:emit("data_removed", category)
    return true
end

function Player:sync_data(category)
    local priv = priv_of(self)
    if not priv then return end
    local payload = {}
    if category then
        if priv.replicated[category] then payload[category] = priv.data[category] end
    else
        for k in pairs(priv.replicated) do payload[k] = priv.data[k] end
    end
    TriggerClientEvent("rig:client:sync_player_data", self.source, payload)
    log("debug", ("Synced player data (%s) to client for source %d"):format(category or "all", self.source))
    self:emit("synced", payload)
end

--- @section Methods

function Player:add_method(name, fn)
    local priv = priv_of(self)
    if not priv or type(name) ~= "string" or type(fn) ~= "function" then return false end

    if self[name] ~= nil then
        log("error", ("Method '%s' collides with existing Player field for source %d"):format(name, self.source))
        error(("rig: method '%s' collides with an existing Player field"):format(name), 2)
    end

    self[name] = fn

    log("debug", ("Added method '%s' to player source %d"):format(name, self.source))
    self:emit("method_added", name)
    return true
end

function Player:remove_method(name)
    local priv = priv_of(self)
    if not priv or type(name) ~= "string" or rawget(self, name) == nil then return false end

    self[name] = nil

    log("debug", ("Removed method '%s' from player source %d"):format(name, self.source))
    self:emit("method_removed", name)
    return true
end

function Player:get_method(name)
    local fn = rawget(self, name)
    return type(fn) == "function" and fn or nil
end

--- @section Extensions

function Player:add_extension(name, ext)
    local priv = priv_of(self)
    if not priv or type(name) ~= "string" or type(ext) ~= "table" then return false end
    if self[name] ~= nil then
        log("error", ("Extension '%s' collides with existing Player field for source %d"):format(name, self.source))
        error(("rig: extension '%s' collides with an existing Player field"):format(name), 2)
    end

    priv.extensions[name] = ext
    self[name] = ext

    log("debug", ("Added extension '%s' to player source %d"):format(name, self.source))
    self:emit("extension_added", name, ext)
    return true
end

function Player:remove_extension(name)
    local priv = priv_of(self)
    if not priv or not priv.extensions[name] then return false end
    priv.extensions[name] = nil
    self[name] = nil
    log("debug", ("Removed extension '%s' from player source %d"):format(name, self.source))
    self:emit("extension_removed", name)
    return true
end

function Player:get_extension(name)
    local priv = priv_of(self)
    return priv and priv.extensions[name]
end

function Player:list_extensions()
    local priv = priv_of(self)
    local keys = {}
    if not priv then return keys end
    for k in pairs(priv.extensions) do keys[#keys + 1] = k end
    return keys
end

return Player