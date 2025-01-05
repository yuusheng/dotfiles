return {
  {
    "kdheepak/lazygit.nvim",
    event = "VeryLazy",
    keys = {
      {
        ";c",
        ":LazyGit<Return>",
        silent = true,
        noremap = true,
      },
    },
    -- optional for floating window border decoration
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function() end,
  },
  {
    "sindrets/diffview.nvim",
    config = function()
      require("diffview").setup({})
    end,
    keys = {
      {
        "<leader>gd",
        "<Cmd>DiffviewOpen<CR>",
        desc = "open diffview",
      },
      {
        "<leader>gD",
        "<Cmd>DiffviewClose<CR>",
        desc = "close diffview",
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
