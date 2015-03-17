local hmac = require 'hawk.hmac'
local ngx = ngx

-- Module
_M = { VERSION = 0.1 }

-- MAC normalization format version
local header_version = '1'
_M.header_version = header_version

-- Construct the normalized string to be used in the MAC calculation
local function normalize_string(creds, attrs, hawk_type)

  local hash = attrs.hash or ''
  local method = attrs.method or ''

  local normalized = 'hawk.' .. header_version .. '.' .. hawk_type .. '\n' .. attrs.ts .. '\n' ..
    attrs.nonce .. '\n' .. string.upper(method) .. '\n' .. attrs.url .. '\n' ..
    string.lower(attrs.host) .. '\n' .. attrs.port .. '\n' .. hash .. '\n'

  if attrs.ext then
    normalized = normalized .. attrs.ext:gsub('\\', '\\\\'):gsub('\n', '\\n')
  end

  normalized = normalized .. '\n'

  if attrs.app then
    local dlg = attrs.dlg or ''
    normalized  = normalized .. attrs.app .. '\n' .. dlg .. '\n'
  end

  return normalized, nil

end

-- Calculate the request MAC
_M.calculate_mac = function(creds, attrs, hawk_type)

  local normalized, err = normalize_string(creds, attrs, hawk_type)
  if err ~= nil then
    return nil, err
  end

  local hmac_func = nil
  if creds.algorithm == 'sha1' then
    hmac_func = hmac:new(creds.key, hmac.ALGOS.SHA1)
  elseif creds.algorithm == 'sha256' then
    hmac_func = hmac:new(creds.key, hmac.ALGOS.SHA256)
  else
    return nil, 'Invalid mac algorithm'
  end

  local digest = hmac_func:final(normalized)
  if not digest then
    return nil, 'Failed to calculate MAC'
  end

  return ngx.encode_base64(digest), nil

end

return _M
