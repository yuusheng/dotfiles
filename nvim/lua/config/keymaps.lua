local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set("n", "x", '"_x', opts)
keymap.set("n", "c", '"_c', opts)

-- Increment/decrement
keymap.set("n", "+", "<C-a>", opts)
keymap.set("n", "-", "<C-x>", opts)

-- Select all
keymap.set("n", "<C-a>", "ggVG", opts)

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

keymap.set("v", "<s-tab>", "<gv", opts)
keymap.set("v", "<tab>", ">gv", opts)
keymap.set("n", "<M-Tab>", "<cmd>bNext<CR>")

keymap.set("n", "ZZ", "<cmd>qa<CR>", opts)
