return {
  "stevearc/conform.nvim",
  ---@param opts conform.setupOpts
  opts = function(_, opts)
    local supported = { "javascript", "typescript", "typescriptreact", "javascriptreact", "vue" }
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    for _, ft in ipairs(supported) do
      opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
      table.insert(opts.formatters_by_ft[ft], "eslint")
    end

    local function get_client(buf)
      return LazyVim.lsp.get_clients({ name = "eslint", bufnr = buf })[1]
    end

    ---@type conform.FileLuaFormatterConfig
    opts.formatters.eslint = {
      meta = {
        url = "",
        description = "Custom ESLint LSP formatter",
      },
      condition = function(_, ctx)
        local client = get_client(ctx.buf)
        return client and true or false
      end,
      format = function(_, ctx, _, callback)
        local diag = vim.diagnostic.get(ctx.buf, { source = "eslint" })
        if #diag > 0 then
          vim.cmd("EslintFixAll")
        end

        callback(nil)
      end,
    }
  end,
}
