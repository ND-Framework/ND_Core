-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

NDCore = {}
NDCore.selectedCharacter = nil
NDCore.characters = {}
NDCore.functions = {}
NDCore.config = config

function GetCoreObject()
    return NDCore
end

function NDCore.functions:getSelectedCharacter(cb)
    if not cb then return NDCore.selectedCharacter end
    cb(NDCore.selectedCharacter)
end

function NDCore.functions:getCharacters(cb)
    if not cb then return NDCore.selectedCharacter end
    cb(NDCore.characters)
end

-- discord rich precense will show on a users profile.
if config.enableRichPrecence then
    Citizen.CreateThread(function()
        SetDiscordAppId(config.appId)
        while true do
            if NDCore.selectedCharacter then
                SetRichPresence(" Playing : " .. config.serverName .. " as " .. NDCore.selectedCharacter.firstName .. " " .. NDCore.selectedCharacter.lastName)
                SetDiscordRichPresenceAsset(config.largeLogo)
                SetDiscordRichPresenceAssetText("Playing: " .. config.serverName)
                SetDiscordRichPresenceAssetSmall(config.smallLogo)
                SetDiscordRichPresenceAssetSmallText("Playing as: " .. NDCore.selectedCharacter.firstName .. " " .. NDCore.selectedCharacter.lastName)
                SetDiscordRichPresenceAction(0, config.firstButtonName, config.firstButtonLink)
                SetDiscordRichPresenceAction(1, config.secondButtonName, config.secondButtonLink)
            end
            Citizen.Wait(config.updateIntervall * 1000)
        end
    end)
end

-- show server name, first name, last name, and the amount of money the character has in the pause menu.
if config.customPauseMenu then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if NDCore.selectedCharacter then
                if IsPauseMenuActive() then
                    BeginScaleformMovieMethodOnFrontendHeader("SET_HEADING_DETAILS")
                    AddTextEntry("FE_THDR_GTAO", config.serverName) 
                    ScaleformMovieMethodAddParamPlayerNameString(NDCore.selectedCharacter.firstName .. " " .. NDCore.selectedCharacter.lastName)
                    PushScaleformMovieFunctionParameterString("Cash: $" .. tostring(NDCore.selectedCharacter.cash))
                    PushScaleformMovieFunctionParameterString("Bank: $" .. tostring(NDCore.selectedCharacter.bank))
                    EndScaleformMovieMethod()
                end
            end
        end
    end)
end

RegisterNetEvent("ND:returnCharacters")
AddEventHandler("ND:returnCharacters", function(characters)
    NDCore.characters = characters
end)

-- updates the money on the client.
RegisterNetEvent("ND:updateMoney")
AddEventHandler("ND:updateMoney", function(cash, bank)
    NDCore.selectedCharacter.cash = cash
    NDCore.selectedCharacter.bank = bank
end)

RegisterNetEvent("ND:setCharacter")
AddEventHandler("ND:setCharacter", function(character)
    NDCore.selectedCharacter = character
end)

-- Enables pvp if it's selected in the config.
AddEventHandler("playerSpawned", function()
    if config.enablePVP then
        SetCanAttackFriendly(PlayerPedId(), true, false)
        NetworkSetFriendlyFireOption(true)
    end
    print("^0This framework is created by ^5Andyyy#7666 ^0for support you can join the ^5discord: ^0https://discord.gg/Z9Mxu72zZ6")
end)