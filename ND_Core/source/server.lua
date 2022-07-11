-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

expectedName = "ND_Core" -- This is the resource and is not suggested to be changed.
resource = GetCurrentResourceName()

-- check if resource is renamed
if resource ~= expectedName then
    print("^1[^4" .. expectedName .. "^1] WARNING^0")
    print("Change the resource name to ^4" .. expectedName .. " ^0or else it won't work!")
end

-- add dots to version.
function fixVersion(version)
    return string.sub(version, 1, 1) .. "." .. string.sub(version, 2, 2) .. "." .. string.sub(version, 3, 3)
end

-- check if resource version is up to date
PerformHttpRequest("https://raw.githubusercontent.com/Andyyy7666/ND_Framework/main/ND_Core/fxmanifest.lua", function(errorCode, resultData, resultHeaders)
    i, j = string.find(tostring(resultData), "version")
    resultData = string.sub(tostring(resultData), i, j + 12)
    resultData = string.gsub(resultData, "version \"", "")
    i, j = string.find(resultData, "\"")
    resultData = string.sub(resultData, 1, i - 1)
    local githubVersion = string.gsub(resultData, "%.", "")
    local fileVersion = string.gsub(GetResourceMetadata(expectedName, "version", 0), "%.", "")
    githubVersion = tonumber(githubVersion)
    fileVersion = tonumber(fileVersion)

    if githubVersion and fileVersion then
        if githubVersion > fileVersion then
            print("^1[^4" .. expectedName .. "^1] WARNING^0")
            print("^4" .. expectedName .. " ^0is outdated. Please update it from ^5https://github.com/Andyyy7666/ND_Framework ^0| Current Version: ^1" .. fixVersion(fileVersion) .. " ^0| New Version: ^2" .. fixVersion(githubVersion) .. " ^0|")
        elseif githubVersion < fileVersion then
            print("^1[^4" .. expectedName .. "^1] WARNING^0")
            print("^4" .. expectedName .. " ^0version number is higher than expected | Current Version: ^3" .. fixVersion(fileVersion) .. " ^0| Expected Version: ^2" .. fixVersion(githubVersion) .. " ^0|")
        else
            print("^4" .. expectedName .. " ^0is up to date | Current Version: ^2" .. fixVersion(fileVersion) .. " ^0|")
        end
    else
        print("^1[^4" .. expectedName .. "^1] WARNING^0")
        print("You may not have the latest version of ^4" .. expectedName .. "^0. A newer, improved version may be present at ^5https://github.com/Andyyy7666/ND_Framework^0")
    end
end)

-- Used to retrive the players discord server nickname, discord name and tag, and the roles.
function getUserDiscordInfo(discordUserId)
    local data
    PerformHttpRequest("https://discordapp.com/api/guilds/" .. server_config.guildId .. "/members/" .. discordUserId, function(errorCode, resultData, resultHeaders)
		if errorCode ~= 200 then
            return
        end
        local result = json.decode(resultData)
        local roles = {}
        for _, roleId in pairs(result.roles) do
            roles[roleId] = roleId
        end
        data = {
            nickname = result.nick,
            discordTag = tostring(result.user.username) .. "#" .. tostring(result.user.discriminator),
            roles = roles
        }
    end, "GET", "", {["Content-Type"] = "application/json", ["Authorization"] = "Bot " .. server_config.discordServerToken})
    while not data do
        Citizen.Wait(0)
    end
    return data
end

-- Get player any identifier, available types: steam, license, xbl, ip, discord, live.
function GetPlayerIdentifierFromType(type, source)
    local identifierCount = GetNumPlayerIdentifiers(source)
    for count = 0, identifierCount do
        local identifier = GetPlayerIdentifier(source, count)
        if identifier and string.find(identifier, type) then
            return identifier
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
    local departmentExists = config.departments[department]
    if departmentExists then
        local discordUserId = string.gsub(GetPlayerIdentifierFromType("discord", player), "discord:", "")
        local roles = getUserDiscordInfo(discordUserId).roles

        for _, roleId in pairs(departmentExists) do
            if roles[roleId] or roleId == 0 or roleId == "0" then
                return true
            end
        end
    end
    return false
