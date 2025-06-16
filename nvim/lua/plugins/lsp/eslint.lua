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

        local formatter = LazyVim.lsp.formatter({
          name = "eslint: lsp",
          primary = false,
          -- eslint after conform.nvim(prettier)
          priority = 50,
          filter = "eslint",
        })

        LazyVim.format.register(formatter)
      end,
    },
  },
}
