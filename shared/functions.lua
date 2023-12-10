local startedResources = {}

local function stateChanged(resourceName, state)
    local callbacks = startedResources[resourceName]
    if not callbacks then return end
    for i=1, #callbacks do
        local cb = callbacks[i]
        cb(state)
    end
end

AddEventHandler("onResourceStart", function(resourceName)
    stateChanged(resourceName, true)
end)

AddEventHandler("onResourceStop", function(resourceName)
    stateChanged(resourceName, false)
end)

function NDCore.isResourceStarted(resourceName, cb)
    local started = GetResourceState(resourceName) == "started"
    if cb then
        if not startedResources[resourceName] then
            startedResources[resourceName] = {}
        end
        startedResources[resourceName][#startedResources[resourceName]+1] = cb
        cb(started)
    end
    return started
end
