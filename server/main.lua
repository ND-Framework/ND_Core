ActivePlayers = {}

function NDCore.getPlayer(src)
    return ActivePlayers[src]
end

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

AddEventHandler("playerDropped", function()
    local src = source
    local char = ActivePlayers[src]
    if not char then return end
    char:unload()
end)

SetConvarServerInfo("ND_Core", GetResourceMetadata(GetCurrentResourceName(), "version", 0) or "invalid")
