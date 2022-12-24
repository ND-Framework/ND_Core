-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

author "Andyyy#7666, N1K0#0001"
description "ND Framework Core"
version "1.0.0"

fx_version "cerulean"
game "gta5"
lua54 "yes"

shared_scripts {
    "config_client.lua",
    "shared/main.lua"
}
client_scripts {
    "client/main.lua",
    "client/functions.lua",
    "client/events.lua",
    "shared/import.lua"
}
server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "config_server.lua",
    "server/main.lua",
    "server/functions.lua",
    "server/events.lua",
    "server/commands.lua",
    "shared/import.lua"
}

exports {
    "GetCoreObject"
}

server_exports {
    "GetCoreObject"
}

dependency "oxmysql"