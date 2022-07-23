-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

author "Andyyy#7666, N1K0#0001"
description "ND Framework Doorlocks for buildings"
version "2.1.0"

fx_version "cerulean"
game "gta5"
lua54 "yes"

client_scripts {
    "config.lua",
    "source/client.lua"
}
server_script "source/server.lua"

dependency "ND_Core"