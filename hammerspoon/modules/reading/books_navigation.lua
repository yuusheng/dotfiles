local M = {}

function M.start()
    M.stop()
    local booksBundleID = "com.apple.iBooksX"

    M.previousPage = hs.hotkey.new({}, 41, function() -- ;
        hs.eventtap.keyStroke({}, "left", 0)
    end)

    M.nextPage = hs.hotkey.new({}, 39, function() -- '
        hs.eventtap.keyStroke({}, "right", 0)
    end)

    local function updateHotkeys()
        local app = hs.application.frontmostApplication()
        local booksIsFrontmost = app and app:bundleID() == booksBundleID

        if booksIsFrontmost then
            M.previousPage:enable()
            M.nextPage:enable()
        else
            M.previousPage:disable()
            M.nextPage:disable()
        end
    end

    M.watcher = hs.application.watcher.new(updateHotkeys)
    M.watcher:start()
    updateHotkeys()

    return M
end

function M.stop()
    if M.watcher then M.watcher:stop(); M.watcher = nil end
    if M.previousPage then M.previousPage:delete(); M.previousPage = nil end
    if M.nextPage then M.nextPage:delete(); M.nextPage = nil end
end

return M
