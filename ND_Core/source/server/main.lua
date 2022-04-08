-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

expectedName = "ND_Core" -- This is the resource and is not suggested to be changed.
resource = GetCurrentResourceName()

-- check if resource is renamed
if resource ~= expectedName then
    print("^1[^4" .. expectedName .. "^1] WARNING^0")
    print("Change the resource name to ^4" .. expectedName .. " ^0or else it won't work!")
end

-- check if resource version is up to date
PerformHttpRequest("https://raw.githubusercontent.com/Andyyy7666/ND_Framework/main/ND_Core/fxmanifest.lua", function(error, res, head)
    i, j = string.find(tostring(res), "version")
    res = string.sub(tostring(res), i, j + 6)
    res = string.gsub(res, "version ", "")
    res = string.gsub(res, '"', "")
    resp = tonumber(res)
    verFile = GetResourceMetadata(expectedName, "version", 0)
    
    if verFile then
        if tonumber(verFile) < resp then
            print("^1[^4" .. expectedName .. "^1] WARNING^0")
            print("^4" .. expectedName .. " ^0is outdated. Please update it from ^5https://github.com/Andyyy7666/ND_Framework ^0| Current Version: ^1" .. verFile .. " ^0| New Version: ^2" .. resp .. " ^0|")
        elseif tonumber(verFile) > tonumber(resp) then
            print("^1[^4" .. expectedName .. "^1] WARNING^0")
            print("^4" .. expectedName .. "s ^0version number is higher than we expected. | Current Version: ^3" .. verFile .. " ^0| Expected Version: ^2" .. resp .. " ^0|")
        else
            print("^4" .. expectedName .. " ^0is up to date | Current Version: ^2" .. verFile .. " ^0|")
        end
    else
        print("^1[^4" .. expectedName .. "^1] WARNING^0")
        print("You may not have the latest version of ^4" .. expectedName .. "^0. A newer, improved version may be present at ^5https://github.com/Andyyy7666/ND_Framework^0")
    end
end)

-- onlinePlayers table.
onlinePlayers = {}

-- Get player identifier function (This will not change the identifier all the time)
function GetPlayerIdentifierFromType(type, source) -- Credits: xander1998, Post: https://forum.cfx.re/t/solved-is-there-a-better-way-to-get-lic-steam-and-ip-than-getplayeridentifiers/236243/2?u=andyyy7666
	local identifiers = {}
	local identifierCount = GetNumPlayerIdentifiers(source)

	for a = 0, identifierCount do
		table.insert(identifiers, GetPlayerIdentifier(source, a))
	end

	for b = 1, #identifiers do
		if string.find(identifiers[b], type, 1) then
			return identifiers[b]
		end
	end
	return nil
end

function validateMoney(cash, bank) 
    if tonumber(cash) > config.maxStartingCash or tonumber(bank) > config.maxStartingBank then
        return false
    end
    return true
end

function validateDepartment(player, department)
    local rolePermission = false
    local departmentExists = config.departments[department]
    if departmentExists then
        for i = 1, #departmentExists do
            rolePermission = IsRolePresent(player, department, departmentExists[i], "start")
            if rolePermission then
                return true
            end
        end
    end
    return false
end

-- Using the IsRolePresent function from discord.lua to check if the player has the roles.
RegisterNetEvent("checkPerms")
AddEventHandler("checkPerms", function(role)
    local player = source
    local rolePermission = false
    for i = 1, #config.departments[role] do
        rolePermission = IsRolePresent(player, role, config.departments[role][i], "start")
        if rolePermission then
            break
        end
    end
    TriggerClientEvent("permsChecked", player, role, rolePermission)
end)

-- Disconnecting a player
RegisterNetEvent("exitGame")
AddEventHandler("exitGame", function()
    local player = source
    DropPlayer(player, "Disconnected using framework.")
end)

-- Inserting the players characters into characters table
RegisterNetEvent("getCharacters")
AddEventHandler("getCharacters", function()
    local player = source
    local characters = {}
    exports.oxmysql:query("SELECT * FROM characters WHERE license = ?", {GetPlayerIdentifierFromType("license", player)}, function(result)
        if result then
            for i = 1, #result do
                temp = result[i]
                characters[temp.character_id] = {id = temp.character_id, firstName = temp.first_name, lastName = temp.last_name, dob = temp.dob, gender = temp.gender, twt = temp.twt, department = temp.department, cash = temp.cash, bank = temp.bank}
            end
            TriggerClientEvent("returnCharacters", player, characters)
        end
    end)
end)

