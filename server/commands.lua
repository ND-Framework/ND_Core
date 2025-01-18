local moneyTypes = {"bank", "cash"}
local moneyActions = {
    remove = function(player, account, amount)
        player.deductMoney(account, amount, "Staff action")
        return ("Removed $%d (%s) to %s"):format(amount, account, player.name), ("removed $%d from %s"):format(amount, account)
    end,
    add = function(player, account, amount)
        player.addMoney(account, amount, "Staff action")
        return ("Added $%d (%s) to %s"):format(amount, account, player.name), ("added $%d to %s"):format(amount, account)
    end,
    set = function(player, account, amount)
        player.setData(account, amount, "Staff action")
        return ("Set %s's (%s) to $%d"):format(player.name, account, amount), ("set %s to $%d"):format(account, amount)
    end
}

lib.addCommand("setmoney", {
    help = "Admin command, set a players money.",
    restricted = "group.admin",
    params = {
        {
            name = "target",
            type = "playerId",
            help = "Target player's server id"
        },
        {
            name = "action",
            type = "string",
            help = "remove/add/set"
        },
        {
            name = "type",
            type = "string",
            help = "bank/cash"
        },
        {
            name = "amount",
            type = "number"
        }
    }
}, function(source, args, raw)
    local action = moneyActions[args.action]
    local moneyType = args.type:lower()
    if not action or not lib.table.contains(moneyTypes, moneyType) then return end

    local player = NDCore.getPlayer(args.target)
    if not player then return end
    local staffMessage, userMessage = action(player, moneyType, args.amount)

    player.notify({
        title = "Staff action",
        description = userMessage,
        type = "inform",
        duration = 10000
    })

    if not source then return end
    TriggerClientEvent("chat:addMessage", source, {
        color = {50, 100, 235},
        multiline = true,
        args = {"Staff action", staffMessage}
    })
end)

lib.addCommand("setjob", {
    help = "Admin command, set a players job.",
    restricted = "group.admin",
    params = {
        {
            name = "target",
            type = "playerId",
            help = "Target player's server id"
        },
        {
            name = "job",
            type = "string",
            help = "Job name"
        },
        {
            name = "rank",
            type = "number",
            optional = true
        }
    }
}, function(source, args, raw)
    local player = NDCore.getPlayer(args.target)
    if not player then return end
    
    local job = args.job:lower()
    local jobInfo = player.setJob(job, args.rank)
    if not player or not jobInfo then return end
    player.notify({
        title = "Staff action",
        description = ("Job updated to %s, rank %s"):format(jobInfo.label, jobInfo.rankName),
        type = "inform",
        duration = 10000
    })

    if not source then return end
    TriggerClientEvent("chat:addMessage", source, {
        color = {50, 100, 235},
        multiline = true,
        args = {"Staff action", "success"}
    })
end)

lib.addCommand("setgroup", {
    help = "Admin command, set a players group.",
    restricted = "group.admin",
    params = {
        {
            name = "target",
            type = "playerId",
            help = "Target player's server id"
        },
        {
            name = "action",
            type = "string",
            help = "remove/add"
        },
        {
            name = "group",
            type = "string",
            help = "group name"
        },
        {
            name = "rank",
            type = "number",
            optional = true
        }
    }
}, function(source, args, raw)
    local player = NDCore.getPlayer(args.target)
    if not player then return end

    if args.action == "add" then
        local groupInfo = player.addGroup(args.group, args.rank)
        if not groupInfo then return end
        player.notify({
            title = "Staff action",
            description = ("Added to group %s, rank %s."):format(groupInfo.label, groupInfo.rankName),
            type = "inform",
            duration = 10000
        })
    elseif args.action == "remove" then
        local groupInfo = player.removeGroup(args.group)
        if not groupInfo then return end
        player.notify({
            title = "Staff action",
            description = ("Removed from group %s."):format(groupInfo.label),
            type = "inform",
            duration = 10000
        })
    else
        return
    end

    if not source then return end
    TriggerClientEvent("chat:addMessage", source, {
        color = {50, 100, 235},
        multiline = true,
        args = {"Staff action", "success"}
    })
end)

