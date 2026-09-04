--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @class Skills
--- @file src/server/players/extensions/skills.lua
--- @description Player skills extension managing per-skill xp storage.

--- @section Imports

local _db = require("src.server.modules.database")

--- @section Initialisation

local Skills = {}
Skills.__index = Skills

--- @section Factory

function Skills.new(player)
    local self = setmetatable({
        player = player
    }, Skills)
    return self
end

--- @section Lifecycle Hooks

function Skills:on_load()
    local unique_id = self.player.unique_id

    local rows = _db.query("SELECT * FROM player_skills WHERE unique_id = ?", { unique_id })

    local skills = {}

    for _, row in ipairs(rows or {}) do
        skills[row.skill_id] = {
            skill_xp = row.skill_xp,
            metadata = type(row.metadata) == "string" and json.decode(row.metadata) or (row.metadata or {}),
            updated_at = row.updated_at,
            created = row.created
        }
    end

    self.player:add_data("skills", skills, true)

    log("debug", ("[Skills] Loaded %d skill(s) for source %d (UID: %s)"):format(#rows or 0, self.player.source, unique_id))
end

function Skills:on_save()
    local data = self.player:get_data("skills")
    if not data then return {} end

    local unique_id = self.player.unique_id
    local queries = {}

    for skill_id, skill in pairs(data) do
        queries[#queries + 1] = {
            query = [[
                INSERT INTO player_skills (unique_id, skill_id, skill_xp, metadata)
                VALUES (?, ?, ?, ?)
                ON DUPLICATE KEY UPDATE
                    skill_xp = VALUES(skill_xp),
                    metadata = VALUES(metadata)
            ]],
            values = {
                unique_id,
                skill_id,
                skill.skill_xp or 0,
                json.encode(skill.metadata or {})
            }
        }
    end

    return queries
end

--- @section Getters

function Skills:get_skills()
    return self.player:get_data("skills")
end

function Skills:get_skill(skill_id)
    if not skill_id then return nil end

    local skills = self:get_skills()
    if not skills then return nil end

    return skills[skill_id]
end

--- @section Mutations

function Skills:set_skill_xp(skill_id, skill_xp)
    if not skill_id or type(skill_xp) ~= "number" then return false end

    local skills = self:get_skills()
    if not skills then return false end

    skills[skill_id] = skills[skill_id] or { metadata = {} }
    skills[skill_id].skill_xp = skill_xp

    return self.player:set_data("skills", { [skill_id] = skills[skill_id] }, true)
end

function Skills:add_skill_xp(skill_id, amount)
    if not skill_id or type(amount) ~= "number" then return false end

    local skills = self:get_skills()
    if not skills then return false end

    skills[skill_id] = skills[skill_id] or { skill_xp = 0, metadata = {} }
    skills[skill_id].skill_xp = (skills[skill_id].skill_xp or 0) + amount

    return self.player:set_data("skills", { [skill_id] = skills[skill_id] }, true)
end

function Skills:set_metadata(skill_id, metadata, merge)
    if not skill_id or type(metadata) ~= "table" then return false end

    local skills = self:get_skills()
    if not skills or not skills[skill_id] then return false end

    if merge then
        skills[skill_id].metadata = skills[skill_id].metadata or {}
        for k, v in pairs(metadata) do skills[skill_id].metadata[k] = v end
    else
        skills[skill_id].metadata = metadata
    end

    return self.player:set_data("skills", { [skill_id] = skills[skill_id] }, true)
end

function Skills:remove_skill(skill_id)
    if not skill_id then return nil end

    local skills = self:get_skills()
    if not skills then return nil end

    local removed = skills[skill_id]
    skills[skill_id] = nil

    self.deleted_skills = self.deleted_skills or {}
    self.deleted_skills[#self.deleted_skills + 1] = skill_id

    self.player:set_data("skills", skills, true)

    return removed
end

return Skills