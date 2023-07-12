-- updates the money on the client.
RegisterNetEvent("ND:updateMoney", function(cash, bank)
    if not NDCore.player then return end
    NDCore.player.cash = cash
    NDCore.player.bank = bank
end)

local function removeCharacterFunctions(character)
    local newData = {}
    for k, v in pairs(character) do
        if type(v) ~= "function" then
            newData[k] = v
        end
    end
    return newData
end

-- Sets main character.
RegisterNetEvent("ND:characterLoaded", function(character)
    if not NDCore.player then return end
    NDCore.player = removeCharacterFunctions(character)
end)

-- Update main character info.
RegisterNetEvent("ND:updateCharacter", function(character)
    if not NDCore.player then return end
    NDCore.player = removeCharacterFunctions(character)
end)

-- Updates last lcoation.
RegisterNetEvent("ND:updateLastLocation", function(location)
    if not NDCore.player then return end
    NDCore.player.lastLocation = location
end)
