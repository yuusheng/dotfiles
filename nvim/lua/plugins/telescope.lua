---load telescope extensions
LazyVim.on_load("telescope.nvim", function()
  local telescope = require("telescope")
  telescope.load_extension("live_grep_args")
  telescope.load_extension("ast_grep")
  telescope.load_extension("smart_open")
end)

return {
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      {
        "nvim-telescope/telescope-live-grep-args.nvim",
        version = "^1.0.0",
      },
      "Marskey/telescope-sg",
      {
        "danielfalk/smart-open.nvim",
        branch = "0.2.x",
        dependencies = {
          "kkharji/sqlite.lua",
        },
      },
    },
    opts = function(_, opts)
      -- color scheme setup
      local colors = require("catppuccin.palettes").get_palette()
      local TelescopeColor = {
        TelescopeMatching = { fg = colors.flamingo },
        TelescopeSelection = { fg = colors.text, bg = colors.surface0, bold = true },

        TelescopePromptPrefix = { bg = colors.surface0 },
        TelescopePromptNormal = { bg = colors.surface0 },
        TelescopeResultsNormal = { bg = colors.mantle },
        TelescopePreviewNormal = { bg = colors.mantle },
        TelescopePromptBorder = { bg = colors.surface0, fg = colors.surface0 },
        TelescopeResultsBorder = { bg = colors.mantle, fg = colors.mantle },
        TelescopePreviewBorder = { bg = colors.mantle, fg = colors.mantle },
        TelescopePromptTitle = { bg = colors.pink, fg = colors.mantle },
        TelescopeResultsTitle = { fg = colors.mantle },
        TelescopePreviewTitle = { bg = colors.green, fg = colors.mantle },
      }

      for hl, col in pairs(TelescopeColor) do
        vim.api.nvim_set_hl(0, hl, col)
      end

      opts.defaults = vim.tbl_deep_extend("force", opts.defaults or {}, {
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
          },
          width = 0.87,
          height = 0.80,
        },
      })

      local actions = require("telescope.actions")
      opts.pickers = vim.tbl_deep_extend("force", opts.pickers, {
        buffers = {
          mappings = {
            i = {
              ["<C-x>"] = actions.delete_buffer + actions.move_to_top,
            },
          },
        },
      })

      local lga_actions = require("telescope-live-grep-args.actions")
      opts.extensions = {
        live_grep_args = {
          auto_quoting = true,
          mappings = {
            i = {
              ["<C-k>"] = lga_actions.quote_prompt(),
              ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
              ["<C-l>"] = lga_actions.quote_prompt({ postfix = " --no-ignore" }),
            },
          },
        },
        ast_grep = {
          command = {
            "sg",
            "--json=stream",
          }, -- must have --json=stream
          grep_open_files = false, -- search in opened files
          lang = nil, -- string value, specify language for ast-grep `nil` for default
        },
      }
    end,
    keys = {
      {
        "<leader>sg",
        "<cmd>Telescope live_grep_args<CR>",
        desc = "Live grep with args (Root Dir)",
      },
      {
        "<leader>sp",
        "<cmd>Telescope ast_grep<CR>",
        desc = "Ast grep",
      },
      {
        "<leader><Space>",
        "<cmd>Telescope smart_open<CR>",
        desc = "Smart Open (recently opened files)",
      },
    },
  },
}
