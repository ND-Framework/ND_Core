-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

author "Andyyy#7666, N1K0#0001"
description "Shot Spotter Script (ND Framework)"
version "2.1.0"

fx_version "cerulean"
game "gta5"
lua54 "yes"

server_scripts {
    "config_server.lua",
    "source/server.lua"
}
client_scripts {
    "config_client.lua",
    "source/client.lua"
}

dependency "ND_Core"