<p  align="center">
  <img src="https://user-images.githubusercontent.com/86536434/193703880-5cb7deef-af37-42cc-8df2-b13332afee67.png" />
</p>

<p align='center'><b><a href="https://discord.gg/andys-development-857672921912836116">Discord</a></b>

<p align='center'><b><a href="https://ndcore.dev/">Documentation</a></b>

## Dependency:
* [oxmysql](https://github.com/overextended/oxmysql/releases)
* [ox_lib](https://github.com/overextended/ox_lib/releases)

## v2 Addons
* [Character selection](https://github.com/ND-Framework/ND_Characters/tree/wip-v2)
* [Banking](https://github.com/ND-Framework/ND_Banking/tree/wip-v2)
* [Appearance shops](https://github.com/ND-Framework/ND_AppearanceShops/tree/wip-v2)
* [Dealership](https://github.com/ND-Framework/ND_Dealership/tree/v2)
* [Inventory](https://github.com/overextended/ox_inventory/pull/1403)

# Need support?
[![Discord](https://discordapp.com/api/guilds/857672921912836116/widget.png?style=banner3)](https://discord.gg/Z9Mxu72zZ6)

# Setup until docs is done:
Paste code below into a file and name it ndcore.cfg then write `exec ndcore.cfg` in your server.cfg
```py
# Your servers name
setr core:serverName "My FiveM Server"

# Discord invite link
setr core:discordInvite "https://discord.gg/Z9Mxu72zZ6"

# Discord app id for rich presence
setr core:discordAppId "858146067018416128"

# Images for discord rich presence
setr core:discordAsset "andyyy"
setr core:discordAssetSmall "andyyy"

# Buttons for discord rich presence
setr core:discordActionText "DISCORD"
setr core:discordActionLink "https://discord.gg/Z9Mxu72zZ6"

setr core:discordActionText2 "STORE"
setr core:discordActionLink2 "https://andyyy.tebex.io/category/fivem-scripts"

# Used for getting users roles from your server, this can be useful for discord based scripts, if you don't add then it won't be used.
# set core:discordGuildId "123456789012345678"
# set core:discordBotToken "EXAMPLE_TOKEN.abc123.xyz456"

# The identifier to use for characters. Players aren't allowed to join without it, license is good don't change unless you know what you're doing.
set core:characterIdentifier "license"

# % chance of random vehicles being unlocked.
setr core:randomUnlockedVehicleChance 30

# disable vehicle air contorl for cars and other land vehicles that's not supposed to do flips in air.
setr core:disableVehicleAirControl true

# If true it will use ox_inventory keys item for vehicles, if false it will use a keybind.
setr core:useInventoryForKeys true

# You can set admins here by their identifiers, admins will receive admin group in core and have access to group.admin ace perms.
# You can also use Discord role ids, Admins get access to commands and more.
set core:admins ["fivem:1459624", "fivem:1152629"]
set core:adminDiscordRoles ["944284542758449212", "93422454258349612", "93345451558145232"]

# Allow ox_lib to use commands, don't remove this!
add_ace resource.ox_lib command.add_ace allow
add_ace resource.ox_lib command.remove_ace allow
add_ace resource.ox_lib command.add_principal allow
add_ace resource.ox_lib command.remove_principal allow

# This is jobs, gangs, police, fire, ambulance, everything.
setr core:groups {
    "sahp": {
        "label": "SAHP",
        "ranks": ["Trooper", "Senior Trooper", "Corporal", "Sergeant", "Lieutenant", "Chief"]
    },
    "lspd": {
        "label": "LSPD",
        "ranks": ["Officer", "Senior officer", "Corporal", "Sergeant", "Lieutenant", "Chief"]
    },
    "bcso": {
        "label": "BCSO",
        "ranks": ["Officer", "Senior officer", "Corporal", "Sergeant", "Lieutenant", "Chief"]
    },
    "swat": {
        "label": "SWAT",
        "ranks": ["Member", "Sniper", "Team lead", "Commander"]
    },
    "lsfd": {
        "label": "LSFD",
        "ranks": ["Volunteer", "Firefighter", "Senior firefighter", "Lieutenant", "Fire Chief"]
    },
    "ballas": {
        "label": "Ballas",
        "ranks": ["Member", "Leader"]
    },
    "families": {
        "label": "Families",
        "ranks": ["Member", "Leader"]
    },
    "cartel": {
        "label": "Madrazo Cartel",
        "ranks": ["Member", "Leader"]
    }
}
```
