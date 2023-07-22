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
        if not amount or account ~= "bank" and account ~= "cash" then return end
        self[account] -= amount
        if ActivePlayers[self.source] then
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
        if not amount or account ~= "bank" and account ~= "cash" then return end
        self[account] += amount
        if ActivePlayers[self.source] then
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

    ---@param key any
    ---@param value any
    function self.setData(key, value)
        self[key] = value
        self.triggerEvent("ND:updateCharacter", self)
    end
    
    ---@param key any
    ---@param value any
    ---@return table
    function self.setMetadata(key, value)
        self.metadata[key] = value
        self.triggerEvent("ND:updateCharacter", self)
        return self.metadata
    end

    -- Completely delete character
    function self.delete()
        local result = MySQL.query.await("DELETE FROM nd_characters WHERE charid = ?", {self.id})
        if result and ActivePlayers[self.source] then
            ActivePlayers[self.source] = nil
        end
        return result
    end
    
    -- Unload and save character
    function self.unload()
        if not ActivePlayers[self.source] then return end
        local ped = GetPlayerPed(self.source)
        if ped then
            local coords = GetEntityCoords(ped)
            local heading = GetEntityHeading(ped)
            self.setMetadata("location", {
                x = coords.x,
                y = coords.y,
                x = coords.z,
                w = heading
            })
        end
        TriggerEvent("ND:characterUnloaded", self.source, self)
        self.save()
        ActivePlayers[self.source] = nil
    end
    
    -- Save character information to database
    function self.save()
        MySQL.update.await("UPDATE nd_characters SET name = ?, firstname = ?, lastname = ?, dob = ?, gender = ?, cash = ?, bank = ?, groups = ?, metadata = ?, inventory = ? WHERE charid = ?", {
            self.name,
            self.firstname,
            self.lastname,
            self.dob,
            self.gender,
            self.cash,
            self.bank,
            json.encode(self.groups),
            json.encode(self.metadata),
            json.encode(self.inventory),
            self.id,
        })
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
        self.triggerEvent("ND:updateCharacter", self)
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
        TriggerClientEvent("ox_lib:notify", self.source, ...)
        return true
    end

    ---@param reason string
    function self.drop(reason)
        if not self.source then return end
        DropPlayer(self.source, reason)
    end

    -- Set the character as the players active character/currently playing character
    function self.active()
        local char = ActivePlayers[self.source]
        if char and char.id == self.id then return true end
        if char then char.unload() end
        ActivePlayers[self.source] = self
        TriggerEvent("ND:characterLoaded", self)
        self.triggerEvent("ND:characterLoaded", self)
        return true
    end

    ---@param name string
    ---@param rank number
    ---@return boolean
    function self.addGroup(name, rank, isJob)
        local groupInfo = Config.groups[name]
        if not groupInfo then return end
        if isJob then
            for _, group in pairs(self.groups) do
                group.isJob = nil
            end
        end
        self.groups[name] = {
            label = groupInfo.label,
            rankName = groupInfo.ranks[rank] or rank,
            rank = rank,
            isJob = isJob
        }
        self.triggerEvent("ND:updateCharacter", self)
        return true
    end

    ---@param name string
    ---@return table
    function self.getGroup(name)
        return self.groups[name]
    end

    ---@param name string
    function self.removeGroup(name)
        self.groups[name] = nil
        self.triggerEvent("ND:updateCharacter", self)
    end

    ---@param name string
    ---@param rank number
    ---@return boolean
    function self.setJob(name, rank)
        return self.addGroup(name, rank, true)
    end

    ---@param job string
    ---@return boolean
    function self.getJob(job)
        for name, group in pairs(self.groups) do
            if group.isJob and not job or name == job then
                return group
            end
        end
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

    charInfo.id = MySQL.insert.await("INSERT INTO nd_characters (identifier, name, firstname, lastname, dob, gender, cash, bank, groups, metadata) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", {
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
function NDCore.fetchCharacter(id)
    local result = MySQL.query.await("SELECT * FROM nd_characters WHERE charid = ?", {id})
    if not result then return end
    
    local info = result[1]
    return createCharacterTable({
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
    if not src then return end
    local character = NDCore.fetchCharacter(id)
    character.source = src
    character.name = GetPlayerName(src)
    character.active()
    return ActivePlayers[src]
end
