local ngx = ngx

-- Module
_M = { VERSION = '0.1' }

-- Determine whether a string starts with the given prefix string
local function starts_with(data, prefix)
  return string.sub(data, 1, string.len(prefix)) == prefix
end

-- Make sure a key and value are valid for hawk
local function validate_key_value(key, value)
  if not value:match('^[%a,%d,%p,%s]+$') then
    return 'Invalid value: ' .. value
  end
  local keys = { id = true, ts = true, nonce = true, hash = true, ext = true, mac = true,
    app = true, dlg = true }
  if not keys[key] then
    return 'Unknown attribute ' .. key
  end
  return nil
end

-- Parse a hawk header string into a table of attributes
_M.parse_auth_header = function(header)
  if not header then
    return nil, 'Invalid header'
  end
  if not starts_with(string.lower(header), 'hawk ') then
    return nil, 'Invalid auth scheme'
  end
  attrs = {}
  for k, v in header:gmatch('(%w+)="([^"]*)"') do
    err = validate_key_value(k, v)
    if err ~= nil then
      return nil, err
    end
    if attrs[k] ~= nil then
      return nil, 'Duplicate attribute: ' .. k
    end
    attrs[k] = v
  end
  return attrs, nil
end

-- Combine relevant request data into a table
_M.parse_request = function(opts)

  local authorization = ngx.var.http_authorization
  if not authorization then
    return nil, 'No http authorization header found'
  end

  local req = {}
  local url = ngx.var.uri
  local args = ngx.var.args
  if args then
    url = url .. '?' .. args
  end

  req.method = string.upper(ngx.req.get_method())
  req.url = ngx.unescape_uri(url)
  req.host = opts.host
  req.port = opts.port
  req.auth = authorization

  return req, nil

end

return _M
