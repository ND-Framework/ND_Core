---@param src number
---@return table
function NDCore.getPlayer(src)
    return ActivePlayers[src]
end

---@param metadata string
---@param data any
---@return table
function NDCore.getPlayers(metadata, data)
    if not metadata or not data then return ActivePlayers end 
    local players = {}
    for src, info in pairs(ActivePlayers) do
        if info.metadata[metadata] == data then
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
