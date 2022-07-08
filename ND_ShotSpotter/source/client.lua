-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

local alreadyShot = false
local setRoute = false
local route = false

-- Suppressors hash, if a weapon has these then it won't trigger the shot spotter.
local suppresors = {
    "0x65EA7EBB", -- Pistol.
    "0x837445AA", -- Carbine Rifle, Advanced Rifle, Bullpup Rifle, Assault Shotgun, Marksman Rifle.
    "0xA73D4664", -- .50 Pistol, Micro SMG, Assault SMG, Assault Rifle, Special Carbine, Bullpup Shotgun, Heavy Shotgun, Sniper Rifle.
    "0xC304849A", -- Combat Pistol, AP Pistol, Heavy Pistol, Vintage Pistol, SMG.
    "0xE608B35E" -- Pump Shotgun.
}

-- check if the players location is inside the shot spotter locations, this will only be used in the code when realistic shot spotter is turned on.
function isInShotSpotterLocation(pedCoords)
    for _, location in pairs(config.realisticShotSpotterLocations) do
        if #(pedCoords - vector3(location.x, location.y, location.z)) < 450.0 then
            return true
        end
    end
    return false
end

-- check if the players department can receive shot spotter alerts.
function isCop()
    local selectedDepartment = exports["ND_Core"]:getCharacterInfo().department
    for _, department in pairs(config.receiveAlerts) do
        if department == selectedDepartment then
            return true
        end
    end
    return false
end

function triggerShotSpotter(ped)
    local pedCoords = GetEntityCoords(ped)
    if config.shotSpotterUsePostal then
        postal = exports[config.postalResourceName]:getPostal()
    else
        postal = false
    end

    -- if the player isn't in the realistic shot spotter locations then the shot spotter won't trigger.
    if config.useRealisticShotSpotter and not isInShotSpotterLocation(pedCoords) then
        return
    end

    -- if the player has a blacklisted weapon then the shot spotter won't trigger.
    local selectedWeapon = GetSelectedPedWeapon(ped)
    for _, weapon in pairs(config.weaponBlackList) do
        if GetHashKey(weapon) == selectedWeapon then
            return
        end
    end

    -- if the player has a suppresor attached to their weapon then the shot spotter won't trigger.
    for _, suppresor in pairs(suppresors) do
        if HasPedGotWeaponComponent(ped, selectedWeapon, tonumber(suppresor)) then
            return
        end
    end

    -- if the player is a cop then they won't trigger the shotspotter.
    if isCop() then
        return
    end

    -- the alreadyShot variable is used for checking if the player has already shot and to add a cooldown until it turns to false.
    if alreadyShot then return end
    alreadyShot = true
    Citizen.Wait(config.shotSpotterDelay * 1000)
    local zoneName = GetLabelText(GetNameOfZone(pedCoords.x, pedCoords.y, pedCoords.z))
    local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(pedCoords.x, pedCoords.y, pedCoords.z))
    TriggerServerEvent("ND_ShotSpotter:Trigger", street, pedCoords, postal, zoneName)
    Citizen.Wait(config.shotSpotterCooldown * 1000)
    alreadyShot = false
end

-- Check if the player is shooting.
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        if IsPedShooting(ped) then
            triggerShotSpotter(ped)
        end
    end
end)

RegisterNetEvent("ND_ShotSpotter:Report")
AddEventHandler("ND_ShotSpotter:Report", function(street, pedCoords, postal)
    -- if the player isn't a cop then they won't receive the alert.
    if not isCop() then
        return
    end

    -- if the player is close to the shots then they won't receive a shot spotter alert.
    if #(GetEntityCoords(PlayerPedId()) - pedCoords) < 50.0 then
        return
    end

    blip = AddBlipForCoord(pedCoords.x, pedCoords.y, pedCoords.z)
    setRoute = true
    route = false
    TriggerEvent("ND_shotSpotter:setRoute")
    notify("~w~Press ~g~G ~w~to respond to the latest shot spotter.")
    SetBlipSprite(blip, 161)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    SetBlipColour(blip, 1)
    if not postal then
        msg = "Shotspotter detected in " .. street .. "."
        AddTextComponentString("Shot Spotter: " .. street)
    else
        msg = "Shotspotter detected in " .. street .. ", postal: " .. postal .. "."
        AddTextComponentString("Shot Spotter: " .. street .. ", postal: " .. postal)
    end
    TriggerEvent("chat:addMessage", {
        color = {255, 0, 0},
        args = {"^*Dispatch ", msg}
    })
    EndTextCommandSetBlipName(blip)
    Citizen.Wait(config.shotSpotterTimer * 1000)
    RemoveBlip(blip)
    setRoute = false
    route = false
end)

-- set route to latest shot spotter location.
RegisterNetEvent("ND_shotSpotter:setRoute")
AddEventHandler("ND_shotSpotter:setRoute", function()
    while setRoute do
        Citizen.Wait(0)
        if IsControlJustPressed(0, 113) then
            if route then
                route = false
                SetBlipRoute(blip, route)
            else
                route = true
                SetBlipRoute(blip, route)
                SetBlipRouteColour(blip, 1)
            end
        end
    end
end)

if config.testing then
    Citizen.CreateThread(function()
        Citizen.Wait(0)
        for k, v in pairs(config.realisticShotSpotterLocations) do
            k = AddBlipForRadius(v.x, v.y, v.z, 450.0)
            SetBlipAlpha(k, 100)
        end
    end)
end