local hawk = require "hawk"
local config = require "config"
local ngx = ngx

return function(id, version)

  local allowed = { HEAD = true, GET = true, POST = true, PUT = true, DELETE = true }
  local method = ngx.req.get_method()

  if not allowed[method] then
    return hawk.method_not_allowed("HEAD, GET, POST, PUT, DELETE")
  end

  local target, err = hawk.authenticate(config, id, version)

  if err ~= nil then
    return hawk.unauthorized()
  end

  ngx.var.proxy_target = target

end
