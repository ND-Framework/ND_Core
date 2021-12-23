------------------------------------------------------------------------
------------------------------------------------------------------------
--			DO NOT EDIT IF YOU DON'T KNOW WHAT YOU'RE DOING			  --
--     							 									  --
--	   For support join my discord: https://discord.gg/Z9Mxu72zZ6	  --
------------------------------------------------------------------------
------------------------------------------------------------------------

RegisterNetEvent("checkPerms")
AddEventHandler("checkPerms", function(role)
    local player = source
    local role = role
    local rolePermission = IsRolePresent(player, role)
    TriggerClientEvent("permsChecked", player, role, rolePermission)
end)

RegisterNetEvent("exitGame")
AddEventHandler("exitGame", function(Player) 
    DropPlayer(Player, "Disconnected using framework.")
end)

RegisterNetEvent("getCharacters")
AddEventHandler("getCharacters", function()
    local player = source
    local license = GetPlayerIdentifier(player, 1)
    exports.oxmysql:execute("SELECT * FROM characters WHERE license = ?", {license}, function(result)
        if result then
            characters = {}
            for i = 1, #result do
                temp = result[i]
                table.insert(characters, {id = temp.character_id, firstName = temp.first_name, lastName = temp.last_name, dob = temp.dob, gender = temp.gender, twt = temp.twt, department = temp.department, cash = temp.cash, bank = temp.bank})
            end
            TriggerClientEvent("returnCharacters", player, characters)
        end
    end)
end)

RegisterNetEvent("newCharacter")
AddEventHandler("newCharacter", function(newCharacter)
    local player = source
    local license = GetPlayerIdentifier(player, 1)
    exports.oxmysql:execute("SELECT MAX(character_id) AS nextID FROM characters WHERE license LIKE ?", {license}, function(result)
        if result then
            character_id = result[1].nextID
            if character_id == nil then
                character_id = 1
            else
                character_id = character_id + 1
            end
            exports.oxmysql:execute("INSERT INTO characters (license, character_id, first_name, last_name, dob, gender, twt, department, cash, bank) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", {license, character_id, newCharacter.firstName, newCharacter.lastName, newCharacter.dateOfBirth, newCharacter.gender, newCharacter.twtName, newCharacter.department, newCharacter.startingCash, newCharacter.startingBank}, function(id)
                if id then
                    TriggerClientEvent("returnNewCharacter", player, id, newCharacter)
                end
            end)
        end
    end)
end)

RegisterNetEvent("delCharacter")
AddEventHandler("delCharacter", function(character_id)
    local player = source
    local license = GetPlayerIdentifier(player, 1)
    exports.oxmysql:execute("DELETE FROM characters WHERE license LIKE ? AND character_id LIKE ?", {license, character_id}, function(id)
        if id then
            print(id)
        end
    end)
end)

RegisterNetEvent("editCharacter")
AddEventHandler("editCharacter", function(newCharacter)
    local player = source
    local license = GetPlayerIdentifier(player, 1)
    exports.oxmysql:execute("UPDATE characters SET first_name = ?, last_name = ?, dob = ?, gender = ?, twt = ?, department = ? WHERE license = ? AND character_id = ?", {newCharacter.firstName, newCharacter.lastName, newCharacter.dateOfBirth, newCharacter.gender, newCharacter.twtName, newCharacter.department, license, newCharacter.id}, function(id)
        if id then
            print(id)
        end
    end)
end)

if config.shotSpotterEnabled then
    RegisterNetEvent("shotSpotterActive")
    AddEventHandler("shotSpotterActive", function(x, y, z, postal)
        TriggerClientEvent("shotSpotterReport", -1, x, y, z, postal)
    end)
end

RegisterNetEvent("bankPay")
AddEventHandler("bankPay", function(characterid, playerid, amount, playerSending, name)
    local player = source
    local license = GetPlayerIdentifier(player, 1)
    exports.oxmysql:execute("UPDATE characters SET bank = bank - ? WHERE license = ? AND character_id = ?", {amount, license, characterid}, function(bank)
        if bank then
            print(bank)
        end
    end)
    TriggerClientEvent("receiveBank", playerid, amount, playerSending, name)
    TriggerClientEvent("updateMoney", player)
end)

RegisterNetEvent("addBank")
AddEventHandler("addBank", function(amount, characterid)
    local player = source
    license = GetPlayerIdentifier(player, 1)
    exports.oxmysql:execute("UPDATE characters SET bank = bank + ? WHERE license = ? AND character_id = ?", {amount, license, characterid}, function(bank)
        if bank then
            print(bank)
        end
    end)
    TriggerClientEvent("updateMoney", player)
end)

RegisterNetEvent("cashPay")
AddEventHandler("cashPay", function(characterid, playerid, amount, playerSending, name)
    local player = source
    local license = GetPlayerIdentifier(player, 1)
    exports.oxmysql:execute("UPDATE characters SET cash = cash - ? WHERE license = ? AND character_id = ?", {amount, license, characterid}, function(cash)
        if cash then
            print(cash)
        end
    end)
    TriggerClientEvent("receiveCash", playerid, amount, playerSending, name)
    TriggerClientEvent("updateMoney", player)
end)

RegisterNetEvent("addCash")
AddEventHandler("addCash", function(amount, characterid)
    local player = source
    local license = GetPlayerIdentifier(player, 1)
    exports.oxmysql:execute("UPDATE characters SET cash = cash + ? WHERE license = ? AND character_id = ?", {amount, license, characterid}, function(cash)
        if cash then
            print(cash)
        end
    end)
    TriggerClientEvent("updateMoney", player)
end)

RegisterNetEvent("getMoney")
AddEventHandler("getMoney", function(characterid)
    local player = source
    local license = GetPlayerIdentifier(player, 1)
    exports.oxmysql:execute("SELECT cash, bank FROM characters WHERE license = ? AND character_id = ?", {license, characterid}, function(result)
        if result then
            for i = 1, #result do
                cash = result[i].cash
                bank = result[i].bank
                print(cash)
                print(bank)
            end
        end
    end)
    Citizen.Wait(300)
    TriggerClientEvent("returnMoney", player, cash, bank)
end)