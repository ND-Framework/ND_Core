local target, ox_target
local locations = {}
local pedBlips = {}
local clothingComponents = {
    face = 0,
    mask = 1,
    hair = 2,
    torso = 3,
    leg = 4,
    bag = 5,
    shoes = 6,
    accessory = 7,
    undershirt = 8,
    kevlar = 9,
    badge = 10,
    torso2 = 11
}
local clothingProps = {
    hat = 0,
    glasses = 1,
    ears = 2,
    watch = 6,
    bracelets = 7
}

NDCore.isResourceStarted("ox_target", function(started)
    target = started
    if not target then return end
    ox_target = exports.ox_target
end)

local function configPed(ped)
    SetPedCanBeTargetted(ped, false)
    SetEntityCanBeDamaged(ped, false)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedCanRagdollFromPlayerImpact(ped, false)
    SetPedResetFlag(ped, 249, true)
    SetPedConfigFlag(ped, 185, true)
    SetPedConfigFlag(ped, 108, true)
    SetPedConfigFlag(ped, 208, true)
    SetPedCanRagdoll(ped, false)
end

local function setClothing(ped, clothing)
    if not clothing then return end
    for component, clothingInfo in pairs(clothing) do
        if clothingComponents[component] then
            SetPedComponentVariation(ped, clothingComponents[component], clothingInfo.drawable, clothingInfo.texture, 0)
        elseif clothingProps[component] then
            SetPedPropIndex(ped, clothingProps[component], clothingInfo.drawable, clothingInfo.texture, true)
        end
    end
end

local function groupCheck(groups, playerGroups)
    if not groups or #groups == 0 then return true end
    for i=1, #groups do
        if playerGroups and playerGroups[groups[i]] then
            return true
        end
    end
end

local function createBlip(coords, info, i)
    if not info then return end
    local groups = info.groups
    local playerGroups = NDCore.player?.groups

    local key = i or #pedBlips+1
    pedBlips[key] = {
        groups = groups,
        info = info,
        coords = coords
    }

    if not groupCheck(groups, playerGroups) then return end
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, info.sprite or 280)
    SetBlipScale(blip, info.scale or 0.8)
    SetBlipColour(blip, info.color or 3)
    SetBlipAsShortRange(blip, true)
    if info.label then                
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(info.label)
        EndTextCommandSetBlipName(blip)
    end

    pedBlips[key].blip = blip
    return blip
end

local function updateBlips(playerGroups)
    for i=1, #pedBlips do
        local blipInfo = pedBlips[i]
        local access = groupCheck(blipInfo.groups, playerGroups)
        if access and not blipInfo.blip or not DoesBlipExist(blipInfo.blip) then
            createBlip(blipInfo.coords, blipInfo.info, i)
        elseif not access and blipInfo.blip and DoesBlipExist(blipInfo.blip) then
            RemoveBlip(blipInfo.blip)
        end
    end
end

function NDCore.createAiPed(info)
    local ped
    local model = type(info.model) == "string" and GetHashKey(info.model) or info.model
    local blipInfo = info.blip
    local anim = info.anim
    local clothing = info.clothing
    local coords = info.coords
    local options = info.options
    local blip = createBlip(coords, blipInfo)
    local point = lib.points.new({
        coords = vec3(coords.x, coords.y, coords.z),
        distance = info.distance or 25.0
    })
    
    local id = #locations+1
    locations[id] = {
        point = point,
        blip = blip,
        options = info.options,
        resource = GetInvokingResource()
    }

    local found, ground = GetGroundZFor_3dCoord(coords.x, coords.y, coords.z, true)
    lib.requestModel(model, 500)

    function point:onEnter()
        ped = CreatePed(4, model, coords.x, coords.y, found and ground or coords.z, coords.w or coords.h or info.heading, false, false)

        local time = GetCloudTimeAsInt()
        while not DoesEntityExist(ped) and time-GetCloudTimeAsInt() < 5 do
            Wait(100)
        end

        configPed(ped)
        setClothing(ped, clothing)
        locations[id].ped = ped

        if anim and anim.dict and anim.clip then
            lib.requestAnimDict(anim.dict)
            TaskPlayAnim(ped, anim.dict, anim.clip, 2.0, 8.0, -1, 1, 0, 0, 0, 0)
        end

        if target and options and DoesEntityExist(ped) then
            ox_target:addLocalEntity({ped}, options)
        end
    end

    function point:onExit()
        if ped and DoesEntityExist(ped) then
            if target and options then
                ox_target:removeLocalEntity({ped})
            end
            Wait(500)
            DeleteEntity(ped)
        end
    end

    return id
end

function NDCore.removeAiPed(id)
    local info = locations[id]
    if not info then return end

    local ped = info.ped
    local blip = info.blip
    info.point:remove()
    locations[id] = nil
    
    if blip and DoesBlipExist(blip) then
        RemoveBlip(blip)
    end

    if ped and DoesEntityExist(ped) then
        if info.options then
            ox_target:removeLocalEntity({ped})
        end
        Wait(500)
        DeleteEntity(ped)
    end
end

RegisterNetEvent("ND:updateCharacter", function(character)
    Wait(3000)
    if character.id ~= NDCore.player?.id then return end
    updateBlips(character.groups)
end)

RegisterNetEvent("ND:characterLoaded", function(character)
    Wait(3000)
    if character.id ~= NDCore.player?.id then return end
    updateBlips(character.groups)
end)

AddEventHandler("onResourceStop", function(name)
    if name == GetCurrentResourceName() then
        for i, _ in ipairs(locations) do
            NDCore.removeAiPed(i)
        end
    else
        for i, v in ipairs(locations) do
            if v.resource == name then
                NDCore.removeAiPed(i)
            end
        end
    end
end)

RegisterCommand("getclothing", function(source, args, rawCommand)
    local info = ""
    for k, v in pairs(clothingComponents) do
        info = ("%s\n%s = {\n    drawable = %s,\n    texture = %s\n},"):format(info, k, GetPedDrawableVariation(cache.ped, v), GetPedTextureVariation(cache.ped, v))
    end
    for k, v in pairs(clothingProps) do
        info = ("%s\n%s = {\n    drawable = %s,\n    texture = %s\n},"):format(info, k, GetPedPropIndex(cache.ped, v), GetPedPropTextureIndex(cache.ped, v))
    end
    lib.setClipboard(info)
end, false)
