function sendToDiscord(name, message, color)
    local embed = {
        {
            title = name,
            description = message,
            footer = {
                icon_url = "https://i.imgur.com/notBtrZ.png",
                text = "Created by Andyyy#7666"
            },
            color = color
        }
    }
    PerformHttpRequest(config.discordWebhook, function(err, text, headers) end, 'POST', json.encode({username = "ND Jailing", embeds = embed}), {["Content-Type"] = "application/json"})
end

-- Jail player discord log, trigger the even on the players client and send a message to everyone.
RegisterNetEvent("ND_Jailing:jailPlayer")
AddEventHandler("ND_Jailing:jailPlayer", function(id, name, time, reason)
    TriggerClientEvent("ND_Jailing:jailPlayer", id, time)
    sendToDiscord("Jail Logs", "**" .. GetPlayerName(source) .. "** Jailed **" .. name .. "** for **" .. time .. " seconds** with the reason: **" .. reason .. "**.", 1595381)
    TriggerClientEvent('chat:addMessage', -1, {
        color = { 255, 0, 0},
        multiline = true,
        args = {"[Judge]", name .. " was charaged with " .. reason .. " and will be spending " .. time .. " months in jail."}
    })
end)

-- Gets all players on the server and adds them to a table.
RegisterNetEvent("ND_Jailing:getPlayers")
AddEventHandler("ND_Jailing:getPlayers", function()
    local players = {}
    for _, id in pairs(GetPlayers()) do
        players[id] = "(" .. id .. ") " .. GetPlayerName(id)
    end
    TriggerClientEvent("ND_Jailing:returnPlayers", source, players)
end)