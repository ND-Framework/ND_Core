config = {
    maxJailTime = 300, -- Max time in seconds that someone can jail another player.
    jailDistance = 90.0, -- How far can the player go from the Jail coordinates. If the player is further than the set amount they will be teleported back.

    jailCoords = {x = 1680.21, y = 2513.25, z = 44.56, h = 6.53},
    releaseCoords = {x = 1840.22, y = 2608.42, z = 45.58, h = 270.09},

    -- Where can players access it from.
    accessLocation = {
        {x = -450.17, y = 6012.62, z = 31.71}, -- Paleto Bay Sheriff's Office
        {x = 1853.57, y = 3690.74, z = 34.26}, -- Sandy Shores Sheriff's Office
        {x = 460.53, y = -988.84, z = 24.91} -- Mission Row PD
    },

    -- Departments that can access the jail tablet.
    accessDepartments = {
        "SAHP",
        "LSPD",
        "BCSO"
    },

    -- How close does the player have to be to the coordiantes to be able to open the tablet.
    accessDistance = 1.2,
}