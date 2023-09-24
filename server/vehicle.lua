local ox_inventory
local inventoryStarted = false
local playerOwnedVehicles = {}

NDCore.isResourceStarted("ox_inventory", function(started)
    inventoryStarted = started
    if not started then return end
    ox_inventory = exports.ox_inventory
end)

local function getVehicleType(model)
    local tempVehicle = CreateVehicle(model, 0, 0, 0, 0, true, true)

    local time = os.time()
    while not DoesEntityExist(tempVehicle) and time-os.time() < 5 do Wait(5) end

    if not DoesEntityExist(tempVehicle) then return end
    local entityType = GetVehicleType(tempVehicle)
    DeleteEntity(tempVehicle)
    return entityType
end

local function generatePlate()
    local plate = {}
    for i=1, 8 do
        plate[i] = math.random(0, 1) == 1 and string.char(math.random(65, 90)) or math.random(0, 9)
    end
    return table.concat(plate)
end

local function generateVehiclePlate(newPlate)
    local plate = newPlate or generatePlate()
    while MySQL.scalar.await("SELECT 1 FROM nd_vehicles WHERE plate = ?", {plate}) do
        plate = generatePlate()
    end
    return plate
end

local function createVehicleInfo(info)
    local entity = info.entity

    function info.delete()
        if not DoesEntityExist(entity) then return end
        DeleteEntity(entity)
    end

    function info.properties(props)
        if not DoesEntityExist(entity) then return end
        local state = Entity(entity).state
        state.props = type(props) == "string" and json.decode(props) or props
    end

    function info.plate(plate)
        if not DoesEntityExist(entity) or MySQL.scalar.await("SELECT 1 FROM nd_vehicles WHERE plate = ?", {plate}) then return end
        SetVehicleNumberPlateText(entity, plate)
        return true
    end

    return info
end

function NDCore.getVehicle(entity)
    if not DoesEntityExist(entity) then return end

    local state = Entity(entity).state
    local vehicleId = state.id
    if not vehicleId then return end
    
    return createVehicleInfo({
        entity = entity,
        owner = state.owner,
        id = vehicleId,
        properties = state.props,
        locked = state.locked,
        keys = state.keys,
        hotwired = state.hotwired,
        metadata = state.metadata
    })
end

function NDCore.getVehicles(characterId)
    local result = MySQL.query.await("SELECT * FROM nd_vehicles WHERE owner = ?", {characterId})
    if not result then return {} end

    local vehicles = {}
    for _, vehicle in pairs(result) do
        vehicles[#vehicles+1] = {
            available = vehicle.stored == 1,
            owner = vehicle.owner,
            id = vehicle.id,
            plate = vehicle.plate,
            properties = json.decode(vehicle.properties)
        }
    end
    return vehicles
end

function NDCore.giveVehicleAccess(source, vehicle, access, vehicleId, netId, plate, model, name, owner)
    if not vehicle or not DoesEntityExist(vehicle) then return end
    local state = Entity(vehicle).state

    if not netId then
        netId = NetworkGetNetworkIdFromEntity(vehicle)
    end
    if not vehicleId then
        vehicleId = state.id or ("temp_%s%d"):format(string.char(math.random(65, 90)), math.random(1, 999999))
    end
    if not plate then
        plate = GetVehicleNumberPlateText(vehicle)
    end
    if not model then
        model = GetEntityModel(vehicle)
    end
    if not state.id then
        state.id = vehicleId
    end

    if inventoryStarted and Config.useInventoryForKeys then
        local item = ox_inventory:GetItem(source, "keys", {vehId = vehicleId, vehNetId = netId}, true)
        local hasKey = item ~= 0
        if access and not hasKey then
            ox_inventory:AddItem(source, "keys", 1, {
                vehOwner = owner,
                vehId = vehicleId,
                vehPlate = plate,
                vehModel = name or model and lib.callback.await("ND_Vehicles:getVehicleModelMakeLabel", source, model) or "",
                keyEnabled = true,
                vehNetId = netId
            })
        elseif not access and hasKey then
            ox_inventory:RemoveItem(source, "keys", 1, {
                vehOwner = owner,
                vehId = vehicleId,
                vehPlate = plate,
                vehModel = name or model and lib.callback.await("ND_Vehicles:getVehicleModelMakeLabel", source, model) or "",
                keyEnabled = true,
                vehNetId = netId
            })
        end
    end

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
end

function NDCore.createVehicle(info)
    local owner = info.owner
    local vehicleId = info.vehicleId
    local properties = info.properties or {}
    local coords = info.coords
    local spawnCoords = coords
    local coordType = type(coords)
    if coordType == "vector3" or coordType == "table" then
        spawnCoords = vector4(coords.x, coords.y, coords.z, coords.w or coords.h or info.heading or 0.0)
    end
    if not spawnCoords then return end

    local model = info.model or properties.model
    local vehType = getVehicleType(model)
    if not vehType then return end

    local veh = CreateVehicleServerSetter(model, vehType, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnCoords.w)
    local time = os.time()
    while not DoesEntityExist(veh) and time-os.time() < 5 do Wait(5) end
    if not veh or not DoesEntityExist(veh) then return end

    local netId = NetworkGetNetworkIdFromEntity(veh)
    local state = Entity(veh).state
    state.locked = true
    local keys = info.keys or {}

    if vehicleId then
        playerOwnedVehicles[vehicleId] = {
            netid = netId,
            entity = veh
        }
    else
        vehicleId = ("temp_%s%d"):format(string.char(math.random(65, 90)), math.random(1, 999999))
    end
    if not properties.plate then
        properties.plate = generateVehiclePlate()
    end
    if owner then
        keys[owner] = true
        state.owner = owner
        state.keys = keys
    end

    state.props = properties
    state.id = vehicleId
    local vehicleName
    if inventoryStarted and Config.useInventoryForKeys then
        for charId, _ in pairs(keys) do
            local player = NDCore.getPlayers("id", charId, true)[1]
            local source = player and player.source
            if source then
                if not vehicleName then
                    vehicleName = lib.callback.await("ND_Vehicles:getVehicleModelMakeLabel", source, model) or ""
                end
                NDCore.giveVehicleAccess(source, veh, true, vehicleId, netId, properties and properties.plate, model, vehicleName, owner)
            end
        end
    end
    
    return createVehicleInfo({
        entity = veh,
        netId = netId,
        owner = owner,
        id = vehicleId,
        properties = properties,
        locked = true,
        keys = keys
    })
