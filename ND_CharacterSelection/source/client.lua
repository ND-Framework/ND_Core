-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

NDCore = exports["ND_Core"]:GetCoreObject()

function tablelength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

function SetDisplay(bool, typeName, bg)
    if not bg then
        background = config.backgrounds[math.random(1, #config.backgrounds)]
    end
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = typeName,
        background = background,
        status = bool,
        serverName = NDCore.Config.serverName,
        characterAmount = tablelength(NDCore.Characters) .. "/" .. NDCore.Config.characterLimit
    })
    if config.characterSelectionAopDisplay then
        SendNUIMessage({
            type = "aop",
            aop = config.aop()
        })
    end
end

function start(switch)
    TriggerServerEvent("ND_CharacterSelection:checkPerms")
    TriggerServerEvent("ND:GetCharacters")
    if switch then
        local ped = PlayerPedId()
        SwitchOutPlayer(ped, 0, 1)
        FreezeEntityPosition(ped, true)
        SetEntityVisible(ped, false, 0)
    end
    SendNUIMessage({
        type = "onStart",
        maxStartingBank = NDCore.Config.startingBank,
        maxStartingCash = NDCore.Config.startingCash
    })
    if config.characterSelectionAopDisplay then
        SendNUIMessage({
            type = "aop",
            aop = config.aop()
        })
    end
end

AddEventHandler("onResourceStart", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    Citizen.Wait(2000)
    start(false)
end)  

AddEventHandler("playerSpawned", function()
    start(true)
end)

-- This is used to add department drop down on the ui.
RegisterNetEvent("ND_CharacterSelection:permsChecked")
AddEventHandler("ND_CharacterSelection:permsChecked", function(allowedRoles)
    SendNUIMessage({
        type = "givePerms",
        deptRoles = json.encode(allowedRoles)
    })
end)

-- Gets all the characters and displays them on the ui.
RegisterNetEvent("ND:returnCharacters")
AddEventHandler("ND:returnCharacters", function(characters)
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
            department = character.job,
            startingCash = character.cash,
            startingBank = character.bank
        })
    end
    SetDisplay(true, "ui", background)
end)

-- Selecting a player from the iu.
RegisterNUICallback("setMainCharacter", function(data)
    local characters = NDCore.Functions.GetCharacters()
    for _, spawn in pairs(config.spawns[characters[data.id].job]) do
        SendNUIMessage({
            type = "setSpawns",
            x = spawn.x,
            y = spawn.y,
            z = spawn.z,
            name = spawn.name
        })
    end
    TriggerServerEvent("ND:setCharacterOnline", data.id)
end)

-- Creating a character from the ui.
RegisterNUICallback("newCharacter", function(data)
    if tablelength(NDCore.Characters) < NDCore.Config.characterLimit then
        TriggerServerEvent("ND_CharacterSelection:newCharacter", {
            firstName = data.firstName,
            lastName = data.lastName,
            dob = data.dateOfBirth,
            gender = data.gender,
            twt = data.twtName,
            job = data.department,
            cash = data.startingCash,
            bank = data.startingBank
        })
    end
end)

-- editing a character from the ui.
RegisterNUICallback("editCharacter", function(data)
    TriggerServerEvent("ND_CharacterSelection:editCharacter", {
        id = data.id,
        firstName = data.firstName,
        lastName = data.lastName,
        dob = data.dateOfBirth,
        gender = data.gender,
        twt = data.twtName,
        job = data.department
    })
end)

-- deleting a character from the ui.
RegisterNUICallback("delCharacter", function(data)
    TriggerServerEvent("ND:deleteCharacter", data.character)
end)

-- Quit button from ui.
RegisterNUICallback("exitGame", function()
    TriggerServerEvent("ND:exitGame")
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
end)

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
