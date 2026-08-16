local fff = require("utils.fff")
local picker_theme = require("utils.picker_theme")

return {
  {
    "dmtrKovalenko/fff",
    build = function()
      require("fff.download").download_or_build_binary()
    end,
    lazy = false,
    init = function()
      picker_theme.setup()
    end,
    opts = {
      lazy_sync = true,
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
          fff.find_files(fff.root())
        end,
        desc = "FFF Find Files (Root)",
      },
      {
        "<leader>ff",
        function()
          fff.find_files(fff.root())
        end,
        desc = "FFF Find Files (Root)",
      },
      {
        "<leader>fF",
        function()
          fff.find_files(fff.cwd())
        end,
        desc = "FFF Find Files (cwd)",
      },
      { "<leader>fd", fff.find_in_directory, desc = "FFF Find Files in Directory" },
      {
        "<leader>/",
        function()
          fff.live_grep(fff.root())
        end,
        desc = "FFF Grep (Root)",
      },
      {
        "<leader>sg",
        function()
          fff.live_grep(fff.root())
        end,
        desc = "FFF Grep (Root)",
      },
      {
        "<leader>sG",
        function()
          fff.live_grep(fff.cwd())
        end,
        desc = "FFF Grep (cwd)",
      },
      { "<leader>sF", fff.grep_in_directory, desc = "FFF Grep in Directory" },
      {
        "<leader>sw",
        function()
          fff.grep_under_cursor(fff.root())
        end,
        mode = { "n", "x" },
        desc = "FFF Search Word/Selection (Root)",
      },
      {
        "<leader>sW",
        function()
          fff.grep_under_cursor(fff.cwd())
        end,
        mode = { "n", "x" },
        desc = "FFF Search Word/Selection (cwd)",
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
