-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

author "Andyyy#7666"
description "ND Framework Core"
version "2.0.0"

fx_version "cerulean"
game "gta5"
lua54 "yes"

client_scripts {
    "client/main.lua",
    "client/functions.lua",
    "client/events.lua",
}
server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/main.lua",
    "server/functions.lua",
    "server/player.lua"
}
shared_scripts {
    "init.lua"
}

dependency "oxmysql"
