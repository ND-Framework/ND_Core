-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

if server_config.SonoranCAD_Enabled then
    local function OnPlayerConnecting(name, setKickReason, deferrals)
        local player = source
        local steamIdentifier
        local identifiers = GetPlayerIdentifiers(player)
        deferrals.defer()

        Citizen.Wait(0)

        deferrals.update(string.format("Hello %s. Your Steam ID is being checked.", name))

        for _, v in pairs(identifiers) do
            if string.find(v, "steam") then
                steamIdentifier = v
                break
            end
        end

        Citizen.Wait(0)

        if not steamIdentifier then
            deferrals.done("You are not connected to Steam.")
        else
            deferrals.done()
        end
    end

    AddEventHandler("playerConnecting", OnPlayerConnecting)
end

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

-- Using the IsRolePresent function from discord.lua to check if the player has the roles.
RegisterNetEvent("checkPerms")
AddEventHandler("checkPerms", function(role)
    local player = source
    local rolePermission = false
    for i = 1, #config.departments[role] do
        rolePermission = IsRolePresent(player, role, config.departments[role][i], "start")
        if rolePermission then
            print(rolePermission)
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
    local department = "CIV"
    if server_config.SonoranCAD_Enabled then
        local steam = string.gsub(GetPlayerIdentifierFromType("steam", player), "steam:", "")
        local info = {
            ["id"] = server_config.SonoranCAD_CommunityID,
            ["key"] = server_config.SonoranCAD_APIKey,
            ["type"] = "GET_CHARACTERS",
            ["data"] = {
                {
                    ["apiId"] = steam
                }
            }
        }

        PerformHttpRequest("https://api.sonorancad.com/civilian/get_characters", function(errorCode, resultData, resultHeaders)
            for k, v in pairs(json.decode(resultData)) do
                if v.sections[2].fields[6].value == "M" then
                    gender = "Male"
                else
                    gender = "Female"
                end
                exports.oxmysql:query("SELECT cash, bank, twt FROM characters WHERE license = ? AND character_id = ?", {GetPlayerIdentifierFromType("license", player), v.id}, function(result)
                    if result then
                        if result[1] and result[1].cash and result[1].bank then
                            cash = result[1].cash
                            bank = result[1].bank
                            twt = result[1].twt
                        else
                            cash = config.maxStartingCash
                            bank = config.maxStartingBank
                            twt = v.sections[2].fields[1].value .. " " .. v.sections[2].fields[2].value
                            exports.oxmysql:query("INSERT INTO characters (license, character_id, cash, bank, twt) VALUES (?, ?, ?, ?, ?)", {GetPlayerIdentifierFromType("license", player), v.id, cash, bank, twt})
                        end
                        characters[v.id] = {id = v.id, firstName = v.sections[2].fields[1].value, lastName = v.sections[2].fields[2].value, dob = v.sections[2].fields[4].value, gender = gender, twt = twt, department = "CIV", cash = cash, bank = bank}
                        TriggerClientEvent("returnCharacters", player, characters)
                    end
                end)
            end
        end, "POST", json.encode(info))
    else
        exports.oxmysql:query("SELECT * FROM characters WHERE license = ?", {GetPlayerIdentifierFromType("license", player)}, function(result)
            if result then
                for i = 1, #result do
                    temp = result[i]
                    characters[temp.character_id] = {id = temp.character_id, firstName = temp.first_name, lastName = temp.last_name, dob = temp.dob, gender = temp.gender, twt = temp.twt, department = temp.department, cash = temp.cash, bank = temp.bank}
                end
                TriggerClientEvent("returnCharacters", player, characters)
            end
        end)
    end
end)

