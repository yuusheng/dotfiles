local M = {
    cli = "/opt/homebrew/bin/aerospace",
    keymap = {},
    windowRatios = { 1 / 2, 2 / 3, 3 / 4 },
    windowListFormat = "%{window-id}\t%{workspace}\t%{app-bundle-id}\t%{app-name}\t%{window-title}",
}

local function add(mods, key, action, command, repeatable, allowNoop)
    table.insert(M.keymap, {
        mods = mods,
        key = key,
        action = action,
        command = command,
        repeatable = repeatable,
        allowNoop = allowNoop,
    })
end

add({ "rCmd" }, "h", "focus_left", { "focus", "left" }, true, true)
add({ "rCmd" }, "j", "focus_down", { "focus", "down" }, true, true)
add({ "rCmd" }, "k", "focus_up", { "focus", "up" }, true, true)
add({ "rCmd" }, "l", "focus_right", { "focus", "right" }, true, true)
add({ "rCmd", "lShift" }, "h", "swap_left", { "move", "left" }, true, true)
add({ "rCmd", "lShift" }, "j", "swap_down", { "move", "down" }, true, true)
add({ "rCmd", "lShift" }, "k", "swap_up", { "move", "up" }, true, true)
add({ "rCmd", "lShift" }, "l", "swap_right", { "move", "right" }, true, true)
add({ "rCmd" }, "r", "cycle_width")
add({ "rCmd", "lShift" }, "r", "reverse_cycle_width")
add({ "rCmd" }, "f", "fullscreen", { "fullscreen" })
add({ "rCmd" }, "c", "balance", { "balance-sizes" }, false, true)
add({ "rCmd" }, "[", "join_left", { "join-with", "left" }, false, true)
add({ "rCmd", "lShift" }, "]", "join_right", { "join-with", "right" }, false, true)
add({ "rCmd" }, "v", "toggle_floating", { "layout", "floating", "tiling" })
add({ "rCmd" }, "]", "toggle_tiling_layout", { "layout", "accordion", "tiles" })
add({ "rCmd" }, "a", "window_chooser")

for index = 1, 9 do
    local workspace = tostring(index)
    add({ "rCmd" }, workspace, "workspace_" .. workspace, { "workspace", workspace })
    add(
        { "rCmd", "lShift" },
        workspace,
        "move_workspace_" .. workspace,
        { "move-node-to-workspace", "--focus-follows-window", workspace }
    )
end

function M.parseWindowList(output)
    local choices = {}
    for line in output:gmatch("[^\r\n]+") do
        local windowID, workspace, bundleID, appName, windowTitle =
            line:match("^([^\t]+)\t([^\t]*)\t([^\t]*)\t([^\t]*)\t(.*)$")
        if windowID and workspace ~= "" and appName ~= "" then
            local detail = "Workspace " .. workspace
            if windowTitle ~= "" then detail = detail .. " · " .. windowTitle end
            table.insert(choices, {
                text = appName,
                subText = detail,
                windowID = windowID,
                workspace = workspace,
                bundleID = bundleID,
            })
        end
    end

    table.sort(choices, function(left, right)
        local leftNumber, rightNumber = tonumber(left.workspace), tonumber(right.workspace)
        if leftNumber and rightNumber and leftNumber ~= rightNumber then return leftNumber < rightNumber end
        if left.workspace ~= right.workspace then return left.workspace < right.workspace end
        if left.text ~= right.text then return left.text < right.text end
        return left.subText < right.subText
    end)
    return choices
end

function M.windowSelectionCommands(choice)
    return {
        { "workspace", choice.workspace },
        { "focus", "--window-id", tostring(choice.windowID) },
    }
end

function M.widthForRatio(screenWidth, index)
    return math.floor(screenWidth * M.windowRatios[index] + 0.5)
end

function M.toggleLayoutCommand(windowID)
    return { "layout", "--window-id", tostring(windowID), "floating", "tiling" }
end

function M.fullscreenOperation(windowID)
    return {
        arguments = { "fullscreen", "--window-id", tostring(windowID) },
        followup = { "focus", "--window-id", tostring(windowID) },
    }
