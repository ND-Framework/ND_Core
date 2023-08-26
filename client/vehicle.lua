local vehicleColorNames = {
    [0] = "Black",
    [1] = "Black",
    [2] = "Black",
    [3] = "Silver",
    [4] = "Silver",
    [5] = "Silver",
    [6] = "Gray",
    [7] = "Silver",
    [8] = "Silver",
    [9] = "Silver",
    [10] = "Metal",
    [11] = "Grey",
    [12] = "Black",
    [13] = "Gray",
    [14] = "Grey",
    [15] = "Black",
    [16] = "Black",
    [17] = "Silver",
    [18] = "Silver",
    [19] = "Metal",
    [20] = "Silver",
    [21] = "Black",
    [22] = "Graphite",
    [23] = "Silver",
    [24] = "Silver",
    [25] = "Silver",
    [26] = "Silver",
    [27] = "Red",
    [28] = "Red",
    [29] = "Red",
    [30] = "Red",
    [31] = "Red",
    [32] = "Red",
    [33] = "Red",
    [34] = "Red",
    [35] = "Red",
    [36] = "Orange",
    [37] = "Gold",
    [38] = "Orange",
    [39] = "Red",
    [40] = "Red",
    [41] = "Orange",
    [42] = "Yellow",
    [43] = "Red",
    [44] = "Red",
    [45] = "Red",
    [46] = "Red",
    [47] = "Red",
    [48] = "Red",
    [49] = "Green",
    [50] = "Green",
    [51] = "Green",
    [52] = "Green",
    [53] = "Green",
    [54] = "Green",
    [55] = "Green",
    [56] = "Green",
    [57] = "Green",
    [58] = "Green",
    [59] = "Green",
    [60] = "Green",
    [61] = "Blue",
    [62] = "Blue",
    [63] = "Blue",
    [64] = "Blue",
    [65] = "Blue",
    [66] = "Blue",
    [67] = "Blue",
    [68] = "Blue",
    [69] = "Blue",
    [70] = "Blue",
    [71] = "Blue",
    [72] = "Blue",
    [73] = "Blue",
    [74] = "Blue",
    [75] = "Blue",
    [76] = "Blue",
    [77] = "Blue",
    [78] = "Blue",
    [79] = "Bblue",
    [80] = "Blue",
    [81] = "Blue",
    [82] = "Blue",
    [83] = "Blue",
    [84] = "Blue",
    [85] = "Blue",
    [86] = "Blue",
    [87] = "Blue",
    [88] = "Yellow",
    [89] = "Yellow",
    [90] = "Bronze",
    [91] = "Yellow",
    [92] = "Lime",
    [93] = "Champagne",
    [94] = "Beige",
    [95] = "Ivory",
    [96] = "Brown",
    [97] = "Brown",
    [98] = "Brown",
    [99] = "Beige",
    [100] = "Brown",
    [101] = "Brown",
    [102] = "Beechwood",
    [103] = "Beechwood",
    [104] = "Orange",
    [105] = "Sand",
    [106] = "Sand",
    [107] = "Cream",
    [108] = "Brown",
    [109] = "Brown",
    [110] = "Brown",
    [111] = "White",
    [112] = "White",
    [113] = "Beige",
    [114] = "Brown",
    [115] = "Brown",
    [116] = "Beige",
    [117] = "Steel",
    [118] = "Steel",
    [119] = "Aluminium",
    [120] = "Chrome",
    [121] = "White",
    [122] = "White",
    [123] = "Orange",
    [124] = "Orange",
    [125] = "Green",
    [126] = "Yellow",
    [127] = "Blue",
    [128] = "Green",
    [129] = "Brown",
    [130] = "Orange",
    [131] = "White",
    [132] = "White",
    [133] = "Green",
    [134] = "White",
    [135] = "Pink",
    [136] = "pink",
    [137] = "Pink",
    [138] = "Orange",
    [139] = "Green",
    [140] = "Blue",
    [141] = "Black",
    [142] = "Black",
    [143] = "Black",
    [144] = "Green",
    [145] = "Purple",
    [146] = "Blue",
    [147] = "Black",
    [148] = "Purple",
    [149] = "Purple",
    [150] = "Red",
    [151] = "Green",
    [152] = "Green",
    [153] = "Brown",
    [154] = "Tan",
    [155] = "Green",
    [156] = "ALLOY",
    [157] = "Blue",
}

local vehicleClassNames = {
    [0] = "Compact",
    [1] = "Sedan",
    [2] = "SUV",
    [3] = "Coupe",
    [4] = "Muscle",
    [5] = "Sports Classic",
    [6] = "Sport",
    [7] = "Super",
    [8] = "Motorcycle",
    [9] = "Off-road",
    [10] = "Industrial",
    [11] = "Utility",
    [12] = "Van",
    [13] = "Cycle",
    [14] = "Boat",
    [15] = "Helicopter",
    [16] = "Plane",
    [17] = "Service",
    [18] = "Emergency",
    [19] = "Military",
    [20] = "Commercial",
    [21] = "Train",
    [22] = "Open wheel"
}

