local ox_inventory
local inventoryStarted = false
local playerOwnedVehicles = {}

NDCore.isResourceStarted("ox_inventory", function(started)
    inventoryStarted = started
    if not started then return end
    ox_inventory = exports.ox_inventory
end)

local function isPlateAvailable(plate)
    return not MySQL.scalar.await("SELECT 1 FROM nd_vehicles WHERE plate = ?", {plate})
end

local function generatePlate()
    local plate = {}
    for i = 1, 8 do
        plate[i] = math.random(0, 1) == 1 and string.char(math.random(65, 90)) or math.random(0, 9)
    end
    return table.concat(plate)
end

local function generatePlateWait()
    local plate = generatePlate()
    while not isPlateAvailable(plate) do
        plate = generatePlate()
    end
    return plate
end

local function getVehicles(characterId)
    local result = MySQL.query.await("SELECT * FROM nd_vehicles WHERE owner = ?", {characterId})
    if not result then return {} end
    local vehicles = {}
    for _, vehicle in pairs(result) do
        local key = #vehicles + 1
        vehicles[key] = {}
        vehicles[key].available = vehicle.stored == 1
        vehicles[key].owner = vehicle.owner
        vehicles[key].id = vehicle.id
        vehicles[key].plate = vehicle.plate
        vehicles[key].properties = json.decode(vehicle.properties)
    end
    return vehicles
end

function NDCore.transferVehicle(vehicleID, fromSource, toSource)
    local playerTo = NDCore.getPlayer(toSource)
    local playerFrom = NDCore.getPlayer(fromSource)
    MySQL.query.await("UPDATE nd_vehicles SET owner = ? WHERE id = ?", {playerTo.id, vehicleID})
    
    if not playerOwnedVehicles[vehicleID] then return end
    local veh = NetworkGetEntityFromNetworkId(playerOwnedVehicles[vehicleID].netid)
    if not veh then
        playerFrom.notify({
            title = "Ownership transfered",
            description = "Vehicle ownership of has been transfered.",
            type = "success",
            position = "bottom-right",
            duration = 4000
        })
        playerTo.notify({
            title = "Ownership received",
            description = "Received vehicle ownership.",
            type = "inform",
            position = "bottom-right",
            duration = 4000
        })
        return
    end
    
    local state = Entity(veh).state
    state.owner = playerTo.id
    state.keys = {
        [playerTo.id] = true
    }

    playerFrom.triggerEvent("ND_Vehicles:blip", playerOwnedVehicles[vehicleID].netid, false)

    playerFrom.notify({
        title = "Ownership transfered",
        description = ("Vehicle ownership of %s has been transfered."):format(GetVehicleNumberPlateText(veh)),
        type = "success",
        position = "bottom-right",
        duration = 4000
    })
    playerTo.notify({
        title = "Ownership received",
        description = ("Received vehicle ownership of %s."):format(GetVehicleNumberPlateText(veh)),
        type = "inform",
        position = "bottom-right",
        duration = 4000
    })
end

function NDCore.setVehicleOwned(src, properties, stored)
    local player = NDCore.getPlayer(src)
    local plate = generatePlateWait()
    properties.plate = plate
    local id = MySQL.insert.await("INSERT INTO nd_vehicles (owner, plate, properties, stored) VALUES (?, ?, ?, ?)", {player.id, properties.plate, json.encode(properties), stored and 1 or 0})
    local vehicles = getVehicles(player.id)
    player.triggerEvent("ND_Vehicles:returnVehicles", vehicles)
    return id
end

function NDCore.giveVehicleKeys(vehicle, source, target)
    local state = Entity(vehicle).state
    if not state then return end

    local player = NDCore.getPlayer(source)
    local owner = state.owner
    if not owner and owner ~= player.id then return end

    local keys = state.keys
    if not keys then return end

    local targetPlayer = NDCore.getPlayer(target)
    state.keys[targetPlayer.id] = true

    player.notify({
        title = "Keys shared",
        description = ("You've shared vehicle keys to %s."):format(GetVehicleNumberPlateText(vehicle)),
        type = "success",
        position = "bottom-right",
        duration = 4000
    })
    targetPlayer.notify({
        title = "Keys received",
        description = ("Received vehicle keys to %s."):format(GetVehicleNumberPlateText(vehicle)),
        type = "inform",
        position = "bottom-right",
        duration = 4000
    })
    return true
end

