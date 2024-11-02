---@diagnostic disable: need-check-nil, discard-returns
local cwd = ((...):reverse():gsub((".server"):reverse(), ""):reverse()) -- proper cleanup was left on my old laptop lol
local socket = require("socket")
local ssl = require(cwd..".lib")
local profiler = require(cwd .. ".profiler")
local ltimer = require("love.timer")

---@class ServeLoveServer
local server = {}
local http_responses = {__index = require(cwd .. ".responses")}

local function split(inputstr, sep)
    local t={}
    for str in string.gmatch(inputstr, "([^"..(sep or "%s").."]+)") do
        table.insert(t, str)
    end
    return t
end
local function RecursiveItems(path, result)
    result = result or {}
	local files = love.filesystem.getDirectoryItems(path)
	for _, v in ipairs(files) do
		local file = path.."/"..v
		local info = love.filesystem.getInfo(file)
		if info then
			if info.type == "file" then
				table.insert(result, file)
			elseif info.type == "directory" then
				RecursiveItems(file, result)
			end
		end
	end
	return result
end
---Creates raw http response
---@param code integer
---@param content any?
---@param headers table?
---@param cookies ServeLoveCookie[]?
---@return string
local function AssembleResponse(self, code, content, headers, cookies)
    local res = ""
    res = res .. self.responses[code].title
    content = content or self.responses[code].content
    local head = {}
    for i, var in pairs(self.responses[code].headers) do
        head[i] = var
    end
    if headers then
        for i, var in pairs(headers) do
            head[i] = var
        end
    end
    if not head["Content-Length"] then
        head["Content-Length"] = (content or ""):len()
    end

    for i, var in pairs(head) do
        res = res .. "\r\n" .. i .. ": " .. var
    end

    if cookies then
        for _, var in ipairs(cookies) do
            res = res .. "\r\n" .. var:Assemble()
        end
    end

    res = res .. "\r\n\r\n"

    if content then
        res = res .. content
    end

    return res
end
local function FindRoute(s, route)
    if s.routes[route] then
        return s.routes[route], 1
    end

    for _, var in pairs(s.routes) do
        local complex_path = "[START]" .. route .. "[END]"
        local complex_key  = "%[START%]" .. var.path:gsub("%b<>", "(%%w+)") .. "%[END%]"
        local start = complex_path:find(complex_key)
        if start then
            return var, 2
        end
    end

    for _, var in ipairs(s.folders) do
        for _, file in ipairs(RecursiveItems(var.path)) do
            if "/" .. var.prefix .. file:sub(file:find("/"), -1) == route then
                return file, 3
            end
        end
    end
end
local function ReadConnection(self, conn, method)
    local headers = {}
    local cookies = {}
    local query = ""
    while true do
        local s = conn:receive("*l")
        if s ~= "" then
            local temp = split(s, ":")
            if temp[1] == "Cookie" then
                local list = split(temp[2], ";")
                for _, var in ipairs(list) do
                    local cookie = split(var, "=")
                    cookies[cookie[1]:sub(2, -1)] = cookie[2]:sub(2, -1)
                end
            else
                headers[temp[1]] = temp[2]:sub(2, -1)
            end
        else
            if headers["Content-Length"] then
                if headers["Content-Length"] > 0 then
                    query = conn:receive(tonumber(headers["Content-Length"]))
                end
            elseif method == "POST" then
                conn:send(AssembleResponse(self, 411))
                return false
            end
            break
        end
    end
    return query, headers, cookies
end

function server:__init(ip, port)
    self.socket = socket.tcp()
    self.socket:setoption('reuseaddr', true)
    self.responses = setmetatable({}, http_responses)
    do --assertion part
        if ip and type(ip) == "string" then
            local addresses = split(ip, ".")
            if #addresses ~= 4 then
                error("Incorrect IP formatting! Expected X.X.X.X", 3)
            end

            for _, var in ipairs(addresses) do
                local success, res = pcall(tonumber, var)
                if not success or res >= 256 then
                    error("Malformed IP address!", 3)
                end
            end
        else
            error("Expected string as IP!", 2)
        end
        if port and type(port) == "number" then
            if not ((math.ceil(port) == port) and (math.floor(port) == port)) then -- will do for now
                error("Expected integer as port!", 3)
            end
        else
            error("Expected integer as port!", 3)
        end
    end

    self.sslparams = {
        mode = "server",
        protocol = "tlsv1_2"
    }
    if love.system.getOS() == "Linux" then
        self.sslparams = {
            mode = "server",
            protocol = "any"
        }
    end
    self.enablessl = false
    self.addresses = {
        ip or "0.0.0.0",
        port or 443
    }
    self.routes = {
    }
    self.folders = {
    }
    self.verbose = "INFO"
