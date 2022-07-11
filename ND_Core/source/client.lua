-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

local selectedCharacter
local characterAmount = 0

function SetDisplay(bool, typeName, bg)
    if not bg then
        background = config.backgrounds[math.random(1, #config.backgrounds)]
    end
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = typeName,
        background = background,
        status = bool,
        serverName = config.serverName,
        characterAmount = characterAmount .. "/" .. config.characterLimit
    })
end

function getCharacterInfo()
    return selectedCharacter
end

function start(switch)
    TriggerServerEvent("checkPerms")
    TriggerServerEvent("getCharacters")
    TriggerServerEvent("getAop")
    Citizen.Wait(100)
    if switch then
        local ped = PlayerPedId()
        SwitchOutPlayer(ped, 0, 1)
        FreezeEntityPosition(ped, true)
        SetEntityVisible(ped, false, 0)
    end
    SendNUIMessage({
        type = "onStart",
        enableMoneySystem = config.enableMoneySystem,
        maxStartingBank = config.maxStartingBank,
        maxStartingCash = config.maxStartingCash
    })
end

AddEventHandler("onResourceStart", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    Citizen.Wait(1000)
    start(false)
end)  

AddEventHandler("playerSpawned", function()
    print("^0This framework is created by ^5Andyyy#7666 ^0for support you can join the ^5discord: ^0https://discord.gg/Z9Mxu72zZ6")
    start(true)
end)

-- This is used to add department drop down on the ui.
RegisterNetEvent("permsChecked")
AddEventHandler("permsChecked", function(allowedRoles)
    for _, dept in pairs(allowedRoles) do
        SendNUIMessage({
            type = "givePerms",
            deptRole = dept
        })
    end
end)

-- Notification when you recieve money.
RegisterNetEvent("receiveBank")
AddEventHandler("receiveBank", function(amount, playerSending, playerId)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName("Received $" .. amount .. " from " .. playerSending .. " [".. playerId .."]")
    EndTextCommandThefeedPostMessagetext("CHAR_BANK_FLEECA", "CHAR_BANK_FLEECA", true, 9,"FleecaBank", "")
end)

-- Notification when you receive cash.
RegisterNetEvent("receiveCash")
AddEventHandler("receiveCash", function(amount, playerSending, playerId)
    BeginTextCommandThefeedPost("STRING")
    AddTextComponentSubstringPlayerName(playerSending .. " gave you $" .. amount .. ".")
    EndTextCommandThefeedPostMessagetext("CHAR_DEFAULT", "CHAR_DEFAULT", true, 9, playerSending .. " [".. playerId .."]", "")
end)

RegisterNetEvent("updateMoney")
AddEventHandler("updateMoney", function(cash, bank)
    selectedCharacter.cash = cash
    selectedCharacter.bank = bank
end)

-- Gets all the characters and displays them on the ui.
RegisterNetEvent("returnCharacters")
AddEventHandler("returnCharacters", function(characters)
    characterAmount = 0
    SendNUIMessage({
        type = "refresh"
    })
    for _, character in pairs(characters) do
        SendNUIMessage({
            type = "character",
            id = character.id,
            firstName = character.firstName,
            lastName = character.lastName,
            dateOfBirth = character.dob,
            gender = character.gender,
            twtName = character.twt,
            department = character.department,
            startingCash = character.cash,
            startingBank = character.bank
        })
        characterAmount = characterAmount + 1
    end
    SetDisplay(true, "ui", background)
end)

-- Selecting a player from the iu.
RegisterNUICallback("setMainCharacter", function(data)
    selectedCharacter = {
        firstName = data.firstName,
        lastName = data.lastName,
        dob = data.dateOfBirth,
        gender = data.gender,
        twt = data.twtName,
        department = data.department,
        cash = data.startingCash,
        bank = data.startingBank,
        id = data.character
    }

    for _, spawn in pairs(config.spawns[selectedCharacter.department]) do
        SendNUIMessage({
            type = "setSpawns",
            x = spawn.x,
            y = spawn.y,
            z = spawn.z,
            name = spawn.name
        })
    end

    TriggerServerEvent("characterOnline", selectedCharacter.id)
    TriggerEvent("characterChanged", selectedCharacter)
end)

