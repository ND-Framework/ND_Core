-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

config = {
    changeCharacterCommand = "changecharacter", -- this is the command to open the ui again and change your character.
    enableAppearance = false, -- you need to install fivem-appearance
    characterSelectionAopDisplay = false,
    aop = function ()
        return "AOP: " .. exports["SimpleHUD"]:getAOP() -- exports["ModernHUD"]:getAOP()
    end,

    -- set your backgrounds, if you have more than 1 then it will randomly change everytime you open the ui.
    backgrounds = {
        "https://i.imgur.com/E51ckFx.png", -- Credits: Fuzzman270#0270
        "https://i.imgur.com/SeZD7TP.png", -- Credits: Fuzzman270#0270
        "https://i.imgur.com/ZWKfYD9.png" -- Credits: 2XRondo#6374
    },

    departments = {
        ["CIV"] = {"0"},
        ["SAHP"] = {"0"},
        ["LSPD"] = {"0"},
        ["BCSO"] = {"872921520719142932"},
        ["LSFD"] = {"872921520719142932"}
    },

    -- set up the spawn buttons for each department.
    spawns = {
        ["CIV"] = {
            {x = -102.78, y = 6336.28, z = 31.49, name = "Dream View Motel (Paleto Bay)"},
            {x = 343.53, y = 2636.94, z = 43.94, name = "Eastern Motel (Sandy Shores)"},
            {x = 196.96, y = -934.54, z = 29.69, name = "Legion Square"},
            {x = -1616.69, y = -1073.81, z = 12.15, name = "Del Perro Pier"},
            {x = -1039.65, y = -2741.02, z = 12.89, name = "LSIA"}
        },
        ["SAHP"] = {
            {x = -447.2, y = 6009.4, z = 30.72, name = "Paleto Bay Sheriff"},
            {x = 1849.4, y = 3688.6, z = 33.27, name = "Sandy Shores Sheriff"},
            {x = 437.6, y = -986.6, z = 29.69, name = "Mission Row PD"}
        },
        ["LSPD"] = {
            {x = -447.2, y = 6009.4, z = 30.72, name = "Paleto Bay Sheriff"},
            {x = 1849.4, y = 3688.6, z = 33.27, name = "Sandy Shores Sheriff"},
            {x = 437.6, y = -986.6, z = 29.69, name = "Mission Row PD"}
        },
        ["BCSO"] = {
            {x = -447.2, y = 6009.4, z = 30.72, name = "Paleto Bay Sheriff"},
            {x = 1849.4, y = 3688.6, z = 33.27, name = "Sandy Shores Sheriff"},
            {x = 437.6, y = -986.6, z = 29.69, name = "Mission Row Police "}
        },
        ["LSFD"] = {
            {x = -384.07, y = 6117.9, z = 30.48, name = "Fire Station No1 (Paleto Bay)"},
            {x = 1691.5, y = 3597.95, z = 34.56, name = "Fire Station No2 (Sandy Shores)"},
            {x = 1194.71, y = -1474.14, z = 33.86, name = "Fire Station No7 (Los Santos)"}
        },
    }
}