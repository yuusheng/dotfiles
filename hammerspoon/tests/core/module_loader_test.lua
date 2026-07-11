package.path = "/Users/yuusheng/.hammerspoon/?.lua;" .. package.path

local calls = {}
local modules = {
    alpha = {
        start = function() table.insert(calls, "start alpha") end,
        stop = function() table.insert(calls, "stop alpha") end,
    },
    beta = {
        start = function() table.insert(calls, "start beta") end,
        stop = function() table.insert(calls, "stop beta") end,
    },
    broken = {
        start = function()
            table.insert(calls, "start broken")
            error("broken after allocation")
        end,
        stop = function() table.insert(calls, "stop broken") end,
    },
}

local errors = {}
local loader = require("core.module_loader").new({
    requireModule = function(name)
        return modules[name]
    end,
    onError = function(name, message)
        errors[name] = message
    end,
})

loader:startAll({
    { name = "alpha", enabled = true },
    { name = "beta", enabled = false },
    { name = "broken", enabled = true },
})

assert(table.concat(calls, ",") == "start alpha,start broken,stop broken", "partially started modules must be cleaned")
assert(errors.broken and errors.broken:match("broken after allocation"), "one bad module must be isolated")

loader:stopAll()
assert(table.concat(calls, ",") == "start alpha,start broken,stop broken,stop alpha", "started modules must stop")

print("module_loader tests passed")
