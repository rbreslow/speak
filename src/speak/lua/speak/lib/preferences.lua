--[[
   Preferences Library
   Copyright 2016 Rocky Breslow

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
]]

if CLIENT then
    local Preferences = {}
    Preferences.prototype = {}
    Preferences.__index = Preferences.prototype

    Preferences.policies = {}

    setmetatable(Preferences, {
        --- Constructor for Preferences class.
        -- @param self Instance
        -- @param packageIdentifier The identitifier for preferences defined within this class
        __call = function(self, packageIdentifier)
            IS.enforce_arg(1, '__call', 'table', type(self))
            IS.enforce_arg(2, '__call', 'string', type(packageIdentifier))

            -- Instantiate a Preferences
            local instance = setmetatable({packageIdentifier = packageIdentifier, prefs = {}}, self)

            instance:_SetupHooks()

            return instance
        end
    })

    --[[ PRIVATE: ]]

    -- Make sure we take action on policy update
    function Preferences.prototype:_SetupHooks()
        hook.Add('preferences.policyupdate', self.packageIdentifier, function()
            if not Preferences.policies[self.packageIdentifier] then return end

            for name, _ in pairs(Preferences.policies[self.packageIdentifier]) do
                self:_FireCallback(name)
            end
        end)
    end
    function Preferences.prototype:_GetFullyQualified(name)
        IS.enforce_arg(1, '_GetFullyQualified', 'string', type(name))

        return self.packageIdentifier .. '_' .. name
    end
    function Preferences.prototype:_EnforceValidPreference(name, type, method)
        if not IS.is(self.prefs[name], 'table') or not IS.is(self.prefs[name].cvar, 'ConVar') then
            error(string.format('bad argument #%d to \'%s\' (%s preference %s does not exist)', 1, method, type, name))
        end

        if not self.prefs[name].type == type then
            error(string.format('bad argument #%d to \'%s\' (cannot manipulate preference defined as %s)', 1, method, self.prefs[name].type))
        end
    end
    function Preferences.prototype:_EnforcePreferenceExistance(name, method)
        -- We're checking to make sure the ConVar we have internally is valid
        if not IS.is(self.prefs[name], 'table') or not IS.is(self.prefs[name].type, 'string') or not IS.is(self.prefs[name].cvar, 'ConVar') then
            error(string.format('bad argument #%d to \'%s\' (preference %s does not exist)', 1, method, name))
        end
    end
    function Preferences.prototype:_FireCallback(name)
        IS.enforce_arg(1, '_FireCallback', 'string', type(name))

        self:_EnforcePreferenceExistance(name, '_FireCallback')

        self.prefs[name].cb(self:Get(name))
    end

    --[[ PUBLIC: ]]

    --- Fires all callbacks in defined preferences. Useful for initializing values.
    function Preferences.prototype:FireAllCallbacks()
        for name, obj in pairs(self.prefs) do
            self:_FireCallback(name)
        end
    end

    --- Define a boolean preference for use later.
    -- @param name The name of the boolean preference
    -- @param default The default value of the boolean preference
    -- @param cb A callback passed the new value after a preference is changed
    function Preferences.prototype:DefineBoolean(name, default, cb)
        IS.enforce_arg(1, 'DefineBoolean', 'string', type(name))
        IS.enforce_arg(2, 'DefineBoolean', 'boolean', type(default))
        IS.enforce_arg(3, 'DefineBoolean', 'function', type(cb))

        -- Store our ConVar internally with a type to let us enforce this
        self.prefs[name] = {type = 'boolean', cvar = CreateClientConVar(self:_GetFullyQualified(name), default and 1 or 0, true, false), cb = cb, doCb = true}

        cvars.RemoveChangeCallback(self:_GetFullyQualified(name), 'a')

        -- If the ConVar isn't 0 or 1 we want to return to the previous value and void the callback
        cvars.AddChangeCallback(self:_GetFullyQualified(name), function(_, oldValue, newValue)
            if tonumber(newValue, 10) == nil or tonumber(newValue, 10) > 1 or tonumber(newValue, 10) < 0 then
                self.prefs[name].doCb = false
                self.prefs[name].cvar:SetString(oldValue)
            else
                if self.prefs[name].doCb then
                    if not self:IsEnforced(name) then
                        self.prefs[name].cb(self.prefs[name].cvar:GetBool())
                    end
                else
                    self.prefs[name].doCb = true
                end
            end
        end, 'a')
    end

    --- Define a number preference for use later.
    -- @param name The name of the number preference
    -- @param default The default value of the number preference
    -- @param cb A callback passed the new value after a preference is changed
    function Preferences.prototype:DefineNumber(name, default, cb)
        IS.enforce_arg(1, 'DefineNumber', 'string', type(name))
        IS.enforce_arg(2, 'DefineNumber', 'number', type(default))
        IS.enforce_arg(3, 'DefineNumber', 'function', type(cb))

        -- Store our ConVar internally with a type to let us enforce this
        self.prefs[name] = {type = 'number', cvar = CreateClientConVar(self:_GetFullyQualified(name), tostring(default), true, false), cb = cb, doCb = true}

        cvars.RemoveChangeCallback(self:_GetFullyQualified(name), 'a')

        -- If the ConVar isn't a number we want to return to the previous value and void the callback
        cvars.AddChangeCallback(self:_GetFullyQualified(name), function(_, oldValue, newValue)
            if tonumber(newValue, 10) == nil then
                self.prefs[name].doCb = false
                self.prefs[name].cvar:SetString(oldValue)
            else
                if self.prefs[name].doCb then
                    if not self:IsEnforced(name) then
                        self.prefs[name].cb(self.prefs[name].cvar:GetFloat())
                    end
                else
                    self.prefs[name].doCb = true
                end
            end
        end, 'a')
    end

    --- Define a string preference for use later.
    -- @param name The name of the string preference
    -- @param default The default value of the string preference
    -- @param cb A callback passed the new value after a preference is changed
    function Preferences.prototype:DefineString(name, default, cb)
        IS.enforce_arg(1, 'DefineString', 'string', type(name))
        IS.enforce_arg(2, 'DefineString', 'string', type(default))
        IS.enforce_arg(3, 'DefineString', 'function', type(cb))

        -- Store our ConVar internally with a type to let us enforce this, doesn't matter much for string
        self.prefs[name] = {type = 'string', cvar = CreateClientConVar(self:_GetFullyQualified(name), default, true, false), cb = cb}

        cvars.RemoveChangeCallback(self:_GetFullyQualified(name), 'a')
        cvars.AddChangeCallback(self:_GetFullyQualified(name), function(_, oldValue, newValue)
            if not self:IsEnforced(name) then
                self.prefs[name].cb(self.prefs[name].cvar:GetString())
            end
        end, 'a')
    end

    --- Define a table preference for use later.
    -- @param name The name of the table preference
    -- @param default The default value of the table preference
    -- @param cb A callback passed the new value after a preference is changed
    function Preferences.prototype:DefineTable(name, default, cb)
        IS.enforce_arg(1, 'DefineTable', 'string', type(name))
        IS.enforce_arg(2, 'DefineTable', 'table', type(default))
        IS.enforce_arg(3, 'DefineTable', 'function', type(cb))

        -- Function to test for validity
        local function valid(value)
            return util.JSONToTable(value)
        end

        -- If the ConVar isn't a table we want to return to the previous value and void the callback
        self.prefs[name] = {type = 'table', cvar = CreateClientConVar(self:_GetFullyQualified(name), util.TableToJSON(default), true, false), cb = cb, doCb = true }

        -- If the existing ConVar is corrupt we'll reset to default
        if not valid(self.prefs[name].cvar:GetString()) then
            self.prefs[name].cvar:SetString(util.TableToJSON(default))
        end

        cvars.RemoveChangeCallback(self:_GetFullyQualified(name), 'a')

        -- If the ConVar isn't a table we want to return to the previous value and void the callback
        cvars.AddChangeCallback(self:_GetFullyQualified(name), function(_, oldValue, newValue)
            if not valid(newValue) then
                self.prefs[name].doCb = false
                self.prefs[name].cvar:SetString(oldValue)
            else
                if self.prefs[name].doCb then
                    if not self:IsEnforced(name) then
                        self.prefs[name].cb(util.JSONToTable(self.prefs[name].cvar:GetString()))
                    end
                else
                    self.prefs[name].doCb = true
                end
            end
        end, 'a')
    end

    --- Set a boolean preference to a boolean value.
    -- @param name The name of the boolean preference
    -- @param value The boolean value to set the boolean preference to
    function Preferences.prototype:SetBoolean(name, value)
        IS.enforce_arg(1, 'SetBoolean', 'string', type(name))
        IS.enforce_arg(2, 'SetBoolean', 'boolean', type(value))

        self:_EnforceValidPreference(name, 'boolean', 'SetBoolean')

        self.prefs[name].cvar:SetBool(value)
    end

    --- Set a number preference to a number value.
    -- @param name The name of the number preference
    -- @param value The number value to set the number preference to
    function Preferences.prototype:SetNumber(name, value)
        IS.enforce_arg(1, 'SetNumber', 'string', type(name))
        IS.enforce_arg(2, 'SetNumber', 'number', type(value))

        self:_EnforceValidPreference(name, 'number', 'SetNumber')

        self.prefs[name].cvar:SetFloat(value)
    end

    --- Set a string preference to a string value.
    -- @param name The name of the string preference
    -- @param value The string value to set the string preference to
    function Preferences.prototype:SetString(name, value)
        IS.enforce_arg(1, 'SetString', 'string', type(name))
        IS.enforce_arg(2, 'SetString', 'string', type(value))

        self:_EnforceValidPreference(name, 'string', 'SetString')

        self.prefs[name].cvar:SetString(value)
    end

    --- Set a table preference to a table value.
    -- @param name The name of the table preference
    -- @param value The table value to set the table preference to
    function Preferences.prototype:SetTable(name, value)
        IS.enforce_arg(1, 'SetTable', 'string', type(name))
        IS.enforce_arg(2, 'SetTable', 'table', type(value))

        self:_EnforceValidPreference(name, 'table', 'SetTable')

        self.prefs[name].cvar:SetString(util.TableToJSON(value))
    end

    --- Retrieve a preference's value by name.
    -- @param name The name of the preference
    function Preferences.prototype:Get(name)
        IS.enforce_arg(1, 'Get', 'string', type(name))

        self:_EnforcePreferenceExistance(name, 'Get')

        -- If the policy is enforced by the server we'll return the enforced preference
        if Preferences.policies[self.packageIdentifier] and Preferences.policies[self.packageIdentifier][name] then
            return Preferences.policies[self.packageIdentifier][name]
        end

        -- Dynamic typing
        if self.prefs[name].type ==  'boolean' then
            return self.prefs[name].cvar:GetBool()
        elseif self.prefs[name].type ==  'number' then
            return self.prefs[name].cvar:GetFloat()
        elseif self.prefs[name].type ==  'string' then
            return self.prefs[name].cvar:GetString()
        elseif self.prefs[name].type == 'table' then
            return util.JSONToTable(self.prefs[name].cvar:GetString())
        else
            error(string.format('bad argument #%d to \'%s\' (type %s for preference %s not valid)', 1, 'Get', self.prefs[name].type, name))
        end
    end

    --- Check if a preference or multiple preferences are enforced by a policy or policies.
    -- @param ... The name of the preference. (varargs)
    function Preferences.prototype:IsEnforced(...)
        local tab = {... }

        for i=1, #tab do
            if not Preferences.policies[self.packageIdentifier] or not Preferences.policies[self.packageIdentifier][tab[i]] then
                return false
            end
        end

        return true
    end

    net.Receive('preferences.enforcepolicy', function(_)
        local obj = net.ReadTable()

        -- Update our local policy store
        Preferences.policies = obj

        -- Alert
        hook.Run('preferences.policyupdate')
    end)

    return Preferences
