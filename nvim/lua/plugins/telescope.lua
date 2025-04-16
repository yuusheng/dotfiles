return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    {
      "nvim-telescope/telescope-live-grep-args.nvim",
      version = "^1.0.0",
    },
    "Marskey/telescope-sg",
  },
  opts = function()
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

    -- live grep with args setup
    local telescope = require("telescope")
    local lga_actions = require("telescope-live-grep-args.actions")

    telescope.setup({
      defaults = {
        sorting_strategy = "ascending",
        layout_config = {
          horizontal = {
            prompt_position = "top",
            preview_width = 0.55,
          },
          width = 0.87,
          height = 0.80,
        },
      },
      extensions = {
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
      },
    })

    telescope.load_extension("live_grep_args")
    telescope.load_extension("ast_grep")
  end,
  keys = {
    {
      "<leader>sg",
      function()
        require("telescope").extensions.live_grep_args.live_grep_args()
      end,
      desc = "Live grep with args (Root Dir)",
    },
    {
      "<leader>sp",
      "<cmd>Telescope ast_grep<CR>",
      desc = "Ast grep",
    },
  },
}