function NDCore.giveVehicleAccess(source, vehicle, access)
    local state = Entity(vehicle).state
    if not state then return end

    local player = NDCore.getPlayer(source)
    if not player then return end

    if not state.keys then
        state.keys = {
            [player.id] = access
        }
    else
        local keys = state.keys
        keys[player.id] = access
        state.keys = keys
    end

    player.triggerEvent("ND_Vehicles:setOwnedIfNot", NetworkGetNetworkIdFromEntity(vehicle))
end

local function getVehicleType(model)
    local tempVehicle = CreateVehicle(model, 0, 0, 0, 0, true, true)
    while not DoesEntityExist(tempVehicle) do Wait(0) end
    local entityType = GetVehicleType(tempVehicle)
    DeleteEntity(tempVehicle)
    return entityType
end

function NDCore.spawnOwnedVehicle(source, vehicleID, coords, heading)
    local player = NDCore.getPlayer(source)
    if not player then return end
    local vehicles = getVehicles(player.id)
    for _, vehicle in pairs(vehicles) do
        if vehicle.id == vehicleID and vehicle.owner == player.id then
            MySQL.query.await("UPDATE nd_vehicles SET stored = ? WHERE id = ?", {0, vehicleID})
            vehicle.available = false
            player.triggerEvent("ND_Vehicles:returnVehicles", vehicles)

            local model = vehicle.properties.model
            local veh = CreateVehicleServerSetter(model, getVehicleType(model), coords.x, coords.y, coords.z, coords.w or heading)
            while not DoesEntityExist(veh) do Wait(0) end

            playerOwnedVehicles[vehicle.id] = {
                netid = NetworkGetNetworkIdFromEntity(veh),
                entity = veh
            }

            local state = Entity(veh).state
            state.owner = vehicle.owner
            state.id = vehicle.id
            state.props = vehicle.properties
            state.locked = true

            if inventoryStarted and Config.useInventoryForKeys and ox_inventory:GetItem(source, "keys", {vehId = vehicle.id}, true) == 0 then
                ox_inventory:AddItem(source, "keys", 1, {
                    vehOwner = vehicle.owner,
                    vehId = vehicle.id,
                    vehPlate = vehicle.properties and vehicle.properties.plate,
                    vehModel = vehicle.properties and lib.callback.await("ND_Vehicles:getVehicleModelMakeLabel", source, vehicle.properties.model) or "",
                    keyEnabled = true
                })
            end

            state.keys = {
                [player.id] = true
            }

            return true
        end
    end
end

function NDCore.returnVehicleToGarage(source, veh, properties)
    local player = NDCore.getPlayer(source)
    if not DoesEntityExist(veh) then return end

    local vehID = Entity(veh).state.id
    local vehicles = getVehicles(player.id)
    
    for _, vehicle in pairs(vehicles) do
        if vehicle.owner == player.id and vehicle.id == vehID then
            MySQL.query.await("UPDATE nd_vehicles SET properties = ?, stored = ? WHERE id = ?", {json.encode(properties), 1, vehID})
            player.triggerEvent("ND_Vehicles:returnVehicles", getVehicles(player.id))
            DeleteEntity(veh)
            return true
        end
    end
end

function NDCore.saveVehicleProperties(source, veh, properties)
    local player = NDCore.getPlayer(source)
    if not DoesEntityExist(veh) then return end

    local vehID = Entity(veh).state.id
    local vehicles = getVehicles(player.id)
    
    for _, vehicle in pairs(vehicles) do
        if vehicle.owner == player.id and vehicle.id == vehID then
            MySQL.query.await("UPDATE nd_vehicles SET properties = ? WHERE id = ?", {json.encode(properties), vehID})
            return true
        end
    end
end

RegisterNetEvent("ND_Vehicles:lockpick", function(netId, success)
    local veh = NetworkGetEntityFromNetworkId(netId)
    local owner = NetworkGetEntityOwner(veh)
    TriggerClientEvent("ND_Vehicles:syncAlarm", owner, netId)
    if not success then return end
    local state = Entity(veh).state
    state.locked = false
end)

RegisterNetEvent("ND_Vehicles:hotwire", function(netId)
    local src = source
    local ped = GetPlayerPed(src)
    local playerVeh = GetVehiclePedIsIn(ped)
    local veh = NetworkGetEntityFromNetworkId(netId)
    if not playerVeh or playerVeh == 0 or playerVeh ~= veh then return end
    local state = Entity(veh).state
    state.hotwired = true
end)

