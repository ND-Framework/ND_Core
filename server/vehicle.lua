local ox_inventory
local inventoryStarted = false
local spawnedPlayerVehicles = {}
local vehicleTypes = json.decode(GetResourceKvpString("ND_Core:vehTypes") or "[]")

NDCore.isResourceStarted("ox_inventory", function(started)
    inventoryStarted = started
    if not started then return end
    ox_inventory = exports.ox_inventory
end)

local function getVehicleType(coords, model)
    if vehicleTypes[model] then
        return vehicleTypes[model]
    end

    local tempVehicle = CreateVehicle(model, coords.x, coords.y, coords.z-5.0, coords.w, true, false)
    local time = os.time()
    
    while not DoesEntityExist(tempVehicle) and os.time()-time < 5 do Wait(0) end
    if not DoesEntityExist(tempVehicle) then return end

    local vehType = GetVehicleType(tempVehicle)
    DeleteEntity(tempVehicle)

    vehicleTypes[model] = vehType
    SetResourceKvp("ND_Core:vehTypes", json.encode(vehicleTypes))

    return vehType
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
        available = not impounded and stored,
        metadata = json.decode(vehicle.metadata) or {}
    }
end

--- get vehicle information queried from the database by the vehicle id
---@param vehicleId string | numb
---@return table | nil
function NDCore.getVehicleById(vehicleId)
    local result = MySQL.query.await("SELECT * FROM nd_vehicles WHERE id = ?", {vehicleId})
    return getVehicleDatabaseInfo(result?[1])
end

--- get vehicle information and functions
---@param entity number
---@return table
function NDCore.getVehicle(entity)
    if not DoesEntityExist(entity) then return end

    local state = Entity(entity).state
    local self = {
        entity = entity,
        id = state.id,
        owner = state.owner,
        keys = state.keys,
        properties = state.props,
        locked = state.locked,
        hotwired = state.hotwired,
        metadata = state.metadata or {},
        netId = NetworkGetNetworkIdFromEntity(entity)
    }

    --- delete the vehicle
    function self.delete(saveProperties)
        if not DoesEntityExist(entity) then return end
        if saveProperties and self.id and self.owner then
            local properties = lib.callback.await("ND_Vehicles:getProps", NetworkGetEntityOwner(entity), self.netId)
            if properties then
                if self.properties?.callsign then
                    properties.callsign = true
                end
                MySQL.query("UPDATE nd_vehicles SET properties = ? WHERE id = ?", {json.encode(properties), self.id})
            end
        end
        DeleteEntity(entity)
    end


    -- remvoe vehicle from db.
    function self.remove(keepEntity)
        if not keepEntity and DoesEntityExist(entity) then
            DeleteEntity(entity)
        end
        MySQL.query("DELETE FROM nd_vehicles WHERE id = ?", {self.id})
    end

    --- set vehicle properties
    ---@param props table
    function self.setProperties(props)
        if not DoesEntityExist(entity) then return end
        local properties = type(props) == "string" and json.decode(props) or props
        local state = Entity(entity).state

        if self.properties?.callsign then
            properties.callsign = true
        end

        state.props = properties
        self.properties = properties
        
        if not self.id or not self.owner then return end
        MySQL.query("UPDATE nd_vehicles SET properties = ? WHERE id = ?", {json.encode(properties), self.id})
    end

    --- set vehicle locked/unlocked
    ---@param status boolean
    function self.setLocked(status)
        if not DoesEntityExist(entity) then return end
        local state = Entity(entity).state
        state.locked = status
        self.locked = status
    end

    --- update the vehicle plate
    ---@param plate string
    ---@return boolean
    function self.setPlate(plate)
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

    --- set the vehicle availability status
    ---@param statusType string
    ---@param status boolean
    function self.setStatus(statusType, status)
        if not lib.table.contains({"stored", "impounded", "stolen"}, statusType) then return end
        if statusType ~= "stolen" then self.delete(true) end
        if not self.id or not self.owner then return end
        local query = ("UPDATE nd_vehicles SET %s = ? WHERE id = ?"):format(statusType)
        MySQL.query(query, {status and 1 or 0, self.id})
        return true
    end

    function self.setMetadata(key, value)
        self.metadata[key] = value
        if DoesEntityExist(entity) then
            local state = Entity(self.entity).state
            local metadata = state.metadata
            metadata[key] = value
            state.metadata = metadata
        end
        if not self.id or not self.owner then return end
        MySQL.query("UPDATE nd_vehicles SET metadata = ? WHERE id = ?", {json.encode(self.metadata), self.id})
    end

    if self.id and self.owner then
        spawnedPlayerVehicles[self.id] = self
    end

    return self
end

--- get a characters owned vehicles
---@param characterId number
---@return table
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

