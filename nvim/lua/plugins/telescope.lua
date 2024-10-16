return {
  "nvim-telescope/telescope.nvim",
  priority = 1000,
  dependencies = {
    {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
    "nvim-telescope/telescope-file-browser.nvim",
    "nvim-telescope/telescope-live-grep-args.nvim",
  },
  keys = {
    {
      ";f",
      function()
        require("telescope.builtin").find_files()
      end,
      desc = "lists files in your current working directory, respects .gitignore",
    },
    {
      ";g",
      function()
        require("telescope").extensions.live_grep_args.live_grep_args()
      end,
      desc = "search for a string in your current working directory ane get results live as you type, respects .gitignore",
    },
    {
      ";b",
      function()
        require("telescope.builtin").buffers()
      end,
      desc = "lists open buffers",
    },
    {
      ";;",
      function()
        require("telescope.builtin").resume()
      end,
      desc = "resume the previous telescope picker",
    },
    {
      ";d",
      function()
        require("telescope.builtin").diagnostics()
      end,
      desc = "lists diagnostics for all open buffers or a specific buffer",
    },
    {
      ";s",
      function()
        require("telescope.builtin").treesitter()
      end,
      desc = "lists function names, variables, from treesitter",
    },
    {
      "ff",
      function()
        require("telescope.builtin").current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          -- previewer = false,
        }))
      end,
      desc = "find content in current buffer",
    },
    {
      "sf",
      function()
        local telescope = require("telescope")

        local function telescope_buffer_dir()
          return vim.fn.expand("%:p:h")
        end

        telescope.extensions.file_browser.file_browser({
          path = "%:p:h",
          cwd = telescope_buffer_dir(),
          respect_gitignore = false,
          hidden = true,
          grouped = true,
          previewer = false,
          initial_mode = "normal",
          layout_config = { height = 40 },
        })
      end,
      desc = "open file browser with the path of the current buffer",
    },
  },
  config = function(_, opts)
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local fb_actions = telescope.extensions.file_browser.actions

    opts.defaults = vim.tbl_deep_extend("force", opts.defaults, {
      wrap_results = true,
      layout_strategy = "horizontal",
      layout_config = { prompt_position = "top" },
      sorting_strategy = "ascending",
      winblend = 0,
      mappings = {
        n = {},
      },
    })
    opts.pickers = {
      diagnostics = {
        theme = "ivy",
        initial_mode = "normal",
        layout_config = {
          preview_cutoff = 9999,
        },
      },
    }
    opts.extensions = {
      file_browser = {
        theme = "dropdown",
        -- disables netrw and use telescope-file-browser in its place
        hijack_netrw = true,
        mappings = {
          -- your custom insert mode mappings
          ["n"] = {
            -- your custom normal mode mappings
            ["n"] = fb_actions.create,
            ["h"] = fb_actions.goto_parent_dir,
            ["<c-u>"] = function(prompt_bufnr)
              for i = 1, 10 do
                actions.move_selection_previous(prompt_bufnr)
              end
            end,
            ["<c-d>"] = function(prompt_bufnr)
              for i = 1, 10 do
                actions.move_selection_next(prompt_bufnr)
              end
            end,
          },
        },
      },
    }
    telescope.setup(opts)
    telescope.load_extension("fzf")
    telescope.load_extension("file_browser")
    telescope.load_extension("live_grep_args")
  end,
}
