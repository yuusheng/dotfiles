vim.g.lazyvim_prettier_needs_config = true
vim.g.root_spec = { "package.json", "Cargo.lock", "lsp", { ".git", "lua" }, "cwd" }
vim.g.snacks_animate = false
vim.g.gitblame_message_when_not_committed = "" -- no gitblame message when not commit

vim.opt.ignorecase = true -- ignore case in searches by default
vim.opt.smartcase = true -- but make it case sensitive if an uppercase is entered
vim.opt.exrc = true -- auto read project level .nvim.lua
vim.opt.title = true
vim.opt.titlestring = "%{v:lua.get_title()}"

function _G.get_title()
  local root = vim.fn.getcwd()
  local root_name = root ~= "" and vim.fn.fnamemodify(root, ":t") or "No Root"

  local file_name = vim.fn.expand("%:t")
  local status = ""
  if vim.bo.modified then
    status = status .. " [+]"
  end
  if vim.bo.readonly then
    status = status .. " [RO]"
  end

  return string.format("%s | %s%s - Neovim", root_name, file_name, status)
end

--- folding
vim.o.foldcolumn = "0" -- '0' is not bad
vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.foldmethod = "expr"
vim.o.fillchars = [[eob: ,fold: ,foldopen:,foldsep: ,foldclose:]]
vim.o.foldexpr = "v:lua.vim.treesitter.foldexpr()"

-- Source: https://www.reddit.com/r/neovim/comments/1fzn1zt/custom_fold_text_function_with_treesitter_syntax/
local function fold_virt_text(result, start_text, lnum)
  local text = ""
  local hl
  for i = 1, #start_text do
    local char = start_text:sub(i, i)
    local captured_highlights = vim.treesitter.get_captures_at_pos(0, lnum, i - 1)
    local outmost_highlight = captured_highlights[#captured_highlights]
    if outmost_highlight then
      local new_hl = "@" .. outmost_highlight.capture
      if new_hl ~= hl then
        -- as soon as new hl appears, push substring with current hl to table
        table.insert(result, { text, hl })
        text = ""
        hl = nil
      end
      text = text .. char
      hl = new_hl
    else
      text = text .. char
    end
  end
  table.insert(result, { text, hl })
end
function _G.custom_foldtext()
  local start_text = vim.fn.getline(vim.v.foldstart):gsub("\t", string.rep(" ", vim.o.tabstop))
  local nline = vim.v.foldend - vim.v.foldstart
  local result = {}
  fold_virt_text(result, start_text, vim.v.foldstart - 1)
  table.insert(result, { " ... ↙ " .. nline .. " lines", "DapBreakpointCondition" })
  return result
end
-- vim.opt.foldtext = "v:lua.custom_foldtext()"
