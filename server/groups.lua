-- Cache of all groups loaded from DB: Config.groups[name] = { label, isJob, ranks = { [weight] = { id, label, weight, isBoss } } }

local function loadGroupsFromDB()
    local groups = {}
    local rows = MySQL.query.await("SELECT * FROM nd_groups")
    if not rows then return groups end

    for _, row in ipairs(rows) do
        groups[row.name] = {
            label = row.label,
            isJob = row.isJob == 1,
            ranks = {}
        }
    end

    local ranks = MySQL.query.await("SELECT * FROM nd_group_ranks ORDER BY weight ASC")
    if ranks then
        for _, rank in ipairs(ranks) do
            local g = groups[rank.group_name]
            if g then
                g.ranks[rank.weight] = {
                    id = rank.id,
                    label = rank.label,
                    weight = rank.weight,
                    isBoss = rank.isBoss == 1
                }
            end
        end
    end

    return groups
end

--- Check if a group exists in the database/cache.
---@param name string
---@return boolean
function NDCore.doesGroupExist(name)
    return Config.groups[name] ~= nil
end

--- Get group data from cache.
---@param name string
---@return table|nil
function NDCore.getGroupData(name)
    return Config.groups[name]
end

--- Create a new group in the database and cache.
---@param name string Unique key
---@param label string Display name
---@param isJob boolean
---@param ranks table Array of { label = string, weight = number, isBoss = boolean }
---@return boolean success
---@return string|nil error
function NDCore.createNewGroup(name, label, isJob, ranks)
    if not name or name == "" then return false, "name is required" end
    if Config.groups[name] then return false, "group already exists" end

    MySQL.insert.await("INSERT INTO nd_groups (`name`, `label`, `isJob`) VALUES (?, ?, ?)", {
        name, label or name, isJob and 1 or 0
    })

    Config.groups[name] = {
        label = label or name,
        isJob = isJob or false,
        ranks = {}
    }

    if ranks and #ranks > 0 then
        for _, rank in ipairs(ranks) do
            local id = MySQL.insert.await("INSERT INTO nd_group_ranks (`group_name`, `label`, `weight`, `isBoss`) VALUES (?, ?, ?, ?)", {
                name, rank.label, rank.weight, rank.isBoss and 1 or 0
            })
            Config.groups[name].ranks[rank.weight] = {
                id = id,
                label = rank.label,
                weight = rank.weight,
                isBoss = rank.isBoss or false
            }
        end
    end

    NDCore.syncGroupsToClients()
    return true
end

--- Edit an existing group in the database and cache.
---@param name string Group key
---@param data table { label?, isJob?, ranks? }
---@return boolean success
---@return string|nil error
function NDCore.editGroupData(name, data)
    if not name or not Config.groups[name] then return false, "group does not exist" end

    if data.label ~= nil or data.isJob ~= nil then
        local label = data.label or Config.groups[name].label
        local isJob = data.isJob ~= nil and data.isJob or Config.groups[name].isJob
        MySQL.update.await("UPDATE nd_groups SET `label` = ?, `isJob` = ? WHERE `name` = ?", {
            label, isJob and 1 or 0, name
        })
        Config.groups[name].label = label
        Config.groups[name].isJob = isJob
    end

    if data.ranks then
        -- Delete all old ranks and replace with new set
        MySQL.update.await("DELETE FROM nd_group_ranks WHERE `group_name` = ?", { name })
        Config.groups[name].ranks = {}

        for _, rank in ipairs(data.ranks) do
            local id = MySQL.insert.await("INSERT INTO nd_group_ranks (`group_name`, `label`, `weight`, `isBoss`) VALUES (?, ?, ?, ?)", {
                name, rank.label, rank.weight, rank.isBoss and 1 or 0
            })
            Config.groups[name].ranks[rank.weight] = {
                id = id,
                label = rank.label,
                weight = rank.weight,
                isBoss = rank.isBoss or false
            }
        end
    end

    NDCore.syncGroupsToClients()
    return true
end

--- Delete a group from the database and cache.
---@param name string
---@return boolean
function NDCore.deleteGroup(name)
    if not name or not Config.groups[name] then return false end
    MySQL.update.await("DELETE FROM nd_groups WHERE `name` = ?", { name })
    Config.groups[name] = nil
    NDCore.syncGroupsToClients()
    return true
end

--- Get all groups formatted for UI or external use.
---@return table
function NDCore.getAllGroups()
    local result = {}
    for name, group in pairs(Config.groups) do
        local ranks = {}
        for weight, rank in pairs(group.ranks) do
            ranks[#ranks+1] = {
                id = rank.id,
                label = rank.label,
                weight = rank.weight,
                isBoss = rank.isBoss
            }
        end
        table.sort(ranks, function(a, b) return a.weight < b.weight end)
        result[#result+1] = {
            name = name,
            label = group.label,
            isJob = group.isJob,
            ranks = ranks
        }
    end
    table.sort(result, function(a, b) return a.name < b.name end)
    return result
end

--- Sync groups convar to all clients after changes.
function NDCore.syncGroupsToClients()
    -- Build a simplified map for the convar (backwards compatible format)
    local simplified = {}
    for name, group in pairs(Config.groups) do
        local rankLabels = {}
        local sortedRanks = {}
        for weight, rank in pairs(group.ranks) do
            sortedRanks[#sortedRanks+1] = rank
        end
        table.sort(sortedRanks, function(a, b) return a.weight < b.weight end)
        for _, rank in ipairs(sortedRanks) do
            rankLabels[#rankLabels+1] = rank.label
        end
        simplified[name] = {
            label = group.label,
            isJob = group.isJob,
            ranks = rankLabels
        }
    end
    SetConvarReplicated("core:groups", json.encode(simplified))
end

--- Load groups from DB into Config.groups. Called at startup.
function NDCore.loadGroups()
    Config.groups = loadGroupsFromDB()
    NDCore.syncGroupsToClients()
end

--- Seed the database from the old JSON config if tables are empty.
function NDCore.seedGroupsFromJson()
    local count = MySQL.scalar.await("SELECT COUNT(*) FROM nd_groups")
    if count and count > 0 then return false end

    local groupsJson = lib.loadJson("_config.groups") or json.decode(GetConvar("core:groups", "[]"))
    if not groupsJson then return false end

    for name, group in pairs(groupsJson) do
        MySQL.insert.await("INSERT INTO nd_groups (`name`, `label`, `isJob`) VALUES (?, ?, ?)", {
            name, group.label or name, (group.isJob and 1 or 0)
        })

        if group.ranks then
            for i, rankLabel in ipairs(group.ranks) do
                local isBoss = false
                if group.minimumBossRank and i >= group.minimumBossRank then
                    isBoss = true
                end
                MySQL.insert.await("INSERT INTO nd_group_ranks (`group_name`, `label`, `weight`, `isBoss`) VALUES (?, ?, ?, ?)", {
                    name, rankLabel, i, isBoss and 1 or 0
                })
            end
        end
    end

    return true
end

for name, func in pairs(NDCore) do
    if type(func) == "function" then
        exports(name, func)
    end
end
