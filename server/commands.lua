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
    help = "Admin command, manage player money.",
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
    help = "Admin command, set player into character clothing menu.",
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
    help = "Admin command, set player into character selection menu.",
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
            name = "amount",
            type = "number"
        }
    }
}, function(source, args, raw)
    if not source then return end
    local targetPlayer
    local pedCoords = GetEntityCoords(GetPlayerPed(source))
    for targetId, targetInfo in pairs(NDCore.players) do
        local targetCoords = GetEntityCoords(GetPlayerPed(targetId))
        if #(pedCoords-targetCoords) < 2.0 and targetId ~= source then
            targetPlayer = targetInfo
            break
        end
    end

    local player = NDCore.getPlayer(source)
    if not player then return end
    local success = player.deductMoney("cash", args.amount)

    if not success then
        return player.notify({
            title = "Couldn't give money",
            type = "error",
            duration = 5000
        })
    end
    
    if not targetPlayer or not targetPlayer.addMoney("cash", args.amount) then return end
    targetPlayer.notify({
        title = "Money received",
        description = ("Received $%d in cash"):format(args.amount),
        type = "inform",
        duration = 10000
    })
    
    player.notify({
        title = "Money given",
        description = ("You gave someone $%d in cash"):format(args.amount),
        type = "inform",
        duration = 10000
    })
end)

lib.addCommand("unlock", {
    help = "Admin force unlock vehicles",
    restricted = "group.admin",
}, function(source, args, raw)
    local ped = GetPlayerPed(source)
    local playerVeh = GetVehiclePedIsIn(ped)
    local coords = GetEntityCoords(ped)
    local vehicles = GetAllVehicles()
    local maxDistance = 2.0
	local closestVehicle

    if not playerVeh or playerVeh == 0 or not DoesEntityExist(playerVeh) then        
        for i=1, #vehicles do
            local vehicle = vehicles[i]
            local vehicleCoords = GetEntityCoords(vehicle)
            local distance = #(coords-vehicleCoords)
    
            if distance < maxDistance then
                maxDistance = distance
                closestVehicle = vehicle
            end
        end
        if not closestVehicle or not DoesEntityExist(closestVehicle) then return end
        local state = Entity(closestVehicle).state
        state.locked = false
    else
        local state = Entity(playerVeh).state
        state.hotwired = true
    end
end)

lib.addCommand("revive", {
    help = "Admin command, revive player.",
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
    help = "Admin command, delete vehicles within the range.",
    restricted = "group.admin",
    params = {
        {
            name = "range",
            type = "number",
            help = "The range to select vehicles for deleteion from",
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
    help = "Admin command, unfreeze a player.",
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
