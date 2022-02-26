-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

author "Andyyy#7666"
description "ND Framework Core"
version "1.2"

fx_version "cerulean"
game "gta5"
lua54 "yes"

files {
	"source/ui/index.html",
	"source/ui/js/jquery-3.6.0.min.js",
	"source/ui/js/listener.js",
	"source/ui/Logo.png",
	"source/ui/style.css",
}

ui_page "source/ui/index.html"

shared_script "config_client.lua"
server_scripts {
    "config_server.lua",
    "source/server/discord.lua",
    "source/server/main.lua",
    "source/server/commands.lua"
}
client_scripts {
    "source/client/main.lua",
    "source/client/commands.lua"
}

exports {
    "getCharacterInfo", -- exports["ND_Core"]:getCharacterInfo(infoType)
}
--[[
    Info types:

    1: First name
    2: Last name
    3: Date of birth
    4: Gender
    5: Twotter name
    6: Department
    7: Cash
    8: Bank
    9: character id
]]

server_exports {
    "getCharacterTable", -- exports["ND_Core"]:getCharacterTable()
}
--[[
    characterId
    firstName
    lastName
    dob
    gender
    twt
    dept
    cash
    bank

    Example:
    players = exports["ND_Core"]:getCharacterTable()
    print(players[3].bank) this will print the bank account balance of the player with id 3.
]]
