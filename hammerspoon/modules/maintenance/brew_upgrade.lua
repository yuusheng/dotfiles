local M = {}

function M.new(dependencies)
    local controller = { running = false }

    local function notifyFailure(stage, exitCode, stdOut, stdErr)
        controller.running = false
        dependencies.log(stage .. " failed (exit " .. tostring(exitCode) .. ")\n" .. stdOut .. stdErr)
        dependencies.notify("Homebrew 更新失败", stage .. " 失败，退出码：" .. tostring(exitCode))
    end

    function controller:runIfDue()
        local today = dependencies.today()
        if self.running or dependencies.getLastRun() == today then
            return false
        end

        -- Mark the attempt immediately so repeated wake events cannot start it again today.
        dependencies.setLastRun(today)
        self.running = true
        dependencies.log("Starting daily Homebrew update")

        dependencies.runBrew({ "update" }, function(updateCode, updateOut, updateErr)
            dependencies.log("brew update output:\n" .. updateOut .. updateErr)
            if updateCode ~= 0 then
                notifyFailure("brew update", updateCode, updateOut, updateErr)
                return
            end

            dependencies.runBrew({ "upgrade", "--no-ask" }, function(upgradeCode, upgradeOut, upgradeErr)
                dependencies.log("brew upgrade output:\n" .. upgradeOut .. upgradeErr)
                if upgradeCode ~= 0 then
                    notifyFailure("brew upgrade", upgradeCode, upgradeOut, upgradeErr)
                    return
                end

                self.running = false
                dependencies.notify("Homebrew 更新完成", "所有可更新的软件包已经处理完毕")
            end)
        end)

        return true
    end

    function controller:onPowerEvent(eventType)
        if eventType == dependencies.wakeEvent then
            dependencies.schedule(60, function()
                self:runIfDue()
            end)
        end
    end

    return controller
end

function M.start()
    M.stop()
    M.activeTasks = {}
    local logPath = os.getenv("HOME") .. "/Library/Logs/Hammerspoon-brew-upgrade.log"

    local function appendLog(message)
        local file = io.open(logPath, "a")
        if not file then return end
        file:write(os.date("[%Y-%m-%d %H:%M:%S] "), message, "\n")
        file:close()
    end

    local function runBrew(arguments, callback)
        local task
        task = hs.task.new("/opt/homebrew/bin/brew", function(exitCode, stdOut, stdErr)
            M.activeTasks[task] = nil
            callback(exitCode, stdOut, stdErr)
        end, arguments)

        M.activeTasks[task] = true
        if not task:start() then
            M.activeTasks[task] = nil
            callback(127, "", "Unable to start /opt/homebrew/bin/brew")
        end
    end

    M.controller = M.new({
        wakeEvent = hs.caffeinate.watcher.systemDidWake,
        today = function() return os.date("%Y-%m-%d") end,
        getLastRun = function() return hs.settings.get("brewUpgradeLastRun") end,
        setLastRun = function(value) hs.settings.set("brewUpgradeLastRun", value) end,
        schedule = function(delay, callback)
            M.timer = hs.timer.doAfter(delay, callback)
        end,
        runBrew = runBrew,
        notify = function(title, message)
            hs.notify.show(title, "", message)
        end,
        log = appendLog,
    })

    M.watcher = hs.caffeinate.watcher.new(function(eventType)
        M.controller:onPowerEvent(eventType)
    end)
    M.watcher:start()

    return M
end

function M.stop()
    if M.watcher then M.watcher:stop(); M.watcher = nil end
    if M.timer then M.timer:stop(); M.timer = nil end
end

return M
