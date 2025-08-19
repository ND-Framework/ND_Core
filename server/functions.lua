function NDCore.getPlayerIdentifierByType(src, indentifierType)
    if Config.sv_lan then
        return ("%s:sv_lan"):format(indentifierType)
    end
    return GetPlayerIdentifierByType(src, indentifierType)
end

NDCore.UsableItems = {}

-- Function to register usable items
---@param item string The name of the item to register
---@param cb function The callback function to execute when the item is used
function NDCore.registerUsableItem(item, cb)
    if not item or type(item) ~= "string" then return end

    NDCore.UsableItems[item] = {
        cb = cb,
        resource = GetInvokingResource() or GetCurrentResourceName()
    }
end

-- Function to check if an item is usable
---@param item string The name of the item to check
---@return boolean|table Returns the item data if usable, false otherwise
function NDCore.isItemUsable(item)
    return NDCore.UsableItems[item] or false
end

-- Function to use an item
---@param src number The source player ID
---@param item string|table The item name or item data
function NDCore.useItem(src, item)
    if not src or not item then return end

    local itemName = type(item) == "table" and item.name or item
    local itemData = NDCore.UsableItems[itemName]

    if itemData and itemData.cb then
        if type(itemData.cb) == "function" then
            itemData.cb(src, item)
        end
    end
end

---@param src number
---@return table
function NDCore.getPlayer(src)
    return NDCore.players[src]
end

---@param metadata string
---@param data any
---@return table
function NDCore.getPlayers(key, value, returnArray)
    if not key or not value then return NDCore.players end

    local players = {}
    local keyTypes = {id = "id", firstname = "firstname", lastname = "lastname", gender = "gender", groups = "groups"}
    local findBy = keyTypes[key] or "metadata"

    if findBy then
        for src, info in pairs(NDCore.players) do
            if findBy == "metadata" and info["metadata"][key] == value or info[findBy] == value then
                if returnArray then
                    players[#players+1] = info
                else
                    players[src] = info
                end
            end
        end
    end
    return players
end

---@param source number
---@return table
function NDCore.getPlayerServerInfo(source)
    return PlayersInfo[source]
end

function NDCore.getConfig(info)
    if not info then
        return Config
    end
    return Config[info]
end

---@param fileLocation string|tabale
---@return boolean
function NDCore.loadSQL(fileLocation, resource)
    local resourceName = resource or GetInvokingResource() or  GetCurrentResourceName()

    if type(fileLocation) == "string" then
        local file = LoadResourceFile(resourceName, fileLocation)
        if not file then return end
        MySQL.query(file)
        return true
    end

    for i=1, #fileLocation do
        local file = LoadResourceFile(resourceName, fileLocation[i])
        if file then
            MySQL.query(file)
            Wait(100)
        end
    end
    return true
end

function NDCore.getDiscordInfo(discordUserId)
    if not discordUserId or not Config.discordBotToken or not Config.discordGuildId then return end
    local done = false
    local data
    local discordErrors = {
        [400] = "Improper HTTP request",
        [401] = "Discord bot token might be missing or incorrect",
        [404] = "User might not be in the server",
        [429] = "Discord bot rate limited"
    }

    if type(discordUserId) == "string" and discordUserId:find("discord:") then discordUserId:gsub("discord:", "") end

    PerformHttpRequest(("https://discordapp.com/api/guilds/%s/members/%s"):format(Config.discordGuildId, discordUserId), function(errorCode, resultData, resultHeaders)
        if errorCode ~= 200 then
            done = true
            return print(("^3Warning: %d %s"):format(errorCode, discordErrors[errorCode]))
        end

        local result = json.decode(resultData)
        data = {
            nickname = result.nick or result.user.username,
            user = result.user,
            roles = result.roles
        }
        done = true
    end, "GET", "", {["Content-Type"] = "application/json", ["Authorization"] = ("Bot %s"):format(Config.discordBotToken)})

    while not done do Wait(50) end
    return data
end

function NDCore.enableMultiCharacter(enable)
    Config.multiCharacter = enable
end

-- Track if we've already integrated
local hasIntegratedWithOxInventory = false

-- Provides a direct hook into ox_inventory's server.UseItem function
function NDCore.integrateWithOxInventory()
    if GetResourceState("ox_inventory") ~= "started" or hasIntegratedWithOxInventory then
        return false
    end

    -- Mark as integrated to prevent duplicate event handlers
    hasIntegratedWithOxInventory = true

    -- Use a more reliable method through event handling
    -- Create a hook for the ox_inventory event
    AddEventHandler("ox_inventory:usedItem", function(playerId, itemName, slot, metadata)
        exports["ND_Core"]:UseItem(playerId, itemName, {
            name = itemName,
            slot = slot,
            metadata = metadata
        })
    end)

    return true
end

-- Try to integrate with ox_inventory when the resource starts
AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    -- Wait a bit to ensure everything is loaded
    SetTimeout(2000, function()
        NDCore.integrateWithOxInventory()
    end)
end)

-- Also try to integrate when ox_inventory starts
AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= "ox_inventory" then return end

    -- Wait a bit to ensure ox_inventory is fully loaded
    SetTimeout(2000, function()
        NDCore.integrateWithOxInventory()
    end)
end)

for name, func in pairs(NDCore) do
    if type(func) == "function" then
        exports(name, func)
    end
end
