--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
----------------------------------------
]]

--- @file init.lua
--- @description Main initialisation file.
--- Handles namepace, settings and some global functions.

--- @section Namespace

core = {}

core.resource_name = GetCurrentResourceName()
core.server = IsDuplicityVersion()
core.client = not IsDuplicityVersion()
core.releases_url = "https://api.github.com/repos/rig-fivem/rig-fivem/releases/latest"
core.cache = {}
core.locales = {}

core.metadata = {
    name = GetResourceMetadata(core.resource_name, "name", 0) or core.resource_name,
    description = GetResourceMetadata(core.resource_name, "description", 0) or "N/A",
    version = GetResourceMetadata(core.resource_name, "version", 0) or "1.0.0",
    author = GetResourceMetadata(core.resource_name, "author", 0) or "Unknown"
}

core.settings = {
    general = {
        debug = GetConvarBool("rig:general:debug", false),
        language = GetConvar("rig:general:language", "en"),
        small_console_splash = GetConvarBool("rig:general:small_console_splash", false),
        connection_messages = GetConvarBool("rig:general:connection_messages", true),
    },

    users = {
        unique_id_chars = GetConvarInt("rig:users:unique_id_chars", 6),
        username_prefix = GetConvar("rig:users:username_prefix", "player"),
    },

    gameplay = {
        player_tick_rate = GetConvarInt("rig:gameplay:player_tick_rate", 5000),
        player_save_interval = GetConvarInt("rig:gameplay:player_save_interval", 5),
        disable_dispatch = GetConvarBool("rig:gameplay:disable_dispatch", true),
        disable_police_scanner = GetConvarBool("rig:gameplay:disable_police_scanner", true),
        disable_garbage_trucks = GetConvarBool("rig:gameplay:disable_garbage_trucks", true),
        disable_random_cops = GetConvarBool("rig:gameplay:disable_random_cops", true),
        disable_wanted = GetConvarBool("rig:gameplay:disable_wanted", true),
        disable_weapon_autoreload = GetConvarBool("rig:gameplay:disable_weapon_autoreload", true),
        disable_weapon_autoswap = GetConvarBool("rig:gameplay:disable_weapon_autoswap", true),
        hide_ammo = GetConvarBool("rig:gameplay:hide_ammo", true),
        invalidate_idle_cam = GetConvarBool("rig:gameplay:invalidate_idle_cam", true),
        artificial_lights = GetConvarBool("rig:gameplay:artificial_lights", true),
        hide_hud_components = GetConvarBool("rig:gameplay:hide_hud_components", true),
        hud_components = GetConvar("rig:gameplay:hud_components", "1,2,3,4,5,6,7,8,9,13,19,20,21,22"),
        disable_controls = GetConvarBool("rig:gameplay:disable_controls", true),
        disabled_controls = GetConvar("rig:gameplay:disabled_controls", "37,157,158,160,161,256,257"),
    }
}

--- @section Global Functions

local function get_local_time()
    if core.server then return os.date("%Y-%m-%d %H:%M:%S") end
    if GetLocalTime then
        local y, m, d, h, min, s = GetLocalTime()
        return string.format("%04d-%02d-%02d %02d:%02d:%02d", y, m, d, h, min, s)
    end
    return "0000-00-00 00:00:00"
end

_G.get_local_time = get_local_time

local function log(level, message)
    if not core.settings.general.debug then return end
    local colours = { reset = "^7", debug = "^6", info = "^5", success = "^2", warn = "^3", error = "^8", critical = "^1", dev = "^9" }
    local clr = colours[level] or "^7"
    local time = get_local_time()
    print(("%s[%s] [%s] [%s]:^7 %s"):format(clr, time, core.metadata.name, level:upper(), message))
end

_G.log = log

local function locale(key, ...)
    local str = core.locales[key]
    if not str and type(key) == "string" then
        local v = core.locales
        for p in key:gmatch("[^%.]+") do v = v and v[p] end
        str = v
    end

    if type(str) == "string" then
        local ok, res = pcall(string.format, str, ...)
        return ok and res or str
    end

    return select("#", ...) > 0 and (tostring(key) .. " | " .. table.concat({...}, ", ")) or tostring(key)
end

_G.locale = locale

local function safe_require(key)
    if not key or type(key) ~= "string" then return nil end

    local path = key:gsub("%.lua$", ""):gsub("%.", "/") .. ".lua"
    local cache_key = ("%s:%s"):format(core.resource_name, path)
    if core.cache[cache_key] then 
        log("debug", ("Loaded module from cache: %s"):format(path))
        return core.cache[cache_key] 
    end

    local file_content = LoadResourceFile(core.resource_name, path)
    if not file_content then 
        log("warn", ("Module not found: %s"):format(path), true)
        return nil 
    end

    local env = setmetatable({}, { __index = _G })
    local chunk, err = load(file_content, ("@@%s/%s"):format(core.resource_name, path), "t", env)

    if not chunk then 
        log("error", ("Module compile error in %s: %s"):format(path, err), true)
        return nil 
    end

    local ok, res = pcall(chunk)
    if not ok then 
        log("error", ("Module runtime error in %s: %s"):format(path, res), true)
        return nil 
    end

    if type(res) ~= "table" then 
        log("error", ("Module %s did not return a table (got %s)"):format(path, type(res)), true)
        return nil 
    end

    core.cache[cache_key] = res
    log("success", ("Successfully loaded module: %s"):format(path))
    return res
