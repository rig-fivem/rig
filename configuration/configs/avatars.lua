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

    locations = {
        default = {
            coords = vector4(153.14, -734.61, 250.15, 343.49),
            is_default = true,
        },
    },

    camera_positions = {
        face = { 
            offset = vector3(0.0, 0.55, 0.60),
            height_adjustment = 0,
            near_dof = 0.4,
            far_dof = 1.3
        },
        body = { 
            offset = vector3(0.0, 1.65, 0.15),
            height_adjustment = 0.35,
            near_dof = 0.7,
            far_dof = 1.9
        },
        legs = { 
            offset = vector3(0.0, 0.85, -0.50),
            height_adjustment = 0,
            ear_dof = 0.7,
            far_dof = 1.5
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
    },

}