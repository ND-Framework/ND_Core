-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

-- Check if discord is connected, and if whitelist is enabled then it will only allow you to join if you have the roles.
AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local player = source
    local discordIdentifier = NDCore.Functions.GetPlayerIdentifierFromType("discord", player)

    deferrals.defer()
    Wait(0)
    deferrals.update("Connecting to discord.")
    Wait(0)

    if not discordIdentifier then
        deferrals.done("Your discord isn't connected to FiveM, make sure discord is open and restart FiveM.")
    else
        if config.enableDiscordWhitelist then
            local discordUserId = discordIdentifier:gsub("discord:", "")
            local discordInfo = NDCore.Functions.GetUserDiscordInfo(discordUserId)
            for _, whitelistRole in pairs(config.whitelistRoles) do
                if whitelistRole == 0 or whitelistRole == "0" or (discordInfo and discordInfo.roles[whitelistRole]) then
                    deferrals.done()
                    break
                end
            end
            deferrals.done(config.notWhitelistedMessage)
        else
            deferrals.done()
        end
    end
end)

-- Getting all the characters the player has and returning them to the client.
RegisterNetEvent("ND:GetCharacters", function()
    local player = source
    TriggerClientEvent("ND:returnCharacters", player, NDCore.Functions.GetPlayerCharacters(player))
end)

-- Creating a new character.
RegisterNetEvent("ND:newCharacter", function(newCharacter)
    local player = source
    NDCore.Functions.CreateCharacter(player, newCharacter.firstName, newCharacter.lastName, newCharacter.dob, newCharacter.gender, newCharacter.cash, newCharacter.bank)
end)

-- Update the character info when edited.
RegisterNetEvent("ND:editCharacter", function(newCharacter)
    local player = source
    local characters = NDCore.Functions.GetPlayerCharacters(player)
    if not characters[newCharacter.id] then return end
    NDCore.Functions.UpdateCharacterData(newCharacter.id, newCharacter.firstName, newCharacter.lastName, newCharacter.dob, newCharacter.gender)
end)

-- Delete character from database.
RegisterNetEvent("ND:deleteCharacter", function(characterId)
    local player = source
    local characters = NDCore.Functions.GetPlayerCharacters(player)
    if not characters[characterId] then return end
    NDCore.Functions.DeleteCharacter(characterId)
end)

-- add a player to the table.
RegisterNetEvent("ND:setCharacterOnline", function(id)
    local player = source
    local characters = NDCore.Functions.GetPlayerCharacters(player)
    if not characters[id] then return end
    NDCore.Functions.SetActiveCharacter(player, id)
end)

-- Update the characters clothes.
RegisterNetEvent("ND:updateClothes", function(clothing)
    local player = source
    local character = NDCore.Players[player]
    NDCore.Functions.SetPlayerData(character.id, "clothing", clothing)
end)

-- Disconnecting a player
RegisterNetEvent("ND:exitGame", function()
    local player = source
    DropPlayer(player, "Disconnected.")
end)

-- Remove player from NDCore.Players table when they leave.
AddEventHandler("playerDropped", function()
    local player = source
    local character = NDCore.Players[player]
    if character then
        local ped = GetPlayerPed(player)
        local lastLocation = GetEntityCoords(ped)
        NDCore.Functions.UpdateLastLocation(character.id, {x = lastLocation.x, y = lastLocation.y, z = lastLocation.z})
    end
    TriggerEvent("ND:characterUnloaded", player, character)
    character = nil
end)

-- Get player discord info on join.
AddEventHandler("playerJoining", function()
    local src = source

    local discordUserId = NDCore.Functions.GetPlayerIdentifierFromType("discord", src):gsub("discord:", "")
    local discordInfo = NDCore.Functions.GetUserDiscordInfo(discordUserId)

    NDCore.PlayersDiscordInfo[src] = discordInfo
end)

AddEventHandler("onResourceStart", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end 
    Wait(1000)

    if not next(NDCore.PlayersDiscordInfo) then
        for _, playerId in ipairs(GetPlayers()) do
            local discordUserId = NDCore.Functions.GetPlayerIdentifierFromType("discord", playerId):gsub("discord:", "")
            local discordInfo = NDCore.Functions.GetUserDiscordInfo(discordUserId)
            NDCore.PlayersDiscordInfo[tonumber(playerId)] = discordInfo
        end
    end
end)
