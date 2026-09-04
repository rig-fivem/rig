--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @module skills
--- @file src/server/modules/skills.lua
--- @description Server side API wrapper for the player skills system.

--- @section Guard

if rawget(_G, "__server_skills_module") then
    return _G.__server_skills_module
end

--- @section Initialisation

local m = {}
_G.__server_skills_module = m

--- @section Functions

function m.get_player_skills(source)
    local p = core.players:get(source)
    if not p then return nil end

    return p.skills:get_skills()
end

function m.get_player_skill(source, skill_id)
    local p = core.players:get(source)
    if not p then return nil end

    return p.skills:get_skill(skill_id)
end

function m.set_player_skill_xp(source, skill_id, skill_xp)
    local p = core.players:get(source)
    if not p then return false end

    return p.skills:set_skill_xp(skill_id, skill_xp)
end

function m.add_player_skill_xp(source, skill_id, amount)
    local p = core.players:get(source)
    if not p then return false end

    return p.skills:add_skill_xp(skill_id, amount)
end

function m.set_player_skill_metadata(source, skill_id, metadata, merge)
    local p = core.players:get(source)
    if not p then return false end

    return p.skills:set_metadata(skill_id, metadata, merge)
end

function m.remove_player_skill(source, skill_id)
    local p = core.players:get(source)
    if not p then return nil end

    return p.skills:remove_skill(skill_id)
end

--- @section Exports

exports("get_player_skills", m.get_player_skills)
exports("get_player_skill", m.get_player_skill)
exports("set_player_skill_xp", m.set_player_skill_xp)
exports("add_player_skill_xp", m.add_player_skill_xp)
exports("set_player_skill_metadata", m.set_player_skill_metadata)
exports("remove_player_skill", m.remove_player_skill)

return m