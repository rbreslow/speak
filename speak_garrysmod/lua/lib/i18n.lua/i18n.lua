--[[
   i18n Library
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

if SERVER then
    AddCSLuaFile()
    AddCSLuaFile('is.lua/is.lua')
end

if CLIENT then
    include('is.lua/is.lua')

    I18n = {}
    I18n.prototype = {}
    I18n.__index = I18n.prototype

    setmetatable(I18n, {
        --- Constructor for I18n class.
        -- @param self Instance
        __call = function(self, locale)
            IS.enforce_arg(1, '__call', 'table', type(self))
            IS.enforce_arg(2, '__call', 'string', type(locale))

            -- Instantiate an I18n
            return setmetatable({
                _locale = locale,
                _fallbackLocale = 'en',
                _locales = {}
            }, self)
        end
    })

    --[[ PUBLIC: ]]

    --- Retrieve the current working ISO 3166-1 locale.
    function I18n.prototype:GetLocale()
            return self._locale
    end

    --- Retrieve the current working ISO 3166-1 fallback locale.
    function I18n.prototype:GetFallbackLocale()
        return self._fallbackLocale
    end

    --- Set the current working locale.
    -- @param locale The ISO 3166-1 alpha-2 value
    function I18n.prototype:SetLocale(locale)
        IS.enforce_arg(1, 'SetLocale', 'string', type(locale))

        self._locale = locale
    end

    --- Set the current working fallback locale.
    -- @param fallbackLocale The ISO 3166-1 alpha-2 value
    function I18n.prototype:SetFallbackLocale(fallbackLocale)
        IS.enforce_arg(1, 'SetFallbackLocale', 'string', type(fallbackLocale))

        self._fallbackLocale = fallbackLocale
    end

    --- Translates a key in the current locale, falls back to the fallback locale of no translation found.
    -- @param key Key to translate
    -- @param ... Formatting options
    function I18n.prototype:Translate(key, ...)
        IS.enforce_arg(1, 'Translate', 'string', type(key))

        if self._locales[self._locale] == nil or self._locales[self._locale][key] == nil then
            if self._locales[self._fallbackLocale] == nil or self._locales[self._fallbackLocale][key] == nil then
                return ''
            end

            return string.format(self._locales[self._fallbackLocale][key], ...)
        end

        return string.format(self._locales[self._locale][key], ...)
    end

    --- Create a new key in the current locale.
    -- @param key Key to translate
    -- @param value Value to translate key to
    function I18n.prototype:Set(key, value)
        IS.enforce_arg(1, 'Set', 'string', type(key))
        IS.enforce_arg(2, 'Set', 'string', type(value))

        if self._locales[self._locale] == nil then
           self._locales[self._locale] = {}
        end

        self._locales[self._locale][key] = value
    end

    function I18n.prototype:Load(data)
        IS.enforce_arg(1, 'Load', 'table', type(data))

        for k,v in pairs(data) do
            self._locales[k] = self._locales[k] and self._locales[k] or {}

            for k2,v2 in pairs(v) do
               self._locales[k][k2] = v2
            end
        end
    end
end
