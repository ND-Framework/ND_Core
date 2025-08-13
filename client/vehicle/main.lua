local vehicleColorNames = {
    [0] = locale("veh_color_black"),
    [1] = locale("veh_color_black"),
    [2] = locale("veh_color_black"),
    [3] = locale("veh_color_silver"),
    [4] = locale("veh_color_silver"),
    [5] = locale("veh_color_silver"),
    [6] = locale("veh_color_grey"),
    [7] = locale("veh_color_silver"),
    [8] = locale("veh_color_silver"),
    [9] = locale("veh_color_silver"),
    [10] = locale("veh_color_metal"),
    [11] = locale("veh_color_grey"),
    [12] = locale("veh_color_black"),
    [13] = locale("veh_color_grey"),
    [14] = locale("veh_color_grey"),
    [15] = locale("veh_color_black"),
    [16] = locale("veh_color_black"),
    [17] = locale("veh_color_silver"),
    [18] = locale("veh_color_silver"),
    [19] = locale("veh_color_metal"),
    [20] = locale("veh_color_silver"),
    [21] = locale("veh_color_black"),
    [22] = locale("veh_color_graphite"),
    [23] = locale("veh_color_silver"),
    [24] = locale("veh_color_silver"),
    [25] = locale("veh_color_silver"),
    [26] = locale("veh_color_silver"),
    [27] = locale("veh_color_red"),
    [28] = locale("veh_color_red"),
    [29] = locale("veh_color_red"),
    [30] = locale("veh_color_red"),
    [31] = locale("veh_color_red"),
    [32] = locale("veh_color_red"),
    [33] = locale("veh_color_red"),
    [34] = locale("veh_color_red"),
    [35] = locale("veh_color_red"),
    [36] = locale("veh_color_orange"),
    [37] = locale("veh_color_gold"),
    [38] = locale("veh_color_orange"),
    [39] = locale("veh_color_red"),
    [40] = locale("veh_color_red"),
    [41] = locale("veh_color_orange"),
    [42] = locale("veh_color_yellow"),
    [43] = locale("veh_color_red"),
    [44] = locale("veh_color_red"),
    [45] = locale("veh_color_red"),
    [46] = locale("veh_color_red"),
    [47] = locale("veh_color_red"),
    [48] = locale("veh_color_red"),
    [49] = locale("veh_color_green"),
    [50] = locale("veh_color_green"),
    [51] = locale("veh_color_green"),
    [52] = locale("veh_color_green"),
    [53] = locale("veh_color_green"),
    [54] = locale("veh_color_green"),
    [55] = locale("veh_color_green"),
    [56] = locale("veh_color_green"),
    [57] = locale("veh_color_green"),
    [58] = locale("veh_color_green"),
    [59] = locale("veh_color_green"),
    [60] = locale("veh_color_green"),
    [61] = locale("veh_color_blue"),
    [62] = locale("veh_color_blue"),
    [63] = locale("veh_color_blue"),
    [64] = locale("veh_color_blue"),
    [65] = locale("veh_color_blue"),
    [66] = locale("veh_color_blue"),
    [67] = locale("veh_color_blue"),
    [68] = locale("veh_color_blue"),
    [69] = locale("veh_color_blue"),
    [70] = locale("veh_color_blue"),
    [71] = locale("veh_color_blue"),
    [72] = locale("veh_color_blue"),
    [73] = locale("veh_color_blue"),
    [74] = locale("veh_color_blue"),
    [75] = locale("veh_color_blue"),
    [76] = locale("veh_color_blue"),
    [77] = locale("veh_color_blue"),
    [78] = locale("veh_color_blue"),
    [79] = locale("veh_color_bblue"),
    [80] = locale("veh_color_blue"),
    [81] = locale("veh_color_blue"),
    [82] = locale("veh_color_blue"),
    [83] = locale("veh_color_blue"),
    [84] = locale("veh_color_blue"),
    [85] = locale("veh_color_blue"),
    [86] = locale("veh_color_blue"),
    [87] = locale("veh_color_blue"),
    [88] = locale("veh_color_yellow"),
    [89] = locale("veh_color_yellow"),
    [90] = locale("veh_color_bronze"),
    [91] = locale("veh_color_yellow"),
    [92] = locale("veh_color_lime"),
    [93] = locale("veh_color_champagne"),
    [94] = locale("veh_color_beige"),
    [95] = locale("veh_color_ivory"),
    [96] = locale("veh_color_brown"),
    [97] = locale("veh_color_brown"),
    [98] = locale("veh_color_brown"),
    [99] = locale("veh_color_beige"),
    [100] = locale("veh_color_brown"),
    [101] = locale("veh_color_brown"),
    [102] = locale("veh_color_beechwood"),
    [103] = locale("veh_color_beechwood"),
    [104] = locale("veh_color_orange"),
    [105] = locale("veh_color_sand"),
    [106] = locale("veh_color_sand"),
    [107] = locale("veh_color_cream"),
    [108] = locale("veh_color_brown"),
    [109] = locale("veh_color_brown"),
    [110] = locale("veh_color_brown"),
    [111] = locale("veh_color_white"),
    [112] = locale("veh_color_white"),
    [113] = locale("veh_color_beige"),
    [114] = locale("veh_color_brown"),
    [115] = locale("veh_color_brown"),
    [116] = locale("veh_color_beige"),
    [117] = locale("veh_color_steel"),
    [118] = locale("veh_color_steel"),
    [119] = locale("veh_color_aluminium"),
    [120] = locale("veh_color_chrome"),
    [121] = locale("veh_color_white"),
    [122] = locale("veh_color_white"),
    [123] = locale("veh_color_orange"),
    [124] = locale("veh_color_orange"),
    [125] = locale("veh_color_green"),
    [126] = locale("veh_color_yellow"),
    [127] = locale("veh_color_blue"),
    [128] = locale("veh_color_green"),
    [129] = locale("veh_color_brown"),
    [130] = locale("veh_color_orange"),
    [131] = locale("veh_color_white"),
    [132] = locale("veh_color_white"),
    [133] = locale("veh_color_green"),
    [134] = locale("veh_color_white"),
    [135] = locale("veh_color_pink"),
    [136] = locale("veh_color_pink"),
    [137] = locale("veh_color_pink"),
    [138] = locale("veh_color_orange"),
    [139] = locale("veh_color_green"),
    [140] = locale("veh_color_blue"),
    [141] = locale("veh_color_black"),
    [142] = locale("veh_color_black"),
    [143] = locale("veh_color_black"),
    [144] = locale("veh_color_green"),
    [145] = locale("veh_color_purple"),
    [146] = locale("veh_color_blue"),
    [147] = locale("veh_color_black"),
    [148] = locale("veh_color_purple"),
    [149] = locale("veh_color_purple"),
    [150] = locale("veh_color_red"),
    [151] = locale("veh_color_green"),
    [152] = locale("veh_color_green"),
    [153] = locale("veh_color_brown"),
    [154] = locale("veh_color_tan"),
    [155] = locale("veh_color_green"),
    [156] = locale("veh_color_alloy"),
    [157] = locale("veh_color_blue"),
}

