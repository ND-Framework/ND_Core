if not lib.table.contains(Config.compatibility, "backwards") then return end

exports("GetCoreObject", function()
    return NDCore
end)

NDCore.Functions = {}
NDCore.Functions.GetPlayer = NDCore.getPlayer
NDCore.Functions.GetPlayers = NDCore.getPlayers
NDCore.Functions.GetUserDiscordInfo = NDCore.getDiscordInfo
NDCore.Functions.SetActiveCharacter = NDCore.setActiveCharacter
NDCore.Functions.GetPlayerCharacters = NDCore.fetchAllCharacters
NDCore.Functions.GetPlayerByCharacterId = NDCore.fetchCharacter

function NDCore.Functions.GetPlayerIdentifierFromType(identifierType, src)
    return GetPlayerIdentifierByType(src, identifierType)
end

function NDCore.Functions.GetNearbyPedToPlayer(src)
    local pedCoords = GetEntityCoords(GetPlayerPed(src))
    for targetId, targetInfo in pairs(NDCore.players) do
        local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
        if #(pedCoords - targetCoords) < 2.0 and targetId ~= src then
            return targetId, targetInfo
        end
    end 
end

function NDCore.Functions.UpdateMoney(src)
    local player = NDCore.getPlayer(src)
    player.triggerEvent("ND:updateMoney", player.cash, player.bank)
end

function NDCore.Functions.TransferBank(amount, source, target, descriptionSender, descriptionReceiver)
    local amount = tonumber(amount)
    local src = tonumber(source)
    local target = tonumber(target)
    local player = NDCore.getPlayer(src)
    if not player then return end
    
    if src == target then
        return false, "Can't transfer money to same account"
    elseif GetPlayerPing(target) == 0 then
        return false, "Account not found"
    elseif amount <= 0 then
        return false, "Invalid amount"
    elseif player.bank < amount then
        return false, "Insufficient funds"
    end

    local targetPlayer = NDCore.getPlayer(target)
    if not targetPlayer then return end
    return player.deductMoney("bank", amount, descriptionSender or "Transfer") and targetPlayer.addMoney("bank", amount, descriptionReceiver or "Transfer")
end

function NDCore.Functions.GiveCash(amount, source, target)
    local amount = tonumber(amount)
    local src = tonumber(source)
    local target = tonumber(target)
    local player = NDCore.getPlayer(src)
    if not player then return end
    
    if src == target then
        return false, "Can't give to self"
    elseif GetPlayerPing(target) == 0 then
        return false, "Target not found"
    elseif amount <= 0 then
        return false, "Invalid amount"
    elseif player.bank < amount then
        return false, "Not enough money"
    end

    local targetPlayer = NDCore.getPlayer(target)
    if not targetPlayer then return endn end
    return player.deductMoney("cash", amount) and targetPlayer.addMoney("cash", amount)
end

function NDCore.Functions.GiveCashToNearbyPlayer(source, amount)
    local targetId = NDCore.Functions.GetNearbyPedToPlayer(source)
    if not targetId then return end
    return NDCore.Functions.GiveCash(amount, source, targetId)
end

function NDCore.Functions.WithdrawMoney(amount, source)
    local player = NDCore.getPlayer(source)
    return player and player.withdrawMoney(amount)
end

function NDCore.Functions.DepositMoney(amount, source)
    local player = NDCore.getPlayer(source)
    return player and player.depositMoney(amount)
end

function NDCore.Functions.DeductMoney(amount, source, account, description)
    local player = NDCore.getPlayer(source)
    return player and player.deductMoney(amount, account, description)
end

function NDCore.Functions.AddMoney(amount, source, account, description)
    local player = NDCore.getPlayer(source)
    return player and player.addMoney(amount, account, description)
end

function NDCore.Functions.CreateCharacter(src, firstName, lastName, dob, gender, cb)
    local player = NDCore.newCharacter(src, {
        firstname = firstName,
        lastname = lastName,
        dob = dob,
        gender = gender,
    })
    
    if cb then cb(player.id) end
    player.triggerEvent("ND:returnCharacters", NDCore.fetchAllCharacters(src))
    return player.id
end

function NDCore.Functions.UpdateCharacter(characterId, firstName, lastName, dob, gender)
    local player = NDCore.fetchCharacter(characterId)
    player.setData({
        source = src,
        firstname = firstName,
        lastname = lastName,
        dob = dob,
        gender = gender
    })
    return player
