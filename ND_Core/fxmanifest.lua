------------------------------------------------------------------------
------------------------------------------------------------------------
--			DO NOT EDIT IF YOU DON'T KNOW WHAT YOU'RE DOING			  --
--     							 									  --
--	   For support join my discord: https://discord.gg/Z9Mxu72zZ6	  --
------------------------------------------------------------------------
------------------------------------------------------------------------

fx_version "cerulean"
game "gta5"
lua54 "yes"

author "Andyyy#7666"
description "ND Framework Core"
version "1.0"

files {
	"source/ui/index.html",
	"source/ui/js/jquery-3.6.0.min.js",
	"source/ui/js/listener.js",
	"source/ui/Logo.png",
	"source/ui/style.css",
}

ui_page "source/ui/index.html"

shared_script "config.lua"

server_scripts {
    "source/server/discord.lua",
    "source/server/main.lua",
    "source/server/commands.lua"
}
client_scripts {
    "source/client/main.lua",
    "source/client/commands.lua"
}

exports {
    "getCharacterInfo", -- getCharacterInfo(int), 1 will return return FirstName, 2 LastName, 3 DateOfBirth, 4 Gender, 5 TwtName, 6 Department, 7 Cash, 8 Bank. 9 will return their character id.
    "sendBank", -- sendBank(sendingCharacterId, receiveingPlayerId, amount, sendingPlayerId)
    "sendCash" -- sendCash(sendingCharacterId, amount, sendingPlayerId)
}