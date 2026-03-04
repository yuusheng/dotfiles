return {
  {
    "kylechui/nvim-surround",
    opts = {
      move_cursor = "sticky",
    },
    keys = {
      {
        "sa",
        "<Plug>(nvim-surround-visual)",
        mode = "v",
        desc = "Add a surrounding pair around a motion (visual mode)",
      },
    },
  },
}
