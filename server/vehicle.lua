local ox_inventory
local inventoryStarted = false
local spawnedPlayerVehicles = {}

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

local function generateTemporaryVehicleId()
    return ("temp_%s%d"):format(string.char(math.random(65, 90)), math.random(1, 999999))
end

local function getVehicleDatabaseInfo(vehicle)
    if not vehicle then return end
    local stored = vehicle.stored == 1
    local impounded = vehicle.impounded == 1
    return {
        id = vehicle.id,
        owner = vehicle.owner,
        plate = vehicle.plate,
        properties = json.decode(vehicle.properties) or {},
        stored = stored,
        impounded = impounded,
        stolen = vehicle.stolen == 1,
        available = not impounded and not stored
    }
end

function NDCore.getVehicleById(vehicleId)
    local result = MySQL.query.await("SELECT * FROM nd_vehicles WHERE id = ?", {vehicleId})
    return getVehicleDatabaseInfo(result?[1])
end

function NDCore.getVehicle(info)
    local infoType = type(info) == "table"
    local entity = infoType and info.entity or info
    if not DoesEntityExist(entity) then return end

    if not infoType then
        info = {}
    end

    local state = Entity(entity).state
    local self = {
        entity = entity,
        id = info.id or state.id,
        owner = info.owner or state.owner,
        keys = info.keys or state.keys,
        properties = info.properties or state.props,
        locked = info.locked or state.locked,
        hotwired = info.hotwired or state.hotwired,
        metadata = info.metadata or state.metadata,
        netId = info.netId or NetworkGetNetworkIdFromEntity(entity)
    }

    -- delete vehicle
    function self.delete()
        if not DoesEntityExist(entity) then return end
        DeleteEntity(entity)
    end

    -- set vehicle properties
    function self.setProperties(props)
        if not DoesEntityExist(entity) then return end
        local properties = type(props) == "string" and json.decode(props) or props
        local state = Entity(entity).state
        state.props = properties
        self.properties = properties
        local id = self.id
        if not id then return end
        MySQL.query.await("UPDATE nd_vehicles SET properties = ? WHERE id = ?", {json.encode(properties), id})
    end

    -- update vehicle plate
    function self.plate(plate)
        if not DoesEntityExist(entity) or MySQL.scalar.await("SELECT 1 FROM nd_vehicles WHERE plate = ?", {plate}) then return end
        if self.properties then
            self.properties.plate = plate
            local state = Entity(entity).state
            state.props = self.properties
        end

        if not self.id or not self.owner then return end
        MySQL.query("UPDATE nd_vehicles SET plate = ? WHERE id = ?", {plate, self.id})
        return true
    end

    function self.store(delete)
        if delete then
            self.delete()
        end
        if not self.id or not self.owner then return end
        MySQL.query.await("UPDATE nd_vehicles SET properties = ?, stored = ? WHERE id = ?", {json.encode(self.properties), 1, self.id})
        -- player.triggerEvent("ND_Vehicles:returnVehicles", NDCore.getVehicles(player.id))
    end

    if self.id then        
        playerOwnedVehicles[self.id] = self
    end

    return self
end

