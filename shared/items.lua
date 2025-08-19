-- Initialize the items table to store item callbacks
local items = {}

-- Flag to prevent multiple event handling
local isProcessingItemUse = {}

-- Function to register a usable item
---@param name string The name of the item to register
---@param cb function The callback function to execute when the item is used
local function RegisterUsableItem(name, cb)
    if not name or type(name) ~= "string" then return end

    -- Store the callback in the items table
    items[name] = cb

    -- Register the item with ND_Core's usable items system
    exports["ND_Core"]:registerUsableItem(name, cb)
end

-- Create a function that ox_inventory can call to use items
local function UseItem(source, itemName, data)
    -- Prevent duplicate handling
    local playerId = tonumber(source)
    if not playerId or isProcessingItemUse[playerId .. itemName] then return false end

    -- Set flag to prevent duplicate handling
    isProcessingItemUse[playerId .. itemName] = true

    -- Check if the item has a registered callback
    local item = items[itemName]
    local result = false

    if item then
        -- Call the item's callback with the source and item data
        result = item(source, data)
    elseif exports["ND_Core"]:isItemUsable(itemName) then
        -- Call ND_Core's useItem function if registered directly with ND_Core
        result = exports["ND_Core"]:useItem(source, data)
    end

    -- Clear the processing flag after a short delay
    SetTimeout(500, function()
        isProcessingItemUse[playerId .. itemName] = nil
    end)

    return result
end

-- Make the RegisterUsableItem function available as an export
exports("RegisterUsableItem", RegisterUsableItem)

-- Make the UseItem function available as an export
exports("UseItem", UseItem)

-- Listen for ox_inventory usedItem event
-- Only register this once when the resource starts
local hasRegisteredEventHandler = false
AddEventHandler("onResourceStart", function(resourceName)
    if resourceName ~= GetCurrentResourceName() or hasRegisteredEventHandler then return end

    hasRegisteredEventHandler = true

    AddEventHandler("ox_inventory:usedItem", function(playerId, itemName, slot, metadata)
        -- Call our UseItem function which has duplicate prevention
        exports["ND_Core"]:UseItem(playerId, itemName, {
            name = itemName,
            slot = slot,
            metadata = metadata
        })
    end)

    -- Wait a bit to ensure everything is loaded
    SetTimeout(1000, function()
        if GetResourceState("ox_inventory") ~= "started" then
            print("WARNING: ox_inventory is not running!")
            return
        end
    end)
end)

-- Example usage:
--[[
    exports["ND_Core"]:RegisterUsableItem("bandage", function(source, item)
        local player = exports["ND_Core"]:getPlayer(source)
        if not player then return end

        TriggerClientEvent("some:healing:event", source)

        TriggerClientEvent("ox_lib:notify", source, {
            title = "Used Bandage",
            description = "You have used a bandage and feel better",
            type = "success"
        })

        return true
    end)
--]]