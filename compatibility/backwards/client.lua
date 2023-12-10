if not lib.table.contains(Config.compatibility, "backwards") then return end

NDCore.Functions = {}
NDCore.Functions.GetSelectedCharacter = NDCore.getPlayer
NDCore.Functions.GetCharacters = NDCore.getCharacters
NDCore.Functions.GetPlayersFromCoords = NDCore.getPlayersFromCoords

exports("GetCoreObject", function()
    return NDCore
end)

RegisterNetEvent("ND:returnCharacters", function(characters)
    NDCore.characters = characters
end)

RegisterNetEvent("ND:setCharacter", function(character)
    NDCore.player = character
end)
