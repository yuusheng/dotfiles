return {
  { "folke/lazy.nvim", version = false },
  {
    "LazyVim/LazyVim",
    version = false,
    opts = {
      colorscheme = "catppuccin-mocha",
      news = {
        lazyvim = true,
        neovim = true,
      },
      kind_filter = {
        javascript = {
          "Class",
          "Constructor",
          "Enum",
          "Function",
          "Interface",
          "Module",
          "Method",
          "Struct",
          "Variable",
          "Type",
        },
        typescript = {
          "Class",
          "Constructor",
          "Enum",
          "Function",
          "Interface",
          "Module",
          "Method",
          "Struct",
          "Variable",
          "Type",
        },
      },
    },
  },
}
