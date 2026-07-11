local M = { keymap = {}, windowRatios = { 1 / 2, 2 / 3, 3 / 4 } }

local function add(mods, key, action, repeatable)
    table.insert(M.keymap, { mods = mods, key = key, action = action, repeatable = repeatable })
end

add({ "rCmd" }, "h", "focus_left", true)
add({ "rCmd" }, "j", "focus_down", true)
add({ "rCmd" }, "k", "focus_up", true)
add({ "rCmd" }, "l", "focus_right", true)
add({ "rCmd", "lShift" }, "h", "swap_left", true)
add({ "rCmd", "lShift" }, "j", "swap_down", true)
add({ "rCmd", "lShift" }, "k", "swap_up", true)
add({ "rCmd", "lShift" }, "l", "swap_right", true)
add({ "rCmd" }, "r", "cycle_width")
add({ "rCmd", "lShift" }, "r", "reverse_cycle_width")
add({ "rCmd" }, "f", "full_width")
add({ "rCmd" }, "c", "center_window")
add({ "rCmd" }, "[", "slurp_in")
add({ "rCmd" }, "]", "barf_out")
add({ "rCmd" }, "v", "toggle_floating")

for index = 1, 9 do
    local key = tostring(index)
    add({ "rCmd" }, key, "switch_space_" .. key)
    add({ "rCmd", "lShift" }, key, "move_window_" .. key)
end

function M.start()
    M.stop()
    local rightCommand = require("modules.window_management.right_command")
    rightCommand.ensureStarted()
    hs.loadSpoon("PaperWM")
    M.spoon = spoon.PaperWM
    M.spoon.window_gap = 8
    M.spoon.window_ratios = M.windowRatios
    M.spoon.window_filter:setScreens("H27P22P")
    M.spoon.window_filter:setAppFilter("Hammerspoon", false)
    M.spoon.window_filter:setAppFilter("System Settings", false)
    M.spoon.window_filter:setAppFilter("System Preferences", false)
    M.spoon.window_filter:setAppFilter("Calculator", false)
    M.spoon:start()

    local actions = M.spoon.actions.actions()
    M.hotkeys = {}
    for _, binding in ipairs(M.keymap) do
        local spaceNumber = binding.action:match("^switch_space_(%d)$")
        local moveNumber = binding.action:match("^move_window_(%d)$")
        local callback
        if spaceNumber then
            callback = function() M.switchExternalSpace(tonumber(spaceNumber)) end
        elseif moveNumber then
            callback = function() M.moveWindowToExternalSpace(tonumber(moveNumber)) end
        else
            callback = assert(actions[binding.action], "Unknown PaperWM action: " .. binding.action)
        end
        table.insert(M.hotkeys, rightCommand.bind(binding.mods, binding.key, callback, binding.repeatable))
    end
    return M
end

local function externalSpaceID(index)
    local screen = hs.screen.find("H27P22P")
    if not screen then return nil end
    local userSpaces = {}
    for _, spaceID in ipairs(hs.spaces.spacesForScreen(screen) or {}) do
        if hs.spaces.spaceType(spaceID) == "user" then table.insert(userSpaces, spaceID) end
    end
    return userSpaces[index]
end

local function realDependencies()
    local screen = hs.screen.find("H27P22P")
    return {
        userSpaces = function()
            if not screen then return {} end
            local result = {}
            for _, spaceID in ipairs(hs.spaces.spacesForScreen(screen) or {}) do
                if hs.spaces.spaceType(spaceID) == "user" then table.insert(result, spaceID) end
            end
            return result
        end,
        addSpace = function(closeMissionControl)
            if not screen then return nil, "找不到外接显示器 H27P22P" end
            return hs.spaces.addSpaceToScreen(screen, closeMissionControl)
        end,
        closeMissionControl = hs.spaces.closeMissionControl,
        waitForSpace = function(index, callback)
            local deadline = hs.timer.secondsSinceEpoch() + 5
            local timer
            local function finish(spaceID, errorMessage)
                if timer then timer:stop(); M.spaceTimers[timer] = nil end
                callback(spaceID, errorMessage)
            end
            local function check()
                local spaces = realDependencies().userSpaces()
                if spaces[index] then
                    finish(spaces[index])
                elseif hs.timer.secondsSinceEpoch() >= deadline then
                    finish(nil, "等待新 Space 出现超时")
                end
            end
            timer = hs.timer.doEvery(0.1, check)
            M.spaceTimers[timer] = true
            check()
        end,
    }
end

function M.ensureExternalSpace(index, callback, dependencies)
    local deps = dependencies or realDependencies()
    local spaces = deps.userSpaces()
    if spaces[index] then callback(spaces[index]); return end

    for number = #spaces + 1, index do
        local closeMissionControl = number == index
        local created, errorMessage = deps.addSpace(closeMissionControl)
        if not created then
            if deps.closeMissionControl then deps.closeMissionControl() end
            callback(nil, errorMessage)
            return
        end
    end

    deps.waitForSpace(index, callback)
end

local function globalSpaceIndex(spaceID)
    local index = 0
    for _, screen in ipairs(hs.screen.allScreens()) do
        for _, candidate in ipairs(hs.spaces.allSpaces()[screen:getUUID()] or {}) do
            index = index + 1
            if candidate == spaceID then return index end
        end
    end
    return nil
end

function M.switchExternalSpace(index)
    local spaceID = externalSpaceID(index)
    if spaceID then M.spoon.space.switchToSpaceID(spaceID) end
end

function M.moveWindowToExternalSpace(index)
    if M.creatingSpace then
        hs.alert.show("正在创建 Space，请稍候")
        return
    end

    local window = hs.window.focusedWindow()
    if not window then return end
    M.creatingSpace = true

    M.ensureExternalSpace(index, function(spaceID, errorMessage)
        M.creatingSpace = false
        if not spaceID then
            hs.notify.show("PaperWM", "无法创建 Space " .. tostring(index), tostring(errorMessage))
            return
        end

        local globalIndex = globalSpaceIndex(spaceID)
        if globalIndex then
            window:focus()
            M.spoon.space.moveWindowToSpace(globalIndex)
        end
    end)
end

function M.stop()
    for timer in pairs(M.spaceTimers or {}) do timer:stop() end
    M.spaceTimers = {}
    M.creatingSpace = false
    if M.hotkeys then require("modules.window_management.right_command").unbind(M.hotkeys); M.hotkeys = nil end
    if M.spoon then M.spoon:stop(); M.spoon = nil end
end

M.spaceTimers = {}

return M
