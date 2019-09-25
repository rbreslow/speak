util.AddNetworkString('tags.update')

if Tags then
  Tags:UpdateClients()
end

Tags = {}
Tags.ranks = {}
Tags.clients = {}

hook.Add('PlayerInitialSpawn', 'tags.playerinitialspawn', function(client)
  Tags:UpdateClient(client)
end)

--[[ PUBLIC: ]]

--- Define a chattag for a usergroup.
-- @param usergroup The usergroup for the tag to be applied to
-- @param tag The tag, in the format of chat.AddText() payload
function Tags:DefineForUserGroup(usergroup, tag)
  IS.enforce_arg(1, 'DefineForUsergroup', 'string', type(usergroup))
  IS.enforce_arg(2, 'DefineForUsergroup', 'table', type(tag))
  
  self.ranks[usergroup] = tag
end

--- Define a chattag for a steamid64.
-- @param usergroup The steamid64 for the tag to be applied to
-- @param tag The tag, in the format of chat.AddText() payload
function Tags:DefineForSteamID64(steamid64, tag)
  IS.enforce_arg(1, 'DefineForSteamID64', 'number', type(steamid64))
  IS.enforce_arg(2, 'DefineForSteamID64', 'table', type(tag))
  
  self.clients[steamid64] = tag
end

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

--- Remove a chattag for a usergroup.
-- @param usergroup The usergroup for the tag to be cleared from
function Tags:RemoveFromUserGroup(usergroup)
  IS.enforce_arg(1, 'RemoveFromUsergroup', 'string', type(usergroup))
  
  self.ranks[usergroup] = nil
end

--- Remove a chattag for a usergroup.
-- @param usergroup The usergroup for the tag to be cleared from
function Tags:RemoveFromSteamID64(steamid64)
  IS.enforce_arg(1, 'RemoveFromSteamID64', 'number', type(steamid64))
  
  self.clients[steamid64] = nil
end

--- Update specific client's local tag store.
-- @param client The client to update
function Tags:UpdateClient(client)
  IS.enforce_arg(1, 'UpdateClient', 'Player', type(client))
  
  local obj = {}
  obj.ranks = self.ranks
  obj.clients = self.clients
  
  net.Start('tags.update')
  net.WriteTable(obj)
  net.Send(client)
end

--- Update all clients' local tag store.
function Tags:UpdateClients()
  local obj = {}
  obj.ranks = self.ranks
  obj.clients = self.clients
  
  net.Start('tags.update')
  net.WriteTable(obj)
  net.Broadcast()
end
