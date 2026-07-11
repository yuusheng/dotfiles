local M = {
    keymap = {
        { mods = { "rCmd" }, key = "space", action = "play_pause", systemKey = "PLAY" },
        { mods = { "rCmd" }, key = ",", action = "previous", systemKey = "PREVIOUS" },
        { mods = { "rCmd" }, key = ".", action = "next", systemKey = "NEXT" },
        { mods = { "rCmd" }, key = "-", action = "volume_down", systemKey = "SOUND_DOWN", repeatable = true },
        { mods = { "rCmd" }, key = "=", action = "volume_up", systemKey = "SOUND_UP", repeatable = true },
        { mods = { "rCmd" }, key = "0", action = "mute", systemKey = "MUTE" },
    },
}

local function pressSystemKey(key)
    hs.eventtap.event.newSystemKeyEvent(key, true):post()
    hs.eventtap.event.newSystemKeyEvent(key, false):post()
end

function M.start()
    M.stop()
    local rightCommand = require("modules.window_management.right_command")
    rightCommand.ensureStarted()
    M.hotkeys = {}
    for _, binding in ipairs(M.keymap) do
        table.insert(M.hotkeys, rightCommand.bind(binding.mods, binding.key, function()
            pressSystemKey(binding.systemKey)
        end, binding.repeatable))
    end
    return M
end

function M.stop()
    if M.hotkeys then require("modules.window_management.right_command").unbind(M.hotkeys); M.hotkeys = nil end
end

return M
