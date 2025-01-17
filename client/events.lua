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
    local oldPed = cache.ped
    local veh = GetVehiclePedIsIn(oldPed)
    local seat = cache.seat
    local coords = GetEntityCoords(oldPed)
    local armor = GetPedArmour(oldPed)

    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(oldPed), true, true, false)

    local ped = PlayerPedId()
    if oldPed ~= ped then
        DeleteEntity(oldPed)
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
    SetPedArmour(ped, armor)

    if veh and veh ~= 0 then
        SetPedIntoVehicle(ped, veh, seat)
    end
end)

RegisterNetEvent("ND:characterUnloaded")

RegisterNetEvent("ND:clothingMenu", function()
    if GetResourceState("fivem-appearance") ~= "started" then return end
    
    local function customize(appearance)
        if not appearance then return end
        TriggerServerEvent("ND:updateClothing", appearance)
    end
    
    exports["fivem-appearance"]:startPlayerCustomization(customize, {
        ped = false,
        headBlend = true,
        faceFeatures = true,
        headOverlays = true,
        components = true,
        props = true,
        tattoos = true
    })
end)
