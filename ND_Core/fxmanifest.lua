-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

author "Andyyy#7666"
description "ND Framework Core"
version "1.4"

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
    "getCharacterInfo", -- getCharacterInfo(infoType), 1 will return return FirstName, 2 LastName, 3 DateOfBirth, 4 Gender, 5 TwtName, 6 Department, 7 Cash, 8 Bank. 9 will return their character id.
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
