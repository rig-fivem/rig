--[[
----------------------------------------
RIG Framework (built for rig)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig_avatars-cfx
License: https://github.com/rig-fivem/rig_avatars-cfx/blob/main/LICENSE
----------------------------------------
]]

--- @module effects
--- @file configs/effects.lua
--- @description Handles all spawns related config settings

return {
    types = {
        buff = true,
        debuff = true,
        status = true
    },

    dysentry = { -- Unique id for effect
        type = "debuff", -- the _type
        label = "Dysentery", -- UI label
        duration = 1800, -- Duration of effect in seconds
        modifiers = { -- What the effect can modify
            thirst = -2.0, -- lowers thirst by -2.0 per tick when affected
            on_tick = { -- @todo implement a on_tick check for effects
                { action = "animation", type = "stomach_ache", chance = 0.1 } -- idea is to trigger animations, throwing up etc random chance stuff
            }
        }
    },

    cholera = {
        type = "debuff",
        label = "Cholera",
        duration = 1800,
        modifiers = {
            health = -1.0,
            thirst = -5.0,
            hunger = -2.0, 
        }
    },

    parasites = {
        type = "debuff",
        label = "Parasites",
        duration = -1,
        modifiers = {
            health = -3.0,
            thirst = -5.0,
            hunger = -8.0, 
        }
    }
}