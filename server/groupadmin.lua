lib.addCommand("groupadmin", {
    help = "Open the group management admin panel.",
    restricted = "group.admin"
}, function(source, args, raw)
    if not source or source == 0 then return end
    local groups = NDCore.getAllGroups()
    TriggerClientEvent("ND:openGroupAdmin", source, groups)
end)

lib.callback.register("ND_Core:groups:create", function(source, data)
    local player = NDCore.getPlayer(source)
    if not player or not player.groups["admin"] then return { success = false } end

    if not data or not data.name or not data.label then
        return { success = false }
    end

    local success, err = NDCore.createNewGroup(data.name, data.label, data.isJob, data.ranks)
    if not success then
        return { success = false, error = err }
    end

    return { success = true, groups = NDCore.getAllGroups() }
end)

lib.callback.register("ND_Core:groups:edit", function(source, data)
    local player = NDCore.getPlayer(source)
    if not player or not player.groups["admin"] then return { success = false } end

    if not data or not data.name then
        return { success = false }
    end

    local success, err = NDCore.editGroupData(data.name, {
        label = data.label,
        isJob = data.isJob,
        ranks = data.ranks
    })
    if not success then
        return { success = false, error = err }
    end

    return { success = true, groups = NDCore.getAllGroups() }
end)

lib.callback.register("ND_Core:groups:delete", function(source, data)
    local player = NDCore.getPlayer(source)
    if not player or not player.groups["admin"] then return { success = false } end

    if not data or not data.name then
        return { success = false }
    end

    local success = NDCore.deleteGroup(data.name)
    if not success then
        return { success = false }
    end

    return { success = true, groups = NDCore.getAllGroups() }
end)
