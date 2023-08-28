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

