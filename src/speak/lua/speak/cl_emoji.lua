local emoji = {}
emoji.list = {}

--- Define an emoji.
-- @param code The short code
-- @param url The url to the image
function emoji:Define(code, url)
  IS.enforce_arg(1, 'Define', 'string', type(code))
  IS.enforce_arg(2, 'Define', 'string', type(url))

  -- If we're getting it locally
  if file.Exists('materials/' .. url, 'GAME') then
    url = 'data:image/png;base64,' .. util.Base64Encode(file.Read('materials/' .. url, 'GAME'))
  end

  self.list[code] = {code = code, url = url}
end

--- Retrieve an emoji.
-- @param code The short code
function emoji:Get(code)
  IS.enforce_arg(1, 'Get', 'string', type(code))

  if self.list[code] then
    return self.list[code]
  end
end

speak.emoji = emoji
