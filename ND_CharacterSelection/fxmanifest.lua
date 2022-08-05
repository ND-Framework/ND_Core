-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

author "Andyyy#7666, N1K0#0001"
description "ND Character Selection (DOJ Based)"
version "2.2.1"

fx_version "cerulean"
game "gta5"
lua54 "yes"

files {
	"source/ui/index.html",
	"source/ui/script.js",
	"source/ui/style.css"
}
ui_page "source/ui/index.html"

shared_script "config.lua"
server_script "source/server.lua"
client_script "source/client.lua"

dependencies {
	"ND_Core",
	-- "fivem-appearance" [TODO] to be implemented properly later
}
