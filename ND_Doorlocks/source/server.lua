-- For support join my discord: https://discord.gg/Z9Mxu72zZ6
RegisterNetEvent("ND_Doorlocks:syncDoor")
AddEventHandler("ND_Doorlocks:syncDoor", function(doorID, state)
    TriggerClientEvent("ND_Doorlocks:syncDoor", -1, doorID, state)
end)