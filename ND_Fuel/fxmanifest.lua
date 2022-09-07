-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

author "Andyyy#7666, N1K0#0001"
description "ND Framework fuel with hose & nozle"
version "1.0.1"

fx_version "cerulean"
game "gta5"
lua54 "yes"

files {
    "source/digital-counter-7.ttf",
	"source/index.html"
}
ui_page "source/index.html"

shared_script "config.lua"
server_scripts {
    "source/server.lua"
}
client_scripts {
    "source/client.lua"
}
