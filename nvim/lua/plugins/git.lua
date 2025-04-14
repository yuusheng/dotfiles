local keymap = require("which-key")

return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = true,
    keys = {
      {
        "<leader>gn",
        function()
          require("neogit").open({ kind = "floating" })
        end,
        desc = "Open Neogit",
      },
      {
        "<leader>gC",
        function()
          require("neogit").open({ "commit", kind = "floating" })
        end,
        desc = "Open Neogit commit",
      },
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
