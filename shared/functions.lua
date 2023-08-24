local startedResources = {}
local callbacks = {}

AddEventHandler("onResourceStart", function(resourceName)
    startedResources[resourceName] = true
    local callback = callbacks[resourceName]
    if not callback then return end
    callback(true)
end)

AddEventHandler("onResourceStop", function(resourceName)
    startedResources[resourceName] = nil
    local callback = callbacks[resourceName]
    if not callback then return end
    callback(false)
end)

function NDCore.isResourceStarted(resourceName, cb)
    local started = GetResourceState(resourceName) == "started"
    if cb then
        startedResources[resourceName] = started
        callbacks[resourceName] = cb
        cb(started)
    end
    return started
end

function NDCore.formatNum(num)
    return tostring(num):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

function NDCore.cleanString(x, y)
    -- x = string
    -- y = true to save whitespace, default false
    if y or false then
        x = string.gsub(tostring(x), '[^%w%s_]', '') -- Save WS
        return x
    else
        x = string.gsub(tostring(x), '[^%w_]', '') -- Kill WS
        return x
    end
end
