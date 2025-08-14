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

RegisterNetEvent("ND:teleportToMarker", function()
    local waypoint = GetFirstBlipInfoId(8)
    if not DoesBlipExist(waypoint) then
        NDCore.notify({
            title = "Error",
            description = "There is no waypoint set!",
            type = "error"
        })
        return
    end

    -- Fade out the screen for teleporting
    DoScreenFadeOut(500)
    Wait(600)  -- Wait a bit longer than the fade out time to ensure it's fully faded

    local ped = PlayerPedId()
    local coords = GetBlipInfoIdCoord(waypoint)
    local x, y, z = coords.x, coords.y, 0
    local ground
    local groundFound = false
    local groundCheckHeight = 1000.0

    for i = 0, 1000 do
        SetPedCoordsKeepVehicle(ped, x, y, groundCheckHeight, false, false, false, false)
        ground, z = GetGroundZFor_3dCoord(x, y, groundCheckHeight, false)

        if ground then
            z = z + 1.0
            groundFound = true
            break
        end

        groundCheckHeight = groundCheckHeight - 5.0
        if groundCheckHeight < 0 then break end

        Wait(0)
    end

    if not groundFound then
        return NDCore.notify({
            title = "Error",
            description = "Could not find ground, please try again!",
            type = "error"
        })
    end

    local pedHeading = GetEntityHeading(ped)
    SetPedCoordsKeepVehicle(ped, x, y, z, false, false, false, false)
    SetEntityHeading(ped, pedHeading)

    -- Fade the screen back in after teleportation
    Wait(200)  -- Small wait to ensure entity is positioned properly
    DoScreenFadeIn(800)

    NDCore.notify({
        title = "Success",
        description = "Successfully teleported to waypoint!",
        type = "success"
    })
end)

RegisterNetEvent("ND:changeWeather", function(weather)
    SetWeatherTypeOverTime(weather, 2.0)
    Wait(2000)
    SetWeatherTypeNowPersist(weather)
end)

RegisterNetEvent("ND:changeTime", function(hours, minutes)
    NetworkOverrideClockTime(hours, minutes, 0)
end)