-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

author "Andyyy#7666"
description "ND Framework ATMs"
version "1.1"

fx_version "cerulean"
game "gta5"
lua54 "yes"

ui_page "source/ui/index.html"

files {
	"source/ui/index.html",
	"source/ui/js/jquery-3.6.0.min.js",
	"source/ui/js/listener.js",
	"source/ui/img/mazebank.png",
	"source/ui/style.css",
}

server_script "source/server.lua"
client_script "source/client.lua"
