if config["/me"] then
    TriggerEvent("chat:addSuggestion", "/me", "Send message in the third person (Proximity Chat).", {{ name="Action", help="Describe your action."}})
end

if config["/gme"] then
    TriggerEvent("chat:addSuggestion", "/gme", "Send message in the third person (Global Chat).", {{ name="Action", help="Describe your action."}})
end

if config["/ooc"] then
    TriggerEvent("chat:addSuggestion", "/ooc", "Out Of Character chat Message (Global Chat).", {{name="Message", help="Put your questions or help request."}})
end

if config["/twt"] then
    TriggerEvent("chat:addSuggestion", "/twt", "Send a Twotter in game. (Global Chat)", {{name="Message", help="Twotter Message."}})
end

if config["/darkweb"].enabled then
    TriggerEvent("chat:addSuggestion", "/darkweb", "Send a anonymous message in game (Global Chat).", {{ name="Message", help=""}})
end

if config["/911"].enabled then
    RegisterNetEvent("ND_Chat:911")
    AddEventHandler("ND_Chat:911", function(coords, callDescription)
        local selectedCharacter = exports["ND_Core"]:getCharacterInfo()
        for _, department in pairs(config["/911"].callTo) do
            if selectedCharacter.department == department then
                local location = GetStreetNameFromHashKey(GetStreetNameAtCoord(coords.x, coords.y, coords.z))
                TriggerEvent("chat:addMessage", {
                    color = {255, 0, 0},
                    args = {"^*[911] ^3Location: " .. location .. " ^1| Call infomation^0", callDescription}
                })
                local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
                SetBlipSprite(blip, 817)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                SetBlipColour(blip, 1)
                AddTextComponentString("911 CALL: " .. location)
                EndTextCommandSetBlipName(blip)
                Citizen.Wait(60 * 1000)
                RemoveBlip(blip)
                break
            end 
        end
    end)
end