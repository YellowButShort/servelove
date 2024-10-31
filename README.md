# servelove
 
A Flask-like crossplatform library based on Luasec designed for Löve that allows hosting an HTTP/S webserver directly in your app.

# Supported platforms
* Windows (32 bit, untested, but supposed to work) 
* Windows (64 bit)
* Linux (64 bit)

# Installation
* Download the `src` folder and put it in your project. Feel free to rename it.
* Require it in your code

# Usage

## Basic routing
Let's start with a simple Hello World!
```lua
local servelove = require("servelove") -- load the library

local server = servelove.NewServer("0.0.0.0", 5000)  -- Creates a new server. Binds it to 0.0.0.0 (all available addresses). 5000 is the default port 

server:Route("/Hello", function(query, response) -- Whenever someone visits /Hello, they get "World!" as a reply
    return "World!"
end)
                   
server:Run() -- Run the server. This function will lock the thread!
```

## Advanced routing
That's something, but not enough. Let's allow user to store and access files

```lua
server:Route("/GetFile/<file>", function(query, response) -- By encapsulating `file` in <>, we tell the server that this part can be anything except for reserved characters
    return response:NewFile( -- Read the file and set headers appropriately
        query:GetUrlArgs("file") -- We can read this undefined part with :GetUrlArgs(). Argument in the function is the part we are interested in.
    )
end, {"GET"}) -- We don't expect anything else but GET method when we retrieve something

server:Route("/WriteFile/<file>", function(query, response)
    print(love.filesystem.write(
        query:GetUrlArgs("file"),
        query:GetUrlEncoded("content") -- Url can also include arguments. They are written as <URL>?key1=value1&key2=value2... We can read them with this function
    ))
    return "Success!"
end, {"POST", "GET"}) -- Note that there is also a GET method, usually it's weird to use GET to save something, 
--but since we are only testing and browsers don't allow changing the request type, it's fine.

-- These two routes above can easily be replaced with a single one and the action will determined by the method used
server:Route("/File/<file>", function(query, response)
    if query:GetMethod() == "POST" then -- As was noted, browsers don't allow sending POST requests, so you gotta use other tools
        love.filesystem.write(
            query:GetUrlArgs("file"), 
            query:GetUrlEncoded("content")
        )
        return "Success!"
    elseif query:GetMethod() == "GET" then
        return response:NewFile(
            query:GetUrlArgs("file")
        )
    end
end, {"POST", "GET"})
```

## File access
We can also expose a folder with a single function like this. It can be used to share access to assets like /favicon.ico (that little icon in your tabs)
```lua
server:RouteFolder(
    "server/assets", -- This is the folder either in your project folder, or in your user folder. Same rules as with love.filesystem
    "assets"  -- And this is how it should it be in Url. So in our case a `test.png` file stored in `server/assets/test.png` will only be accessible at `assets/test.png`
)
```

## Authentication
That's cool and all, but allowing every user to access our files is a bit risky. Let's add some form of authentication

```lua
-- This is the most simple, yet still pretty secure way of authentification. User has to send a header with their key and we check if it's in our system
local keys = { 
    "admin" -- don't do this kids, please (yet we will for the sake of clarity)
}
local function auth(query)
    for _, var in ipairs(keys) do
        if var == query:GetHeaders()["Token"] then -- if the token is valid, we allow the user
            return true
        end
    end
end

-- And now we insert it into our functions. Both :Route and :RouteFolder can use this function
server:Route("/File/<file>", function(query, response)
    if query:GetMethod() == "POST" then -- As was noted, browsers don't allow sending POST requests, so you gotta use other tools
        love.filesystem.write(
            query:GetUrlArgs("file"), 
            query:GetUrlEncoded("content")
        )
        return "Success!"
    elseif query:GetMethod() == "GET" then
        return response:NewFile(
            query:GetUrlArgs("file")
        )
    end
end, {"POST", "GET"}, auth) -- right there
```

## Profiler
Let's measure the performance of our code

```lua
-- To start the profiler, we can use this little function
server:StartProfiler()

-- Let's also create a separate address to see the results
server:Route("/Profiler", function(query, response)
    return server:PrintProfiler()
end, {"GET"}, auth) -- Same auth function from previous part
```

Unlike regular HTTP, HTTPS requires a signed SSL certificate. You can get one for free for example at ZeroSSL or anywhere else
Without it will be able to access it, but it's not that secure and unsuited for public usage.

```lua
server:Certificate("certificate.crt")
server:PrivateKey("private.key") 
```

So let's compile everything we have.

```lua
local servelove = require("servelove") -- load the library

local server = servelove.NewServer("0.0.0.0", 5000)  -- Creates a new server. Binds it to 0.0.0.0 (all available addresses). 5000 is the default port 

server:Route("/Hello", function(query, response) -- Whenever someone visits /Hello, they get "World!" as a reply
    return "World!"
end)


local keys = { 
    "admin" -- don't do this kids, please (yet we will for the sake of clarity)
}
local function auth(query)
    for _, var in ipairs(keys) do
        if var == query:GetHeaders()["Token"] then -- if the token is valid, we allow the user
            return true
        end
    end
end


server:Route("/GetFile/<file>", function(query, response) -- By encapsulating `file` in <>, we tell the server that this part can be anything except for reserved characters
    return response:NewFile( -- Read the file and set headers appropriately
        query:GetUrlArgs("file") -- We can read this undefined part with :GetUrlArgs(). Argument in the function is the part we are interested in.
    )
end, {"GET"}, auth) -- We don't expect anything else but GET method when we retrieve something

server:Route("/WriteFile/<file>", function(query, response)
    print(love.filesystem.write(
        query:GetUrlArgs("file"),
        query:GetUrlEncoded("content") -- Url can also include arguments. They are written as <URL>?key1=value1&key2=value2... We can read them with this function
    ))
    return "Success!"
end, {"POST", "GET"}, auth) -- Note that there is also a GET method, usually it's weird to use GET to save something, 
--but since we are only testing and browsers don't allow changing the request type, it's fine.

-- These two routes above can easily be replaced with a single one and the action will determined by the method used
server:Route("/File/<file>", function(query, response)
    if query:GetMethod() == "POST" then -- As was noted, browsers don't allow sending POST requests, so you gotta use other tools
        love.filesystem.write(
            query:GetUrlArgs("file"), 
            query:GetUrlEncoded("content")
        )
        return "Success!"
    elseif query:GetMethod() == "GET" then
        return response:NewFile(
            query:GetUrlArgs("file")
        )
    end
end, {"POST", "GET"}, auth)


server:RouteFolder(
    "server/assets", -- This is the folder either in your project folder, or in your user folder. Same rules as with love.filesystem
    "assets"  -- And this is how it should it be in Url. So in our case a `test.png` file stored in `server/assets/test.png` will only be accessible at `assets/test.png`
)


-- To start the profiler, we can use this little function
server:StartProfiler()

-- Let's also create a separate address to see the results
server:Route("/Profiler", function(query, response)
    return server:PrintProfiler()
end, {"GET"}, auth)


server:Certificate("certificate.crt")
server:PrivateKey("private.key") 


server:Run()
```

For more stuff, please refer to the documentation.