-- Creating a character from the ui.
RegisterNUICallback("newCharacter", function(data)
    if characterAmount < config.characterLimit then
        TriggerServerEvent("newCharacter", {
            firstName = data.firstName,
            lastName = data.lastName,
            dateOfBirth = data.dateOfBirth,
            gender = data.gender,
            twtName = data.twtName,
            department = data.department,
            startingCash = data.startingCash,
            startingBank = data.startingBank
        })
    end
end)

-- editing a character from the ui.
RegisterNUICallback("editCharacter", function(data)
    TriggerServerEvent("editCharacter", {
        firstName = data.firstName,
        lastName = data.lastName,
        dateOfBirth = data.dateOfBirth,
        gender = data.gender,
        twtName = data.twtName,
        department = data.department,
        id = data.id
    })
end)

-- deleting a character from the ui.
RegisterNUICallback("delCharacter", function(data)
    TriggerServerEvent("delCharacter", data.character)
    characterAmount = characterAmount -1
    SendNUIMessage({
        characterAmount = characterAmount .. "/" .. config.characterLimit
    })
end)

-- Quit button from ui.
RegisterNUICallback("exitGame", function(data)
    TriggerServerEvent("exitGame")
end)

-- Teleporting using ui.
RegisterNUICallback("tpToLocation", function(data)
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, false)
    SetEntityCoords(ped, tonumber(data.x), tonumber(data.y), tonumber(data.z), false, false, false, false)
    FreezeEntityPosition(ped, true)
    SwitchInPlayer(ped)
    Citizen.Wait(500)
    SetDisplay(false, "ui")
    Citizen.Wait(500)
    FreezeEntityPosition(ped, false)
    SetEntityVisible(ped, true, 0)
    TriggerServerEvent("getMoney", selectedCharacter.id)
end)

-- Choosing the do not tp button.
RegisterNUICallback("tpDoNot", function()
    local ped = PlayerPedId()
    SwitchInPlayer(ped)
    Citizen.Wait(500)
    SetDisplay(false, "ui")
    Citizen.Wait(500)
    SetEntityVisible(ped, true, 0)
    FreezeEntityPosition(ped, false)
    TriggerServerEvent("getMoney", selectedCharacter.id)
end)

-- discord rich presence will show on a users profile.
if config.enableRichPresence then
    Citizen.CreateThread(function()
        while true do
            SetDiscordAppId(config.appId)
            if selectedCharacter then
                SetRichPresence(" Playing : " .. config.serverName .. " as " .. selectedCharacter.firstName .. " " .. selectedCharacter.lastName)
                SetDiscordRichPresenceAsset(config.largeLogo)
                SetDiscordRichPresenceAssetText("Playing: " .. config.serverName)
                SetDiscordRichPresenceAssetSmall(config.smallLogo)
                SetDiscordRichPresenceAssetSmallText("Playing as: " .. selectedCharacter.firstName .. " " .. selectedCharacter.lastName)
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
            if selectedCharacter then
                if IsPauseMenuActive() then
                    BeginScaleformMovieMethodOnFrontendHeader("SET_HEADING_DETAILS")
                    AddTextEntry("FE_THDR_GTAO", config.serverName) 
                    ScaleformMovieMethodAddParamPlayerNameString(selectedCharacter.firstName .. " " .. selectedCharacter.lastName)
                    if config.enableMoneySystem then
                        PushScaleformMovieFunctionParameterString("Cash: $" .. tostring(selectedCharacter.cash))
                        PushScaleformMovieFunctionParameterString("Bank: $" .. tostring(selectedCharacter.bank))
                    end
                    EndScaleformMovieMethod()
                end
            end
        end
    end)
end

-- Change character command
RegisterCommand(config.changeCharacterCommand, function()
    SwitchOutPlayer(PlayerPedId(), 0, 1)
    Citizen.Wait(2000)
    FreezeEntityPosition(ped, true)
    SetEntityVisible(ped, false, 0)
	SetDisplay(true, "ui")
end, false)

-- chat suggestions
TriggerEvent("chat:addSuggestion", "/" .. config.changeCharacterCommand, "Switch your framework character.")
if config.enableMoneySystem then
    TriggerEvent("chat:addSuggestion", "/" .. config.payCommand, "Transfer money to player", {{name="id", help="Player server id" }, {name="amount", help="amount to pay"}})
    TriggerEvent("chat:addSuggestion", "/" .. config.giveCommand, "Give money to closeby player", {{name="amount", help="amount to give"}})
end
