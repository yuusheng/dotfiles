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
    "blink.cmp",
    opts = {
      keymap = {
        ["<Tab>"] = {
          function(cmp)
            if cmp.snippet_active() then
              return cmp.accept()
            else
              return cmp.select_and_accept()
            end
          end,
          "snippet_forward",
          "fallback",
        },
        ["<S-Tab>"] = { "snippet_backward", "fallback" },
      },
    },
  },
  {
    "ibhagwan/fzf-lua",
    opts = function(_, opts)
      opts.grep.rg_glob_fn = function(query)
        local regex, flags = query:match("^(.-)%s%-%-(.*)$")
        -- If no separator is detected will return the original query
        return (regex or query), flags
      end
      opts.grep.rg_glob = true
    end,
    keys = {
      {
        "<leader>sp",
        function()
          require("fzf-lua").fzf_live("ast-grep run --color=always -p <query>", {
            previewer = "builtin",
            prompt = "Ast Grep>",
            fzf_opts = {
              ["--delimiter"] = ":",
              ["--with-nth"] = "2..",
            },
          })
        end,
      },
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
}
