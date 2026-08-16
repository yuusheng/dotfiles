local M = {}

local function normalize_dir(path)
  if not path or path == "" then
    return nil
  end

  path = vim.fs.normalize(vim.fn.fnamemodify(vim.fn.expand(path), ":p"))
  if vim.fn.isdirectory(path) ~= 1 then
    LazyVim.warn("Not a directory: " .. path)
    return nil
  end

  return path
end

function M.root()
  return normalize_dir(LazyVim.root({ normalize = true }))
end

function M.cwd()
  return normalize_dir(vim.uv.cwd() or ".")
end

function M.buffer_dir()
  local name = vim.api.nvim_buf_get_name(0)
  return normalize_dir(name ~= "" and vim.fs.dirname(name) or M.cwd())
end

function M.find_files(dir)
  dir = normalize_dir(dir or M.root())
  if dir then
    require("fff").find_files_in_dir(dir)
  end
end

function M.live_grep(dir)
  dir = normalize_dir(dir or M.root())
  if dir then
    require("fff").live_grep({
      cwd = dir,
      title = "Grep in " .. vim.fn.fnamemodify(dir, ":~"),
    })
  end
end

function M.grep_under_cursor(dir)
  dir = normalize_dir(dir or M.root())
  if dir then
    require("fff").live_grep_under_cursor({
      cwd = dir,
      title = "Grep word in " .. vim.fn.fnamemodify(dir, ":~"),
    })
  end
end

function M.with_directory(callback)
  local default = M.buffer_dir() or M.cwd() or ""
  local input = vim.fn.input("Directory: ", default .. "/", "dir")
  local dir = normalize_dir(input)
  if dir then
    callback(dir)
  end
end

function M.find_in_directory()
  M.with_directory(M.find_files)
end

function M.grep_in_directory()
  M.with_directory(M.live_grep)
end

return M
