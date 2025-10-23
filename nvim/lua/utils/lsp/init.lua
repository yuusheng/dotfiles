local Methods = vim.lsp.protocol.Methods

local M = {}

local function complete_clients(arg)
  return vim
    .iter(vim.lsp.get_clients())
    :map(function(client)
      return client.name
    end)
    :filter(function(name)
      return name:sub(1, #arg) == arg
    end)
    :totable()
end

---Set up a callback to run on LSP attach
---@param callback fun(client:vim.lsp.Client,bufnr:number)
function M.on_attach(callback)
  vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      if client then
        callback(client, bufnr)
      end
    end,
  })
end

function M.on_attach_default(client)
  -- if current nvim version supports inlay hints, enable them
  if vim.lsp["inlay_hint"] ~= nil and client.supports_method(Methods.textDocument_inlayHint) then
    vim.lsp.inlay_hint.enable(true)
  end

  vim.api.nvim_create_user_command("LspRestart", function(info)
    M.lsp_restart(info)
  end, {
    nargs = "*",
    complete = complete_clients,
    desc = "Restart one or more LSP clients (all if none specified)",
  })

  vim.api.nvim_create_user_command("LspLog", function()
    vim.cmd(string.format("tabnew %s", vim.lsp.log.get_filename()))
  end, {
    desc = "Opens the Nvim LSP client log.",
  })

  vim.api.nvim_create_user_command("LspInfo", function()
    vim.cmd(string.format("tabnew %s", vim.lsp.log.get_filename()))
  end, {
    desc = "Opens the Nvim LSP client log.",
  })

  vim.api.nvim_create_user_command("LspInfo", ":checkhealth vim.lsp", { desc = "Alias to `:checkhealth vim.lsp`" })

  vim.api.nvim_create_user_command("LspLog", function()
    local log_filename = vim.lsp.log.get_filename()

    if not log_filename or vim.fn.filereadable(log_filename) == 0 then
      vim.notify("No Lsp log file", vim.log.levels.WARN)
      return
    end

    vim.cmd(string.format("e %s", log_filename))

    local _bufnr = vim.api.nvim_get_current_buf()
    vim.bo[_bufnr].readonly = true
    vim.bo[_bufnr].buftype = "nofile"
    vim.bo[_bufnr].swapfile = false -- 避免生成交换文件
    vim.bo[_bufnr].filetype = "lsplog"
  end, {
    desc = "Opens the Nvim LSP client log.",
  })
end

function M.apply_ui_tweaks()
  -- customize LSP icons
  local icons = {
    Error = " ",
    Warn = " ",
    Hint = " ",
    Info = " ",
  }

  local icon_map = {
    [vim.diagnostic.severity.ERROR] = icons.Error,
    [vim.diagnostic.severity.WARN] = icons.Warn,
    [vim.diagnostic.severity.INFO] = icons.Info,
    [vim.diagnostic.severity.HINT] = icons.Hint,
  }

  local function diagnostic_format(diagnostic)
    return string.format("%s %s (%s)", icon_map[diagnostic.severity], diagnostic.message, diagnostic.code)
  end

  vim.diagnostic.config({
    virtual_text = {
      format = diagnostic_format,
      prefix = "",
    },
    float = {
      format = diagnostic_format,
    },
    signs = { priority = 100, text = icon_map },
    underline = true,
    update_in_insert = false,
    severity_sort = true,
  })
end

function M.lsp_restart(info)
  local clients = info.fargs

  -- Default to restarting all active servers
  if #clients == 0 then
    clients = vim
      .iter(vim.lsp.get_clients())
      :map(function(client)
        return client.name
      end)
      :totable()
  end

  for _, name in ipairs(clients) do
    if vim.lsp.config[name] == nil then
      vim.notify(("Invalid server name '%s'"):format(name))
    else
      vim.lsp.enable(name, false)
    end
  end

  local timer = assert(vim.uv.new_timer())
  timer:start(500, 0, function()
    for _, name in ipairs(clients) do
      vim.schedule_wrap(function(x)
        vim.lsp.enable(x)
      end)(name)
    end
  end)
end

--- Appends `new_names` to `root_files` if `field` is found in any such file in any ancestor of `fname`.
---
--- NOTE: this does a "breadth-first" search, so is broken for multi-project workspaces:
--- https://github.com/neovim/nvim-lspconfig/issues/3818#issuecomment-2848836794
---
--- @param root_files string[] List of root-marker files to append to.
--- @param new_names string[] Potential root-marker filenames (e.g. `{ 'package.json', 'package.json5' }`) to inspect for the given `field`.
--- @param field string Field to search for in the given `new_names` files.
--- @param fname string Full path of the current buffer name to start searching upwards from.
function M.root_markers_with_field(root_files, new_names, field, fname)
  local path = vim.fn.fnamemodify(fname, ":h")
  local found = vim.fs.find(new_names, { path = path, upward = true })

  for _, f in ipairs(found or {}) do
    -- Match the given `field`.
    for line in io.lines(f) do
      if line:find(field) then
        root_files[#root_files + 1] = vim.fs.basename(f)
        break
      end
    end
  end

  return root_files
end

function M.insert_package_json(root_files, field, fname)
  return M.root_markers_with_field(root_files, { "package.json", "package.json5" }, field, fname)
end

return M