end

if SERVER then
    util.AddNetworkString('preferences.enforcepolicy')

    local Policy = {}
    Policy.prototype = {}
    Policy.__index = Policy.prototype

    setmetatable(Policy, {
        --- Constructor for Policy class.
        -- @param self Instance
        -- @param packageIdentifier The identitifier for preferences defined on the client
        __call = function(self, packageIdentifier)
            IS.enforce_arg(1, '__call', 'table', type(self))
            IS.enforce_arg(2, '__call', 'string', type(packageIdentifier))

            -- Instantiate a Policy
            local instance = setmetatable({packageIdentifier = packageIdentifier, policies = {}}, self)

            instance:_SetupHooks()

            return instance
        end
    })

    --[[ PRIVATE: ]]
    function Policy.prototype:_SetupHooks()
        -- Update new clients' local policy store.
        hook.Add('PlayerInitialSpawn', self.packageIdentifier, function(client)
            self:UpdateClient(client)
        end)
    end

    --[[ PUBLIC: ]]

    --- Enforce a preference to be a specific value.
    -- @param name The name of the preference
    -- @param value The value to enforce
    function Policy.prototype:Enforce(name, value)
        IS.enforce_arg(1, 'Enforce', 'string', type(name))

        self.policies[name] = value
    end

    --- Unenforce a preference's value.
    -- @param name The name of the preference
    function Policy.prototype:Unenforced(name)
        IS.enforce_arg(1, 'Unenforced', 'string', type(name))

        self.policies[name] = nil
    end

    --- Update specific client's local policy store.
    -- @param client The client to update
    function Policy.prototype:UpdateClient(client)
        IS.enforce_arg(1, 'UpdateClient', 'Player', type(client))
                  
        local obj = {}
        obj[self.packageIdentifier] = {}

        for name, value in pairs(self.policies) do
            obj[self.packageIdentifier][name] = value
        end

        net.Start('preferences.enforcepolicy')
        net.WriteTable(obj)
        net.Send(client)
    end

    --- Update all clients' local policy store.
    function Policy.prototype:UpdateClients()
        local obj = {}
        obj[self.packageIdentifier] = {}

        for name, value in pairs(self.policies) do
            obj[self.packageIdentifier][name] = value
        end

        net.Start('preferences.enforcepolicy')
        net.WriteTable(obj)
        net.Broadcast()
    end

    return Policy
end
