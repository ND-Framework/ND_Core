local function charDelete(self)
    local result = MySQL.query.await("DELETE FROM nd_characters WHERE charid = ?", {self.id})
    if result and self.source then
        ActivePlayers[self.source] = nil
    end
    return result
end

local function charDeductMoney(self, account, amount, reason)
    local amount = tonumber(amount)
    if not amount or account ~= "bank" and account ~= "cash" then return end
    self[account] -= amount
    if self.source then
        TriggerEvent("ND:moneyChange", self.source, account, amount, "remove", reason)
        ActivePlayers[self.source] = self
    end
    return true
end

local function charAddMoney(self, account, amount, reason)
    local amount = tonumber(amount)
    if not amount or account ~= "bank" and account ~= "cash" then return end
    self[account] += amount
    if self.source then
        TriggerEvent("ND:moneyChange", self.source, account, amount, "add", reason)
        ActivePlayers[self.source] = self
    end
    return true
end

local function charDepositMoney(self, amount)
    local amount = tonumber(amount)
    if not amount or self.cash < amount or amount <= 0 then return end
    return self:deductMoney("cash", amount, "Deposit") and self:AddMoney("bank", amount, "Deposit")
end

local function charWithdrawMoney(self, amount)
    local amount = tonumber(amount)
    if not amount or self.bank < amount or amount <= 0 then return end
    return self:deductMoney("bank", amount, "Withdraw") and self:AddMoney("cash", amount, "Withdraw")
end

local function charSetMetadata(self, key, value)
    self.metadata[key] = value
    if self.source then
        ActivePlayers[self.source] = self
        return ActivePlayers[self.source].metadata
    end
    return self.metadata
end

local function charUnload(self)
    TriggerEvent("ND:characterUnloaded", self.source, self)
    local ped = GetPlayerPed(self.source)
    self:setMetadata("location", GetEntityCoords(ped))
    self:save()
    if not self.source then return end
    ActivePlayers[self.source] = nil
end

local function charSave(self)
    MySQL.update.await("UPDATE nd_characters SET name = ?, firstname = ?, lastname = ?, dob = ?, gender = ?, cash = ?, bank = ?, metadata = ?, inventory = ? WHERE charid = ?", {
        self.name,
        self.firstname,
        self.lastname,
        self.dob,
        self.gender,
        self.cash,
        self.bank,
        json.encode(self.metadata),
        json.encode(self.inventory),
        self.id,
    })
end

local function charCreateLicense(self, licenseType, expire)
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

    if not self.source then return end
    ActivePlayers[self.source] = self
end

local function charSetCoords(self, coords)
    if not self.source or not coords then return end
    local ped = GetPlayerPed(self.source)
    if not DoesEntityExist(ped) then return end
    SetEntityCoords(ped, coords.x, coords.y, coords.z)
    return true
end

local function initPlayerTable(playerTable)
    playerTable.delete = charDelete,
    playerTable.deductMoney = charDeductMoney,
    playerTable.addMoney = charAddMoney
    playerTable.depositMoney = charDepositMoney,
    playerTable.withdrawMoney = charWithdrawMoney,
    playerTable.setMetadata = charSetMetadata,
    playerTable.save = charSave,
    playerTable.unload = charUnload,
    playerTable.createLicense = charCreateLicense
    playerTable.setCoords = charSetCoords
    return playerTable
end

function NDCore.newCharacter(src, info)
    local license = GetPlayerIdentifierByType(src, "license")
    if not license then return end

    local charInfo = initPlayerTable({
        source = src,
        name = GetPlayerName(src) or "",
        firstname = info.firstname or "",
        lastname = info.lastname or "",
        dob = info.dob or "",
        gender = info.gender or "",
        cash = info.cash or 0,
        bank = info.bank or 0,
        license = license,
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
        charInfo.metadata
    )

    return charInfo
end

function NDCore.fetchCharacter(id)
    local result = MySQL.query.await("SELECT * FROM nd_characters WHERE charid = ?", {id})
    if not result then return end
    
    local info = result[1]
    return initPlayerTable({
        id = id,
        name = info.name,
        firstname = info.firstname,
        lastname = info.lastname,
        dob = info.dob,
        gender = info.gender,
        cash = info.cash,
        bank = info.bank,
        license = info.license,
        metadata = json.decode(info.metadata),
        inventory = json.decode(i.inventory)
    })
end

function NDCore.getPlayerCharacters(src)
    local characters = {}
    local result = MySQL.query.await("SELECT * FROM nd_characters WHERE license = ?", {GetPlayerIdentifierByType(src, "license")})
    local amount = #result

    for i=1, amount do
        local info = result[i]
        characters[info.charid] = initPlayerTable({
            id = info.charid,
            name = info.name,
            firstname = info.firstname,
            lastname = info.lastname,
            dob = info.dob,
            gender = info.gender,
            cash = info.cash,
            bank = info.bank,
            license = info.license,
            metadata = json.decode(info.metadata),
            inventory = json.decode(info.inventory),
        })
    end
    return characters
end

function NDCore.setActiveCharacter(src, id)
    local char = ActivePlayers[src]
    if char then char:unload() end

    local character = NDCore.fetchCharacter(id)
    character.source = src,
    character.name = GetPlayerName(src)
    ActivePlayers[src] = character

    TriggerEvent("ND:characterLoaded", character)
    TriggerClientEvent("ND:characterLoaded", src, character)
    return ActivePlayers[src]
end
