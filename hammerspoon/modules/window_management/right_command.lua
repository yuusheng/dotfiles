local M = { hotkeys = {} }

function M.start()
    M.stop()
    hs.loadSpoon("LeftRightHotkey")
    M.spoon = spoon.LeftRightHotkey
    M.spoon:start()
    return M
end

function M.bind(modifiers, key, callback, repeatable)
    assert(M.spoon, "right_command must be started before bindings are registered")
    local hotkey
    if repeatable then
        hotkey = M.spoon:bind(modifiers, key, callback, nil, callback)
    else
        hotkey = M.spoon:bind(modifiers, key, callback)
    end
    M.hotkeys[hotkey] = true
    return hotkey
end

function M.ensureStarted()
    assert(M.spoon, "right_command feature must be enabled before dependent features")
end

function M.unbind(hotkeys)
    for _, hotkey in ipairs(hotkeys or {}) do
        if M.hotkeys[hotkey] then
            hotkey:delete()
            M.hotkeys[hotkey] = nil
        end
    end
end

function M.stop()
    local registered = {}
    for hotkey in pairs(M.hotkeys) do table.insert(registered, hotkey) end
    M.unbind(registered)
    if M.spoon then M.spoon:stop() end
    M.spoon = nil
end

return M
