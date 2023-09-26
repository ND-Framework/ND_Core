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
    "client/peds.lua",
    "client/vehicle/main.lua",
    "client/vehicle/garages.lua",
    "client/functions.lua",
    "client/events.lua",
    "client/death.lua",
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

files {
    "init.lua",
    "client/vehicle/data.lua"
}

dependency "oxmysql"
