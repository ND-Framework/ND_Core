local function removeCharacterFunctions(character)
    local newData = {}
    for k, v in pairs(character) do
        if type(v) ~= "function" then
            newData[k] = v
        end
    end
    return newData
end

local function createCharacterTable(info)
    local playerInfo = PlayersInfo[info.source] or {}

    local self = {
        id = info.id,
        source = info.source,
        identifier = info.identifier,
        identifiers = playerInfo.identifiers or {},
        discord = playerInfo.discord or {},
        name = info.name,
        firstname = info.firstname,
        lastname = info.lastname,
        fullname = ("%s %s"):format(info.firstname, info.lastname),
        dob = info.dob,
        gender = info.gender,
        cash = info.cash,
        bank = info.bank,
        groups = info.groups,
        metadata = info.metadata,
        inventory = info.inventory
    }
    
    ---@param account string
    ---@param amount number
    ---@param reason string|nil
    ---@return boolean
    function self.deductMoney(account, amount, reason)
        local amount = tonumber(amount)
        if not amount or amount <= 0 or account ~= "bank" and account ~= "cash" then return end
        self[account] -= amount
        if NDCore.players[self.source] then
            self.triggerEvent("ND:updateMoney", self.cash, self.bank)
            TriggerEvent("ND:moneyChange", self.source, account, amount, "remove", reason)
        end
        return true
    end
    
    ---@param account string
    ---@param amount number
    ---@param reason string|nil
    ---@return boolean
    function self.addMoney(account, amount, reason)
        local amount = tonumber(amount)
        if not amount or amount <= 0 or account ~= "bank" and account ~= "cash" then return end
        self[account] += amount
        if NDCore.players[self.source] then
            self.triggerEvent("ND:updateMoney", self.cash, self.bank)
            TriggerEvent("ND:moneyChange", self.source, account, amount, "add", reason)
        end
        return true
    end

    ---@param amount number
    ---@return boolean
    function self.depositMoney(amount)
        local amount = tonumber(amount)
        if not amount or self.cash < amount or amount <= 0 then return end
        return self.deductMoney("cash", amount, "Deposit") and self.addMoney("bank", amount, "Deposit")
    end
    
    ---@param amount number
    ---@return boolean
    function self.withdrawMoney(amount)
        local amount = tonumber(amount)
        if not amount or self.bank < amount or amount <= 0 then return end
        return self.deductMoney("bank", amount, "Withdraw") and self.addMoney("cash", amount, "Withdraw")
    end

    ---@param data string
    ---@return any
    function self.getData(data)
        return self[data]
    end

    ---@param metadata string|table
    ---@return any
    function self.getMetadata(metadata)
        if type(metadata) ~= "table" then
            return self.metadata[metadata]
        end
        local returnData = {}
        for i=1, #metadata do
            local data = metadata[i]
            returnData[data] = self.metadata[data]
        end
        return returnData
    end

    ---@param key string|table
    ---@param value any
    function self.setData(key, value, reason)
        if type(key) == "table" then
            for k, v in pairs(key) do
                self[k] = v
                if k == "cash" or k == "bank" then
                    TriggerEvent("ND:moneyChange", self.source, k, v, "set", reason)
                end
            end
        else
            self[key] = value
            if key == "cash" or key == "bank" then
                TriggerEvent("ND:moneyChange", self.source, key, value, "set", reason)
            end
        end
        self.triggerEvent("ND:updateCharacter", removeCharacterFunctions(self))
    end
    
    ---@param key string|table
    ---@param value any
    ---@return table
    function self.setMetadata(key, value)
        if type(key) == "table" then
            for k, v in pairs(key) do
                self.metadata[k] = v
            end
        else
            self.metadata[key] = value
        end
        self.triggerEvent("ND:updateCharacter", removeCharacterFunctions(self))
        return self.metadata
    end

    -- Completely delete character
    function self.delete()
        local result = MySQL.query.await("DELETE FROM nd_characters WHERE charid = ?", {self.id})
        if result and NDCore.players[self.source] then
            NDCore.players[self.source] = nil
        end
        return result
    end
    
    -- Unload and save character
    function self.unload()
        if not NDCore.players[self.source] then return end
        for name, _ in pairs(self.groups) do
            lib.removePrincipal(self.source, ("group.%s"):format(name))
        end
        local ped = GetPlayerPed(self.source)
        if ped then
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            self.setMetadata("location", {
                x = coords.x,
                y = coords.y,
                z = coords.z,
                w = heading
            })
        end
        self.triggerEvent("ND:characterUnloaded")
        TriggerEvent("ND:characterUnloaded", self.source, self)
        local saved = self.save()
        NDCore.players[self.source] = nil
        return saved
    end
    
    -- Save character information to database
    function self.save()
        local affectedRows = MySQL.update.await("UPDATE nd_characters SET name = ?, firstname = ?, lastname = ?, dob = ?, gender = ?, cash = ?, bank = ?, `groups` = ?, metadata = ? WHERE charid = ?", {
            self.name,
            self.firstname,
            self.lastname,
            self.dob,
            self.gender,
            self.cash,
            self.bank,
            json.encode(self.groups),
            json.encode(self.metadata),
            self.id
        })
        return affectedRows > 0
    end
    
    ---Create a license/permit for the character
    ---@param licenseType string
    ---@param expire number
    function self.createLicense(licenseType, expire)
        local expireIn = tonumber(expire) or 2592000
        local time = os.time()
        local licenses = self.metadata.licenses
        local identifier = {}
    
        for i=1, 16 do
            identifier[i] = math.random(0, 1) == 1 and string.char(math.random(65, 90)) or math.random(0, 9)
        end
    
        local license = {
            type = licenseType,
            status = "valid",
            issued = time,
            expires = time+expireIn,
            identifier = table.concat(identifier)
        }
    
        if licenses then
            self.metadata.licenses[#licenses+1] = license
        else
            self.metadata.licenses = {license}
        end
        self.triggerEvent("ND:updateCharacter", removeCharacterFunctions(self))
    end

    function self.getLicense(identifier)
        local licenses = self.metadata.licenses or {}
        for i=1, #licenses do
            local data = licenses[i]
            if data.identifier == identifier then
                return data, i
            end
        end
    end

    function self.updateLicense(identifier, newData)
        local data, i = self.getLicense(identifier)
        if not data then return end
        for k, v in pairs(newData) do
            data[k] = v
        end
        self.save()
    end
    
    ---@param coords vector3|vector4
    ---@return boolean
    function self.setCoords(coords)
        if not self.source or not coords then return end
        local ped = GetPlayerPed(self.source)
        if not DoesEntityExist(ped) then return end
        SetEntityCoords(ped, coords.x, coords.y, coords.z)
        if coords.w then
            SetEntityHeading(ped, coords.w)
        end
        return true
    end

    ---@param eventName string
    ---@param ... any
    ---@return boolean
    function self.triggerEvent(eventName, ...)
        if not self.source then return end
        TriggerClientEvent(eventName, self.source, ...)
        return true
    end
    
    function self.notify(...)
        if not self.source then return end
        if GetResourceState("ModernHUD") == "started" then
            TriggerClientEvent("ModernHUD:notify", self.source, ...)
        elseif GetResourceState("ox_lib") == "started" then
            TriggerClientEvent("ox_lib:notify", self.source, ...)
        end
        return true
    end

    function self.revive()
        self.triggerEvent("ND:revivePlayer")
        self.setMetadata({
            dead = false,
            deathInfo = false,
        })
    end

    ---@param reason string
    function self.drop(reason)
        if not self.source then return end
        DropPlayer(self.source, reason)
    end

    -- Set the character as the players active character/currently playing character
    function self.active()
        local char = NDCore.players[self.source]
        if char and char.id == self.id then return end
        if char then char.unload() end
        for identifierType, identifier in pairs(self.identifiers) do
            if lib.table.contains(Config.admins, ("%s:%s"):format(identifierType, identifier)) then
                self.addGroup("admin")
            end
        end

        local roles = self.discord.roles
        if roles then            
            for i=1, #Config.adminDiscordRoles do
                local role = Config.adminDiscordRoles[i]
                if lib.table.contains(roles, role) then
                    self.addGroup("admin")
                end
            end
        end

        for name, _ in pairs(self.groups) do
            lib.addPrincipal(self.source, ("group.%s"):format(name))
        end
        NDCore.players[self.source] = self
        TriggerEvent("ND:characterLoaded", self)
        self.triggerEvent("ND:characterLoaded", removeCharacterFunctions(self))
    end

    ---@param name string
    ---@param rank number
    ---@param isJob boolean
    ---@return boolean
    function self.addGroup(name, rank, isJob)
        local groupRank = tonumber(rank) or 1
        local groupInfo = Config.groups?[name]
        local bossRank = groupInfo and groupInfo.minimumBossRank

        -- if not groupInfo then return end
        if isJob then
            for _, group in pairs(self.groups) do
                group.isJob = nil
            end
        end

        self.groups[name] = {
            label = groupInfo and groupInfo.label or name,
            rankName = groupInfo and groupInfo.ranks[groupRank] or groupRank,
            rank = groupRank,
            isJob = isJob,
            isBoss = bossRank and rank >= bossRank
        }
        
        self.triggerEvent("ND:updateCharacter", removeCharacterFunctions(self))
        lib.addPrincipal(self.source, ("group.%s"):format(name))
        return self.groups[name]
    end

    ---@param name string
    ---@return table
    function self.getGroup(name)
        return self.groups[name]
    end

    ---@param name string
    function self.removeGroup(name)
        local group = self.groups[name]
        if not group then return end
        self.groups[name] = nil
        self.triggerEvent("ND:updateCharacter", removeCharacterFunctions(self))
        lib.removePrincipal(self.source, ("group.%s"):format(name))
        return group
    end

    ---@param name string
    ---@param rank number
    ---@return boolean
    function self.setJob(name, rank)
        self.removeGroup(self.job)
        local job = self.addGroup(name, rank, true)
        local jobName, jobInfo = self.getJob()
        if jobInfo then
            self.job = jobName
            self.jobInfo = jobInfo
        end
        return job
    end

    ---@param job string
    ---@return boolean
    function self.getJob()
        for name, group in pairs(self.groups) do
            if group.isJob then
                return name, group
            end
        end
    end

    local jobName, jobInfo = self.getJob()
    if jobInfo then
        self.job = jobName
        self.jobInfo = jobInfo
    end
    
    return self
end

---@param src number
---@param info table
---@return table
function NDCore.newCharacter(src, info)
    local identifier = GetPlayerIdentifierByType(src, Config.characterIdentifier)
    if not identifier then return end

    local charInfo = {
        source = src,
        identifier = identifier,
        name = GetPlayerName(src) or "",
        firstname = info.firstname or "",
        lastname = info.lastname or "",
        dob = info.dob or "",
        gender = info.gender or "",
        cash = info.cash or 0,
        bank = info.bank or 0,
        groups = info.groups or {},
        metadata = info.metadata or {},
        inventory = info.inventory or {},
    }

    charInfo.id = MySQL.insert.await("INSERT INTO nd_characters (identifier, name, firstname, lastname, dob, gender, cash, bank, `groups`, metadata) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", {
        identifier,
        charInfo.name,
        charInfo.firstname,
        charInfo.lastname,
        charInfo.dob,
        charInfo.gender,
        charInfo.cash,
        charInfo.bank,
        json.encode(charInfo.groups),
        json.encode(charInfo.metadata)
    })

    return createCharacterTable(charInfo)
end

---@param id number
---@return table
function NDCore.fetchCharacter(id, src)
    local result
    if src then
        result = MySQL.query.await("SELECT * FROM nd_characters WHERE charid = ? and identifier = ?", {id, GetPlayerIdentifierByType(src, Config.characterIdentifier)})
    else
        result = MySQL.query.await("SELECT * FROM nd_characters WHERE charid = ?", {id})
    end

    if not result then return end
    local info = result[1]
    return createCharacterTable({
        source = src,
        id = info.charid,
        identifier = info.identifier,
        name = info.name,
        firstname = info.firstname,
        lastname = info.lastname,
        dob = info.dob,
        gender = info.gender,
        cash = info.cash,
        bank = info.bank,
        groups = json.decode(info.groups),
        metadata = json.decode(info.metadata),
        inventory = json.decode(info.inventory)
    })
end

---@param src number
---@return table
function NDCore.fetchAllCharacters(src)
    local characters = {}
    local result = MySQL.query.await("SELECT * FROM nd_characters WHERE identifier = ?", {GetPlayerIdentifierByType(src, Config.characterIdentifier)})

    for i=1, #result do
        local info = result[i]
        characters[info.charid] = createCharacterTable({
            source = src,
            id = info.charid,
            identifier = info.identifier,
            name = info.name,
            firstname = info.firstname,
            lastname = info.lastname,
            dob = info.dob,
            gender = info.gender,
            cash = info.cash,
            bank = info.bank,
            groups = json.decode(info.groups),
            metadata = json.decode(info.metadata),
            inventory = json.decode(info.inventory),
        })
    end
    return characters
end

---@param src number
---@param id number
---@return table
function NDCore.setActiveCharacter(src, id)
    local char = NDCore.players[src]
    if not src or char and char.id == id then return end

    local character = NDCore.fetchCharacter(id, src)
    if not character then return end
    
    character.name = GetPlayerName(src)
    character.active()
    return character
end
