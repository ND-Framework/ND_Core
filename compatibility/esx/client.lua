if not lib.table.contains(Config.compatibility, "esx") then return end

NDCore.Game = {}
NDCore.Game.Utils = {}
NDCore.Scaleform = {}
NDCore.Scaleform.Utils = {}
NDCore.Streaming = {}
NDCore.UI = {}
NDCore.UI.HUD = {}
NDCore.UI.Menu = {}
NDCore.PlayerData = {}

local uiMetatable = {
    __index = function(table, key)
        if type(key) == "string" and key:match("^%a+$") then
            return function()
                print(("[^3WARNING^7] ESX Function '%s' is not compatible with NDCore!"):format(key))
            end
        end
    end
}

setmetatable(NDCore.UI, uiMetatable)
setmetatable(NDCore.UI.HUD, uiMetatable)
setmetatable(NDCore.UI.Menu, uiMetatable)

local function exportHandler(resource, exportName, cb)
    AddEventHandler(("__cfx_export_%s_%s"):format(resource, exportName), function(setCB)
        setCB(cb)
    end)
end

exportHandler("es_extended", "getSharedObject", function()
    return NDCore
end)

function NDCore.GetPlayerData()
    local player = NDCore.getPlayer()
    if not player then return {} end

    player.Accounts = {
        Bank = player.bank,
        Money = player.Cash,
        Black = player.Cash
    }

    if player.jobInfo then        
        player.job = {
            id = player.job,
            name = player.job,
            label = player.jobInfo.label,
            grade = player.jobInfo.rank,
            grade_name = player.jobInfo.rankName,
            grade_label = player.jobInfo.rankName,
            grade_salary = 0,
            skin_male = {},
            skin_female = {}
        }
    end

    player.coords = GetEntityCoords(cache.ped)
    player.loadout = {}
    player.maxWeight = GetResourceState("ox_inventory") == "started" and exports.ox_inventory:GetPlayerMaxWeight() or 0
    player.money = player.Accounts.Money
    player.sex = player.gender
    player.firstName = player.firstname
    player.lastName = player.lastname
    player.dateofbirth = player.dob
    player.height = 120
    player.dead = LocalPlayer.state.dead or false
    NDCore.PlayerData = player

    return player
end

function NDCore.IsPlayerLoaded()
    return NDCore.getPlayer() ~= nil
end

function NDCore.Progressbar(message, lenght, options)
    local newOptions = {
        duration = lenght,
        label = message,
        canCancel = true
    }

    if options.animation then        
        newOptions.anim = {}
        if options.animation.type == "anim" then            
            if options.animation.dict then
                newOptions.anim.dict = options.animation.dict
            end
            if options.animation.lib then
                newOptions.anim.clip = options.animation.lib
            end
        elseif options.animation.type == "Scenario" then
            newOptions.anim.scenario = options.animation.Scenario
        end
    end

    if options.FreezePlayer then FreezeEntityPosition(cache.ped, true) end
    local complete = lib.progressBar(newOptions)

    if options.FreezePlayer then FreezeEntityPosition(cache.ped, false) end
    if newOptions.onFinish and complete then
        newOptions.onFinish()
    end
    if newOptions.onCancel and not complete then
        newOptions.onCancel()
    end
    return complete
end

function NDCore.SearchInventory(item, count)
    local itemCount =  GetResourceState("ox_inventory") == "started" and exports.ox_inventory:Search(item) or 0
    return itemCount >= count and itemCount
end

function NDCore.SetPlayerData()
    print("[^3WARNING^7] ESX Function 'SetPlayerData' is not compatible with NDCore!")
end

function NDCore.ShowAdvancedNotification()
    print("[^3WARNING^7] ESX Function 'ShowAdvancedNotification' is not compatible with NDCore!")
end

function NDCore.ShowFloatingHelpNotification()
    print("[^3WARNING^7] ESX Function 'ShowFloatingHelpNotification' is not compatible with NDCore!")
end

function NDCore.ShowHelpNotification()
    print("[^3WARNING^7] ESX Function 'ShowHelpNotification' is not compatible with NDCore!")
end

function NDCore.ShowInventory()
    return GetResourceState("ox_inventory") == "started" and exports.ox_inventory:openInventory("player", cache.serverId)
end

function NDCore.ShowNotification(msg, type, time)
    NDCore.notify({
        title = "Notification",
        description = msg,
        type = type == "info" and "inform" or type,
        duration = time
    })
