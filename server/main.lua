NDCore = {}
ActivePlayers = {}

AddEventHandler("playerDropped", function()
    local src = source
    local char = ActivePlayers[src]
    if not char then return end
    char:unload()
end)

SetConvarServerInfo("ND_Core", GetResourceMetadata(GetCurrentResourceName(), "version", 0) or "invalid")
