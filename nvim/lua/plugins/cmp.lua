return {
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-emoji",
      "L3MON4D3/LuaSnip",
      "hrsh7th/cmp-nvim-lsp", -- lsp auto-completion
      "hrsh7th/cmp-buffer", -- buffer auto-completion
      "hrsh7th/cmp-path", -- path auto-completion
      "hrsh7th/cmp-cmdline", -- cmdline auto-completion
    },
    opts = function(_, opts)
      table.insert(opts.sources, { name = "emoji" })
      table.insert(opts.sources, {
        name = "lazydev",
        group_index = 0, -- set group index to 0 to skip loading LuaLS completions
      })
      local cmp = require("cmp")
      cmp.setup({
        snippet = {
          -- REQUIRED - you must specify a snippet engine
          expand = function(args)
            require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
          end,
        },
        mapping = cmp.mapping.preset.insert({
          -- Use <C-b/f> to scroll the docs
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          -- Use <C-k/j> to switch in items
          ["<C-k>"] = cmp.mapping.select_prev_item(),
          ["<C-j>"] = cmp.mapping.select_next_item(),
          -- Use <CR>(Enter) to confirm selection
          -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
          ["<Tab>"] = cmp.mapping.confirm({ select = true }),

          ["<M-j>"] = cmp.mapping(function(fallback)
            if not cmp.visible() then
              cmp.complete()
            else
              fallback()
            end
          end),
        }),

        -- Set source precedence
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, -- For nvim-lsp
          { name = "luasnip" }, -- For luasnip user
          { name = "buffer" }, -- For buffer word completion
          { name = "path" }, -- For path completion
        }),
      })
    end,
  },
}
