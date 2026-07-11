package.path = "/Users/yuusheng/.hammerspoon/?.lua;" .. package.path

local paperwm = require("modules.window_management.paperwm_feature")

local function fixture(initialSpaces, failAt)
    local spaces = {}
    for _, id in ipairs(initialSpaces) do table.insert(spaces, id) end
    local calls = {}
    local result

    local dependencies = {
        userSpaces = function() return spaces end,
        addSpace = function(closeMissionControl)
            table.insert(calls, closeMissionControl)
            if failAt and #calls == failAt then return nil, "add failed" end
            table.insert(spaces, 100 + #spaces + 1)
            return true
        end,
        waitForSpace = function(index, callback) callback(spaces[index]) end,
        closeMissionControl = function() calls.closedAfterFailure = true end,
    }

    paperwm.ensureExternalSpace(#initialSpaces, function() end, dependencies)
    calls = {}
    paperwm.ensureExternalSpace(5, function(spaceID, errorMessage)
        result = { spaceID = spaceID, errorMessage = errorMessage }
    end, dependencies)

    return calls, result
end

local calls, result = fixture({ 11, 12 })
assert(#calls == 3, "two existing Spaces should require three additions for Space 5")
assert(calls[1] == false and calls[2] == false and calls[3] == true, "only final addition should close Mission Control")
assert(result.spaceID == 105 and result.errorMessage == nil, "callback should receive newly created Space")

calls, result = fixture({ 11, 12 }, 2)
assert(#calls == 2, "creation must stop at the first failure")
assert(calls.closedAfterFailure, "Mission Control must close after failure")
assert(result.spaceID == nil and result.errorMessage == "add failed", "failure must reach callback")

local existingResult
paperwm.ensureExternalSpace(2, function(spaceID) existingResult = spaceID end, {
    userSpaces = function() return { 11, 12 } end,
    addSpace = function() error("must not create an existing Space") end,
    waitForSpace = function() error("must not wait for an existing Space") end,
})
assert(existingResult == 12, "existing Space should be returned immediately")

print("space_creation tests passed")
