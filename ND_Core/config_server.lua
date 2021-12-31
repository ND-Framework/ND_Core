-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

server_config = {
    DiscordToken = "0", -- discord bot token for permissions
    GuildId = "872496972454592523", -- discord guild id

    -- role id for each role of the department in your discord. 0 Gives the role to everyone.
    roles = {
        ["ADMIN"] = "0", -- You can remove this if you don't want it but this should only be here for permisisons not as a department and it won't display as a department. This can be used for /setaop and other permissions.
        ["CIV"] = "0", 
        ["SAHP"] = "0",
        ["LSPD"] = "0",
        ["BCSO"] = "0",
        ["LSFD"] = "0"
    }
}
