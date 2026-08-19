local fff = require("utils.fff")
local picker_theme = require("utils.picker_theme")

return {
  {
    "dmtrKovalenko/fff",
    build = function()
      require("fff.download").download_or_build_binary()
    end,
    lazy = true,
    init = function()
      picker_theme.setup()
    end,
    opts = {
      lazy_sync = true,
      prompt_vim_mode = true,
      keymaps = {
        focus_list = "<A-w>",
        focus_preview = "<A-w>",
      },
      layout = {
        prompt_position = "top",
      },
      grep = {
        modes = { "plain", "regex", "fuzzy" },
        enable_filename_constraint = true,
      },
      debug = {
        enabled = true,
        show_scores = true,
      },
      hl = {
        matched = "UnifiedPickerMatch",
        prompt = "UnifiedPickerPrompt",
        cursor = "UnifiedPickerSelection",
        grep_match = "UnifiedPickerMatch",
        winhl = {
          prompt = table.concat({
            "Normal:UnifiedPickerInput",
            "FloatBorder:UnifiedPickerInputBorder",
            "FloatTitle:UnifiedPickerInputTitle",
          }, ","),
          list = table.concat({
            "Normal:UnifiedPickerList",
            "FloatBorder:UnifiedPickerListBorder",
            "FloatTitle:UnifiedPickerListTitle",
          }, ","),
          preview = table.concat({
            "Normal:UnifiedPickerPreview",
            "FloatBorder:UnifiedPickerPreviewBorder",
            "FloatTitle:UnifiedPickerPreviewTitle",
          }, ","),
          file_info = table.concat({
            "Normal:UnifiedPickerPreview",
            "FloatBorder:UnifiedPickerPreviewBorder",
            "FloatTitle:UnifiedPickerPreviewTitle",
          }, ","),
        },
      },
    },
    keys = {
      {
        "<leader><space>",
        function()
          fff.find_files(fff.cwd())
        end,
        desc = "FFF Find Files (cwd)",
      },
      {
        "<leader>ff",
        function()
          fff.find_files(fff.cwd())
        end,
        desc = "FFF Find Files (cwd)",
      },
      {
        "<leader>fF",
        function()
          fff.find_files(fff.root())
        end,
        desc = "FFF Find Files (Root)",
      },
      { "<leader>fd", fff.find_in_directory, desc = "FFF Find Files in Directory" },
      {
        "<leader>/",
        function()
          fff.live_grep(fff.cwd())
        end,
        desc = "FFF Grep (cwd)",
      },
      {
        "<leader>sg",
        function()
          fff.live_grep(fff.cwd())
        end,
        desc = "FFF Grep (cwd)",
      },
      {
        "<leader>sG",
        function()
          fff.live_grep(fff.root())
        end,
        desc = "FFF Grep (Root)",
      },
      { "<leader>sF", fff.grep_in_directory, desc = "FFF Grep in Directory" },
      {
        "<leader>sw",
        function()
          fff.grep_under_cursor(fff.cwd())
        end,
        mode = { "n", "x" },
        desc = "FFF Search Word/Selection (cwd)",
      },
      {
        "<leader>sW",
        function()
          fff.grep_under_cursor(fff.root())
        end,
        mode = { "n", "x" },
        desc = "FFF Search Word/Selection (Root)",
      },
      {
        "<leader>sR",
        function()
          require("fff").resume()
        end,
        desc = "FFF Resume",
      },
    },
  },
}
