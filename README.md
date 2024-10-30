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

```lua
local servelove = require("servelove")               -- load the library

local server = servelove.NewServer("0.0.0.0", 5000)  -- Creates a new server. Binds it to 0.0.0.0 (all available addresses). 5000 is the default port 
server:Route("/Hello", function(query, response)     -- Whenever someone visits /Hello, they get "World!" as a reply
    return "World!"
end)

-- Unlike regular HTTP, HTTPS requires a signed SSL certificate. You can get one for free for example at ZeroSSL or anywhere else 
server:Certificate("certificate.crt")
server:PrivateKey("private.key")                    
server:Run()                                         -- Run the server. This function will lock the thread!
```

For more useful stuff, please refer to the documentation.