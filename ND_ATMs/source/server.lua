RegisterNetEvent("ND_ATM:withdraw")
AddEventHandler("ND_ATM:withdraw", function(amount)
    local player = source
    local update = exports["ND_Core"]:withdrawMoney(amount, player)
    TriggerClientEvent("ND_ATM:update", player, update)
end)

RegisterNetEvent("ND_ATM:deposit")
AddEventHandler("ND_ATM:deposit", function(amount)
    local player = source
    local update = exports["ND_Core"]:depositMoney(amount, player)
    TriggerClientEvent("ND_ATM:update", player, update)
end)