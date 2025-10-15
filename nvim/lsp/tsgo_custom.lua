local root_files = {
  "tsconfig.base.json",
  "tsconfig.json",
  "jsconfig.json",
  "package.json",
  ".git",
}

if not vim.g.use_tsgo then
  return
end

---@type vim.lsp.Config
return {
  cmd = { vim.env.HOME .. "/typescript-go/built/local/tsgo", "--lsp", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
  },
  root_markers = root_files,
}
