--- @class UserRegistry
--- @file src/server/user/registry.lua
--- @description Manages account connections and the User class layer.

--- @section Imports

local User = require("src.server.user.class")
local _db = require("src.server.modules.database")
local _utils = require("src.server.modules.utils")

--- @section Initialisation

local UserRegistry = {}
UserRegistry.__index = UserRegistry

--- @section Helpers

local function update_deferral(deferrals, key, ...)
    if not rig.settings.general.connection_messages then return end
    local msg = locale(key, ...)
    deferrals.update(msg)
end

--- @section Factory

function UserRegistry.new()
    log("debug", "Initialised UserRegistry instance")
    return setmetatable({
        temp = {},
        active = {}
    }, UserRegistry)
end

--- @section Persistence

function UserRegistry:exists(license)
    log("debug", ("Checking user account existence for license: %s"):format(tostring(license)))
    local query = "SELECT * FROM users WHERE license = ? LIMIT 1"
    return exports.oxmysql:query_async(query, { license })
end

function UserRegistry:persist(username, name, unique_id, license, discord, tokens, ip)
    log("info", ("Persisting new user record UID %s (%s) to database"):format(tostring(unique_id), tostring(username)))
    local query = "INSERT INTO users (unique_id, username, name, license, discord, tokens, ip) VALUES (?, ?, ?, ?, ?, ?, ?)"
    local params = { unique_id, username, name, license, discord, json.encode(tokens), ip }
    return exports.oxmysql:insert_async(query, params)
end

--- @section Connections

function UserRegistry:request_connection(source, name, deferrals)
    log("debug", ("Processing connection request for source %d (%s)..."):format(source, name))

    local ids = _utils.get_identifiers(source)
    if not ids.license then
        log("warn", ("Connection rejected for source %d: missing license identifier"):format(source))
        return deferrals.done(locale("server.user.registry.no_license"))
    end

    deferrals.defer()
    update_deferral(deferrals, "src.server.user.registry.checking")

    local result = self:exists(ids.license)
    local user_data = result and result[1]

    if not user_data then
        update_deferral(deferrals, "src.server.user.registry.creating")
        local uid = _db.generate_unique_id(rig.settings.users.unique_id_chars, "users", "unique_id", nil)
        local username = rig.settings.users.username_prefix .. "_" .. uid
        self:persist(username, name, uid, ids.license, ids.discord, GetPlayerTokens(source), ids.ip)
        user_data = { username = username, name = name, unique_id = uid, license = ids.license, discord = ids.discord, ip = ids.ip, banned = false, vip = 1 }
        log("success", ("Created new user profile UID %s for %s"):format(uid, name))
    end

    update_deferral(deferrals, "src.server.user.registry.checking_bans")
    local ban_query = "SELECT id, reason, expires_at FROM user_bans WHERE unique_id = ? AND expired = 0 ORDER BY created DESC LIMIT 1"
    local ban = exports.oxmysql:query_async(ban_query, { user_data.unique_id })
    local active_ban = ban and ban[1]

    if active_ban then
        if active_ban.expires_at and os.time() > (active_ban.expires_at / 1000) then
            exports.oxmysql:query_async("UPDATE user_bans SET expired = 1 WHERE id = ?", { active_ban.id })
            exports.oxmysql:query_async("UPDATE users SET banned = 0 WHERE unique_id = ?", { user_data.unique_id })
            log("info", ("Expired ban cleaned up for UID %s"):format(user_data.unique_id))
        else
            local time_str = active_ban.expires_at and os.date("%Y-%m-%d %H:%M:%S", active_ban.expires_at / 1000) or locale("server.user.registry.ban_permanent")
            local reason = active_ban.reason or locale("server.user.ban_no_reason")
            log("warn", ("Connection rejected for source %d (UID %s): active ban active"):format(source, user_data.unique_id))
            return deferrals.done(locale("server.user.registry.banned", time_str, reason))
        end
    end

    self.temp[ids.license] = user_data
    log("debug", ("Connection request approved for source %d (UID %s)"):format(source, user_data.unique_id))
    deferrals.done()
end

function UserRegistry:activate(source, license)
    local data = self.temp[license]
    if not data then
        log("warn", ("Failed to activate user for source %d: no temporary connection data found for license %s"):format(source, tostring(license)))
        return false
    end

    local u = User.new(source, data)
    if not u then
        log("error", ("Failed to instantiate User object during activation for source %d"):format(source))
        return false
    end

    self.active[source] = u
    self.temp[license] = nil
    log("success", ("Activated user session for source %d (UID: %s)"):format(source, tostring(u.unique_id)))
    return true
end

--- @section Active Users

function UserRegistry:get(source)
    return self.active[source]
end

function UserRegistry:remove(source)
    if self.active[source] then
        log("info", ("Removed active user session for source %d"):format(source))
        self.active[source] = nil
    end
end

return UserRegistry