--- give a player keys/access to a vehicle
---@param source number
---@param vehicle number
---@param access boolean
---@param info table
function NDCore.giveVehicleAccess(source, vehicle, access, info)
    if not vehicle or not DoesEntityExist(vehicle) then return end
    local state = Entity(vehicle).state
    local netId = info?.netId or NetworkGetNetworkIdFromEntity(vehicle)
    local vehicleId = info?.vehicleId or state.id or generateTemporaryVehicleId()

    if not state.id then
        state.id = vehicleId
    end

    local player = NDCore.getPlayer(source)
    if player then
        local keys = state.keys or {}
        keys[player.id] = access
        state.keys = keys
    end

    if not inventoryStarted or not Config.useInventoryForKeys then return end
    local plate = info?.plate or GetVehicleNumberPlateText(vehicle)
    local model = info?.model or GetEntityModel(vehicle)
    local modelName = info?.modelName or model and lib.callback.await("ND_Vehicles:getVehicleModelMakeLabel", source, model) or ""
    local hasKey = ox_inventory:GetSlotIdWithItem(source, "keys", {
        vehId = vehicleId
    })

    if access and not hasKey then
        ox_inventory:AddItem(source, "keys", 1, {
            vehOwner = owner or state.owner,
            vehId = vehicleId,
            vehPlate = plate,
            vehModel = modelName,
            keyEnabled = true,
            vehNetId = netId
        })
    elseif not access and hasKey then
        ox_inventory:RemoveItem(source, "keys", 1, nil, hasKey)
    end
end

--- spawn a vehicle, set info & give keys.
---@param info table
---@return table
function NDCore.createVehicle(info)
    local owner = info.owner
    local vehicleId = info.vehicleId or generateTemporaryVehicleId()
    local properties = info.properties or {}
    local coords = info.coords
    local spawnCoords = coords

    local coordType = type(coords)
    if coordType == "vector3" or coordType == "table" then
        spawnCoords = vector4(coords.x, coords.y, coords.z, coords.w or coords.h or info.heading or 0.0)
    end
    if not spawnCoords then
        return Citizen.Trace("NDCore.createVehicle", "spawnCoords not found")
    end

    local model = info.model or properties.model
    local vehType = getVehicleType(spawnCoords, model)
    if not vehType then
        return Citizen.Trace("NDCore.createVehicle", "vehType not found")
    end

    local veh = CreateVehicleServerSetter(model, vehType, spawnCoords.x, spawnCoords.y, spawnCoords.z, spawnCoords.w)
    local time = os.time()
    while not DoesEntityExist(veh) and os.time()-time < 5 do Wait(5) end
    if not veh or not DoesEntityExist(veh) then
        return Citizen.Trace("NDCore.createVehicle", "vehicle entity doesn't exist")
    end

    local netId = NetworkGetNetworkIdFromEntity(veh)
    local state = Entity(veh).state
    state.locked = true
    local keys = info.keys or {}

    if not properties.plate then
        properties.plate = generateVehiclePlate()
    end
    if owner then
        keys[owner] = true
        state.owner = owner
    end

    state.keys = keys
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
                NDCore.giveVehicleAccess(playerSource, veh, true, {
                    vehicleId = vehicleId,
                    netId = netId,
                    plate = properties?.plate,
                    model = model,
                    vehicleName = vehicleName,
                    owner = owner
                })
            end
        end
    end

    return NDCore.getVehicle(veh)
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
    local player = NDCore.getPlayer(source)
    if not player then return end

    local vehicle = NDCore.getVehicleById(vehicleId)
    if not vehicle or vehicle.owner ~= player.id then return end
    if not vehicle.available and not vehicle.impounded then return end

    MySQL.query.await("UPDATE nd_vehicles SET stored = ? WHERE id = ?", {0, vehicleId})

    local properties = vehicle.properties
    if properties.callsign then
        local callsign = player.getMetadata("callsign")
        if not callsign or callsign == "" then goto skip end
        
        callsign = tostring(callsign)
        if not callsign or callsign:len() ~= 3 then goto skip end

        properties.modFender = tonumber(callsign:sub(1, 1))
        properties.modRightFender = tonumber(callsign:sub(2, 2))
        properties.modRoof = tonumber(callsign:sub(3, 3))
    end

    ::skip::

    return NDCore.createVehicle({
        owner = player.id,
        model = properties.model,
        coords = vec4(coords.x, coords.y, coords.z, coords.w or coords.heading or heading),
        properties = properties,
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
        keyEnabled = true,
        vehNetId = NetworkGetNetworkIdFromEntity(veh)
    })
end, false)

-- key sharing if not using inventory or inventory keys.
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
    
    NDCore.shareVehicleKeys(src, target, veh)
end, false)

-- lock/unlock vehicles if they're within range.
RegisterNetEvent("ND_Vehicles:toggleVehicleLock", function(netId)
    if Config.useInventoryForKeys and inventoryStarted then return end

    local src = source
    local veh = NetworkGetEntityFromNetworkId(netId)
    if not veh or not DoesEntityExist(veh) then return end

    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)
    local vehCoords = GetEntityCoords(veh)
    if not pedCoords or not vehCoords then return end
    toggleVehicleLock(src, veh, #(pedCoords-vehCoords) < 25.0)
end)

