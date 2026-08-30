--- @module avatars
--- @file src/client/modules/avatars.lua
--- @description Client side handling for player avatar system.

--- @section Imports

local _data = require("src.shared.data.avatars")
local _cam = require("src.client.modules.camera")

--- @section Guard

if rawget(_G, "__client_avatars_module") then
    return _G.__client_avatars_module
end

--- @section Initialisation

local m = {}
_G.__client_avatars_module = m

--- @section Helpers

local function copy_table(t)
    local orig_type = type(t)
    local copy

    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, t, nil do
            copy[copy_table(orig_key)] = copy_table(orig_value)
        end
        setmetatable(copy, copy_table(getmetatable(t)))
    else
        copy = t
    end

    return copy
end

--- @section Variables

m.original_heading = nil
m.current_ped = "mp_m_freemode_01"
m.current_avatar_id = nil
m.appearance_ranges = nil
m.avatar_styles = copy_table(_data.styles or {})

--- @section Functions

function m.reset_avatar_style(ped_model)
    ped_model = ped_model or m.current_ped
    if _data.styles[ped_model] then
        m.avatar_styles[ped_model] = copy_table(_data.styles[ped_model])
    end
    return m.avatar_styles[ped_model]
end

function m.rotate_avatar(direction)
    if not direction then 
        log("error", "Function: appearance_rotate_ped failed. | Reason: Direction parameter is missing.") 
        return 
    end

    local player_ped = PlayerPedId()
    local current_heading = GetEntityHeading(player_ped)
    m.original_heading = m.original_heading or current_heading
    local rotations = {
        right = current_heading + 45,
        left = current_heading - 45,
        flip = current_heading + 180,
        reset = m.original_heading
    }

    local new_heading = rotations[direction]
    if not new_heading then 
        log("error", "Function: appearance_rotate_ped failed. | Reason: Invalid direction parameter - Use right, left, flip, reset.") 
        return 
    end

    if direction == "reset" then
        m.original_heading = nil
    end

    SetEntityHeading(player_ped, new_heading)
end

function m.apply_overlay(player, overlay, barber_data)
    local style = tonumber(barber_data[overlay.style]) or 0
    local opacity = (tonumber(barber_data[overlay.opacity]) or 0) / 100
    SetPedHeadOverlay(player, overlay.index, style, opacity)

    if overlay.colour then
        local colour = tonumber(barber_data[overlay.colour])
        if colour then
            SetPedHeadOverlayColor(player, overlay.index, 1, colour, colour)
        else
            log("error", "Invalid overlay colour for " .. overlay.style)
        end
    end
end

function m.apply_clothing(player, item, clothing_data)
    local style = tonumber(clothing_data[item.style]) or -1
    local texture = tonumber(clothing_data[item.texture]) or 0

    if style >= 0 then
        if item.is_prop then
            SetPedPropIndex(player, item.index, style, texture, true)
        else
            SetPedComponentVariation(player, item.index, style, texture, 0)
        end
    end
end

function m.apply_tattoos(player, tattoos, ped_model)
    if not tattoos then return end
    local is_male = (ped_model == "mp_m_freemode_01")

    for zone, zone_tattoos in pairs(tattoos) do
        if type(zone_tattoos) == "table" then
            for _, tattoo_info in ipairs(zone_tattoos) do
                if tattoo_info and tattoo_info.name and tattoo_info.name ~= "none" then
                    local hash_field = is_male and tattoo_info.hash_m or tattoo_info.hash_f
                    if not hash_field or hash_field == "" then
                        log("[DEBUG] Skipping invalid hash for tattoo:", tattoo_info.name)
                    else
                        local hash = GetHashKey(hash_field)
                        local collection_hash = GetHashKey(tattoo_info.collection)
                        if hash and collection_hash then
                            SetPedDecoration(player, collection_hash, hash)
                        else
                            log("[ERROR] Invalid hash or collection for tattoo:", json.encode(tattoo_info))
                        end
                    end
                end
            end
        end
    end
end

