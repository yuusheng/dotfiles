local home = assert(os.getenv("HOME"), "HOME is required")
local configRoot = home .. "/.config/hammerspoon"
package.path = configRoot .. "/?.lua;" .. package.path
assert(package.searchpath("core.module_loader", package.path) == configRoot .. "/core/module_loader.lua")

local calls = { deleted = 0 }
local fakeSpoon = {
    start = function(self) calls.started = true; return self end,
    stop = function(self) calls.stopped = true; return self end,
    bind = function(self, mods, key, callback)
        calls.mods, calls.key, calls.callback = mods, key, callback
        return { delete = function() calls.deleted = calls.deleted + 1 end }
    end,
}

hs = { loadSpoon = function(name) assert(name == "LeftRightHotkey") end }
spoon = { LeftRightHotkey = fakeSpoon }

local rightCommand = require("modules.window_management.right_command")
rightCommand.start()
rightCommand.bind({ "rCmd" }, "h", function() end)

assert(calls.started, "LeftRightHotkey must start")
assert(calls.mods[1] == "rCmd" and calls.key == "h", "must preserve right-side modifier")

rightCommand.stop()
assert(calls.deleted == 1, "registered hotkeys must be deleted")
assert(calls.stopped, "LeftRightHotkey must stop")

print("right_command tests passed")
