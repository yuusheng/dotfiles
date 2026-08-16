local picker_theme = require("utils.picker_theme")

return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader><space>", false },
      { "<leader>/", false },
      { "<leader>ff", false },
      { "<leader>fF", false },
      { "<leader>gd", false },
      { "<leader>sg", false },
      { "<leader>sG", false },
      { "<leader>sw", false, mode = { "n", "x" } },
      { "<leader>sW", false, mode = { "n", "x" } },
      { "<leader>sR", false },
      { "<leader>sp", false },
      {
        "<leader>sI",
        function()
          Snacks.picker.grep({ cwd = LazyVim.root(), hidden = true, ignored = true })
        end,
        desc = "Grep Ignored Files (Root)",
      },
    },
    opts = function(_, opts)
      opts.picker = opts.picker or {}
      opts.picker.layout = { preset = "telescope_catppuccin" }
      opts.picker.layouts = opts.picker.layouts or {}
      opts.picker.layouts.telescope_catppuccin = {
        layout = {
          box = "horizontal",
          backdrop = false,
          width = 0.87,
          height = 0.80,
          border = "none",
          {
            box = "vertical",
            {
              win = "input",
              height = 1,
              border = true,
              title = "{title} {live} {flags}",
              title_pos = "center",
            },
            {
              win = "list",
              title = " Results ",
              title_pos = "center",
              border = true,
            },
          },
          {
            win = "preview",
            title = "{preview:Preview}",
            title_pos = "center",
            width = 0.55,
            border = true,
          },
        },
      }
    end,
    init = function()
      picker_theme.setup()
    end,
  },
}
