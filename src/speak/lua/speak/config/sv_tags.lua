-- [[ Chat Tags ]]
speak.tags:DefineForUserGroup("superadmin", {
    Color(29, 131, 225),
    "(Superadmin)"
})

speak.tags:DefineForUserGroup("admin", {
    Color(225, 29, 33),
    "(Admin)"
})

-- speak.tags:DefineForSteamID64(76561198058648898, {
--     Color(205, 0, 205),
--     "(VIP) :star2:"
-- })

speak.tags:UpdateClients()