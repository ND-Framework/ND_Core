-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

local background = config.backgrounds[math.random(1, #config.backgrounds)]
local started = true
local priorityText = nil
registered = false
cash = nil
bank = nil

-- This is used to add department drop down on the ui.
RegisterNetEvent("permsChecked")
AddEventHandler("permsChecked", function(role, rolePermission)
    if rolePermission then
        SendNUIMessage({
            type = "givePerms",
            deptRole = role
        })
    end
end)

RegisterNetEvent("refreshCharacters")
AddEventHandler("refreshCharacters", function()
    TriggerServerEvent("getCharacters")
end)

Citizen.CreateThread(function()
    while started do
        Citizen.Wait(200)
        local ped = PlayerPedId()
        if IsPedOnFoot(ped) or IsPedInVehicle(ped, GetVehiclePedIsIn(ped, false), false) then
            print("^0This framework is created by ^5Andyyy#7666 ^0for support you can join the ^5discord: ^0https://discord.gg/Z9Mxu72zZ6")
            for departmentName in pairs(config.departments) do -- if you have an error that says attempt to index a nil value (global 'config') it's beacuse you have edited the config wrong.
                TriggerServerEvent("checkPerms", departmentName) -- check permissions for each department with the department names.
            end
            TriggerServerEvent("getCharacters")
            Citizen.Wait(100)
            TriggerServerEvent("getAop")
            SwitchOutPlayer(ped, 0, 1)
            FreezeEntityPosition(ped, true)
            SetEntityVisible(ped, false, 0)
            started = false
            SendNUIMessage({
                type = "onStart",
                enableMoneySystem = config.enableMoneySystem,
                maxStartingBank = config.maxStartingBank,
                maxStartingCash = config.maxStartingCash
            })
        end
    end
end)

RegisterNUICallback("exitGame", function(data)
    TriggerServerEvent("exitGame")
end)

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

    for _, spawn in pairs(config.spawns[mainDepartment]) do
        SendNUIMessage({
            type = "setSpawns",
            x = spawn.x,
            y = spawn.y,
            z = spawn.z,
            name = spawn.name
        })
    end

    TriggerServerEvent("characterOnline", mainCharaterId)
    TriggerServerEvent("getPriority")
    registered = true
end)

if config.enableMoneySystem then
    -- This will display the money that the player has.
    RegisterNetEvent("returnMoney")
    AddEventHandler("returnMoney", function(newCash, newBank)
        while not registered do
            Citizen.Wait(10)
        end
        cash = newCash
        bank = newBank
        if config.legacyMoneyDisplay then
            if registered then
                while true do
                    Citizen.Wait(0)
                    text("💵", 0.885, 0.028, 0.35, 7)
                    text("💳", 0.885, 0.068, 0.35, 7)
                    text("~g~$~w~".. cash, 0.91, 0.03, 0.55, 7)
                    text("~b~$~w~".. bank, 0.91, 0.07, 0.55, 7)
                end
            end
        else
            SendNUIMessage({
                type = "Money",
                cash = "Cash: $" .. cash,
                bank = "Bank: $" .. bank
            })
        end
    end)

    -- This is to update the players money on the ui.
    RegisterNetEvent("updateMoney")
    AddEventHandler("updateMoney", function()
        TriggerServerEvent("getMoney", mainCharaterId)
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

    -- Notification when receiving salary.
    RegisterNetEvent("receiveSalary")
    AddEventHandler("receiveSalary", function(amount)
        if registered then
            BeginTextCommandThefeedPost("STRING")
            AddTextComponentSubstringPlayerName("Daily Salary + $" .. config.salaryAmount)
            EndTextCommandThefeedPostMessagetext("CHAR_BANK_FLEECA", "CHAR_BANK_FLEECA", true, 9,"FleecaBank", "")
            TriggerServerEvent("getMoney", mainCharaterId)
        end
    end)
end

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

if config.enablePriorityCooldown then
    TriggerEvent("chat:addSuggestion", "/" .. config.startPriorityCommand, "Start a priority.")
    TriggerEvent("chat:addSuggestion", "/" .. config.stopPriorityCommand, "Stop an active priority.")
    TriggerEvent("chat:addSuggestion", "/" .. config.cooldownPriorityCommand, "Start a cooldown on priorities.", {
        {name="Time", help="Time in minutes to start a cooldown"}
    })
    
    RegisterNetEvent("returnPriority")
    AddEventHandler("returnPriority", function(priority)
        priorityText = nil
        for _, departmentName in pairs(config.canSeePriority) do
            if departmentName == mainDepartment then
                priorityText = priority
                break
            end
        end
    end)
end

if config.hideAmmoAndMoney or config.hideReticle or config.customPauseMenu or config.enablePriorityCooldown then
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
                    if registered and config.enableMoneySystem then
                        PushScaleformMovieFunctionParameterString("Cash: $" .. cash)
                        PushScaleformMovieFunctionParameterString("Bank: $" .. bank)
                    end
                    EndScaleformMovieMethod()
                end
            end
            if config.enablePriorityCooldown and priorityText and config.enablePriorityDefaultHUD then
                text(priorityText, 0.182, 0.891, 0.4, 4)
            end
        end
    end)
end

-- Notification above the map.
function notify(message)
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName(message)
	EndTextCommandThefeedPostTicker(0,1)
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
            cash,
            bank,
            mainCharaterId,
            priorityText
        }
        return mainCharacter[infoType]
    else
        return "Error: Player not registered"
    end
end

function text(text, x, y, scale, font)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextOutline()
    SetTextJustification(1)
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x, y)
end
