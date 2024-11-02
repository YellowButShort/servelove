---@diagnostic disable: undefined-field
---@class ServeLoveCookie
local cookie = {}


---Indicates the maximum lifetime of the cookie as a date timestamp. Accepts either seconds since the start of the epoch or os.date table<br>Returns itself for daisy-chaining
---@param date number|osdateparam
---@return ServeLoveCookie
function cookie:Expires(date)
    if type(date) == "table" then
        self.expires = os.date("%a, %d %b %Y %H:%M:%S GMT", os.time(date))
    elseif type(date) == "number" then
        self.expires = date
    else
        error("Incorrect argument type!", 2)
    end
    return self
end

---Forbids JavaScript from accessing the cookie, for example, through the Document.cookie property. Note that a cookie that has been created with HttpOnly will still be sent with JavaScript-initiated requests<br>Returns itself for daisy-chaining
---@return ServeLoveCookie
function cookie:HttpOnly()
    self.httponly = true
    return self
end

---Indicates the number of seconds until the cookie expires. Preferable to :Expires() due to possible differences in system time. If both :Expires() and :MaxAge() are set, :MaxAge() has precedence<br>Returns itself for daisy-chaining
---@param seconds integer
---@return ServeLoveCookie
function cookie:MaxAge(seconds)
    self.maxage = seconds
    return self
end

function cookie:Assemble()
    local str = "Set-Cookie: " .. self.name .. "=" .. self.value
    if self.expires then
        str = str .. "; Expires=" .. self.expires
    end
    if self.httponly then
        str = str .. "; HttpOnly"
    end
    if self.maxage then
        str = str .. "; Max-Age=" .. self.maxage
    end
    return str
end


return {__index = cookie}