local vehicleClassNames = {
    [0] = locale("veh_class_compact"),
    [1] = locale("veh_class_sedan"),
    [2] = locale("veh_class_suv"),
    [3] = locale("veh_class_coupe"),
    [4] = locale("veh_class_muscle"),
    [5] = locale("veh_class_sports_classic"),
    [6] = locale("veh_class_sport"),
    [7] = locale("veh_class_super"),
    [8] = locale("veh_class_motorcycle"),
    [9] = locale("veh_class_off_road"),
    [10] = locale("veh_class_industrial"),
    [11] = locale("veh_class_utility"),
    [12] = locale("veh_class_van"),
    [13] = locale("veh_class_cycle"),
    [14] = locale("veh_class_boat"),
    [15] = locale("veh_class_helicopter"),
    [16] = locale("veh_class_plane"),
    [17] = locale("veh_class_service"),
    [18] = locale("veh_class_emergency"),
    [19] = locale("veh_class_military"),
    [20] = locale("veh_class_commercial"),
    [21] = locale("veh_class_train"),
    [22] = locale("veh_class_open_wheel")
}

local cruiseSpeedSet = 0
local cruiseSpeedVehicle = 0
local cruiseControlEnabled = false
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

local function getVehFromNetId(netId)
    local time = GetCloudTimeAsInt()
    while not NetworkDoesNetworkIdExist(netId) or not NetworkDoesEntityExistWithNetworkId(netId) and time-GetCloudTimeAsInt() < 5 do
        Wait(100)
    end
    return NetToVeh(netId)
