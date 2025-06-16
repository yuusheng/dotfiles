local async = require("plenary.async")
local lsp_util = vim.lsp.util

local M = {}

---@param bufnr integer
---@param method string
---@param handler function
local function lsp_request(bufnr, method, handler)
  local ra = require("rustaceanvim.rust_analyzer")
  local clients = ra.get_active_rustaceanvim_clients(0)
  if #clients == 0 then
    return
  end
  local params = lsp_util.make_position_params(0, clients[1].offset_encoding or "utf-8")
  ra.buf_request(bufnr, method, params, handler)
end

M.buf_request = async.wrap(lsp_request, 3)

function M.extend_list(...)
  local result = {}
  for _, list in ipairs({ ... }) do
    for _, value in ipairs(list) do
      table.insert(result, value)
    end
  end
  return result
end

return M