end
local defaultmethods = {
    "GET",
    "PUT",
    "POST",
    "DELETE",
    "PATCH",
    "HEAD",
    "OPTIONS",
    "TRAC"
}
local defaultmethods_proxy = {
    ["GET"] = true,
    ["PUT"] = true,
    ["POST"] = true,
    ["DELETE"] = true,
    ["PATCH"] = true,
    ["HEAD"] = true,
    ["OPTIONS"] = true,
    ["TRAC"] = true
}
local loglevels = {
    NONE  = 0,
    ERROR = 1,
    WARN  = 2,
    INFO  = 3,
    DEBUG = 4
}
local newresponse = {__index = require(cwd .. ".baseresponse")}
local newquery = {__index = require(cwd .. ".baserequest")}


---Creates a new resource on the server.
---@param route string Address of the resource. Must start with "/". Path can include <>. They will be treated as anything and will be added as arguments to callback and authentication.   
---@param func function Callback that will be called when the address is requested. The function takes ServeLoveRequest and ServeLoveResponse as arguments. Whatever the function returns will be sent as a response body
---@param methods table? What methods will the server accept. If not provided, all methods are allowed
---@param authentication function? Callback that will be called when the address is requested prior to the regular callback. Used to authenticate the user. Must return either true or false. If the result is true - callback is called and everything goes as usual. If the result is false - the server sends 403 Forbidden 
function server:Route(route, func, methods, authentication)
    local proxymethods = {}
    if not (type(route) == "string") then
        error("Expected string as route!", 2)
    end
    if not (type(func) == "function") then
        error("Expected function as func!", 2)
    end
    if not (type(authentication) == "function" or type(authentication) == "nil") then
        error("Expected function as authentication!", 2)
    end
    if not (type(methods) == "table" or type(methods) == "nil") then
        error("Expected table as methods!", 2)
    end
    methods = methods or defaultmethods
    for _, var in ipairs(methods) do
        if not defaultmethods_proxy[var:upper()] then
            error(var:upper() .. " is not a valid HTTP method!", 2)
        end
        proxymethods[var:upper()] = true
    end

    self.routes[route] = {path = route, func = func, methods = proxymethods, authentication = authentication}
end

---Similar to server:Route, but opens an entire folder for access. Can be used for nearly anything
---@param path string Path to the folder relative to where the library was required
---@param prefix string? What should come before the path in the URL. For example "assets/".
---@param methods table? What methods will the server accept. If not provided, all methods are allowed
---@param authentication function? Callback that will be called when the address is requested prior to the regular callback. Used to authenticate the user. Must return either true or false. If the result is true - callback is called and everything goes as usual. If the result is false - the server sends 403 Forbidden 
function server:RouteFolder(path, prefix, methods, authentication)
    local proxymethods = {}
    if not (type(path) == "string") then
        error("Expected string as path!", 2)
    end
    if not (type(methods) == "table" or type(methods) == "nil") then
        error("Expected table as methods!", 2)
    end
    if not (type(prefix) == "string" or type(prefix) == "nil") then
        error("Expected string as prefix!", 2)
    end
    if not (type(authentication) == "function" or type(authentication) == "nil") then
        error("Expected function as authentication!", 2)
    end
    methods = methods or defaultmethods
    for _, var in ipairs(methods) do
        if not defaultmethods_proxy[var:upper()] then
            error(var:upper() .. " is not a valid HTTP method!", 2)
        end
        proxymethods[var:upper()] = true
    end

    table.insert(self.folders, {path = path, methods = proxymethods, prefix = prefix or "", authentication = authentication})
end


---Sets the logging level
---@param level "NONE"|"ERROR"|"WARN"|"INFO"|"DEBUG"
function server:Verbose(level)
    if not (type(level) == "string") then
        error("Expected string!", 2)
    end
    self.verbose = level
