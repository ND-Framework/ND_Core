------------------------------------------------------------------------
------------------------------------------------------------------------
--			DO NOT EDIT IF YOU DON'T KNOW WHAT YOU'RE DOING			  --
--     							 									  --
--	   For support join my discord: https://discord.gg/Z9Mxu72zZ6	  --
------------------------------------------------------------------------
------------------------------------------------------------------------

started = true
registered = false
admin = false

RegisterNetEvent("permsChecked")
AddEventHandler("permsChecked", function(role, rolePermission)
    if rolePermission == true then
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
                TriggerServerEvent("checkPerms", config.departments[i])
            end
            Citizen.Wait(10)
            TriggerServerEvent("checkPerms", "ADMIN")
            Citizen.Wait(10)
            TriggerServerEvent("getCharacters")
            Citizen.Wait(100)
            TriggerServerEvent("getAop")
            Citizen.Wait(10)
            SwitchOutPlayer(ped, 0, 1)
            FreezeEntityPosition(ped, true)
            SetEntityVisible(ped, false, 0)
            started = false
        end
    end
end)

RegisterNUICallback("exitGame", function(data)
    TriggerServerEvent("exitGame", GetPlayerServerId(PlayerId()))
end)

RegisterNetEvent("returnCharacters")
AddEventHandler("returnCharacters", function(characters)
    for i = 1, #characters do
        index = characters[i]
        if config.debugMode then
            print(index.id .. " " .. index.firstName .. " " .. index.lastName .. " " .. index.dob .. " " .. index.gender .. index.twt .. " " .. index.department .. " " .. index.cash .. " " .. index.bank)
        end
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
    if config.debugMode then
        print("Characters: " .. characterAmount .. "/" .. config.characterLimit)
    end
    SetDisplay(true, "ui")
end)

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

RegisterNUICallback("editCharacter", function(data)
    newCharacter = {
        firstName = data.firstName,
        lastName = data.lastName,
        dateOfBirth = data.dateOfBirth,
        gender = data.gender,
        twtName = data.twtName,
        department = data.department,
        --startingCash = data.startingCash,
        --startingBank = data.startingBank,
        id = data.id
    }
    TriggerServerEvent("editCharacter", newCharacter)
end)

RegisterNUICallback("delCharacter", function(data)
    TriggerServerEvent("delCharacter", data.character)
    characterAmount = characterAmount -1
    SendNUIMessage({
        characterAmount = characterAmount .. "/" .. config.characterLimit
    })
end)

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

    if config.debugMode then
        for k, v in pairs(data) do
            print(v)
        end
    end

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

RegisterNetEvent("returnMoney")
AddEventHandler("returnMoney", function(cash, bank)
    while not registered do
        Citizen.Wait(100)
    end
    cash = cash
    bank = bank
    SendNUIMessage({
        type = "Money",
        cash = "Cash: $" .. cash,
        bank = "Bank: $" .. bank
    })
end)

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

if config.enableRichPrecence == true then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(config.updateIntervall * 1000)
            SetDiscordAppId(config.appId)
            if registered == true then
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

