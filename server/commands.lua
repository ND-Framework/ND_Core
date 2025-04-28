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
local validWeather = {
    "clear", "extrasunny", "clouds", "overcast", "rain", "clearing", "thunder", "smog", "foggy", "xmas", "snow", "snowlight", "blizzard", "halloween", "neutral"
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

    if not source or source == 0 then return end
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

    if not source or source == 0 then return end
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

    if not source or source == 0 then return end
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
    if not source or source == 0 then return end

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
    local coords = GetEntityCoords(ped)
    local count = 0
    local message = nil
    local veh = lib.getClosestVehicle(coords, 3.0)

    if args.range then
        local vehicles = lib.getNearbyVehicles(coords, args.range)
        count = #vehicles

        for i=1, count do
            local veh = vehicles[i]
            DeleteEntity(veh.vehicle)
        end
    elseif veh then
        DeleteEntity(veh)
        count = 1
    end

    if count == 0 then
        message = {"Staff action [dv]", "no vehicles found"}
    elseif count == 1 then
        message = {"Staff action [dv]", "deleted 1 vehicle"}
    else
        message = {"Staff action [dv]", ("deleted %d vehicles"):format(count)}
    end

    TriggerClientEvent("chat:addMessage", source, {
        color = {50, 100, 235},
        multiline = true,
        args = message
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

lib.addCommand("tpm", {
    help = "Admin command, teleport to marked location.",
    restricted = "group.admin"
}, function(source, args, raw)
    TriggerClientEvent("ND:teleportToMarker", source)
end)

lib.addCommand("tp", {
    help = "Admin command, teleport to coordinates.",
    restricted = "group.admin",
    params = {
        {
            name = "x",
            type = "number",
            help = "X coordinate"
        },
        {
            name = "y",
            type = "number",
            help = "Y coordinate"
        },
        {
            name = "z",
            type = "number",
            help = "Z coordinate"
        }
    }
}, function(source, args, raw)
    if not args or not args.x or not args.y or not args.z then
        local player = NDCore.getPlayer(source)
        return player.notify({
            title = "Error",
            description = "No coordinates provided! /tp <x> <y> <z>",
            type = "error"
        })
    end
    local ped = GetPlayerPed(source)
    SetEntityCoords(ped, tonumber(args.x) + 0.0, tonumber(args.y) + 0.0, tonumber(args.z) + 0.0)
end)

lib.addCommand("weather", {
    help = "Admin command, change the weather.",
    restricted = "group.admin",
    params = {
        {
            name = "weather",
            type = "string",
            help = ("Weather Type (%s)"):format(table.concat(validWeather, ", "))
        }
    }
}, function(source, args, raw)
    if not args or not args.weather then
        local player = NDCore.getPlayer(source)
        return player.notify({
            title = "Error",
            description = "No weather type provided! /weather <type>",
            type = "error"
        })
    end
    local weather = args.weather:lower()

    if not lib.table.contains(validWeather, weather) then
        local player = NDCore.getPlayer(source)
        return player.notify({
            title = "Invalid Weather",
            description = ("Format: %s"):format(table.concat(validWeather, ", ")),
            type = "error"
        })
    end

    TriggerClientEvent("ND:changeWeather", -1, weather)
end)

lib.addCommand("time", {
    help = "Admin command, change the time.",
    restricted = "group.admin",
    params = {
        {
            name = "hours",
            type = "number",
            help = "Hours"
        },
        {
            name = "minutes",
            type = "number",
            help = "Minutes"
        },
        {
            name = "seconds",
            type = "number",
            help = "Seconds",
            optional = true
        }
    }
}, function(source, args, raw)
    if not args or not args.hours or not args.minutes then
        local player = NDCore.getPlayer(source)
        return player.notify({
            title = "Error",
            description = "No time provided! /time <hour> <minute>",
            type = "error"
        })
    else
        local hours = tonumber(args.hours)
        local minutes = tonumber(args.minutes)
        local seconds = args.seconds and tonumber(args.seconds) or 0

        if not hours or hours < 0 or hours > 23 or
            not minutes or minutes < 0 or minutes > 59 or
            seconds < 0 or seconds > 59 then
            local player = NDCore.getPlayer(source)
            return player.notify({
                title = "Invalid Time",
                description = "Format: /time <hour 0-23> <minute 0-59>",
                type = "error"
            })
        end

        TriggerClientEvent("ND:changeTime", -1, hours, minutes, seconds)
    end
end)

lib.addCommand("coords", {
    help = "Admin command, get your current coordinates.",
    restricted = "group.admin"
}, function(source, args, raw)
    local ped = GetPlayerPed(source)
    local coords = GetEntityCoords(ped)
    local heading = GetEntityHeading(ped)
    local message = ("Your current coordinates are: x: %.2f, y: %.2f, z: %.2f, w: %.2f"):format(coords.x, coords.y, coords.z, heading)

    TriggerClientEvent("chat:addMessage", source, {
        color = {65, 105, 225},
        multiline = true,
        args = {"Coordinates", message}
    })
end)