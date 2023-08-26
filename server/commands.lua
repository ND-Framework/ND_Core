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
    -- restricted = "group.admin",
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
            type = "number",
            help = "bank/cash"
        }
    },
}, function(source, args, raw)
    local action = moneyActions[args.action]
    local moneyType = args.type:lower()
    if not action or not lib.table.contains(moneyTypes, moneyType) then return end

    local player = NDCore.getPlayer(args.target)
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