end

function NDCore.TriggerServerCallback(name, cb, ...)
    lib.callback(name, nil, cb, ...)
end

function NDCore.Streaming.RequestAnimDict(animDict, cb)
    lib.requestAnimDict(animDict)
    if cb then cb(animDict) end
    return animDict
end

function NDCore.Streaming.RequestAnimSet(animSet, cb)
    lib.requestAnimSet(animSet)
    if cb then cb(animSet) end
    return animSet
end

function NDCore.Streaming.RequestModel(model, cb)
    lib.requestModel(model)
    if cb then cb(model) end
    return model
end

function NDCore.Streaming.RequestNamedPtfxAsset(assetName, cb)
    lib.requestNamedPtfxAsset(assetName)
    if cb then cb(assetName) end
    return assetName
end

function NDCore.Streaming.RequestStreamedTextureDict(textureDict, cb)
    lib.requestStreamedTextureDict(textureDict)
    if cb then cb(textureDict) end
    return textureDict
end

function NDCore.Streaming.RequestWeaponAsset(weaponHash, cb)
    lib.requestWeaponAsset(weaponHash)
    if cb then cb(weaponHash) end
    return weaponHash
end

function NDCore.Scaleform.ShowBreakingNews()
    print("[^3WARNING^7] ESX Function 'Scaleform.ShowBreakingNews' is not compatible with NDCore!")
end

function NDCore.Scaleform.ShowFreemodeMessage()
    print("[^3WARNING^7] ESX Function 'Scaleform.ShowFreemodeMessage' is not compatible with NDCore!")
end

function NDCore.Scaleform.ShowPopupWarning()
    print("[^3WARNING^7] ESX Function 'Scaleform.ShowPopupWarning' is not compatible with NDCore!")
end

function NDCore.Scaleform.ShowTrafficMovie()
    print("[^3WARNING^7] ESX Function 'Scaleform.ShowTrafficMovie' is not compatible with NDCore!")
end

function NDCore.Scaleform.Utils.RequestScaleformMovie()
    print("[^3WARNING^7] ESX Function 'Scaleform.Utils.RequestScaleformMovie' is not compatible with NDCore!")
end