-- Creating a new character and increasing the character id.
RegisterNetEvent("newCharacter")
AddEventHandler("newCharacter", function(newCharacter)
    local player = source
    local license = GetPlayerIdentifierFromType("license", player)

    -- validate that the person has permission to use the department.
    local departmentCheck = validateDepartment(player, newCharacter.department)
    if not departmentCheck then return end

    local startingCash = newCharacter.startingCash
    local startingBank = newCharacter.startingBank
    -- Don't trust the client, validate maximum amounts.
    local moneyCheck = validateMoney(startingCash, startingBank)

    -- Set money to maximum amount in the config .
    -- Only triggers if the client is sending an amount that exceeds the maximum.
    if not moneyCheck then
        startingCash = config.maxStartingCash
        startingBank = config.maxStartingBank
    end

    exports.oxmysql:query("SELECT character_id FROM characters WHERE license = ?", {GetPlayerIdentifierFromType("license", player)}, function(result)
        if (result) and (config.characterLimit > #result) then
            exports.oxmysql:query("INSERT INTO characters (license, character_id, first_name, last_name, dob, gender, twt, department, cash, bank) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", {license, character_id, newCharacter.firstName, newCharacter.lastName, newCharacter.dateOfBirth, newCharacter.gender, newCharacter.twtName, newCharacter.department, startingCash, startingBank}, function(id)
                if id then
                    exports.oxmysql:query("SELECT * FROM characters WHERE license = ?", {GetPlayerIdentifierFromType("license", player)}, function(result)
                        if result then
                            characters = {}
                            for i = 1, #result do
                                temp = result[i]
                                characters[temp.character_id] = {id = temp.character_id, firstName = temp.first_name, lastName = temp.last_name, dob = temp.dob, gender = temp.gender, twt = temp.twt, department = temp.department, cash = temp.cash, bank = temp.bank}
                            end
                            TriggerClientEvent("returnCharacters", player, characters)
                        end
                    end)
                end
            end)
        end
    end)
end)

-- Delete character from database.
RegisterNetEvent("delCharacter")
AddEventHandler("delCharacter", function(character_id)
    local player = source
    local license = GetPlayerIdentifierFromType("license", player)
    exports.oxmysql:query("DELETE FROM characters WHERE license = ? AND character_id = ?", {license, character_id})
end)

-- Update the character info when edited.
RegisterNetEvent("editCharacter")
AddEventHandler("editCharacter", function(newCharacter)
    local player = source

    -- validate that the person has permission to use the department.
    local departmentCheck = validateDepartment(player, newCharacter.department)
    if not departmentCheck then return end
    
    exports.oxmysql:query("UPDATE characters SET first_name = ?, last_name = ?, dob = ?, gender = ?, twt = ?, department = ? WHERE license = ? AND character_id = ?", {newCharacter.firstName, newCharacter.lastName, newCharacter.dateOfBirth, newCharacter.gender, newCharacter.twtName, newCharacter.department, GetPlayerIdentifierFromType("license", player), newCharacter.id})
end)

if config.enableMoneySystem then
    -- This is used to find out how much money the player has and use it in the client to show it on the ui.
    RegisterNetEvent("getMoney")
    AddEventHandler("getMoney", function(characterid)
        local player = source
        local license = GetPlayerIdentifierFromType("license", player)
        exports.oxmysql:query("SELECT cash, bank FROM characters WHERE license = ? AND character_id = ?", {license, characterid}, function(result)
            if result then
                local cash = result[1].cash
                local bank = result[1].bank
                onlinePlayers[player].cash = cash
                onlinePlayers[player].bank = bank
                TriggerClientEvent("returnMoney", player, cash, bank)
            end
        end)
    end)

    -- paying command.
    RegisterCommand(config.payCommand, function(source, args, raw)
        local player = source
        local target = tonumber(args[1])
        local amount = tonumber(args[2])
        transferBank(amount, player, target)
    end)

    -- Give money command.
    RegisterCommand(config.giveCommand, function(source, args, raw)
        local player = source
        local amount = tonumber(args[1])
        giveCashToClosestTarget(amount, player)
    end)

    -- Salary.
    local salaryInterval = config.salaryInterval * 60000
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(salaryInterval)
            for playerid, playerinfo in pairs(onlinePlayers) do
                local license = GetPlayerIdentifierFromType("license", playerid)
                exports.oxmysql:query("UPDATE characters SET bank = bank + ? WHERE license = ? AND character_id = ?", {config.salaryAmount, license, playerinfo.characterId})
                TriggerClientEvent("receiveSalary", playerid, config.salaryAmount)
            end
        end
    end)
end

-- add a player to the table.
RegisterNetEvent("characterOnline")
AddEventHandler("characterOnline", function(id)
    local player = source
    local license = GetPlayerIdentifierFromType("license", player)
    exports.oxmysql:query("SELECT * FROM characters WHERE license = ? AND character_id = ?", {license, id}, function(result)
        if result then
            local i = result[1]
            onlinePlayers[player] = {
                characterId = id,
                firstName = i.first_name,
                lastName = i.last_name,
                dob = i.dob,
                gender = i.gender,
                twt = i.twt,
                dept = i.department,
                cash = i.cash,
                bank = i.bank
            }
        end
    end)
end)

-- Remove player from onlinePlayers table when they leave.
AddEventHandler("playerDropped", function(reason)
    local player = source
    onlinePlayers[player] = nil
end)

