------------------------------------------------------------------------
------------------------------------------------------------------------
--			DO NOT EDIT IF YOU DON'T KNOW WHAT YOU'RE DOING			  --
--     							 									  --
--	   For support join my discord: https://discord.gg/Z9Mxu72zZ6	  --
------------------------------------------------------------------------
------------------------------------------------------------------------

-- Aop command
if config.enableAopCommand then
    TriggerEvent("chat:addSuggestion", "/" .. config.aopCommand, "Change the Area of Play.", {
        { name="Area", help="Area of Play" }
    })
    TriggerEvent("chat:addSuggestion", "/" .. config.checkAopCommand, "Check the current Area of Play.", {})
    RegisterCommand(config.checkAopCommand, function(source, args, raw)
        TriggerServerEvent("getAop")
    end, false)
    RegisterCommand(config.aopCommand, function(source, args, raw)
        if admin then
            TriggerServerEvent("registerAop", string.gsub(raw, config.aopCommand .. " ", ""))
        else
            TriggerEvent("chat:addMessage", {
                args = {"~r~You don't have permission to set the aop."}
            })
        end
    end, false)
    RegisterNetEvent("setAop")
    AddEventHandler("setAop", function(aop)
        SendNUIMessage({
            type = "aop",
            aop = "Current AOP: " .. aop
        })
        TriggerEvent("chat:addMessage", {
            color = {0, 150, 250},
            args = {"Aop has been changed to", aop}
        })
    end)
    RegisterNetEvent("returnAop")
    AddEventHandler("returnAop", function(aop)
        SendNUIMessage({
            type = "aop",
            aop = "Current AOP: " .. aop
        })
        TriggerEvent("chat:addMessage", {
            color = {0, 150, 250},
            args = {"The current AOP is", aop}
        })
    end)
end

-- Money commands
RegisterCommand(config.payCommand, function(source, args, raw)
    sendBank(mainCharaterId, args[1], args[2], GetPlayerServerId(PlayerId()))
end)
RegisterCommand(config.giveCommand, function(source, args, raw)
    sendCash(mainCharaterId, args[1], GetPlayerServerId(PlayerId()))
end)

-- Twotter command
RegisterCommand("twt", function(source, args, rawCommand)
    TriggerServerEvent("twt", GetPlayerServerId(PlayerId()), mainTwtName, string.gsub(rawCommand, "twt", ""))
end, false)
RegisterNetEvent("twt")
AddEventHandler("twt", function(id, twtName, twt)
    TriggerEvent("chat:addMessage", {
        template = "<img src='data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiIHN0YW5kYWxvbmU9Im5vIj8+Cjxz%0D%0AdmcKICB2aWV3Ym94PSIwIDAgMjAwMCAxNjI1LjM2IgogIHdpZHRoPSIyMDAwIgogIGhlaWdodD0i%0D%0AMTYyNS4zNiIKICB2ZXJzaW9uPSIxLjEiCiAgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAv%0D%0Ac3ZnIj4KICA8cGF0aAogICAgZD0ibSAxOTk5Ljk5OTksMTkyLjQgYyAtNzMuNTgsMzIuNjQgLTE1%0D%0AMi42Nyw1NC42OSAtMjM1LjY2LDY0LjYxIDg0LjcsLTUwLjc4IDE0OS43NywtMTMxLjE5IDE4MC40%0D%0AMSwtMjI3LjAxIC03OS4yOSw0Ny4wMyAtMTY3LjEsODEuMTcgLTI2MC41Nyw5OS41NyBDIDE2MDku%0D%0AMzM5OSw0OS44MiAxNTAyLjY5OTksMCAxMzg0LjY3OTksMCBjIC0yMjYuNiwwIC00MTAuMzI4LDE4%0D%0AMy43MSAtNDEwLjMyOCw0MTAuMzEgMCwzMi4xNiAzLjYyOCw2My40OCAxMC42MjUsOTMuNTEgLTM0%0D%0AMS4wMTYsLTE3LjExIC02NDMuMzY4LC0xODAuNDcgLTg0NS43MzksLTQyOC43MiAtMzUuMzI0LDYw%0D%0ALjYgLTU1LjU1ODMsMTMxLjA5IC01NS41NTgzLDIwNi4yOSAwLDE0Mi4zNiA3Mi40MzczLDI2Ny45%0D%0ANSAxODIuNTQzMywzNDEuNTMgLTY3LjI2MiwtMi4xMyAtMTMwLjUzNSwtMjAuNTkgLTE4NS44NTE5%0D%0ALC01MS4zMiAtMC4wMzksMS43MSAtMC4wMzksMy40MiAtMC4wMzksNS4xNiAwLDE5OC44MDMgMTQx%0D%0ALjQ0MSwzNjQuNjM1IDMyOS4xNDUsNDAyLjM0MiAtMzQuNDI2LDkuMzc1IC03MC42NzYsMTQuMzk1%0D%0AIC0xMDguMDk4LDE0LjM5NSAtMjYuNDQxLDAgLTUyLjE0NSwtMi41NzggLTc3LjIwMywtNy4zNjQg%0D%0ANTIuMjE1LDE2My4wMDggMjAzLjc1LDI4MS42NDkgMzgzLjMwNCwyODQuOTQ2IC0xNDAuNDI5LDEx%0D%0AMC4wNjIgLTMxNy4zNTEsMTc1LjY2IC01MDkuNTk3MiwxNzUuNjYgLTMzLjEyMTEsMCAtNjUuNzg1%0D%0AMSwtMS45NDkgLTk3Ljg4MjgsLTUuNzM4IDE4MS41ODYsMTE2LjQxNzYgMzk3LjI3LDE4NC4zNTkg%0D%0ANjI4Ljk4OCwxODQuMzU5IDc1NC43MzIsMCAxMTY3LjQ2MiwtNjI1LjIzOCAxMTY3LjQ2MiwtMTE2%0D%0ANy40NyAwLC0xNy43OSAtMC40MSwtMzUuNDggLTEuMiwtNTMuMDggODAuMTc5OSwtNTcuODYgMTQ5%0D%0ALjczOTksLTEzMC4xMiAyMDQuNzQ5OSwtMjEyLjQxIgogICAgc3R5bGU9ImZpbGw6IzAwYWNlZCIv%0D%0APgo8L3N2Zz4K' height='16'> <b>{0}</b>: {1}",
        multiline = true,
        args = {"^4@" .. twtName .. " (#" .. id .. ")", twt}
    })
end)

