-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

NDCore = {}
NDCore.SelectedCharacter = nil
NDCore.Characters = {}
NDCore.Functions = {}
NDCore.Config = config

function GetCoreObject()
    return NDCore
end

function NDCore.Functions.GetSelectedCharacter(cb)
    if not cb then return NDCore.SelectedCharacter end
    cb(NDCore.SelectedCharacter)
end

function NDCore.Functions.GetCharacters(cb)
    if not cb then return NDCore.Characters end
    cb(NDCore.Characters)
end

-- discord rich precense will show on a users profile.
if config.enableRichPrecence then
    Citizen.CreateThread(function()
        while true do
            if NDCore.SelectedCharacter then
                SetDiscordAppId(config.appId)
                SetRichPresence(" Playing : " .. config.serverName .. " as " .. NDCore.SelectedCharacter.firstName .. " " .. NDCore.SelectedCharacter.lastName)
                SetDiscordRichPresenceAsset(config.largeLogo)
                SetDiscordRichPresenceAssetText("Playing: " .. config.serverName)
                SetDiscordRichPresenceAssetSmall(config.smallLogo)
                SetDiscordRichPresenceAssetSmallText("Playing as: " .. NDCore.SelectedCharacter.firstName .. " " .. NDCore.SelectedCharacter.lastName)
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
            if NDCore.SelectedCharacter then
                if IsPauseMenuActive() then
                    BeginScaleformMovieMethodOnFrontendHeader("SET_HEADING_DETAILS")
                    AddTextEntry("FE_THDR_GTAO", config.serverName) 
                    ScaleformMovieMethodAddParamPlayerNameString(NDCore.SelectedCharacter.firstName .. " " .. NDCore.SelectedCharacter.lastName)
                    PushScaleformMovieFunctionParameterString("Cash: $" .. tostring(NDCore.SelectedCharacter.cash))
                    PushScaleformMovieFunctionParameterString("Bank: $" .. tostring(NDCore.SelectedCharacter.bank))
                    EndScaleformMovieMethod()
                end
            end
        end
    end)
end

RegisterNetEvent("ND:returnCharacters")
AddEventHandler("ND:returnCharacters", function(characters)
    NDCore.Characters = characters
end)

-- updates the money on the client.
RegisterNetEvent("ND:updateMoney")
AddEventHandler("ND:updateMoney", function(cash, bank)
    NDCore.SelectedCharacter.cash = cash
    NDCore.SelectedCharacter.bank = bank
end)

-- Sets main character.
RegisterNetEvent("ND:setCharacter")
AddEventHandler("ND:setCharacter", function(character)
    NDCore.SelectedCharacter = character
end)

-- Updates last lcoation.
RegisterNetEvent("ND:updateLastLocation")
AddEventHandler("ND:updateLastLocation", function(location)
    NDCore.SelectedCharacter.lastLocation = location
end)

-- Enables pvp if it's selected in the config.
AddEventHandler("playerSpawned", function()
    if config.enablePVP then
        SetCanAttackFriendly(PlayerPedId(), true, false)
        NetworkSetFriendlyFireOption(true)
    end
    print("^0This framework is created by ^5Andyyy#7666 ^0for support you can join the ^5discord: ^0https://discord.gg/Z9Mxu72zZ6")
end)