function NDCore.Game.Utils.DrawText3D(coords, text, size, font)
    local onScreen, x, y = World3dToScreen2d(coords.x, coords.y, coords.z)
    if not onScreen then return end
    SetTextScale(size or 0.4, size or 0.4)
    SetTextFont(font or 4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(true)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()
    AddTextComponentString(text)
    DrawText(x, y)
end

function NDCore.Game.DeleteObject(object)
    if not DoesEntityExist(object) then return end
    DeleteEntity(object)
end

function NDCore.Game.DeleteVehicle(vehicle)
    if not DoesEntityExist(vehicle) then return end
    DeleteEntity(vehicle)
end

function NDCore.Game.GetClosestEntity(coords)
    coords = coords or GetEntityCoords(cache.ped)
    local loc = vec3(coords.x, coords.y, coords.z)
    local entities = {lib.getClosestObject(loc), lib.getClosestPed(loc), lib.getClosestVehicle(loc)}
    local closest = nil
    local closestDistance = math.huge

    for i = 1, #entities do
        local ent = entities[i]
        if DoesEntityExist(ent.object or ent.ped or ent.vehicle) then
            local distance = #(loc-ent.coords)
            if distance < closestDistance then
                closest = ent
                closestDistance = distance
            end
        end
    end
    return closest.object or closest.ped or closest.vehicle
end

function NDCore.Game.GetClosestObject(coords)
    coords = coords or GetEntityCoords(cache.ped)
    local loc = vec3(coords.x, coords.y, coords.z)
    return lib.getClosestObject(loc).object
end

function NDCore.Game.GetClosestPed(coords)
    coords = coords or GetEntityCoords(cache.ped)
    local loc = vec3(coords.x, coords.y, coords.z)
    return lib.getClosestPed(loc).ped
end

function NDCore.Game.GetClosestPlayer(coords)
    coords = coords or GetEntityCoords(cache.ped)
    local loc = vec3(coords.x, coords.y, coords.z)
    local ply = lib.getClosestPlayer(loc)
    return ply.playerId, #(ply.playerCoords-loc)
end

function NDCore.Game.GetClosestVehicle(coords)
    coords = coords or GetEntityCoords(cache.ped)
    local loc = vec3(coords.x, coords.y, coords.z)
    return lib.getClosestVehicle(loc).vehicle
end

function NDCore.Game.GetObjects()
    return GetGamePool("CObject")
end

function NDCore.Game.GetPedMugshot()
    print("[^3WARNING^7] ESX Function 'Game.GetPedMugshot' is not compatible with NDCore!")
end

function NDCore.Game.GetPeds(onlyOtherPeds)
    local peds = GetGamePool("CPed")
    if onlyOtherPeds then
        for i=1, #peds do
            if peds[i] == cache.ped then
                table.remove(peds, i)
            end
        end
    end
    return peds
end

function NDCore.Game.GetPlayers()
    print("[^3WARNING^7] ESX Function 'Game.GetPlayers' is not compatible with NDCore!")
end

function NDCore.Game.GetPlayersInArea()
    print("[^3WARNING^7] ESX Function 'Game.GetPlayersInArea' is not compatible with NDCore!")
end

function NDCore.Game.GetPlayersInArea()
    print("[^3WARNING^7] ESX Function 'Game.GetPlayersInArea' is not compatible with NDCore!")
end

function NDCore.Game.GetVehicleInDirection()
    print("[^3WARNING^7] ESX Function 'Game.GetVehicleInDirection' is not compatible with NDCore!")
end

function NDCore.Game.GetVehicleProperties(vehicle)
    return lib.getVehicleProperties(vehicle)
end

function NDCore.Game.GetVehicles()
    return GetGamePool("CVehicle")
end

function NDCore.Game.GetVehiclesInArea()
    print("[^3WARNING^7] ESX Function 'Game.GetVehiclesInArea' is not compatible with NDCore!")
end

function NDCore.Game.IsSpawnPointClear()
    print("[^3WARNING^7] ESX Function 'Game.IsSpawnPointClear' is not compatible with NDCore!")
end

function NDCore.Game.IsVehicleEmpty(vehicle)
    for i=-1, 6 do
        if not IsVehicleSeatFree(vehicle, i) then
            return false
        end
    end
    return true
end

function NDCore.Game.SetVehicleProperties(vehicle, props)
    lib.setVehicleProperties(vehicle, props)
end

function NDCore.Game.SpawnLocalObject(model, coords, cb)
    if type(model) == "string" then
        model = GetHashKey(model)
    end
    local entity = CreateObject(model, coords.x, coords.y, coords.z, false, false, false)
    entity = lib.waitFor(function()
        if DoesEntityExist(entity) then return entity end
    end)
    if cb then cb(entity) end
    return entity
end

function NDCore.Game.SpawnLocalVehicle(model, coords, heading, cb)
    if type(model) == "string" then
        model = GetHashKey(model)
    end
    local entity = CreateVehicle(model, coords.x, coords.y, coords.z, heading, false, false, false)
    entity = lib.waitFor(function()
        if DoesEntityExist(entity) then return entity end
    end)
    if cb then cb(entity) end
    return entity
end

function NDCore.Game.SpawnObject(model, coords, cb)
    if type(model) == "string" then
        model = GetHashKey(model)
    end
    local entity = CreateObject(model, coords.x, coords.y, coords.z, true, false, false)
    entity = lib.waitFor(function()
        if DoesEntityExist(entity) then return entity end
    end)
    if cb then cb(entity) end
    return entity
end

function NDCore.Game.SpawnVehicle(model, coords, heading, cb)
    if type(model) == "string" then
        model = GetHashKey(model)
    end
    local entity = CreateVehicle(model, coords.x, coords.y, coords.z, heading, true, false, false)
    entity = lib.waitFor(function()
        if DoesEntityExist(entity) then return entity end
    end)
    if cb then cb(entity) end
    return entity
end

function NDCore.Game.Teleport(entity, coords, cb)
    if DoesEntityExist(entity) then
        RequestCollisionAtCoord(coords.x, coords.y, coords.z)
        while not HasCollisionLoadedAroundEntity(entity) do
            Wait(0)
        end

        SetEntityCoords(entity, coords.x, coords.y, coords.z, false, false, false, false)
        SetEntityHeading(entity, coords.w or coords.heading or 0.0)
    end

    if cb then
        cb()
    end
end

AddEventHandler("ND:characterLoaded", function()
    NDCore.GetPlayerData()
end)

AddEventHandler("ND:updateCharacter", function()
    NDCore.GetPlayerData()
end)
