local playerOwnedVehicles = {}

local function isPlateAvailable(plate)
    return not MySQL.scalar.await("SELECT 1 FROM vehicles WHERE plate = ?", {plate})
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
    local result = MySQL.query.await("SELECT * FROM vehicles WHERE owner = ?", {characterId})
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
        playerFrom:notify({
            title = "Ownership transfered",
            description = "Vehicle ownership of has been transfered.",
            type = "success",
            position = "bottom-right",
            duration = 4000
        })
        playerTo:notify({
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

    playerFrom:triggerEvent("ND_Vehicles:blip", playerOwnedVehicles[vehicleID].netid, false)

    playerFrom:notify({
        title = "Ownership transfered",
        description = ("Vehicle ownership of %s has been transfered."):format(GetVehicleNumberPlateText(veh)),
        type = "success",
        position = "bottom-right",
        duration = 4000
    })
    playerTo:notify({
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
    local id = MySQL.insert.await("INSERT INTO vehicles (owner, plate, properties, stored) VALUES (?, ?, ?, ?)", {player.id, properties.plate, json.encode(properties), stored and 1 or 0})
    local vehicles = getVehicles(player.id)
    player:triggerEvent("ND_Vehicles:returnVehicles", vehicles)
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

    player:notify({
        title = "Keys shared",
        description = ("You've shared vehicle keys to %s."):format(GetVehicleNumberPlateText(vehicle)),
        type = "success",
        position = "bottom-right",
        duration = 4000
    })
    targetPlayer:notify({
        title = "Keys received",
        description = ("Received vehicle keys to %s."):format(GetVehicleNumberPlateText(vehicle)),
        type = "inform",
        position = "bottom-right",
        duration = 4000
    })
    return true
end

function NDCore.giveVehicleAccess(source, vehicle)
    local state = Entity(vehicle).state
    if not state then return end

    local player = NDCore.getPlayer(source)
    if not player then return end

    if not state.keys then
        state.keys = {
            [player.id] = true
        }
    else
        local keys = state.keys
        keys[player.id] = true
        state.keys = keys
    end

    player:triggerEvent("ND_Vehicles:setOwnedIfNot", NetworkGetNetworkIdFromEntity(vehicle))
end

local function isParkingAvailable(source, coords)
    local tries = 1
    while tries < #coords do
        Wait(300)
        local coord = coords[math.random(1, #coords)]
        local available = lib.callback.await("ND_Vehicles:getParkedVehicle", source, vector3(coord.x, coord.y, coord.z))
        if available then
            return coord
        end
        tries += 1
    end
    return false
end

local function getVehicleType(model)
    local tempVehicle = CreateVehicle(model, 0, 0, 0, 0, false, false)
    while not DoesEntityExist(tempVehicle) do Wait(0) end
    local entityType = GetVehicleType(tempVehicle)
    DeleteEntity(tempVehicle)
    return entityType
end

function NDCore.spawnOwnedVehicle(source, vehicleID, coords)
    local player = NDCore.getPlayer(source)
    local spawnCoords = coords

    if type(coords) == "table" then
        spawnCoords = isParkingAvailable(source, coords)
        if not spawnCoords then
            player:notify({
                title = "Can't bring out vehicle",
                description = "No parking spot available for your vehicle. It's still in your garage.",
                type = "error",
                position = "bottom",
                duration = 4000
            })
            return
        end
    end

    local vehicles = getVehicles(player.id)
    for _, vehicle in pairs(vehicles) do
        if vehicle.owner == player.id and vehicle.id == vehicleID then
            MySQL.query.await("UPDATE vehicles SET stored = ? WHERE id = ?", {0, vehicleID})
            player:triggerEvent("ND_VehicleSystem:returnVehicles", getVehicles(player.id))

            local veh = CreateVehicleServerSetter(vehicle.properties.model, getVehicleType(vehicle.properties.model), spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnCoords.w)
            while not DoesEntityExist(veh) do Wait(0) end

            playerOwnedVehicles[vehicle.id] = {
                netid = NetworkGetNetworkIdFromEntity(veh)
            }

            local state = Entity(veh).state
            state.owner = vehicle.owner
            state.id = vehicle.id
            state.props = vehicle.properties
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
            MySQL.query.await("UPDATE vehicles SET properties = ?, stored = ? WHERE id = ?", {json.encode(properties), 1, vehID})
            player:triggerEvent("ND_Vehicles:returnVehicles", getVehicles(player.id))
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
            MySQL.query.await("UPDATE vehicles SET properties = ? WHERE id = ?", {json.encode(properties), vehID})
            return true
        end
    end
end

RegisterNetEvent("ND_Vehicles:syncAlarm", function(netid, success, action)
    local veh = NetworkGetEntityFromNetworkId(netid)
    local owner = NetworkGetEntityOwner(veh)
    TriggerClientEvent("ND_Vehicles:syncAlarm", owner, netid, success, action)
end)

if Config.useInventoryForKeys then
    RegisterCommand("getkeys", function(source, args, rawCommand)
        local veh = GetVehiclePedIsIn(GetPlayerPed(source))
        if not veh or veh == 0 then return end

        local player = NDCore.getPlayer(source)
        local state = Entity(veh).state
        local owner = state.owner
        if not owner or owner ~= player.id then return end

        local props = state.props
        local keys = state.keys
        keys[player.id] = true
        state.keys = keys

        exports.ox_inventory:AddItem(source, "keys", 1, {
            vehOwner = owner,
            vehId = state.id,
            vehPlate = props.plate,
            vehModel = props.model
        })
    end, false)
else
    RegisterCommand("givekeys", function(source, args, rawCommand)
        local src = source
        if not args[1] then return end
        local target = tonumber(args[1])
        if not GetPlayerPing(target) then return end

        local veh = GetVehiclePedIsIn(GetPlayerPed(src))
        if veh == 0 then
            veh = GetVehiclePedIsIn(GetPlayerPed(src), true)
            if veh == 0 then return end
        end
        
        giveKeys(veh, src, target)
    end, false)
end
