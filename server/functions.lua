-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

-- Get an active players character data.
function NDCore.Functions.GetPlayer(player)
    return NDCore.Players[player]
end

-- Get all active players character data.
function NDCore.Functions.GetPlayers(getBy, value)
    if not getBy or not value then
        return NDCore.Players
    end
    local players = {}

    if getBy == "groups" then
        for player, playerInfo in pairs(NDCore.Players) do
            if playerInfo.data.groups then
                local valueGroup = value:lower()
                for group, _ in pairs(playerInfo.data.groups) do
                    if group and group:lower() == valueGroup then
                        players[player] = playerInfo
                    end
                end
            end
        end
    else
        for player, playerInfo in pairs(NDCore.Players) do
            if playerInfo[getBy] == value then
                players[player] = playerInfo
            end
        end
    end

    return players
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
        local nickname = ""
        local tag = ""
        if result and result.roles then
            for _, roleId in pairs(result.roles) do
                roles[roleId] = roleId
            end
            if result.nick then
                nickname = result.nick
            end
            if result.user and result.user.username and result.user.discriminator then
                tag = tostring(result.user.username) .. "#" .. tostring(result.user.discriminator)
            end
            data = {
                nickname = nickname,
                discordTag = tag,
                roles = roles
            }
            return
        end
        data = {
            nickname = nickname,
            discordTag = tag,
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
    local result = MySQL.query.await("SELECT cash, bank FROM characters WHERE character_id = ? LIMIT 1", {NDCore.Players[player].id})
    if result then
        local cash = result[1].cash
        local bank = result[1].bank
        NDCore.Players[player].cash = cash
        NDCore.Players[player].bank = bank
        TriggerClientEvent("ND:updateMoney", player, cash, bank)
    end
end

-- Transfer money from one players bank account to another.
function NDCore.Functions.TransferBank(amount, player, target, descriptionSender, descriptionReceiver)
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
        MySQL.query.await("UPDATE characters SET bank = bank - ? WHERE character_id = ?", {amount, NDCore.Players[player].id})
        NDCore.Functions.UpdateMoney(player)
        TriggerEvent("ND:moneyChange", player, "bank", amount, "remove", descriptionSender or "Transfer")
        TriggerClientEvent("chat:addMessage", player, {
            color = {0, 255, 0},
            args = {"Success", "You paid " .. NDCore.Players[target].firstName .. " " .. NDCore.Players[target].lastName .. " $" .. amount .. "."}
        })
        
        MySQL.query.await("UPDATE characters SET bank = bank + ? WHERE character_id = ?", {amount, NDCore.Players[target].id})
        NDCore.Functions.UpdateMoney(target)
        TriggerEvent("ND:moneyChange", target, "bank", amount, "add", descriptionReceiver or "Transfer")
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
        MySQL.query.await("UPDATE characters SET cash = cash - ? WHERE character_id = ?", {amount, NDCore.Players[player].id})
        NDCore.Functions.UpdateMoney(player)
        TriggerEvent("ND:moneyChange", player, "cash", amount, "remove")
        TriggerClientEvent("chat:addMessage", player, {
            color = {0, 255, 0},
            args = {"Success", "You gave " .. NDCore.Players[target].firstName .. " " .. NDCore.Players[target].lastName .. " $" .. amount .. "."}
        })
        
        MySQL.query.await("UPDATE characters SET cash = cash + ? WHERE character_id = ?", {amount, NDCore.Players[target].id})
        NDCore.Functions.UpdateMoney(target)
        TriggerEvent("ND:moneyChange", target, "cash", amount, "add")
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
    TriggerEvent("ND:moneyChange", player, "bank", amount, "remove", "Withdraw")
    TriggerEvent("ND:moneyChange", player, "cash", amount, "add", "Withdraw")
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
    TriggerEvent("ND:moneyChange", player, "cash", amount, "remove", "Deposit")
    TriggerEvent("ND:moneyChange", player, "bank", amount, "add", "Deposit")
    return true
end

-- Deducts money from the player, "bank" or "cash" needs to be specified.
function NDCore.Functions.DeductMoney(amount, player, from, description)
    local amount = tonumber(amount)
    local player = tonumber(player)
    if from == "bank" then
        MySQL.query.await("UPDATE characters SET bank = bank - ? WHERE character_id = ? LIMIT 1", {amount, NDCore.Players[player].id})
    elseif from == "cash" then
        MySQL.query.await("UPDATE characters SET cash = cash - ? WHERE character_id = ? LIMIT 1", {amount, NDCore.Players[player].id})
    end
    NDCore.Functions.UpdateMoney(player)
    TriggerEvent("ND:moneyChange", player, from, amount, "remove", description)
end

-- Adds money from the player, "bank" or "cash" needs to be specified.
function NDCore.Functions.AddMoney(amount, player, to, description)
    local amount = tonumber(amount)
    local player = tonumber(player)
    if to == "bank" then
        MySQL.query.await("UPDATE characters SET bank = bank + ? WHERE character_id = ? LIMIT 1", {amount, NDCore.Players[player].id})
    elseif to == "cash" then
        MySQL.query.await("UPDATE characters SET cash = cash + ? WHERE character_id = ? LIMIT 1", {amount, NDCore.Players[player].id})
    end
    NDCore.Functions.UpdateMoney(player)
    TriggerEvent("ND:moneyChange", player, to, amount, "add", description)
end

-- Adds the players character to the NDCore.Players table, this table consists of every players selected character.
function NDCore.Functions.SetActiveCharacter(player, characterId)
    if NDCore.Players[player] then
        TriggerEvent("ND:characterUnloaded", player, NDCore.Players[player])
    end
    local result = MySQL.query.await("SELECT * FROM characters WHERE character_id = ? LIMIT 1", {characterId})
    if result then
        local i = result[1]
        NDCore.Players[player] = {
            source = player,
            id = characterId,
            firstName = i.first_name,
            lastName = i.last_name,
            dob = i.dob,
            gender = i.gender,
            cash = i.cash,
            bank = i.bank,
            phoneNumber = i.phone_number,
            lastLocation = json.decode(i.last_location),
            inventory = json.decode(i.inventory),
            discordInfo = NDCore.PlayersDiscordInfo[player],
            data = json.decode(i.data),
            job = i.job
        }
    end
    NDCore.Functions.RefreshCommands(player)
    TriggerEvent("ND:characterLoaded", NDCore.Players[player])
    TriggerClientEvent("ND:setCharacter", player, NDCore.Players[player])
end

-- This returns all the characters the player has.
function NDCore.Functions.GetPlayerCharacters(player)
    local characters = {}
    local result = MySQL.query.await("SELECT * FROM characters WHERE license = ?", {NDCore.Functions.GetPlayerIdentifierFromType("license", player)})
    for i = 1, #result do
        local temp = result[i]
        characters[temp.character_id] = {
            id = temp.character_id,
            firstName = temp.first_name,
            lastName = temp.last_name,
            dob = temp.dob,
            gender = temp.gender,
            cash = temp.cash,
            bank = temp.bank,
            phoneNumber = temp.phone_number,
            lastLocation = json.decode(temp.last_location),
            inventory = json.decode(temp.inventory),
            discordInfo = NDCore.PlayersDiscordInfo[player],
            data = json.decode(temp.data),
            job = temp.job
        }
    end
    return characters
end

-- Creates a new character for the player and returns all their characters to the client.
function NDCore.Functions.CreateCharacter(player, firstName, lastName, dob, gender, cb)
    local characterId = false
    local license = NDCore.Functions.GetPlayerIdentifierFromType("license", player)
    local result = MySQL.query.await("SELECT character_id FROM characters WHERE license = ?", {license})
    if result and config.characterLimit > #result then
        characterId = MySQL.insert.await("INSERT INTO characters (license, first_name, last_name, dob, gender, cash, bank, data) VALUES (?, ?, ?, ?, ?, ?, ?, ?)", {license, firstName, lastName, dob, gender, config.startingCash, config.startingBank, json.encode({groups={}})})
        if cb then cb(characterId) end
        TriggerClientEvent("ND:returnCharacters", player, NDCore.Functions.GetPlayerCharacters(player))
    end
    return characterId
end

-- Update/edit a character info by character id.
function NDCore.Functions.UpdateCharacter(characterId, firstName, lastName, dob, gender)
    local result = MySQL.query.await("UPDATE characters SET first_name = ?, last_name = ?, dob = ?, gender = ? WHERE character_id = ? LIMIT 1", {firstName, lastName, dob, gender, characterId})
    return result
end

-- Delete a character by character id.
function NDCore.Functions.DeleteCharacter(characterId)
    local result = MySQL.query.await("DELETE FROM characters WHERE character_id = ? LIMIT 1", {characterId})
    return result
end

-- Updates the player's data
function NDCore.Functions.SetPlayerData(characterId, key, value, description)
    if not key then return end

    local player = nil
    for id, character in pairs(NDCore.Players) do
        if character.id == characterId then
            player = id
            break
        end
    end

    if key == "cash" then
        if player then
            NDCore.Players[player][key] = value
            TriggerEvent("ND:moneyChange", player, "cash", tonumber(value), "set", description)
        end
        MySQL.query.await("UPDATE characters SET cash = ? WHERE character_id = ?", {tonumber(value), characterId})
    elseif key == "bank" then
        if player then
            NDCore.Players[player][key] = value
            TriggerEvent("ND:moneyChange", player, "bank", tonumber(value), "set", description)
        end
        MySQL.query.await("UPDATE characters SET bank = ? WHERE character_id = ?", {tonumber(value), characterId})
    elseif key == "job" then
        if player then
            NDCore.Players[player].job = value
        end
        MySQL.query.await("UPDATE characters SET job = ? WHERE character_id = ?", {value, characterId})
    else
        if player then
            NDCore.Players[player].data[key] = value
            MySQL.query.await("UPDATE characters SET `data` = ? WHERE character_id = ?", {json.encode(NDCore.Players[player].data), characterId})
        else
            local result = MySQL.query.await("SELECT `data` FROM characters WHERE character_id = ?", {characterId})
            if not result or not result[1] then return end

            local data = json.decode(result[1].data)
            data[key] = value
            MySQL.query.await("UPDATE characters SET `data` = ? WHERE character_id = ?", {json.encode(data), characterId})
        end
    end

    if not player then return end
    TriggerClientEvent("ND:updateCharacter", player, NDCore.Players[player])
end

-- Get a character by the character id.
function NDCore.Functions.GetPlayerByCharacterId(id)
    for _, character in pairs(NDCore.Players) do
        if character.id == id then
            return character
        end
    end
end

-- Generate a random string with letters and numbers.
function randomString(length)
    local number = {}
    for i = 1, length do
        number[i] = math.random(0, 1) == 1 and string.char(math.random(65, 90)) or math.random(0, 9)
    end
    return table.concat(number)
end

-- Give a player a license.
function NDCore.Functions.CreatePlayerLicense(characterId, licenseType, expire)
    local expireIn = tonumber(expire)
    if not expireIn then
        expireIn = 2592000
    end

    local time = os.time()
    local license = {
        type = licenseType,
        status = "valid",
        issued = time,
        expires = time+expireIn,
        identifier = randomString(16)
    }

    local character = NDCore.Functions.GetPlayerByCharacterId(characterId)
    if character then
        local data = character.data
        if not data.licences then
            data.licences = {}
        end
        character.data.licences[#character.data.licences+1] = license
        NDCore.Functions.SetPlayerData(character.id, "licences", character.data.licences)
        return true
    end

    local result = MySQL.query.await("SELECT data FROM characters WHERE character_id = ?", {characterId})
    if result and result[1] then
        local data = result[1].data
        if not data.licences then
            data.licences = {}
        end
        data.licences[#data.licences+1] = license
        NDCore.Functions.SetPlayerData(character.id, "licences", data.licences)
        return true
    end
end

-- find a players license by it's identifier.
function NDCore.Functions.FindLicenseByIdentifier(licences, identifier)
    for key, license in pairs(licences) do
        if license.identifier == identifier then
            return license
        end
    end
    return {}
end

-- Edit a license by the license identifier.
function NDCore.Functions.EditPlayerLicense(characterId, identifier, newData)
    local licences = {}
    local character = NDCore.Functions.GetPlayerByCharacterId(characterId)
    if character then
        licences = character.data.licences
    else
        local result = MySQL.query.await("SELECT data FROM characters WHERE character_id = ?", {characterId})
        if result and result[1] then
            local data = result[1].data
            if not data.licences then
                data.licences = {}
            end
            licences = data.licences
        end
    end

    local license = NDCore.Functions.FindLicenseByIdentifier(licences, identifier)
    for k, v in pairs(newData) do
        license[k] = v
    end
    NDCore.Functions.SetPlayerData(characterId, "licences", licences)
    return licences
end

-- Set the players job and job rank.
function NDCore.Functions.SetPlayerJob(characterId, job, rank)
    if not job then return end

    local jobRank = tonumber(rank)
    if not jobRank then
        jobRank = 1
    end
    
    local result = MySQL.query.await("SELECT job FROM characters WHERE character_id = ?", {characterId})
    if result and result[1] then
        local character = NDCore.Functions.GetPlayerByCharacterId(characterId)
        if character then
            local oldRank = 1
            if character.data.groups and character.data.groups[character.job] then
                oldRank = character.data.groups[character.job].rank
            end
            TriggerEvent("ND:jobChanged", character.source, {name = job, rank = jobRank}, {name = character.job, rank = oldRank})
            TriggerClientEvent("ND:jobChanged", character.source, {name = job, rank = jobRank}, {name = character.job, rank = oldRank})
        end
        NDCore.Functions.RemovePlayerFromGroup(characterId, result[1].job)
    end

    NDCore.Functions.SetPlayerData(characterId, "job", job)
    NDCore.Functions.SetPlayerToGroup(characterId, job, jobRank)
end

-- Set a player to a group.
function NDCore.Functions.SetPlayerToGroup(characterId, group, rank)
    local groupRank = tonumber(rank)
    if not groupRank then
        groupRank = 1
    end

    local group = group:lower()
    for groupName, groupRanks in pairs(config.groups) do
        if groupName:lower() == group then
            group = groupName
            break
        end
    end

    local character = NDCore.Functions.GetPlayerByCharacterId(characterId)
    if character then
        local data = character.data
        if not data.groups then
            data.groups = {}
        end
        local rankName = tostring(groupRank)
        if config.groups[group] and config.groups[group][groupRank] then
            rankName = config.groups[group][groupRank]
        end
        data.groups[group] = {
            rank = groupRank,
            rankName = rankName
        }
        NDCore.Functions.SetPlayerData(characterId, "groups", data.groups)
        return true
    end

    local result = MySQL.query.await("SELECT data FROM characters WHERE character_id = ?", {characterId})
    if not result or not result[1] then return end
    local data = json.decode(result[1].data)
    if not data then
        data = {}
    end
    if not data.groups then
        data.groups = {}
    end
    local rankName = tostring(groupRank)
    if config.groups[group] and config.groups[group][groupRank] then
        rankName = config.groups[group][groupRank]
    end
    data.groups[group] = {
        rank = groupRank,
        rankName = rankName
    }
    NDCore.Functions.SetPlayerData(characterId, "groups", data.groups)
    return true
end

-- Remove a player from a group.
function NDCore.Functions.RemovePlayerFromGroup(characterId, group)
    if not group then return end
    local group = group:lower()
    for groupName, groupRanks in pairs(config.groups) do
        if groupName:lower() == group then
            group = groupName
            break
        end
    end

    local character = NDCore.Functions.GetPlayerByCharacterId(characterId)
    if character then
        local data = character.data
        if not data.groups then
            data.groups = {}
        end
        data.groups[group] = nil
        NDCore.Functions.SetPlayerData(characterId, "groups", data.groups)
        return true
    end

    local result = MySQL.query.await("SELECT data FROM characters WHERE character_id = ?", {characterId})
    if result and result[1] then
        local data = result[1].data
        if not data.groups then
            data.groups = {}
        end
        data.groups[group] = nil
        NDCore.Functions.SetPlayerData(characterId, "groups", data.groups)
        return true
    end
end

-- Update the characters last location into the database.
function NDCore.Functions.UpdateLastLocation(characterId, location)
    local result = MySQL.query.await("UPDATE characters SET last_location = ? WHERE character_id = ? LIMIT 1", {json.encode(location), characterId})
    return result
end

function NDCore.Functions.AddCommand(name, help, callback, argsrequired, arguments)
    local commandName = name:lower()
    if NDCore.Commands[commandName] then print("/" .. commandName .. " has already been registered.") return end

    local arguments = arguments or {}

    RegisterCommand(commandName, function(source, args, rawCommand)
        if argsrequired and #args < #arguments then
            return TriggerClientEvent("chat:addMessage", source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"Error", "all arguments required."}
            })
        end
        local message = callback(source, args, rawCommand)
        if not message then return end
        TriggerClientEvent("chat:addMessage", source, message)
    end, false)

    NDCore.Commands[commandName] = {
        name = commandName,
        help = help,
        callback = callback,
        argsrequired = argsrequired,
        arguments = arguments
    }
end

function NDCore.Functions.RefreshCommands(source)
    local suggestions = {}
    for command, info in pairs(NDCore.Commands) do
        suggestions[#suggestions + 1] = {
            name = "/" .. command,
            help = info.help,
            params = info.arguments
        }
    end
    TriggerClientEvent("chat:addSuggestions", source, suggestions)
end

function NDCore.Functions.IsPlayerAdmin(src)
    local discordInfo = NDCore.PlayersDiscordInfo[src]
    if not discordInfo or not discordInfo.roles then return end
    for _, adminRole in pairs(config.adminRoles) do
        for _, role in pairs(discordInfo.roles) do
            if role == adminRole then return true end
        end
    end
end

function NDCore.Functions.VersionChecker(expectedResourceName, resourceName, downloadLink, rawGithubLink)
    if expectedResourceName ~= resourceName then
        print(("^4%s ^1WARNING^0"):format(expectedResourceName))
        print(("Change the resource name to ^4%s ^0or else it won't work properly!"):format(expectedResourceName))
        StopResource(resourceName)
        return
    end
    PerformHttpRequest(rawGithubLink, function(errorCode, resultData, resultHeaders)
        local i, j = tostring(resultData):find("version")
        if not i or not j then return end
        local resultData = tostring(resultData):sub(i, j + 12)
        local resultData = resultData:gsub("version \"", "")
        local i, j = resultData:find("\"")
        local resultData = resultData:sub(1, i - 1)
        local githubVersion = resultData:gsub("%.", "")
        local fileVersion = GetResourceMetadata(expectedResourceName, "version", 0):gsub("%.", "")

        if not githubVersion and not fileVersion then
            print(("^4%s ^1WARNING^0"):format(expectedResourceName))
            print(("You may not have the latest version of ^4%s^0. A newer, improved version may be present at ^5%s^0"):format(expectedResourceName, downloadLink))
        elseif githubVersion > fileVersion then
            local oldVersion =  ("%s.%s.%s"):format(fileVersion:sub(1, 1), fileVersion:sub(2, 2), fileVersion:sub(3, 3))
            local newVersion = ("%s.%s.%s"):format(githubVersion:sub(1, 1), githubVersion:sub(2, 2), githubVersion:sub(3, 3))
            print(("^4%s ^1WARNING^0"):format(expectedResourceName))
            print(("^4%s ^0is outdated. Please update it from ^5%s ^0| Current Version: ^1%s ^0| New Version: ^2%s ^0|"):format(expectedResourceName, downloadLink, oldVersion, newVersion))
        elseif githubVersion < fileVersion then
            local oldVersion = ("%s.%s.%s"):format(fileVersion:sub(1, 1), fileVersion:sub(2, 2), fileVersion:sub(3, 3))
            local newVersion = ("%s.%s.%s"):format(githubVersion:sub(1, 1), githubVersion:sub(2, 2), githubVersion:sub(3, 3))
            print(("^4%s ^1WARNING^0"):format(expectedResourceName))
            print(("^4%s ^0version number is higher than expected | Current Version: ^3%s ^0| Expected Version: ^2%s ^0|"):format(expectedResourceName, oldVersion, newVersion))
        else
            local newVersion = ("%s.%s.%s"):format(githubVersion:sub(1, 1), githubVersion:sub(2, 2), githubVersion:sub(3, 3))
            print(("^4%s ^0is up to date | Current Version: ^2%s ^0|"):format(expectedResourceName, newVersion))
        end
    end)
end
NDCore.Functions.VersionChecker("ND_Core", GetCurrentResourceName(), "https://github.com/ND-Framework/ND_Core", "https://raw.githubusercontent.com/ND-Framework/ND_Core/main/fxmanifest.lua")


-- Callbacks are licensed under LGPL v3.0
-- <https://github.com/overextended/ox_lib>
NDCore.callback = {}
local events = {}

RegisterNetEvent("ND:callbacks", function(key, ...)
	local cb = events[key]
	return cb and cb(...)
end)

function triggerCallback(_, name, playerId, cb, ...)
	local key = ("%s:%s:%s"):format(name, math.random(0, 100000), playerId)
	TriggerClientEvent(("ND:%s_cb"):format(name), playerId, key, ...)

	local promise = not cb and promise.new()

	events[key] = function(response, ...)
        response = { response, ... }
		events[key] = nil

		if promise then
			return promise:resolve(response)
		end

        if cb then
            cb(table.unpack(response))
        end
	end

	if promise then
		return table.unpack(Citizen.Await(promise))
	end
end

setmetatable(NDCore.callback, {
	__call = triggerCallback
})

function NDCore.callback.await(name, playerId, ...)
    return triggerCallback(nil, name, playerId, false, ...)
end

function NDCore.callback.register(name, callback)
    RegisterNetEvent(("ND:%s_cb"):format(name), function(key, ...)
        local src = source
        TriggerClientEvent("ND:callbacks", src, key, callback(src, ...))
    end)
end
