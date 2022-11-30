NDCore.Functions.AddCommand("setmoney", "Admin command, manage player money.", function(source, args, rawCommand)
    if not NDCore.Functions.IsPlayerAdmin(source) then return end

    local target = tonumber(args[1])
    local action = args[2]
    local moneyType = args[3]:lower()
    local amount = tonumber(args[4])
    
    if not target or GetPlayerPing(target) == 0 then return end
    if action ~= "remove" and action ~= "add" and action ~= "set" then return end
    if moneyType ~= "bank" and moneyType ~= "cash" then return end

    if action == "remove" then
        if not amount or amount < 1 then return end
        NDCore.Functions.DeductMoney(amount, target, moneyType)
    elseif action == "add" then
        if not amount or amount < 1 then return end
        NDCore.Functions.AddMoney(amount, target, moneyType)
    elseif action == "set" then
        local character = NDCore.Functions.GetPlayer(target)
        NDCore.Functions.SetPlayerData(character.id, moneyType, amount)
    end
end, true, {
    { name="player", help="Player server id" },
    { name="action", help="remove/add/set" },
    { name="type", help="bank/cash" },
    { name="amount" }
})

NDCore.Functions.AddCommand("setjob", "Admin command, set player job.", function(source, args, rawCommand)
    if not NDCore.Functions.IsPlayerAdmin(source) then return end
    
    local target = tonumber(args[1])
    if not target or GetPlayerPing(target) == 0 then return end

    local character = NDCore.Functions.GetPlayer(target)
    NDCore.Functions.SetPlayerJob(character.id, args[2], args[3])
end, true, {
    { name="player", help="Player server id" },
    { name="job name" },
    { name="rank", help="This should be a number, default value is 1." }
})

NDCore.Functions.AddCommand("setgroup", "Admin command, set player group.", function(source, args, rawCommand)
    if not NDCore.Functions.IsPlayerAdmin(source) then return end
    
    local target = tonumber(args[1])
    if not target or GetPlayerPing(target) == 0 then return end

    local character = NDCore.Functions.GetPlayer(target)
    if args[2] == "remove" then
        NDCore.Functions.RemovePlayerFromGroup(character.id, args[3])
    elseif args[2] == "add" then
        NDCore.Functions.SetPlayerToGroup(character.id, args[3], args[4])
    end
end, false, {
    { name="player", help="Player server id" },
    { name="action", help="remove/add"},
    { name="group", help="Group name, make sure it's correct or it won't work."},
    { name="rank", help="This should be a number, default value is 1 (not required if removing)." }
})

NDCore.Functions.AddCommand("pay", "give cash to a nearby player", function(source, args, rawCommand)
    local amount = args[1]
    if not amount or amount == 0 then return end
    NDCore.Functions.GiveCashToNearbyPlayer(source, amount)
end, true, {
    { name="Amount" },
})