local vehicleClassNotDisableAirControl = {
    [8] = true, --motorcycle
    [13] = true, --bicycles
    [14] = true, --boats
    [15] = true, --helicopter
    [16] = true, --plane
    [19] = true --military
}

local function getVehicleBlipSprite(entity)
    if not IsEntityAVehicle(entity) then
        return 148 -- circle blip
    end

    local class = GetVehicleClass(entity)
    local model = GetEntityModel(entity)
    local classBlip = {
        [16] = 423, -- plane
        [8] = 226, -- motorcycle
        [15] = 64, -- helicopter
        [14] = 427, -- boat
        [6] = 825, -- sports
        [7] = 523, -- super
        [2] = 821, -- SUV
        [4] = 663 -- muscle
    }
    local typeBlip = {
        [`seashark`] = 471,
        [`marquis`] = 410,
        [`rhino`] = 421,
        [`hydra`] = 424,
        [`lazer`] = 424,
        [`taxi`] = 198,
        [`trash`] = 318,
        [`trash2`] = 318
    }

    return typeBlip[model] or classBlip[class] or 225 -- 255 is default car blip
end

RegisterNetEvent("ND_Vehicles:blip", function(netid, status)
    local veh = NetToVeh(netid)
    if not veh then return end
    if not status then
        local blip = GetBlipFromEntity(veh)
        if not blip or not DoesBlipExist(blip) then return end
        return RemoveBlip(blip)
    end
    local blip = AddBlipForEntity(veh)
    SetBlipSprite(blip, getVehicleBlipSprite(veh))
    SetBlipColour(blip, 0)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentSubstringPlayerName("Personal vehicle")
    EndTextCommandSetBlipName(blip)
end)

RegisterNetEvent("ND_Vehicles:syncAlarm", function(netid)
    local veh = NetToVeh(netid)
    if not veh then return end
    SetVehicleAlarmTimeLeft(veh, 1)
    SetVehicleAlarm(veh, true)
    StartVehicleAlarm(veh)
end)

RegisterNetEvent("ND_VehicleSystem:setOwnedIfNot", function(netid)
    local veh = NetToVeh(netid)
    if not veh then return end
    setVehicleOwned(veh, true)
    setVehicleLocked(veh, true)
end)

AddStateBagChangeHandler("props", nil, function(bagName, key, value, reserved, replicated)
    local entity = GetEntityFromStateBagName(bagName)
    if entity == 0 or not value then return end
    lib.setVehicleProperties(entity, value)
end)

