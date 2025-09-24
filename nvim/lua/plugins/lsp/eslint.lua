return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ---@type vim.lsp.Config
      eslint = {
        settings = {
          workingDirectory = { mode = "auto" },
        },
      },
    },
    setup = {
      eslint = function(_, opts)
        local nodePath = require("neoconf").get("vscode.eslint.nodePath") or ""
        opts.settings.nodePath = nodePath

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
