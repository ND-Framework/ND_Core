NDCore = {}

CreateThread(function()
    SetDiscordAppId(Config.discordAppId)
    SetDiscordRichPresenceAsset(Config.discordAsset)
    SetDiscordRichPresenceAssetSmall(Config.discordAssetSmall)
    SetDiscordRichPresenceAction(0, Config.discordActionText, Config.discordActionLink)
    SetDiscordRichPresenceAction(1, Config.discordActionText2, Config.discordActionLink2)
    local presenceText = ("Playing: %s"):format(Config.serverName)
    while true do
        if NDCore.player then
            local presence = ("Playing: %s as % %"):format(Config.serverName, NDCore.player.firstname, NDCore.player.lastname)
            local presenceTextSmall = ("Playing as: %s %s"):format(NDCore.player.firstname, NDCore.player.lastname)
            SetRichPresence(presence)
            SetDiscordRichPresenceAssetText(presenceText)
            SetDiscordRichPresenceAssetSmallText(presenceTextSmall)
        end
        Wait(60000)
    end
end)

CreateThread(function()
    AddTextEntry("FE_THDR_GTAO", Config.serverName)
    local sleep = 500
    while true do
        Wait(sleep)
        if NDCore.player and IsPauseMenuActive() then
            sleep = 0
            BeginScaleformMovieMethodOnFrontendHeader("SET_HEADING_DETAILS")
            ScaleformMovieMethodAddParamPlayerNameString(("%s %s"):format(NDCore.player.firstname, NDCore.player.lastname))
            ScaleformMovieMethodAddParamTextureNameString(("Cash: $%d"):format(NDCore.player.cash))
            ScaleformMovieMethodAddParamTextureNameString(("Bank: $%d"):format(NDCore.player.bank))
            EndScaleformMovieMethod()
        elseif sleep == 0 then
            sleep = 500
        end
    end
end)