-- Me command
RegisterCommand("me", function(source, args, rawCommand)
    TriggerServerEvent("me", GetPlayerServerId(PlayerId()), mainFirstName .. " " .. mainLastName, string.gsub(rawCommand, "me", ""), GetEntityCoords(PlayerPedId()))
end, false)
RegisterNetEvent("me")
AddEventHandler("me", function(id, name, msg, coords)
    if #(coords - GetEntityCoords(PlayerPedId())) < 19.999 then
        TriggerEvent("chat:addMessage", {
            color = {255, 0, 0},
            args = {"^*ME | ^0" .. name .. " (#" .. id .. ")", msg}
        })
    end
end)

-- Change character command
TriggerEvent("chat:addSuggestion", "/" .. config.changeCharacterCommand, "Switch your framework character.", {})
RegisterCommand(config.changeCharacterCommand, function()
    SwitchOutPlayer(PlayerPedId(), 0, 1)
    Citizen.Wait(2000)
    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, false, 0)
	SetDisplay(true, "ui")
end, false)

-- Help command
RegisterCommand("help", function(source, args, rawCommand)
    TriggerEvent("chat:addMessage", {
        color = {252, 186, 3},
        args = {"^*Help | ", "/twt, /ooc, /darkweb, /me, /setAop, /aop, /pay, /give, /changecharacter"}
    })
end, false)

-- chat suggestions
TriggerEvent("chat:addSuggestion", "/" .. config.payCommand, "Transfer money to player", {{ name="id", help="Player server id" }, { name="amount", help="amount to pay" }})
TriggerEvent("chat:addSuggestion", "/" .. config.giveCommand, "Give money to closeby player", {{ name="amount", help="amount to give" }})
TriggerEvent("chat:addSuggestion", "/twt", "Send a Twotter in game. (Global Chat)", {{ name="Message", help="Twotter Message."}})
TriggerEvent("chat:addSuggestion", "/ooc", "Out Of Character chat Message. (Global Chat)", {{ name="Message", help="Put your questions or help request."}})
TriggerEvent("chat:addSuggestion", "/darkweb", "Send a anonymous message in game. (Global Chat)", {{ name="Message", help="Anonymous Message."}})
TriggerEvent("chat:addSuggestion", "/me", "Send message in the third person. (Proximity Chat)", {{ name="Action", help="action."}})
TriggerEvent("chat:addSuggestion", "/help", "", {})
