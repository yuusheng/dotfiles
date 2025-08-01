return {
  -- Hihglight colors
  {
    "echasnovski/mini.hipatterns",
    event = "BufReadPre",
    config = true,
  },
  {
    "rhysd/accelerated-jk",
    event = "VeryLazy",
    keys = {
      { "j", "<Plug>(accelerated_jk_gj)" },
      { "k", "<Plug>(accelerated_jk_gk)" },
    },
  },
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      {
        "<leader>sA",
        function()
          local grug = require("grug-far")
          grug.open({
            engine = "astgrep",
          })
        end,
        mode = { "n", "v" },
        desc = "Search and Replace using ast-grep",
      },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    event = "VeryLazy",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function(plugin)
      if vim.fn.executable("npx") then
        vim.cmd("!cd " .. plugin.dir .. " && cd app && npx --yes yarn install")
      else
        vim.cmd([[lazy load markdown-preview.nvim]])
        vim.fn["mkdp#util#install"]()
      end
    end,
    init = function()
      if vim.fn.executable("npx") then
        vim.g.mkdp_filetypes = { "markdown" }
      end
    end,
  },
  {
    "ethanholz/nvim-lastplace",
    config = true,
  },
  {
    "windwp/nvim-ts-autotag",
    event = "VeryLazy",
    opts = {
      opts = {
        enable_close_on_slash = true,
      },
    },
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    opts = {
      enable_check_bracket_line = true,
    },
  },
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters.sqlfluff = {
        args = { "format", "--dialect=ansi", "-" },
      }

      local sql_ft = { "sql" }

      for _, ft in ipairs(sql_ft) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
        table.insert(opts.formatters_by_ft[ft], "sqlfluff")
      end
    end,
  },
  {
    "rmagatti/goto-preview",
    dependencies = { "rmagatti/logger.nvim" },
    event = "LazyFile",
    opts = {
      post_open_hook = function(bufnr)
        vim.bo[bufnr].buflisted = false
        vim.schedule(function()
          vim.keymap.set("n", "q", function()
            require("goto-preview").close_all_win()
          end, {
            buffer = bufnr,
            silent = true,
            desc = "Quit go to preview window",
          })
        end)
      end,
    },
    keys = {
      {
        "gp",
        "<cmd>lua require('goto-preview').goto_preview_definition()<CR>",
        desc = "Goto Preview Definition",
        {
          noremap = true,
        },
      },
    },
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          always_show = {
            ".gitignore",
            ".github",
            ".nuxt",
            ".vscode",
            ".npmrc",
          },
          always_show_by_pattern = {
            ".env*",
          },
          never_show = {
            ".DS_Store",
          },
        },
      },
    },
  },
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {},
    keys = {
      {
        "<leader>o",
        "<Cmd>Oil<CR>",
        desc = "Open Oil parent directory",
        mode = { "n" },
      },
    },
    lazy = true,
    config = function()
      require("oil").setup({
        delete_to_trash = true,
        skip_confirm_for_simple_edits = true,
        view_options = {
          show_hidden = true,
          natural_order = true,
          is_always_hidden = function(name)
            return name == ".git"
          end,
        },
      })
    end,
  },
  {
    "nvzone/floaterm",
    dependencies = "nvzone/volt",
    cmd = "FloatermToggle",
    opts = {
      mappings = {
        term = function(buf)
          vim.keymap.set({ "n", "t" }, "<C-a>", function()
            require("floaterm.api").new_term()
          end, { buffer = buf })
          -- Normal mode and search
          vim.keymap.set({ "n", "t" }, "<D-f>", "<C-\\><C-n>/", { buffer = buf })
        end,
      },
    },
    keys = {
      {
        "<D-j>",
        "<cmd>FloatermToggle<CR>",
        mode = { "n", "t" },
        desc = "Toggle float term",
      },
    },
  },
}
