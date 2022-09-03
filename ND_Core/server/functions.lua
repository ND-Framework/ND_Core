-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

-- Callback to update each selected character on the server.
function NDCore.Functions.GetPlayers(players)
    if not cb then return NDCore.Players end
    cb(NDCore.Players)
end

local discordErrors = {
    [400] = "improper http request",
    [401] = "Discord bot token might be missing or incorrect",
    [404] = "user might not be in server.",
    [429] = "Discord bot rate limited."
}
-- Used to retrive the players discord server nickname, discord name and tag, and the roles.
function NDCore.Functions.GetUserDiscordInfo(discordUserId)
    local data
    local timeout = 0
    PerformHttpRequest("https://discordapp.com/api/guilds/" .. server_config.guildId .. "/members/" .. discordUserId, function(errorCode, resultData, resultHeaders)
        if errorCode ~= 200 then
            print("Error: " .. errorCode .. " " .. discordErrors[errorCode])
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
        Wait(1000)
        timeout = timeout + 1
        if timeout > 5 then
            break
        end
    end
    return data
end

-- Get player any identifier, available types: steam, license, xbl, ip, discord, live.
function NDCore.Functions.GetPlayerIdentifierFromType(type, player)
    local identifierCount = GetNumPlayerIdentifiers(player)
    for count = 0, identifierCount do
        local identifier = GetPlayerIdentifier(player, count)
        if identifier and string.find(identifier, type) then
            return identifier
        end
    end
    return nil
end

-- This will return the server id and ND player data of a nearby player.
function NDCore.Functions.GetNearbyPedToPlayer(player)
    local pedCoords = GetEntityCoords(GetPlayerPed(player))
    for targetId, targetInfo in pairs(NDCore.Players) do
        local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
        if #(pedCoords - targetCoords) < 2.0 and targetId ~= player then
            return targetId, targetInfo
        end
    end 
end

-- update the players money on the client kinda like a refresh.
function NDCore.Functions.UpdateMoney(player)
    local player = tonumber(player)
    MySQL.query("SELECT cash, bank FROM characters WHERE character_id = ? LIMIT 1", {NDCore.Players[player].id}, function(result)
        if result then
            local cash = result[1].cash
            local bank = result[1].bank
            NDCore.Players[player].cash = cash
            NDCore.Players[player].bank = bank
            TriggerClientEvent("ND:updateMoney", player, cash, bank)
        end
    end)
end

-- Transfer money from one players bank account to another.
function NDCore.Functions.TransferBank(amount, player, target)
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
    elseif amount <= 0 then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            args = {"Error", "You can't send that amount."}
        })
        return false
    elseif NDCore.Players[player].bank < amount then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            args = {"Error", "You don't have enough money."}
        })
        return false
    else
        MySQL.query.await("UPDATE characters SET bank = bank - ? WHERE character_id = ? LIMIT 1", {amount, NDCore.Players[player].id})
        NDCore.Functions.UpdateMoney(player)
        MySQL.query.await("UPDATE characters SET bank = bank + ? WHERE character_id = ? LIMIT 1", {amount, NDCore.Players[target].id})
        NDCore.Functions.UpdateMoney(target)
        TriggerClientEvent("chat:addMessage", player, {
            color = {0, 255, 0},
            args = {"Success", "You paid " .. NDCore.Players[target].firstName .. " " .. NDCore.Players[target].lastName .. " $" .. amount .. "."}
        })
        TriggerClientEvent("chat:addMessage", target, {
            color = {0, 255, 0},
            args = {"Success", NDCore.Players[player].firstName .. " " .. NDCore.Players[player].lastName .. " sent you $" .. amount .. "."}
        })
        return true
    end
end

