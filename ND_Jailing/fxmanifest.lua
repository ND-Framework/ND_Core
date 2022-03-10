------------------------------------------------------------------------
------------------------------------------------------------------------
--			DO NOT EDIT IF YOU DON'T KNOW WHAT YOU'RE DOING			  --
--     							 									  --
--	   For support join my discord: https://discord.gg/Z9Mxu72zZ6	  --
------------------------------------------------------------------------
------------------------------------------------------------------------

version "1.0"
description "Jail tablet"
author "Andyyy#7666"

fx_version "cerulean"
game "gta5"
lua54 "yes"

escrow_ignore {
    "config_client.lua",
    "config_server.lua"
}

ui_page "source/ui/index.html"

files {
	"source/ui/index.html",
	"source/ui/js/jquery-3.6.0.min.js",
	"source/ui/js/listener.js",
	"source/ui/style.css"
}

server_scripts {
    "source/server.lua",
    "config_server.lua"
}
client_scripts {
    "source/client.lua",
    "config_client.lua"
}