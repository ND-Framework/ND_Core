-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

config = {
    serverName = "Andy's Development",
    characterLimit = 15, -- How many characters can a player create.
    customPauseMenu = true, -- A custom pause menu will display your money, characters name and the server name in the pause menu.
    enablePVP = true, -- pvp allows doing damage to other players.
    
    -- Money related
    startingCash = 2500, -- default cash the character will start with if the character creator doesn't specify it.
    startingBank = 8000,-- default money in the bank account the character will start with if the character creator doesn't specify it.
    
    -- If you'd like to whitelist certain roles on discord then set this to true and add role ids.
    enableDiscordWhitelist = false,
    notWhitelistedMessage = "You're not allowlisted in this server please join our discord to apply for a allowlist: https://discord.gg/Z9Mxu72zZ6",
    whitelistRoles = {
        "872921520719142932"
    },

    -- These are admins roles that will give a user permission to admin commands and more.
    adminRoles = {
        "872921520719142932"
    },

    -- Discord Rich presence
    enableRichPresence = true,
    updateIntervall = 60, -- how many seconds of delay until it updates status.
    appId = 858146067018416128,
    largeLogo = "andyyy",
    smallLogo = "andyyy",
    firstButtonName = "DISCORD",
    firstButtonLink = "https://discord.gg/Z9Mxu72zZ6",
    secondButtonName = "TEBEX",
    secondButtonLink = "https://andyyy.tebex.io/category/fivem-scripts",


    -- Groups can be gangs, jobs, subdivisions, etc.
    groups = {
        ["Ballas"] = {
            "Member", -- rank 1
            "Boss" -- rank 2
        },
        ["SWAT"] = {
            "Member", -- rank 1
            "Sniper", -- rank 2
            "Team lead", -- rank 3
            "Commander" -- rank 4
        },
        ["SAHP"] = {
            "Trooper",
            "Senior Trooper",
            "Corporal",
            "Sergeant",
            "Lieutenant",
            "Cheif"
        },
        ["LSPD"] = {
            "Officer",
            "Senior officer",
            "Corporal",
            "Sergeant",
            "Lieutenant",
            "Cheif"
        },
        ["BCSO"] = {
            "Deputy",
            "Senior Deputy",
            "Corporal",
            "Sergeant",
            "Lieutenant",
            "Cheif"
        }
    },
}