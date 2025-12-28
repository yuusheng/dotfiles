return {
  {
    "yetone/avante.nvim",
    enabled = vim.g.ai_cmp,
    opts = {
      behaviour = {
        auto_suggestions = false,
        auto_apply_diff_after_generation = true,
        support_paste_from_clipboard = true,
      },
      mappings = {
        --- @class AvanteConflictMappings
        suggestion = {
          accept = "<M-l>",
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      --- @alias FileSelectorProvider "native" | "fzf" | "mini.pick" | "snacks" | "telescope" | string
      file_selector = {
        provider = "telescope", -- Avoid native provider issues
      },
      system_prompt = function()
        local hub = require("mcphub").get_hub_instance()
        return hub and hub:get_active_servers_prompt() or ""
      end,
      -- Using function prevents requiring mcphub before it's loaded
      custom_tools = function()
        return {
          require("mcphub.extensions.avante").mcp_tool(),
        }
      end,
    },
  },
  {
    "ravitemer/mcphub.nvim",
    build = "npm install -g mcp-hub@latest", -- Installs `mcp-hub` node binary globally
    config = function()
      require("mcphub").setup()
    end,
  },
  {
    "folke/sidekick.nvim",
    opts = {
      nes = { enabled = false },
      cli = {
        tools = {
          droid = {
            cmd = { "droid" },
          },
        },
      },
    },
  },
}