local function playKeyFob(veh)
    local keyFob
    local ped = cache.ped
    local coords = GetEntityCoords(ped)
    if #(coords-GetEntityCoords(veh)) > 25.0 then return end

    if GetVehiclePedIsIn(ped) == 0 then
        ClearPedTasks(ped)
        lib.requestAnimDict("anim@mp_player_intmenu@key_fob@")
        TaskPlayAnim(ped, "anim@mp_player_intmenu@key_fob@", "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
        keyFob = CreateObject(`lr_prop_carkey_fob`, 0, 0, 0, true, true, true)
        AttachEntityToEntity(keyFob, ped, GetPedBoneIndex(ped, 0xDEAD), 0.12, 0.04, -0.025, -100.0, 100.0, 0.0, true, true, false, true, 1, true)
        Wait(700)
    end

    PlaySoundFromEntity(-1, "Remote_Control_Fob", ped, "PI_Menu_Sounds", true, 0)
    SetVehicleLights(veh, 2)
    Wait(100)
    SetVehicleLights(veh, 0)
    Wait(200)
    SetVehicleLights(veh, 2)
    Wait(100)
    SetVehicleLights(veh, 0)
    return keyFob and DeleteEntity(keyFob)
end

RegisterNetEvent("ND_Vehicles:keyFob", function(vehicleNetId)
    playKeyFob(NetToVeh(vehicleNetId))
end)

local dontLock = {
    [8] = true, -- Motorcycles
    [13] = true, -- Cycles
    [14] = true -- boats
}

AddStateBagChangeHandler("locked", nil, function(bagName, key, value, reserved, replicated)
    local entity = GetEntityFromStateBagName(bagName)
    if entity == 0 then return end
    if dontLock[GetVehicleClass(entity)] then return end

    if value then
        -- SetVehicleDoorsLockedForAllPlayers(entity, true)
        return SetVehicleDoorsLocked(entity, 2)
    end

    CreateThread(function()
        while GetVehiclePedIsEntering(cache.ped) == entity do Wait(10) end
        -- SetVehicleDoorsLockedForAllPlayers(entity, false)
        SetVehicleDoorsLocked(entity, 0)
    end)
end)

lib.callback.register("ND_Vehicles:getProps", function()
    local veh = GetVehiclePedIsIn(cache.ped)
    local props = lib.getVehicleProperties(veh)
    local colorPrimary, colorSecondary = GetVehicleColours(veh)
    props.colorNamePrimary = vehicleColorNames[colorPrimary]
    props.colorNameSecondary = vehicleColorNames[colorSecondary]
    props.colorName = props.colorNamePrimary == props.colorNameSecondary and props.colorNamePrimary or ("%s & %s"):format(props.colorNamePrimary, props.colorNameSecondary)
    props.className = vehicleClassNames[GetVehicleClass(veh)]
    props.makeName = GetLabelText(GetMakeNameFromVehicleModel(props.model))
    props.modelName = GetLabelText(GetDisplayNameFromVehicleModel(props.model))
    return props
end)

lib.callback.register("ND_Vehicles:getNearbyVehicleById", function(vehId)
    local coords = GetEntityCoords(cache.ped)
    local vehicles = lib.getNearbyVehicles(coords, 25.0, true)
    for i=1, #vehicles do
        local veh = vehicles[i]
        local state = Entity(veh.vehicle).state
        if state and state.id == vehId then
            return VehToNet(veh.vehicle)
        end
    end
end)

lib.callback.register("ND_Vehicles:getVehicleModelMakeLabel", function(model)
    local make = GetLabelText(GetMakeNameFromVehicleModel(model))
    local name = GetLabelText(GetDisplayNameFromVehicleModel(model))
    return ("%s %s"):format(make, name)
end)

local playerVehicle = cache.seat == -1 and cache.vehicle
local cloudTime = GetCloudTimeAsInt()
local vehicleLockCheckTime = {
    lastCheck = cloudTime,
    lastUse = cloudTime
}
local keyCheckTime = {
    lastCheck = cloudTime,
    hasKey = false
}

local function hasVehicleKeys(veh)
    local state = Entity(veh).state
    if Config.ox_inventory and Config.useInventoryForKeys then
        local metadata = {
            vehPlate = GetVehicleNumberPlateText(veh),
            keyEnabled = true
        }
        local hasKey = exports.ox_inventory:GetItemCount("keys", metadata) > 0
        return hasKey or state.hotwired
    end

    local keys = state and state.keys
    local player = NDCore.getPlayer()
    local hasKey = player and keys and keys[player.id]
    return hasKey or state.hotwired
end

local function hasVehicleKeysCheck(veh)
    local time = GetCloudTimeAsInt()
    if time-keyCheckTime.lastCheck < 5 then
        return keyCheckTime.hasKey
    end

    local hasKey = hasVehicleKeys(veh)
    keyCheckTime.lastCheck = time
    keyCheckTime.hasKey = hasKey
    return hasKey
end

local function getNearestVehicle(hasKeysForOnly)
    local coords = GetEntityCoords(cache.ped)
    local vehicles = lib.getNearbyVehicles(coords, 25.0, true)
    local nearestVeh = {}

    local function setNearestVehicle(veh)
        if hasKeysForOnly and not hasVehicleKeys(veh.vehicle) then return end
        local nearestDist = nearestVeh.dist
        local dist = #(GetEntityCoords(cache.ped)-veh.coords)
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

NDCore.isResourceStarted("ox_inventory", function(started)
    Config.ox_inventory = started
    if not started or not Config.useInventoryForKeys then
        return vehicleLockKeybind:disable(false)
    end
    Wait(1000)
    vehicleLockKeybind:disable(true)
    exports.ox_inventory:displayMetadata({
        vehPlate = "Plate",
        vehModel = "Model"
    })
end)

-- save wheels steering angle.
CreateThread(function()
    local angle = 0.0
    while true do
        Wait(300)
        if playerVehicle then
            if GetIsTaskActive(cache.ped, 2) then
                SetVehicleSteeringAngle(playerVehicle, angle)
            end
            angle = DoesEntityExist(playerVehicle) and GetVehicleSteeringAngle(playerVehicle)
        end
    end
end)

CreateThread(function()
    local wait = 500
    while true do
        Wait(wait)
        playerVehicle = cache.seat == -1 and cache.vehicle
        if playerVehicle then
            if Config.disableVehicleAirControl and not vehicleClassNotDisableAirControl[GetVehicleClass(playerVehicle)] and (IsEntityInAir(playerVehicle) or IsEntityUpsidedown(playerVehicle)) then
                wait = 0
                DisableControlAction(0, 59) -- disable vehicle air control.
                DisableControlAction(0, 60)
            elseif not GetIsVehicleEngineRunning(playerVehicle) and not hasVehicleKeysCheck(playerVehicle) then
                wait = 0
                DisableControlAction(0, 59)
                if DoesEntityExist(playerVehicle) and IsVehicleEngineStarting(playerVehicle) then
                    SetVehicleEngineOn(playerVehicle, false, true, true) -- don't turn on engine if no keys.
                end
            else
                wait = 500
            end
        elseif wait ~= 500 then
            wait = 500
        end
    end
end)
