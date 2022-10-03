-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

author "Andyyy#7666, N1K0#0001"
description "ND Framework Core"
version "3.1.3"

fx_version "cerulean"
game "gta5"
lua54 "yes"

shared_script "config_client.lua"
client_scripts {
    "client/**"
}
server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "config_server.lua",
    "server/**"
}

exports {
    "GetCoreObject"
}

server_exports {
    "GetCoreObject"
}

dependency "oxmysql"
