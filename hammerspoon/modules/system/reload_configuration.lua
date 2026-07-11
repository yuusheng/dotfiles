local M = {}

function M.start()
    M.stop()
    hs.loadSpoon("ReloadConfiguration")
    M.spoon = spoon.ReloadConfiguration
    M.spoon:start()
    return M
end

function M.stop()
    if M.spoon and M.spoon.watchers then
        for _, watcher in pairs(M.spoon.watchers) do watcher:stop() end
        M.spoon.watchers = nil
    end
    M.spoon = nil
end

return M
