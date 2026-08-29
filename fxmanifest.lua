--[[
----------------------------------------
RIG Framework (built for CFX Platforms)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-framework/rig-cfx
License: https://github.com/rig-framework/rig-cfx/blob/main/LICENSE
----------------------------------------
]]

fx_version "cerulean"
games { "gta5" }
name "rig"
version "0.1.0"
description "A purpose built survival framework built for FiveM."
license "Apache 2.0"
author "Case"
lua54 "yes"

files {
    "configuration/locales/*.json"
}

shared_scripts {
    "core/init.lua"
}

server_scripts {
    "core/server/modules/*.lua",

    "core/server/**/class.lua",
    "core/server/**/registry.lua",

    "core/server/main.lua",

    "tests/server/*.lua"
}

dependency "oxmysql"
provide "rig"