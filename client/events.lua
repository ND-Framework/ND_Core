-- updates the money on the client.
RegisterNetEvent("ND:updateMoney", function(cash, bank)
    if not NDCore.player then return end
    NDCore.player.cash = cash
    NDCore.player.bank = bank
end)

-- Sets main character.
RegisterNetEvent("ND:characterLoaded", function(character)
    NDCore.player = character
end)

-- Update main character info.
RegisterNetEvent("ND:updateCharacter", function(character)
    NDCore.player = character
end)

-- Updates last lcoation.
RegisterNetEvent("ND:updateLastLocation", function(location)
    if not NDCore.player then return end
    NDCore.player.lastLocation = location
end)

RegisterNetEvent("ND:revivePlayer", function()
    NDCore.revivePlayer(true)
end)
