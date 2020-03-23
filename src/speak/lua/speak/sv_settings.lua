local settings = {}

settings.FAST_DL = false
settings.WORKSHOP_ID = "2030639821"

speak.tags:DefineForSteamID64(76561198058648898, {
    Color(205, 0, 205),
    "(VIP) :star2:"
})

speak.tags:UpdateClients()

return settings
