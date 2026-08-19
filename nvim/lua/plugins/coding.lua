return {
  -- Not using extra as some keys conflict with goto-preview.nvim
  {
    "gbprod/yanky.nvim",
    desc = "Better Yank/Paste",
    dependencies = { "folke/snacks.nvim" },
    opts = {
      highlight = { timer = 150 },
    },
    keys = {
      {
        "<leader>yh",
        function()
          Snacks.picker.yanky()
        end,
        mode = { "n", "x" },
        desc = "Open Yank History",
      },
        -- stylua: ignore
      { "y", "<Plug>(YankyYank)", mode = { "n", "x" }, desc = "Yank Text" },
      { "p", "<Plug>(YankyPutAfter)", mode = { "n", "x" }, desc = "Put Text After Cursor" },
      { "P", "<Plug>(YankyPutBefore)", mode = { "n", "x" }, desc = "Put Text Before Cursor" },
      { "[y", "<Plug>(YankyCycleForward)", desc = "Cycle Forward Through Yank History" },
      { "]y", "<Plug>(YankyCycleBackward)", desc = "Cycle Backward Through Yank History" },
      { "]p", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put Indented After Cursor (Linewise)" },
      { "[p", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put Indented Before Cursor (Linewise)" },
      { "]P", "<Plug>(YankyPutIndentAfterLinewise)", desc = "Put Indented After Cursor (Linewise)" },
      { "[P", "<Plug>(YankyPutIndentBeforeLinewise)", desc = "Put Indented Before Cursor (Linewise)" },
      { ">p", "<Plug>(YankyPutIndentAfterShiftRight)", desc = "Put and Indent Right" },
      { "<p", "<Plug>(YankyPutIndentAfterShiftLeft)", desc = "Put and Indent Left" },
      { ">P", "<Plug>(YankyPutIndentBeforeShiftRight)", desc = "Put Before and Indent Right" },
      { "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)", desc = "Put Before and Indent Left" },
      { "=p", "<Plug>(YankyPutAfterFilter)", desc = "Put After Applying a Filter" },
      { "=P", "<Plug>(YankyPutBeforeFilter)", desc = "Put Before Applying a Filter" },
    },
  },
  {
    "mfussenegger/nvim-lint",
    event = function()
      return { "BufWritePost", "InsertLeave" }
    end,
  },
  {
    "folke/which-key.nvim",
    opts = {
      spec = {
        {
          "<leader>y",
          group = "yanky",
        },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft.go = nil
    end,
  },
  {
    "kawre/leetcode.nvim",
    cmd = "Leet",
    lazy = "leetcode.nvim" ~= vim.fn.argv(0, -1),
    opts = {
      arg = "leetcode.nvim",
      lang = "javascript",
      picker = { provider = "snacks-picker" },
      cn = {
        enabled = true,
        translator = true,
        translate_problems = true,
      },
      injector = {
        ["rust"] = {
          before = { "#[allow(dead_code)]", "fn main(){}", "#[allow(dead_code)]", "struct Solution;" },
        }, ---@type table<lc.lang, lc.inject>
      },
      hooks = {
        ---@type fun(question: lc.ui.Question)[]
        ["question_enter"] = {
          function(question)
            if question.lang ~= "rust" then
              return
            end
            local problem_dir = vim.fn.stdpath("data") .. "/leetcode/Cargo.toml"
            local content = [[
              [package]
              name = "leetcode"
              edition = "2024"

              [lib]
              name = "%s"
              path = "%s"

              [dependencies]
              rand = "0.10"
              regex = "1"
              itertools = "0.14.0"
            ]]
            local file = io.open(problem_dir, "w")
            if file then
              local formatted = (content:gsub(" +", "")):format(question.q.frontend_id, question:path())
              file:write(formatted)
              file:close()
            else
              print("Failed to open file: " .. problem_dir)
            end
          end,
        },
      },
    },
  },
}
