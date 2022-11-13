NDCore.Commands = {}
NDCore.Commands.Registry = {}

function NDCore.Commands.Add(name, help, arguments, argsrequired, callback, ...)
    RegisterCommand(name, function(source, args, rawCommand)
        if argsrequired and #args < #arguments then
            return TriggerClientEvent("chat:addMessage", source, {
                color = {255, 0, 0},
                multiline = true,
                args = {"System", "All arguments must be filled out!"}
            })
        end
        callback(source, args, rawCommand)
    end, false)

    NDCore.Commands.Registry[name:lower()] = {
        name = name:lower(),
        help = help,
        arguments = arguments,
        argsrequired = argsrequired,
        callback = callback
    }
end

function NDCore.Commands.Refresh(source)
    local src = source
    local Player = NDCore.Functions.GetPlayer(src)
    local suggestions = {}
    if Player then
        for command, info in pairs(NDCore.Commands.Registry) do
            suggestions[#suggestions + 1] = {
                name = "/" .. command,
                help = info.help,
                params = info.arguments
            }
        end
        TriggerClientEvent("chat:addSuggestions", src, suggestions)
    end
end