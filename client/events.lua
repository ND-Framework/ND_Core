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
    if source == "" then return end
    local veh = GetVehiclePedIsIn(cache.ped)
    local seat = cache.seat
    local coords = GetEntityCoords(cache.ped)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(cache.ped), true, true, false)

    local ped = PlayerPedId()
    if cache.ped ~= ped then
        DeleteEntity(cache.ped)
        ClearAreaOfPeds(coords.x, coords.y, coords.z, 0.2, false)
    end

    SetEntityInvincible(ped, false)
    FreezeEntityPosition(ped, false)
    SetEntityVisible(ped, true)
    SetEveryoneIgnorePlayer(ped, false)
    SetPedCanBeTargetted(ped, true)
    SetEntityCanBeDamaged(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, false)
    SetPedCanRagdollFromPlayerImpact(ped, true)
    ClearPedTasksImmediately(ped)

    if veh and veh ~= 0 then
        SetPedIntoVehicle(ped, veh, seat)
    end
end)

RegisterNetEvent("ND:characterUnloaded")
