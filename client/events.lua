RegisterNetEvent("ND:returnCharacters", function(characters)
    NDCore.Characters = characters
end)

-- updates the money on the client.
RegisterNetEvent("ND:updateMoney", function(cash, bank)
    NDCore.SelectedCharacter.cash = cash
    NDCore.SelectedCharacter.bank = bank
end)

-- Sets main character.
RegisterNetEvent("ND:setCharacter", function(character)
    NDCore.SelectedCharacter = character
end)

-- Update main character info.
RegisterNetEvent("ND:updateCharacter", function(character)
    NDCore.SelectedCharacter = character
end)

-- Updates last lcoation.
RegisterNetEvent("ND:updateLastLocation", function(location)
    NDCore.SelectedCharacter.lastLocation = location
end)
