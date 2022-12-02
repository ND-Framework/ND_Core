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

function isResourceStarted(resourceName, cb)
    local started = GetResourceState(resourceName) == "started"
    startedResources[resourceName] = started

    if cb then
        callbacks[resourceName] = cb
        cb(started)
    end
    
    return started
end

exports("isResourceStarted", isResourceStarted)