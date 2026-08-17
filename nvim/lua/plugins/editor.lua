return {
  -- Hihglight colors
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
        "<leader>sp",
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
    "ThePrimeagen/refactoring.nvim",
    event = function()
      return {}
    end,
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
    "windwp/nvim-ts-autotag",
    event = function()
      return {}
    end,
    ft = {
      "astro",
      "blade",
      "dot",
      "elixir",
      "eruby",
      "glimmer",
      "handlebars",
      "hbs",
      "heex",
      "html",
      "htmlangular",
      "htmldjango",
      "javascript",
      "javascript.glimmer",
      "javascript.jsx",
      "javascriptreact",
      "liquid",
      "markdown",
      "php",
      "rescript",
      "rust",
      "svelte",
      "templ",
      "twig",
      "typescript",
      "typescript.glimmer",
      "typescript.tsx",
      "typescriptreact",
      "vento",
      "vue",
      "xml",
    },
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
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
  {
    "stevearc/oil.nvim",
    keys = {
      {
        "<leader>e",
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
          ["<C-s>"] = false,
          ["<leader>s"] = { "actions.select", opts = { vertical = true } },
          ["<leader>h"] = { "actions.select", opts = { horizontal = true } },
          ["<C-r>"] = "actions.refresh",
          ["l"] = "actions.select",
          ["h"] = "actions.parent",
          ["q"] = "actions.close",
          ["<leader>e"] = "actions.close",
          -- relative
          ["<leader>yr"] = { "actions.yank_entry", opts = { modify = ":." } },
          -- absolute
          ["<leader>ya"] = { "actions.yank_entry" },

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
          ["<leader>ff"] = {
            function()
              local dir = require("oil").get_current_dir()
              if dir then
                require("fff").find_files_in_dir(dir)
              end
            end,
            mode = "n",
            nowait = true,
            desc = "Find files in the current directory",
          },
          ["<D-f>"] = {
            function()
              local dir = require("oil").get_current_dir()
              if dir then
                require("fff").live_grep({ cwd = dir, title = "Grep in " .. vim.fn.fnamemodify(dir, ":~") })
              end
            end,
            mode = "n",
            nowait = true,
            desc = "Grep in the current directory",
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
          vim.keymap.set({ "n", "t" }, "<D-k>", function()
            if vim.bo.buftype ~= "terminal" then
              return
            end

            local job_id = vim.b.terminal_job_id
            if not job_id then
              return
            end

            vim.fn.chansend(job_id, "printf '\\033c'\n")
          end, { buffer = buf })
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
    "Bekaboo/dropbar.nvim",
    -- optional, but required for fuzzy finder support
    dependencies = {
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
      },
    },
    config = function()
      local dropbar_api = require("dropbar.api")
      vim.keymap.set("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
      vim.keymap.set("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
      vim.keymap.set("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })
    end,
  },
  {
    "mluders/comfy-line-numbers.nvim",
    opts = function()
      require("comfy-line-numbers").setup()
    end,
  },
  {
    "folke/which-key.nvim",
    opts = function(_, opts)
      opts.spec = opts.spec or {}

      -- hide harpoon keymaps
      for i = 1, 9 do
        table.insert(opts.spec, {
          "<leader>" .. i,
          hidden = true,
        })
      end
    end,
  },
  {
    "mrjones2014/smart-splits.nvim",
    keys = {
      {
        "<C-h>",
        function()
          require("smart-splits").move_cursor_left()
        end,
      },
      {
        "<C-j>",
        function()
          require("smart-splits").move_cursor_down()
        end,
      },
      {
        "<C-k>",
        function()
          require("smart-splits").move_cursor_up()
        end,
      },
      {
        "<C-l>",
        function()
          require("smart-splits").move_cursor_right()
        end,
      },
    },
  },
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        rust = { "rustfmt", lsp_format = "fallback" },
      },
    },
  },
  {
    "kawre/leetcode.nvim",
    cmd = "Leet",
    opts = {
      lang = "cpp",
      picker = { provider = "snacks-picker" },
      cn = {
        enabled = true, ---@type boolean
        translator = true, ---@type boolean
        translate_problems = true, ---@type boolean
      },
      injector = {
        ["rust"] = {
          before = { "#[allow(dead_code)]", "fn main(){}", "#[allow(dead_code)]", "struct Solution;" },
        },
      },
      hooks = {
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
