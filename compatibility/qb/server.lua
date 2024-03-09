if not lib.table.contains(Config.compatibility, "qb") then return end

local QBCore = {}

QBCore.Config = QBConfig
QBCore.Shared = QBShared
QBCore.ClientCallbacks = {}
QBCore.ServerCallbacks = {}

QBCore.Players = {}
QBCore.Functions = {}
QBCore.Player_Buckets = {}
QBCore.Entity_Buckets = {}
QBCore.UsableItems = {}

function QBCore.Functions.GetCoords(entity)
    local coords = GetEntityCoords(entity)
    local heading = GetEntityHeading(entity)
    return vec4(coords.x, coords.y, coords.z, heading)
end

function QBCore.Functions.GetIdentifier(source, idtype)
    if GetConvarInt("sv_fxdkMode", 0) == 1 then return "license:fxdk" end
    return GetPlayerIdentifierByType(source, idtype or "license")
end

function QBCore.Functions.GetSource(identifier)
    for src, _ in pairs(NDCore.players) do
        local idens = GetPlayerIdentifiers(src)
        for _, id in pairs(idens) do
            if identifier == id then
                return src
            end
        end
    end
    return 0
end

local function createPlayer(player)
    
end

function QBCore.Functions.GetPlayer(source)
    if type(source) == "number" then
        return createPlayer(NDCore.players[source])
    else
        return createPlayer(NDCore.players[QBCore.Functions.GetSource(source)])
    end
end

function QBCore.Functions.GetPlayerByCitizenId(citizenid)
    for src in pairs(NDCore.players) do
        if NDCore.players[src].id == citizenid then
            return NDCore.players[src]
        end
    end
end

-- function QBCore.Functions.GetOfflinePlayerByCitizenId(citizenid)
--     return QBCore.Player.GetOfflinePlayer(citizenid)
-- end

-- function QBCore.Functions.GetPlayerByLicense(license)
--     return QBCore.Player.GetPlayerByLicense(license)
-- end

function QBCore.Functions.GetPlayerByPhone(number)
    for src in pairs(NDCore.players) do
        if NDCore.players[src].phonenumber == number then
            return createPlayer(NDCore.players[src])
        end
    end
end
