local M = {
    keymap = {
        { mods = { "rCmd" }, key = "t", action = "ghostty", match = { "com.mitchellh.ghostty" } },
        { mods = { "rCmd" }, key = "b", action = "browser", match = { "company.thebrowser.Browser", "com.google.Chrome" } },
        { mods = { "rCmd" }, key = "m", action = "netease_music", match = { "com.netease.163music" } },
        { mods = { "rCmd" }, key = "o", action = "finder", match = { "com.apple.finder" } },
    },
}

local function switchWindow(matchTexts)
    local focused = hs.window.focusedWindow()
    local ordered = hs.window.orderedWindows()
    local selected

    if focused and M.spoon.match(focused, matchTexts) then
        for _, window in ipairs(ordered) do
            if M.spoon.match(window, matchTexts) then selected = window end
        end
    else
        for _, window in ipairs(ordered) do
            if M.spoon.match(window, matchTexts) then selected = window; break end
        end
    end

    if selected then
        selected:raise():focus()
    else
        hs.alert.show("没有已打开的目标窗口")
    end
end

function M.start()
    M.stop()
    local rightCommand = require("modules.window_management.right_command")
    rightCommand.ensureStarted()
    hs.loadSpoon("AppWindowSwitcher")
    M.spoon = spoon.AppWindowSwitcher
    M.hotkeys = {}
    for _, binding in ipairs(M.keymap) do
        table.insert(M.hotkeys, rightCommand.bind(binding.mods, binding.key, function()
            switchWindow(binding.match)
        end))
    end
    return M
end

function M.stop()
    if M.hotkeys then require("modules.window_management.right_command").unbind(M.hotkeys); M.hotkeys = nil end
    M.spoon = nil
end

return M
