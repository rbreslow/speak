--
-- log.lua
--
-- Copyright (c) 2016 rxi
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.
--

local log = { _version = "0.1.0" }

log.usecolor = true
log.outfile = nil
log.level = "trace"

local modes = {
  { name = "trace", color = "\27[34m", alt = Color(122, 166, 218) }, -- blue
  { name = "debug", color = "\27[36m", alt = Color(112, 192, 186) }, -- cyan
  { name = "info",  color = "\27[32m", alt = Color(185, 202, 74) }, -- green
  { name = "warn",  color = "\27[33m", alt = Color(230, 197, 71) }, -- yellow
  { name = "error", color = "\27[31m", alt = Color(213, 78, 83) }, -- red
  { name = "fatal", color = "\27[35m", alt = Color(195, 151, 216) }, -- magenta
} 

local levels = {}
for i, v in ipairs(modes) do
  levels[v.name] = i
end


local round = function(x, increment)
  increment = increment or 1
  x = x / increment
  return (x > 0 and math.floor(x + .5) or math.ceil(x - .5)) * increment
end


local _tostring = tostring

local tostring = function(...)
  local t = {}
  for i = 1, select('#', ...) do
    local x = select(i, ...)
    if type(x) == "number" then
      x = round(x, .01)
    end
    t[#t + 1] = _tostring(x)
  end
  return table.concat(t, " ")
end


for i, x in ipairs(modes) do
  local nameupper = x.name:upper()
  log[x.name] = function(...)
    
    -- Return early if we're below the log level
    if i < levels[log.level] then
      return
    end

    local msg = tostring(...)
    local info = debug.getinfo(2, "Sl")
    local lineinfo = info.short_src .. ":" .. info.currentline

    if log.usecolor and (CLIENT or system.IsWindows()) then
      MsgC(x.alt, 
        string.format("[%-6s%s]", 
                      nameupper, 
                      os.date("%H:%M:%S")), 
        Color(255, 255, 255), 
        string.format(" %s: %s\n", 
                      lineinfo, 
                      msg))
    else
      -- Output to console
      print(string.format("%s[%-6s%s]%s %s: %s",
                          log.usecolor and x.color or "",
                          nameupper,
                          os.date("%H:%M:%S"),
                          log.usecolor and "\27[0m" or "",
                          lineinfo,
                          msg))
    end

    -- Output to log file
    if log.outfile then
      local fp = io.open(log.outfile, "a")
      local str = string.format("[%-6s%s] %s: %s\n",
                                nameupper, os.date(), lineinfo, msg)
      fp:write(str)
      fp:close()
    end

  end
end

return log
