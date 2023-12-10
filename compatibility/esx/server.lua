if not lib.table.contains(Config.compatibility, "esx") then return end

local itemNames
local registeredItems = {}

local function getAmmoFromWeapon(weapon)
    if not weapon then return end
    for item, data in pairs(exports.ox_inventory:Items()) do
        if data.weapon and data.model and data.model:lower() == weapon:lower() then
            return data.ammoname
        end
    end
end

local function createPlayerFunctions(self)
    self.Accounts = {
        Bank = self.bank,
        Money = self.Cash,
        Black = self.Cash
    }

    if self.jobInfo then        
        self.job = {
            id = self.job,
            name = self.job,
            label = self.jobInfo.label,
            grade = self.jobInfo.rank,
            grade_name = self.jobInfo.rankName,
            grade_label = self.jobInfo.rankName,
            grade_salary = 0,
            skin_male = {},
            skin_female = {}
        }
    end

    local ped = GetPlayerPed(self.source)
    if DoesEntityExist(ped) then
        self.coords = GetEntityCoords()
    end

    self.loadout = {}
    self.maxWeight = 30000
    self.money = self.Accounts.Money
    self.sex = self.gender
    self.firstName = self.firstname
    self.lastName = self.lastname
    self.dateofbirth = self.dob
    self.height = 120
    self.dead = self.getMetadata("dead")

    function self.addAccountMoney(account, amount)
        local amount = tonumber(amount)
        if not amount or amount <= 0 or account ~= "bank" and account ~= "cash" then return end
        self[account] += amount
        if NDCore.players[self.source] then
            self.triggerEvent("ND:updateMoney", self.cash, self.bank)
            TriggerEvent("ND:moneyChange", self.source, account, amount, "add")
        end
        return true
    end

    function self.addInventoryItem(item, count)
        exports.ox_inventory:AddItem(self.source, item, count)
    end

    function self.addMoney(amount)
        local amount = tonumber(amount)
        if not amount or amount <= 0 then return end
        self["bank"] += amount
        if NDCore.players[self.source] then
            self.triggerEvent("ND:updateMoney", self.cash, self.bank)
            TriggerEvent("ND:moneyChange", self.source, "bank", amount, "add", reason)
        end
        return true
    end

    function self.addWeaponAmmo(weaponName, ammoCount)
        local ammoName = getAmmoFromWeapon(weaponName)
        if not ammoName then return end
        self.addInventoryItem(ammoName, ammoCount)
    end

    function self.addWeapon(weaponName, ammo)
        local name = nil
        if weaponName:find("weapon") then
            name = weaponName
        else
           name = ("weapon_%s"):format(weaponName)
        end
        self.addInventoryItem(name, 1)
        self.addWeaponAmmo(name, ammo)

        -- local weapon = GetHashKey(name)
        -- local ped = GetPlayerPed(self.source)
        -- GiveWeaponToPed(ped, weapon, ammo, false, false)
    end

    function self.addWeaponComponent(_, component)
        self.addInventoryItem(component, 1)
    end

    function self.canCarryItem(item, count)
        return exports.ox_inventory:CanCarryItem(self.source, item, count)
    end

    function self.canSwapItem(firstItem, firstItemCount, testItem, testItemCount)
        exports.ox_inventory:CanSwapItem(self.source, firstItem, firstItemCount, testItem, testItemCount)
    end

    function self.clearMeta(index)
        self.setMetadata(index, nil)
    end

    function self.getMeta(index, subIndex)
        local meta = self.getMetadata(index)
        if type(meta) == "table" then
            return meta[subIndex]
        end
        return meta
    end

    function self.getCoords(useVector)
        local ped = GetPlayerPed(self.source)
        local coords = GetEntityCoords(ped)
        if useVector then
            return coords
        end
        return {
            x = coords.x,
            y = coords.y,
            z = coords.z
        }
    end

    function self.getIdentifier()
        return self.identifier
    end

    function self.getInventory(minimal)
        local playerItems = exports.ox_inventory:GetInventoryItems(self.source)
        if not minimal then
            return playerItems
        end
        -- minimal stuff
    end

    function self.getInventoryItem(item)
        local playerItems = exports.ox_inventory:GetInventoryItems(self.source)
        for name, data in pairs(playerItems) do
            if name == item then
                return data
            end
        end
    end

    function self.getMoney()
        return self.bank
    end

    function self.getName()
        return self.fullname
    end
    
    function self.hasItem(item, metadata)
        return exports.ox_inventory:GetItem(self.source, item, metadata)
    end

    function self.removeInventoryItem(item, count)
        exports.ox_inventory:RemoveItem(self.source, item, count)
    end

    function self.removeMoney(amount)
        self.deductMoney("bank", amount)
    end

    function setMoney(amount)
        self.setData("bank", amount)
    end

    self.kick = self.drop
    self.removeAccountMoney = self.deductMoney
    self.setMeta = self.setMetadata
    self.setAccountMoney = self.setData
    self.setInventoryItem = self.addInventoryItem


    -- self.getAccount(account)
    -- self.getAccounts()
    -- self.getGroup()
    -- self.getJob()
    -- self.getLoadout()
    -- self.getMissingAccounts(cb)
    -- self.getWeapon(weaponName)
    -- self.getWeaponTint(weaponName, weaponTintIndex)
    -- self.getWeight()
    -- self.hasWeapon(weaponName)
    -- self.hasWeaponComponent(weaponName, weaponComponent)
    -- self.removeWeapon(weaponName)
    -- self.removeWeaponAmmo(weaponName, ammoCount)
    -- self.removeWeaponComponent(weaponName, weaponComponent)
    -- self.setMaxWeight(newWeight)
    -- self.setName(newName)
    -- self.setWeaponTint(weaponName, weaponTintIndex)
    -- self.showAdvancedNotification(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
    -- self.showHelpNotification(msg, thisFrame, beep, duration)
    -- self.showNotification(msg, flash, saveToBrief, hudColorIndex)

    return self
end

NDCore.OneSync = {}
NDCore.RegisterServerCallback = lib.callback.register
NDCore.SetTimeout = SetTimeout
NDCore.Trace = Citizen.Trace

local function exportHandler(resource, exportName, cb)
    AddEventHandler(("__cfx_export_%s_%s"):format(resource, exportName), function(setCB)
        setCB(cb)
    end)
end

exportHandler("es_extended", "getSharedObject", function()
    return NDCore
end)

function NDCore.ClearTimeout()
    print("[^3WARNING^7] ESX Function 'ClearTimeout' is not compatible with NDCore!")
end

function NDCore.CreatePickup()
    print("[^3WARNING^7] ESX Function 'CreatePickup' is not compatible with NDCore!")
end

function NDCore.DiscordLog()
    print("[^3WARNING^7] ESX Function 'DiscordLog' is not compatible with NDCore!")
end

function NDCore.DiscordLogFields()
    print("[^3WARNING^7] ESX Function 'DiscordLogFields' is not compatible with NDCore!")
end

function NDCore.RegisterUsableItem()
    print("[^3WARNING^7] ESX Function 'RegisterUsableItem' is not compatible with NDCore!")
end

function NDCore.UseItem()
    print("[^3WARNING^7] ESX Function 'UseItem' is not compatible with NDCore!")
end


function NDCore.GetPlayerFromId(src)
    return createPlayerFunctions(NDCore.getPlayer(src))
end

function NDCore.GetExtendedPlayers(key, value)
    local players = {}
    if not key or not value then
        for _, info in pairs(NDCore.players) do
            players[#players+1] = createPlayerFunctions(info)
        end
        return players
    end 
    
    local keyTypes = {id = "id", firstname = "firstname", lastname = "lastname", gender = "gender", groups = "groups"}
    local findBy = keyTypes[key] or "metadata"
    if findBy then
        for _, info in pairs(NDCore.players) do
            if findBy == "metadata" and info["metadata"][key] == value or info[findBy] == value then
                players[#players+1] = createPlayerFunctions(info)
            end
        end
    end
    return players
end

NDCore.GetPlayers = NDCore.GetExtendedPlayers

function NDCore.RegisterCommand(name, perms, cb, allowConsole, suggestion)
    lib.addCommand(name, {
        help = suggestion.help,
        params = suggestion.arguments,
        restricted = perms and ("group.%s"):format(perms)
    }, function(source, args, raw)
        if allowConsole and source == 0 then
            return print("[^3WARNING^7] ^5Command Cannot be executed from console")
        end
        local player = NDCore.getPlayer(source)
        cb(player, args, function(msg)
            if source == 0 then
                return print(("[^3WARNING^7] %s^7"):format(msg))
            end
            player.showNotification(msg)
        end)
    end)
end

function NDCore.DoesJobExist(job, grade)
    local groupInfo = Config.groups[job]
    if groupInfo and groupInfo.ranks[grade] then
        return true
    end
end

function NDCore.GetItemLabel(item)
    if not itemNames then
        itemNames = {}
        for item, data in pairs(exports.ox_inventory:Items()) do
            itemNames[item] = data.label
        end
    end
    return itemNames[item]
end

function NDCore.GetJobs()
    return Config.groups
end

function NDCore.GetPlayerFromIdentifier(identifier)
    for _, info in pairs(NDCore.players) do
        if info.identifier:find(identifier) then
            return info
        end
    end
end

function NDCore.OneSync.SpawnObject(model, coords, heading, cb)
    local entity = CreateObject(model, coords.x, coords.y, coords.z, true, false, false)
    local value = lib.waitFor(function()
        if DoesEntityExist(entity) then return entity end
    end, "Failed to spawn object", 5000)
    if not value then return end
    SetEntityHeading(value, heading)
    if not cb then return end
    cb(value)
end

function NDCore.OneSync.SpawnPed(model, coords, heading, cb)
    local entity = CreatePed(0, model, coords.x, coords.y, coords.z, heading, true, false)
    local value = lib.waitFor(function()
        if DoesEntityExist(entity) then return entity end
    end, "Failed to spawn ped", 5000)
    if not value or not cb then return end
    cb(NetworkGetNetworkIdFromEntity(value))
end

function NDCore.OneSync.SpawnVehicle(model, coords, heading, properties, cb)
    local vehicle = NDCore.createVehicle({
        model = model,
        coords = coords,
        heading = heading
    })
    if not cb then return end
    cb(vehicle.netId)
end

function NDCore.OneSync.SpawnPedInVehicle(model, vehicle, seat, cb)
    local entity = CreatePedInsideVehicle(vehicle, 0, model, seat, true, false)
    local value = lib.waitFor(function()
        if DoesEntityExist(entity) then return entity end
    end, "Failed to spawn ped", 5000)
    if not value or not cb then return end
    cb(value)
end

AddEventHandler("ND:characterUnloaded", function(src, character)
    TriggerEvent("esx:playerDropped", src, "")
end)

AddEventHandler("ND:characterLoaded", function(character)
    TriggerEvent("esx:playerLoaded", character.source, createPlayerFunctions(character))
end)
