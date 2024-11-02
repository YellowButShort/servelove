---@class ServeLoveRequest
local request = {}
local cwd = ((...):reverse():gsub((".baserequest"):reverse(), ""):reverse()) -- proper cleanup was left on my old laptop lol

--local nativefs = require(cwd .. ".nativefs")
local json = require(cwd .. ".json")

function request:__init(payload, headers, link, method, peer, cookies, complex_args)
    self.payload = payload
    self.headers = headers
    self.link = link
    self.method = method
    self.peer = peer
    self.cookies = cookies
    self.complex_args = complex_args or {}
    return self
end
---Returns the query as a JSON converted table
---@return table
function request:GetJson()
    return json.decode(self.payload)
end
---Returns the table with request headers
---@return table
function request:GetHeaders()
    return self.headers
end
---Returns the method that was used during the request
---@return string
function request:GetMethod()
    return self.method
end
---Returns a table of cookies that user has. If key is provided, it returns a cookie with this name
---@param key string
---@return ServeLoveCookie[]
function request:GetCookies(key)
    if key then
        return self.cookies[key]
    else
        return self.cookies
    end
end
local function split(inputstr, sep)
    local t={}
    for str in string.gmatch(inputstr, "([^"..(sep or "%s").."]+)") do
        table.insert(t, str)
    end
    return t
end
---Returns raw text query
function request:GetRaw()
    return self.payload
end
---Returns the query arguments encoded in URL. If key is provided returns the value, otherwise it returns the whole table
---@param key string?
---@return string|table
function request:GetUrlEncoded(key)
    local encoded = self.__urlencoded or {}
    if not self.__urlencoded and self.link:find("?") then
        local t = split(self.link:sub(self.link:find("?")+1, -1), "&")
        for _, var in ipairs(t) do
            local keyvalue = split(var, "=")
            encoded[keyvalue[1]] = keyvalue[2]
            self.__urlencoded = encoded
        end
    end
    if not key then
        return encoded
    else
        return encoded[key]
    end
end
function request:GetPeer()
    return self.peer:getpeername()
end
---Returns the query arguments defined in :Route() with <>. If key is provided returns the value, otherwise it returns the whole table
---@param key string?
---@return string|table
function request:GetUrlArgs(key)
    return key and self.complex_args[key] or self.complex_args
end

return request