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
    "chrisgrieser/nvim-spider",
    lazy = true,
    opts = {
      subwordMovement = false,
    },
    keys = {
      { "w", "<cmd>lua require('spider').motion('w')<CR>", mode = { "n", "o", "x" } },
      { "e", "<cmd>lua require('spider').motion('e')<CR>", mode = { "n", "o", "x" } },
      { "b", "<cmd>lua require('spider').motion('b')<CR>", mode = { "n", "o", "x" } },
    },
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
    keys = {
      {
        "<leader>p",
        "<Cmd>Oil<CR>",
        desc = "Open Oil parent directory",
        mode = { "n" },
      },
    },
    lazy = true,
    config = function()
      function _G.get_oil_winbar()
        local dir = require("oil").get_current_dir()
        if dir then
          return vim.fn.fnamemodify(dir, ":~")
        else
          return vim.api.nvim_buf_get_name(0)
        end
      end

      local detail = false

      require("oil").setup({
        delete_to_trash = true,
        skip_confirm_for_simple_edits = true,
        view_options = {
          show_hidden = true,
          natural_order = true,
          is_always_hidden = function(name)
            local never_show = { ".git", ".DS_Store" }
            return vim.tbl_contains(never_show, name)
          end,
        },
        keymaps = {
          ["<C-h>"] = false,
          ["<C-l>"] = false,
          ["<C-r>"] = "actions.refresh",
          ["L"] = "actions.select",
          ["q"] = "actions.close",
          ["gd"] = {
            desc = "Toggle file detail view",
            callback = function()
              detail = not detail
              if detail then
                require("oil").set_columns({ "icon", "permissions", "size", "mtime" })
              else
                require("oil").set_columns({ "icon" })
              end
            end,
          },
        },
        win_options = {
          winbar = "%!v:lua.get_oil_winbar()",
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
    "nvimdev/lspsaga.nvim",
    event = "BufRead",
    dependencies = {
      "nvim-treesitter/nvim-treesitter", -- optional
    },
    opts = {
      ui = {
        code_action = "",
      },
      lightbulb = {
        enable = false,
        virtual_text = false,
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
