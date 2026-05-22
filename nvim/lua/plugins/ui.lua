return {
  -- messages, cmdline and the popupmenu
  {
    "folke/noice.nvim",
    opts = function(_, opts)
      table.insert(opts.routes, {
        filter = {
          event = "notify",
          find = "No information available",
        },
        opts = { skip = true },
      })
      local focused = true
      vim.api.nvim_create_autocmd("FocusGained", {
        callback = function()
          focused = true
        end,
      })
      vim.api.nvim_create_autocmd("FocusLost", {
        callback = function()
          focused = false
        end,
      })
      table.insert(opts.routes, 1, {
        filter = {
          cond = function()
            return not focused
          end,
        },
        view = "notify_send",
        opts = { stop = false },
      })

      opts.commands = {
        all = {
          -- options for the message history that you get with `:Noice`
          view = "split",
          opts = { enter = true, format = "details" },
          filter = {},
        },
      }

      opts.presets.lsp_doc_border = true
      -- Too many messages, using lualine lsp_status
      opts.lsp.progress = { enabled = false }
    end,
  },

  {
    "OXY2DEV/helpview.nvim",
    ft = "help",
  },
  {
    "nvim-lualine/lualine.nvim",
    opts = function(_, opts)
      opts.sections.lualine_c = {
        opts.sections.lualine_c[1],
        opts.sections.lualine_c[2],
        opts.sections.lualine_c[3],
      }

      opts.sections.lualine_y = {
        { "location", padding = { left = 0, right = 1 } },
        {
          "lsp_status",
          icon = "", -- f013
          symbols = {
            -- Standard unicode symbols to cycle through for LSP progress:
            spinner = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
            -- Standard unicode symbol for when LSP is done:
            done = "✓",
            -- Delimiter inserted between LSP names:
            separator = " ",
          },
          -- List of LSP names to ignore (e.g., `null-ls`):
          ignore_lsp = {
            "copilot",
            "rustowl",
          },
        },
      }
    end,
  },
}
