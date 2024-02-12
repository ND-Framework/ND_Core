function NDCore.getPlayer()
    return NDCore.player
end

function NDCore.getCharacters()
    return NDCore.characters
end

function NDCore.getPlayersFromCoords(distance, coords)
    if coords then
        coords = type(coords) == "table" and vec3(coords.x, coords.y, coords.z) or coords
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

function NDCore.getConfig(info)
    if not info then
        return Config
    end
    return Config[info]
end

function NDCore.notify(...)
    lib.notify(...)
end

for name, func in pairs(NDCore) do
    if type(func) == "function" then
        exports(name, func)
    end
end