-- Give cash from one players wallet to another.
function NDCore.Functions.GiveCash(amount, player, target)
    local amount = tonumber(amount)
    local player = tonumber(player)
    local target = tonumber(target)
    if player == target then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            args = {"Error", "You can't give money to yourself."}
        })
        return false
    elseif GetPlayerPing(target) == 0 then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            args = {"Error", "That player does not exist."}
        })
        return false
    elseif amount <= 0 then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            args = {"Error", "You can't give that amount."}
        })
        return false
    elseif NDCore.Players[player].cash < amount then
        TriggerClientEvent("chat:addMessage", player, {
            color = {255, 0, 0},
            args = {"Error", "You don't have enough money."}
        })
        return false
    else
        MySQL.query.await("UPDATE characters SET cash = cash - ? WHERE character_id = ? LIMIT 1", {amount, NDCore.Players[player].id})
        NDCore.Functions.UpdateMoney(player)
        MySQL.query.await("UPDATE characters SET cash = cash + ? WHERE character_id = ? LIMIT 1", {amount, NDCore.Players[target].id})
        NDCore.Functions.UpdateMoney(target)
        TriggerClientEvent("chat:addMessage", player, {
            color = {0, 255, 0},
            args = {"Success", "You gave $" .. amount .. "."}
        })
        TriggerClientEvent("chat:addMessage", target, {
            color = {0, 255, 0},
            args = {"Success", " Received $" .. amount .. "."}
        })
        return true
    end
end

-- Give money from a players wallet to a nearby player.
function NDCore.Functions.GiveCashToNearbyPlayer(player, amount)
    local targetId = NDCore.Functions.GetNearbyPedToPlayer(player)
    if targetId then
        NDCore.Functions.GiveCash(amount, player, targetId)
        return true
    end
    TriggerClientEvent("chat:addMessage", player, {
        color = {255, 0, 0},
        args = {"Error", "No players nearby."}
    })
    return false
end

-- withdraws money from a players bank account to their wallet/cash.
function NDCore.Functions.WithdrawMoney(amount, player)
    local amount = tonumber(amount)
    local player = tonumber(player)
    if amount <= 0 then return false end
    if NDCore.Players[player].bank < amount then return false end
    MySQL.query.await("UPDATE characters SET bank = bank - ? WHERE character_id = ? LIMIT 1", {amount, NDCore.Players[player].id})
    MySQL.query.await("UPDATE characters SET cash = cash + ? WHERE character_id = ? LIMIT 1", {amount, NDCore.Players[player].id})
    NDCore.Functions.UpdateMoney(player)
    return true
end

-- deposits money from a players wallet/cash to their bank account.
function NDCore.Functions.DepositMoney(amount, player)
    local amount = tonumber(amount)
    local player = tonumber(player)
    if amount <= 0 then return false end
    if NDCore.Players[player].cash < amount then return false end
    MySQL.query.await("UPDATE characters SET cash = cash - ? WHERE character_id = ? LIMIT 1", {amount, NDCore.Players[player].id})
    MySQL.query.await("UPDATE characters SET bank = bank + ? WHERE character_id = ? LIMIT 1", {amount, NDCore.Players[player].id})
    NDCore.Functions.UpdateMoney(player)
    return true
end

-- Deducts money from the player, "bank" or "cash" needs to be specified.
function NDCore.Functions.DeductMoney(amount, player, from)
    local amount = tonumber(amount)
    local player = tonumber(player)
    if from == "bank" then
        MySQL.query.await("UPDATE characters SET bank = bank - ? WHERE character_id = ? LIMIT 1", {amount, NDCore.Players[player].id})
    elseif from == "cash" then
        MySQL.query.await("UPDATE characters SET cash = cash - ? WHERE character_id = ? LIMIT 1", {amount, NDCore.Players[player].id})
    end
    NDCore.Functions.UpdateMoney(player)
end

-- Adds money from the player, "bank" or "cash" needs to be specified.
function NDCore.Functions.AddMoney(amount, player, to)
    local amount = tonumber(amount)
    local player = tonumber(player)
    if to == "bank" then
        MySQL.query.await("UPDATE characters SET bank = bank + ? WHERE character_id = ? LIMIT 1", {amount, NDCore.Players[player].id})
    elseif to == "cash" then
        MySQL.query.await("UPDATE characters SET cash = cash + ? WHERE character_id = ? LIMIT 1", {amount, NDCore.Players[player].id})
    end
    NDCore.Functions.UpdateMoney(player)
