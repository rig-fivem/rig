--- @module user
--- @file src/server/modules/user.lua
--- @description Server side handling for user accounts.

--- @section Guard

if rawget(_G, "__server_users_module") then
    return _G.__server_users_module
end

--- @section Initialisation

local m = {}
_G.__server_users_module = m

--- @section Getters

function m.get_user_data(source)
    local u = core.users:get(source)
    if not u then return nil end

    return {
        unique_id = u.unique_id,
        license = u.license,
        username = u.username,
        name = u.name,
        vip = u.vip,
        banned = u:is_banned(),
        muted = u:is_muted()
    }
end

function m.get_username(source)
    local u = core.users:get(source)
    return u and u.username or nil
end

function m.get_unique_id(source)
    local u = core.users:get(source)
    return u and u.unique_id or nil
end

function m.get_name(source)
    local u = core.users:get(source)
    return u and u.name or nil
end

function m.get_vip(source)
    local u = core.users:get(source)
    return u and u.vip or nil
end

--- @section State

function m.is_banned(source)
    local u = core.users:get(source)
    return u ~= nil and u:is_banned()
end

function m.is_muted(source)
    local u = core.users:get(source)
    return u ~= nil and u:is_muted()
end

--- @section Moderation

function m.ban_user(source, banned_by, reason, expires_at)
    local u = core.users:get(source)
    if not u then
        log("warn", ("Function: ban_user failed | Reason: no user instance for source %d"):format(source))
        return false
    end

    return u:ban(banned_by, reason, expires_at)
end

function m.unban_user(source, appealed_by)
    local u = core.users:get(source)
    if not u then
        log("warn", ("Function: unban_user failed | Reason: no user instance for source %d"):format(source))
        return false
    end

    return u:unban(appealed_by)
end

function m.warn_user(source, warned_by, reason)
    local u = core.users:get(source)
    if not u then
        log("warn", ("Function: warn_user failed | Reason: no user instance for source %d"):format(source))
        return false
    end

    return u:warn(warned_by, reason)
end

function m.mute_user(source, muted_by, reason)
    local u = core.users:get(source)
    if not u then
        log("warn", ("Function: mute_user failed | Reason: no user instance for source %d"):format(source))
        return false
    end

    return u:mute(muted_by, reason)
end

function m.unmute_user(source)
    local u = core.users:get(source)
    if not u then
        log("warn", ("Function: unmute_user failed | Reason: no user instance for source %d"):format(source))
        return false
    end

    return u:unmute()
end

--- @section Records

function m.get_user_bans(source)
    local u = core.users:get(source)
    if not u then return {} end
    return u:get_bans()
end

function m.get_user_warnings(source)
    local u = core.users:get(source)
    if not u then return {} end
    return u:get_warnings()
end

function m.get_active_ban(source)
    local u = core.users:get(source)
    if not u then return nil end
    return u:get_active_ban()
end

--- @section Account

function m.set_username(source, username)
    local u = core.users:get(source)
    if not u then
        log("warn", ("Function: set_username failed | Reason: no user instance for source %d"):format(source))
        return false
    end

    return u:set_username(username)
end

function m.set_vip(source, vip)
    local u = core.users:get(source)
    if not u then
        log("warn", ("Function: set_vip failed | Reason: no user instance for source %d"):format(source))
        return false
    end

    return u:set_vip(vip)
end

--- @section Exports

exports("get_user_data", m.get_user_data)
exports("get_username", m.get_username)
exports("get_unique_id", m.get_unique_id)
exports("get_name", m.get_name)
exports("get_vip", m.get_vip)
exports("is_banned", m.is_banned)
exports("is_muted", m.is_muted)
exports("ban_user", m.ban_user)
exports("unban_user", m.unban_user)
exports("warn_user", m.warn_user)
exports("mute_user", m.mute_user)
exports("unmute_user", m.unmute_user)
exports("get_user_bans", m.get_user_bans)
exports("get_user_warnings", m.get_user_warnings)
exports("get_active_ban", m.get_active_ban)
exports("set_username", m.set_username)
exports("set_vip", m.set_vip)

return m