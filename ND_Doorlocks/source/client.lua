-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

function drawText3D(coords, text)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z + 0.5)
    local pX, pY, pZ = table.unpack(GetGameplayCamCoords())
    SetTextScale(0.4, 0.4)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextEntry("STRING")
    SetTextCentre(true)
    SetTextColour(255, 255, 255, 255)
    SetTextOutline()
    AddTextComponentString(text)
    DrawText(_x, _y)
end

function getDoorText(locked)
    if locked then
        return "Locked [E]"
    end
    return "Unlocked [E]"
end

function isAuthorized(door)
    for _, authorizedJob in pairs(door.authorizedJobs) do
        if job == authorizedJob then
            return true
        end
    end
    return false
end

AddEventHandler("onResourceStart", function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    job = exports["ND_Core"]:getCharacterInfo().department
end)

AddEventHandler("characterChanged", function(selectedCharacter)
    job = selectedCharacter.department
end)

Citizen.CreateThread(function()
    while true do
        pedCoords = GetEntityCoords(PlayerPedId())
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        for doorID, door in pairs(doorList) do
            if #(pedCoords - door.textCoords) < door.accessDistance and isAuthorized(door) then
                drawText3D(door.textCoords, getDoorText(door.locked))
                for _, doors in pairs(door.doors) do
                    local entity = GetClosestObjectOfType(doors.coords.x, doors.coords.y, doors.coords.z, 1.0, doors.hash, false, false, false)
                    FreezeEntityPosition(entity, door.locked)
                end
            end
            if IsControlJustPressed(0, 51) then
                door.locked = not door.locked
                TriggerServerEvent("ND_Doorlocks:syncDoor", doorID, door.locked)
            end
        end
        Citizen.Wait(0)
    end
end)

RegisterNetEvent("ND_Doorlocks:syncDoor")
AddEventHandler("ND_Doorlocks:syncDoor", function(doorID, state)
    doorList[doorID].locked = state
    for _, doors in pairs(doorList[doorID].doors) do
        local entity = GetClosestObjectOfType(doors.coords.x, doors.coords.y, doors.coords.z, 1.0, doors.hash, false, false, false)
        SetEntityHeading(entity, doors.heading)
    end
end)
