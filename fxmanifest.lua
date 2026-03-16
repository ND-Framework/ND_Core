-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

author "Andyyy#7666"
description "ND Framework Core"
version "2.3.2"

fx_version "cerulean"
game "gta5"
lua54 "yes"

files {
    "init.lua",
    "compatibility/**/locale.lua",
    "locales/*.json",
    "ui/**"
}

ui_page "ui/index.html"

shared_script "@ox_lib/init.lua"
client_scripts {
    "client/main.lua",
    "shared/functions.lua",
    "client/peds.lua",
    "client/vehicle.lua",
    "client/functions.lua",
    "client/events.lua",
    "client/death.lua",
    "client/groupadmin.lua",
    "compatibility/**/client.lua"
}
server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/main.lua",
    "shared/functions.lua",
    "shared/items.lua",
    "server/player.lua",
    "server/vehicle.lua",
    "server/functions.lua",
    "server/groups.lua",
    "server/groupadmin.lua",
    "compatibility/**/server.lua",
    "server/commands.lua"
}

dependencies {
    "ox_lib",
    "oxmysql"
}

-- below were used with backwards compatibility but could interfere with resources checking if the resources are started.
-- provide "es_extended"
-- provide "qb-Core"
