NDCore = {}
ActivePlayers = {}
PlayersInfo = {}
local resourceName = GetCurrentResourceName()
local tempPlayersInfo = {}
local databaseFiles = {
    "database/characters.sql",
    "database/vehicles.sql"
}
local discordErrors = {
    [400] = "Improper HTTP request",
    [401] = "Discord bot token might be missing or incorrect",
    [404] = "User might not be in the server",
    [429] = "Discord bot rate limited"
}

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
    discordGuildId = GetConvar("core:discordGuildId"),
    discordBotToken = GetConvar("core:discordBotToken"),
    randomUnlockedVehicleChance = GetConvarInt("core:randomUnlockedVehicleChance", 30),
    disableVehicleAirControl = GetConvarInt("core:disableVehicleAirControl", 1) == 1,
    useInventoryForKeys = GetConvarInt("core:useInventoryForKeys", 1) == 1,
    groups = json.decode(GetConvar("core:groups", "[]"))
}

SetConvarServerInfo("ND_Core", GetResourceMetadata(resourceName, "version", 0) or "invalid")
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

local function getDiscordInfo(discordUserId)
    local done = false
    local data

    PerformHttpRequest(("https://discordapp.com/api/guilds/%s/members/%s"):format(Config.discordGuildId, discordUserId), function(errorCode, resultData, resultHeaders)
        if errorCode ~= 200 then
            done = true
            return print(("^3Warning: %d %s"):format(errorCode, discordErrors[errorCode]))
        end

        local result = json.decode(resultData)
        data = {
            nickname = result.nick or result.user.username,
            user = result.user,
            roles = result.roles
        }
        done = true
    end, "GET", "", {["Content-Type"] = "application/json", ["Authorization"] = ("Bot %s"):format(Config.discordBotToken)})

    while not done do Wait(500) end
    return data
end

AddEventHandler("playerJoining", function(oldId)
    local src = source
    PlayersInfo[src] = tempPlayersInfo[oldId]
    tempPlayersInfo[oldId] = nil
end)

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local tempSrc = source
    local identifiers = getIdentifierList(tempSrc)
    local mainIdentifier = identifiers[Config.characterIdentifier]
    local discordInfo = {}

    deferrals.defer()
    Wait(0)

    if mainIdentifier and Config.discordBotToken and Config.discordGuildId then
        local discordIdentifier = identifiers["discord"]
        if not discordIdentifier then
            deferrals.done(("Your discord was not found, join our discord here: %s."):format(Config.discordInvite))
            Wait(0)
            return
        end
        discordInfo = getDiscordInfo(discordIdentifier:gsub("discord:", ""))
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
    local char = ActivePlayers[src]
    if char then
        char:unload()
    end
    PlayersInfo[src] = nil
end)

for i=1, #databaseFiles do
    local file = LoadResourceFile(resourceName, databaseFiles[i])
    if file then
        MySQL.query(file)
    end
end
