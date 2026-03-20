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
        job = "job"
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

function NDCore.getDiscordInfo(discordUserId)
    if not discordUserId or not Config.discordBotToken or not Config.discordGuildId then return end
    local done = false
    local data
    local discordErrors = {
        [400] = "Improper HTTP request",
        [401] = "Discord bot token might be missing or incorrect",
        [404] = "User might not be in the server",
        [429] = "Discord bot rate limited"
    }

    if type(discordUserId) == "string" and discordUserId:find("discord:") then discordUserId:gsub("discord:", "") end

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

    while not done do Wait(50) end
    return data
end

function NDCore.enableMultiCharacter(enable)
    Config.multiCharacter = enable
end

for name, func in pairs(NDCore) do
    if type(func) == "function" then
        exports(name, func)
    end
end
