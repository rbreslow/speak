I18n = include "lib/i18n.lua"

local function getGameLocale()
  return GetConVar("gmod_language"):GetString():sub(1, 2)
end

local i18n = I18n(getGameLocale())

cvars.AddChangeCallback("gmod_language", function(_, _, _)
  i18n:SetLocale(getGameLocale())

  -- refresh stale settings strings
  speak.settingsView:Remove()
  speak.settingsView = vgui.Create("speak.Settings")
end)

i18n:Load({
  en = {
    SAY = "SAY",
    SAY_TEAM = "SAY TEAM",
    
    AVATAR_STYLE = "Avatar Style",
    STEAM_AVATAR = "Steam Avatar",
    PLAYER_MODEL = "Player Model",
    TAG_POSITION = "Tag Position",
    LEFT = "Left",
    RIGHT = "Right",
    ADMIN = "Admin",
    DISPLAY_OPTIONS = "Display Options",
    DISPLAY_TIMESTAMPS = "Display timestamps in console log",
    HOUR = "Show 24-hour times (16:00 rather than 4:00 PM)",
    EMOJI_STYLE = "Emoji Style",
    APPLE = "Apple/International Style",
    GOOGLE = "Google Style",
    TWITTER = "Twitter Style",
    FACEBOOK = "Facebook Style",
    MESSENGER = "Messenger Style",
    
    MESSAGE_DISPLAY = "Message Display",
    MESSAGE_DISPLAY_POPOVER = "Tweak message display settings.",
    STYLE = "Style",
    STYLE_POPOVER = "Style the chatbox.",
    ABOUT = "About",
    ABOUT_POPOVER = "Information and attributions.",
    
    EMOJI_ENABLED = "Emoji Enabled",
    AVATARS_ENABLED = "Avatars Enabled",
    
    SOUNDS = "Sounds",
    DURATION = "Duration",
    DO_NOT_DISTURB = "Do Not Disturb",
    NOTIFICATIONS = "Notifications",
    NOTIFICATIONS_POPOVER = "Adjust notification settings.",
    
    TIMESTAMPS = "Timestamps",
    COLOR = "Color",
    SIZE = "Size",
    FONT = "Font",
    NAME = "Name",
    WEIGHT = "Weight",
    BORDER = "Border",
    TYPE = "Type",
    DROP_SHADOW = "Drop Shadow",
    STROKE = "Stroke",
    BLUR = "Blur",
    OPACITY = "Opacity",
  },
  
  sv = {
    SAY = "TALA",
    SAY_TEAM = "TALA LAG",
    
    AVATAR_STYLE = "Porträttyp",
    STEAM_AVATAR = "Din Steam Avatar",
    PLAYER_MODEL = "Din Spelarmodell",
    TAG_POSITION = "Etikettsposition",
    LEFT = "Vänster",
    RIGHT = "Höger",
    ADMIN = "Admin",
    DISPLAY_OPTIONS = "Visningsinställningar",
    DISPLAY_TIMESTAMPS = "Visa tidsstämplar i konsollen",
    HOUR = "Använd 24-timmars klocka",
    EMOJI_STYLE = "Emojistil",
    APPLE = "Apple/Internationell",
    GOOGLE = "Google",
    TWITTER = "Twitter",
    FACEBOOK = "Facebook",
    MESSENGER = "Messenger",
    
    MESSAGE_DISPLAY = "Meddelanden",
    MESSAGE_DISPLAY_POPOVER = "Konfigurera meddelandensinställningar.",
    STYLE = "Stil",
    STYLE_POPOVER = "Ändra utseendet av chatten.",
    ABOUT = "Om",
    ABOUT_POPOVER = "Information.",
    
    EMOJI_ENABLED = "Aktivera Emojis",
    AVATARS_ENABLED = "Aktivera Porträttbilder",
    
    SOUNDS = "Ljud",
    DURATION = "Varaktighet",
    DO_NOT_DISTURB = "Stör Ej",
    NOTIFICATIONS = "Aviseringar",
    NOTIFICATIONS_POPOVER = "Ändra aviseringsinställningar.",
    
    TIMESTAMPS = "Tidsstämplar",
    COLOR = "Färg",
    SIZE = "Storlek",
    FONT = "Typsnitt",
    NAME = "Namn",
    WEIGHT = "Tjocklek",
    BORDER = "Ram",
    TYPE = "Typ",
    DROP_SHADOW = "Skuggning",
    STROKE = "Linje",
    BLUR = "Utsuddning",
    OPACITY = "Opacitet",
  },
  
  fr = {
    SAY = "DIRE",
    SAY_TEAM = "DIRE (ALLIÉ)",
    
    AVATAR_STYLE = "Style d'avatar",
    STEAM_AVATAR = "Avatar Steam",
    PLAYER_MODEL = "Modèle de joueur",
    TAG_POSITION = "Position de marque",
    LEFT = "À gauche",
    RIGHT = "À droit",
    ADMIN = "Admin",
    DISPLAY_OPTIONS = "Option d'affichage",
    DISPLAY_TIMESTAMPS = "Afficher les horodatages dans le journal de la console",
    HOUR = "Afficher le temps de 24 heures (ex. 14:00)",
    EMOJI_STYLE = "Style d'emoji",
    APPLE = "Style Apple/International",
    GOOGLE = "Style Google",
    TWITTER = "Style Twitter",
    FACEBOOK = "Style Facebook",
    MESSENGER = "Style Messenger",
    
    MESSAGE_DISPLAY = "Affichage de messages",
    MESSAGE_DISPLAY_POPOVER = "Modifier les paramètres d'affichage de message.",
    STYLE = "Style",
    STYLE_POPOVER = "Style de la boîte de discussion.",
    ABOUT = "À propos",
    ABOUT_POPOVER = "Information et attributions.",
    
    EMOJI_ENABLED = "Emoji Activés",
    AVATARS_ENABLED = "Avatars Activés",
    
    SOUNDS = "Acoustique",
    DURATION = "Durée",
    DO_NOT_DISTURB = "Ne Pas Déranger",
    NOTIFICATIONS = "Notifications",
    NOTIFICATIONS_POPOVER = "Ajuster les paramètres de notification.",
    
    TIMESTAMPS = "Horodatages",
    COLOR = "Couleur",
    SIZE = "Grandeur",
    FONT = "Police",
    NAME = "Nom",
    WEIGHT = "Poids",
    BORDER = "Bordure",
    TYPE = "Type",
    DROP_SHADOW = "Ombre portée",
    STROKE = "Coup",
    BLUR = "Flou",
    OPACITY = "Opacité",
  }
})

return i18n
