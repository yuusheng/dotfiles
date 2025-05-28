local root_file = {
  ".eslintrc",
  ".eslintrc.js",
  ".eslintrc.cjs",
  ".eslintrc.yaml",
  ".eslintrc.yml",
  ".eslintrc.json",
  "eslint.config.js",
  "eslint.config.mjs",
  "eslint.config.cjs",
  "eslint.config.ts",
  "eslint.config.mts",
  "eslint.config.cts",
}

---@param fname string
---@return string|nil
local get_eslint_root = function(fname)
  local util = require("lspconfig.util")
  root_file = util.insert_package_json(root_file, "eslintConfig", fname)
  return util.root_pattern(unpack(root_file))(fname)
end

return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      eslint = {
        root_dir = function(fname, bufnr)
          local root = get_eslint_root(fname)
          if not root then
            return
          end

          return vim.fs.root(bufnr, { ".git", ".vscode" }) or vim.fs.root(bufnr, { "package.json", "node_modules" })
        end,
        settings = {
          workingDirectory = { mode = "auto" },
        },
      },
    },
    setup = {
      eslint = function(_, opts)
        local vscode_config = require("neoconf").get("vscode")
        if vscode_config then
          local eslint_neoconf = vscode_config.eslint or {}
          opts.settings.nodePath = eslint_neoconf.nodePath or ""
        end
        require("lspconfig").eslint.setup(opts)

        require("lazyvim.util").lsp.on_attach(function(client)
          if client.name == "eslint" then
            client.server_capabilities.documentFormattingProvider = true
            --- Volar will format vue file sometimes conflict with eslint. Disable for now
          elseif client.name == "tsserver" or client.name == "volar" then
            client.server_capabilities.documentFormattingProvider = false
          end
        end)
      end,
    },
  },
}
