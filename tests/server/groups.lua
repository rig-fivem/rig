--[[
----------------------------------------
RIG Framework (built for CFX Platforms)
Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-framework/rig-cfx
----------------------------------------
]]

local commands = require("src.server.modules.commands")
local _groups = require("src.server.modules.groups")

commands.register_command({
    name = "testcreategroup",
    help = "Tests _groups.create_group",
    handler = function(source)
        local parent_success = _groups.create_group({
            name = "alliance_alpha",
            label = "Alpha Alliance",
            type = "faction",
            parent_name = nil,
            metadata = { inherit_permissions = true }
        })

        local child_success = _groups.create_group({
            name = "clan_storm",
            label = "Storm Clan",
            type = "clan",
            parent_name = "alliance_alpha",
            metadata = { inherit_permissions = true }
        })

        if core.groups and type(core.groups.load_all) == "function" then
            core.groups:load_all()
        end

        log("success", ("[testcreategroup] Parent created: %s | Child created: %s"):format(tostring(parent_success), tostring(child_success)))
    end
})

commands.register_command({
    name = "testaddgrouprole",
    help = "Tests _groups.add_group_role",
    handler = function(source)
        _groups.add_group_role("alliance_alpha", {
            name = "commander",
            label = "Alliance Commander",
            grade = 10,
            permissions = { "faction.exclusive" }
        })

        local success = _groups.add_group_role("clan_storm", {
            name = "member",
            label = "Clan Member",
            grade = 1,
            permissions = { "clan.chat" }
        })

        log("success", ("[testaddgrouprole] Result: %s"):format(tostring(success)))
    end
})

commands.register_command({
    name = "testremovegrouprole",
    help = "Tests _groups.remove_group_role",
    handler = function(source)
        _groups.add_group_role("clan_storm", {
            name = "temp_role",
            label = "Temporary Role",
            grade = 2,
            permissions = {}
        })
        local success = _groups.remove_group_role("clan_storm", "temp_role")
        log("success", ("[testremovegrouprole] Result: %s"):format(tostring(success)))
    end
})

commands.register_command({
    name = "testaddplayertogroup",
    help = "Tests _groups.add_player_to_group",
    handler = function(source)
        local success = _groups.add_player_to_group(source, "clan_storm", "member", { primary = true })
        log("success", ("[testaddplayertogroup] Result: %s"):format(tostring(success)))
    end
})

commands.register_command({
    name = "testgroupinheritance",
    help = "Tests if a player in a child group correctly inherits parent group permissions",
    handler = function(source)
        -- Test against the player to ensure the registry's recursive inherit logic works
        local inherited_perm = _groups.has_player_permission(source, "faction.exclusive")
        log("success", ("[testgroupinheritance] Player inherited parent perm 'faction.exclusive': %s"):format(tostring(inherited_perm)))
    end
})

commands.register_command({
    name = "testgetplayergroups",
    help = "Tests _groups.get_player_groups",
    handler = function(source)
        local groups = _groups.get_player_groups(source)
        log("success", ("[testgetplayergroups] Retrieved player groups successfully."))
    end
})

commands.register_command({
    name = "testhasplayergroup",
    help = "Tests _groups.has_player_group",
    handler = function(source)
        local has = _groups.has_player_group(source, "clan_storm")
        log("success", ("[testhasplayergroup] Result: %s"):format(tostring(has)))
    end
})

commands.register_command({
    name = "testhasplayerpermission",
    help = "Tests _groups.has_player_permission",
    handler = function(source)
        local has = _groups.has_player_permission(source, "clan.chat")
        log("success", ("[testhasplayerpermission] Result: %s"):format(tostring(has)))
    end
})

commands.register_command({
    name = "testremoveplayerfromgroup",
    help = "Tests _groups.remove_player_from_group",
    handler = function(source)
        local success = _groups.remove_player_from_group(source, "clan_storm")
        log("success", ("[testremoveplayerfromgroup] Result: %s"):format(tostring(success)))
    end
})

commands.register_command({
    name = "testdeletegroups",
    help = "Tests _groups.delete_group",
    handler = function(source)
        local child_deleted = _groups.delete_group("clan_storm")
        local parent_deleted = _groups.delete_group("alliance_alpha")
        log("success", ("[testdeletegroups] Child deleted: %s | Parent deleted: %s"):format(tostring(child_deleted), tostring(parent_deleted)))
    end
})