-- Creating a new character and increasing the character id.
RegisterNetEvent("newCharacter")
AddEventHandler("newCharacter", function(newCharacter)
    local player = source
    local license = GetPlayerIdentifierFromType("license", player)

    if server_config.SonoranCAD_Enabled then
        local steam = string.gsub(GetPlayerIdentifierFromType("steam", player), "steam:", "")
        if newCharacter.gender == "Male" then
            newGender = "M"
        else
            newGender = "F"
        end

        local info = {
            ["id"] = server_config.SonoranCAD_CommunityID,
            ["key"] = server_config.SonoranCAD_APIKey,
            ["type"] = "NEW_CHARACTER",
            ["data"] = {
                {
                    ["user"] = steam,
                    ["useDictionary"] = true,
                    ["recordTypeId"] = 7,
                    ["replaceValues"] = {
                        ["first"] = newCharacter.firstName,
                        ["last"] = newCharacter.lastName,
                        ["dob"] = newCharacter.dateOfBirth,
                        ["sex"] = newGender
                    }
                }
            }
        }

        PerformHttpRequest("https://api.sonorancad.com/civilian/new_character", function(errorCode, resultData, resultHeaders)
            print("Returned error code: " .. tostring(errorCode))
            print("Returned data: " .. tostring(resultData))
            print("Returned result Headers: " .. tostring(resultHeaders))
        end, "POST", json.encode(info))

        TriggerClientEvent("refreshCharacters", player)
    else
        exports.oxmysql:query("SELECT character_id FROM characters WHERE license = ?", {GetPlayerIdentifierFromType("license", player)}, function(result)
            if (result) and (config.characterLimit > #result) then
                exports.oxmysql:query("SELECT MAX(character_id) AS nextID FROM characters WHERE license = ?", {license}, function(result)
                    if result then
                        character_id = result[1].nextID
                        if not character_id then
                            character_id = 1
                        else
                            character_id = character_id + 1
                        end
                        exports.oxmysql:query("INSERT INTO characters (license, character_id, first_name, last_name, dob, gender, twt, department, cash, bank) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", {license, character_id, newCharacter.firstName, newCharacter.lastName, newCharacter.dateOfBirth, newCharacter.gender, newCharacter.twtName, newCharacter.department, newCharacter.startingCash, newCharacter.startingBank}, function(id)
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
            end
        end)
    end
end)

-- Delete character from database.
RegisterNetEvent("delCharacter")
AddEventHandler("delCharacter", function(character_id)
    local player = source
    if server_config.SonoranCAD_Enabled then
        local info = {
            ["id"] = server_config.SonoranCAD_CommunityID,
            ["key"] = server_config.SonoranCAD_APIKey,
            ["type"] = "REMOVE_CHARACTER",
            ["data"] = {
                {
                    ["id"] = character_id,
                },
            }
        }
        PerformHttpRequest("https://api.sonorancad.com/civilian/remove_character", function(errorCode, resultData, resultHeaders)
            print("Returned error code: " .. tostring(errorCode))
            print("Returned data: " .. tostring(resultData))
            print("Returned result Headers: " .. tostring(resultHeaders))
        end, "POST", json.encode(info))
        exports.oxmysql:query("DELETE FROM characters WHERE license = ? AND character_id = ?", {GetPlayerIdentifierFromType("license", player), character_id})
    else
        exports.oxmysql:query("DELETE FROM characters WHERE license = ? AND character_id = ?", {GetPlayerIdentifierFromType("license", player), character_id})
    end
end)

-- Update the character info when edited.
RegisterNetEvent("editCharacter")
AddEventHandler("editCharacter", function(newCharacter)
    local player = source
    if server_config.SonoranCAD_Enabled then
        local steam = string.gsub(GetPlayerIdentifierFromType("steam", player), "steam:", "")
        if newCharacter.gender == "Male" then
            newGender = "M"
        else
            newGender = "F"
        end
        local info = {
            ["id"] = server_config.SonoranCAD_CommunityID,
            ["key"] = server_config.SonoranCAD_APIKey,
            ["type"] = "EDIT_CHARACTER",
            ["data"] = {
                {
                    ["user"] = steam,
                    ["useDictionary"] = true,
                    ["recordId"] = newCharacter.id,
                    ["replaceValues"] = {
                        ["first"] = newCharacter.firstName,
                        ["last"] = newCharacter.lastName,
                        ["dob"] = newCharacter.dateOfBirth,
                        ["sex"] = newGender
                    }
                }
            }
        }
        PerformHttpRequest("https://api.sonorancad.com/civilian/edit_character", function(errorCode, resultData, resultHeaders)
            print("Returned error code: " .. tostring(errorCode))
            print("Returned data: " .. tostring(resultData))
            print("Returned result Headers: " .. tostring(resultHeaders))
        end, "POST", json.encode(info))
    else
        exports.oxmysql:query("UPDATE characters SET first_name = ?, last_name = ?, dob = ?, gender = ?, twt = ?, department = ? WHERE license = ? AND character_id = ?", {newCharacter.firstName, newCharacter.lastName, newCharacter.dateOfBirth, newCharacter.gender, newCharacter.twtName, newCharacter.department, GetPlayerIdentifierFromType("license", player), newCharacter.id})
    end
end)

if config.enableMoneySystem then
    -- This is used to find out how much money the player has and use it in the client to show it on the ui.
    RegisterNetEvent("getMoney")
    AddEventHandler("getMoney", function(characterid)
        local player = source
        exports.oxmysql:query("SELECT cash, bank FROM characters WHERE license = ? AND character_id = ?", {GetPlayerIdentifierFromType("license", player), characterid}, function(result)
            if result then
                cash = result[1].cash
                bank = result[1].bank
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
    end)

    -- Give money command.
    RegisterCommand(config.giveCommand, function(source, args, raw)
        local player = source
        local amount = tonumber(args[1])

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
    end)

    -- Salary.
    local salaryInterval = config.salaryInterval * 60000
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(salaryInterval)
            for k, v in pairs(onlinePlayers) do
                exports.oxmysql:query("UPDATE characters SET bank = bank + ? WHERE license = ? AND character_id = ?", {config.salaryAmount, GetPlayerIdentifierFromType("license", k), v.characterId})
                TriggerClientEvent("receiveSalary", k, config.salaryAmount)
            end
        end
    end)
end

-- add a player to the table.
RegisterNetEvent("characterOnline")
AddEventHandler("characterOnline", function(id)
    local player = source
    local license = GetPlayerIdentifierFromType("license", player)

    if server_config.SonoranCAD_Enabled then
        local steam = string.gsub(GetPlayerIdentifierFromType("steam", player), "steam:", "")
        local info = {
            ["id"] = server_config.SonoranCAD_CommunityID,
            ["key"] = server_config.SonoranCAD_APIKey,
            ["type"] = "GET_CHARACTERS",
            ["data"] = {
                {
                    ["apiId"] = steam
                }
            }
        }
        PerformHttpRequest("https://api.sonorancad.com/civilian/get_characters", function(errorCode, resultData, resultHeaders)
            for k, v in pairs(json.decode(resultData)) do
                if v.sections[2].fields[6].value == "M" then
                    gender = "Male"
                else
                    gender = "Female"
                end
                exports.oxmysql:query("SELECT cash, bank, twt FROM characters WHERE license = ? AND character_id = ?", {GetPlayerIdentifierFromType("license", player), v.id}, function(result)
                    if result then
                        if result[1] and result[1].cash and result[1].bank then
                            cash = result[1].cash
                            bank = result[1].bank
                            twt = result[1].twt
                        else
                            cash = config.maxStartingCash
                            bank = config.maxStartingBank
                            twt = v.sections[2].fields[1].value .. " " .. v.sections[2].fields[2].value
                            exports.oxmysql:query("INSERT INTO characters (license, character_id, cash, bank, twt) VALUES (?, ?, ?, ?, ?)", {GetPlayerIdentifierFromType("license", player), v.id, cash, bank, twt})
                        end
                        if v.id == id then
                            onlinePlayers[player] = {
                                characterId = id,
                                firstName = v.sections[2].fields[1].value,
                                lastName = v.sections[2].fields[2].value,
                                dob = v.sections[2].fields[4].value,
                                gender = gender,
                                twt = twt,
                                dept = "CIV",
                                cash = cash,
                                bank = bank
                            }
                        end
                    end
                end)
            end
        end, "POST", json.encode(info))
    else
        exports.oxmysql:query("SELECT * FROM characters WHERE license = ? AND character_id = ?", {GetPlayerIdentifierFromType("license", player), id}, function(result)
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
    end
end)

-- Remove player from onlinePlayers table when they leave.
AddEventHandler("playerDropped", function(reason)
    local player = source
    onlinePlayers[player] = nil
end)

function getCharacterTable()
    return onlinePlayers
end
