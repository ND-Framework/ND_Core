RegisterNetEvent("ND:returnCharacters", function(characters)
    NDCore.Characters = characters
end)

-- updates the money on the client.
RegisterNetEvent("ND:updateMoney", function(cash, bank)
    NDCore.player.cash = cash
    NDCore.player.bank = bank
end)

-- Sets main character.
RegisterNetEvent("ND:setCharacter", function(character)
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

-- Enable pvp for players.
AddEventHandler("playerSpawned", function()
    print("^0ND Framework support discord: ^5https://discord.gg/Z9Mxu72zZ6")
    SetCanAttackFriendly(PlayerPedId(), true, false)
    NetworkSetFriendlyFireOption(true)
end)
