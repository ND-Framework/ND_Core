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

RegisterNetEvent("ND_Vehicles:syncAlarm", function(netid, success, action)
    local veh = NetToVeh(netid)
    if not veh then return end
    SetVehicleAlarmTimeLeft(veh, 1)
    SetVehicleAlarm(veh, true)
    StartVehicleAlarm(veh)
    if success and action == "lockpick" then
        setVehicleLocked(veh, false)
    end
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

AddStateBagChangeHandler("locked", nil, function(bagName, key, value, reserved, replicated)
    local entity = GetEntityFromStateBagName(bagName)
    if entity == 0 then return end
    
    CreateThread(function()
        playKeyFob(entity)
    end)

    if value then
        SetVehicleDoorsLocked(entity, 4)
        return SetVehicleDoorsLocked(entity, 2)
    end

    CreateThread(function()
        while GetVehiclePedIsEntering(cache.ped) ~= 0 do Wait(10) end
        SetVehicleDoorsLocked(entity, 1)
    end)
end)

lib.callback.register("ND_Vehicles:getProps", function()
    return lib.getVehicleProperties(GetVehiclePedIsIn(cache.ped))
end)

lib.callback.register("ND_Vehicles:getNearbyVehicleById", function(vehId)
    local coords = GetEntityCoords(cache.ped)
    local vehicles = lib.getNearbyVehicles(coords, 25.0, true)
    for i=1, #vehicles do
        local veh = vehicles[i]
        local state = Entity(veh).state
        if state and state.id == vehId then
            return VehToNet(veh)
        end
    end
end)
