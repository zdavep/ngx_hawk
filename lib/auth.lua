local cjson = require 'cjson'
local crypto = require 'hawk.crypto'
local ngx = ngx

-- Module
_M = { VERSION = 0.1 }

-- A "do nothing" nonce/ts check function
local function nonce_no_op(artifacts, opts)
  return nil
end

_M.authenticate = function(req, creds, attrs, opts)

  -- Determine nonce check function
  local nonce_func = opts.nonce_func or nonce_no_op

  -- Verify required attributes
  if not attrs.id or not attrs.ts or not attrs.nonce or not attrs.mac then
    return nil, 'Missing attributes'
  end

  -- Construct artifacts
  local artifacts = {
    method = req.method, host = req.host, port = req.port, url = req.url,
    ts = attrs.ts, nonce = attrs.nonce, hash = attrs.hash, ext = attrs.ext, app = attrs.app,
    dlg = attrs.dlg, mac = attrs.mac, id = attrs.id
  }

  -- Calculate and check MAC
  local mac, err = crypto.calculate_mac(creds, artifacts, 'header')
  if err ~= nil then
    return artifacts, err
  end
  if attrs.mac ~= mac then
    return artifacts, 'Bad MAC'
  end

  -- TODO: If provided, validate payload hash here...

  -- Check nonce and timestamp
  err = nonce_func(artifacts, opts)
  if err ~= nil then
    return artifacts, err
  end

  -- Success
  return artifacts, nil

end

return _M
