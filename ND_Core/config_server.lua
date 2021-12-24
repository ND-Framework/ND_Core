------------------------------------------------------------------------
------------------------------------------------------------------------
--     							 									  --
--	   For support join my discord: https://discord.gg/Z9Mxu72zZ6	  --
--     							 									  --
------------------------------------------------------------------------
------------------------------------------------------------------------

config = {
    -- Server name to display on the ui.
    serverName = "Andy's Development",
    characterLimit = 100,
    changeCharacterCommand = "changecharacter", -- this is the command to open the ui again and change your character.

    -- discord bot token for permissions
    DiscordToken = "OTAwODg1MDMxMDQ2Nzc0ODQ1.YXH0kQ.p5DRIbh5m9Ia5_tlMZdxkfgJjsI",
	GuildId = "872496972454592523", -- discord guild id

    -- role id for each role of the department in your discord. 0 Gives the role to everyone.
	roles = {
        ["ADMIN"] = "0", -- You can remove this if you don't want it but this should only be here for permisisons not as a department and it won't display as a department. This can be used for /setaop and other permissions.
		["CIV"] = "0", 
        ["SAHP"] = "0",
        ["LSPD"] = "0",
        ["BCSO"] = "0",
        ["LSFD"] = "0"
	},

    -- Money related
    payCommand = "pay", -- Command to transfer someone money from bank account.
    giveCommand = "give", -- Command to give someone close money from wallet.
    
    salaryAmount = 300, -- the daily amount that players will receive.
    salaryInterval = 24, -- every x minutes the player will receive the salaryAmount.
}