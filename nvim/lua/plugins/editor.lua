return {
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
    "kevinhwang91/nvim-ufo",
    event = "BufReadPost",
    dependencies = { "kevinhwang91/promise-async" },
    opts = {
      provider_selector = function()
        return { "lsp", "indent" }
      end,
      fold_virt_text_handler = function(virtText, lnum, endLnum, width, truncate)
        vim.api.nvim_set_hl(0, "UfoFoldSuffix", { fg = "#AE9F86" })
        local newVirtText = {}
        local suffix = (" 󰁂 %d "):format(endLnum - lnum)
        local sufWidth = vim.fn.strdisplaywidth(suffix)
        local targetWidth = width - sufWidth
        local curWidth = 0
        for _, chunk in ipairs(virtText) do
          local chunkText = chunk[1]
          local chunkWidth = vim.fn.strdisplaywidth(chunkText)
          if targetWidth > curWidth + chunkWidth then
            table.insert(newVirtText, chunk)
          else
            chunkText = truncate(chunkText, targetWidth - curWidth)
            local hlGroup = chunk[2]
            table.insert(newVirtText, { chunkText, hlGroup })
            chunkWidth = vim.fn.strdisplaywidth(chunkText)
            if curWidth + chunkWidth < targetWidth then
              suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
            end
            break
          end
          curWidth = curWidth + chunkWidth
        end
        table.insert(newVirtText, { suffix, "UfoFoldSuffix" })
        return newVirtText
      end,
    },
    keys = {
      {
        "zR",
        function()
          require("ufo").openAllFolds()
        end,
        desc = "Open all folds",
      },
      {
        "zM",
        function()
          require("ufo").closeAllFolds()
        end,
        desc = "Close all folds",
      },
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
    dependencies = {
      "refractalize/oil-git-status.nvim",
      "JezerM/oil-lsp-diagnostics.nvim",
    },
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
          ["<C-f>"] = {
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
          ["<C-g>"] = {
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
          signcolumn = "yes:2",
          winbar = "%!v:lua.get_oil_winbar()",
        },
      })

      require("oil-git-status").setup({})
      require("oil-lsp-diagnostics").setup()
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
    opts = {},
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
}
