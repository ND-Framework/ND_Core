------------------------------------------------------------------------
------------------------------------------------------------------------
--			DO NOT EDIT IF YOU DON'T KNOW WHAT YOU'RE DOING			  --
--     							 									  --
--	   For support join my discord: https://discord.gg/Z9Mxu72zZ6	  --
------------------------------------------------------------------------
------------------------------------------------------------------------

--PlaySoundFrontend(-1, "PIN_BUTTON", "ATM_SOUNDS", 1)

local display = false
local balance = nil

local atmModels = {
    "-870868698",  -- older atms
    "-1126237515",  -- blue atm
    "-1364697528",  -- red atm
    "506770882"  -- green atm
}

local days = {
    [0] = "Sunday",
    [1] = "Monday",
    [2] = "Tuesday",
    [3] = "Wednesday",
    [4] = "Thursday",
    [5] = "Friday",
    [6] = "Saturday"
}

local months = {
    [1] = "January",
    [2] = "February",
    [3] = "March",
    [4] = "April",
    [5] = "May",
    [6] = "June",
    [7] = "July",
    [8] = "August",
    [9] = "September",
    [10] = "October",
    [11] = "November",
    [12] = "December"
}

RegisterNUICallback("close", function(data)
    PlaySoundFrontend(-1, "PIN_BUTTON", "ATM_SOUNDS", 1)
    SetDisplay(false)
end)

RegisterNUICallback("sound", function(data)
    PlaySoundFrontend(-1, "PIN_BUTTON", "ATM_SOUNDS", 1)
end)

RegisterNUICallback("withdraw", function(data)
    TriggerServerEvent("ND:withdraw", data.amount)
end)

RegisterNUICallback("deposit", function(data)
    TriggerServerEvent("ND:deposit", data.amount)
end)

-- Alert thread
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		if not display and IsNearATM() then
			alert("Press ~INPUT_CONTEXT~ to use the ATM")
			if IsControlJustPressed(0, 51) then
				SetDisplay(true)
			end
            if display then
                TriggerScreenblurFadeIn(1000)
            else
                TriggerScreenblurFadeOut(1000)
            end
		end
	end
end)

-- Hide/Show ui
function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        status = bool,
		playerName = exports["ND_Core"]:getCharacterInfo(1) .. " " .. exports["ND_Core"]:getCharacterInfo(2),
		balance = "Account Balance: $" .. exports["ND_Core"]:getCharacterInfo(8) .. ".00",
        date = getDay() .. ", " .. getMonth() .. " " .. GetClockDayOfMonth() .. ", " .. GetClockYear(),
        time = getTime()
    })
end

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

-- Get the day of the week
function getDay()
    local currentDay = GetClockDayOfWeek()
    for k, v in pairs(days) do
        if currentDay == k then
            return v
        end
    end
end

-- Get Month of the year
function getMonth()
    local currentMonth = GetClockMonth()
    for k, v in pairs(months) do
        if currentMonth == k then
            return v
        end
    end
end

-- Alert on top left of screen
function alert(msg) 
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, 0, 1, -1)
end

-- Check if player is near an atm
function IsNearATM()
	local playerCoords = GetEntityCoords(PlayerPedId(), 0)
    for k, v in pairs(atmModels) do
        ATM = GetCoordsAndRotationOfClosestObjectOfType(playerCoords.x, playerCoords.y, playerCoords.z, 0.7, tonumber(v), 0)
        if ATM == 1 then
            return true
        end
    end
end