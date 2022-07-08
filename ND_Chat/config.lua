config = {
    ["/me"] = true,
    ["/gme"] = true,
    ["/ooc"] = true,
    ["/twt"] = true,
    ["/darkweb"] = {
        enabled = true,
        canNotSee = {
            "LSPD",
            "BCSO",
            "SAHP",
            "LSFD"
        }
    },
    ["/911"] = {
        enabled = true,
        callTo = {
            "LSPD",
            "BCSO",
            "SAHP",
            "LSFD"
        }
    }
}