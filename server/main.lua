lib.locale()
NDCore = {}
NDCore.players = {}
PlayersInfo = {}
local resourceName = GetCurrentResourceName()
local tempPlayersInfo = {}

Config = {
    serverName = GetConvar("core:serverName", "Unconfigured ND-Core Server"),
    discordInvite = GetConvar("core:discordInvite", "https://discord.gg/Z9Mxu72zZ6"),
    discordMemeberRequired = GetConvarInt("core:discordMemeberRequired", 1) == 1,
    discordAppId = GetConvar("core:discordAppId", "858146067018416128"),
    discordAsset = GetConvar("core:discordAsset", "andyyy"),
    discordAssetSmall = GetConvar("core:discordAssetSmall", "andyyy"),
    discordActionText = GetConvar("core:discordActionText", "DISCORD"),
    discordActionLink = GetConvar("discordActionLink", "https://discord.gg/Z9Mxu72zZ6"),
    discordActionText2 = GetConvar("core:discordActionText2", "STORE"),
    discordActionLink2 = GetConvar("core:discordActionLink2", "https://andyyy.tebex.io/category/fivem-scripts"),
    characterIdentifier = GetConvar("core:characterIdentifier", "license"),
    selectIdentifiers = json.decode(GetConvar("core:selectIdentifiers", '["discord", "license", "license2", "fivem"]')),
    discordGuildId = GetConvar("core:discordGuildId", "false"),
    discordBotToken = GetConvar("core:discordBotToken", "false"),
    randomUnlockedVehicleChance = GetConvarInt("core:randomUnlockedVehicleChance", 30),
    disableVehicleAirControl = GetConvarInt("core:disableVehicleAirControl", 1) == 1,
    useInventoryForKeys = GetConvarInt("core:useInventoryForKeys", 1) == 1,
    groups = json.decode(GetConvar("core:groups", "[]")),
    admins = json.decode(GetConvar("core:admins", "[]")),
    adminDiscordRoles = json.decode(GetConvar("core:adminDiscordRoles", "[]")),
    groupRoles = json.decode(GetConvar("core:groupRoles", "[]")),
    multiCharacter = false,
    compatibility = json.decode(GetConvar("core:compatibility", "[]")),
    sv_lan = GetConvar("sv_lan", "false") == "true",
    platePattern = GetConvar("core:platePattern", "11AAA111")
}

SetConvarServerInfo("Discord", Config.discordInvite)
SetConvarServerInfo("NDCore", GetResourceMetadata(resourceName, "version", 0) or "invalid")
SetConvarReplicated("inventory:framework", "nd")

lib.versionCheck('ND-Framework/ND_Core')

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

    if Config.sv_lan then
        list[Config.characterIdentifier] = NDCore.getPlayerIdentifierByType(src, Config.characterIdentifier)
    end

    return list
end

AddEventHandler("playerJoining", function(oldId)
    local src = source
    local oldTempId = tonumber(oldId)
    PlayersInfo[src] = tempPlayersInfo[oldTempId]
    tempPlayersInfo[oldTempId] = nil

    if Config.sv_lan then
        lib.addPrincipal(("player.%s"):format(src), "group.admin")
    end

    local identifiers = PlayersInfo[src] and PlayersInfo[src].identifiers or getIdentifierList(src)

    local whereParts = {}
    local params = {}

    for identifierType, identifier in pairs(identifiers) do
        local isSelected = false
        for i=1, #Config.selectIdentifiers do
            local selectedType = Config.selectIdentifiers[i]
            if identifierType == selectedType then
                isSelected = true
                break
            end
        end
        
        if isSelected then
            local columnName = "id_" .. identifierType
            local cleanId = identifier:gsub("^[^:]*:", "")
            table.insert(whereParts, columnName .. " = ?")
            table.insert(params, cleanId)
        end
    end

    local user = nil
    if #whereParts > 0 then
        local query = "SELECT user_id FROM nd_users WHERE " .. table.concat(whereParts, " OR ") .. " LIMIT 1"
        user = MySQL.query.await(query, params)
    end

    if user and user[1] then
        PlayersInfo[src].userId = user[1].user_id

        local updateParts = {}
        local updateParams = {}
        
        for identifierType, identifier in pairs(identifiers) do
            local columnName = "id_" .. identifierType
            local cleanId = identifier:gsub("^[^:]*:", "")
            table.insert(updateParts, columnName .. " = ?")
            table.insert(updateParams, cleanId)
        end
        
        if #updateParts > 0 then
            table.insert(updateParams, user[1].user_id)
            local updateQuery = "UPDATE nd_users SET " .. table.concat(updateParts, ", ") .. " WHERE user_id = ?"
            MySQL.update.await(updateQuery, updateParams)
        end
    else
        local columns = {}
        local values = {}
        local insertParams = {}

        for identifierType, identifier in pairs(identifiers) do
            local columnName = "id_" .. identifierType
            local cleanId = identifier:gsub("^[^:]*:", "")
            table.insert(columns, columnName)
            table.insert(values, "?")
            table.insert(insertParams, cleanId)
        end

        local insertQuery = "INSERT INTO nd_users (" .. table.concat(columns, ", ") .. ") VALUES (" .. table.concat(values, ", ") .. ")"
        local user_id = MySQL.insert.await(insertQuery, insertParams)
        PlayersInfo[src].userId = user_id
    end

    if Config.multiCharacter then return end
    Wait(3000)

    local characters = NDCore.fetchAllCharacters(src)
    local id = next(characters)
    if id then
        return NDCore.setActiveCharacter(src, id)
    end

    local player = NDCore.newCharacter(src, {
        firstname = GetPlayerName(src),
        lastname = "",
        dob = "",
        gender = ""
    })
    NDCore.setActiveCharacter(src, player.id)
end)