lib.addCommand("skin", {
    help = "Admin command, show character clothing menu for player.",
    restricted = "group.admin",
    params = {
        {
            name = "target",
            type = "playerId",
            help = "Target player's server id"
        }
    }
}, function(source, args, raw)
    TriggerClientEvent("ND:clothingMenu", args.target)
end)

lib.addCommand("character", {
    help = "Admin command, show character selection menu for player.",
    restricted = "group.admin",
    params = {
        {
            name = "target",
            type = "playerId",
            help = "Target player's server id"
        }
    }
}, function(source, args, raw)
    TriggerClientEvent("ND:characterMenu", args.target)
end)

lib.addCommand("pay", {
    help = "give money to nearby player.",
    params = {
        {
            name = "target",
            type = "playerId",
            help = "Target player's server id"
        },
        {
            name = "amount",
            type = "number",
            help = "Amount of cash to give"
        }
    }
}, function(source, args, raw)
    if not source then return end

    local player = NDCore.getPlayer(source)
    local targetPlayer = NDCore.getPlayer(args.target)

    if not player or not targetPlayer then
        return player.notify({
            title = "Error",
            description = "No player found",
            type = "error"
        })
    end

    if player.cash < args.amount then
        return player.notify({
            title = "Error",
            description = "You don't have enough cash",
            type = "error"
        })
    end

    local playerCoords = GetEntityCoords(GetPlayerPed(player.source))
    local targetCoords = GetEntityCoords(GetPlayerPed(targetPlayer.source))
    if #(playerCoords-targetCoords) > 2.0 then
        return player.notify({
            title = "Error",
            description = "Player is not nearby",
            type = "error"
        })
    end

    local success = player.deductMoney("cash", args.amount) and targetPlayer.addMoney("cash", args.amount)
    if not success then
        return player.notify({
            title = "Couldn't give money",
            type = "error",
            duration = 5000
        })
    end
    
    targetPlayer.notify({
        title = "Money received",
        description = ("Received $%d in cash"):format(args.amount),
        type = "inform",
        duration = 5000
    })
    
    player.notify({
        title = "Money given",
        description = ("You gave $%d in cash"):format(args.amount),
        type = "inform",
        duration = 5000
    })
end)

lib.addCommand("unlock", {
    help = "Admin Command, force unlock a vehicle.",
    restricted = "group.admin",
}, function(source, args, raw)
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local veh = lib.getClosestVehicle(coords, 2.5, true)

    if not veh then return end

    local state = Entity(veh).state
    state.hotwired = true
    state.locked = false
end)

lib.addCommand("revive", {
    help = "Admin command, revive a player.",
    restricted = "group.admin",
    params = {
        {
            name = "target",
            type = "playerId",
            help = "Target player's server id"
        }
    }
}, function(source, args, raw)
    local player = NDCore.getPlayer(args.target)
    if not player then return end
    player.revive()
end)

lib.addCommand("dv", {
    help = "Admin command, delete vehicles within the range or the closest.",
    restricted = "group.admin",
    params = {
        {
            name = "range",
            type = "number",
            help = "Range to delete vehicles in",
            optional = true
        }
    }
}, function(source, args, raw)
    local ped = GetPlayerPed(source)
    local veh = GetVehiclePedIsIn(ped)
    if veh and veh ~= 0 and DoesEntityExist(veh) then
        DeleteEntity(veh)
        return TriggerClientEvent("chat:addMessage", source, {
            color = {50, 100, 235},
            multiline = true,
            args = {"Staff action", "deleted 1 vehicle"}
        })
    end
    
    local count = 0
    local coords = GetEntityCoords(ped)
    if args.range then
        for _, veh in ipairs(GetAllVehicles()) do
            local vehDist = #(GetEntityCoords(veh) - coords)
            if vehDist < args.range then
                DeleteEntity(veh)
                count += 1
            end
        end
        return TriggerClientEvent("chat:addMessage", source, {
            color = {50, 100, 235},
            multiline = true,
            args = {"Staff action", ("deleted %d vehicles"):format(count)}
        })
    end

    local closest, dist
    for _, veh in ipairs(GetAllVehicles()) do
        local vehDist = #(GetEntityCoords(veh) - coords)
        if vehDist < 5.0 and not closest or (dist and dist > vehDist) then
            closest = veh
            dist = vehDist
        end
    end

    if not closest then return "no vehicle found nearby" end
    DeleteEntity(closest)
    TriggerClientEvent("chat:addMessage", source, {
        color = {50, 100, 235},
        multiline = true,
        args = {"Staff action", "deleted 1 vehicle"}
    })
end)

