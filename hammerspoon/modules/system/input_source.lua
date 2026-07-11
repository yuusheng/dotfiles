local M = {
    ghosttyBundleID = "com.mitchellh.ghostty",
    englishLayout = "ABC",
}

function M.shouldSwitch(bundleID)
    return bundleID == M.ghosttyBundleID
end

local function switchIfNeeded(application)
    if application and M.shouldSwitch(application:bundleID()) then
        hs.keycodes.setLayout(M.englishLayout)
    end
end

function M.start()
    M.stop()
    M.watcher = hs.application.watcher.new(function(_, eventType, application)
        if eventType == hs.application.watcher.activated then
            switchIfNeeded(application)
        end
    end)
    M.watcher:start()
    switchIfNeeded(hs.application.frontmostApplication())
    return M
end

function M.stop()
    if M.watcher then M.watcher:stop(); M.watcher = nil end
end

return M
