local picker_theme = require("utils.picker_theme")

local normal_ignore = {
  -- Node/Web dependencies
  "node_modules",
  "bower_components",
  ".pnpm-store",
  ".npm",
  ".yarn",
  -- Go dependencies
  "vendor",
  -- Python environments and caches
  ".venv",
  "venv",
  ".tox",
  ".nox",
  "__pycache__",
  ".pytest_cache",
  ".mypy_cache",
  ".ruff_cache",
  ".hypothesis",
  ".eggs",
  "*.egg-info",
  "htmlcov",
  -- Rust output
  "target",
  -- Shared Node/Web/Python build and coverage output
  "build",
  "dist",
  "out",
  "coverage",
  ".next",
  ".nuxt",
  ".output",
  ".svelte-kit",
  ".angular",
  ".astro",
  ".cache",
  ".parcel-cache",
  ".turbo",
  ".vite",
}

return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader><space>", false },
      { "<leader>/", false },
      { "<leader>ff", false },
      { "<leader>fF", false },
      {
        "<leader>fi",
        function()
          Snacks.picker.files({
            cwd = vim.uv.cwd(),
            hidden = true,
            ignored = true,
            exclude = normal_ignore,
          })
        end,
        desc = "Find Files incl. Ignored (cwd)",
      },
      { "<leader>gd", false },
      { "<leader>gD", false },
      { "<leader>sg", false },
      { "<leader>sG", false },
      { "<leader>sw", false, mode = { "n", "x" } },
      { "<leader>sW", false, mode = { "n", "x" } },
      { "<leader>sR", false },
      { "<leader>sp", false },
      {
        "<leader>si",
        function()
          Snacks.picker.grep({ cwd = vim.uv.cwd(), hidden = true, ignored = true, exclude = normal_ignore })
        end,
        desc = "Grep Ignored Files (cwd)",
      },
    },
    opts = function(_, opts)
      opts.image = opts.image or {}
      opts.image.enabled = true

      opts.dashboard = opts.dashboard or {}
      opts.dashboard.preset = opts.dashboard.preset or {}
      opts.dashboard.preset.pick = function(cmd, pick_opts)
        local fff = require("utils.fff")
        local cwd = pick_opts and pick_opts.cwd or nil

        if cmd == "files" then
          return fff.find_files(cwd)
        elseif cmd == "live_grep" then
          return fff.live_grep(cwd)
        end

        return LazyVim.pick(cmd, pick_opts)()
      end

      opts.picker = opts.picker or {}
      opts.picker.layout = { preset = "telescope_catppuccin" }
      opts.picker.layouts = opts.picker.layouts or {}
      opts.picker.layouts.telescope_catppuccin = {
        layout = {
          box = "horizontal",
          backdrop = false,
          width = 0.87,
          height = 0.80,
          border = "none",
          {
            box = "vertical",
            {
              win = "input",
              height = 1,
              border = true,
              title = "{title} {live} {flags}",
              title_pos = "center",
            },
            {
              win = "list",
              title = " Results ",
              title_pos = "center",
              border = true,
            },
          },
          {
            win = "preview",
            title = "{preview:Preview}",
            title_pos = "center",
            width = 0.55,
            border = true,
          },
        },
      }
    end,
    init = function()
      picker_theme.setup()
    end,
  },
}
