vim.g.lazyvim_prettier_needs_config = true
vim.g.lazyvim_eslint_auto_format = true
vim.g.root_spec = { { ".git", "lua" }, "lsp", "cwd" }
vim.g.snacks_animate = false
vim.g.gitblame_message_when_not_committed = "" -- no gitblame message when not commit

vim.opt.ignorecase = true -- ignore case in searches by default
vim.opt.smartcase = true -- but make it case sensitive if an uppercase is entered
vim.opt.exrc = true -- auto read project level .nvim.lua
