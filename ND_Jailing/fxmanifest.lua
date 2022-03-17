-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

version "1.2"
description "Jail tablet"
author "Andyyy#7666"

fx_version "cerulean"
game "gta5"
lua54 "yes"

ui_page "source/ui/index.html"

files {
	"source/ui/index.html",
	"source/ui/js/jquery-3.6.0.min.js",
	"source/ui/js/listener.js",
	"source/ui/style.css"
}

shared_script "config_client.lua"
server_scripts {
    "source/server.lua",
    "config_server.lua"
}
client_script "source/client.lua"