end
---Logs the information
---@param msg string
---@param level "NONE"|"ERROR"|"WARN"|"INFO"|"DEBUG"
function server:Log(msg, level)
    local level_int = loglevels[level or "INFO"]
    if level_int <= loglevels[self.verbose] then
        print("["..(level or "INFO").."]["..os.date("%X").."]: ".. msg)
    end
end

---Starts the profiler to measure the performance of your code
function server:StartProfiler()
    profiler.Enable(self)
end
---Stops the recording of the profiler
function server:DisableProfiler()
    profiler.Disable(self)
end
---Outputs the profiler results into console + returns it as a string
---@return string
function server:PrintProfiler(minimum)
    return profiler.PrintResult(self, minimum)
end

---Sets the SSL Private Key (absolute path)
---@param filepath string
function server:PrivateKey(filepath)
    if type(filepath) ~= "string" then
        error("Expected string as filepath!", 2)
    end
    self.enablessl = true
    self.sslparams.key = filepath
end
---Sets the SSL Certificate (absolute path)
---@param filepath string
function server:Certificate(filepath)
    if type(filepath) ~= "string" then
        error("Expected string as filepath!", 2)
    end
    self.enablessl = true
    self.sslparams.certificate = filepath
end
---Sets the SSL CA File (absolute path)
---@param filepath string
function server:CaFile(filepath)
    if type(filepath) ~= "string" then
        error("Expected string as filepath!", 2)
    end
    self.enablessl = true
    self.sslparams.cafile = filepath
end


---Returns default StatusResponses. Can be used for setting default page, or to modify existing error page.
---@return table
function server:GetStatusResponses()
    return self.responses
end

---Returns a new query from the client
---@param query any?
---@param headers any?
---@param link any?
---@return ServeLoveRequest
local function NewQuery(query, headers, link, method, conn, cookies, complex_args)
    return setmetatable({}, newquery):__init(query, headers, link, method, conn, cookies, complex_args)
end

---Returns a new response for the client
---@return ServeLoveResponse
local function NewResponse()
    return setmetatable({}, newresponse):__init()
end