end

-- Adds the players character to the NDCore.Players table, this table consists of every players selected character.
function NDCore.Functions.SetActiveCharacter(player, characterId)
    local result = MySQL.query.await("SELECT * FROM characters WHERE character_id = ? LIMIT 1", {characterId})
    if result then
        local i = result[1]
        NDCore.Players[player] = {
            id = characterId,
            firstName = i.first_name,
            lastName = i.last_name,
            dob = i.dob,
            gender = i.gender,
            twt = i.twt,
            job = i.job,
            cash = i.cash,
            bank = i.bank,
            phoneNumber = i.phone_number,
            groups = json.decode(i.groups),
            lastLocation = json.decode(i.last_location),
            clothing = json.decode(i.clothing)
        }
    end
    TriggerClientEvent("ND:setCharacter", player, NDCore.Players[player])
end

-- This returns all the characters the player has.
function NDCore.Functions.GetPlayerCharacters(player)
    local characters = {}
    local result = MySQL.query.await("SELECT * FROM characters WHERE license = ? LIMIT", {NDCore.Functions.GetPlayerIdentifierFromType("license", player)})
    for i = 1, #result do
        local temp = result[i]
        characters[temp.character_id] = {id = temp.character_id, firstName = temp.first_name, lastName = temp.last_name, dob = temp.dob, gender = temp.gender, twt = temp.twt, job = temp.job, cash = temp.cash, bank = temp.bank, phoneNumber = temp.phone_number, groups = json.decode(temp.groups), lastLocation = json.decode(temp.last_location), clothing = json.decode(temp.clothing)}
    end
    return characters
end

-- Creates a new character for the player and returns all their characters to the client.
function NDCore.Functions.CreateCharacter(player, firstName, lastName, dob, gender, twt, job, cash, bank)
    local license = NDCore.Functions.GetPlayerIdentifierFromType("license", player)
    if not cash or not bank or tonumber(cash) > config.startingCash or tonumber(bank) > config.startingBank then
        cash = config.startingCash
        bank = config.startingBank
    end
    local result = MySQL.query.await("SELECT character_id FROM characters WHERE license = ?", {license})
    if result and config.characterLimit > #result then
        MySQL.query.await("INSERT INTO characters (license, first_name, last_name, dob, gender, twt, job, cash, bank) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", {license, firstName, lastName, dob, gender, twt, job, cash, bank})
        TriggerClientEvent("ND:returnCharacters", player, NDCore.Functions.GetPlayerCharacters(player))
    end
    return result
end

-- Update/edit a character info by character id.
function NDCore.Functions.UpdateCharacterData(characterId, firstName, lastName, dob, gender, twt, job)
    local result = MySQL.query.await("UPDATE characters SET first_name = ?, last_name = ?, dob = ?, gender = ?, twt = ?, job = ? WHERE character_id = ? LIMIT 1", {firstName, lastName, dob, gender, twt, job, characterId})
    return result
end

-- Delete a character by character id.
function NDCore.Functions.DeleteCharacter(characterId)
    local result = MySQL.query.await("DELETE FROM characters WHERE character_id = ? LIMIT 1", {characterId})
    return result
end

-- Update the all the characters groups in the database.
function NDCore.Functions.UpdateAllGroups(characterId, groups)
    local result = MySQL.query.await("UPDATE characters SET groups = ? WHERE character_id = ? LIMIT 1", {groups, characterId})
    return result
end

-- Set a group to a character in the database.
function NDCore.Functions.SetGroup(characterId, group)
    local groups = {}
    local result = MySQL.query.await("SELECT groups FROM characters WHERE character_id = ? LIMIT 1", {characterId})
    if result then
        groups = json.decode(result[1].groups)
        table.insert(groups, group)
    end
    result = MySQL.query.await("UPDATE characters SET groups = ? WHERE character_id = ? LIMIT 1", {json.encode(groups), characterId})
    return result
