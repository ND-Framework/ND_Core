local function createCharacterTable(info)
    local self = {
        source = info.source,
        license = info.license,
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
        if self.source then
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
        if self.source then
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
    
    ---@param key string
    ---@param value any
    ---@return table
    function self.setMetadata(key, value)
        self.metadata[key] = value
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
        if not self.source then return end
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
            return
        end
        self.metadata.licenses = {license}
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

    ---@param reason string
    function self.drop(reason)
        if not self.source then return end
        DropPlayer(self.source, reason)
    end

    -- Set the character as the players active character/currently playing character
    function self.active()
        local char = ActivePlayers[self.source]
        if char and char.id == self.id then return true end
        if char then char:unload() end
        ActivePlayers[self.source] = self
        TriggerEvent("ND:characterLoaded", self)
        TriggerClientEvent("ND:characterLoaded", self.source, self)
    end

    ---@param name string
    ---@param rank number
    ---@return boolean
    function self.addGroup(name, rank)
        local groupInfo = Config.groups[name]
        if not groupInfo return end
        self.groups[name] = {
            label = groupInfo.label,
            rankName = groupInfo.ranks[rank] or rank,
            rank = rank
        }
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
    end

    return self
end

---@param src number
---@param info table
---@return table
function NDCore.newCharacter(src, info)
    local license = GetPlayerIdentifierByType(src, "license")
    if not license then return end

    local charInfo = createCharacterTable({
        source = src,
        license = license,
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
    })

    charInfo.id = MySQL.insert.await("INSERT INTO nd_characters (license, name, firstname, lastname, dob, gender, cash, bank, metadata) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)", {
        license,
        charInfo.name,
        charInfo.firstname,
        charInfo.lastname,
        charInfo.dob,
        charInfo.gender,
        charInfo.cash,
        charInfo.bank,
        json.encode(charInfo.metadata)
    })

    return charInfo
end

---@param id number
---@return table
function NDCore.fetchCharacter(id)
    local result = MySQL.query.await("SELECT * FROM nd_characters WHERE charid = ?", {id})
    if not result then return end
    
    local info = result[1]
    return createCharacterTable({
        id = id,
        license = info.license,
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
function NDCore.getPlayerCharacters(src)
    local characters = {}
    local result = MySQL.query.await("SELECT * FROM nd_characters WHERE license = ?", {GetPlayerIdentifierByType(src, "license")})
    local amount = #result

    for i=1, amount do
        local info = result[i]
        characters[info.charid] = createCharacterTable({
            id = info.charid,
            license = info.license,
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
    local char = ActivePlayers[src]
    if char then char:unload() end

    local character = NDCore.fetchCharacter(id)
    character.source = src
    character.name = GetPlayerName(src)
    ActivePlayers[src] = character

    TriggerEvent("ND:characterLoaded", character)
    TriggerClientEvent("ND:characterLoaded", src, character)
    return ActivePlayers[src]
end