end

_G.require = safe_require
exports("require", safe_require)

local function safe_require_json(key)
    if not key or type(key) ~= "string" then return nil end

    local path = key:gsub("%.json$", ""):gsub("%.", "/") .. ".json"
    local cache_key = ("%s:%s"):format(core.resource_name, path)
    if core.cache[cache_key] then 
        log("debug", ("Loaded JSON from cache: %s"):format(path))
        return core.cache[cache_key] 
    end

    local file_content = LoadResourceFile(core.resource_name, path)
    if not file_content then 
        log("warn", ("JSON file not found: %s"):format(path), true)
        return nil 
    end

    local ok, res = pcall(json.decode, file_content)
    if not ok or not res then 
        log("error", ("Failed to parse JSON file %s"):format(path), true)
        return nil 
    end

    core.cache[cache_key] = res
    log("success", ("Successfully loaded JSON: %s"):format(path))
    return res
end

_G.require_json = safe_require_json
exports("require_json", safe_require_json)

--- @section Setup Locales

local loaded_locales = require_json("locales." .. core.settings.general.language)
if loaded_locales then
    core.locales = loaded_locales
end

--- @section Console Splash & Version Check

if core.server then

    local function log_setting(key, value)
        local function format_value(v)
            if type(v) == "boolean" then return v and "^2true" or "^1false" end
            if type(v) == "number" and (v == 0 or v == 1) then return v == 1 and "^2true" or "^1false" end
            return "^2" .. tostring(v)
        end
        if type(value) == "table" then
            print("^7    " .. key .. ":")
            for k, v in pairs(value) do print("^7      " .. k .. ": " .. format_value(v)) end
        else
            print("^7    " .. key .. ": " .. format_value(value))
        end
    end

    local function render_startup(remote, current_ver)
        local separator = "^2---------------------------------------------------------------------^7"
        local is_mismatch = remote and remote.version and (tostring(remote.version) ~= tostring(current_ver))
        local ver_tag = not remote and ("^8[Unable to verify]^7") or is_mismatch and ("^3[v" .. remote.version .. " Available]^7") or ("^2[Up to date]^7")

        if core.settings.general.small_console_splash then
            print(separator)
            print(("^7[%s] ^2v%s^7 %s"):format(core.metadata.name, current_ver, ver_tag))
            if is_mismatch then
                print("^3Update available -- disable small_console_splash for full changelog details^7")
            end
            print(separator)
            return
        end

        print(separator)
        print("^2█████▄  ██  ▄████    ██     ██^7")
        print("^2██▄▄██▄ ██ ██  ▄▄▄   ██     ██^7")
        print("^2██   ██ ██  ▀███▀  ▄ ██████ ██^7")
        print(separator)
        print("^7Name: ^2" .. core.metadata.name .. "^7")
        print("^7Description: ^2" .. core.metadata.description .. "^7")
        print("^7Author: ^2" .. core.metadata.author .. "^7")
        print(("^7Version: %s %s"):format(is_mismatch and "^1v" .. current_ver or "^2v" .. current_ver, ver_tag))
        print("^7Language: ^2" .. (core.settings.general.language or "en") .. "^7")

        if is_mismatch then
            print(separator)
            print("^1[!] UPDATE AVAILABLE FOR RIG [!]^7")
            if remote.download then
                print("^7Download: ^5" .. remote.download .. "^7")
            end
            if type(remote.changelog) == "table" and #remote.changelog > 0 then
                print("^7Changelog:^7")
                for i = 1, #remote.changelog do
                    print("  ^3* " .. remote.changelog[i] .. "^7")
                end
            end
        end

        print(separator)
        print("^7Settings:^7")
        for key, value in pairs(core.settings) do
            log_setting(key, value)
        end
        print(separator)
    end

    local function check_release(current_ver)
        PerformHttpRequest(core.releases_url, function(status, body)
            if status ~= 200 then
                return render_startup(nil, current_ver)
            end

            local ok, release = pcall(json.decode, body or "")
            if not ok or type(release) ~= "table" or not release.tag_name then
                return render_startup(nil, current_ver)
            end

            local remote = {
                version = release.tag_name:gsub("^v", ""),
                download = release.html_url,
                changelog = {}
            }

            if type(release.body) == "string" and release.body ~= "" then
                for line in release.body:gmatch("[^\r\n]+") do
                    remote.changelog[#remote.changelog + 1] = line
                end
            end

            render_startup(remote, current_ver)
        end, "GET", "", { ["User-Agent"] = "RIG-VersionChecker" })
    end

    check_release(core.metadata.version)

end