function NDCore.getVehicles(characterId)
    local result = MySQL.query.await("SELECT * FROM nd_vehicles WHERE owner = ?", {characterId})
    if not result then return {} end

    local vehicles = {}
    for _, vehicle in pairs(result) do
        local info = getVehicleDatabaseInfo(vehicle)
        if info then
            vehicles[#vehicles+1] = info
        end
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

    if not vehicleId then
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
            local playerSource = charId == owner and info.source
            if not playerSource then                
                local player = NDCore.getPlayers("id", charId, true)[1]
                playerSource = player and player.source
            end
            if playerSource then
                if not vehicleName then
                    vehicleName = lib.callback.await("ND_Vehicles:getVehicleModelMakeLabel", playerSource, model) or ""
                end
                NDCore.giveVehicleAccess(playerSource, veh, true, vehicleId, netId, properties and properties.plate, model, vehicleName, owner)
            end
        end
    end

    return NDCore.getVehicle(entity)
end

--- transfer ownership of a vehicle between players
---@param vehicleId number|string
---@param fromSource number
---@param toSource number
---@return boolean
function NDCore.transferVehicleOwnership(vehicleId, fromSource, toSource)
    local playerFrom = NDCore.getPlayer(fromSource)
    local playerTo = NDCore.getPlayer(toSource)
    if not playerFrom or not playerTo then return end

    local vehicle = NDCore.getVehicleById(vehicleId)
    if not vehicle or vehicle.owner ~= playerFrom.id then return end

    MySQL.query.await("UPDATE nd_vehicles SET owner = ? WHERE id = ?", {playerTo.id, vehicleId})
    local vehicleInfo = spawnedPlayerVehicles[vehicleId]

    if vehicleInfo then
        local veh, netId, model = vehicleInfo.entity, vehicleInfo.netId, GetEntityModel(veh)
        playerFrom.triggerEvent("ND_Vehicles:blip", netId, false)
        playerTo.triggerEvent("ND_Vehicles:blip", netId, true)

        NDCore.giveVehicleAccess(fromSource, veh, false, {
            vehicleId = vehicleId,
            netId = netId,
            model = model,
            owner = playerFrom.id
        })

        local state = Entity(veh).state
        state.owner = playerTo.id
        NDCore.giveVehicleAccess(toSource, veh, true, {
            vehicleId = vehicleId,
            netId = netId,
            model = model,
            owner = playerTo.id
        })
    end

    playerFrom.notify({
        title = "Ownership transfered",
        description = ("Vehicle ownership of %s has been transfered."):format(vehicle.plate),
        position = "bottom-right",
        type = "success"
    })
    playerTo.notify({
        title = "Ownership received",
        description = ("Received vehicle ownership of %s."):format(vehicle.plate),
        position = "bottom-right"
    })
    return true
end

--- set vehicle as owned by player
---@param playerId number
---@param properties table
---@param stored boolean
---@return vehicleId number
function NDCore.setVehicleOwned(playerId, properties, stored)
    local plate = generateVehiclePlate()
    properties.plate = plate
    return MySQL.insert.await("INSERT INTO nd_vehicles (owner, plate, properties, stored) VALUES (?, ?, ?, ?)", {playerId, plate, json.encode(properties), stored and 1 or 0})
end

--- give a player access to another players vehicle as if they are next to eachother and hand the keys.
---@param source number
---@param target number
---@param vehicle number
---@return boolean
function NDCore.shareVehicleKeys(source, target, vehicle)
    if not vehicle or not DoesEntityExist(vehicle) then return end
    
    local player = NDCore.getPlayer(source)
    local targetPlayer = NDCore.getPlayer(target)
    local state = Entity(vehicle).state
    if not targetPlayer or not player or player.id ~= state.owner then return end

    NDCore.giveVehicleAccess(target, vehicle, true)
    local plate = GetVehicleNumberPlateText(vehicle)

    player.notify({
        title = "Keys shared",
        description = ("You've shared vehicle keys to %s."):format(plate),
        position = "bottom-right",
        type = "success",
    })
    targetPlayer.notify({
        title = "Keys received",
        description = ("Received vehicle keys to %s."):format(plate),
        position = "bottom-right",
    })
    return true
end

--- spawned a vehicle that's owned by the player and checks for availability
---@param source number
---@param vehicleId number
---@param coords vector4
---@return table
function NDCore.spawnOwnedVehicle(source, vehicleId, coords, heading)
    local player = NDCore.getPlayer(src)
    if not player then return end

    local vehicle = NDCore.getVehicleById(vehicleId)
    if not vehicle or not vehicle.available or vehicle.owner ~= player.id then return end
    
    vehicle.stored = false
    MySQL.query.await("UPDATE nd_vehicles SET stored = ? WHERE id = ?", {0, vehicleId})
    return NDCore.createVehicle({
        owner = player.id,
        model = vehicle.properties.model,
        coords = vec4(coords.x, coords.y, coords.z, coords.w or coords.heading or heading),
        properties = vehicle.properties,
        vehicleId = vehicleId,
        source = source
    })
end

local function toggleVehicleLock(source, entity, nearby, metadata)
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

    local vehicle = NDCore.getVehicle(entity)
    local locked = not vehicle.locked
    vehicle.setLocked(locked)

    player.triggerEvent("ND_Vehicles:keyFob", vehicle.netId)
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
    local veh = spawnedPlayerVehicles[vehId]?.entity

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

--- inventory keys using item.
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

-- if using inventory and inventory keys players can spawn keys when in their vehicle with this command.
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

-- sync alarm when vehicle is lockpicked.
RegisterNetEvent("ND_Vehicles:lockpick", function(netId, success)
    local src = source
    local veh = NetworkGetEntityFromNetworkId(netId)
    if not veh or not DoesEntityExist(veh) then return end

    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)
    local vehCoords = GetEntityCoords(veh)
    if #(pedCoords-vehCoords) > 5.0 then return end

    local owner = NetworkGetEntityOwner(veh)
    TriggerClientEvent("ND_Vehicles:syncAlarm", owner, netId)

    if not success then return end
    local state = Entity(veh).state
    state.locked = false
end)

-- sync alarm if vehicle gets hotwired.
RegisterNetEvent("ND_Vehicles:hotwire", function(netId)
    local src = source
    local ped = GetPlayerPed(src)
    local playerVeh = GetVehiclePedIsIn(ped)
    local veh = NetworkGetEntityFromNetworkId(netId)
    if not playerVeh or playerVeh == 0 or playerVeh ~= veh then return end
    local state = Entity(veh).state
    state.hotwired = true
end)

-- lib.callback.await("ND_Vehicles:getProps", src)

RegisterCommand("test", function(src, args, rawCommand)
    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)
    NDCore.spawnOwnedVehicle(src, 35, vec4(coords.x, coords.y, coords.z, GetEntityHeading(ped)))
end, false)

RegisterCommand("test2", function(source, args, rawCommand)
    local src = source
    local properties = lib.callback.await("ND_Vehicles:getProps", src)
    NDCore.setVehicleOwned(src, properties, true)
end, false)
