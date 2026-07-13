local home = assert(os.getenv("HOME"), "HOME is required")
local configRoot = home .. "/.config/hammerspoon"
package.path = configRoot .. "/?.lua;" .. package.path
assert(package.searchpath("core.module_loader", package.path) == configRoot .. "/core/module_loader.lua")

local modules = {
    (require("modules.window_management.aerospace_feature")),
    (require("modules.window_management.app_switcher")),
    (require("modules.system.media_controls")),
}

local seen = {}
local total = 0

local function signature(binding)
    local modifiers = {}
    for _, modifier in ipairs(binding.mods) do table.insert(modifiers, modifier) end
    table.sort(modifiers)
    return table.concat(modifiers, "+") .. "+" .. binding.key
end

for _, module in ipairs(modules) do
    for _, binding in ipairs(module.keymap) do
        local key = signature(binding)
        assert(not seen[key], "duplicate key binding: " .. key)
        seen[key] = binding.action
        total = total + 1
    end
end

assert(total == 44, "expected 44 right-Command bindings, got " .. total)
assert(seen["rCmd+h"] == "focus_left")
assert(seen["lShift+rCmd+l"] == "swap_right")
assert(seen["rCmd+t"] == "ghostty")
assert(seen["rCmd+b"] == "browser")
assert(seen["rCmd+space"] == "play_pause")
assert(seen["rCmd+."] == "next")
assert(seen["rCmd+,"] == nil, "comma must stay unbound")
assert(seen["rCmd+]"] == "toggle_tiling_layout")
assert(seen["lShift+rCmd+]"] == "join_right")
assert(seen["rCmd+a"] == "window_chooser")
assert(seen["rCmd+tab"] == nil, "Cmd-Tab is reserved by macOS")

print("keymap tests passed")
