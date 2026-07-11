local home = assert(os.getenv("HOME"), "HOME is required")
local configRoot = home .. "/.config/hammerspoon"
package.path = configRoot .. "/?.lua;" .. package.path
assert(package.searchpath("core.module_loader", package.path) == configRoot .. "/core/module_loader.lua")

local inputSource = require("modules.system.input_source")

assert(inputSource.shouldSwitch("com.mitchellh.ghostty"), "Ghostty must switch to English")
assert(not inputSource.shouldSwitch("company.thebrowser.Browser"), "browser input source must be untouched")
assert(not inputSource.shouldSwitch("com.netease.163music"), "music input source must be untouched")
assert(inputSource.englishLayout == "ABC", "expected installed ABC layout")

print("input_source tests passed")
