local M = {}

function M.new(dependencies)
    local loader = { started = {} }

    function loader:startAll(specifications)
        for _, specification in ipairs(specifications) do
            if specification.enabled then
                local ok, moduleOrError = pcall(dependencies.requireModule, specification.name)
                if ok and type(moduleOrError) == "table" and type(moduleOrError.start) == "function" then
                    local started, startError = pcall(moduleOrError.start)
                    if started then
                        table.insert(self.started, { name = specification.name, module = moduleOrError })
                    else
                        if type(moduleOrError.stop) == "function" then
                            local cleaned, cleanupError = pcall(moduleOrError.stop)
                            if not cleaned then dependencies.onError(specification.name, cleanupError) end
                        end
                        dependencies.onError(specification.name, startError)
                    end
                else
                    dependencies.onError(specification.name, moduleOrError or "module has no start()")
                end
            end
        end
    end

    function loader:stopAll()
        for index = #self.started, 1, -1 do
            local entry = self.started[index]
            if type(entry.module.stop) == "function" then
                local ok, stopError = pcall(entry.module.stop)
                if not ok then dependencies.onError(entry.name, stopError) end
            end
        end
        self.started = {}
    end

    return loader
end

return M
