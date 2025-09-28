local plenary_path = require("plenary.path")

---@parma node_id string
local function get_path(node_id)
  ---@type Path
  local path = plenary_path:new(node_id)
  assert(type(path) == "table", "Path is not a table")

  if path:is_dir() then
    return path
  else
    return path:parent()
  end
end

return {
  -- Hihglight colors
  {
    "nvim-mini/mini.hipatterns",
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
            ".*rc",
          },
          never_show = {
            ".DS_Store",
          },
        },
        commands = {
          telescope_grep = function(state)
            local cwd = vim.uv.cwd()
            local path = get_path(state.tree:get_node():get_id())
            local last_directory = path:make_relative(cwd)

            require("telescope").extensions.live_grep_args.live_grep_args({
              search = "",
              cwd = last_directory,
              prompt_title = "Live Grep in " .. last_directory,
            })
          end,
        },
        window = {
          mappings = {
            ["<D-f>"] = "telescope_grep", -- 绑定快捷键
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
          vim.keymap.set({ "n", "t" }, "<Esc>", "<C-\\><C-n>", { buffer = buf })
          vim.keymap.set({ "n", "t" }, "<D-k>", "clear<CR>", { buffer = buf })
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

  {
    "mluders/comfy-line-numbers.nvim",
    opts = function()
      require("comfy-line-numbers").setup()
    end,
  },
}
