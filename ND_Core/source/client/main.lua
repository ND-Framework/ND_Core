------------------------------------------------------------------------
------------------------------------------------------------------------
--			DO NOT EDIT IF YOU DON'T KNOW WHAT YOU'RE DOING			  --
--     							 									  --
--	   For support join my discord: https://discord.gg/Z9Mxu72zZ6	  --
------------------------------------------------------------------------
------------------------------------------------------------------------

local started = true
registered = false
admin = false

-- This is used to add department drop down on the ui.
RegisterNetEvent("permsChecked")
AddEventHandler("permsChecked", function(role, rolePermission)
    if rolePermission then
        if role == "ADMIN" then
            admin = true
        else
            SendNUIMessage({
                type = "givePerms",
                deptRole = role
            })
        end
    end
end)

Citizen.CreateThread(function()
    while started do
        Citizen.Wait(200)
        local ped = PlayerPedId()
        if IsPedOnFoot(ped) or IsPedInVehicle(ped, GetVehiclePedIsIn(ped, false), false) then
            print("^0This framework is created by ^5Andyyy#7666 ^0for support you can join the ^5discord: ^0https://discord.gg/Z9Mxu72zZ6")
            for i = 1, #config.departments do -- if you have an error that says attempt to index a nil value (global 'config') it's beacuse you have edited the config wrong.
                TriggerServerEvent("checkPerms", config.departments[i]) -- check permissions for each department with the department names.
            end
            TriggerServerEvent("checkPerms", "ADMIN") -- check if the player has the admin role.
            TriggerServerEvent("getCharacters")
            Citizen.Wait(100)
            TriggerServerEvent("getAop")
            SwitchOutPlayer(ped, 0, 1)
            FreezeEntityPosition(ped, true)
            SetEntityVisible(ped, false, 0)
            started = false
        end
    end
end)

RegisterNUICallback("exitGame", function(data)
    TriggerServerEvent("exitGame")
end)

RegisterNetEvent("returnCharacters")
AddEventHandler("returnCharacters", function(characters)
    for i = 1, #characters do
        index = characters[i]
        SendNUIMessage({
            type = "character",
            id = index.id,
            firstName = index.firstName,
            lastName = index.lastName,
            dateOfBirth = index.dob,
            gender = index.gender,
            twtName = index.twt,
            department = index.department,
            startingCash = index.cash,
            startingBank = index.bank
        })
    end
    characterAmount = #characters
    SetDisplay(true, "ui")
end)

-- Creating a character
RegisterNUICallback("newCharacter", function(data)
    if characterAmount < config.characterLimit then
        newCharacter = {
            firstName = data.firstName,
            lastName = data.lastName,
            dateOfBirth = data.dateOfBirth,
            gender = data.gender,
            twtName = data.twtName,
            department = data.department,
            startingCash = data.startingCash,
            startingBank = data.startingBank
        }
        TriggerServerEvent("newCharacter", newCharacter)
    end
end)

RegisterNetEvent("returnNewCharacter")
AddEventHandler("returnNewCharacter", function(id, character)
    characterAmount = characterAmount +1
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
        startingBank = character.bank,
        characterAmount = characterAmount .. "/" .. config.characterLimit
    })
end)

-- editing a character
RegisterNUICallback("editCharacter", function(data)
    newCharacter = {
        firstName = data.firstName,
        lastName = data.lastName,
        dateOfBirth = data.dateOfBirth,
        gender = data.gender,
        twtName = data.twtName,
        department = data.department,
        id = data.id
    }
    TriggerServerEvent("editCharacter", newCharacter)
end)

-- deleting a character
RegisterNUICallback("delCharacter", function(data)
    TriggerServerEvent("delCharacter", data.character)
    characterAmount = characterAmount -1
    SendNUIMessage({
        characterAmount = characterAmount .. "/" .. config.characterLimit
    })
end)

-- Once the player clicks on the character in the ui, it will be set as the main character or the current character. This info can be used later in exports or elsewhere in this resource.
RegisterNUICallback("setMainCharacter", function(data)
    mainFirstName = data.firstName
    mainLastName = data.lastName
    mainDateOfBirth = data.dateOfBirth
    mainGender = data.gender
    mainTwtName = data.twtName
    mainDepartment = data.department
    mainStartingCash = data.startingCash
    mainStartingBank = data.startingBank
    mainCharaterId = data.character

    for i = 1, #config.departments do
        validDept = config.departments[i]
        if mainDepartment == validDept then
            for i = 1, #config.spawns[validDept] do
                SendNUIMessage({
                    type = "setSpawns",
                    x = config.spawns[validDept][i].x,
                    y = config.spawns[validDept][i].y,
                    z = config.spawns[validDept][i].z,
                    name = config.spawns[validDept][i].name
                })
            end
        end
    end

    registered = true
end)

-- This will display the money that the player has.
RegisterNetEvent("returnMoney")
AddEventHandler("returnMoney", function(cash, bank)
    while not registered do
        Citizen.Wait(10)
    end
    SendNUIMessage({
        type = "Money",
        cash = "Cash: $" .. cash,
        bank = "Bank: $" .. bank
    })
end)

-- Teleporting
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
    TriggerServerEvent("getMoney", mainCharaterId)
end)

