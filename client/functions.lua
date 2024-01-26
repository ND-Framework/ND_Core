function NDCore.getPlayer()
    return NDCore.player
end

function NDCore.getCharacters()
    return NDCore.characters
end

function NDCore.getPlayersFromCoords(distance, coords)
    if coords then
        coords = type(coords) == "table" and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(PlayerPedId())
    end
    distance = distance or 5
    local closePlayers = {}
    local players = GetActivePlayers()
    for _, player in ipairs(players) do
        local target = GetPlayerPed(player)
        local targetCoords = GetEntityCoords(target)
        local targetdistance = #(targetCoords - coords)
        if targetdistance <= distance then
            closePlayers[#closePlayers + 1] = player
        end
    end
    return closePlayers
end

function NDCore.getConfig(info)
    if not info then
        return Config
    end
    return Config[info]
end

function NDCore.revivePlayer(reset, keepDead)
    local usingAmbulance = GetResourceState("ND_Ambulance") == "started"
    if not keepDead then
        LocalPlayer.state.dead = false
        if usingAmbulance then
            local state = Player(cache.serverId).state
            state:set("isDead", false, true)
        end
    end

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
    if reset and GetPedMovementClipset(ped) == `move_m@injured` then
        ClearEntityLastDamageEntity(ped)
        SetPedMoveRateOverride(ped, 1.0)
        ResetPedMovementClipset(ped, 0)
    end
    if reset and usingAmbulance then
        exports["ND_Ambulance"]:resetBodyDamage()
    end
end

function NDCore.notify(...)
    lib.notify(...)
end

for name, func in pairs(NDCore) do
    if type(func) == "function" then
        exports(name, func)
    end
end
