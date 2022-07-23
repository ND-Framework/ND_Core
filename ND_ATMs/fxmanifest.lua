-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

author "Andyyy#7666, N1K0#0001"
description "ND Framework ATMs"
version "2.1.0"

fx_version "cerulean"
game "gta5"
lua54 "yes"

ui_page "source/ui/index.html"

files {
	"source/ui/index.html",
	"source/ui/script.js",
	"source/ui/style.css"
}

server_script "source/server.lua"
client_script "source/client.lua"

dependency "ND_Core"