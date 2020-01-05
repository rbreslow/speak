Tags = {}
Tags.ranks = {}
Tags.clients = {}

net.Receive('tags.update', function(_)
    local obj = net.ReadTable()

    -- Update our local tag store
    Tags.ranks = obj.ranks
    Tags.clients = obj.clients
end)

--[[ PUBLIC: ]]

--- Retrieve a tag from a player object.
-- @param client The player
function Tags:Get(client)
    IS.enforce_arg(1, 'Get', 'Player', type(client))

    if Tags.clients[tonumber(client:SteamID64(), 10)] then
        return Tags.clients[tonumber(client:SteamID64(), 10)]
    end

    if Tags.ranks[client:GetUserGroup()] then
        return Tags.ranks[client:GetUserGroup()]
    end

    return {}
end

--- Retrieve a tag from a usergroup.
-- @param usergroup The usergroup
function Tags:GetFromUserGroup(usergroup)
    IS.enforce_arg(1, 'GetFromUserGroup', 'string', type(usergroup))

    if Tags.ranks[usergroup] then
        return Tags.ranks[usergroup]
    end
end

--- Retrieve a tag from a steamid64.
-- @param steamid64 The steamid64
function Tags:GetFromSteamID64(steamid64)
    IS.enforce_arg(1, 'GetFromSteamID64', 'number', type(steamid64))

    if Tags.clients[steamid64] then
        return Tags.clients[steamid64]
    end
end