local function toggleVehicleLock(source, veh, nearby, metadata)
    local player = NDCore.getPlayer(source)

    if metadata and not metadata.keyEnabled then
        return player.notify({
            title = "No signal",
            description = "Vehicle key disabled.",
            type = "error",
            position = "bottom-right",
            duration = 3000
        })
    elseif not nearby then
        return player.notify({
            title = "No signal",
            description = "Vehicle to far away.",
            type = "error",
            position = "bottom-right",
            duration = 3000
        })
    end

    local state = Entity(veh).state
    local locked = not state.locked
    state.locked = locked
    player.triggerEvent("ND_Vehicles:keyFob", NetworkGetNetworkIdFromEntity(veh))
    if locked then
        return player.notify({
            title = "LOCKED",
            description = "Your vehicle has now been locked.",
            type = "success",
            position = "bottom-right",
            duration = 3000
        })
    end
    player.notify({
        title = "UNLOCKED",
        description = "Your vehicle has now been unlocked.",
        type = "inform",
        position = "bottom-right",
        duration = 3000
    })
end

local function lockNearestVehicle(source, vehId, metadata)
    local veh = playerOwnedVehicles[vehId] and playerOwnedVehicles[vehId].entity
    if veh and DoesEntityExist(veh) then
        local ped = GetPlayerPed(source)
        local pedCoords = GetEntityCoords(ped)
        local vehCoords = GetEntityCoords(veh)
        if not pedCoords or not vehCoords then return end
        return toggleVehicleLock(source, veh, #(pedCoords-vehCoords) < 25.0, metadata)
    end

    lib.callback("ND_Vehicles:getNearbyVehicleById", source, function(netId)
        local veh = netId and NetworkGetEntityFromNetworkId(netId)
        if not veh then return end
        toggleVehicleLock(source, veh, true, metadata)
    end, vehId)
end

exports("keys", function(event, item, inventory, slot, data)
    if event ~= "usingItem" or not Config.useInventoryForKeys or not inventoryStarted then return end
    local metadata
    for i=1, #inventory.items do
        local item = inventory.items[i]
        if item.slot == slot then
            metadata = item.metadata
            break
        end

    if not metadata then return false end
    lockNearestVehicle(inventory.id, metadata.vehId, metadata)
    return false
end)

RegisterCommand("getkeys", function(source, args, rawCommand)
    if not Config.useInventoryForKeys or not inventoryStarted then return end
    local veh = GetVehiclePedIsIn(GetPlayerPed(source))
    if not veh or veh == 0 then return end

    local player = NDCore.getPlayer(source)
    local state = Entity(veh).state
    local owner = state.owner
    if not owner or owner ~= player.id then return end

    local props = state.props
    ox_inventory:AddItem(source, "keys", 1, {
        vehOwner = owner,
        vehId = state.id,
        vehPlate = props.plate,
        vehModel = lib.callback.await("ND_Vehicles:getVehicleModelMakeLabel", source, props.model),
        keyEnabled = true
    })
end, false)

RegisterCommand("givekeys", function(source, args, rawCommand)
    if Config.useInventoryForKeys and inventoryStarted then return end

    local src = source
    if not args[1] then return end
    local target = tonumber(args[1])
    if not GetPlayerPing(target) then return end

    local veh = GetVehiclePedIsIn(GetPlayerPed(src))
    if veh == 0 then
        veh = GetVehiclePedIsIn(GetPlayerPed(src), true)
        if veh == 0 then return end
    end
    
    NDCore.giveVehicleKeys(veh, src, target)
end, false)

RegisterNetEvent("ND_Vehicles:toggleVehicleLock", function(netId)
    if Config.useInventoryForKeys and inventoryStarted then return end

    local src = source
    local veh = NetworkGetEntityFromNetworkId(netId)
    if not DoesEntityExist(veh) then return end

    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)
    local vehCoords = GetEntityCoords(veh)
    if not pedCoords or not vehCoords then return end
    toggleVehicleLock(src, veh, #(pedCoords-vehCoords) < 25.0)
end)

RegisterNetEvent("entityCreated", function(entity)
    if not DoesEntityExist(entity) or GetEntityType(entity) ~= 2 then return end
    local state = Entity(entity).state
    if state.owner or math.random(1, 100) <= Config.randomUnlockedVehicleChance then return end
    if state.locked ~= nil then return end
    state.locked = true
end)

