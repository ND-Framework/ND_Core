-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

author "Andyyy#7666"
description "ND Framework Core"
version "2.0.0"

fx_version "cerulean"
game "gta5"
lua54 "yes"

shared_script "@ox_lib/init.lua"
client_scripts {
    "client/main.lua",
    "shared/functions.lua",
    "client/vehicle.lua",
    "client/functions.lua",
    "client/events.lua",
    "compatibility/**/client.lua"
}
server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/main.lua",
    "shared/functions.lua",
    "server/player.lua",
    "server/vehicle.lua",
    "server/functions.lua",
    "compatibility/**/server.lua",
    "server/commands.lua"
}

file "init.lua"

dependency "oxmysql"