-- Choosing the do not tp button.
RegisterNUICallback("tpDoNot", function(data)
    local ped = PlayerPedId()
    SwitchInPlayer(ped)
    Citizen.Wait(500)
    SetDisplay(false, "ui")
    Citizen.Wait(500)
    SetEntityVisible(ped, true, 0)
    FreezeEntityPosition(ped, false)
    TriggerServerEvent("getMoney", mainCharaterId)
end)

function SetDisplay(bool, typeName)
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = typeName,
        background = config.backgrounds[math.random(1, #config.backgrounds)],
        status = bool,
        serverName = config.serverName,
        characterAmount = characterAmount .. "/" .. config.characterLimit
    })
end

if config.enableRichPrecence then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(config.updateIntervall * 1000)
            SetDiscordAppId(config.appId)
            if registered then
                SetRichPresence(" Playing : " .. config.serverName .. " as " .. mainFirstName .. " " .. mainLastName)
                SetDiscordRichPresenceAsset(config.largeLogo)
                SetDiscordRichPresenceAssetText("Playing: " .. config.serverName)
                SetDiscordRichPresenceAssetSmall(config.smallLogo)
                SetDiscordRichPresenceAssetSmallText("Playing as: " .. mainFirstName .. " " .. mainLastName)
                SetDiscordRichPresenceAction(0, config.firstButtonName, config.firstButtonLink)
                SetDiscordRichPresenceAction(1, config.secondButtonName, config.secondButtonLink)
            end
        end
    end)
end

-- hide gta default cash, ammo and reticle hud.
if config.hideAmmoAndMoney or config.hideReticle then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if config.hideAmmoAndMoney then
                HideHudComponentThisFrame(3) -- CASH
                HideHudComponentThisFrame(4) -- MP_CASH
                HideHudComponentThisFrame(13) -- CASH_CHANGE
                HideHudComponentThisFrame(2) -- WEAPON_ICON
            end
            if config.hideReticle then
                HideHudComponentThisFrame(14) -- RETICLE
            end
            if config.customPauseMenu and registered then
                if IsPauseMenuActive() then
                    BeginScaleformMovieMethodOnFrontendHeader("SET_HEADING_DETAILS")
                    AddTextEntry("FE_THDR_GTAO", config.serverName) 
                    ScaleformMovieMethodAddParamPlayerNameString(mainFirstName .. " " .. mainLastName)
                    --PushScaleformMovieFunctionParameterString("Cash: $" .. cash)
                    --PushScaleformMovieFunctionParameterString("Bank: $" .. bank)
                    EndScaleformMovieMethod()
                end
            end
        end
    end)
end

-- Planning on moving everything money related to server side.
RegisterNetEvent("receiveBank")
AddEventHandler("receiveBank", function(amount, playerSending, name)
    SetNotificationTextEntry("STRING")
	AddTextComponentString("Recived $" .. amount .. " from " .. name .. " [".. playerSending .."]")
	SetNotificationMessage("CHAR_BANK_FLEECA", "CHAR_BANK_FLEECA", true, 9,"FleecaBank", "")
	TriggerServerEvent("addBank", amount, mainCharaterId)
end)

-- Planning on moving everything money related to server side.
RegisterNetEvent("receiveCash")
AddEventHandler("receiveCash", function(amount, playerSending, name)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(name .. " gave you $" .. amount .. ".")
	SetNotificationMessage("CHAR_DEFAULT", "CHAR_DEFAULT", true, 9, name .. " [".. playerSending .."]", "")
    TriggerServerEvent("addCash", amount, mainCharaterId)
end)

RegisterNetEvent("updateMoney")
AddEventHandler("updateMoney", function()
    TriggerServerEvent("getMoney", mainCharaterId)
end)

-- Salary | Planning on moving everything money related to server side.
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(config.salaryInterval * 60000)
        if registered then
            TriggerServerEvent("addBank", config.salaryAmount, mainCharaterId)
            SetNotificationTextEntry("STRING")
            AddTextComponentString("Daily Salary + $" .. config.salaryAmount)
            SetNotificationMessage("CHAR_BANK_FLEECA", "CHAR_BANK_FLEECA", true, 9,"FleecaBank", "")
        end
    end
end)

-- Planning on moving everything money related to server side.
function sendBank(sendingCharacterId, receiveingPlayerId, amount, sendingPlayerId)
    if registered then
        TriggerServerEvent("bankPay", sendingCharacterId, receiveingPlayerId, amount, sendingPlayerId, mainFirstName .. " " .. mainLastName)
    end
end

-- Planning on moving everything money related to server side.
function sendCash(sendingCharacterId, amount, sendingPlayerId)
    if registered then
        target, distance = GetClosestPlayer()
        if (distance ~= -1 and distance < 3) then
            TriggerServerEvent("cashPay", sendingCharacterId, GetPlayerServerId(target), amount, sendingPlayerId, mainFirstName .. " " .. mainLastName)
        else
            notify("No players nearby")
        end
    end
end

-- Notification above the map.
function notify(message)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(message)
	DrawNotification(0,1)
end

function GetClosestPlayer()
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(ply, 0)

    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = GetDistanceBetweenCoords(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

function GetPlayers()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end

    return players
end

function getCharacterInfo(infoType)
    if registered then
        mainCharacter = {
            mainFirstName,
            mainLastName,
            mainDateOfBirth,
            mainGender,
            mainTwtName,
            mainDepartment,
            mainStartingCash,
            mainStartingBank,
            mainCharaterId
        }
        return mainCharacter[infoType]
    else
        return "Error: Player not registered"
    end
end
