--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @class User
--- @file src/server/users/class.lua
--- @description Main user class, handles everything to do with user accounts.

--- @section Imports

local _db = require("src.server.modules.database")

--- @section Initialisation

local User = {}
User.__index = User
User.__metatable = false

local private = {}

--- @section Helpers

local function priv_of(self)
    return private[self]
end

--- @section Factory

function User.new(source, data)
    if not source or not data then
        log("warn", ("Failed to instantiate User: missing source (%s) or data (%s)"):format(tostring(source), tostring(data)))
        return nil
    end

    local self = setmetatable({
        source = source,
        unique_id = data.unique_id,
        license = data.license,
        username = data.username,
        name = data.name,
        vip = data.vip,
    }, User)

    private[self] = {
        banned = data.banned == 1 or data.banned == true,
        muted = data.muted == 1 or data.muted == true
    }

    log("debug", ("Instantiated User object for source %d (UID: %s)"):format(source, tostring(data.unique_id)))
    return self
end

--- @section Event Bus

function User:emit(event, ...)
    TriggerEvent(("rig:server:user_%s"):format(event), self.source, ...)
end

--- @section State

function User:is_banned()
    local priv = priv_of(self)
    return priv ~= nil and priv.banned == true
end

function User:is_muted()
    local priv = priv_of(self)
    return priv ~= nil and priv.muted == true
end

--- @section Moderation

function User:ban(banned_by, reason, expires_at)
    local priv = priv_of(self)
    if not priv then
        log("error", ("Failed to ban user for source %d: private instance not found"):format(self.source))
        return false
    end

    local by = banned_by or "rig"
    local r = reason or "You have been banned."

    exports.oxmysql:transaction_async({
        { query = "UPDATE users SET banned = 1 WHERE unique_id = ?", values = { self.unique_id } },
        { query = "INSERT INTO user_bans (unique_id, banned_by, reason, expires_at) VALUES (?, ?, ?, ?)", values = { self.unique_id, by, reason or nil, expires_at or nil } }
    })
    priv.banned = true
    log("warn", ("User UID %s (source %d) banned by %s: %s"):format(tostring(self.unique_id), self.source, by, r))
    self:emit("banned", by, reason, expires_at)
    DropPlayer(self.source, r)
    return true
end

function User:unban(appealed_by)
    local priv = priv_of(self)
    if not priv then
        log("error", ("Failed to unban user UID %s: private instance not found"):format(tostring(self.unique_id)))
        return false
    end

    local by = appealed_by or "rig"
    exports.oxmysql:transaction_async({
        { query = "UPDATE users SET banned = 0 WHERE unique_id = ?", values = { self.unique_id } },
        { query = "UPDATE user_bans SET expired = 1, appealed = 1, appealed_by = ? WHERE unique_id = ? AND expired = 0", values = { by, self.unique_id } }
    })
    priv.banned = false
    log("info", ("User UID %s unbanned by %s"):format(tostring(self.unique_id), by))
    self:emit("unbanned", by)
    return true
end

function User:warn(warned_by, reason)
    local priv = priv_of(self)
    if not priv then
        log("error", ("Failed to warn user UID %s: private instance not found"):format(tostring(self.unique_id)))
        return false
    end

    local by = warned_by or "rig"
    exports.oxmysql:insert_async("INSERT INTO user_warnings (unique_id, warned_by, reason) VALUES (?, ?, ?)", { self.unique_id, by, reason or nil })
    TriggerClientEvent("rig:client:user_warned", self.source, by, reason)
    log("info", ("User UID %s (source %d) warned by %s: %s"):format(tostring(self.unique_id), self.source, by, tostring(reason)))
    self:emit("warned", by, reason)
    return true
end

function User:mute(muted_by, reason)
    local priv = priv_of(self)
    if not priv then
        log("error", ("Failed to mute user UID %s: private instance not found"):format(tostring(self.unique_id)))
        return false
    end

    local by = muted_by or "rig"
    exports.oxmysql:update_async("UPDATE users SET muted = 1 WHERE unique_id = ?", { self.unique_id })
    priv.muted = true
    log("info", ("User UID %s (source %d) muted by %s"):format(tostring(self.unique_id), self.source, by))
    self:emit("muted", by, reason)
    return true
end

function User:unmute()
    local priv = priv_of(self)
    if not priv then
        log("error", ("Failed to unmute user UID %s: private instance not found"):format(tostring(self.unique_id)))
        return false
    end

    exports.oxmysql:update_async("UPDATE users SET muted = 0 WHERE unique_id = ?", { self.unique_id })
    priv.muted = false
    log("info", ("User UID %s (source %d) unmuted"):format(tostring(self.unique_id), self.source))
    self:emit("unmuted")
    return true
end

--- @section Records

function User:get_bans()
    log("debug", ("Fetching ban records for user UID %s"):format(tostring(self.unique_id)))
    return exports.oxmysql:query_async("SELECT * FROM user_bans WHERE unique_id = ? ORDER BY created DESC", { self.unique_id })
end

function User:get_warnings()
    log("debug", ("Fetching warning records for user UID %s"):format(tostring(self.unique_id)))
    return exports.oxmysql:query_async("SELECT * FROM user_warnings WHERE unique_id = ? ORDER BY created DESC", { self.unique_id })
end

function User:get_active_ban()
    log("debug", ("Fetching active ban record for user UID %s"):format(tostring(self.unique_id)))
    local result = exports.oxmysql:query_async("SELECT * FROM user_bans WHERE unique_id = ? AND expired = 0 ORDER BY created DESC LIMIT 1", { self.unique_id })
    return result and result[1] or nil
end

--- @section Account

function User:set_username(username)
    if type(username) ~= "string" or username == "" then
        log("warn", ("Invalid username payload provided for user UID %s"):format(tostring(self.unique_id)))
        return false
    end
    if username == self.username then return true end

    if _db.value_exists_in_database("users", "username", username) then
        log("warn", ("Failed to change username for UID %s: '%s' is already taken"):format(tostring(self.unique_id), username))
        return false, "taken"
    end

    exports.oxmysql:update_async("UPDATE users SET username = ? WHERE unique_id = ?", { username, self.unique_id })
    self.username = username
    log("info", ("Updated username for UID %s to '%s'"):format(tostring(self.unique_id), username))
    self:emit("username_changed", username)
    return true
end

function User:set_vip(vip)
    if type(vip) ~= "number" then
        log("warn", ("Invalid VIP level provided for user UID %s"):format(tostring(self.unique_id)))
        return false
    end
    exports.oxmysql:update_async("UPDATE users SET vip = ? WHERE unique_id = ?", { vip, self.unique_id })
    self.vip = vip
    log("info", ("Updated VIP level for UID %s to %d"):format(tostring(self.unique_id), vip))
    self:emit("vip_changed", vip)
    return true
end

return User