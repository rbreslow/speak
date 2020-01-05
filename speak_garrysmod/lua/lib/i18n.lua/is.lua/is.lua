-- is.lua - Type checking for Lua
-- Copyright 2016 Jack Wilsdon
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

IS = {}

--- Throw an error caused by invalid arguments.
-- @param count The index of the invalid argument.
-- @param fname The name of the function that the invalid argument was passed to.
-- @param extype The expected type being passed.
-- @param actype The actual type passed.
function IS.arg_error(count, fname, extype, actype)
    if type(count) ~= 'number' then
        IS.arg_error(1, 'arg_error', 'number', type(count))
    end

    if type(fname) ~= 'string' then
        IS.arg_error(2, 'arg_error', 'string', type(fname))
    end

    if type(extype) ~= 'string' then
        IS.arg_error(3, 'arg_error', 'string', type(extype))
    end

    if type(actype) ~= 'string' then
        IS.arg_error(4, 'arg_error', 'string', type(actype))
    end

    local msg = string.format('bad argument #%d to \'%s\' (%s expected, got %s)', count, fname, extype, actype)
    error(msg)
end

--- Throw an argument error if two types do not match.
-- @param count The index of the invalid argument.
-- @param fname The name of the function that the invalid argument was passed to.
-- @param extype The expected type being passed.
-- @param actype The actual type passed.
function IS.enforce_arg(count, fname, extype, actype)
    if type(count) ~= 'number' then
        IS.arg_error(1, 'enforce_arg', 'number', type(count))
    end

    if type(fname) ~= 'string' then
        IS.arg_error(2, 'enforce_arg', 'string', type(fname))
    end

    if type(extype) ~= 'string' then
        IS.arg_error(3, 'enforce_arg', 'string', type(extype))
    end

    if type(actype) ~= 'string' then
        IS.arg_error(4, 'enforce_arg', 'string', type(actype))
    end

    if extype ~= actype then
        IS.arg_error(count, fname, extype, actype)
    end
end

--- Throw an argument error if all of the values in a table do not match the type provided.
-- @param count The index of the invalid argument.
-- @param fname The name of the function that the invalid argument was passed to.
-- @param extype The expected type being passed.
-- @param tbl The table of valuess to compare.
function IS.enforce_arg_table(count, fname, extype, tbl)
    if type(count) ~= 'number' then
        IS.arg_error(1, 'enforce_all_values', 'number', type(count))
    end

    if type(fname) ~= 'string' then
        IS.arg_error(2, 'enforce_all_values', 'string', type(fname))
    end

    if type(extype) ~= 'string' then
        IS.arg_error(3, 'enforce_all_values', 'string', type(extype))
    end

    if type(tbl) ~= 'table' then
        IS.arg_error(4, 'enforce_all_values', 'table', type(tbl))
    end

    for _, v in pairs(tbl) do
        if not IS.is(v, extype) then
            IS.arg_error(count, fname, extype, type(v))
        end
    end
end

--- Check whether obj is of type typename.
-- @param obj The object to check.
-- @param typename The type(s) to check against.
-- @return Whether obj is of type typename.
function IS.is(obj, typename)
    if type(typename) ~= 'string' and type(typename) ~= 'table' then
        IS.arg_error(2, 'is', 'string or table', type(typename))
    end

    if type(typename) == 'table' then
        for _, v in pairs(typename) do
            if type(v) ~= 'string' then
                IS.arg_error(2, 'is', 'string', type(v))
            end

            if type(obj) == v then return true end
        end
    else
        if type(obj) == typename then return true end
    end

    return false
end

--- Check whether all values are of type typename.
-- @param tbl The table to check.
-- @param typename The type(s) to check against.
-- @return Whether all of tbl's values are of type typename.
function IS.is_all_values(tbl, typename)
    if type(tbl) ~= 'table' then
        IS.arg_error(1, 'is_all_values', 'table', type(tbl))
    end

    if type(typename) ~= 'string' and type(typename) ~= 'table' then
        IS.arg_error(2, 'is_all_values', 'string or table', type(typename))
    end

    for _, v in pairs(tbl) do
        if not IS.is(v, typename) then return false end
    end

    return true
end
