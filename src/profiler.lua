local profiler = {}
local hub = {}
local order = {
    "Authentication",
    "Callback",
    "Total time per connection"
}

function profiler.RecordTime(server, time, event, path)
    if not hub[server] then
        return
    end
    if not hub[server].paths[path] then
        hub[server].paths[path] = {}
    end
    table.insert(hub[server][event], time)
    table.insert(hub[server].paths[path], time)
    hub[server].counter = hub[server].counter + 1
end
function profiler.Enable(server)
    if not hub[server] then
        hub[server] = {paths = {}, counter = 0}
        for _, key in ipairs(order) do
            hub[server][key] = {}
        end
    end
end
function profiler.Disable(server)
    hub[server] = nil
end
function profiler.Reset(server)
    hub[server] = {paths = {}, counter = 0}
    for _, key in ipairs(order) do
        hub[server][key] = {}
    end
end
function profiler.PrintResult(server, minimum)
    if not hub[server] then
        return
    end
    local res = ""
    res = res .. ("Servelove profiler:") .. "\n"
    res = res .. ("Recorded " .. hub[server].counter .. " events") .. "\n"
    res = res .. ("  Per event information") .. "\n"
    for _, var in ipairs(order) do
        res = res .. ("    "..var..":") .. "\n"
        local avg = 0
        local low1p = 0
        local low1pn = math.max(math.ceil(#hub[server][var] / 100), 1)
        local low10p = 0
        local low10pn = math.max(math.ceil(#hub[server][var] / 10), 1)
        local ordered = {}
        for _, value in ipairs(hub[server][var]) do
            avg = avg + value
            table.insert(ordered, value)
        end
        table.sort(ordered, function(a, b) return a > b end)
        for x = 1, low1pn do
            if ordered[x] then
                low1p = low1p + ordered[x]
            end
        end
        for x = 1, low10pn do
            if ordered[x] then
                low10p = low10p + ordered[x]
            end
        end

        res = res .. ("      Average: "..tostring(avg/#hub[server][var])) .. "\n"
        res = res .. ("      1% low : "..tostring(low1p/low1pn)) .. "\n"
        res = res .. ("      10% low: "..tostring(low10p/low10pn)) .. "\n"
    end
    
    res = res .. ("  Per route information:") .. "\n"
    for key, path in pairs(hub[server].paths) do
        if #path > (minimum or 0) then
            res = res .. ("    "..key..":") .. "\n"
            local avg = 0
            local low1p = 0
            local low1pn = math.max(math.ceil(#path / 100), 1)
            local low10p = 0
            local low10pn = math.max(math.ceil(#path / 10), 1)
            local ordered = {}
            for _, value in ipairs(path) do
                avg = avg + value
                table.insert(ordered, value)
            end
            table.sort(ordered, function(a, b) return a > b end)
            for x = 1, low1pn do
                low1p = low1p + ordered[x]
            end
            for x = 1, low10pn do
                low10p = low10p + ordered[x]
            end

            res = res .. ("      Average: "..tostring(avg/#path)) .. "\n"
            res = res .. ("      1% low : "..tostring(low1p/low1pn)) .. "\n"
            res = res .. ("      10% low: "..tostring(low10p/low10pn)) .. "\n"
        end
    end
    return res
end

return profiler