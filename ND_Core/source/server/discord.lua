-- original discord roles author: https://forum.cfx.re/t/discord-roles-for-permissions-im-creative-i-know/233805?u=andyyy7666
local FormattedToken = "Bot "..config.DiscordToken

function DiscordRequest(method, endpoint, jsondata)
    local data = nil
    PerformHttpRequest("https://discordapp.com/api/"..endpoint, function(errorCode, resultData, resultHeaders)
		data = {data=resultData, code=errorCode, headers=resultHeaders}
    end, method, #jsondata > 0 and json.encode(jsondata) or "", {["Content-Type"] = "application/json", ["Authorization"] = FormattedToken})

    while data == nil do
        Citizen.Wait(0)
    end
	
    return data
end

 --[[ we don't use this in this resource.
function GetRoles(user)
	local discordId = nil
	for _, id in ipairs(GetPlayerIdentifiers(user)) do
		if string.match(id, "discord:") then
			discordId = string.gsub(id, "discord:", "")
			print("Found discord id: "..discordId)
			break
		end
	end

	if discordId then
		local endpoint = ("guilds/%s/members/%s"):format(config.GuildId, discordId)
		local member = DiscordRequest("GET", endpoint, {})
		if member.code == 200 then
			local data = json.decode(member.data)
			local roles = data.roles
			local found = true
			return roles
		else
			print("Error occurred, maybe they are not in discord?")
			return false
		end
	else
		print("missing identifier")
		return false
	end
end
]]

function IsRolePresent(user, role)
	local discordId = nil
	for _, id in ipairs(GetPlayerIdentifiers(user)) do
		if string.match(id, "discord:") then
			discordId = string.gsub(id, "discord:", "")
			print("Found discord id: "..discordId)
			break
		end
	end

	local theRole = nil
	if type(role) == "number" then
		theRole = tostring(role)
	else
		theRole = config.roles[role]
	end

    if theRole == "0" then
        print("Role Given (0 in config)")
        return true
    elseif discordId then
		local endpoint = ("guilds/%s/members/%s"):format(config.GuildId, discordId)
		local member = DiscordRequest("GET", endpoint, {})
		if member.code == 200 then
			local data = json.decode(member.data)
			local roles = data.roles
			local found = true
			for i=1, #roles do
				if roles[i] == theRole then
					print("Found role")
					return true
				end
			end
			print("Not found!")
			return false
		else
			print("Error occurred, maybe they are not in discord?")
			return false
		end
    else
		print("missing identifier")
		return false
	end
end

Citizen.CreateThread(function()
	local guild = DiscordRequest("GET", "guilds/"..config.GuildId, {})
	if guild.code == 200 then
		local data = json.decode(guild.data)
		print("Permission system guild set to: "..data.name.." ("..data.id..")")
	else
		print("An error occured, please check your config and ensure everything is correct. Error: "..(guild.data or guild.code)) 
	end
end)