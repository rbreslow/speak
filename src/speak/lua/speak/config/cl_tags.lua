-- https://www.colorhexa.com
local COLOR_RED = Color(225, 29, 33)
local COLOR_GREEN = Color(131, 225, 29)
local COLOR_BLUE = Color(29, 131, 225)
local COLOR_MAGENTA = Color(225, 29, 131)

-- [[ Chat Tags ]]
speak.tags:DefineForUserGroup("superadmin", {
    COLOR_BLUE, "(Superadmin)"
})

speak.tags:DefineForUserGroup("admin", {
    COLOR_RED, "(Admin)"
})

-- https://steamid.io/lookup/garry -> 76561197960279927
speak.tags:DefineForSteamID64(76561197960279927, {
    COLOR_MAGENTA, "(VIP)"
})
