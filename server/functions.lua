function NDCore.getPlayerIdentifierByType(src, indentifierType)
    if Config.sv_lan then
        return ("%s:sv_lan"):format(indentifierType)
    end
    return GetPlayerIdentifierByType(src, indentifierType)
end

---@param src number
---@return table
function NDCore.getPlayer(src)
    return NDCore.players[src]
end

---@param metadata string
---@param data any
---@return table
function NDCore.getPlayers(key, value, returnArray)
    if not key or not value then return NDCore.players end 
    
    local players = {}
    local keyTypes = {
        id = "id",
        firstname = "firstname",
        lastname = "lastname",
        gender = "gender",
        groups = "groups",
        job = "job",
        gender = "gender"
    }

    local findBy = keyTypes[key] or "metadata"

    if findBy then
        for src, info in pairs(NDCore.players) do
            if findBy == "metadata" and info["metadata"][key] == value or info[findBy] == value then
                if returnArray then
                    players[#players+1] = info
                else
                    players[src] = info
                end
            end
        end
    end
    return players
end

---@param source number
---@return table
function NDCore.getPlayerServerInfo(source)
    return PlayersInfo[source]
end

function NDCore.getConfig(info)
    if not info then
        return Config
    end
    return Config[info]
end

---@param fileLocation string|tabale
---@return boolean
function NDCore.loadSQL(fileLocation, resource)
    local resourceName = resource or GetInvokingResource() or  GetCurrentResourceName()

    if type(fileLocation) == "string" then
        local file = LoadResourceFile(resourceName, fileLocation)
        if not file then return end
        MySQL.query(file)
        return true
    end
    
    for i=1, #fileLocation do
        local file = LoadResourceFile(resourceName, fileLocation[i])
        if file then
            MySQL.query(file)
            Wait(100)
        end
    end
    return true
end

local DiscordCache = {}
local CacheRefreshInterval = 30 * 60 * 1000 

local discordErrors = {
    [400] = "Improper HTTP request",
    [401] = "Discord bot token might be missing or incorrect",
    [404] = "User might not be in the server",
    [429] = "Discord bot rate limited"
}

function NDCore.buildDiscordCache()
    local done = false

    PerformHttpRequest(("https://discordapp.com/api/guilds/%s/members?limit=500"):format(Config.discordGuildId), function(errorCode, resultData, resultHeaders)
        if errorCode ~= 200 then
            done = true
            return print(("^3[Warning]: %d %s"):format(errorCode, discordErrors[errorCode] or "Unknown Error"))
        end

        local working, members = pcall(function() return json.decode(resultData) end)
        if not working or not members then
            done = true
            return print("^1[Error]: Failed to decode Discord cache response.")
        end

        DiscordCache = {}
        local count = 0
        for _, member in ipairs(members) do
            local name = member.nick or member.user.username
            if name and name:sub(1, 1) == "[" then
                DiscordCache[member.user.id] = member
                count = count + 1
            end
        end

        print(("^2[DEBUG] Cached %d Discord members successfully."):format(count))
        done = true
    end, "GET", "", {["Authorization"] = "Bot " .. Config.discordBotToken})

    while not done do Wait(50) end
end


function NDCore.getDiscordInfo(discordUserId)
    if not discordUserId or not Config.discordBotToken or not Config.discordGuildId then return end
    if type(discordUserId) == "string" and discordUserId:find("discord:") then
        discordUserId = discordUserId:gsub("discord:", "")
    end

    if DiscordCache[discordUserId] then
        local result = DiscordCache[discordUserId]
        return {
            nickname = result.nick or result.user.username,
            user = result.user,
            roles = result.roles
        }
    end

    local done = false

    PerformHttpRequest(("https://discordapp.com/api/guilds/%s/members/%s"):format(Config.discordGuildId, discordUserId), function(errorCode, resultData, resultHeaders)
        if errorCode ~= 200 then
            done = true
            return print(("^3[Warning]: %d %s"):format(errorCode, discordErrors[errorCode] or "Unknown Error"))
        end

        local result = json.decode(resultData)
        local data = {
            nickname = result.nick or result.user.username,
            user = result.user,
            roles = result.roles
        }

        if result.nick and result.nick:sub(1, 1) == "[" then
            DiscordCache[discordUserId] = result
        end

        done = true
    end, "GET", "", {
        ["Content-Type"] = "application/json",
        ["Authorization"] = "Bot " .. Config.discordBotToken
    })

    while not done do Wait(50) end
    return data
end

CreateThread(function()
    while true do
        NDCore.buildDiscordCache()
        Wait(CacheRefreshInterval)
    end
end)

RegisterCommand("reloaddiscordcache", function(src, args, raw)
    if src == 0 then
        print("^3[NDCore]^7 Reloading Discord cache manually...")
        NDCore.buildDiscordCache()
    end
end, true)


function NDCore.enableMultiCharacter(enable)
    Config.multiCharacter = enable
end

for name, func in pairs(NDCore) do
    if type(func) == "function" then
        exports(name, func)
    end
end
