-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

author "Andyyy#7666"
description "ND-Core"
version "2.0.0"

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

exports {
    "getCharacterInfo",
}

server_exports {
    "transferBank", -- exports["ND_Core"]:transferBank(amount, player, target)
    "giveCashToClosestTarget", -- exports["ND_Core"]:giveCashToClosestTarget(amount, player)
    "withdrawMoney", -- exports["ND_Core"]:withdrawMoney(amount, player)
    "depositMoney", -- exports["ND_Core"]:depositMoney(amount, player)
    "deductMoney", -- exports["ND_Core"]:deductMoney(amount, player, from)
    "addMoney", -- exports["ND_Core"]:addMoney(amount, player, to)
    "getCharacterTable" -- exports["ND_Core"]:getCharacterTable() this will return a table with all the online players and their info. View below on how to use this.
}

dependency "oxmysql"

--[[
    Keys in the getCharacterTable:
    
    characterId
    firstName
    lastName
    dob
    gender
    twt
    dept
    cash
    bank

    Usage:
    players = exports["ND_Core"]:getCharacterTable()
    print(players[3].bank) this will print the bank account of the player with id 3.
]]