function m.set_avatar_appearance(player, data)
    if not player or not data then 
        log("error", "Function: set_avatar_appearance failed | Reason: Missing required parameters (player or data).") 
        return 
    end

    local genetics = data.genetics
    SetPedHeadBlendData(player, genetics.mother, genetics.father, nil, genetics.mother, genetics.father, nil, genetics.resemblance, genetics.skin, nil, true)
    SetPedEyeColor(player, genetics.eye_colour)

    local barber = data.barber
    SetPedComponentVariation(player, 2, barber.hair, 0, 0)
    SetPedHairColor(player, barber.hair_colour, barber.highlight_colour)

    for _, feature in ipairs(_data.constants.facial_features) do
        SetPedFaceFeature(player, feature.index, tonumber(genetics[feature.value]) or 0)
    end

    for _, overlay in ipairs(_data.constants.overlays) do
        m.apply_overlay(player, overlay, barber)
    end

    for _, item in ipairs(_data.constants.clothing) do
        m.apply_clothing(player, item, data.clothing)
    end

    ClearPedDecorations(player)
    m.apply_tattoos(player, data.tattoos, m.current_ped)
    log("info", "Ped appearance successfully updated.")
end

function m.set_avatar_model(player_id, player_ped, ped_model)
    if ped_model and ped_model ~= m.current_ped then
        m.current_ped = ped_model
    end

    local model = m.current_ped or "mp_m_freemode_01"
    local hash = GetHashKey(tostring(model))
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Wait(0)
        end
    end

    local valid = IsModelValid(hash)
    if not valid then
        return false, "Model is not valid."
    end
    SetPlayerModel(player_id, hash)

    Wait(200)

    player_ped = GetPlayerPed(player_id)
    SetModelAsNoLongerNeeded(hash)
    SetPedComponentVariation(player_ped, 0, 0, 0, 1)

    local p_style = m.avatar_styles[m.current_ped] or m.reset_avatar_style(m.current_ped)
    m.set_avatar_appearance(player_ped, p_style)
    return true, "Model set successfully."
end

function m.update_avatar_appearance(category, id, value)
    if not category or value == nil then
        log("error", "Function: update_avatar_appearance failed | Reason: Missing required parameters.")
        return
    end

    if category == "tattoos" and id and type(value) == "table" then
        m.avatar_styles[m.current_ped].tattoos = m.avatar_styles[m.current_ped].tattoos or {}
        m.avatar_styles[m.current_ped].tattoos[id] = value
        m.set_avatar_appearance(PlayerPedId(), m.avatar_styles[m.current_ped])
        return
    end

    if id == "resemblance" or id == "skin" then
        if value ~= -1 then
            value = value / 100
        end
    end

    if id and type(m.avatar_styles[m.current_ped][category][id]) == "table" then
        for k, _ in pairs(m.avatar_styles[m.current_ped][category][id]) do
            m.avatar_styles[m.current_ped][category][id][k] = value[k]
        end
    elseif id then
        m.avatar_styles[m.current_ped][category][id] = value
    else
        m.avatar_styles[m.current_ped][category] = value
    end

    m.set_avatar_appearance(PlayerPedId(), m.avatar_styles[m.current_ped])
end

function m.get_appearance_ranges()
    local ped = PlayerPedId()
    local style_data = m.avatar_styles[m.current_ped] or m.avatar_styles["mp_m_freemode_01"]
    local barber_data = style_data.barber or {}
    local clothing_data = style_data.clothing or {}

    local ranges = {
        mother = { min = -1, max = 21 },
        father = { min = -1, max = 21 },
        resemblance = { min = -1, max = 100 },
        skin = { min = -1, max = 100 },
        eye_colour = { min = -1, max = 31 },
        eye_opening = { min = -1, max = 20 },
        eyebrow_height = { min = -1, max = 20 },
        eyebrow_depth = { min = -1, max = 20 },
        nose_width = { min = -1, max = 20 },
        nose_peak_height = { min = -1, max = 20 },
        nose_peak_length = { min = -1, max = 20 },
        nose_bone_height = { min = -1, max = 20 },
        nose_peak_lower = { min = -1, max = 20 },
        nose_twist = { min = -1, max = 20 },
        cheek_bone = { min = -1, max = 20 },
        cheek_bone_sideways = { min = -1, max = 20 },
        cheek_bone_width = { min = -1, max = 20 },
        lip_thickness = { min = -1, max = 20 },
        jaw_bone_width = { min = -1, max = 20 },
        jaw_bone_shape = { min = -1, max = 20 },
        chin_bone = { min = -1, max = 20 },
        chin_bone_length = { min = -1, max = 20 },
        chin_bone_shape = { min = -1, max = 20 },
        chin_hole = { min = -1, max = 20 },
        neck_thickness = { min = -1, max = 20 },

        hair = { min = -1, max = GetNumberOfPedDrawableVariations(ped, 2) - 1 },
        hair_colour = { min = -1, max = 63 },
        fade = { min = -1, max = GetNumberOfPedTextureVariations(ped, 2, tonumber(barber_data.hair) or 0) - 1 },
        fade_colour = { min = -1, max = 63 }
    }

    for _, overlay in ipairs(_data.constants.overlays) do
        ranges[overlay.style] = { min = -1, max = GetPedHeadOverlayNum(overlay.index) - 1 }
        if overlay.opacity then
            ranges[overlay.opacity] = { min = -1, max = 100 }
        end
        if overlay.colour then
            ranges[overlay.colour] = { min = -1, max = 63 }
        end
    end

    for _, item in ipairs(_data.constants.clothing) do
        local max_drawable, max_texture = -1, -1
        local current_style = tonumber(clothing_data[item.style]) or 0

        if item.is_prop then
            max_drawable = GetNumberOfPedPropDrawableVariations(ped, item.index) - 1
            if current_style >= 0 then
                max_texture = GetNumberOfPedPropTextureVariations(ped, item.index, current_style) - 1
            end
        else
            max_drawable = GetNumberOfPedDrawableVariations(ped, item.index) - 1
            if current_style >= 0 then
                max_texture = GetNumberOfPedTextureVariations(ped, item.index, current_style) - 1
            end
        end

        ranges[item.style] = { min = -1, max = max_drawable }
        if item.texture then
            ranges[item.texture] = { min = -1, max = math.max(max_texture, 0) }
        end
    end

    m.appearance_ranges = ranges
    return ranges