end

RegisterNetEvent("ND_Vehicles:blip", function(netId, status)
    local veh = getVehFromNetId(netId)
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
    AddTextComponentSubstringPlayerName(locale("personal_vehicle"))
    EndTextCommandSetBlipName(blip)
end)

RegisterNetEvent("ND_Vehicles:syncAlarm", function(netId)
    local veh = getVehFromNetId(netId)
    if not veh then return end
    SetVehicleAlarmTimeLeft(veh, 1)
    SetVehicleAlarm(veh, true)
    StartVehicleAlarm(veh)
end)

RegisterNetEvent("ND_VehicleSystem:setOwnedIfNot", function(netId)
    local veh = getVehFromNetId(netId)
    if not veh then return end
    setVehicleOwned(veh, true)
    setVehicleLocked(veh, true)
end)

AddStateBagChangeHandler("props", nil, function(bagName, key, value, reserved, replicated)
    local entity = GetEntityFromStateBagName(bagName)
    if not value or not DoesEntityExist(entity) or NetworkGetEntityOwner(entity) ~= cache.playerId then return end
    local props = value
    if type(value) == "string" then
        props = json.decode(value)
    end
    lib.setVehicleProperties(entity, props)
end)

local playingKey = 0
local function playKeyFob(veh)
    local keyFob
    local ped = cache.ped
    local coords = GetEntityCoords(ped)
    if #(coords-GetEntityCoords(veh)) > 25.0 then return end

    if not playerVehicle then
        playingKey += 1
        SetPedCurrentWeaponVisible(ped, false, false)
        ClearPedTasks(ped)
        lib.requestAnimDict("anim@mp_player_intmenu@key_fob@")
        TaskPlayAnim(ped, "anim@mp_player_intmenu@key_fob@", "fob_click_fp", 8.0, 8.0, -1, 48, 1, false, false, false)
        keyFob = CreateObject(`lr_prop_carkey_fob`, 0, 0, 0, true, true, true)
        AttachEntityToEntity(keyFob, ped, GetPedBoneIndex(ped, 0xDEAD), 0.12, 0.04, -0.025, -100.0, 100.0, 0.0, true, true, false, true, 1, true)
        Wait(700)
        SetTimeout(400, function()
            playingKey -= 1
        end)
        SetTimeout(1200, function()
            if playingKey > 0 then return end
            SetPedCurrentWeaponVisible(ped, true, false)
        end)
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

RegisterNetEvent("ND_Vehicles:keyFob", function(netId)
    playKeyFob(getVehFromNetId(netId))
end)

local dontLock = {
    [8] = true, -- Motorcycles
    [13] = true, -- Cycles
    [14] = true -- boats
}

