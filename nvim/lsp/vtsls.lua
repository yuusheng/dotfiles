-- Keep in function to get the value of $MASON
local vue_language_server_path = vim.fn.expand("$MASON/packages")
  .. "/vue-language-server"
  .. "/node_modules/@vue/language-server"

local tsserver_filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" }
local vue_plugin = {
  name = "@vue/typescript-plugin",
  location = vue_language_server_path,
  languages = { "vue" },
  configNamespace = "typescript",
  enableForWorkspaceTypeScriptVersions = true,
}

if vim.g.use_tsgo then
  return
end

---@type vim.lsp.Config
return {
  cmd = { "vtsls", "--stdio" },
  init_options = {
    hostInfo = "neovim",
  },
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {
          vue_plugin,
        },
      },
    },
  },
  filetypes = tsserver_filetypes,
  root_dir = function(bufnr, on_dir)
    -- The project root is where the LSP can be started from
    -- As stated in the documentation above, this LSP supports monorepos and simple projects.
    -- We select then from the project root, which is identified by the presence of a package
    -- manager lock file.
    local root_markers = { "package-lock.json", "yarn.lock", "pnpm-lock.yaml", "bun.lockb", "bun.lock" }
    -- Give the root markers equal priority by wrapping them in a table
    root_markers = vim.fn.has("nvim-0.11.3") == 1 and { root_markers, { ".git" } }
      or vim.list_extend(root_markers, { ".git" })
    -- We fallback to the current working directory if no project root is found
    local project_root = vim.fs.root(bufnr, root_markers) or vim.fn.getcwd()

    on_dir(project_root)
  end,
}