end

RegisterNetEvent("checkPerms")
AddEventHandler("checkPerms", function()
    local player = source
    local discordUserId = string.gsub(GetPlayerIdentifierFromType("discord", player), "discord:", "")
    local allowedRoles = {}
    local roles = getUserDiscordInfo(discordUserId).roles

    for dept, roleTable in pairs(config.departments) do
        for _, roleId in pairs(roleTable) do
            if roles[roleId] or roleId == 0 or roleId == "0" then
                table.insert(allowedRoles, dept)
            end
        end
    end

    TriggerClientEvent("permsChecked", player, allowedRoles)
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

    if config.enableMoneySystem then
        -- Don't trust the client, validate maximum amounts.
        local moneyCheck = validateMoney(startingCash, startingBank)

        -- Set money to maximum amount in the config .
        -- Only triggers if the client is sending an amount that exceeds the maximum.
        if not moneyCheck then
            startingCash = config.maxStartingCash
            startingBank = config.maxStartingBank
        end
    end

    exports.oxmysql:query("SELECT character_id FROM characters WHERE license = ?", {GetPlayerIdentifierFromType("license", player)}, function(result)
        if (result) and (config.characterLimit > #result) then
            exports.oxmysql:query("INSERT INTO characters (license, first_name, last_name, dob, gender, twt, department, cash, bank) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", {license, newCharacter.firstName, newCharacter.lastName, newCharacter.dateOfBirth, newCharacter.gender, newCharacter.twtName, newCharacter.department, startingCash, startingBank}, function(id)
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

-- onlinePlayers table, this is used to store all the players current character info on the server.
onlinePlayers = {}

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

-- Disconnecting a player
RegisterNetEvent("exitGame")
AddEventHandler("exitGame", function()
    local player = source
    DropPlayer(player, "Disconnected using framework.")
end)

-- this is for the exports
function getCharacterTable()
    return onlinePlayers
end

function updateMoney(player)
    local player = tonumber(player)
    local license = GetPlayerIdentifierFromType("license", player)
    exports.oxmysql:query("SELECT cash, bank FROM characters WHERE license = ? AND character_id = ?", {license, onlinePlayers[player].characterId}, function(result)
        if result then
            local cash = result[1].cash
            local bank = result[1].bank
            onlinePlayers[player].cash = cash
            onlinePlayers[player].bank = bank
            TriggerClientEvent("updateMoney", player, cash, bank)
        end
    end)
end

function transferBank(amount, player, target)
    local amount = tonumber(amount)
    local player = tonumber(player)
    local target = tonumber(target)
    if player == target then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            args = {"Error", "You can't send money to yourself."}
        })
        return false
    elseif GetPlayerPing(target) == 0 then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            args = {"Error", "That player does not exist."}
        })
        return false
    elseif onlinePlayers[player].bank < amount then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            args = {"Error", "You don't have enough money."}
        })
        return false
    else
        exports.oxmysql:query("UPDATE characters SET bank = bank - ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", player), onlinePlayers[player].characterId})
        updateMoney(player)
        exports.oxmysql:query("UPDATE characters SET bank = bank + ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", target), onlinePlayers[target].characterId})
        updateMoney(target)

        TriggerClientEvent("chat:addMessage", player, {
            color = {0, 255, 0},
            args = {"Success", "You paid " .. onlinePlayers[target].firstName .. " " .. onlinePlayers[target].lastName .. " $" .. amount .. "."}
        })
        TriggerClientEvent("receiveBank", target, amount, onlinePlayers[player].firstName .. " " .. onlinePlayers[player].lastName, player)
        return true
    end
end

