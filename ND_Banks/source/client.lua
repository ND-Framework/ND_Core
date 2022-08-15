-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

NDCore = exports["ND_Core"]:GetCoreObject()
local display = false
local nearModel = false

local banks = {
    [1] = { -- harmony fleeca bank
	   ["coords"] = vector3(1175.77, 2706.89, 38.09),
	   ["name"] = "Fleeca Bank"
    },
    [2] = { -- legion square fleeca bank
	    ["coords"] = vector3(149.23, -1040.57, 29.36),
	    ["name"] = "Fleeca Bank"
    },
    [3] = {
        ["coords"] = vector3(-2962.53, 482.25, 15.69),
        ["name"] = "Fleeca Bank"
    },
    [4] = { -- paleto bay bank
        ["coords"] = vector3(-112.02, 6469.13, 31.62),
        ["name"] = "Blaine County Savings Bank"
    },
    [5] = {
        ["coords"] = vector3(-351.56, -49.70, 49.02),
        ["name"] = "Fleeca Bank"
    },
    [6] = {
        ["coords"] = vector3(-351.56, -49.70, 49.02),
        ["name"] = "Fleeca Bank"
    },
    [7] = {
        ["coords"] = vector3(313.66, -278.90, 54.16),
        ["name"] = "Fleeca Bank"
    },
}

local days = {
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday"
}

-- Get the time
function getTime()
    local hours = GetClockHours()
    local minutes = GetClockMinutes()
    if hours <= 9 then
        hours = "0" .. hours
    end
    if minutes <= 9 then
        minutes = "0" .. minutes
    end
    return hours .. ":" .. minutes
end

-- Hide/Show ui
function SetDisplay(bool)
    local selectedCharacter = NDCore.Functions.GetSelectedCharacter()
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        status = bool,
		playerName = selectedCharacter.firstName .. " " .. selectedCharacter.lastName,
		balance = "Account Balance: $" .. selectedCharacter.bank .. ".00",
        date = days[GetClockDayOfWeek() + 1],
        time = getTime()
    })
end

function drawText3D(coords, text)
    local onScreen, _x, _y = GetScreenCoordFromWorldCoord(coords.x, coords.y, coords.z + 0.3)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
    SetTextScale(0.4, 0.4)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(true)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()
    AddTextComponentString(text)
    DrawText(_x, _y)
end

-- check if ped is close to a bank coordinate.
function inRange(ped)
    playerCoords = GetEntityCoords(ped)
    for _, bank in pairs(banks) do
        if (#(playerCoords - bank.coords)) < 1.5 then
            return bank.coords
        end
    end
    return false
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)
        ped = PlayerPedId()
        nearModel = inRange(ped)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if not display and nearModel then
            drawText3D(nearModel, "~w~Press ~g~E ~w~to use the bank")
            if IsControlJustPressed(0, 51) then
                SetDisplay(true)
                TriggerScreenblurFadeIn(1000)
            end
        end
    end
end)

CreateThread(function()
	for _, blips in ipairs(banks) do
		local blip = AddBlipForCoord(blips.coords)
		SetBlipSprite(blip, 431)
		SetBlipColour(blip, 2)
		SetBlipScale(blip, 1.0)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(blips.name)
		EndTextCommandSetBlipName(blip)
	end
end)

-- close the ui.
RegisterNUICallback("close", function(data)
    PlaySoundFrontend(-1, "PIN_BUTTON", "ATM_SOUNDS", 1)
    SetDisplay(false)
    TriggerScreenblurFadeOut(1000)
end)

-- makes a button sount for when the ui is clicked.
RegisterNUICallback("sound", function(data)
    PlaySoundFrontend(-1, "PIN_BUTTON", "ATM_SOUNDS", 1)
end)

-- deposit/withdraw
RegisterNUICallback("useATM", function(data)
    local action = string.gsub(data.action, " ", "")
    if action == "WITHDRAW" then
        if data.amount == "" then
            Citizen.Wait(1000)
            SendNUIMessage({
                success = false
            })
            return
        end
        TriggerServerEvent("ND_Banks:withdraw", data.amount)
    elseif action == "DEPOSIT" then
        if data.amount == "" then
            Citizen.Wait(1000)
            SendNUIMessage({
                success = false
            })
            return
        end
        TriggerServerEvent("ND_Banks:deposit", data.amount)
    elseif action == "TRANSFER" then
        if data.transferAmount == "" or data.transferTarget == "" then
            Citizen.Wait(1000)
            SendNUIMessage({
                success = false
            })
            return
        end
        TriggerServerEvent("ND_Banks:transfer", data.transferAmount, data.transferTarget)
    end
end)

-- update the balance on the ui and confirm if the deposit/withdraw was successful.
RegisterNetEvent("ND_Banks:update")
AddEventHandler("ND_Banks:update", function(status)
    Citizen.Wait(1000)
    local selectedCharacter = NDCore.Functions.GetSelectedCharacter()
    SendNUIMessage({
        balance = "Account Balance: $" .. selectedCharacter.bank .. ".00",
        success = status
    })
end)