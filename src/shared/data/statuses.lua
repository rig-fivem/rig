--[[
----------------------------------------
RIG Framework (built for rig)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig_avatars-cfx
License: https://github.com/rig-fivem/rig_avatars-cfx/blob/main/LICENSE
----------------------------------------
]]

--- @module statuses
--- @file src/shared/data/statuses.lua
--- @description Handles default statuses and injuries.
--- You probably dont want to change these

return {
    
    statuses = {
        health = 200.0,
        armour = 0.0,
        hunger = 100.0,
        thirst = 100.0,
        hygiene = 100.0,
        fatigue = 0.0,
        sanity = 100.0,
        temperature = 37.0,
        bleeding = 0.0,
        radiation = 0.0,
        infection = 0.0,
        poison = 0.0
    },

    injuries = {
        head = 0.0,
        upper_torso = 0.0,
        lower_torso = 0.0,
        forearm_right = 0.0,
        forearm_left = 0.0,
        hand_right = 0.0,
        hand_left = 0.0,
        thigh_right = 0.0,
        thigh_left = 0.0,
        calf_right = 0.0,
        calf_left = 0.0,
        foot_right = 0.0,
        foot_left = 0.0
    }
}