local function checkDiscordIdentifier(identifiers)
    if Config.discordBotToken == "false" or Config.discordGuildId == "false" then return end

    local discordIdentifier = identifiers["discord"]
    if not discordIdentifier then return end

    return NDCore.getDiscordInfo(discordIdentifier:gsub("discord:", ""))
end

AddEventHandler("onResourceStart", function(name)
    if name ~= resourceName then return end
    for _, playerId in ipairs(GetPlayers()) do
        local src = tonumber(playerId)
        local identifiers = getIdentifierList(src)
        PlayersInfo[src] = {
            identifiers = identifiers,
            discord = checkDiscordIdentifier(identifiers) or {}
        }
        Wait(65)
    end
end)

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    local tempSrc = source
    local identifiers = getIdentifierList(tempSrc)
    local mainIdentifier = identifiers[Config.characterIdentifier]
    local discordInfo = nil

    deferrals.defer()
    Wait(0)

    if mainIdentifier and Config.discordBotToken ~= "false" and Config.discordGuildId ~= "false" then
        discordInfo = checkDiscordIdentifier(identifiers)
        if not discordInfo and Config.discordMemeberRequired and not Config.sv_lan then
            deferrals.done(locale("not_in_discord", Config.discordInvite))
            Wait(0)
        end
    end

    deferrals.update(locale("connecting"))
    Wait(0)

    if Config.sv_lan then
        tempPlayersInfo[tempSrc] = {
            identifiers = {
                [Config.characterIdentifier] = "sv_lan"
            },
            discord = discordInfo
        }
        deferrals.done()
        return
    end

    if mainIdentifier then
        tempPlayersInfo[tempSrc] = {
            identifiers = identifiers,
            discord = discordInfo
        }
        deferrals.done()
    else
        deferrals.done(locale("identifier_not_found", Config.characterIdentifier))
        Wait(0)
    end
end)

AddEventHandler("playerDropped", function()
    local src = source
    local char = NDCore.players[src]
    if char then char.unload() end
    PlayersInfo[src] = nil
end)

AddEventHandler("onResourceStop", function(name)
    if name ~= resourceName then return end
    for _, player in pairs(NDCore.players) do
        player.unload()
        Wait(10)
    end
end)

RegisterNetEvent("ND:playerEliminated", function(info)
    local src = source
    local player = NDCore.getPlayer(src)
    if not player then return end
    player.setMetadata({
        dead = true,
        deathInfo = info
    })
end)

RegisterNetEvent("ND:updateClothing", function(clothing)
    local src = source
    local player = NDCore.getPlayer(src)
    if not player or not clothing or type(clothing) ~= "table" then return end
    player.setMetadata("clothing", clothing)
end)

MySQL.ready(function()
    Wait(100)
    NDCore.loadSQL({
        "database/users.sql",
        "database/characters.sql",
        "database/vehicles.sql",
        "database/moneylogs.sql"
    }, resourceName)
end)

-- Hourly cron, purge soft-deleted characters older than 30 days.
lib.cron.new("0 * * * *", function()
    MySQL.update.await("DELETE FROM nd_characters WHERE deleted_at IS NOT NULL AND deleted_at < DATE_SUB(NOW(), INTERVAL 30 DAY)")
end)