function giveCashToClosestTarget(amount, player)
    local amount = tonumber(amount)
    local player = tonumber(player)
    local playerFound = false
    local playerCoords = GetEntityCoords(GetPlayerPed(player))
    if onlinePlayers[player].cash < amount then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            args = {"Error", "You don't have enough money."}
        })
        return false
    else
        for targetId, targetInfo in pairs(onlinePlayers) do
            local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
            if (#(playerCoords - targetCoords) < 2.0) and (targetId ~= player) and not playerFound then
                exports.oxmysql:query("UPDATE characters SET cash = cash - ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", player), onlinePlayers[player].characterId})
                updateMoney(player)
                exports.oxmysql:query("UPDATE characters SET cash = cash + ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", targetId), tonumber(targetInfo.characterId)})
                updateMoney(targetId)
                playerFound = true
                TriggerClientEvent("chat:addMessage", player, {
                    color = {0, 255, 0},
                    args = {"Success", "You gave " .. onlinePlayers[targetId].firstName .. " " .. onlinePlayers[targetId].lastName .. " $" .. amount .. "."}
                })
                TriggerClientEvent("receiveCash", targetId, amount, onlinePlayers[player].firstName .. " " .. onlinePlayers[player].lastName, player)
                break
            end 
        end
        if not playerFound then
            TriggerClientEvent("chat:addMessage", player, {
                color = {255, 0, 0},
                args = {"Error", "No players nearby."}
            })
            return false
        end
        playerFound = false
        return true
    end
end

function withdrawMoney(amount, player)
    local amount = tonumber(amount)
    local player = tonumber(player)
    if onlinePlayers[player].bank >= amount then
        exports.oxmysql:query("UPDATE characters SET bank = bank - ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", player), onlinePlayers[player].characterId})
        exports.oxmysql:query("UPDATE characters SET cash = cash + ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", player), onlinePlayers[player].characterId})
        Citizen.Wait(500)
        updateMoney(player)
        return true
    end
    return false
end

function depositMoney(amount, player)
    local amount = tonumber(amount)
    local player = tonumber(player)
    if onlinePlayers[player].cash >= amount then
        exports.oxmysql:query("UPDATE characters SET cash = cash - ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", player), onlinePlayers[player].characterId})
        exports.oxmysql:query("UPDATE characters SET bank = bank + ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", player), onlinePlayers[player].characterId})
        Citizen.Wait(500)
        updateMoney(player)
        return true
    end
    return false
end

function deductMoney(amount, player, from)
    local amount = tonumber(amount)
    local player = tonumber(player)
    if from == "bank" then
        exports.oxmysql:query("UPDATE characters SET bank = bank - ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", player), onlinePlayers[player].characterId})
        Citizen.Wait(500)
        updateMoney(player)
    elseif from == "cash" then
        exports.oxmysql:query("UPDATE characters SET cash = cash - ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", player), onlinePlayers[player].characterId})
        Citizen.Wait(500)
        updateMoney(player)
    end
end

function addMoney(amount, player, to)
    local amount = tonumber(amount)
    local player = tonumber(player)
    if to == "bank" then
        exports.oxmysql:query("UPDATE characters SET bank = bank + ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", player), onlinePlayers[player].characterId})
        Citizen.Wait(500)
        updateMoney(player)
    elseif to == "cash" then
        exports.oxmysql:query("UPDATE characters SET cash = cash + ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", player), onlinePlayers[player].characterId})
        Citizen.Wait(500)
        updateMoney(player)
    end
end

-- paying command.
RegisterCommand(config.payCommand, function(source, args, raw)
    local player = source
    local target = tonumber(args[1])
    local amount = math.floor(tonumber(args[2]))
    transferBank(amount, player, target)
end)

-- Give money command.
RegisterCommand(config.giveCommand, function(source, args, raw)
    local player = source
    local amount = math.floor(tonumber(args[1]))
    giveCashToClosestTarget(amount, player)
end)
