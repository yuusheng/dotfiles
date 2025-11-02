return {
  {
    "nvim-treesitter/nvim-treesitter",
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
    },
  },
  {
    "nvim-mini/mini.ai",
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
          -- u = ai.gen_spec.function_call({ name_pattern = "[%w_%.%!%?]" }),
          -- U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
          u = ai.gen_spec.treesitter({
            a = { "@call.outer" },
            i = { "@call.inner" },
          }),
          p = ai.gen_spec.treesitter({
            a = { "@parameter.outer", "@attribute.outer" },
            i = { "@parameter.inner", "@attribute.inner" },
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
        disabledDefaults = { "io", "ao", "n" },
      },
      notify = {
        whenObjectNotFound = false,
      },
    },
    keys = function()
      local various = require("various-textobjs")
      local core = require("various-textobjs.charwise-core")

      local function smallForward()
        return require("various-textobjs.config.config").config.forwardLooking.small
      end

      return {
        {
          "as",
          function()
            various.subword("outer")
          end,
          mode = { "o", "x" },
          desc = "Select Outer Subword",
        },
        {
          "is",
          function()
            various.subword("inner")
          end,
          mode = { "o", "x" },
          desc = "Select Inner Subword",
        },
        {
          "n",
          -- A more powerful n motion command. Eg. 3n could jump to the 3rd next search result.
          function()
            local count = (vim.v.count == 0 and 1 or vim.v.count) - 1
            local pattern = "().(%S%s*)$"
            local row, _, endCol = core.getTextobjPos(pattern, "inner", 0)
            local targetCol = math.max(0, endCol - count)
            core.selectFromCursorTo({ row, targetCol }, smallForward())
          end,
          mode = { "o", "x" },
          desc = "Select to neear End of Line",
        },
        { "ir", "i[", mode = { "o", "x" } },
        { "ar", "a[", mode = { "o", "x" } },
        {
          "dsi",
          function()
            -- select outer indentation
            require("various-textobjs").indentation("outer", "outer")

            -- plugin only switches to visual mode when a textobj has been found
            local indentationFound = vim.fn.mode():find("V")
            if not indentationFound then
              return
            end

            -- dedent indentation
            vim.cmd.normal({ "<", bang = true })

            -- delete surrounding lines
            local endBorderLn = vim.api.nvim_buf_get_mark(0, ">")[1]
            local startBorderLn = vim.api.nvim_buf_get_mark(0, "<")[1]
            vim.cmd(tostring(endBorderLn) .. " delete") -- delete end first so line index is not shifted
            vim.cmd(tostring(startBorderLn) .. " delete")
          end,
          desc = "Delete Surrounding Indentation",
          mode = "n",
        },
      }
    end,
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
