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
    RegisterCommand(config.checkAopCommand, function(source, args, rawCommand)
        TriggerServerEvent("getAop")
    end, false)
    RegisterCommand(config.aopCommand, function(source, args, rawCommand)
        if admin then
            TriggerServerEvent("registerAop", string.sub(rawCommand, string.len(config.aopCommand) + 1, string.len(rawCommand)))
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

RegisterNetEvent("911")
AddEventHandler("911", function(coords, rawCommand)
    local location = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
    TriggerEvent("chat:addMessage", {
        color = {255, 0, 0},
        args = {"^*[911] ^3Location: " .. location .. " ^1| Call infomation^0", string.sub(rawCommand, 4, string.len(rawCommand))}
    })
    blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 817)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    SetBlipColour(blip, 1)
    AddTextComponentString("911 CALL: " .. location)
    EndTextCommandSetBlipName(blip)
    Citizen.Wait(60 * 1000)
    RemoveBlip(blip)
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
