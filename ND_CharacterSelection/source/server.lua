-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

NDCore = exports["ND_Core"]:GetCoreObject()

function validateDepartment(player, department)
    local departmentExists = config.departments[department]
    if departmentExists then
        local discordUserId = NDCore.Functions.GetPlayerIdentifierFromType("discord", player):gsub("discord:", "")
        local discordInfo = NDCore.Functions.GetUserDiscordInfo(discordUserId)

        -- validate that the player actually has the role that they selected on the client.
        for _, roleId in pairs(departmentExists) do
            if roleId == 0 or roleId == "0" or (discordInfo and discordInfo.roles[roleId]) then
                return true
            end
        end
    end
    return false
end

-- Creating a new character.
RegisterNetEvent("ND_CharacterSelection:newCharacter", function(newCharacter)
    local player = source

    -- validate that the person has permission to use the department.
    local departmentCheck = validateDepartment(player, newCharacter.job)
    if not departmentCheck then return end

    -- Create the character if the player has permission to the department.
    NDCore.Functions.CreateCharacter(player, newCharacter.firstName, newCharacter.lastName, newCharacter.dob, newCharacter.gender, newCharacter.twt, newCharacter.job, newCharacter.cash, newCharacter.bank)
end)

-- Update the character info when edited.
RegisterNetEvent("ND_CharacterSelection:editCharacter", function(newCharacter)
    local player = source

    -- check if player owns the character.
    local characters = NDCore.Functions.GetPlayerCharacters(player)
    if not characters[newCharacter.id] then return end
        
    -- validate that the person has permission to use the department.
    local departmentCheck = validateDepartment(player, newCharacter.job)
    if not departmentCheck then return end
    
    -- Updating the character information in the database.
    NDCore.Functions.UpdateCharacterData(newCharacter.id, newCharacter.firstName, newCharacter.lastName, newCharacter.dob, newCharacter.gender, newCharacter.twt, newCharacter.job)

    -- Updating characters on the client.
    TriggerClientEvent("ND:returnCharacters", player, NDCore.Functions.GetPlayerCharacters(player))
end)

RegisterNetEvent("ND_CharacterSelection:checkPerms", function()
    local player = source
    local discordUserId = NDCore.Functions.GetPlayerIdentifierFromType("discord", player):gsub("discord:", "")
    local allowedRoles = {}
    local discordInfo = NDCore.Functions.GetUserDiscordInfo(discordUserId)
    
    -- Check if the players discord roles will grant them permission to the department.
    for dept, roleTable in pairs(config.departments) do
        for _, roleId in pairs(roleTable) do
            if roleId == 0 or roleId == "0" or (discordInfo and discordInfo.roles[roleId]) then
                table.insert(allowedRoles, dept)
            end
        end
    end
    TriggerClientEvent("ND_CharacterSelection:permsChecked", player, allowedRoles)
end)

if config.departmentPaychecks then
    CreateThread(function()
        while true do
            Wait(config.paycheckInterval * 60000)
            for player, playerInfo in pairs(NDCore.Functions.GetPlayers()) do
                local salary = config.departmentSalaries[playerInfo.job]
                NDCore.Functions.AddMoney(salary, player, "bank")
                TriggerClientEvent("chat:addMessage", player, {
                    color = {0, 255, 0},
                    args = {"Salary", "Received $" .. salary .. "."}
                })
            end
        end
    end)
end
