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

for name, func in pairs(NDCore) do
    if type(func) == "function" then
        exports(name, func)
    end
end
