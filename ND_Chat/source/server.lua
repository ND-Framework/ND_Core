if config["/me"] then
    RegisterCommand("me", function(source, args, rawCommand)
        local player = source
        local players = exports["ND_Core"]:getCharacterTable()
        local playerCoords = GetEntityCoords(GetPlayerPed(player))
        for serverPlayer, _ in pairs(players) do
            local targetCoords = GetEntityCoords(GetPlayerPed(serverPlayer))
            if (#(playerCoords - targetCoords) < 20.0) then
                TriggerClientEvent("chat:addMessage", serverPlayer, {
                    color = {255, 0, 0},
                    args = {"^*ME | ^0" .. players[player].firstName .. " " .. players[player].lastName .. " (#" .. player .. ")", table.concat(args, " ")}
                })
            end
        end
    end, false)
end

if config["/gme"] then
    RegisterCommand("gme", function(source, args, rawCommand)
        local player = source
        local players = exports["ND_Core"]:getCharacterTable()
        TriggerClientEvent("chat:addMessage", -1, {
            color = {255, 0, 0},
            args = {"^*GME | ^0" .. players[player].firstName .. " " .. players[player].lastName .. " (#" .. player .. ")", table.concat(args, " ")}
        })
    end, false)
end

if config["/ooc"] then
    RegisterCommand("ooc", function(source, args, rawCommand)
        local player = source
        TriggerClientEvent("chat:addMessage", -1, {
            color = {150, 150, 150},
            args = {"^*OOC | ^0" .. GetPlayerName(player) .. " (#" .. player .. ")", table.concat(args, " ")}
        })
    end, false)
end

if config["/twt"] then
    RegisterCommand("twt", function(source, args, rawCommand)
        local player = source
        local players = exports["ND_Core"]:getCharacterTable()
        TriggerClientEvent("chat:addMessage", -1, {
            template = "<img src='data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+Cjxz%0D%0AdmcKICB2aWV3Ym94PSIwIDAgMjAwMCAxNjI1LjM2IgogIHdpZHRoPSIyMDAwIgogIGhlaWdodD0i%0D%0AMTYyNS4zNiIKICB2ZXJzaW9uPSIxLjEiCiAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAv%0D%0Ac3ZnIj4KICA8cGF0aAogICAgZD0ibSAxOTk5Ljk5OTksMTkyLjQgYyAtNzMuNTgsMzIuNjQgLTE1%0D%0AMi42Nyw1NC42OSAtMjM1LjY2LDY0LjYxIDg0LjcsLTUwLjc4IDE0OS43NywtMTMxLjE5IDE4MC40%0D%0AMSwtMjI3LjAxIC03OS4yOSw0Ny4wMyAtMTY3LjEsODEuMTcgLTI2MC41Nyw5OS41NyBDIDE2MDku%0D%0AMzM5OSw0OS44MiAxNTAyLjY5OTksMCAxMzg0LjY3OTksMCBjIC0yMjYuNiwwIC00MTAuMzI4LDE4%0D%0AMy43MSAtNDEwLjMyOCw0MTAuMzEgMCwzMi4xNiAzLjYyOCw2My40OCAxMC42MjUsOTMuNTEgLTM0%0D%0AMS4wMTYsLTE3LjExIC02NDMuMzY4LC0xODAuNDcgLTg0NS43MzksLTQyOC43MiAtMzUuMzI0LDYw%0D%0ALjYgLTU1LjU1ODMsMTMxLjA5IC01NS41NTgzLDIwNi4yOSAwLDE0Mi4zNiA3Mi40MzczLDI2Ny45%0D%0ANSAxODIuNTQzMywzNDEuNTMgLTY3LjI2MiwtMi4xMyAtMTMwLjUzNSwtMjAuNTkgLTE4NS44NTE5%0D%0ALC01MS4zMiAtMC4wMzksMS43MSAtMC4wMzksMy40MiAtMC4wMzksNS4xNiAwLDE5OC44MDMgMTQx%0D%0ALjQ0MSwzNjQuNjM1IDMyOS4xNDUsNDAyLjM0MiAtMzQuNDI2LDkuMzc1IC03MC42NzYsMTQuMzk1%0D%0AIC0xMDguMDk4LDE0LjM5NSAtMjYuNDQxLDAgLTUyLjE0NSwtMi41NzggLTc3LjIwMywtNy4zNjQg%0D%0ANTIuMjE1LDE2My4wMDggMjAzLjc1LDI4MS42NDkgMzgzLjMwNCwyODQuOTQ2IC0xNDAuNDI5LDEx%0D%0AMC4wNjIgLTMxNy4zNTEsMTc1LjY2IC01MDkuNTk3MiwxNzUuNjYgLTMzLjEyMTEsMCAtNjUuNzg1%0D%0AMSwtMS45NDkgLTk3Ljg4MjgsLTUuNzM4IDE4MS41ODYsMTE2LjQxNzYgMzk3LjI3LDE4NC4zNTkg%0D%0ANjI4Ljk4OCwxODQuMzU5IDc1NC43MzIsMCAxMTY3LjQ2MiwtNjI1LjIzOCAxMTY3LjQ2MiwtMTE2%0D%0ANy40NyAwLC0xNy43OSAtMC40MSwtMzUuNDggLTEuMiwtNTMuMDggODAuMTc5OSwtNTcuODYgMTQ5%0D%0ALjczOTksLTEzMC4xMiAyMDQuNzQ5OSwtMjEyLjQxIgogICAgc3R5bGU9ImZpbGw6IzAwYWNlZCIv%0D%0APgo8L3N2Zz4K' height='16'> <b>{0}</b>: {1}",
            multiline = true,
            args = {"^4@" .. players[player].twt .. " (#" .. player .. ")", table.concat(args, " ")}
        })
    end, false)
end

function hasDarkWebPermission(player, players, args)
    for _, department in pairs(config["/darkweb"].canNotSee) do
        if players[player].dept == department then 
            TriggerClientEvent("chat:addMessage", player, {
                color = {255, 0, 0},
                args = {"^*Error", players[player].dept .. " cannot access this command."}
            })
            return false
        end
    end
    for serverPlayer, playerInfo in pairs(players) do
        for _, department in pairs(config["/darkweb"].canNotSee) do
            if playerInfo.dept == department then
                return false
            end
        end
        TriggerClientEvent("chat:addMessage", serverPlayer, {
            color = {0, 0, 0},
            args = {"^*Dark web | ^0Anonymous (#" .. player .. ")", table.concat(args, " ")}
        })
    end
end

if config["/darkweb"].enabled then
    RegisterCommand("darkweb", function(source, args, rawCommand)
        local player = source
        local players = exports["ND_Core"]:getCharacterTable()
        hasDarkWebPermission(player, players, args)
    end, false)
end

if config["/911"].enabled then
    RegisterCommand("911", function(source, args, rawCommand)
        local player = source
        TriggerClientEvent("ND_Chat:911", -1, GetEntityCoords(GetPlayerPed(player)), table.concat(args, " "))
    end, false)
end