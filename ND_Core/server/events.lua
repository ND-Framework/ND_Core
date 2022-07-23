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
            local discordUserId = string.gsub(discordIdentifier, "discord:", "")
            local roles = NDCore.Functions.GetUserDiscordInfo(discordUserId).roles
            for _, whitelistRole in pairs(config.whitelistRoles) do
                if roles[whitelistRole] or whitelistRole == 0 or whitelistRole == "0" then
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

-- Creating database tables
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    MySQL.query("CREATE TABLE IF NOT EXISTS characters ( `character_id` INT(10) NOT NULL AUTO_INCREMENT, `license` VARCHAR(200) NOT NULL DEFAULT '0', `first_name` VARCHAR(50) NULL DEFAULT NULL, `last_name` VARCHAR(50) NULL DEFAULT NULL, `dob` VARCHAR(50) NULL DEFAULT NULL, `gender` VARCHAR(50) NULL DEFAULT NULL, `twt` VARCHAR(50) NULL DEFAULT NULL, `job` VARCHAR(50) NULL DEFAULT NULL, `cash` INT(10) NULL DEFAULT '0', `bank` INT(10) NULL DEFAULT '0', PRIMARY KEY (`character_id`) USING BTREE);")
    print('^4ND_Core ^0Database structure validated!')
end)

-- Getting all the characters the player has and returning them to the client.
RegisterNetEvent("ND:GetCharacters", function()
    local player = source
    print(NDCore.Functions.GetPlayerCharacters(player)[1])
    TriggerClientEvent("ND:returnCharacters", player, NDCore.Functions.GetPlayerCharacters(player))
end)

-- Creating a new character.
RegisterNetEvent("ND:newCharacter", function(newCharacter)
    local player = source
    NDCore.Functions.CreateCharacter(player, newCharacter.firstName, newCharacter.lastName, newCharacter.dob, newCharacter.gender, newCharacter.twt, newCharacter.job, newCharacter.cash, newCharacter.bank)
end)

-- Update the character info when edited.
RegisterNetEvent("ND:editCharacter", function(newCharacter)
    local player = source
    NDCore.Functions.UpdateCharacterData(newCharacter.id, newCharacter.firstName, newCharacter.lastName, newCharacter.dob, newCharacter.gender, newCharacter.twt, newCharacter.job)
end)

-- Delete character from database.
RegisterNetEvent("ND:deleteCharacter", function(characterId)
    local player = source
    NDCore.Functions.DeleteCharacter(characterId)
end)

-- add a player to the table.
RegisterNetEvent("ND:setCharacterOnline", function(id)
    local player = source
    NDCore.Functions.SetActiveCharacter(player, id)
end)

-- Disconnecting a player
RegisterNetEvent("ND:exitGame", function()
    local player = source
    DropPlayer(player, "Disconnected.")
end)

-- Remove player from NDCore.Players table when they leave.
AddEventHandler("playerDropped", function()
    local player = source
    NDCore.Players[player] = nil
end)
