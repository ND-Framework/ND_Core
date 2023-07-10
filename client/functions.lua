function GetCoreObject()
    return NDCore
end

function NDCore.Functions.GetSelectedCharacter()
    return NDCore.SelectedCharacter
end

function NDCore.Functions.GetCharacters()
    return NDCore.Characters
end


function NDCore.Functions.GetPlayersFromCoords(distance, coords)
    if coords then
        coords = type(coords) == 'table' and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(PlayerPedId())
    end
    distance = distance or 5
    local closePlayers = {}
    local players = GetActivePlayers()
    for _, player in ipairs(players) do
        local target = GetPlayerPed(player)
        local targetCoords = GetEntityCoords(target)
        local targetdistance = #(targetCoords - coords)
        if targetdistance <= distance then
            closePlayers[#closePlayers + 1] = player
        end
    end
    return closePlayers
end

-- Callbacks are licensed under LGPL v3.0
-- <https://github.com/overextended/ox_lib>
NDCore.callback = {}
local events = {}

RegisterNetEvent("ND:callbacks", function(key, ...)
	local cb = events[key]
	return cb and cb(...)
end)

local function triggerCallback(_, name, cb, ...)
    local key = ("%s:%s"):format(name, math.random(0, 100000))
	TriggerServerEvent(("ND:%s_cb"):format(name), key, ...)
    
    local promise = not cb and promise.new()

	events[key] = function(response, ...)
        response = { response, ... }
		events[key] = nil

		if promise then
			return promise:resolve(response)
		end

        if cb then
            cb(table.unpack(response))
        end
	end

	if promise then
		return table.unpack(Citizen.Await(promise))
	end
end

setmetatable(NDCore.callback, {
	__call = triggerCallback
})

function NDCore.callback.await(name, ...)
    return triggerCallback(nil, name, false, ...)
end

function NDCore.callback.register(name, callback)
    RegisterNetEvent(("ND:%s_cb"):format(name), function(key, ...)
        TriggerServerEvent("ND:callbacks", key, callback(...))
    end)
end
