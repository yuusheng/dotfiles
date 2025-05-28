return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "luacheck",
        "shellcheck",
        "shfmt",
        "tailwindcss-language-server",
        "typescript-language-server",
        "css-lsp",
        "vue-language-server",
        "rust-analyzer",
        "vtsls",
        "markdownlint-cli2",
        "markdown-toc",
        "thriftls",
        "pyright",
        "protols",
        "ast-grep",
        "sqlfluff",
      },
    },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    opts = {
      library = {
        -- See the configuration section for more details
        -- Load luvit types when the `vim.uv` word is found
        { path = "luvit-meta/library", words = { "vim%.uv" } },
      },
    },
  },
  { "Bilal2453/luvit-meta", lazy = true }, -- optional `vim.uv` typings
  -- lsp servers
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = true },
      servers = {
        cssls = {},
        marksman = {},
        protols = {},
        tailwindcss = {
          root_dir = function(...)
            return require("lspconfig.util").root_pattern(".git")(...)
          end,
        },
        volar = {
          init_options = {
            vue = {
              hybridMode = false,
            },
          },
          settings = {
            vue = {
              updateImportsOnFileMove = { enabled = true },
            },
          },
        },
        vtsls = {
          init_options = {
            provideFormatter = false,
          },
        },
        html = {},
        lua_ls = {
          single_file_support = true,
          settings = {
            Lua = {
              workspace = {
                checkThirdParty = false,
              },
              completion = {
                workspaceWord = true,
                callSnippet = "Both",
              },
              misc = {
                parameters = {
                  -- "--log-level=trace",
                },
              },
              hint = {
                enable = true,
                setType = false,
                paramType = true,
                paramName = "Disable",
                semicolon = "Disable",
                arrayIndex = "Disable",
              },
              doc = {
                privateName = { "^_" },
              },
              type = {
                castNumberToInteger = true,
              },
              diagnostics = {
                disable = { "incomplete-signature-doc", "trailing-space" },
                -- enable = false,
                groupSeverity = {
                  strong = "Warning",
                  strict = "Warning",
                },
                groupFileStatus = {
                  ["ambiguity"] = "Opened",
                  ["await"] = "Opened",
                  ["codestyle"] = "None",
                  ["duplicate"] = "Opened",
                  ["global"] = "Opened",
                  ["luadoc"] = "Opened",
                  ["redefined"] = "Opened",
                  ["strict"] = "Opened",
                  ["strong"] = "Opened",
                  ["type-check"] = "Opened",
                  ["unbalanced"] = "Opened",
                  ["unused"] = "Opened",
                },
                unusedLocalExclude = { "_*" },
              },
              format = {
                enable = false,
                defaultConfig = {
                  indent_style = "space",
                  indent_size = "2",
                  continuation_indent_size = "2",
                },
              },
            },
          },
        },
        ast_grep = {},
      },
      setup = {
        ast_grep = function()
          local configs = require("lspconfig.configs")
          configs.ast_grep = {
            default_config = {
              cmd = { "ast-grep", "lsp" },
              single_file_support = false,
              root_dir = require("lspconfig.util").root_pattern("sgconfig.yml"),
            },
          }
        end,
      },
    },
  },
  {
    "mhanberg/output-panel.nvim",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("output_panel").setup({
        max_buffer_size = 5000, -- default
      })
    end,
    cmd = { "OutputPanel" },
  },
}
