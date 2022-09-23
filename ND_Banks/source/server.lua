NDCore = exports["ND_Core"]:GetCoreObject()
NDCore.Functions.VersionChecker("ND_Banks", GetCurrentResourceName(), "https://github.com/ND-Framework/ND_Framework", "https://raw.githubusercontent.com/ND-Framework/ND_Framework/main/ND_Banks/fxmanifest.lua")

RegisterNetEvent("ND_Banks:withdraw", function(amount)
    local player = source
    local update = NDCore.Functions.WithdrawMoney(amount, player)
    TriggerClientEvent("ND_Banks:update", player, update)
end)

RegisterNetEvent("ND_Banks:deposit", function(amount)
    local player = source
    local update = NDCore.Functions.DepositMoney(amount, player)
    TriggerClientEvent("ND_Banks:update", player, update)
end)

RegisterNetEvent("ND_Banks:transfer", function(amount, target)
    local player = source
    local update = NDCore.Functions.TransferBank(amount, player, target)
    TriggerClientEvent("ND_Banks:update", player, update)
end)
