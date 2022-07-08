RegisterNetEvent("ND_Banks:withdraw")
AddEventHandler("ND_Banks:withdraw", function(amount)
    local player = source
    local update = exports["ND_Core"]:withdrawMoney(amount, player)
    TriggerClientEvent("ND_Banks:update", player, update)
end)

RegisterNetEvent("ND_Banks:deposit")
AddEventHandler("ND_Banks:deposit", function(amount)
    local player = source
    local update = exports["ND_Core"]:depositMoney(amount, player)
    TriggerClientEvent("ND_Banks:update", player, update)
end)

RegisterNetEvent("ND_Banks:transfer")
AddEventHandler("ND_Banks:transfer", function(amount, target)
    local player = source
    local update = exports["ND_Core"]:transferBank(amount, player, target)
    TriggerClientEvent("ND_Banks:update", player, update)
end)