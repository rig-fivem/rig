--[[
----------------------------------------
RIG Framework (built for FiveM)

Author: Case (https://caseirl.dev)
Repo: https://github.com/rig-fivem/rig
License: https://github.com/rig-fivem/rig/blob/main/LICENSE
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

ui_page "ui/index.html"
files {
    "locales/*.json",
    "src/shared/data/*.json",
    "src/shared/data/*.lua",
    "ui/**/*",
}

shared_script "init.lua"

server_scripts {
    "src/server/modules/*.lua",
    "src/server/players/extensions/*.lua",
    "src/server/**/class.lua",
    "src/server/**/registry.lua",
    "src/server/gameplay.lua",
    "src/server/main.lua",

    "tests/server/*.lua"
}

client_scripts {
    "src/client/modules/*.lua",
    "src/client/**/class.lua",
    "src/client/**/events.lua",
    "src/client/gameplay.lua",
    "src/client/main.lua",

    "tests/client/*.lua"
}

dependency "oxmysql"
provide "rig"