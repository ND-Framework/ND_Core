NDCore = exports["ND_Core"]:GetCoreObject()
NDCore.Functions.VersionChecker("ND_ATMs", GetCurrentResourceName(), "https://github.com/Andyyy7666/ND_Framework", "https://raw.githubusercontent.com/Andyyy7666/ND_Framework/main/ND_ATMs/fxmanifest.lua")

RegisterNetEvent("ND_ATMs:withdraw", function(amount)
    local player = source
    local update = NDCore.Functions.WithdrawMoney(amount, player)
    TriggerClientEvent("ND_ATMs:update", player, update)
end)

RegisterNetEvent("ND_ATMs:deposit", function(amount)
    local player = source
    local update = NDCore.Functions.DepositMoney(amount, player)
    TriggerClientEvent("ND_ATMs:update", player, update)
end)