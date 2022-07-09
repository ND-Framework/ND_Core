-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

config = {
    shotSpotterDelay = 10, -- How long until the police are notified about the shooting (in seconds).
    shotSpotterTimer = 120, -- How long should the shot spotter stay on the map.
    shotSpotterCooldown = 30, -- How long until the shot spotter can be activated again.

    shotSpotterUsePostal = true, -- If you're using a postal script turn this to true.
    postalResourceName = "nearest-postal", -- the resource name of the postal script, this is used for the export.

    -- What departments should recieve the alerts.
    receiveAlerts = {
        "SAHP",
        "LSPD",
        "BCSO"
    },

    -- What weapons will not trigger the shot spotter.
    weaponBlackList = {
        "weapon_flaregun",
        "weapon_stungun_mp",
        "weapon_grenade",
        "weapon_bzgas",
        "weapon_molotov",
        "weapon_stickybomb",
        "weapon_proxmine",
        "weapon_snowball",
        "weapon_pipebomb",
        "weapon_ball",
        "weapon_smokegrenade",
        "weapon_flare",
        "weapon_petrolcan",
        "weapon_fireextinguisher",
        "weapon_hazardcan",
        "weapon_fertilizercan"
    },

    useRealisticShotSpotter = false, -- Enable this if you want the shot spotters to only be in the locations below. (default is in and around Los Santos)
    realisticShotSpotterLocations = {
        {x = 653.4214, y = -648.7440, z = 57.1897},
        {x = 1015.9837, y = -255.2573, z = 85.5857},
        {x = 329.9973, y = 288.9604, z = 120.1029},
        {x = -202.7689, y = -327.3490, z = 66.0497},
        {x = 31.3205, y = -875.2959, z = 31.4629},
        {x = 70.1372, y = -1718.3291, z = 34.2056},
        {x = 1196.9178, y = -1624.6641, z = 50.3403},
        {x = -852.9095, y = -1215.8782, z = 9.2463},
        {x = -932.7648, y = -448.8844, z = 42.9436},
        {x = -1713.6848, y = 478.4267, z = 130.3795},
        {x = -596.5602, y = 515.0753, z = 109.675},
        {x = 716.6274, y = -1958.7434, z = 44.7564}
    },

    testing = false -- If you're adding zones and want to test them easier, set this to true. Otherwise keep it false.
}

function notify(message)
	BeginTextCommandThefeedPost("STRING")
	AddTextComponentSubstringPlayerName(message)
	EndTextCommandThefeedPostTicker(0,1)
end
