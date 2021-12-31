-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

local isCiv = false
local isLEO = false
local activateShotSpotter = false
local alreadyShot = false
local setRoute = false

-- Suppressors hash
local suppresors = {
    "0x65EA7EBB", -- Pistol.
    "0x837445AA", -- Carbine Rifle, Advanced Rifle, Bullpup Rifle, Assault Shotgun, Marksman Rifle.
    "0xA73D4664", -- .50 Pistol, Micro SMG, Assault SMG, Assault Rifle, Special Carbine, Bullpup Shotgun, Heavy Shotgun, Sniper Rifle.
    "0xC304849A", -- Combat Pistol, AP Pistol, Heavy Pistol, Vintage Pistol, SMG.
    "0xE608B35E" -- Pump Shotgun.
}

function notify(message)
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName(message)
	EndTextCommandThefeedPostTicker(0,1)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if setRoute then
            if IsControlJustPressed(0, 113) then
                if setRoute then
                    SetBlipRoute(blip, true)
                    SetBlipRouteColour(blip, 1)
                else
                    setRoute = false
                end
            end
        end
    end
end)

RegisterNetEvent("ND:shotSpotterReport")
AddEventHandler("ND:shotSpotterReport", function(pedCoords, postal)
    if #(GetEntityCoords(PlayerPedId()) - pedCoords) > 10.0 then -- player must be 10.0 away from the shotspotter for it to trigger.
        if isLEO and not isCiv then
            notify("~w~Press ~g~G ~w~to respond to the latest shot spotter.")
            blip = AddBlipForCoord(pedCoords.x, pedCoords.y, pedCoords.z)
            setRoute = true
            SetBlipSprite(blip, 161)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            SetBlipColour(blip, 1)
            local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(pedCoords.x, pedCoords.y, pedCoords.z))
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
        end
    end
end)

RegisterNetEvent("ND:returnDept")
AddEventHandler("ND:returnDept", function(playerDept)
    if playerDept == "CIV" then
        isCiv = true
        isLEO = false
    else
        for k, v in pairs(config.LEODepartments) do
            if playerDept == v then
                isLEO = true
                isCiv = false
            end
        end
    end
    if isCiv and not isLEO then
        Citizen.Wait(config.shotSpotterDelay * 1000)
        pedCoords = GetEntityCoords(PlayerPedId())
        if config.shotSpotterUsePostal then
            postal = exports["nearest_postal123"]:getPostal()
        else
            postal = false
        end
        TriggerServerEvent("ND:shotSpotterActive", pedCoords, postal)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        if IsPedShooting(ped) then
            if config.useRealisticShotSpotter then
                local detected = false
                for k, v in pairs(config.realisticShotSpotterLocations) do
                    if #(GetEntityCoords(ped) - vector3(v.x, v.y, v.z)) < 450.0 then
                        detected = true
                    end
                end
                if detected then
                    local selectedWeapon = GetSelectedPedWeapon(ped)
                    local hasBlackListedWeapon = false
                    local hasSuppressor = false
                    for k, v in pairs(config.weaponBlackList) do
                        if GetHashKey(v) == selectedWeapon then
                            hasBlackListedWeapon = true
                        end
                    end
                    if not hasBlackListedWeapon then
                        for k, v in pairs(suppresors) do
                            if HasPedGotWeaponComponent(ped, selectedWeapon, tonumber(v)) then
                                hasSuppressor = true
                            end
                        end
                        if not hasSuppressor and not alreadyShot then
                            alreadyShot = true
                            TriggerServerEvent("ND:getDept")
                            Citizen.Wait(config.shotSpotterCooldown * 1000)
                            alreadyShot = false
                        end
                    end
                end
            else
                local selectedWeapon = GetSelectedPedWeapon(ped)
                local hasBlackListedWeapon = false
                local hasSuppressor = false
                for k, v in pairs(config.weaponBlackList) do
                    if GetHashKey(v) == selectedWeapon then
                        hasBlackListedWeapon = true
                    end
                end
                if not hasBlackListedWeapon then
                    for k, v in pairs(suppresors) do
                        if HasPedGotWeaponComponent(ped, selectedWeapon, tonumber(v)) then
                            hasSuppressor = true
                        end
                    end
                    if not hasSuppressor and not alreadyShot then
                        alreadyShot = true
                        TriggerServerEvent("ND:getDept")
                        Citizen.Wait(config.shotSpotterCooldown * 1000)
                        alreadyShot = false
                    end
                end
            end
        end
    end
end)

if config.testing then
    Citizen.CreateThread(function()
        Citizen.Wait(1000)
        for k, v in pairs(config.realisticShotSpotterLocations) do
            k = AddBlipForRadius(v.x, v.y, v.z, 450.0)
            SetBlipAlpha(k, 100)
        end
    end)
end