---Starts the server. If any of the SSL related functions are used, it the server will run using HTTPS, otherwise, it will use HTTP. NOTE: this function is thread locking! Run the server in a thread if you want to avoid it
---@param retries number? If the launch is failed (for example due to busy port), this many retries will the server take before surrendering. -1 for infinity
---@param retry_timeout number? If the launch is failed (for example due to busy port), this is the time inbetween the attempts
function server:Run(retries, retry_timeout)
    self:Log(("Attempting to bind to %s:%s"):format(self.addresses[1], self.addresses[2]), "WARN")
    do
        local n = 0
        while true do
            local check, errormsg
            self:Log("Bind attempt", "DEBUG")
            check, errormsg = self.socket:bind(self.addresses[1], self.addresses[2])
            if not check then
                if n == retries then
                    error(errormsg, 2)
                else
                    self:Log(errormsg, "ERROR")
                    self.socket = socket.tcp()
                    self.socket:setoption('reuseaddr', true)
                end
            else
                self:Log("    Success!", "DEBUG")
                self:Log("Listen attempt", "DEBUG")
                check, errormsg = self.socket:listen()
                if not check then
                    if n == retries then
                        error(errormsg, 2)
                    else
                        self:Log(errormsg, "ERROR")
                        self.socket = socket.tcp()
                        self.socket:setoption('reuseaddr', true)
                    end
                else
                    self:Log("    Success!", "DEBUG")
                    local ip, port = self.socket:getsockname()
                    local protocol = self.enablessl and "https" or "http"
                    if ip == "0.0.0.0" then
                        self:Log(("The server is running on all available addresses (%s://%s:%s)"):format(protocol, ip, port), "WARN")
                        local res
                        if love.system.getOS() == "Linux" then
                            local cmd = io.popen("hostname -I | awk '{print $1}'")
                            res = cmd:read("*a"):sub(0, -2)
                        elseif love.system.getOS() == "Windows" then
                            local cmd = io.popen([[for /f "tokens=2 delims=:" %i  in ('ipconfig ^| findstr "IPv4" ^| findstr [0-9]') do echo %i]])
                            cmd:read("*l")
                            cmd:read("*l")
                            res = cmd:read("*l"):sub(2, -1)
                        end
                        if res and res ~= "" then
                            self:Log(("    The server is running on public address accessible at %s://%s:%s"):format(protocol, res, port), "INFO")
                        end
                        self:Log(("    The server is running on private address accessible at %s://localhost:%s"):format(protocol, port), "INFO")
                        self:Log(("    The server is running on private address accessible at %s://127.0.0.1:%s"):format(protocol, port), "INFO")
                    else
                        self:Log(("The server is running on %s://%s:%s"):format(protocol, ip, port), "WARN")
                    end
                    if love.system.getOS() == "Windows" then
                        self:Log("Windows version is heavily outdated. It may contain severe security vulnerabities so I would advise against using it in production", "WARN")
                    end
                    break
                end
            end
            n = n + 1
            if retry_timeout then
                ltimer.sleep(retry_timeout)
            end
        end
    end
    
    while true do
        self:Log("Waiting for connection...", "DEBUG")
        local conn = self.socket:accept()
        local path
        local time
        local sslerr
        if self.enablessl then
            self:Log("SSL Handshake", "DEBUG")
            conn, sslerr = ssl.wrap(conn, self.sslparams)
            if conn then
                conn:dohandshake()
            else
                self:Log(sslerr, "ERROR")
                goto continue
            end
        end
        local r, e = conn:receive()
        if r then
            time = ltimer.getTime()
            local args = split(r, "%s")
            self:Log(("Connection: %s  %s  %s"):format(args[1], args[2], args[3]), "INFO")
            path = args[2]
            if path:find("?") then
                path = path:sub(0, path:find("?")-1)
            end

            local res, type = FindRoute(self, path)
            if res then
                self:Log("Method check", "DEBUG")
                if type ~= 3 and not res.methods[args[1]] then
                    conn:send(AssembleResponse(self, 405))
                    goto continue
                end

                self:Log("Connection read", "DEBUG")
                local query, headers, cookies = ReadConnection(self, conn, args[1])
                if not query then
                    goto continue
                end
                local complex_args
                if type == 2 then
                    self:Log("complex_args read", "DEBUG")
                    local complex_path = "[START]" .. path .. "[END]"
                    local complex_key  = "%[START%]" .. res.path:gsub("%b<>", "(%%w+)") .. "%[END%]"
                    complex_args = {}
                    local vals = {complex_path:match(complex_key)}
                    local counter = 1
                    for key in res.path:gmatch("%b<>") do
                        complex_args[key:sub(2, -2)] = vals[counter]
                        counter = counter + 1
                    end
                end
                if res.authentication then
                    self:Log("Auth", "DEBUG")

                    local t = ltimer.getTime()
                    local res, msg = pcall(res.authentication, NewQuery(query, headers, args[2], args[1], conn, cookies, complex_args))
                    profiler.RecordTime(self, ltimer.getTime() - t, "Authentication", path)

                    if res then
                        if not msg then
                            self:Log("Auth failed", "DEBUG")
                            conn:send(AssembleResponse(self, 403))
                            goto continue
                        end
                    else
                        self:Log(e, "ERROR")
                        conn:send(AssembleResponse(self, 503))
                    end
                end
                
                local t = ltimer.getTime()
                if type == 3 then
                    local response = NewResponse()
                    
                    conn:send(AssembleResponse(self, 200, response:NewFile(res), response:GetHeaders()))
                else
                    local response = NewResponse()
                    local res, msg = pcall(res.func, NewQuery(query, headers, args[2], args[1], conn, cookies, complex_args), response)
                    if res then
                        conn:send(AssembleResponse(self, response:GetCode(), msg, response:GetHeaders(), response:GetCookies()))
                    else
                        self:Log(msg, "ERROR")
                        conn:send(AssembleResponse(self, 503))
                    end
                end
                profiler.RecordTime(self, ltimer.getTime() - t, "Callback", path)
            else
                conn:send(AssembleResponse(self, 404))
            end
            profiler.RecordTime(self, ltimer.getTime() - time, "Total time per connection", path)
        elseif e == "closed" then
            self:Log("Connection closed", "WARN")
        else
            self:Log(e, "ERROR")
        end
        ::continue::
        conn:close()
    end
end

return server