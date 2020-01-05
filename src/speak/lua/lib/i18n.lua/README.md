# i18n.lua
GLua library for easily handling localization

```lua
local i18n = I18n('en')

i18n:Load({
    en = {
        HELLO_WORLD = "Hello world"
    },
    fr = {
        HELLO_WORLD = "Bonjour monde"
    },
    ru = {
        HELLO_WORLD = "Здравствулте мир"
    }
})

-- We constructed our instance with 'en' as the current working locale
print(i18n:Translate("HELLO_WORLD")) -- Returns: Hello world

i18n:SetLocale("fr")
print(i18n:Translate("HELLO_WORLD")) -- Returns: Bonjour monde

i18n:SetLocale("ru")
print(i18n:Translate("HELLO_WORLD")) -- Returns: Здравствулте мир
```

## Installation
Clone the repository into your Garry's Mod addon/gamemode's Lua folder.

On the server, `include` the i18n library.
```lua
    include('path/to/library/i18n.lua')
```

On the client, `include` the i18n library.
```lua
    include('path/to/library/i18n.lua')
```