lib.addCommand("goto", {
    help = "Admin command, teleport to a player.",
    restricted = "group.admin",
    params = {
        {
            name = "target",
            type = "playerId",
            help = "Target player's server id"
        }
    }
}, function(source, args, raw)
    if args.target == source then return end
    local target = GetPlayerPed(args.target)
    local coords = GetEntityCoords(target)
    local ped = GetPlayerPed(source)
    SetEntityCoords(ped, coords.x, coords.y, coords.z)
end)

lib.addCommand("bring", {
    help = "Admin command, teleport a player to you.",
    restricted = "group.admin",
    params = {
        {
            name = "target",
            type = "playerId",
            help = "Target player's server id"
        }
    }
}, function(source, args, raw)
    if args.target == source then return end
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local targetPed = GetPlayerPed(args.target)
    SetEntityCoords(targetPed, coords.x, coords.y, coords.z)
end)

lib.addCommand("freeze", {
    help = "Admin command, freeze a player.",
    restricted = "group.admin",
    params = {
        {
            name = "target",
            type = "playerId",
            help = "Target player's server id"
        }
    }
}, function(source, args, raw)
    local ped = GetPlayerPed(args.target)
    FreezeEntityPosition(ped, true)
end)

lib.addCommand("unfreeze", {
    help = "Admin command, unfreeze a player.",
    restricted = "group.admin",
    params = {
        {
            name = "target",
            type = "playerId",
            help = "Target player's server id"
        }
    }
}, function(source, args, raw)
    local ped = GetPlayerPed(args.target)
    FreezeEntityPosition(ped, false)
end)

lib.addCommand("vehicle", {
    help = "Admin command, spawn a vehicle.",
    restricted = "group.admin",
    params = {
        {
            name = "model",
            type = "string",
            help = "Name of the vehicle to spawn"
        }
    }
}, function(source, args, raw)
    local player =  NDCore.getPlayer(source)
    if not player then return end

    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local info = NDCore.createVehicle({
        owner = player.id,
        coords = coords,
        heading = heading,
        model = GetHashKey(args.model)
    })

    local veh = info.entity
    for i=1, 10 do
        if GetPedInVehicleSeat(veh, -1) ~= ped then
            SetPedIntoVehicle(ped, veh, -1)
        else
            break
        end
        Wait(100)
    end
end)

lib.addCommand("claim-veh", {
    help = "Admin command, add a copy of the vehicle you're inside to players garage.",
    restricted = "group.admin",
    params = {
        {
            name = "target",
            type = "playerId",
            help = "Target player's server id"
        }
    }
}, function(source, args, raw)
    local player = NDCore.getPlayer(source)
    if not player then return end

    local targetPlayer = NDCore.getPlayer(args.target)
    if not targetPlayer then
        return player.notify({
            title = "Player not found!",
            description = "Target player not found, make sure they select a charcter!",
            type = "error"
        })
    end


    local properties = lib.callback.await("ND_Vehicles:getPropsFromCurrentVeh", source)
    if not properties then
        return player.notify({
            title = "Vehicle data not found!",
            description = "The vehicle properties data was not found!",
            type = "error"
        })
    end
    
    NDCore.setVehicleOwned(targetPlayer.id, properties, true)

    player.notify({
        title = "Vehicle added!",
        description = ("The vehicle has now been added to %s's garage!"):format(targetPlayer.name),
        type = "success"
    })
end)
