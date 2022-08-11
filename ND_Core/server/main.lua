-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

NDCore = {}
NDCore.Players = {}
NDCore.Functions = {}
NDCore.Config = config

function GetCoreObject()
    return NDCore
end

CreateThread(function()
    while true do
        Wait(30000)
        for player, playerInfo in pairs(NDCore.Players) do
            local ped = GetPlayerPed(player)
            if DoesEntityExist(ped) then
                local lastLocation = GetEntityCoords(ped)
                playerInfo.lastLocation = {x = lastLocation.x, y = lastLocation.y, z = lastLocation.z}
                TriggerClientEvent("ND:updateLastLocation", player, playerInfo.lastLocation)
            end
        end
    end
end)