-- For support join my discord: https://discord.gg/Z9Mxu72zZ6  

author "Andyyy#7666"
description "ND Framework Jailing"
version "2.1.0"

fx_version "cerulean"
game "gta5"
lua54 "yes"

files {
	"source/ui/index.html",
	"source/ui/script.js",
	"source/ui/style.css"
}
ui_page "source/ui/index.html"

shared_script "config_client.lua"
client_script "source/client.lua"
server_scripts {
    "config_server.lua",
    "source/server.lua"
}

dependency "ND_Core"