local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set("n", "x", '"_x')

-- Increment/decrement
keymap.set("n", "+", "<C-a>")
keymap.set("n", "-", "<C-x>")

-- Select all
keymap.set("n", "<C-a>", "ggVG")

-- Save file and quit
keymap.set("n", "<Leader>w", ":update<Return>", opts)
keymap.set("n", "<Leader>q", ":quit<Return>", opts)
keymap.set("n", "<Leader>Q", ":qa<Return>", opts)

-- Ctrl-o for move back, Ctrl-i for move forward
keymap.set("n", "<C-i>", "<tab>", opts)

-- Split window
keymap.set("n", "<Leader>ss", ":split<Return>", opts)
keymap.set("n", "<Leader>sv", ":vsplit<Return>", opts)

-- Resize window
keymap.set("n", "<C-S-h>", "<C-w><")
keymap.set("n", "<C-S-l>", "<C-w>>")
keymap.set("n", "<C-S-k>", "<C-w>+")
keymap.set("n", "<C-S-j>", "<C-w>-")

-- Diagnostics
keymap.set("n", "<M-d>", function()
  vim.diagnostic.goto_next()
end, opts)

keymap.set("v", "<s-tab>", "<gv", opts)
keymap.set("v", "<tab>", ">gv", opts)
keymap.set("n", "<M-Tab>", "<cmd>bNext<CR>")

keymap.set("n", "ZZ", "<cmd>qa<CR>", opts)