-- locking of npc vehicles, if the players spawns inside a vehicle it won't be locked.
AddEventHandler("entityCreated", function(entity)
    local time = os.time()
    while not DoesEntityExist(entity) and os.time()-time < 5 do Wait(50) end

    if not DoesEntityExist(entity) or GetEntityType(entity) ~= 2 then return end

    local state = Entity(entity).state
    if state.owner or state.locked ~= nil then return end

    time = os.time()
    local driver = GetPedInVehicleSeat(entity, -1)
    while DoesEntityExist(entity) and driver == 0 and os.time()-time < 2 do
        driver = GetPedInVehicleSeat(entity, -1)
        Wait(100)
    end

    if not DoesEntityExist(entity) then return end

    if DoesEntityExist(driver) and IsPedAPlayer(driver) then
        state.locked = false
        state.hotwired = true
    end

    if math.random(1, 100) <= Config.randomUnlockedVehicleChance then return end
    state.locked = true
end)

-- disables inventory vehicles keys, disabled vehicles keys can no longer be used. Kinda like taking the battery out.
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

RegisterNetEvent("ND_Vehicles:storeVehicle", function(netId)
    local src = source
    local vehicle = NDCore.getVehicle(NetworkGetEntityFromNetworkId(netId))
    if not vehicle then return end
    
    local player = NDCore.getPlayer(src)
    if not vehicle.setStatus("stored", true) or not player or player.id ~= vehicle.owner then
        return player.notify({
            title = "Garage",
            description = "No owned vehicle found nearby.",
            type = "error",
            position = "bottom",
            duration = 3000
        })
    end
    player.notify({
        title = "Garage",
        description = "Vehicle stored in garage.",
        type = "success",
        position = "bottom",
        duration = 3000
    })
    NDCore.giveVehicleAccess(src, vehicle.entity, false, {
        vehicleId = vehicle.id,
        netId = vehicle.netId,
        owner = vehicle.owner
    })
end)

local function isParkingAvailable(locations)
    for i=1, #locations do
        local loc = locations[math.random(1, #locations)]
        if #getNearbyVehicles(vec3(loc.x, loc.y, loc.z), 2.0) == 0 then
            return loc
        end
    end
end

RegisterNetEvent("ND_Vehicles:takeVehicle", function(vehId, locations)
    local src = source
    local vehicle = NDCore.getVehicleById(vehId)
    local player = NDCore.getPlayer(src)
    if not player or not vehicle or vehicle.owner ~= player.id then return end

    local info = NDCore.spawnOwnedVehicle(src, vehicle.id, isParkingAvailable(locations))
    if not info then return end
    TriggerClientEvent("ND_Vehicles:blip", src, info.netId, true)

    if vehicle.impounded then
        local reclaimPrice = vehicle.metadata.impoundReclaimPrice or 200
        if not player.deductMoney("bank", reclaimPrice, "Vehicle impound reclaim") then
            return player.notify({
                title = "Impound",
                description = ("Price to reclaim is $%d, you don't have enough!"):format(reclaimPrice),
                type = "error",
                position = "bottom"
            })
        end
        player.notify({
            title = "Impound",
            description = ("Paid $%d to reclaim vehicle!"):format(reclaimPrice),
            type = "success",
            position = "bottom"
        })
        MySQL.query.await("UPDATE nd_vehicles SET impounded = ? WHERE id = ?", {0, vehicle.id})
    end
end)

lib.callback.register("ND_Vehicles:getOwnedVehicles", function(src)
    local player = NDCore.getPlayer(src)
    if not player then return end
    return NDCore.getVehicles(player.id)
end)

AddEventHandler("ND:characterLoaded", function(player)
    local ownedExistingVehicles = {}
    local ownedVehicles = NDCore.getVehicles(player.id)
    local vehicles = GetAllVehicles()
    local vehiclesToImpound = {}
    
    for i=1, #vehicles do
        local veh = vehicles[i]
        local state = Entity(veh).state
        if state.owner == player.id then
            ownedExistingVehicles[#ownedExistingVehicles+1] = state.id
        end
    end

    for i=1, #ownedVehicles do
        local veh = ownedVehicles[i]
        if veh and not veh.stored and not veh.impounded and not lib.table.contains(ownedExistingVehicles, veh.id) then
            vehiclesToImpound[#vehiclesToImpound+1] = veh.id
        end
    end

    if #vehiclesToImpound == 0 then return end

    local query = ("UPDATE nd_vehicles SET impounded = ? WHERE owner = ? AND id IN (%s)"):format(table.concat(vehiclesToImpound, ", "))
    MySQL.rawExecute(query, {1, player.id})
end)