function getCharacterTable()
    return onlinePlayers
end

function transferBank(amount, player, target)
    exports.oxmysql:query("SELECT bank FROM characters WHERE license = ? AND character_id = ?", {GetPlayerIdentifierFromType("license", player), onlinePlayers[player].characterId}, function(result)
        if result then
            if player == target then
                TriggerClientEvent("chat:addMessage", player, {
                    color = {255, 0, 0},
                    args = {"Error", "You can't send money to yourself."}
                })
            elseif GetPlayerPing(target) == 0 then
                TriggerClientEvent("chat:addMessage", player, {
                    color = {255, 0, 0},
                    args = {"Error", "That player does not exist."}
                })
            elseif result[1].bank < amount then
                TriggerClientEvent("chat:addMessage", player, {
                    color = {255, 0, 0},
                    args = {"Error", "You don't have enough money."}
                })
            else
                exports.oxmysql:query("UPDATE characters SET bank = bank - ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", player), onlinePlayers[player].characterId})
                TriggerClientEvent("updateMoney", player)
                exports.oxmysql:query("UPDATE characters SET bank = bank + ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", target), onlinePlayers[target].characterId})
                TriggerClientEvent("updateMoney", target)

                TriggerClientEvent("chat:addMessage", player, {
                    color = {0, 255, 0},
                    args = {"Success", "You paid " .. onlinePlayers[target].firstName .. " " .. onlinePlayers[target].lastName .. " $" .. amount .. "."}
                })
                TriggerClientEvent("receiveBank", target, amount, onlinePlayers[player].firstName .. " " .. onlinePlayers[player].lastName, player)
            end
        end
    end)
end

function giveCashToClosestTarget(amount, player)
    exports.oxmysql:query("SELECT cash FROM characters WHERE license = ? AND character_id = ?", {GetPlayerIdentifierFromType("license", player), onlinePlayers[player].characterId}, function(result)
        if result then
            local playerFound = false
            local playerCoords = GetEntityCoords(GetPlayerPed(player))
            if result[1].cash < amount then
                TriggerClientEvent("chat:addMessage", player, {
                    color = {255, 0, 0},
                    args = {"Error", "You don't have enough money."}
                })
            else
                for k, v in pairs(onlinePlayers) do
                    local targetCoords = GetEntityCoords(GetPlayerPed(k))
                    if (#(playerCoords - targetCoords) < 2.0) and (k ~= player) and not playerFound then
                        exports.oxmysql:query("UPDATE characters SET cash = cash - ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", player), onlinePlayers[player].characterId})
                        TriggerClientEvent("updateMoney", player)
                        exports.oxmysql:query("UPDATE characters SET cash = cash + ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", k), tonumber(v.characterId)})
                        TriggerClientEvent("updateMoney", k)
                        playerFound = true
                        TriggerClientEvent("chat:addMessage", player, {
                            color = {0, 255, 0},
                            args = {"Success", "You gave " .. onlinePlayers[k].firstName .. " " .. onlinePlayers[k].lastName .. " $" .. amount .. "."}
                        })
                        TriggerClientEvent("receiveCash", k, amount, onlinePlayers[player].firstName .. " " .. onlinePlayers[player].lastName, player)
                        break
                    end 
                end
                if not playerFound then
                    TriggerClientEvent("chat:addMessage", player, {
                        color = {255, 0, 0},
                        args = {"Error", "No players nearby."}
                    })
                end
                playerFound = false
            end
        end
    end)
end

function withdrawMoney(amount, player)
    exports.oxmysql:query("UPDATE characters SET bank = bank - ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", player), onlinePlayers[player].characterId})
    exports.oxmysql:query("UPDATE characters SET cash = cash + ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", player), onlinePlayers[player].characterId})
    TriggerClientEvent("updateMoney", player)
end

function depositMoney(amount, player)
    exports.oxmysql:query("UPDATE characters SET cash = cash - ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", player), onlinePlayers[player].characterId})
    exports.oxmysql:query("UPDATE characters SET bank = bank + ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", player), onlinePlayers[player].characterId})
    TriggerClientEvent("updateMoney", player)
end

function deductMoney(amount, player, from)
    if from == "bank" then
        exports.oxmysql:query("UPDATE characters SET bank = bank - ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", player), onlinePlayers[player].characterId})
        TriggerClientEvent("updateMoney", player)
    elseif from == "cash" then
        exports.oxmysql:query("UPDATE characters SET cash = cash - ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", player), onlinePlayers[player].characterId})
        TriggerClientEvent("updateMoney", player)
    end
end

function addMoney(amount, player, to)
    if to == "bank" then
        exports.oxmysql:query("UPDATE characters SET bank = bank + ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", player), onlinePlayers[player].characterId})
        TriggerClientEvent("updateMoney", player)
    elseif to == "cash" then
        exports.oxmysql:query("UPDATE characters SET cash = cash + ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", player), onlinePlayers[player].characterId})
        TriggerClientEvent("updateMoney", player)
    end
end
