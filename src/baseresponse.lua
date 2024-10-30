---@class ServeLoveResponse
local response = {}
local cwd = ((...):reverse():gsub((".baseresponse"):reverse(), ""):reverse()) -- proper cleanup was left on my old laptop lol
local json = require(cwd .. ".json")
local puremagic = require(cwd .. ".puremagic")

function response:__init()
    self.headers = {}
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