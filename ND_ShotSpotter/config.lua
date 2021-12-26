-- For support join my discord: https://discord.gg/Z9Mxu72zZ6

config = {
    shotSpotterDelay = 5, -- delay (in seconds) when cops will receive a notification after there has been a shooting.
    shotSpotterTimer = 25, -- How long should the shot spotter stay on the map.
    shotSpotterCooldown = 10, -- Cooldown for the next time a player can trigger it again.
    shotSpotterUsePostal = false, -- if you're using the nearest postal script turn this to true.

    -- This is the departments that will receive the shot spotter.
    LEODepartments = {
        "SAHP",
        "LSPD",
        "BCSO"
    }
}