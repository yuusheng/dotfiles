local M = {}

function M.start()
    hs.loadSpoon("SpoonInstall")
    return M
end

function M.stop()
    -- SpoonInstall has no background watcher unless an install/update is requested.
end

return M
