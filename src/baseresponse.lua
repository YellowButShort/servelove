---@class ServeLoveResponse
local response = {}
local cwd = ((...):reverse():gsub((".baseresponse"):reverse(), ""):reverse()) -- proper cleanup was left on my old laptop lol
local json = require(cwd .. ".json")
local base_cookie = require(cwd .. ".basecookie")
local puremagic = require(cwd .. ".puremagic")

function response:__init()
    self.headers = {}
    self.cookies = {}
    self.code = 200
    return self
end
---Returns a file and sets an appropriate Content-Type header. Filepath is bound to rules set by love.filesystem.read
---@param filepath string
---@return string
function response:NewFile(filepath)
    local res = love.filesystem.read(filepath)
    self:SetHeader("Content-Type", puremagic.via_path(filepath))
    --self:SetHeader("Content-Disposition", ([[%s; filename="%s"]]):format(inline and "inline" or "attachment", filename or "file"))
    return res
end
---Encodes a table into JSON and sets an appropriate Content-Type header
---@param t table
---@return string
function response:NewJson(t)
    self:SetHeader("Content-Type", "application/json")
    return json.encode(t)
end
---Returns an HTML page and sets an appropriate Content-Type header. Filepath is bound to rules set by love.filesystem.read. Currently doesn't have any substantial differences to NewFile
---@param filepath string
---@return string
function response:NewPage(filepath)
    local code = love.filesystem.read(filepath)
    self:SetHeader("Content-Type", "text/html")
    return code
end
---Sets a response header
---@param key string
---@param value string
function response:SetHeader(key, value)
    self.headers[key] = value
end
---Returns the table with response headers
---@return table
function response:GetHeaders()
    return self.headers
end
---Creates and sets a new cookie that user will save. Anything you put here could be later accessed in subsequent requests from this user (if they support cookies)
---@param name string
---@param value string
---@return ServeLoveCookie
function response:SetCookie(name, value)
    local cookie = setmetatable({}, base_cookie)

    --https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie
    if name:match([=[[",;\%(%)<>@:%[%]?={}]]=]) then
        error("Cookie name cannot contain ".. name:match([=[[",;\%(%)<>@:%[%]?={}]]=]) .. "!", 2)
    end
    if value:match([=[[",;\]]=]) then
        error("Cookie value cannot contain ".. value:match([=[[",;\]]=]) .. "!", 2)
    end

    cookie.name = name
    cookie.value = '"' .. value .. '"'
    table.insert(self.cookies, cookie)

    return cookie
end
---Returns all cookies set within this response
---@return ServeLoveCookie[]
function response:GetCookies()
    return self.cookies
end
---Sets the HTTP response code
---@param code integer
function response:SetCode(code)
    self.code = code
end
---Returns the HTTP response code
---@return integer
function response:GetCode()
    return self.code
end


return response