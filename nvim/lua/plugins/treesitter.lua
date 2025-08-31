return {
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = {
      "nvim-treesitter/playground",
    },
    event = "VeryLazy",
    opts = {
      ensure_installed = {
        "javascript",
        "typescript",
        "css",
        "gitignore",
        "graphql",
        "http",
        "json",
        "scss",
        "sql",
        "vim",
        "lua",
        "vue",
        "rust",
        "thrift",
        "go",
        "gomod",
        "gowork",
        "gosum",
        "tsx",
        "sql",
        "comment",
      },
      query_linter = {
        enable = true,
        use_virtual_text = true,
        lint_events = { "BufWrite", "CursorHold" },
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<D-k>",
          node_incremental = "<D-k>",
          scope_incremental = false,
          node_decremental = "<D-j>",
        },
      },
    },
  },
  {
    "RRethy/nvim-treesitter-textsubjects",
    config = function()
      require("nvim-treesitter-textsubjects").configure({
        prev_selection = ",",
        keymaps = {
          ["."] = "textsubjects-smart",
          [";"] = "textsubjects-container-outer",
          ["i;"] = "textsubjects-container-inner",
        },
      })
    end,
  },
  {
    "echasnovski/mini.ai",
    opts = function()
      local ai = require("mini.ai")

      return {
        custom_textobjects = {
          o = ai.gen_spec.treesitter({ -- code block
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }), -- class
          t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" }, -- tags
          d = { "%f[%d]%d+" }, -- digits
          e = { -- Word with case
            { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
            "^().*()$",
          },
          g = LazyVim.mini.ai_buffer, -- buffer
          u = ai.gen_spec.function_call({ name_pattern = "[%w_%.%!%?]" }),
          U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
          a = ai.gen_spec.treesitter({
            a = { "@call.outer", "@attribute.outer" },
            i = { "@call.inner", "@attribute.inner" },
          }),
        },
      }
    end,
  },
  {
    "chrisgrieser/nvim-various-textobjs",
    event = "VeryLazy",
    opts = {
      keymaps = {
        useDefaults = true,
      },
      notify = {
        whenObjectNotFound = false,
      },
    },
    keys = {
      {
        "as",
        function()
          require("various-textobjs").subword("outer")
        end,
        mode = { "o", "x" },
        desc = "Select Outer Subword",
      },
      {
        "is",
        function()
          require("various-textobjs").subword("inner")
        end,
        mode = { "o", "x" },
        desc = "Select Inner Subword",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    keys = {
      {
        "gc",
        function()
          require("treesitter-context").go_to_context(vim.v.count1)
        end,
        desc = "Treesitter Context: Go to Context",
      },
    },
  },
}
