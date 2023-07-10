NDCore = {}
ActivePlayers = {}
PlayersInfo = {}
local tempPlayersInfo = {}

AddEventHandler("playerDropped", function()
    local src = source
    local char = ActivePlayers[src]
    if not char then return end
    char:unload()
end)

SetConvarServerInfo("ND_Core", GetResourceMetadata(GetCurrentResourceName(), "version", 0) or "invalid")
SetConvarReplicated("inventory:framework", "nd")

local file = LoadResourceFile(GetCurrentResourceName(), "query.sql")
if file then
    MySQL.query(file)
end

local function getIdentifierList(src)
    local list = {}
    for i=0, GetNumPlayerIdentifiers(src) do
        local identifier = GetPlayerIdentifier(src, i)
        if identifier then
            local colon = identifier:find(":")
            list[identifierType] = identifier:sub(1, colon-1)
        end
    end
    return list
end

local discordErrors = {
    [400] = "Improper HTTP request",
    [401] = "Discord bot token might be missing or incorrect",
    [404] = "User might not be in the server",
    [429] = "Discord bot rate limited"
}

local function getDiscordInfo(discordUserId)
    local done = false
    local data

    PerformHttpRequest(("https://discordapp.com/api/guilds/%s/members/%s"):format(Config.discordGuildId, discordUserId), function(errorCode, resultData, resultHeaders)
        if errorCode ~= 200 then
            done = true
            return print(("Error %d: %s"):format(errorCode, discordErrors[errorCode]))
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
        discordInfo = getDiscordInfo(discordIdentifier:gsub("discord:"))
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
