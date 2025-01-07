local keymap = require("which-key")

return {
  {
    "kdheepak/lazygit.nvim",
    event = "VeryLazy",
    keys = {
      {
        ";c",
        "<Cmd>LazyGit<CR>",
        silent = true,
        noremap = true,
      },
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
  },
  {
    "sindrets/diffview.nvim",
    opts = {
      enhanced_diff_hl = true,
      hooks = {
        view_enter = function()
          keymap.add({
            {
              "<leader>gd",
              "<Cmd>DiffviewClose<CR>",
              desc = "Close Git Diffview",
            },
          })
        end,
        view_leave = function()
          keymap.add({
            {
              "<leader>gd",
              "<Cmd>DiffviewOpen<CR>",
              desc = "Open Git Diffview",
            },
          })
        end,
      },
    },
    keys = {
      {
        "<leader>gd",
        "<Cmd>DiffviewOpen<CR>",
        desc = "open diffview",
      },
    },
  },
  { "akinsho/git-conflict.nvim", version = "*", config = true },
  {
    "f-person/git-blame.nvim",
    opts = {
      date_format = "%r",
      message_template = "  <author> 󰔠 <date> 󰈚 <summary>  <sha>",
    },
  },
}
