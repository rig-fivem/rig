--- @file tests/server/user.lua
--- @description Basic user class tests

--- @section Imports

local User = require("core.server.user.class")
local commands = require("core.server.modules.commands")

--- @section Commands

commands.register({
    name = "testjoin",
    help = "Manually re-activates your user + player session after a core restart",
    handler = function(source)
        if not rig.users:get(source) then
            local ids = User:get_identifiers(source)
            if not ids.license then
                print(("[testjoin] No license identifier for source %d"):format(source))
                return
            end

            local result = rig.users:exists(ids.license)
            local user_data = result and result[1]
            if not user_data then
                print(("[testjoin] No DB record found for license %s"):format(ids.license))
                return
            end

            local u = User.new(source, user_data)
            if not u then
                print(("[testjoin] Failed to instantiate User for source %d"):format(source))
                return
            end

            rig.users.active[source] = u
            print(("[testjoin] Activated User UID %s"):format(tostring(u.unique_id)))
        else
            print(("[testjoin] User session already active for source %d"):format(source))
        end
    end
})

commands.register({
    name = "testuser",
    help = "Prints your active User object's core fields",
    handler = function(source)
        local user = rig.users:get(source)
        if not user then
            print(("[testuser] No active user for source %d"):format(source))
            return
        end

        print(("[testuser] source=%d unique_id=%s username=%s name=%s vip=%s banned=%s muted=%s"):format(
            user.source,
            tostring(user.unique_id),
            tostring(user.username),
            tostring(user.name),
            tostring(user.vip),
            tostring(user:is_banned()),
            tostring(user:is_muted())
        ))
    end
})

commands.register({
    name = "testidentifiers",
    help = "Prints identifiers for the current user",
    handler = function(source)
        local user = rig.users:get(source)
        if not user then
            print(("[testidentifiers] No active user for source %d"):format(source))
            return
        end

        local ids = user:get_identifiers()
        print(("[testidentifiers] license=%s discord=%s ip=%s"):format(
            tostring(ids.license), tostring(ids.discord), tostring(ids.ip)
        ))
    end
})

commands.register({
    name = "testvip",
    help = "Sets your VIP level",
    params = { { name = "level", help = "VIP level (number)" } },
    handler = function(source, args)
        local user = rig.users:get(source)
        if not user then
            print(("[testvip] No active user for source %d"):format(source))
            return
        end

        local level = tonumber(args[1])
        if not level then
            print("[testvip] Usage: /testvip <number>")
            return
        end

        local ok = user:set_vip(level)
        print(("[testvip] set_vip(%d) -> %s"):format(level, tostring(ok)))
    end
})

commands.register({
    name = "testusername",
    help = "Sets your username",
    params = { { name = "username", help = "New username" } },
    handler = function(source, args)
        local user = rig.users:get(source)
        if not user then
            print(("[testusername] No active user for source %d"):format(source))
            return
        end

        local username = args[1]
        if not username then
            print("[testusername] Usage: /testusername <name>")
            return
        end

        local ok, err = user:set_username(username)
        print(("[testusername] set_username('%s') -> %s%s"):format(username, tostring(ok), err and (" (" .. err .. ")") or ""))
    end
})

commands.register({
    name = "testban",
    help = "Bans yourself for testing (careful!)",
    handler = function(source)
        local user = rig.users:get(source)
        if not user then
            print(("[testban] No active user for source %d"):format(source))
            return
        end

        user:ban("test_command", "Testing ban flow", nil)
    end
})