AddStateBagChangeHandler("locked", nil, function(bagName, key, value, reserved, replicated)
    local entity = GetEntityFromStateBagName(bagName)
    if entity == 0 or value == nil or dontLock[GetVehicleClass(entity)] then return end
    
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

local function getProps(veh)
    if not veh or not DoesEntityExist(veh) then return end
    
    local props = lib.getVehicleProperties(veh)
    local colorPrimary, colorSecondary = GetVehicleColours(veh)
    if not props then return end

    props.colorNamePrimary = vehicleColorNames[colorPrimary]
    props.colorNameSecondary = vehicleColorNames[colorSecondary]
    props.colorName = props.colorNamePrimary == props.colorNameSecondary and props.colorNamePrimary or ("%s & %s"):format(props.colorNamePrimary, props.colorNameSecondary)
    props.className = vehicleClassNames[GetVehicleClass(veh)]
    props.makeName = GetLabelText(GetMakeNameFromVehicleModel(props.model))
    props.modelName = GetLabelText(GetDisplayNameFromVehicleModel(props.model))

    return props
end

lib.callback.register("ND_Vehicles:getProps", function(netId)
    local veh = getVehFromNetId(netId)
    return getProps(veh)
end)

lib.callback.register("ND_Vehicles:getPropsFromCurrentVeh", function()
    local veh = GetVehiclePedIsIn(cache.ped)
    return getProps(veh)
end)

lib.callback.register("ND_Vehicles:getVehicleModelMakeLabel", function(model)
    local make = GetLabelText(GetMakeNameFromVehicleModel(model))
    local name = GetLabelText(GetDisplayNameFromVehicleModel(model))
    if make == "NULL" then
        return name
    elseif name == "NULL" then
        return make
    end
    return ("%s %s"):format(make, name)
end)

local function hasVehicleKeys(veh, checkEngine)
    local state = Entity(veh).state
    if Config.ox_inventory and Config.useInventoryForKeys then
        local metadata = {
            vehId = state.id,
            keyEnabled = true
        }
        local hasKey = exports.ox_inventory:GetItemCount("keys", metadata) > 0
        return hasKey or checkEngine and state.hotwired
    end

    local keys = state and state.keys
    local player = NDCore.getPlayer()
    local hasKey = player and keys and keys[player.id]
    return hasKey or checkEngine and state.hotwired
end

local function hasVehicleKeysCheck(veh)
    local time = GetCloudTimeAsInt()
    if time-keyCheckTime.lastCheck < 5 then
        return keyCheckTime.hasKey
    end

    local hasKey = hasVehicleKeys(veh, true)
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

local vehicleLockKeybind = lib.addKeybind({
    name = "vehicleKey",
    description = locale("keybind_carkey"),
    defaultKey = "E",
    onPressed = function(self)
        local time = GetCloudTimeAsInt()
        if time-vehicleLockCheckTime.lastCheck < 1 and time-vehicleLockCheckTime.lastUse > 1 then
            vehicleLockCheckTime.lastUse = time
            local veh = getNearestVehicle(true)
            if not veh then return end
            TriggerServerEvent("ND_Vehicles:toggleVehicleLock", VehToNet(veh))
        end
        vehicleLockCheckTime.lastCheck = time
    end
})

NDCore.isResourceStarted("ox_inventory", function(started)
    Config.ox_inventory = started
    if not started or not Config.useInventoryForKeys then
        return vehicleLockKeybind:disable(false)
    end
    Wait(1000)
    vehicleLockKeybind:disable(true)
    exports.ox_inventory:displayMetadata({
        vehPlate = locale("veh_plate"),
        vehModel = locale("veh_model")
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

        local reset = true
        playerVehicle = cache.seat == -1 and cache.vehicle

        local entering = GetVehiclePedIsEntering(cache.ped)
        if entering and DoesEntityExist(entering) and IsVehicleNeedsToBeHotwired(entering) then
            SetVehicleNeedsToBeHotwired(entering, false)
        end
        
        if not playerVehicle then goto skip end

        if Config.disableVehicleAirControl and not vehicleClassNotDisableAirControl[GetVehicleClass(playerVehicle)] and (IsEntityInAir(playerVehicle) or IsEntityUpsidedown(playerVehicle)) then
            wait = 0
            reset = false
            DisableControlAction(0, 59) -- disable vehicle air control.
            DisableControlAction(0, 60)
        end
        if Config.requireKeys and not GetIsVehicleEngineRunning(playerVehicle) and not hasVehicleKeysCheck(playerVehicle) then
            wait = 0
            reset = false
            DisableControlAction(0, 59)
            DisableControlAction(0, 71)
            if DoesEntityExist(playerVehicle) and IsVehicleEngineStarting(playerVehicle) then
                SetVehicleEngineOn(playerVehicle, false, true, true) -- don't turn on engine if no keys.
            end
        end

        ::skip::
        if (reset or not playerVehicle) and wait ~= 500 then
            wait = 500
        end
    end
end)

local function hotwireVehicle()
    local state = playerVehicle and Entity(playerVehicle).state
    if not playerVehicle or state.hotwired then return end

    local finished = false
    lib.requestModel(`imp_prop_impexp_pliers_02`)
    lib.requestModel(`prop_tool_screwdvr01`)
    lib.requestAnimDict("veh@handler@base")

    if GetFollowVehicleCamViewMode() > 2 then
        SetFollowVehicleCamViewMode(0)
    end

    CreateThread(function()
        while not finished do
            Wait(0)
            DisableFirstPersonCamThisFrame()
        end
    end)

    local modelWithHandles = {`seashark`, `seashark2`, `seashark3`}
    local vehicleModel = GetEntityModel(playerVehicle)
    local bikeHandles = GetVehicleClass(playerVehicle) == 8 or lib.table.contains(modelWithHandles, vehicleModel)

    local success = lib.progressCircle({
        duration = math.random(10000, 20000),
        label = locale("progress_hotwiring"),
        useWhileDead = false,
        allowRagdoll = false,
        allowCuffed = false,
        allowFalling = false,
        canCancel = true,
        anim = {
            dict = bikeHandles and "anim@veh@boat@jetski@front@base" or "veh@handler@base",
            clip = "hotwire"
        },
        disable = {
            move = true,
            car = true,
            combat = true
        },
        prop = {
            {
                model = `imp_prop_impexp_pliers_02`,
                bone = 0x49D9, -- SKEL_R_Hand
                pos = vec3(0.1, -0.05, 0.0),
                rot = vec3(-1.5, -15.0, -1.5)
            },
            {
                model = `prop_tool_screwdvr01`,
                bone = 0xDEAD, -- SKEL_R_Hand
                pos = vec3(0.1, 0.08, -0.03),
                rot = vec3(90.0, 0.0, 0.0)
            }
        }
    })

    finished = true
    if not success then return end
    if not playerVehicle then return false, true end
    TriggerServerEvent("ND_Vehicles:hotwire", VehToNet(playerVehicle))
    return true, true
end

local function lockpickVehicle()
    if cache.vehicle then return end
    local pos = GetEntityCoords(cache.ped)
    local rot = GetEntityRotation(cache.ped, 2)
    local veh = lib.getClosestVehicle(pos, 2.5, false)
    if not veh then return end

    local dificulties = {
        "easy",
        "medium",
        "hard"
    }
    local dificultyTime = {
        easy = 500,
        medium = 800,
        hard = 1000
    }

    lib.requestAnimDict("veh@break_in@0h@p_m_one@")
    for i=1, Config.lockpickTries do
        TaskPlayAnimAdvanced(cache.ped, "veh@break_in@0h@p_m_one@", "std_force_entry_ds", pos.x, pos.y, pos.z+0.025, rot.x, rot.y, rot.z, 8.0, 8.0, 1800, 28, 0.1)
        local dificulty = dificulties[math.random(1, #dificulties)]
        local success = lib.skillCheck(dificulty)
        if not success or not DoesEntityExist(veh) or #(pos-GetEntityCoords(veh)) > 2.5 then
            TriggerServerEvent("ND_Vehicles:lockpick", VehToNet(veh), false)
            return false, true
        end
        Wait(dificultyTime[dificulty])
    end

    veh = lib.getClosestVehicle(pos, 2.5, false)
    if not veh then return false, true end
    TriggerServerEvent("ND_Vehicles:lockpick", VehToNet(veh), true)
    PlaySoundFromEntity(-1, "Remote_Control_Fob", cache.ped, "PI_Menu_Sounds", true, 0)
    return true, true
end

exports("lockpick", function(data, slot)
    local _, used = lockpickVehicle()
    if used then
        exports.ox_inventory:useItem(data)
    end
end)

exports("hotwire", function(data, slot)
    local _, used = hotwireVehicle()
    if used then
        exports.ox_inventory:useItem(data)
    end
end)

exports("keyControl", function(action, slot)
    for item, data in pairs(exports.ox_inventory:Items()) do
        local metadata = data.metadata
        if data.slot == slot then
            if metadata and not metadata.keyEnabled then
                return lib.notify({
                    title = locale("no_signal"),
                    description = locale("veh_key_disabled"),
                    type = "error",
                    position = "bottom-right",
                    duration = 3000
                })
            end
            break
        end
    end
    exports.ox_inventory:closeInventory()
    if action == "trunk" then
        local veh = getNearestVehicle(true)
        if not veh then return end
        playKeyFob(veh)
        if GetVehicleDoorAngleRatio(veh, 5) > 0.0 then
            SetVehicleDoorShut(veh, 5)
        else
            SetVehicleDoorOpen(veh, 5, false)
        end
    elseif action == "disable" then
        TriggerServerEvent("ND_Vehicles:disableKey", slot)
        lib.notify({
            title = locale("veh_key_disabled"),
            description = locale("veh_key_disabled2"),
            type = "inform",
            position = "bottom-right",
            duration = 3000
        })
    end
end)

local function cruiseControl()
    cruiseSpeedVehicle = GetEntitySpeed(playerVehicle) * 2.236936
    if not playerVehicle then
        lib.notify({
            title = locale("cruise_control"),
            description = locale("cruise_control_disabled"),
            type = "inform",
            position = "bottom-right",
            duration = 3000
        })
        return
    end
    if cruiseSpeedVehicle < cruiseSpeedSet/3 then
        lib.notify({
            title = locale("cruise_control"),
            description = locale("cruise_control_disabled"),
            type = "inform",
            position = "bottom-right",
            duration = 3000
        })
        return
    end
    if cruiseSpeedVehicle < cruiseSpeedSet then
        SetControlNormal(0, 71, 0.6)
    end
    return true
end

lib.addKeybind({
    name = "vehicleCruiseControl",
    description = locale("cruise_control_toggle"),
    defaultKey = "",
    onPressed = function(self)
        if cruiseControlEnabled and cruiseSpeedVehicle-1 > cruiseSpeedSet then
            cruiseSpeedSet = cruiseSpeedVehicle
            return lib.notify({
                title = locale("cruise_control"),
                description = locale("cruise_control_increase"),
                type = "inform",
                position = "bottom-right",
                duration = 3000
            })
        elseif cruiseControlEnabled then
            cruiseControlEnabled = false
            return lib.notify({
                title = locale("cruise_control"),
                description = locale("cruise_control_disabled"),
                type = "inform",
                position = "bottom-right",
                duration = 3000
            })
        end
        if not playerVehicle then return end

        local speed = math.floor(GetEntitySpeed(playerVehicle) * 2.236936)
        if speed < 10 then return end

        cruiseControlEnabled = true
        cruiseSpeedVehicle = speed
        cruiseSpeedSet = cruiseSpeedVehicle
        
        lib.notify({
            title = locale("cruise_control"),
            description = locale("cruise_control_enabled"),
            type = "inform",
            position = "bottom-right",
            duration = 3000
        })
        CreateThread(function()
            while cruiseControlEnabled and cruiseControl() do Wait(0) end
            cruiseControlEnabled = false
        end)
    end
})

lib.addKeybind({
    name = "vehicleShuffleSeat",
    description = locale("seat_shuffle"),
    defaultKey = "",
    onPressed = function(self)
        if not cache.vehicle then return end
        local seats = {
            [-1] = 0,
            [0] = -1,
            [1] = 2,
            [2] = 1,
            [3] = 4,
            [4] = 3,
            [5] = 6,
            [6] = 5
        }
        SetPedIntoVehicle(cache.ped, cache.vehicle, seats[cache.seat])
    end
})

lib.onCache("ped", function(value)
    SetPedConfigFlag(value, 184, true)
end)

lib.onCache("vehicle", function(value)
    local veh = value or cache.vehicle
    local blip = GetBlipFromEntity(veh)
    if not blip or not DoesBlipExist(blip) then return end
    SetBlipAlpha(blip, value and 0 or 255)
end)

SetTimeout(500, function()
    SetPedConfigFlag(cache.ped, 184, true)
end)
