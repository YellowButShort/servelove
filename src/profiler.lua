local profiler = {}
local hub = {}
local order = {}

function profiler.RecordTime(server, time, event, path)
    if not hub[server] then
        return
    end
    if not hub[server].paths[path] then
        hub[server].paths[path] = {}
        for _, key in ipairs(order) do
            hub[server].paths[path][key] = {}
        end
    end
    table.insert(hub[server][event], time)
    table.insert(hub[server].paths[path][event], time)
end
function profiler.Enable(server)
    if not hub[server] then
        hub[server] = {paths = {}}
        for _, key in ipairs(order) do
            hub[server][key] = {}
        end
    end
end
function profiler.Disable(server)
    hub[server] = nil
end
function profiler.Reset(server)
    hub[server] = {paths = {}}
    for _, key in ipairs(order) do
        hub[server][key] = {}
    end
end
function profiler.PrintResult(server)
    if not hub[server] then
        return
    end
    
    for _, var in ipairs(order) do
        print("  "..var..":")
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
            low1p = low1p + ordered[x]
        end
        for x = 1, low10pn do
            low10p = low10p + ordered[x]
        end

        print("    Average: "..tostring(avg))
        print("    1% low: "..tostring(avg))
        print("    10% low: "..tostring(avg))
    end
end

return profiler