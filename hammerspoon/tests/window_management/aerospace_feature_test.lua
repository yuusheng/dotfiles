local home = assert(os.getenv("HOME"), "HOME is required")
local configRoot = home .. "/.config/hammerspoon"
package.path = configRoot .. "/?.lua;" .. package.path
assert(package.searchpath("core.module_loader", package.path) == configRoot .. "/core/module_loader.lua")

local aerospace = require("modules.window_management.aerospace_feature")

assert(#aerospace.keymap == 35, "expected 35 AeroSpace bindings")
assert(aerospace.windowRatios[1] == 1 / 2)
assert(aerospace.windowRatios[2] == 2 / 3)
assert(aerospace.windowRatios[3] == 3 / 4)
assert(aerospace.widthForRatio(1920, 1) == 960)
assert(aerospace.widthForRatio(1920, 2) == 1280)
assert(aerospace.widthForRatio(1920, 3) == 1440)
assert(aerospace.nextRatioIndex(960, 1920, 1) == 2)
assert(aerospace.nextRatioIndex(1280, 1920, 1) == 3)
assert(aerospace.nextRatioIndex(1440, 1920, 1) == 1)
assert(aerospace.nextRatioIndex(960, 1920, -1) == 3)
assert(table.concat(aerospace.toggleLayoutCommand(42), " ") == "layout --window-id 42 floating tiling")
local fullscreen = aerospace.fullscreenOperation(42)
assert(table.concat(fullscreen.arguments, " ") == "fullscreen --window-id 42")
assert(table.concat(fullscreen.followup, " ") == "focus --window-id 42")
local layoutToggle = aerospace.toggleLayoutOperation(42)
assert(table.concat(layoutToggle.followup, " ") == "focus --window-id 42")

local commands = {}
for _, binding in ipairs(aerospace.keymap) do commands[binding.action] = binding.command end
assert(table.concat(commands.focus_left, " ") == "focus left")
assert(table.concat(commands.swap_right, " ") == "move right")
assert(table.concat(commands.workspace_3, " ") == "workspace 3")
assert(table.concat(commands.move_workspace_3, " ") == "move-node-to-workspace --focus-follows-window 3")
assert(table.concat(commands.fullscreen, " ") == "fullscreen")
assert(table.concat(commands.balance, " ") == "balance-sizes")
assert(table.concat(commands.toggle_tiling_layout, " ") == "layout accordion tiles")
assert(commands.window_chooser == nil, "window chooser is a dynamic action")

local choices = aerospace.parseWindowList(table.concat({
    "15920\t1\tcompany.thebrowser.Browser\tArc\tTaste Skill",
    "11581\t4\tcom.mitchellh.ghostty\tGhostty\t.config",
    "15897\t10\tcom.openai.chat\tChatGPT\tChatGPT",
}, "\n"))
assert(#choices == 3, "all AeroSpace windows must become chooser entries")
assert(choices[1].workspace == "1" and choices[1].text == "Arc")
assert(choices[2].workspace == "4" and choices[2].windowID == "11581")
assert(choices[3].workspace == "10", "numeric workspaces must sort naturally")
assert(choices[2].subText:match("Workspace 4") and choices[2].subText:match("%.config"))

local selectionCommands = aerospace.windowSelectionCommands(choices[2])
assert(table.concat(selectionCommands[1], " ") == "workspace 4")
assert(table.concat(selectionCommands[2], " ") == "focus --window-id 11581")

local started = {}
local callbacks = {}
local errors = {}
local runner = aerospace.newRunner({
    startTask = function(arguments, callback)
        table.insert(started, table.concat(arguments, " "))
        table.insert(callbacks, callback)
        return true
    end,
    onError = function(message) table.insert(errors, message) end,
})

runner:enqueue({ "focus", "left" }, true)
runner:enqueue({ "workspace", "2" }, false)
assert(#started == 1, "commands must execute serially")
callbacks[1](1, "", "No windows in the specified direction")
assert(#started == 2, "second command starts after first finishes")
assert(#errors == 0, "silent boundary failure must not notify")
callbacks[2](2, "", "config error")
assert(#errors == 1 and errors[1]:match("config error"), "real command errors must be reported")

runner:enqueue({ "focus", "left" }, true)
callbacks[3](1, "", "server unavailable")
assert(#errors == 2 and errors[2]:match("server unavailable"), "allow-noop must suppress only known boundary text")

runner:enqueue({ "workspace", "2" }, false)
callbacks[4](2, "", "")
assert(errors[3] == "exit 2", "empty command output must fall back to exit code")

local dynamicPrepared = 0
runner:enqueue({ "focus", "right" }, true)
runner:enqueueDynamic(function()
    dynamicPrepared = dynamicPrepared + 1
    return { "resize", "--window-id", "42", "width", "960" }
end, false)
assert(dynamicPrepared == 0, "dynamic resize must wait behind earlier focus command")
callbacks[5](0, "", "")
assert(dynamicPrepared == 1, "dynamic resize prepares only when it reaches the front of the queue")
assert(started[6] == "resize --window-id 42 width 960")
callbacks[6](0, "", "")

runner:enqueueDynamic(function()
    return { arguments = { "fullscreen", "--window-id", "42" }, followup = { "focus", "--window-id", "42" } }
end, false)
callbacks[7](0, "", "")
assert(started[8] == "focus --window-id 42", "successful fullscreen must restore focus before later commands")
callbacks[8](0, "", "")

runner:enqueue({ "focus", "right" }, true)
runner:enqueue({ "focus", "left" }, true)
runner:stop()
assert(#runner.queue == 0, "stop must clear queued commands")

print("aerospace_feature tests passed")