end

function m.setup_avatar_creator(opts)
    if type(opts) ~= "table" then
        log("error", "Function: setup_avatar_creator failed | Reason: Missing options table.")
        return
    end

    local coords = opts.coords or opts.location
    local is_valid_coords = type(coords) == "vector4" or (type(coords) == "table" and coords.x and coords.y and coords.z)
    if not is_valid_coords then
        log("error", "Function: setup_avatar_creator failed | Reason: Valid coords required in opts.")
        return
    end

    local target_ped = opts.ped or m.current_ped

    if opts.style then
        m.avatar_styles[target_ped] = copy_table(opts.style)
    else
        m.reset_avatar_style(target_ped)
    end

    local player_id = PlayerId()
    local player_ped = PlayerPedId()
    local success, message = m.set_avatar_model(player_id, player_ped, target_ped)
    if not success then
        log("error", message)
        return
    end

    local model_hash = GetEntityModel(PlayerPedId())
    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(model_hash) and GetGameTimer() < timeout do
        Wait(0)
    end

    player_ped = PlayerPedId()

    timeout = GetGameTimer() + 5000
    while not DoesEntityExist(player_ped) and GetGameTimer() < timeout do
        Wait(0)
        player_ped = PlayerPedId()
    end

    FreezeEntityPosition(player_ped, false)
    local found, ground_z = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, false)
    local target_z = found and ground_z or coords.z

    SetEntityCoords(player_ped, coords.x, coords.y, target_z - 1.0, false, false, false, true)
    SetEntityHeading(player_ped, coords.w or coords.h or 0.0)

    timeout = GetGameTimer() + 2000
    while GetGameTimer() < timeout do
        local pos = GetEntityCoords(player_ped)
        if #(pos - vector3(coords.x, coords.y, target_z)) > 1.0 then
            break
        end
        Wait(0)
    end

    FreezeEntityPosition(player_ped, true)

    if opts.camera_offset then
        _cam.set_entity_cam({
            entity = player_ped,
            coords = opts.camera_offset,
            height_adjustment = opts.height_adjustment or 0.0
        })
    end

    SetNuiFocus(true, true)
    DisplayRadar(false)

    Wait(100)

    if IsScreenFadedOut() then DoScreenFadeIn(500) end
end

--- @section Exports

exports("setup_avatar_creator", m.setup_avatar_creator)
exports("exit_avatar_creator", function()
    _cam.destroy_cam()
    SetNuiFocus(false, false)
    DisplayRadar(true)
    
    local player_ped = PlayerPedId()
    FreezeEntityPosition(player_ped, false)
end)
exports("set_avatar_model", m.set_avatar_model)
exports("set_avatar_appearance", m.set_avatar_appearance)
exports("update_avatar_appearance", m.update_avatar_appearance)
exports("get_appearance_ranges", m.get_appearance_ranges)
exports("reset_avatar_style", m.reset_avatar_style)
exports("rotate_avatar", m.rotate_avatar)
exports("get_avatar_style", function(ped_model)
    ped_model = ped_model or m.current_ped
    return m.avatar_styles[ped_model]
end)
exports("get_current_avatar_ped", function()
    return m.current_ped
end)

return m

