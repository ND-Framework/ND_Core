---@param src number
---@return table
function NDCore.getPlayer(src)
    return ActivePlayers[src]
end

---@param metadata string
---@param data any
---@return table
function NDCore.getPlayers(key, value)
    if not key or not value then return ActivePlayers end 
    
    local players = {}
    local keyTypes = {firstname = "firstname", lastname = "lastname", gender = "gender", groups = "groups"}
    local findBy = keyTypes[key] or "metadata"

    for src, info in pairs(ActivePlayers) do
        if info[findBy][key] == value then
            players[src] = info
        end
    end
    return players
end

---@param source number
---@return table
function NDCore.getPlayerServerInfo(source)
    return PlayersInfo[source]
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

for name, func in pairs(NDCore) do
    if type(func) == "function" then
        exports(name, func)
    end
end