end

function NDCore.Functions.DeleteCharacter(characterId)
    local player = NDCore.fetchCharacter(characterId)
    return player and player.delete()
end

function NDCore.Functions.SetPlayerData(characterId, key, value)
    local player = NDCore.fetchCharacter(characterId)
    if not player then return end

    if player[key] then
        return player.setData(key, value)
    end
    return player.setMetadata(key, value)
end

function NDCore.Functions.CreatePlayerLicense(characterId, licenseType, expire)
    local player = NDCore.fetchCharacter(characterId)
    return self.createLicense(licenseType, expire)
end

-- find a players license by it's identifier.
function NDCore.Functions.FindLicenseByIdentifier(licences, identifier)
    for key, license in pairs(licences) do
        if license.identifier == identifier then
            return license, key
        end
    end
    return {}
end

-- Edit a license by the license identifier.
function NDCore.Functions.EditPlayerLicense(characterId, identifier, newData)
    local player = NDCore.fetchCharacter(characterId)
    if not player then return end
    player.updateLicense(identifier, newData)
end

-- Set the players job and job rank.
function NDCore.Functions.SetPlayerJob(characterId, job, rank)
    local player = NDCore.fetchCharacter(characterId)
    if not player then return end
    if player.source then
        local oldJob = player.getJob(job)
        TriggerEvent("ND:jobChanged", player.source, {name = job, rank = rank or 1}, {name = player.job, rank = oldJob and oldJob.rank or 1})
        TriggerClientEvent("ND:jobChanged", player.source, {name = job, rank = rank or 1}, {name = player.job, rank = oldJob and oldJob.rank or 1})
    end
    return player.setJob(job, rank)
end

-- Set a player to a group.
function NDCore.Functions.SetPlayerToGroup(characterId, group, rank)
    local player = NDCore.fetchCharacter(characterId)
    return player and player.addGroup(group, rank)
end

-- Remove a player from a group.
function NDCore.Functions.RemovePlayerFromGroup(characterId, group)
    local player = NDCore.fetchCharacter(characterId)
    return player and player.removeGroup(group)
end

-- Update the characters last location into the database.
function NDCore.Functions.UpdateLastLocation(characterId, location)
    local player = NDCore.fetchCharacter(characterId)
    return player and player.setMetadata("location", {
        x = location.x,
        y = location.y,
        x = location.z,
        w = location.h or location.heading or location.w or 0.0
    })
end

function NDCore.Functions.IsPlayerAdmin(src)
    local player = NDCore.getPlayer(src)
    if player.groups["admin"] then
        return true
    end
end

-- Getting all the characters the player has and returning them to the client.
RegisterNetEvent("ND:GetCharacters", function()
    local src = source
    TriggerClientEvent("ND:returnCharacters", src, NDCore.fetchAllCharacters(src))
end)

-- Creating a new character.
RegisterNetEvent("ND:newCharacter", function(newCharacter)
    local src = source
    NDCore.newCharacter(src, {
        firstname = newCharacter.firstName,
        lastname = newCharacter.lastName,
        dob = newCharacter.dob,
        gender = newCharacter.gender,
        cash = newCharacter.cash,
        bank = newCharacter.bank,
    })
end)

-- Update the character info when edited.
RegisterNetEvent("ND:editCharacter", function(newCharacter)
    local src = source
    local player = NDCore.fetchCharacter(newCharacter.id, src)
    return player and player.setData({
        source = src,
        firstname = newCharacter.firstName,
        lastname = newCharacter.lastName,
        dob = newCharacter.dob,
        gender = newCharacter.gender
    })
end)

-- Delete character from database.
RegisterNetEvent("ND:deleteCharacter", function(characterId)
    local src = source
    local player = NDCore.fetchCharacter(characterId, src)
    if not player or player.source ~= source then return end
    return player.delete()
end)

-- add a player to the table.
RegisterNetEvent("ND:setCharacterOnline", function(id)
    local src = source
    NDCore.setActiveCharacter(src, tonumber(id))
end)

-- Update the characters clothes.
RegisterNetEvent("ND:updateClothes", function(clothing)
    local src = source
    local player = NDCore.getPlayer(src)
    player.setMetadata("clothing", clothing)
end)
