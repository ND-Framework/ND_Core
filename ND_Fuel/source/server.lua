NDCore = exports["ND_Core"]:GetCoreObject()
-- NDCore.Functions.VersionChecker("ND_Fuel", GetCurrentResourceName(), "https://github.com/Andyyy7666/ND_Framework", "https://raw.githubusercontent.com/Andyyy7666/ND_Framework/main/ND_Fuel/fxmanifest.lua")

RegisterNetEvent("ND_Fuel:pay", function(amount)
    local player = source
    NDCore.Functions.DeductMoney(math.floor(amount), player, "bank")
    TriggerClientEvent("chat:addMessage", player, {
        color = {0, 255, 0},
        args = {"Success", "Paid: $" .. string.format("%.2f", amount) .. " for gas."}
    })
end)

RegisterNetEvent("ND_Fuel:jerryCan", function(amount)
    local player = source
    NDCore.Functions.DeductMoney(amount, player, "cash")
    TriggerClientEvent("chat:addMessage", player, {
        color = {0, 255, 0},
        args = {"Success", "Paid: $" .. amount .. " for gas."}
    })
end)