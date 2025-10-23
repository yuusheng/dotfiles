return {
  {
    "mrcjkb/rustaceanvim",
    opts = {
      tools = {
        float_win_config = {
          border = "rounded",
        },
      },
      server = {
        on_attach = function(_, bufnr)
          vim.keymap.set("n", "<leader>cR", function()
            vim.cmd.RustLsp("codeAction")
          end, { desc = "Code Action", buffer = bufnr })
          vim.keymap.set("n", "<leader>dr", function()
            vim.cmd.RustLsp("debuggables")
          end, { desc = "Rust Debuggables", buffer = bufnr })
          vim.keymap.set(
            "n",
            "K",
            require("plugins.lang.rust.super_hover"),
            { buffer = bufnr, desc = "Rust hover actions" }
          )
        end,
      },
    },
  },
  {
    "cordx56/rustowl",
    version = "*", -- Latest stable version
    build = "cargo binstall rustowl",
    lazy = false, -- This plugin is already lazy
    opts = {
      client = {
        on_attach = function(_, buffer)
          vim.keymap.set("n", "<leader>ro", function()
            require("rustowl").toggle(buffer)
          end, { buffer = buffer, desc = "Toggle RustOwl" })
        end,
      },
      highlight_style = "underline",
    },
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "rust-analyzer" },
    },
  },
}
