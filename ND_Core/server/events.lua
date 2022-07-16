-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

-- Getting all the characters the player has and returning them to the client.
RegisterNetEvent("ND:getCharacters")
AddEventHandler("ND:getCharacters", function()
    local player = source
    TriggerClientEvent("ND:returnCharacters", player, NDCore.functions:getPlayerCharacters(player))
end)

-- Creating a new character.
RegisterNetEvent("ND:newCharacter")
AddEventHandler("ND:newCharacter", function(newCharacter)
    local player = source
    NDCore.functions:createCharacter(player, newCharacter.firstName, newCharacter.lastName, newCharacter.dob, newCharacter.gender, newCharacter.twt, newCharacter.job, newCharacter.cash, newCharacter.bank)
end)

-- Update the character info when edited.
RegisterNetEvent("ND:editCharacter")
AddEventHandler("ND:editCharacter", function(newCharacter)
    local player = source
    NDCore.functions:updateCharacterData(newCharacter.id, newCharacter.firstName, newCharacter.lastName, newCharacter.dob, newCharacter.gender, newCharacter.twt, newCharacter.job)
end)

-- Delete character from database.
RegisterNetEvent("ND:deleteCharacter")
AddEventHandler("ND:deleteCharacter", function(characterId)
    local player = source
    NDCore.functions:deleteCharacter(characterId)
end)

-- add a player to the table.
RegisterNetEvent("ND:setCharacterOnline")
AddEventHandler("ND:setCharacterOnline", function(id)
    local player = source
    NDCore.functions:setActiveCharacter(player, id)
end)

-- Disconnecting a player
RegisterNetEvent("ND:exitGame")
AddEventHandler("ND:exitGame", function()
    local player = source
    DropPlayer(player, "Disconnected.")
end)

-- Remove player from NDCore.players table when they leave.
AddEventHandler("playerDropped", function()
    local player = source
    NDCore.players[player] = nil
end)