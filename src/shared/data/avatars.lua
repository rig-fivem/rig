--[[
----------------------------------------
RIG Framework (built for rig)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig_avatars-cfx
License: https://github.com/rig-fivem/rig_avatars-cfx/blob/main/LICENSE
----------------------------------------
]]

--- @module avatars
--- @file configs/avatars.lua
--- @description Handles locations for creator and default avatar styles for mp_""_freemode peds.

return {

    constants = {
        facial_features = {
            { index = 0, value = "nose_width" }, 
            { index = 1, value = "nose_peak_height" }, 
            { index = 2, value = "nose_peak_length" },
            { index = 3, value = "nose_bone_height" }, 
            { index = 4, value = "nose_peak_lower" }, 
            { index = 5, value = "nose_twist" },
            { index = 6, value = "eyebrow_height" }, 
            { index = 7, value = "eyebrow_depth" }, 
            { index = 8, value = "cheek_bone" },
            { index = 9, value = "cheek_sideways_bone" }, 
            { index = 10, value = "cheek_bone_width" },
            { index = 11, value = "eye_opening" }, 
            { index = 12, value = "lip_thickness" }, 
            { index = 13, value = "jaw_bone_width" },
            { index = 14, value = "jaw_bone_shape" }, 
            { index = 15, value = "chin_bone" }, 
            { index = 16, value = "chin_bone_length" },
            { index = 17, value = "chin_bone_shape" }, 
            { index = 18, value = "chin_hole" }, 
            { index = 19, value = "neck_thickness" }
        },

        overlays = {
            { index = 2, style = "eyebrow", opacity = "eyebrow_opacity", colour = "eyebrow_colour" },
            { index = 1, style = "facial_hair", opacity = "facial_hair_opacity", colour = "facial_hair_colour" },
            { index = 10, style = "chest_hair", opacity = "chest_hair_opacity", colour = "chest_hair_colour" },
            { index = 4, style = "make_up", opacity = "make_up_opacity", colour = "make_up_colour" },
            { index = 5, style = "blush", opacity = "blush_opacity", colour = "blush_colour" },
            { index = 8, style = "lipstick", opacity = "lipstick_opacity", colour = "lipstick_colour" },
            { index = 0, style = "blemish", opacity = "blemish_opacity" },
            { index = 11, style = "moles", opacity = "moles_opacity" },
            { index = 3, style = "ageing", opacity = "ageing_opacity" },
            { index = 6, style = "complexion", opacity = "complexion_opacity" },
            { index = 7, style = "sun_damage", opacity = "sun_damage_opacity" },
            { index = 9, style = "body_blemish", opacity = "body_blemish_opacity" }
        },

        clothing = {
            { index = 1, style = "mask_style", texture = "mask_texture" },
            { index = 11, style = "jacket_style", texture = "jacket_texture" },
            { index = 8, style = "shirt_style", texture = "shirt_texture" },
            { index = 9, style = "vest_style", texture = "vest_texture" },
            { index = 4, style = "legs_style", texture = "legs_texture" },
            { index = 6, style = "shoes_style", texture = "shoes_texture" },
            { index = 3, style = "hands_style", texture = "hands_texture" },
            { index = 5, style = "bag_style", texture = "bag_texture" },
            { index = 10, style = "decals_style", texture = "decals_texture" },
            { index = 7, style = "neck_style", texture = "neck_texture" },
            { index = 0, style = "hats_style", texture = "hats_texture", is_prop = true },
            { index = 1, style = "glasses_style", texture = "glasses_texture", is_prop = true },
            { index = 2, style = "earwear_style", texture = "earwear_texture", is_prop = true },
            { index = 6, style = "watches_style", texture = "watches_texture", is_prop = true },
            { index = 7, style = "bracelets_style", texture = "bracelets_texture", is_prop = true }
        }
    },

    styles = {
        mp_m_freemode_01 = {
            genetics = {
                mother = 0, father = 0, resemblance = 0, skin = 0,
                eye_colour = 1, eye_opening = 0, eyebrow_height = 0, eyebrow_depth = 0,
                nose_width = 0, nose_peak_height = 0, nose_peak_length = 0, nose_bone_height = 0, nose_peak_lower = 0, nose_twist = 0,
                cheek_bone = 0, cheek_bone_sideways = 0, cheek_bone_width = 0,
                lip_thickness = 0,
                jaw_bone_width = 0, jaw_bone_shape = 0,
                chin_bone = 0, chin_bone_length = 0, chin_bone_shape = 0, chin_hole = 0,
                neck_thickness = 0
            },
            barber = {
                hair = -1, hair_colour = 0, highlight_colour = 0,
                fade = -1, fade_colour = 0,
                eyebrow = -1, eyebrow_opacity = 1.0, eyebrow_colour = 0,
                facial_hair = -1, facial_hair_opacity = 1.0, facial_hair_colour = 0,
                chest_hair = -1, chest_hair_opacity = 1.0, chest_hair_colour = 0,
                make_up = -1, make_up_opacity = 1.0, make_up_colour = 0,
                blush = -1, blush_opacity = 1.0, blush_colour = 0,
                lipstick = -1, lipstick_opacity = 1.0, lipstick_colour = 0,
                blemish = -1, blemish_opacity = 1.0,
                body_blemish = -1, body_blemish_opacity = 1.0,
                ageing = -1, ageing_opacity = 1.0,
                complexion = -1, complexion_opacity = 1.0,
                sun_damage = -1, sun_damage_opacity = 1.0,
                moles = -1, moles_opacity = 0
            },
            clothing = {
                mask_style = -1, mask_texture = 0,
                jacket_style = 15, jacket_texture = 0,
                shirt_style = 15, shirt_texture = 0,
                vest_style = -1, vest_texture = 0,
                legs_style = 21, legs_texture = 0,
                shoes_style = 34, shoes_texture = 0,
                hands_style = 15, hands_texture = 0,
                bag_style = -1, bag_texture = 0,
                decals_style = -1, decals_texture = 0,
                hats_style = -1, hats_texture = 0,
                glasses_style = -1, glasses_texture = 0,
                earwear_style = -1, earwear_texture = 0,
                watches_style = -1, watches_texture = 0,
                bracelets_style = -1, bracelets_texture = 0,
                neck_style = -1, neck_texture = 0
            },
            tattoos = {
                ZONE_HEAD = {}, ZONE_TORSO = {}, 
                ZONE_LEFT_ARM = {}, ZONE_RIGHT_ARM = {}, 
                ZONE_LEFT_LEG = {}, ZONE_RIGHT_LEG = {}
            }
        },
        
        mp_f_freemode_01 = {
            genetics = {
                mother = 0, father = 0, resemblance = 0, skin = 0,
                eye_colour = 1, eye_opening = 0, eyebrow_height = 0, eyebrow_depth = 0,
                nose_width = 0, nose_peak_height = 0, nose_peak_length = 0, nose_bone_height = 0, nose_peak_lower = 0, nose_twist = 0,
                cheek_bone = 0, cheek_bone_sideways = 0, cheek_bone_width = 0,
                lip_thickness = 0,
                jaw_bone_width = 0, jaw_bone_shape = 0,
                chin_bone = 0, chin_bone_length = 0, chin_bone_shape = 0, chin_hole = 0,
                neck_thickness = 0
            },
            barber = {
                hair = -1, hair_colour = 0, highlight_colour = 0,
                fade = -1, fade_colour = 0,
                eyebrow = -1, eyebrow_opacity = 1.0, eyebrow_colour = 0,
                facial_hair = -1, facial_hair_opacity = 1.0, facial_hair_colour = 0,
                chest_hair = -1, chest_hair_opacity = 1.0, chest_hair_colour = 0,
                make_up = -1, make_up_opacity = 1.0, make_up_colour = 0,
                blush = -1, blush_opacity = 1.0, blush_colour = 0,
                lipstick = -1, lipstick_opacity = 1.0, lipstick_colour = 0,
                blemish = -1, blemish_opacity = 1.0,
                body_blemish = -1, body_blemish_opacity = 1.0,
                ageing = -1, ageing_opacity = 1.0,
                complexion = -1, complexion_opacity = 1.0,
                sun_damage = -1, sun_damage_opacity = 1.0,
                moles = -1, moles_opacity = 0
            },
            clothing = {
                mask_style = -1, mask_texture = 0,
                jacket_style = -1, jacket_texture = 0,
                shirt_style = 10, shirt_texture = -1,
                vest_style = -1, vest_texture = 0,
                legs_style = 15, legs_texture = 0,
                shoes_style = 5, shoes_texture = 0,
                hands_style = 15, hands_texture = 0,
                bag_style = -1, bag_texture = 0,
                decals_style = -1, decals_texture = 0,
                hats_style = -1, hats_texture = 0,
                glasses_style = -1, glasses_texture = 0,
                earwear_style = -1, earwear_texture = 0,
                watches_style = -1, watches_texture = 0,
                bracelets_style = -1, bracelets_texture = 0,
                neck_style = -1, neck_texture = 0
            },
            tattoos = {
                ZONE_HEAD = {}, ZONE_TORSO = {}, 
                ZONE_LEFT_ARM = {}, ZONE_RIGHT_ARM = {}, 
                ZONE_LEFT_LEG = {}, ZONE_RIGHT_LEG = {}
            }
        }
    }
}