end

-- Update the characters last location into the database.
function NDCore.Functions.UpdateLastLocation(characterId, location)
    local result = MySQL.query.await("UPDATE characters SET last_location = ? WHERE character_id = ? LIMIT 1", {json.encode(location), characterId})
    return result
end

-- Update the characters clothing into the database.
function NDCore.Functions.UpdateClothes(characterId, clothing)
    local result = MySQL.query.await("UPDATE characters SET clothing = ? WHERE character_id = ? LIMIT 1", {json.encode(clothing), characterId})
    return result
end

function NDCore.Functions.VersionChecker(expectedResourceName, resourceName, downloadLink, rawGithubLink)
    if expectedResourceName ~= resourceName then
        print("^1[^4" .. expectedResourceName .. "^1] WARNING^0")
        print("Change the resource name to ^4" .. expectedResourceName .. " ^0or else it won't work properly!")
        StopResource(resourceName)
        return
    end
    PerformHttpRequest(rawGithubLink, function(errorCode, resultData, resultHeaders)
        local i, j = string.find(tostring(resultData), "version")
        local resultData = string.sub(tostring(resultData), i, j + 12)
        local resultData = string.gsub(resultData, "version \"", "")
        local i, j = string.find(resultData, "\"")
        local resultData = string.sub(resultData, 1, i - 1)
        local githubVersion = string.gsub(resultData, "%.", "")
        local fileVersion = string.gsub(GetResourceMetadata(expectedResourceName, "version", 0), "%.", "")
        local githubVersion = tonumber(githubVersion)
        local fileVersion = tonumber(fileVersion)

        if not githubVersion and not fileVersion then
            print("^1[^4" .. expectedResourceName .. "^1] WARNING^0")
            print("You may not have the latest version of ^4" .. expectedResourceName .. "^0. A newer, improved version may be present at ^5" .. downloadLink .. "^0")
        elseif githubVersion > fileVersion then
            local oldVersion = string.sub(fileVersion, 1, 1) .. "." .. string.sub(fileVersion, 2, 2) .. "." .. string.sub(fileVersion, 3, 3)
            local newVersion = string.sub(githubVersion, 1, 1) .. "." .. string.sub(githubVersion, 2, 2) .. "." .. string.sub(githubVersion, 3, 3)
            print("^1[^4" .. expectedResourceName .. "^1] WARNING^0")
            print("^4" .. expectedResourceName .. " ^0is outdated. Please update it from ^5" .. downloadLink .. " ^0| Current Version: ^1" .. oldVersion .. " ^0| New Version: ^2" .. newVersion .. " ^0|")
        elseif githubVersion < fileVersion then
            local oldVersion = string.sub(fileVersion, 1, 1) .. "." .. string.sub(fileVersion, 2, 2) .. "." .. string.sub(fileVersion, 3, 3)
            local newVersion = string.sub(githubVersion, 1, 1) .. "." .. string.sub(githubVersion, 2, 2) .. "." .. string.sub(githubVersion, 3, 3)
            print("^1[^4" .. expectedResourceName .. "^1] WARNING^0")
            print("^4" .. expectedResourceName .. " ^0version number is higher than expected | Current Version: ^3" .. oldVersion .. " ^0| Expected Version: ^2" .. newVersion .. " ^0|")
        else
            local newVersion = string.sub(githubVersion, 1, 1) .. "." .. string.sub(githubVersion, 2, 2) .. "." .. string.sub(githubVersion, 3, 3)
            print("^4" .. expectedResourceName .. " ^0is up to date | Current Version: ^2" .. newVersion .. " ^0|")
        end
    end)
end
NDCore.Functions.VersionChecker("ND_Core", GetCurrentResourceName(), "https://github.com/Andyyy7666/ND_Framework", "https://raw.githubusercontent.com/Andyyy7666/ND_Framework/main/ND_Core/fxmanifest.lua")
