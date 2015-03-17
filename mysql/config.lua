local aes = require 'resty.aes'
local os = require 'os'
local math = require 'math'
local mysql = require 'resty.mysql'
local cjson = require 'cjson'
local ngx = ngx


-- Module
_M = { VERSION = 0.1 }


-- Hawk options
local hawk_opts = {
  host = 'localhost',
  port = 80,
  offset = 0,
  skew = 60 -- seconds
}


-- MySQL config
local db_config = {
  host     = "127.0.0.1",
  port     = 3306,
  database = "ngx_hawk",
  user     = "ngx_hawk",
  password = "FIXME",
  timeout  = 1000
}


-- Decryption params
local aes_secret_key = 'FIXME'
local aes_rounds = 1024
local aes_hash = aes.hash.sha256
local aes_cipher = aes.cipher(256, 'cbc')


-- Return a MySQL connection
local function get_connection()
  local conn = mysql:new()
  conn:set_timeout(db_config.timeout)
  conn:connect(db_config)
  return conn
end


-- Execute a SQL statment, then return the result set and status
local function exec_query(stmt)
  local conn = get_connection()
  local res, err, errno, sqlstate = conn:query(stmt)
  conn:set_keepalive(0, 100) -- Return to a pool of size 100
  return res, err, errno, sqlstate
end


-- Check that the timestamp is fresh and that the nonce hasn't already been used.
local function mysql_nonce_check(artifacts, opts)
  -- Get attributes
  local id, nonce, ts = artifacts.id, artifacts.nonce, artifacts.ts
  -- Check ts
  local now = ngx.time()
  if opts.offset ~= nil then
    now = now - opts.offset
  end
  local tdiff = math.floor(math.abs(now - ts))
  if tdiff > opts.skew then
    return 'Stale timestamp: ' .. ts .. ', time diff = ' .. tdiff .. ' seconds'
  end
  -- Check nonce
  local stmt = 'insert into nonces (hawk_id, nonce, artifacts) values (' ..
    ngx.quote_sql_str(id) .. ', ' .. ngx.quote_sql_str(nonce) .. ', ' ..
    ngx.quote_sql_str(cjson.encode(artifacts)) .. ')'
  local res, err, errno, sqlstate = exec_query(stmt)
  if not res then
    ngx.log(ngx.ERR, "Unable to store nonce: " .. err .. ": " .. errno .. ": " .. sqlstate)
    return 'Nonce already used'
  end
  -- OK
  return nil
end


-- Look up client hawk credentials, checking permissions in the process.
_M.get_credentials = function(id, service, version)
  local locked = 'N'
  local stmt = 'select c.secret_key, c.salt, c.algorithm' ..
    ' from clients c, permissions p, services s' ..
    ' where p.client_id = c.id' ..
    ' and p.service_id = s.id' ..
    ' and date(now()) between p.beg_eff_date and p.end_eff_date' ..
    ' and p.locked = ' .. ngx.quote_sql_str(locked) ..
    ' and c.hawk_id = ' .. ngx.quote_sql_str(id) ..
    ' and s.name = ' .. ngx.quote_sql_str(service) ..
    ' and s.version = ' .. ngx.quote_sql_str(version)
  local res, err, errno, sqlstate = exec_query(stmt)
  if not res or #res == 0 then
    ngx.log(ngx.ERR, "Permission denied: " .. err .. ": " .. errno .. ": " .. sqlstate)
    return nil, 'Permission denied'
  end
  local creds = {}
  local crypter = aes:new(aes_secret_key, res[1].salt, aes_cipher, aes_hash, aes_rounds)
  creds.key = crypter:decrypt(ngx.decode_base64(res[1].secret_key))
  creds.algorithm = res[1].algorithm
  return creds, nil
end


-- Return local hawk options
_M.get_opts = function()
  hawk_opts.nonce_func = mysql_nonce_check
  return hawk_opts
end


-- Determine the target service/version host:port for a client
_M.get_service_target = function(id, service, version)
  local target = nil
  local stmt = 'select host, port from services where name = ' .. ngx.quote_sql_str(service) ..
    ' and version = ' .. ngx.quote_sql_str(version)
  local res, err, errno, sqlstate = exec_query(stmt)
  if not res or #res == 0 then
    ngx.log(ngx.ERR, "Unable to find service: " .. err .. ": " .. errno .. ": " .. sqlstate)
    return nil, 'Unable to find service/version target'
  elseif #res > 1 then
    err = 'More than one service/version target found'
    ngx.log(ngx.ERR, err)
    return nil, err
  end
  local host, port = res[1].host, res[1].port
  if port == 80 or port == 443 then
    target = host
  else
    target = host .. ':' .. port
  end
  return target, nil
end


return _M
