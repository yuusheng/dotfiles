require("hs.ipc")

local features = require("features")

featureLoader = require("core.module_loader").new({
    requireModule = require,
    onError = function(name, message)
        local text = "Failed to load " .. tostring(name) .. ": " .. tostring(message)
        print(text)
        hs.notify.show("Hammerspoon 配置错误", name, tostring(message))
    end,
})

featureLoader:startAll({
    { name = "modules.reading.books_navigation", enabled = features.books_navigation },
    { name = "modules.maintenance.brew_upgrade", enabled = features.brew_upgrade },
    { name = "modules.system.spoon_manager", enabled = features.spoon_manager },
    { name = "modules.system.reload_configuration", enabled = features.reload_configuration },
    { name = "modules.window_management.right_command", enabled = features.right_command },
    { name = "modules.window_management.paperwm_feature", enabled = features.paperwm },
    { name = "modules.window_management.aerospace_feature", enabled = features.aerospace },
    { name = "modules.window_management.app_switcher", enabled = features.app_switcher },
    { name = "modules.system.input_source", enabled = features.input_source },
    { name = "modules.system.media_controls", enabled = features.media_controls },
})

hs.shutdownCallback = function()
    featureLoader:stopAll()
end
