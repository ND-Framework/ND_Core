local locations = require "client.vehicle.data"
local sprite = {
    ["water"] = 356,
    ["heli"] = 360,
    ["plane"] = 359,
    ["land"] = 357
}
local garageTypes = {
    ["water"] = 14,
    ["heli"] = 15,
    ["plane"] = 16
}

local clothing = {
    {
        face = {
            drawable = 1,
            texture = 1
        },
        undershirt = {
            drawable = 0,
            texture = 0
        },
        torso = {
            drawable = 1,
            texture = 1
        },
        leg = {
            drawable = 0,
            texture = 0
        },
        glasses = {
            drawable = 1,
            texture = 0
        },
        hat = {
            drawable = -1,
            texture = -1
        },
    },
    {
        leg = {
            drawable = 0,
            texture = 1
        },
        undershirt = {
            drawable = 0,
            texture = 0
        },
        face = {
            drawable = 0,
            texture = 0
        },
        torso = {
            drawable = 0,
            texture = 2
        },
        glasses = {
            drawable = -1,
            texture = -1
        },
        hat = {
            drawable = 0,
            texture = 0
        },
    },
    {
        face = {
            drawable = 0,
            texture = 2
        },
        undershirt = {
            drawable = 0,
            texture = 0
        },
        torso = {
            drawable = 1,
            texture = 2
        },
        leg = {
            drawable = 0,
            texture = 0
        },
        hat = {
            drawable = -1,
            texture = -1
        },
        glasses = {
            drawable = -1,
            texture = -1
        },
    }
}

local function getClosestOwnedVehicle()
    local coords = GetEntityCoords(cache.ped)
    local vehicles = lib.getNearbyVehicles(coords, 50.0, true)
    local nearestVeh = {}

    local function setNearestVehicle(veh)
        local state = Entity(veh.vehicle).state
        if not state.owner or state.owner ~= NDCore.player?.id then return end

        local nearestDist = nearestVeh.dist
        local dist = #(coords-veh.coords)
        if not nearestDist or dist < nearestDist then
            nearestVeh.dist = dist
            nearestVeh.coords = veh.coords
            nearestVeh.entity = veh.vehicle
        end
    end

    for i=1, #vehicles do
        setNearestVehicle(vehicles[i])
    end
    return nearestVeh.entity, nearestVeh.coords, nearestVeh.dist
end

local function parkVehicle(veh)
    if not veh or not DoesEntityExist(veh) then
        return NDCore.notify({
            title = "Garage",
            description = "No owned vehicle found nearby.",
            type = "error",
            position = "bottom",
            duration = 3000
        })
    end
    if GetPedInVehicleSeat(veh, -1) ~= 0 then
        NDCore.notify({
            title = "Garage",
            description = "Player in vehicle!",
            type = "error",
            position = "bottom",
            duration = 3000
        })
        return
    end

    local properties = lib.getVehicleProperties(veh)
    properties.class = GetVehicleClass(veh)
    TriggerServerEvent("ND_Vehicles:storeVehicle", VehToNet(veh))
end

local function isVehicleClassForGarage(class, garageType)
    if not class then return true end
    for garType, garClass in pairs(garageTypes) do
        print(garType, garageType, garClass, class)
        if garType == garageType and garClass == class then
            return true
        end
    end
end

local function getEngineStatus(health)
    if health > 950 then
        return "Perfect"
    elseif health > 750 then
        return "Good"
    elseif health > 500 then
        return "Bad"
    end
    return "Very bad"
end

local function createMenuOptions(vehicle, vehicleSpawns)
    local props = vehicle.properties
    local makeName = GetLabelText(GetMakeNameFromVehicleModel(props.model))
    local modelName = GetLabelText(GetDisplayNameFromVehicleModel(props.model))

    local metadata = {
        {label = "Plate", value = vehicle.properties.plate},
        {label = "Fuel", value = ("%d%s"):format(vehicle.properties.fuelLevel, "%")},
        {label = "Engine status", value = getEngineStatus(vehicle.properties.engineHealth)}
    }

    if not makeName or makeName == "NULL" then
        makeName = ""
    else
        metadata[#metadata+1] = {label = "Make", value = makeName}
        makeName = makeName .. " " 
    end
    if not modelName or modelName == "NULL" then
        modelName = ""
    else
        metadata[#metadata+1] = {label = "Model", value = modelName}
    end

    return {
        title = ("%s%s"):format(makeName, modelName),
        metadata = metadata,
        onSelect = function(args)
            TriggerServerEvent("ND_Vehicles:takeVehicle", vehicle.id, vehicleSpawns)
        end,
    }
end

local function createMenu(vehicles, garageType, vehicleSpawns)
    local options = {
        {
            title = "Park vehicle",
            onSelect = function(args)
                local veh = getClosestOwnedVehicle()
                parkVehicle(veh)
            end
        }
    }
    for _, vehicle in ipairs(vehicles) do
        if vehicle.available and isVehicleClassForGarage(vehicle.properties.class, garageType) then
            options[#options+1] = createMenuOptions(vehicle, vehicleSpawns)
        end
    end
    return {
        id = ("garage_%s"):format(garageType),
        title = "Parking garage",
        options = options,
        onExit = function()
            garageOpen = false
        end
    }
end

for i=1, #locations do
    local location = locations[i]
    NDCore.createAiPed({
        model = `s_m_y_airworker`,
        coords = location.ped,
        distance = 45.0,
        clothing = clothing[math.random(1, #clothing)],
        blip = {
            label = ("Parking garage (%s)"):format(location.garageType),
            sprite = sprite[location.garageType],
            scale = 0.7,
            color = 3,
            groups = location.groups
        },
        anim = {
            dict = "anim@amb@casino@valet_scenario@pose_d@",
            clip = "base_a_m_y_vinewood_01"
        },
        options = {
            {
                name = "nd_core:garagePed",
                icon = "fa-solid fa-warehouse",
                label = "View garage",
                distance = 2.0,
                canInteract = function(entity, distance, coords, name, bone)
                    if not location.groups then return true end
                    local groups = location.groups
                    local playerGroups = NDCore.player?.groups
                    for i=1, #groups do
                        if playerGroups?[groups[i]] then
                            return true
                        end
                    end
                end,
                onSelect = function(data)
                    local vehicles = lib.callback.await("ND_Vehicles:getOwnedVehicles") or {}
                    local menu = createMenu(vehicles, location.garageType, location.vehicleSpawns)
                    lib.registerContext(menu)
                    lib.showContext(menu.id)
                end
            }
        },
    })
end
