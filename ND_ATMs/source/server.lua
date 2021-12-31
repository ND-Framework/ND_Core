-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

expectedName = "ND_ATMs" -- This is the resource and is not suggested to be changed.
resource = GetCurrentResourceName()

-- check if resource is renamed
if resource ~= expectedName then
    print("^1[^4" .. expectedName .. "^1] WARNING^0")
    print("Change the resource name to ^4" .. expectedName .. " ^0or else it won't work!")
end

-- check if resource version is up to date
PerformHttpRequest("https://raw.githubusercontent.com/Andyyy7666/ND_Framework/main/ND_ATMs/fxmanifest.lua", function(error, res, head)
    i, j = string.find(tostring(res), "version")
    res = string.sub(tostring(res), i, j + 6)
    res = string.gsub(res, "version ", "")
    res = string.gsub(res, '"', "")
    resp = tonumber(res)
    verFile = GetResourceMetadata(expectedName, "version", 0)
    
    if verFile then
        if tonumber(verFile) < resp then
            print("^1[^4" .. expectedName .. "^1] WARNING^0")
            print("^4" .. expectedName .. " ^0is outdated. Please update it from ^5https://github.com/Andyyy7666/ND_Framework ^0| Current Version: ^1" .. verFile .. " ^0| New Version: ^2" .. resp .. " ^0|")
        elseif tonumber(verFile) > tonumber(resp) then
            print("^1[^4" .. expectedName .. "^1] WARNING^0")
            print("^4" .. expectedName .. "s ^0version number is higher than we expected. | Current Version: ^3" .. verFile .. " ^0| Expected Version: ^2" .. resp .. " ^0|")
        else
            print("^4" .. expectedName .. " ^0is up to date | Current Version: ^2" .. verFile .. " ^0|")
        end
    else
        print("^1[^4" .. expectedName .. "^1] WARNING^0")
        print("You may not have the latest version of ^4" .. expectedName .. "^0. A newer, improved version may be present at ^5https://github.com/Andyyy7666/ND_Framework^0")
    end
end)

function GetPlayerIdentifierFromType(type, source) -- Credits: xander1998, Post: https://forum.cfx.re/t/solved-is-there-a-better-way-to-get-lic-steam-and-ip-than-getplayeridentifiers/236243/2?u=andyyy7666
	local identifiers = {}
	local identifierCount = GetNumPlayerIdentifiers(source)

	for a = 0, identifierCount do
		table.insert(identifiers, GetPlayerIdentifier(source, a))
	end

	for b = 1, #identifiers do
		if string.find(identifiers[b], type, 1) then
			return identifiers[b]
		end
	end
	return nil
end

RegisterNetEvent("ND:withdraw")
AddEventHandler("ND:withdraw", function(amount)
    local player = source
    local characterId = exports["ND_Core"]:getCharacterTable()[player].characterId
    exports.oxmysql:query("UPDATE characters SET bank = bank - ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", player), characterId}, function(result)
        if result then
            exports.oxmysql:query("UPDATE characters SET cash = cash + ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", player), characterId})
            TriggerClientEvent("updateMoney", player)
        end
    end)
end)

RegisterNetEvent("ND:deposit")
AddEventHandler("ND:deposit", function(amount)
    local player = source
    local characterId = exports["ND_Core"]:getCharacterTable()[player].characterId
    exports.oxmysql:query("UPDATE characters SET cash = cash - ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", player), characterId}, function(result)
        if result then
            exports.oxmysql:query("UPDATE characters SET bank = bank + ? WHERE license = ? AND character_id = ?", {amount, GetPlayerIdentifierFromType("license", player), characterId})
            TriggerClientEvent("updateMoney", player)
        end
    end)
end)