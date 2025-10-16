return {
  "saghen/blink.cmp",
  event = { "InsertEnter", "CmdlineEnter" },
  dependencies = {
    -- emoji completion
    "moyiz/blink-emoji.nvim",
    "xzbdmw/colorful-menu.nvim",
  },
  version = "1.*",
  ---@module 'blink.cmp'
  ---@type blink.cmp.Config
  opts = {
    sources = {
      providers = {
        emoji = {
          module = "blink-emoji",
          name = "Emoji",
        },
      },
    },
    completion = {
      accept = {
        auto_brackets = {
          enabled = false,
        },
      },
      documentation = {
        auto_show = true,
      },
      menu = {
        draw = {
          -- We don't need label_description now because label and label_description are already
          -- combined together in label by colorful-menu.nvim.
          columns = { { "kind_icon" }, { "label", gap = 1 } },
          components = {
            label = {
              text = function(ctx)
                return require("colorful-menu").blink_components_text(ctx)
              end,
              highlight = function(ctx)
                return require("colorful-menu").blink_components_highlight(ctx)
              end,
            },
          },
        },
      },
    },
    cmdline = {
      enabled = true,
      completion = {
        list = { selection = { preselect = true } },
        ghost_text = { enabled = true },
        menu = { auto_show = true },
      },
      keymap = {
        ["<Tab>"] = { "show", "accept" },
      },
    },
    keymap = {
      ["<Tab>"] = {
        -- Snippet first
        "snippet_forward",
        function(cmp)
          if cmp.snippet_active() then
            return cmp.accept()
          else
            return cmp.select_and_accept()
          end
        end,
        function() -- sidekick next edit suggestion
          return require("sidekick").nes_jump_or_apply()
        end,
        "fallback",
      },
      ["<S-Tab>"] = { "snippet_backward", "fallback" },
    },
  },
  keys = {
    {
      "<M-j>",
      function()
        local cmp = require("blink.cmp")
        if cmp.is_visible() then
          cmp.hide()
        else
          cmp.show()
        end
      end,
      mode = { "i" },
      desc = "Toggle blink.cmp",
      noremap = true,
    },
  },
}
