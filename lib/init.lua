local cjson = require "cjson"
local parser = require 'hawk.parser'
local auth = require 'hawk.auth'
local ngx = ngx

-- Module
_M = { VERSION = 0.1 }

-- Hawk authentication function
_M.authenticate = function(config, service, version)

  local err, req, creds, attrs, artifacts, target = nil, nil, nil, nil, nil, nil
  local opts = config.get_opts() or {}

  -- Gather request data
  req, err = parser.parse_request(opts)
  if err ~= nil then
    ngx.log(ngx.ERR, 'Error parsing request: ' .. err)
    return nil, err
  end

  -- Parse / validate hawk auth header
  attrs, err = parser.parse_auth_header(req.auth)
  if err ~= nil then
    ngx.log(ngx.ERR, 'Error parsing auth header: ' .. err)
    return nil, err
  end

  -- Lookup client credentials, checking permissions in the process
  creds, err = config.get_credentials(attrs.id, service, version)
  if err ~= nil then
    ngx.log(ngx.ERR, 'Error getting credentials: ' .. err)
    return nil, err
  end

  -- Authenticate by validating mac, ts and nonce
  artifacts, err = auth.authenticate(req, creds, attrs, opts)
  if err ~= nil then
    ngx.log(ngx.ERR, 'Error authenticating request: ' .. err)
    return nil, err
  end

  -- Return service proxy target for client
  target, err = config.get_service_target(attrs.id, service, version)
  if err ~= nil then
    ngx.log(ngx.ERR, 'Error getting service target: ' .. err)
    return nil, err
  end

  return target, nil

end

-- Send a JSON error response
local function send_error(status, codeVal, msg)
  ngx.header.content_type = 'application/json; charset=utf-8'
  ngx.status = status
  local resp = { code = codeVal, error = msg }
  ngx.say(cjson.encode(resp))
  return false
end

-- Tell the client that only certain methods are allowed
_M.method_not_allowed = function(allowed_methods)
  ngx.header["Allow"] = allowed_methods
  return send_error(ngx.HTTP_NOT_ALLOWED, 'MethodNotAllowed', 'See allow header for methods')
end

-- Tell the client they need to authenticate the requst with hawk
_M.unauthorized = function()
  ngx.header["WWW-Authenticate"] = "Hawk"
  return send_error(ngx.HTTP_UNAUTHORIZED, 'Unauthorized', 'Hawk authentication required')
end

return _M
