# preferences.lua
GLua library for easily defining preferences and enforcing preferences serverside

```lua
local preferences = Preferences('myaddon')

preferences:DefineBoolean('feature_enabled', true, function(value)
    print(string.format('feature_enabled changed to: \'%s\'', value))
end)

preferences:SetBoolean('feature_enabled', true) -- Prints: 'feature_enabled changed to: true'

preferences:Get('feature_enabled') -- Returns: (boolean) true
```

## Features
* Stores tables
* Built around ConVars
* Strict type enforcement
* Enforce values on the server

## Installation
Clone the repository into your Garry's Mod addon/gamemode's Lua folder.

On the server, `include` and `AddCSLuaFile` the preferences library.
```lua
    include('path/to/library/preferences.lua')
    AddCSLuaFile('path/to/library/preferences.lua')
```

On the client,  `include` the preferences library.
```lua
    include('path/to/library/preferences.lua')
```