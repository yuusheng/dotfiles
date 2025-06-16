local utils = require("plugins.lang.rust.utils")
local config = require("rustaceanvim.config.internal")
local async = require("plenary.async")
local async_util = require("plenary.async.util")

local lsp_util = vim.lsp.util

---@class rustaceanvim.hover_actions.State
local _state = {
  ---@type integer
  winnr = nil,
  ---@type unknown
  commands = nil,
}

local function close_hover()
  local ui = require("rustaceanvim.ui")
  ui.close_win(_state.winnr)
end

local function execute_rust_analyzer_command(action, ctx)
  local fn = vim.lsp.commands[action.command]
  if fn then
    fn(action, ctx)
  end
end

-- run the command under the cursor, if the thing under the cursor is not the
-- command then do nothing
---@param ctx table
---@param line integer
local function run_command(ctx, line)
  if line > #_state.commands then
    return
  end

  local action = _state.commands[line]

  close_hover()
  execute_rust_analyzer_command(action, ctx)
end

local function hover_float(markdown_lines, result, ctx)
  local float_win_config = config.tools.float_win_config
  local bufnr, winnr = lsp_util.open_floating_preview(
    markdown_lines,
    "markdown",
    vim.tbl_extend("keep", float_win_config, {
      focusable = true,
      focus_id = "rust-analyzer-hover-actions",
      close_events = { "CursorMoved", "BufHidden", "InsertCharPre" },
    })
  )

  if float_win_config.auto_focus then
    vim.api.nvim_set_current_win(winnr)
  end

  if _state.winnr ~= nil then
    return
  end

  -- update the window number here so that we can map escape to close even
  -- when there are no actions, update the rest of the state later
  _state.winnr = winnr
  vim.keymap.set("n", "q", close_hover, { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("n", "<Esc>", close_hover, { buffer = bufnr, noremap = true, silent = true })

  vim.api.nvim_buf_attach(bufnr, false, {
    on_detach = function()
      _state.winnr = nil
    end,
  })

  --- stop here if there are no possible actions
  if result.actions == nil then
    return
  end

  -- makes more sense in a dropdown-ish ui
  vim.wo[winnr].cursorline = true

  -- explicitly disable signcolumn
  vim.wo[winnr].signcolumn = "no"

  -- run the command under the cursor
  vim.keymap.set("n", "<CR>", function()
    local line = vim.api.nvim_win_get_cursor(winnr)[1]
    run_command(ctx, line)
  end, { buffer = bufnr, noremap = true, silent = true })
  vim.keymap.set("n", "<Plug>RustHoverAction", function()
    local line = math.max(vim.v.count, 1)
    run_command(ctx, line)
  end, { buffer = vim.api.nvim_get_current_buf(), noremap = true, silent = true })
end

---@return string[]
local function parse_commands()
  local prompt = {}

  for i, value in ipairs(_state.commands) do
    if value.command == "rust-analyzer.gotoLocation" then
      table.insert(prompt, string.format("%d. Go to %s (%s)", i, value.title, value.tooltip))
    elseif value.command == "rust-analyzer.showReferences" then
      table.insert(prompt, string.format("%d. %s", i, "Go to " .. value.title))
    else
      table.insert(prompt, string.format("%d. %s", i, value.title))
    end
  end

  return prompt
end

---@param result table
local function add_macros_lines(result)
  local lines = {}
  if result ~= nil and result.expansion ~= nil then
    table.insert(lines, "---")
    table.insert(lines, "Expand macro: `" .. result.name .. "`")
    table.insert(lines, "```rust\n" .. result.expansion .. "```")
  end

  return lines
end

---@param ctx lsp.HandlerContext
local function hover_handler(result, ctx)
  if not (result and result.contents) then
    return
  end

  local markdown_lines = lsp_util.convert_input_to_markdown_lines(result.contents, {})
  if result.actions then
    _state.commands = result.actions[1].commands
    local prompt = parse_commands()
    local l = {}

    for _, value in ipairs(prompt) do
      table.insert(l, value)
    end
    table.insert(l, "---")

    markdown_lines = vim.list_extend(l, markdown_lines)
  end

  if vim.tbl_isempty(markdown_lines) then
    return
  end

  return markdown_lines
end

local function hover()
  local methods = { "textDocument/hover", "rust-analyzer/expandMacro" }
  local requests = {}
  for _, method in ipairs(methods) do
    local _request = function()
      return utils.buf_request(0, method)
    end
    table.insert(requests, _request)
  end

  local result = async_util.join(requests)

  local _, hover_result, ctx = unpack(result[1])
  local _, macro_result = unpack(result[2])

  local hover_lines = hover_handler(hover_result, ctx)
  local macros_lines = add_macros_lines(macro_result)
  local markdown_lines = utils.extend_list(hover_lines, macros_lines)

  if #markdown_lines == 0 then
    return
  end
  hover_float(markdown_lines, hover_result, ctx)
end

return async.void(hover)
