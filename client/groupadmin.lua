local isOpen = false

RegisterNUICallback("hide", function(_, cb)
    isOpen = false
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("groups:create", function(data, cb)
    local result = lib.callback.await("ND_Core:groups:create", false, data)
    cb(result or {})
end)

RegisterNUICallback("groups:edit", function(data, cb)
    local result = lib.callback.await("ND_Core:groups:edit", false, data)
    cb(result or {})
end)

RegisterNUICallback("groups:delete", function(data, cb)
    local result = lib.callback.await("ND_Core:groups:delete", false, data)
    cb(result or {})
end)

RegisterNetEvent("ND:openGroupAdmin", function(groups)
    if isOpen then return end
    isOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({
        type = "groups:open",
        groups = groups
    })
end)
