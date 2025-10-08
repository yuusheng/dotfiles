local lsp_util = require("utils.lsp")

lsp_util.apply_ui_tweaks()
lsp_util.on_attach(lsp_util.on_attach_default)
lsp_util.on_attach(require("utils.lsp.keymap").on_attach)

return {
  {
    "mrjones2014/codesettings.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {},
    config = function(_, opts)
      local codesettings = require("codesettings")
      codesettings.setup(opts)

      LazyVim.format.register(LazyVim.lsp.formatter())

      local enabled_lsp = vim
        .iter(vim.api.nvim_get_runtime_file("lsp/*.lua", true))
        :filter(function(f)
          return not not string.find(f, vim.fn.stdpath("config"), 1, true)
        end)
        :map(function(f)
          return vim.fn.fnamemodify(f, ":t:r")
        end)
        :totable()

      -- enable all LSPs defined under lsp/
      vim.lsp.enable(enabled_lsp)

      vim.lsp.config("*", {
        before_init = function(params, config)
          config = codesettings.with_local_settings(config.name, config)
          return params, config
        end,
      })

      require("mason-lspconfig").setup({
        ensure_installed = vim.list_extend(enabled_lsp, LazyVim.opts("mason-lspconfig.nvim").ensure_installed or {}),
      })
    end,
    event = "VeryLazy",
  },
  {
    "mason-org/mason.nvim",
    event = { "BufReadPost", "BufNewFile", "VimEnter" },
  },
  { "mason-org/mason-lspconfig.nvim", config = function() end },
  {
    "mhanberg/output-panel.nvim",
    version = "*",
    event = "VeryLazy",
    opts = {
      max_buffer_size = 5000, -- default
    },
    cmd = { "OutputPanel" },
  },
  {
    "isak102/ghostty.nvim",
    ft = "conf",
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    enabled = false,
  },
}
