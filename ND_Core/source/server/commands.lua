------------------------------------------------------------------------
------------------------------------------------------------------------
--			DO NOT EDIT IF YOU DON'T KNOW WHAT YOU'RE DOING			  --
--     							 									  --
--	   For support join my discord: https://discord.gg/Z9Mxu72zZ6	  --
------------------------------------------------------------------------
------------------------------------------------------------------------
local aop = "Unknown" -- aop unknown if it's not set.

-- Aop command events
RegisterNetEvent("registerAop")
AddEventHandler("registerAop", function(aopRegistered)
    local player = source
    if IsRolePresent(player, "ADMIN") then
        aop = aopRegistered
        TriggerClientEvent("setAop", -1, aop)
    else
        DropPlayer(player, "Tried to use a mod menu to change the aop.")
    end
end)
RegisterNetEvent("getAop")
AddEventHandler("getAop", function()
    local player = source
    TriggerClientEvent("returnAop", player, aop)
end)

-- Twotter command event
RegisterNetEvent("twt")
AddEventHandler("twt", function(id, twtName, twt)
    TriggerClientEvent("twt", -1, id, twtName, twt)
end)

-- Me command event
RegisterNetEvent("me")
AddEventHandler("me", function(id, name, msg, coords)
    TriggerClientEvent("me", -1, id, name, msg, coords)
end)

-- OOC command event
RegisterCommand("ooc", function(source, args, rawCommand)
    TriggerClientEvent("chat:addMessage", -1, {
        color = {150, 150, 150},
        args = {"^*OOC | ^0" .. GetPlayerName(source) .. " (#" .. source .. ")", string.gsub(rawCommand, "ooc", "")}
    })
end, false)

-- Darkweb command event
RegisterCommand("darkweb", function(source, args, rawCommand)
    TriggerClientEvent("chat:addMessage", -1, {
        color = {0, 0, 0},
        args = {"^*Dark web | ^0Anonymous (#" .. source .. ")", string.gsub(rawCommand, "darkweb", "")}
    })
end, false)