end

function NDCore.transferVehicle(vehicleId, fromSource, toSource)
    local playerTo = NDCore.getPlayer(toSource)
    local playerFrom = NDCore.getPlayer(fromSource)
    MySQL.query.await("UPDATE nd_vehicles SET owner = ? WHERE id = ?", {playerTo.id, vehicleId})
    
    if not playerOwnedVehicles[vehicleId] then return end
    local veh = NetworkGetEntityFromNetworkId(playerOwnedVehicles[vehicleId].netid)
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

    playerFrom.triggerEvent("ND_Vehicles:blip", playerOwnedVehicles[vehicleId].netid, false)

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
    local plate = generateVehiclePlate()
    properties.plate = plate
    local id = MySQL.insert.await("INSERT INTO nd_vehicles (owner, plate, properties, stored) VALUES (?, ?, ?, ?)", {player.id, properties.plate, json.encode(properties), stored and 1 or 0})
    local vehicles = NDCore.getVehicles(player.id)
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

function NDCore.spawnOwnedVehicle(source, vehicleId, coords, heading)
    local player = NDCore.getPlayer(source)
    if not player then return end
    local vehicles = NDCore.getVehicles(player.id)
    for _, vehicle in pairs(vehicles) do
        if vehicle.id == vehicleId and vehicle.owner == player.id then
            MySQL.query.await("UPDATE nd_vehicles SET stored = ? WHERE id = ?", {0, vehicleId})
            vehicle.available = false
            player.triggerEvent("ND_Vehicles:returnVehicles", vehicles)
            return NDCore.createVehicle({
                owner = vehicle.owner,
                model = vehicle.properties.model,
                coords = vec4(coords.x, coords.y, coords.z, coords.w or heading),
                properties = vehicle.properties,
                vehicleId = vehicleId,
                source = source
            })
        end
    end
end

function NDCore.returnVehicleToGarage(source, veh, properties)
    local player = NDCore.getPlayer(source)
    if not DoesEntityExist(veh) then return end

    local vehID = Entity(veh).state.id
    local vehicles = NDCore.getVehicles(player.id)
    
    for _, vehicle in pairs(vehicles) do
        if vehicle.owner == player.id and vehicle.id == vehID then
            MySQL.query.await("UPDATE nd_vehicles SET properties = ?, stored = ? WHERE id = ?", {json.encode(properties), 1, vehID})
            player.triggerEvent("ND_Vehicles:returnVehicles", NDCore.getVehicles(player.id))
            DeleteEntity(veh)
            return true
        end
    end
end

function NDCore.saveVehicleProperties(source, veh, properties)
    local player = NDCore.getPlayer(source)
    if not DoesEntityExist(veh) then return end

    local vehID = Entity(veh).state.id
    local vehicles = NDCore.getVehicles(player.id)
    
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

local function getNearbyVehicles(coords, range)
    local nearby = {}
    local vehicles = GetAllVehicles()
    for i=1, #vehicles do
        local veh = vehicles[i]
        local vehCoords = GetEntityCoords(veh)
        if #(coords-vehCoords) < range then
            nearby[#nearby+1] = veh
        end
    end
    return nearby
end

local function lockNearestVehicle(source, vehId, metadata)
    local ped = GetPlayerPed(source)
    local pedCoords = GetEntityCoords(ped)
    local veh = playerOwnedVehicles[vehId] and playerOwnedVehicles[vehId].entity

    if veh and DoesEntityExist(veh) then
        local vehCoords = GetEntityCoords(veh)
        if not pedCoords or not vehCoords then return end
        return toggleVehicleLock(source, veh, #(pedCoords-vehCoords) < 25.0, metadata)
    end
    
    local vehicles = getNearbyVehicles(pedCoords, 25.0)
    for i=1, #vehicles do
        local veh = vehicles[i]
        local state = Entity(veh).state
        if state and state.id == vehId then
            return toggleVehicleLock(source, veh, true, metadata)
        end
    end
end

exports("keys", function(event, item, inventory, slot, data)
    if event ~= "usingItem" or not Config.useInventoryForKeys or not inventoryStarted then return end
    local metadata
    for i=1, #inventory.items do
        local item = inventory.items[i]
        if item and item.slot == slot then
            metadata = item.metadata
            break
        end
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
    if state.owner or state.locked ~= nil then return end

    local driver = GetPedInVehicleSeat(entity, -1)
    if DoesEntityExist(driver) and IsPedAPlayer(driver) then
        state.locked = false
        state.hotwired = true
    end

    if math.random(1, 100) <= Config.randomUnlockedVehicleChance then return end
    state.locked = true
end)

RegisterNetEvent("ND_Vehicles:disableKey", function(slot)
    local src = source
    local key = ox_inventory:GetSlot(src, slot)
    local metadata = key.metadata
    if not metadata.keyEnabled then return end
    metadata.keyEnabled = false
    ox_inventory:SetMetadata(src, slot, key.metadata)
end)

