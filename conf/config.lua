local os = require 'os'
local math = require 'math'
local ngx = ngx

--
-- TODO: This is only a sample hawk configuration file. Should probably pull config from MySQL or Redis.
--

-- Module
_M = { VERSION = 0.1 }

-- Services (use * for all version)
local hello_service = 'hello-*'

-- Client permissions
local permissions_table = {}
permissions_table[hello_service] = { bb190a0c210f = true, b705f62e4292 = true  }

-- Service target URLs
local services_table = {}
services_table[hello_service] = '127.0.0.1:8080'

-- Client credentials
local credentials_table = {
  bb190a0c210f = { key = 'saRgjL5mz305xgKdKm7wtyH3uXbJb1YMtGEFbiGB5kAukFessyq1KiVNJ3rGDPT', algorithm = 'sha256' },
  b705f62e4292 = { key = 'tF37RtSLxbd57DPA4WNTlY9sZPs62tsOcoqXFOTsGzJ8HO9d8dN3BTSD8TjyY0D', algorithm = 'sha1'   }
}

-- Return client hawk credentials after checking permission for the given service/version.
_M.get_credentials = function(id, service, version)

  -- Build service ID
  local service_id = service .. '-' .. version

  -- Check permission
  local permissions = permissions_table[service_id]
  if not permissions then
    return nil, 'Invalid service/version'
  end
  if not permissions[id] then
    return nil, 'Permission denied; client = ' .. id .. ', service = ' .. service_id
  end

  -- Check for credentials existence
  if not credentials_table[id] then
    return nil, 'Invalid client ID: ' .. id
  end

  return credentials_table[id]

end

-- In this implementation, we only make sure the nonce is present.
local function nonce_check(attrs, opts)

  -- Get attributes
  local id, nonce, ts = attrs.id, attrs.nonce, attrs.ts

  -- Check nonce
  if not nonce then
    return 'Missing nonce'
  end

  -- Check ts
  local now = ngx.time()
  if opts.offset ~= nil then
    now = now - opts.offset
  end
  local tdiff = math.floor(math.abs(now - ts))
  if tdiff > opts.skew then
    ngx.log(ngx.ERR, 'tdiff = ' .. tdiff)
    return 'Stale timestamp: ' .. ts
  end

  -- OK
  return nil

end

-- Set override host and port here (if necessary)
_M.get_opts = function()

  opts = {}
  opts.host = 'localhost'
  opts.port = 80
  opts.offset = 0
  opts.skew = 60 -- seconds
  opts.nonce_func = nonce_check

  return opts

end

-- Determine the target service/version URL for a client
_M.get_service_target = function(id, service, version)

  if not credentials_table[id] then
    return nil, 'Invalid client ID'
  end

  local service_id = service .. '-' .. version
  local target = services_table[service_id]
  if not target then
    return nil, 'Invalid service/version: ' .. service_id
  end

  return target, nil

end

return _M

