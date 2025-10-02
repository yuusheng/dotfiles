return {
  -- lsp servers
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Keep in function to get the value of $MASON
      local vue_language_server_path = vim.fn.expand("$MASON/packages")
        .. "/vue-language-server"
        .. "/node_modules/@vue/language-server"

      local tsserver_filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" }
      local vue_plugin = {
        name = "@vue/typescript-plugin",
        location = vue_language_server_path,
        languages = { "vue" },
        configNamespace = "typescript",
        enableForWorkspaceTypeScriptVersions = true,
      }

      local ret = {
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
          vtsls = {
            settings = {
              vtsls = {
                tsserver = {
                  globalPlugins = {
                    vue_plugin,
                  },
                },
              },
            },
            filetypes = tsserver_filetypes,
          },
          vue_ls = {},
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
          copilot = { enabled = true },
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
      }

      return vim.tbl_deep_extend("force", opts, ret)
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "shellcheck",
        "shfmt",
        "tailwindcss-language-server",
        "typescript-language-server",
        "css-lsp",
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
    "mhanberg/output-panel.nvim",
    version = "*",
    event = "VeryLazy",
    opts = {
      max_buffer_size = 5000, -- default
    },
    cmd = { "OutputPanel" },
  },
}
