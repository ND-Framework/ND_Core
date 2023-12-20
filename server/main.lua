NDCore = {}
NDCore.players = {}
PlayersInfo = {}
local resourceName = GetCurrentResourceName()
local tempPlayersInfo = {}

Config = {
    serverName = GetConvar("core:serverName", "Unconfigured ND-Core Server"),
    discordInvite = GetConvar("core:discordInvite", "https://discord.gg/Z9Mxu72zZ6"),
    discordAppId = GetConvar("core:discordAppId", "858146067018416128"),
    discordAsset = GetConvar("core:discordAsset", "andyyy"),
    discordAssetSmall = GetConvar("core:discordAssetSmall", "andyyy"),
    discordActionText = GetConvar("core:discordActionText", "DISCORD"),
    discordActionLink = GetConvar("discordActionLink", "https://discord.gg/Z9Mxu72zZ6"),
    discordActionText2 = GetConvar("core:discordActionText2", "STORE"),
    discordActionLink2 = GetConvar("core:discordActionLink2", "https://andyyy.tebex.io/category/fivem-scripts"),
    characterIdentifier = GetConvar("core:characterIdentifier", "license"),
    discordGuildId = GetConvar("core:discordGuildId", "false"),
    discordBotToken = GetConvar("core:discordBotToken", "false"),
    randomUnlockedVehicleChance = GetConvarInt("core:randomUnlockedVehicleChance", 30),
    disableVehicleAirControl = GetConvarInt("core:disableVehicleAirControl", 1) == 1,
    useInventoryForKeys = GetConvarInt("core:useInventoryForKeys", 1) == 1,
    groups = json.decode(GetConvar("core:groups", "[]")),
    admins = json.decode(GetConvar("core:admins", "[]")),
    adminDiscordRoles = json.decode(GetConvar("core:adminDiscordRoles", "[]")),
    multiCharacter = false,
    compatibility = json.decode(GetConvar("core:compatibility", "[]"))
}

SetConvarServerInfo("Discord", Config.discordInvite)
SetConvarServerInfo("NDCore", GetResourceMetadata(resourceName, "version", 0) or "invalid")
SetConvarReplicated("inventory:framework", "nd")

local function getIdentifierList(src)
    local list = {}
    for i=0, GetNumPlayerIdentifiers(src) do
        local identifier = GetPlayerIdentifier(src, i)
        if identifier then
            local colon = identifier:find(":")
            local identifierType = identifier:sub(1, colon-1)
            list[identifierType] = identifier
        end
    end
    return list
end

AddEventHandler("playerJoining", function(oldId)
    local src = source
    local oldTempId = tonumber(oldId)
    PlayersInfo[src] = tempPlayersInfo[oldTempId]
    tempPlayersInfo[oldTempId] = nil

    if Config.multiCharacter then return end
    Wait(3000)

    local characters = NDCore.fetchAllCharacters(src)
    local id = next(characters)
    if id then
        return NDCore.setActiveCharacter(src, id)
    end

    local player = NDCore.newCharacter(src, {
        firstname = GetPlayerName(src),
        lastname = "",
        dob = "",
        gender = ""
    })
    NDCore.setActiveCharacter(src, player.id)
end)

local function checkDiscordIdentifier(identifiers)
    if Config.discordBotToken == "false" or Config.discordGuildId == "false" then return end

    local discordIdentifier = identifiers["discord"]
    if not discordIdentifier then return end

    return NDCore.getDiscordInfo(discordIdentifier:gsub("discord:", ""))
end

AddEventHandler("onResourceStart", function(name)
    if name ~= resourceName then return end
    for _, playerId in ipairs(GetPlayers()) do
        local src = tonumber(playerId)
        local identifiers = getIdentifierList(src)
        PlayersInfo[src] = {
            identifiers = identifiers,
            discord = checkDiscordIdentifier(identifiers) or {}
        }
        Wait(65)
    end
end)

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local tempSrc = source
    local identifiers = getIdentifierList(tempSrc)
    local mainIdentifier = identifiers[Config.characterIdentifier]
    local discordInfo = {}

    deferrals.defer()
    Wait(0)

    if mainIdentifier and Config.discordBotToken ~= "false" and Config.discordGuildId ~= "false" and next(discordInfo) == nil then
        discordInfo = checkDiscordIdentifier(identifiers)
        if not discordInfo then
            deferrals.done(("Your discord was not found, join our discord here: %s."):format(Config.discordInvite))
            Wait(0)
        end
    end

    deferrals.update("Connecting...")
    Wait(0)

    if mainIdentifier then
        tempPlayersInfo[tempSrc] = {
            identifiers = identifiers,
            discord = discordInfo
        }
        deferrals.done()
    else
        deferrals.done(("Your %s was not found."):format(Config.characterIdentifier))
        Wait(0)
    end
end)

AddEventHandler("playerDropped", function()
    local src = source
    local char = NDCore.players[src]
    if char then char.unload() end
    PlayersInfo[src] = nil
end)

AddEventHandler("onResourceStop", function(name)
    if name ~= resourceName then return end
    for _, player in pairs(NDCore.players) do
        player.unload()
        Wait(10)
    end
end)

SetTimeout(500, function()
    NDCore.loadSQL({
        "database/characters.sql",
        "database/vehicles.sql"
    }, resourceName)
end)

RegisterNetEvent("ND:playerEliminated", function(info)
    local src = source
    local player = NDCore.getPlayer(src)
    if not player then return end
    player.setMetadata({
        dead = true,
        deathInfo = info
    })
end)