end

function M.toggleLayoutOperation(windowID)
    return {
        arguments = M.toggleLayoutCommand(windowID),
        followup = { "focus", "--window-id", tostring(windowID) },
    }
end

function M.nextRatioIndex(windowWidth, screenWidth, direction)
    local ratio = windowWidth / screenWidth
    local closestIndex, closestDistance = 1, math.huge
    for index, candidate in ipairs(M.windowRatios) do
        local distance = math.abs(candidate - ratio)
        if distance < closestDistance then closestIndex, closestDistance = index, distance end
    end

    if closestDistance <= 0.08 then
        if direction > 0 then return (closestIndex % #M.windowRatios) + 1 end
        return ((closestIndex - 2) % #M.windowRatios) + 1
    end

    if direction > 0 then
        for index, candidate in ipairs(M.windowRatios) do
            if candidate > ratio then return index end
        end
        return 1
    end

    for index = #M.windowRatios, 1, -1 do
        if M.windowRatios[index] < ratio then return index end
    end
    return #M.windowRatios
end

function M.newRunner(dependencies)
    local runner = { queue = {}, active = false, running = true }

    local function pump()
        if not runner.running or runner.active or #runner.queue == 0 then return end
        local item = table.remove(runner.queue, 1)
        runner.active = true
        local arguments = item.arguments
        if item.prepare then
            local prepared, result = pcall(item.prepare)
            if not prepared then
                runner.active = false
                dependencies.onError(result)
                pump()
                return
            end
            if type(result) == "table" and result.arguments then
                arguments = result.arguments
                item.followup = result.followup
            else
                arguments = result
            end
            if not arguments then runner.active = false; pump(); return end
        end

        local started = dependencies.startTask(arguments, function(exitCode, stdOut, stdErr)
            runner.active = false
            local message = stdErr ~= "" and stdErr
                or (stdOut ~= "" and stdOut)
                or ("exit " .. tostring(exitCode))
            local expectedNoop = item.allowNoop and exitCode == 1 and (
                message:find("No windows in the specified direction", 1, true)
                or message:find("No window is focused", 1, true)
            )
            if runner.running and exitCode ~= 0 and not expectedNoop then
                dependencies.onError(message)
            end
            if runner.running and exitCode == 0 and item.followup then
                table.insert(runner.queue, 1, { arguments = item.followup, allowNoop = false })
            end
            pump()
        end)
        if not started then
            runner.active = false
            dependencies.onError("unable to start AeroSpace CLI")
            pump()
        end
    end

    function runner:enqueue(arguments, allowNoop)
        if not self.running then return end
        table.insert(self.queue, { arguments = arguments, allowNoop = allowNoop })
        pump()
    end

    function runner:enqueueDynamic(prepare, allowNoop)
        if not self.running then return end
        table.insert(self.queue, { prepare = prepare, allowNoop = allowNoop })
        pump()
    end

    function runner:stop()
        self.running = false
        self.queue = {}
    end

    return runner
end

local function cycleWidth(direction)
    M.runner:enqueueDynamic(function()
        if not hs.application.get("bobko.aerospace") then
            hs.notify.show("AeroSpace 未运行", "", "请先启动 AeroSpace")
            return nil
        end
        local window = hs.window.focusedWindow()
        if not window then return nil end
        local screenWidth = window:screen():frame().w
        local index = M.nextRatioIndex(window:frame().w, screenWidth, direction)
        local width = M.widthForRatio(screenWidth, index)
        return { "resize", "--window-id", tostring(window:id()), "width", tostring(width) }
    end, false)
end

local function showWindowChooser()
    if not hs.application.get("bobko.aerospace") then
        hs.notify.show("AeroSpace 未运行", "", "请先启动 AeroSpace")
        return
    end
    if M.windowListTask then return end

    local task
    task = hs.task.new(M.cli, function(exitCode, stdOut, stdErr)
        M.runningTasks[task] = nil
        M.windowListTask = nil
        if exitCode ~= 0 then
            local message = stdErr ~= "" and stdErr or stdOut
            hs.notify.show("窗口列表读取失败", "", message ~= "" and message or ("退出码：" .. tostring(exitCode)))
            return
        end

        local choices = M.parseWindowList(stdOut)
        if #choices == 0 then
            hs.alert.show("没有可切换的窗口")
            return
        end
        for _, choice in ipairs(choices) do
            if choice.bundleID ~= "" then
                local ok, appImage = pcall(hs.image.imageFromAppBundle, choice.bundleID)
                if ok then choice.image = appImage end
            end
        end
        M.chooser:choices(choices)
        M.chooser:show()
    end, { "list-windows", "--all", "--format", M.windowListFormat })

    M.windowListTask = task
    M.runningTasks[task] = true
    if not task:start() then
        M.runningTasks[task] = nil
        M.windowListTask = nil
        hs.notify.show("窗口列表读取失败", "", "无法启动 AeroSpace CLI")
    end
end

function M.start()
    M.stop()
    local rightCommand = require("modules.window_management.right_command")
    rightCommand.ensureStarted()
    assert(hs.fs.attributes(M.cli), "AeroSpace CLI not found at " .. M.cli)
    local preflightOutput, serverRunning = hs.execute(M.cli .. " list-workspaces --all", true)
    assert(serverRunning, "AeroSpace server/config unavailable: " .. tostring(preflightOutput))

    M.runningTasks = {}
    M.runner = M.newRunner({
        startTask = function(arguments, callback)
            local task
            task = hs.task.new(M.cli, function(exitCode, stdOut, stdErr)
                M.runningTasks[task] = nil
                callback(exitCode, stdOut, stdErr)
            end, arguments)
            M.runningTasks[task] = true
            if not task:start() then M.runningTasks[task] = nil; return false end
            return true
        end,
        onError = function(message)
            print("AeroSpace command failed: " .. tostring(message))
            hs.notify.show("AeroSpace 命令失败", "", tostring(message))
        end,
    })

    M.chooser = hs.chooser.new(function(choice)
        if not choice or not M.runner then return end
        for _, command in ipairs(M.windowSelectionCommands(choice)) do
            M.runner:enqueue(command, false)
        end
    end)
    M.chooser:placeholderText("搜索所有 workspace 的应用和窗口")
    M.chooser:searchSubText(true)
    M.chooser:rows(12)
    M.chooser:width(60)

    M.hotkeys = {}
    for _, binding in ipairs(M.keymap) do
        local callback
        if binding.action == "cycle_width" then
            callback = function() cycleWidth(1) end
        elseif binding.action == "reverse_cycle_width" then
            callback = function() cycleWidth(-1) end
        elseif binding.action == "window_chooser" then
            callback = showWindowChooser
        elseif binding.action == "fullscreen" then
            callback = function()
                M.runner:enqueueDynamic(function()
                    local window = hs.window.focusedWindow()
                    return window and M.fullscreenOperation(window:id()) or nil
                end, false)
            end
        elseif binding.action == "toggle_floating" then
            callback = function()
                M.runner:enqueueDynamic(function()
                    if not hs.application.get("bobko.aerospace") then
                        hs.notify.show("AeroSpace 未运行", "", "请先启动 AeroSpace")
                        return nil
                    end
                    local window = hs.window.focusedWindow()
                    return window and M.toggleLayoutOperation(window:id()) or nil
                end, false)
            end
        else
            callback = function()
                if not hs.application.get("bobko.aerospace") then
                    hs.notify.show("AeroSpace 未运行", "", "请先启动 AeroSpace")
                    return
                end
                M.runner:enqueue(binding.command, binding.allowNoop)
            end
        end
        table.insert(M.hotkeys, rightCommand.bind(binding.mods, binding.key, callback, binding.repeatable))
    end

    return M
end

function M.stop()
    if M.hotkeys then require("modules.window_management.right_command").unbind(M.hotkeys); M.hotkeys = nil end
    if M.runner then M.runner:stop(); M.runner = nil end
    if M.windowListTask then M.windowListTask:terminate(); M.windowListTask = nil end
    if M.chooser then M.chooser:hide(); M.chooser:delete(); M.chooser = nil end
    M.runningTasks = {}
end

return M
