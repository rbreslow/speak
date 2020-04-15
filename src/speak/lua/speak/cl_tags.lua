local tags = {}
tags.usergroups = {}
tags.players = {}

--- Define a chattag for a usergroup.
-- @param usergroup The usergroup for the tag to be applied to
-- @param tag The tag, in the format of chat.AddText() payload
function tags:DefineForUserGroup(usergroup, tag)
    IS.enforce_arg(1, 'DefineForUsergroup', 'string', type(usergroup))
    IS.enforce_arg(2, 'DefineForUsergroup', 'table', type(tag))

    self.usergroups[usergroup] = tag
end
  
--- Define a chattag for a steamid64.
-- @param usergroup The steamid64 for the tag to be applied to
-- @param tag The tag, in the format of chat.AddText() payload
function tags:DefineForSteamID64(steamid64, tag)
    IS.enforce_arg(1, 'DefineForSteamID64', 'number', type(steamid64))
    IS.enforce_arg(2, 'DefineForSteamID64', 'table', type(tag))

    self.players[steamid64] = tag
end
  

--- Retrieve a tag from a player object.
-- @param ply The player
function tags:Get(ply)
    IS.enforce_arg(1, 'Get', 'Player', type(ply))

    if self.players[tonumber(ply:SteamID64(), 10)] then
        return self.players[tonumber(ply:SteamID64(), 10)]
    end

    if self.usergroups[ply:GetUserGroup()] then
        return self.usergroups[ply:GetUserGroup()]
    end

    return {}
end

--- Retrieve a tag from a usergroup.
-- @param usergroup The usergroup
function tags:GetFromUserGroup(usergroup)
    IS.enforce_arg(1, 'GetFromUserGroup', 'string', type(usergroup))

    return self.usergroups[usergroup]
end

--- Retrieve a tag from a steamid64.
-- @param steamid64 The steamid64
function tags:GetFromSteamID64(steamid64)
    IS.enforce_arg(1, 'GetFromSteamID64', 'number', type(steamid64))

    return self.players[steamid64]
end

speak.tags = tags
