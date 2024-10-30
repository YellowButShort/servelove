local responses = {}

local cwd = ((...):reverse():gsub((".responses"):reverse(), ""):reverse()) -- proper cleanup was left on my old laptop lol
local generic_error_page = love.filesystem.read(cwd:gsub("%.", "/") .. "/generic_error_page.html")

responses[100] = {
    title = [[HTTP/1.1 100 Continue]],
    headers = {}
}
--[=[ No use to us (at least yet)
responses[101] = {
    title = [[HTTP/1.1 101 Switching Protocols]],
    headers = {}
}
responses[103] = {
    title = [[HTTP/1.1 103 Early Hints]],
    headers = {}
}
]=]



-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------



responses[200] = {
    title = [[HTTP/1.1 200 OK]],
    headers = {}
}
responses[201] = {
    title = [[HTTP/1.1 201 Created]],
    headers = {}
}
responses[202] = {
    title = [[HTTP/1.1 202 Accepted]],
    headers = {}
}
responses[203] = {
    title = [[HTTP/1.1 203 Non-Authoritative Information]],
    headers = {}
}
responses[204] = {
    title = [[HTTP/1.1 204 No Content]],
    headers = {}
}
responses[205] = {
    title = [[HTTP/1.1 205 Reset Content]],
    headers = {}
}
responses[206] = {
    title = [[HTTP/1.1 206 Partial Content]],
    headers = {}
}



-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------



responses[300] = {
    title = [[HTTP/1.1 300 Multiple Choices]],
    headers = {}
}
responses[301] = {
    title = [[HTTP/1.1 301 Moved Permanently]],
    headers = {}
}
responses[302] = {
    title = [[HTTP/1.1 302 Found]],
    headers = {}
}
responses[303] = {
    title = [[HTTP/1.1 303 See Other]],
    headers = {}
}
responses[304] = {
    title = [[HTTP/1.1 304 Not Modified]],
    headers = {}
}
responses[305] = {
    title = [[HTTP/1.1 305 Use Proxy Deprecated]],
    headers = {}
}
responses[306] = {
    title = [[HTTP/1.1 306 unused]],
    headers = {}
}
responses[307] = {
    title = [[HTTP/1.1 307 Temporary Redirect]],
    headers = {}
}
responses[308] = {
    title = [[HTTP/1.1 308 Permanent Redirect]],
    headers = {}
}



-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------



responses[400] = {
    title = [[HTTP/1.1 400 Bad Request]],
    headers = {
        ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "400 Bad Request")
}
responses[401] = {
    title = [[HTTP/1.1 401 Unauthorized]],
    headers = {
      ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "401 Unauthorized")
}
responses[402] = {
    title = [[HTTP/1.1 402 Payment Required]],
    headers = {
        ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "402 Payment Required")
}
responses[403] = {
    title = [[HTTP/1.1 403 Forbidden]],
    headers = {
      ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "403 Forbidden")
}
responses[404] = {
    title = [[HTTP/1.1 404 Not Found]],
    headers = {
        ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "404 Not Found")
}
responses[405] = {
    title = [[HTTP/1.1 405 Method Not Allowed]],
    headers = {
      ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "405 Method Not Allowed")
}
responses[406] = {
    title = [[HTTP/1.1 406 Not Acceptable]],
    headers = {
        ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "406 Not Acceptable")
}
responses[407] = {
    title = [[HTTP/1.1 407 Proxy Authentication Required]],
    headers = {
      ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "407 Proxy Authentication Required")
}
responses[408] = {
    title = [[HTTP/1.1 408 Request Timeout]],
    headers = {
        ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "408 Request Timeout")
}
responses[409] = {
    title = [[HTTP/1.1 409 Conflict]],
    headers = {
      ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "409 Conflict")
}
responses[410] = {
    title = [[HTTP/1.1 410 Gone]],
    headers = {
        ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "410 Gone")
}
responses[411] = {
    title = [[HTTP/1.1 411 Length Required]],
    headers = {
      ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "411 Length Required")
}
responses[412] = {
    title = [[HTTP/1.1 412 Precondition Failed]],
    headers = {
        ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "412 Precondition Failed")
}
responses[413] = {
    title = [[HTTP/1.1 413 Content Too Large]],
    headers = {
      ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "413 Content Too Large")
}
responses[414] = {
    title = [[HTTP/1.1 414 URI Too Long]],
    headers = {
        ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "414 URI Too Long")
}
responses[415] = {
    title = [[HTTP/1.1 415 Unsupported Media Type]],
    headers = {
      ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "415 Unsupported Media Type")
}
responses[416] = {
    title = [[HTTP/1.1 416 Range Not Satisfiable]],
    headers = {
        ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "416 Range Not Satisfiable")
}
responses[417] = {
    title = [[HTTP/1.1 417 Expectation Failed]],
    headers = {
      ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "417 Expectation Failed")
}
responses[421] = {
    title = [[HTTP/1.1 421 Misdirected Request]],
    headers = {
      ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "421 Misdirected Request")
}
responses[426] = {
    title = [[HTTP/1.1 426 Upgrade Required]],
    headers = {
        ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "426 Upgrade Required")
}
responses[428] = {
    title = [[HTTP/1.1 428 Precondition Required]],
    headers = {
      ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "428 Precondition Required")
}
responses[429] = {
    title = [[HTTP/1.1 429 Too Many Requests]],
    headers = {
        ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "429 Too Many Requests")
}
responses[431] = {
    title = [[HTTP/1.1 431 Request Header Fields Too Large]],
    headers = {
      ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "431 Request Header Fields Too Large")
}
responses[451] = {
    title = [[HTTP/1.1 451 Unavailable For Legal Reasons]],
    headers = {
      ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "451 Unavailable For Legal Reasons")
}



-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------



responses[500] = {
    title = [[HTTP/1.1 500 Internal Server Error]],
    headers = {
        ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "500 Internal Server Error")
}
responses[501] = {
    title = [[HTTP/1.1 501 Not Implemented]],
    headers = {
        ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "501 Not Implemented")
}
responses[502] = {
    title = [[HTTP/1.1 502 Bad Gateway]],
    headers = {
        ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "502 Bad Gateway")
}
responses[503] = {
    title = [[HTTP/1.1 503 Service Unavailable]],
    headers = {
        ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "503 Service Unavailable")
}
responses[504] = {
    title = [[HTTP/1.1 504 Gateway Timeout]],
    headers = {
        ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "504 Gateway Timeout")
}
responses[505] = {
    title = [[HTTP/1.1 505 HTTP Version Not Supported]],
    headers = {
        ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "505 HTTP Version Not Supported")
}
responses[506] = {
    title = [[HTTP/1.1 506 Variant Also Negotiates]],
    headers = {
        ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "506 Variant Also Negotiates")
}
responses[510] = {
    title = [[HTTP/1.1 510 Not Extended]],
    headers = {
        ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "510 Not Extended")
}
responses[511] = {
    title = [[HTTP/1.1 511 Network Authentication Required]],
    headers = {
        ["Content-Type"] = "text/html"
    },
    content = generic_error_page:gsub("LUA_ERROR_CODE", "511 Network Authentication Required")
}


return responses