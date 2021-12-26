-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

local isCiv = false
local isLEO = false
local activateShotSpotter = false
local alreadyShot = false

RegisterNetEvent("ND:shotSpotterReport")
AddEventHandler("ND:shotSpotterReport", function(x, y, z, postal)
    for i = 1, #config.LEODepartments do
        if exports["ND_Core"]:getCharacterInfo(6) == config.LEODepartments[i] then
            isLEO = true
        end
    end
    if isLEO and not isCiv then
        blip = AddBlipForCoord(x, y, z)
        SetBlipSprite(blip, 161)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        local street = GetStreetNameFromHashKey(GetStreetNameAtCoord(x, y, z))
        if not postal then
            msg = "Shotspotter detected in " .. street .. "."
            AddTextComponentString("Shot Spotter: " .. street)
        else
            msg = "Shotspotter detected in " .. street .. ", postal: " .. postal .. "."
            AddTextComponentString("Shot Spotter: " .. street .. ", postal: " .. postal)
        end
        TriggerEvent("chat:addMessage", {
            color = {255, 0, 0},
            args = {"^*Dispatch: ^0", msg}
        })
        EndTextCommandSetBlipName(blip)
        Citizen.Wait(config.shotSpotterTimer * 1000)
        RemoveBlip(blip)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local ped = PlayerPedId()
        if IsPedShooting(ped) then
            if exports["ND_Core"]:getCharacterInfo(6) == "CIV" then
                isCiv = true
            else
                isCiv = false
            end
            if isCiv and not alreadyShot then
                Citizen.Wait(config.shotSpotterDelay * 1000)
                pedCoords = GetEntityCoords(ped)
                if config.shotSpotterUsePostal then
                    postal = exports["nearest_postal123"]:getPostal()
                else
                    postal = false
                end
                TriggerServerEvent("ND:shotSpotterActive", pedCoords.x, pedCoords.y, pedCoords.z, postal)
            end
            alreadyShot = true
            Citizen.Wait(config.shotSpotterCooldown * 1000)
            alreadyShot = false
        end
    end
end)