-- Shot spotter
if config.shotSpotterEnabled then
    local activateShotSpotter = false
    local alreadyShot = false
    RegisterNetEvent("shotSpotterReport")
    AddEventHandler("shotSpotterReport", function(x, y, z, postal)
        if registered then
            if mainDepartment == "SAHP" or mainDepartment == "LSPD" or mainDepartment == "BCSO" then
                activateShotSpotter = true
                while activateShotSpotter do
                    Citizen.Wait(0)
                    blip = AddBlipForCoord(x, y, z)
                    SetBlipSprite(blip, 161)
                    SetBlipAsShortRange(blip, true)
                    BeginTextCommandSetBlipName("STRING")
                    AddTextComponentString("Shot Spotter")
                    EndTextCommandSetBlipName(blip)
                    if not postal then
                        msg = "~r~Dispatch: ~w~Shotspotter detected in " .. GetStreetNameFromHashKey(GetStreetNameAtCoord(x, y, z)) .. "."
                    else
                        msg = "~r~Dispatch: ~w~Shotspotter detected in " .. GetStreetNameFromHashKey(GetStreetNameAtCoord(x, y, z)) .. ", postal: " .. postal .. "."
                    end
                    TriggerEvent('chat:addMessage', {
                        args = {msg}
                    })
                    Citizen.Wait(config.shotSpotterTimer * 1000)
                    activateShotSpotter = false
                    break
                end
                RemoveBlip(blip)
            end
        end
    end)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            local ped = PlayerPedId()
            if registered then
                if mainDepartment == "CIV" then
                    if IsPedShooting(ped) then
                        if not alreadyShot then
                            Citizen.Wait(config.shotSpotterDelay * 1000)
                            pedCoords = GetEntityCoords(ped)
                            if config.shotSpotterUsePostal then
                                postal = exports["nearest_postal123"]:getPostal()
                            else
                                postal = false
                            end
                            TriggerServerEvent("shotSpotterActive", pedCoords.x, pedCoords.y, pedCoords.z, postal)
                            if config.debugMode then
                                print(pedCoords.x, pedCoords.y, pedCoords.z)
                            end
                        end
                        alreadyShot = true
                        Citizen.Wait(config.shotSpotterCooldown * 1000)
                        alreadyShot = false
                    end
                end
            end
        end
    end)
end

-- hide gta default cash, ammo and reticle hud.
if config.hideAmmoAndMoney == true or config.hideReticle == true then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if config.hideAmmoAndMoney == true then
                HideHudComponentThisFrame(3) -- CASH
                HideHudComponentThisFrame(4) -- MP_CASH
                HideHudComponentThisFrame(13) -- CASH_CHANGE
                HideHudComponentThisFrame(2) -- WEAPON_ICON
            end
            if config.hideReticle == true then
                --if IsPlayerFreeAiming(PlayerPedId()) then
                    HideHudComponentThisFrame(14) -- RETICLE
                --end
            end
            if config.customPauseMenu then
                if registered then
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
        end
    end)
end

RegisterNetEvent("receiveBank")
AddEventHandler("receiveBank", function(amount, playerSending, name)
    if config.debugMode then
        print("Recived $" .. amount .. " from " .. name .. " [".. playerSending .."]")
    end
    SetNotificationTextEntry("STRING")
	AddTextComponentString("Recived $" .. amount .. " from " .. name .. " [".. playerSending .."]")
	SetNotificationMessage("CHAR_BANK_FLEECA", "CHAR_BANK_FLEECA", true, 9,"FleecaBank", "")
	TriggerServerEvent("addBank", amount, mainCharaterId)
end)

RegisterNetEvent("receiveCash")
AddEventHandler("receiveCash", function(amount, playerSending, name)
    if config.debugMode then
        print("Recived $" .. amount .. " from " .. name .. " [".. playerSending .."]")
    end
	SetNotificationTextEntry("STRING")
	AddTextComponentString(name .. " gave you $" .. amount .. ".")
	SetNotificationMessage("CHAR_DEFAULT", "CHAR_DEFAULT", true, 9, name .. " [".. playerSending .."]", "")
    TriggerServerEvent("addCash", amount, mainCharaterId)
end)

RegisterNetEvent("updateMoney")
AddEventHandler("updateMoney", function()
    TriggerServerEvent("getMoney", mainCharaterId)
end)

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

function sendBank(sendingCharacterId, receiveingPlayerId, amount, sendingPlayerId)
    if registered then
        TriggerServerEvent("bankPay", sendingCharacterId, receiveingPlayerId, amount, sendingPlayerId, mainFirstName .. " " .. mainLastName)
    end
end

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

function getCharacterInfo(int)
    if registered then
        if int == 1 then
            return mainFirstName
        elseif int == 2 then
            return mainLastName
        elseif int == 3 then
            return mainDateOfBirth
        elseif int == 4 then
            return mainGender
        elseif int == 5 then
            return mainTwtName
        elseif int == 6 then
            return mainDepartment
        elseif int == 7 then
            return mainStartingCash
        elseif int == 8 then
            return mainStartingBank
        elseif int == 9 then
            return mainCharaterId
        end
    end
end