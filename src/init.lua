local servelove = {}
local base = {__index = require(... .. ".server")}

---Creates a new server.
---@param ip string? Defaults to localhost
---@param port integer? Defaults to 443 or 80 for HTTPS and HTTP respectively 
---@return ServeLoveServer
function servelove.NewServer(ip, port)
    local ent = setmetatable({}, base)
    ent:__init(ip, port)
    return ent
end

return servelove