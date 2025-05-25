return {
  "saghen/blink.cmp",
  event = "VeryLazy",
  dependencies = {
    -- emoji completion
    "moyiz/blink-emoji.nvim",
  },
  opts = {
    sources = {
      per_filetype = { sql = { "dadbod" } },
      providers = {
        dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
        emoji = {
          module = "blink-emoji",
          name = "Emoji",
          score_offset = 15, -- Tune by preference
        },
      },
      default = {
        "emoji",
      },
    },
    completion = {
      accept = {
        auto_brackets = {
          enabled = false,
        },
      },
    },
    cmdline = {
      enabled = true,
      completion = {
        ghost_text = { enabled = true },
        menu = { auto_show = true },
      },
      keymap = {
        ["<Tab>"] = { "show", "accept" },
      },
    },
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
    },
  },
}
