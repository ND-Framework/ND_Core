local ambulance
local usingAmbulance = false
local alreadyEliminated = false

NDCore.isResourceStarted("ND_Ambulance", function(started)
    usingAmbulance = started
    if not usingAmbulance then return end
    ambulance = exports["ND_Ambulance"]
end)

local function PlayerEliminated(deathCause, killerServerId, killerClientId)
    if alreadyEliminated then return end
    alreadyEliminated = true
    local info = {
        deathCause = deathCause,
        killerServerId = killerServerId,
        killerClientId = killerClientId,
        damagedBones = usingAmbulance and ambulance:getBodyDamage() or {}
    }
    TriggerEvent("ND:playerEliminated", info)
    TriggerServerEvent("ND:playerEliminated", info)
    Wait(1000)
    alreadyEliminated = false
end

AddEventHandler("gameEventTriggered", function(name, args)
	if name ~= "CEventNetworkEntityDamage" then return end

	local victim = args[1]
	if not IsPedAPlayer(victim) or NetworkGetPlayerIndexFromPed(victim) ~= cache.playerId then return end

    local hit, bone = GetPedLastDamageBone(victim)
    if hit and usingAmbulance then
        local damageWeapon = ambulance:getLastDamagingWeapon(victim)
        ambulance:updateBodyDamage(bone, damageWeapon)
    end
    
    if not IsPedDeadOrDying(victim, true) or GetEntityHealth(victim) > 100 then return end

    local killerEntity, deathCause = GetPedSourceOfDeath(cache.ped), GetPedCauseOfDeath(cache.ped)
    local killerClientId = NetworkGetPlayerIndexFromPed(killerEntity)
    if killerEntity ~= cache.ped and killerClientId and NetworkIsPlayerActive(killerClientId) then
        return PlayerEliminated(deathCause, GetPlayerServerId(killerClientId), killerClientId)
    end
    PlayerEliminated(deathCause)
end)

local firstSpawn = true
exports.spawnmanager:setAutoSpawnCallback(function()
    if firstSpawn then
        firstSpawn = false
        return exports.spawnmanager:spawnPlayer() and exports.spawnmanager:setAutoSpawn(false)
    end
end)
