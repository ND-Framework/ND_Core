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
            title = locale("garage"),
            description = locale("no_owned_veh_nearby"),
            type = "error",
            position = "bottom",
            duration = 3000
        })
    end
    if GetPedInVehicleSeat(veh, -1) ~= 0 then
        NDCore.notify({
            title = locale("garage"),
            description = locale("player_in_veh"),
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

local function isVehicleAvailable(vehicle, garageType, impound)
    local class = vehicle.properties.class
    local available = vehicle.available and not impound or vehicle.impounded and impound
    if available and not garageTypes[garageType] then return true end
    
    for garType, garClass in pairs(garageTypes) do
        if available and garType == garageType and garClass == class then
            return true
        end
    end
end

local function getEngineStatus(health)
    if health > 950 then
        return locale("perfect")
    elseif health > 750 then
        return locale("good")
    elseif health > 500 then
        return locale("bad")
    end
    return locale("very_bad")
end

local function createMenuOptions(vehicle, vehicleSpawns)
    local props = vehicle.properties
    local makeName = GetLabelText(GetMakeNameFromVehicleModel(props.model))
    local modelName = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
    local metadata = {}

    if not makeName or makeName == "NULL" then
        makeName = ""
    else
        metadata[#metadata+1] = {label = locale("veh_make_brand"), value = makeName}
        makeName = makeName .. " " 
    end
    if not modelName or modelName == "NULL" then
        modelName = ""
    else
        metadata[#metadata+1] = {label = locale("veh_model"), value = modelName}
    end

    if props?.plate then
        metadata[#metadata+1] = {label = locale("veh_plate"), value = props.plate}
    end
    if props?.engineHealth then
        metadata[#metadata+1] = {
            label = locale("engine_status"),
            value = getEngineStatus(props.engineHealth),
            progress = props.engineHealth/10,
            colorScheme = "blue"
        }
    end

    if props?.fuelLevel then
        metadata[#metadata+1] = {
            label = "Fuel",
            value = ("%d%s"):format(props.fuelLevel, "%"),
            progress = props.fuelLevel,
            colorScheme = "yellow"
        }
    end

    return {
        title = ("%s: %s%s\n%s: %s"):format(locale("vehicle"), makeName, modelName, locale("veh_plate"), props?.plate or locale("not_found")),
        metadata = metadata,
        onSelect = function(args)
            TriggerServerEvent("ND_Vehicles:takeVehicle", vehicle.id, vehicleSpawns)
        end,
    }
end

local function createMenu(vehicles, garageType, vehicleSpawns, impound)
    local options = {}
    if not impound then
        options[#options+1] = {
            title = locale("park_veh"),
            onSelect = function(args)
                local veh = getClosestOwnedVehicle()
                parkVehicle(veh)
            end
        }
    end
    for _, vehicle in ipairs(vehicles) do
        if isVehicleAvailable(vehicle, garageType, impound) then
            options[#options+1] = createMenuOptions(vehicle, vehicleSpawns)
        end
    end
    if impound and #options == 0 then
        options[#options+1] = {
            title = locale("no_vehs_found"),
            readOnly = true
        }
    end
    return {
        id = ("garage_%s"):format(garageType),
        title = impound and locale("vehicle_impound") or locale("parking_garage"),
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
            label = location.impound and locale("impound_w_location", location.garageType) or locale("garage_w_location", location.garageType),
            sprite = location.impound and 285 or sprite[location.garageType],
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
                label = location.impound and locale("view_impounded_vehs") or locale("view_garage"),
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
                    local menu = createMenu(vehicles, location.garageType, location.vehicleSpawns, location.impound)
                    lib.registerContext(menu)
                    lib.showContext(menu.id)
                end
            }
        },
    })
end
