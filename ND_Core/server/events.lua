-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

-- Getting all the characters the player has and returning them to the client.
RegisterNetEvent("ND:GetCharacters", function()
    local player = source
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