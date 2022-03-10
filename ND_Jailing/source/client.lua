local display = false
local isJailed = false

function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
    SendNUIMessage({
        type = "ui",
        status = bool
    })
end

function alert(msg) 
    BeginTextCommandDisplayHelp("STRING")
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, 0, 1, -1)
end

-- Jail a player and loop to keep them in jail every second.
RegisterNetEvent("ND_Jailing:jailPlayer")
AddEventHandler("ND_Jailing:jailPlayer", function(time)
    local player = PlayerPedId()
    isJailed = true
    SetEntityCoords(player, config.jailCoords.x, config.jailCoords.y, config.jailCoords.z, false, false, false, false)
    SetEntityHeading(player, config.jailCoords.h)

    while isJailed do
        time = time -1
        local pedCoords = GetEntityCoords(player)

        if #(pedCoords - vector3(config.jailCoords.x, config.jailCoords.y, config.jailCoords.z)) > config.jailDistance then
            SetEntityCoords(player, config.jailCoords.x, config.jailCoords.y, config.jailCoords.z, false, false, false, false)
        end
        if time == 0 then
            SetEntityCoords(player, config.releaseCoords.x, config.releaseCoords.y, config.releaseCoords.z, false, false, false, false)
            SetEntityHeading(player, config.releaseCoords.h)
            Citizen.Wait(100)
            TaskGoStraightToCoord(player, config.releaseCoords.x + 10, config.releaseCoords.y, config.releaseCoords.z, 1.0, 8000, config.releaseCoords.h, 0)
            isJailed = false
        end
        Citizen.Wait(1000)
    end
end)

-- Chat suggestion for command.
TriggerEvent("chat:addSuggestion", "/jail", "Jail a player", {
    {name="Id", help="Player Id"},
    {name="time", help="time to jail (seconds)"},
    {name="Reason", help="Short reason or list of charges."}
})

-- Same jail function but with a command.
RegisterCommand("jail", function(source, args, rawCommand)
    local id = tonumber(args[1])
    local time = tonumber(args[2])
    local reason = args[3]
    local hasAccess = false
    for _, dept in pairs(config.accessDepartments) do
        if exports["ND_Core"]:getCharacterInfo(6) == dept then
            hasAccess = true
            break
        end
    end
    if hasAccess then
        local name = GetPlayerName(GetPlayerFromServerId(id))
        if not GetPlayerFromServerId(id) then
            TriggerEvent("chat:addMessage", {
                color = { 255, 0, 0},
                multiline = true,
                args = {"[Error]", "couldn't find a player with id " .. id .. "."}
            })
        elseif time > config.maxJailTime then
            TriggerEvent("chat:addMessage", {
                color = { 255, 0, 0},
                multiline = true,
                args = {"[Error]", "max time to jail is: " .. config.maxJailTime .. " seconds."}
            })
        elseif time <= config.maxJailTime then
            TriggerServerEvent("jailPlayer", id, name, time, reason)
            SetDisplay(false)
        end
    else
        TriggerEvent("chat:addMessage", {
            color = { 255, 0, 0},
            multiline = true,
            args = {"[Error]", "You don't have permission to use this command."}
        })
    end
end, false)

-- Return list of all players on the server and open ui.
RegisterNetEvent("ND_Jailing:returnPlayers")
AddEventHandler("ND_Jailing:returnPlayers", function(players)
    for _, player in pairs(players) do
        SendNUIMessage({
            type = "players",
            players = player,
        })
    end
    SetDisplay(true)
end)

-- Check permission and distance of player.
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
        local pedCoords = GetEntityCoords(PlayerPedId())
        for locations in pairs(config.accessLocation) do
            if #(pedCoords - vector3(config.accessLocation[locations].x, config.accessLocation[locations].y, config.accessLocation[locations].z)) < config.accessDistance then
                for _, dept in pairs(config.accessDepartments) do
                    if exports["ND_Core"]:getCharacterInfo(6) == dept then
                        if not display then
                            alert("Press ~INPUT_CONTEXT~ to open the jail ui")
                        end
                        if IsControlJustPressed(1, 51) then
                            TriggerServerEvent("ND_Jailing:getPlayers")
                        end
                    end
                end
            end
        end
	end
end)

-- When form is submitted.
RegisterNUICallback("sumbit", function(data)
    local id = tonumber(string.sub(data.id, 2, string.find(data.id, ")") - 1))
    local time = tonumber(data.time)
    local reason = data.reason
    local name = GetPlayerName(GetPlayerFromServerId(id))
    if time > config.maxJailTime then
        SendNUIMessage({
            error = "Error: max time to jail is: " .. config.maxJailTime .. " seconds."
        })
        Citizen.Wait(5000)
        SendNUIMessage({
            error = ""
        })
    else
        TriggerServerEvent("ND_Jailing:jailPlayer", id, name, time, reason)
        SendNUIMessage({
            type = "clean"
        })
        SetDisplay(false)
    end
end)

-- Close ui.
RegisterNUICallback("closeUI", function(data)
    SetDisplay(false)
end)