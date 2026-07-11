local home = assert(os.getenv("HOME"), "HOME is required")
local configRoot = home .. "/.config/hammerspoon"
package.path = configRoot .. "/?.lua;" .. package.path
assert(package.searchpath("core.module_loader", package.path) == configRoot .. "/core/module_loader.lua")

local function assertEqual(actual, expected, message)
    if actual ~= expected then
        error((message or "values differ") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
    end
end

local function newFixture(lastRun)
    local calls = { commands = {}, notifications = {}, logs = {} }
    local stored = lastRun
    local scheduled

    local controller = require("modules.maintenance.brew_upgrade").new({
        wakeEvent = 1,
        today = function() return "2026-07-11" end,
        getLastRun = function() return stored end,
        setLastRun = function(value) stored = value end,
        schedule = function(delay, fn)
            scheduled = fn
            calls.delay = delay
        end,
        runBrew = function(arguments, callback)
            table.insert(calls.commands, { arguments = arguments, callback = callback })
        end,
        notify = function(title, message)
            table.insert(calls.notifications, { title = title, message = message })
        end,
        log = function(message) table.insert(calls.logs, message) end,
    })

    return controller, calls, function() return stored end, function() scheduled() end
end

local controller, calls, stored, runScheduled = newFixture(nil)
controller:onPowerEvent(99)
assertEqual(calls.delay, nil, "non-wake event must be ignored")

controller:onPowerEvent(1)
assertEqual(calls.delay, 60, "wake should schedule after 60 seconds")
runScheduled()
assertEqual(stored(), "2026-07-11", "date must be persisted before running")
assertEqual(calls.commands[1].arguments[1], "update", "first command must be brew update")

calls.commands[1].callback(0, "updated", "")
assertEqual(calls.commands[2].arguments[1], "upgrade", "upgrade must follow a successful update")
calls.commands[2].callback(0, "upgraded", "")
assertEqual(calls.notifications[#calls.notifications].title, "Homebrew 更新完成", "success notification")

controller, calls, stored, runScheduled = newFixture("2026-07-11")
controller:onPowerEvent(1)
runScheduled()
assertEqual(#calls.commands, 0, "must not run twice on the same day")

controller, calls, stored, runScheduled = newFixture(nil)
controller:onPowerEvent(1)
runScheduled()
calls.commands[1].callback(1, "", "network error")
assertEqual(#calls.commands, 1, "upgrade must not run after update failure")
assertEqual(calls.notifications[#calls.notifications].title, "Homebrew 更新失败", "failure notification")

print("brew_upgrade tests passed")
