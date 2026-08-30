--- @class Avatar
--- @file extensions/server/avatars/classes/player.lua
--- @description Player avatar extension class managing ped appearance and customization

--- @section Initialisation

local Avatar = {}
Avatar.__index = Avatar

--- @section Factory

function Avatar.new(player)
    local self = setmetatable({
        player = player
    }, Avatar)
    return self
end

--- @section Lifecycle Hooks

function Avatar:on_load()
    local unique_id = self.player.unique_id

    local row = exports.oxmysql:single_async("SELECT * FROM avatars WHERE unique_id = ?", { unique_id })

    if not row then
        log("info", ("[Avatar] No avatar record found for unique_id: %s. Creating default..."):format(unique_id))

        exports.oxmysql:insert_async([[
            INSERT INTO avatars (unique_id, ped, genetics, barber, clothing, tattoos, has_customised)
            VALUES (?, 'mp_m_freemode_01', '{}', '{}', '{}', '{}', 0)
        ]], { unique_id })

        row = {
            unique_id = unique_id,
            ped = "mp_m_freemode_01",
            genetics = {},
            barber = {},
            clothing = {},
            tattoos = {},
            has_customised = false
        }
    else
        row.genetics = type(row.genetics) == "string" and json.decode(row.genetics) or (row.genetics or {})
        row.barber = type(row.barber) == "string" and json.decode(row.barber) or (row.barber or {})
        row.clothing = type(row.clothing) == "string" and json.decode(row.clothing) or (row.clothing or {})
        row.tattoos = type(row.tattoos) == "string" and json.decode(row.tattoos) or (row.tattoos or {})
        row.has_customised = (row.has_customised == 1 or row.has_customised == true)
    end

    self.player:add_data("avatar", {
        ped = row.ped,
        genetics = row.genetics,
        barber = row.barber,
        clothing = row.clothing,
        tattoos = row.tattoos,
        has_customised = row.has_customised
    }, true)

    log("debug", ("[Avatar] Loaded avatar data for source %d (UID: %s)"):format(self.player.source, unique_id))
end

function Avatar:on_save()
    local data = self.player:get_data("avatar")
    if not data then return {} end

    return {
        {
            query = [[
                UPDATE avatars 
                SET ped = ?, genetics = ?, barber = ?, clothing = ?, tattoos = ?, has_customised = ? 
                WHERE unique_id = ?
            ]],
            values = {
                data.ped or "mp_m_freemode_01",
                json.encode(data.genetics or {}),
                json.encode(data.barber or {}),
                json.encode(data.clothing or {}),
                json.encode(data.tattoos or {}),
                data.has_customised and 1 or 0,
                self.player.unique_id
            }
        }
    }
end

--- @section Getters

function Avatar:get_data()
    return self.player:get_data("avatar")
end

function Avatar:get_ped()
    local data = self:get_data()
    return data and data.ped or "mp_m_freemode_01"
end

function Avatar:get_genetics()
    local data = self:get_data()
    return data and data.genetics or {}
end

function Avatar:get_barber()
    local data = self:get_data()
    return data and data.barber or {}
end

function Avatar:get_clothing()
    local data = self:get_data()
    return data and data.clothing or {}
end

function Avatar:get_tattoos()
    local data = self:get_data()
    return data and data.tattoos or {}
end

--- @section Validation

function Avatar:has_customised()
    local data = self:get_data()
    return data and (data.has_customised == true) or false
end

--- @section Setters

function Avatar:set_ped(ped)
    if type(ped) ~= "string" then return false end
    local data = self:get_data() or {}
    data.ped = ped
    return self.player:set_data("avatar", data, true)
end

function Avatar:set_genetics(genetics)
    if type(genetics) ~= "table" then return false end
    local data = self:get_data() or {}
    data.genetics = genetics
    return self.player:set_data("avatar", data, true)
end

function Avatar:set_barber(barber)
    if type(barber) ~= "table" then return false end
    local data = self:get_data() or {}
    data.barber = barber
    return self.player:set_data("avatar", data, true)
end

function Avatar:set_clothing(clothing)
    if type(clothing) ~= "table" then return false end
    local data = self:get_data() or {}
    data.clothing = clothing
    return self.player:set_data("avatar", data, true)
end

function Avatar:set_tattoos(tattoos)
    if type(tattoos) ~= "table" then return false end
    local data = self:get_data() or {}
    data.tattoos = tattoos
    return self.player:set_data("avatar", data, true)
end

function Avatar:set_has_customised(state)
    local data = self:get_data() or {}
    data.has_customised = (state == true)
    return self.player:set_data("avatar", data, true)
end

function Avatar:set_all(data)
    if type(data) ~= "table" then return false end
    return self.player:set_data("avatar", {
        ped = data.ped or self:get_ped(),
        genetics = data.genetics or self:get_genetics(),
        barber = data.barber or self:get_barber(),
        clothing = data.clothing or self:get_clothing(),
        tattoos = data.tattoos or self:get_tattoos(),
        has_customised = data.has_customised ~= nil and (data.has_customised == true) or self:has_customised()
    }, true)
end

return Avatar