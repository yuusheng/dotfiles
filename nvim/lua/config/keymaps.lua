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

-- Resize window
keymap.set("n", "<C-S-h>", "<C-w><", opts)
keymap.set("n", "<C-S-l>", "<C-w>>", opts)
keymap.set("n", "<C-S-k>", "<C-w>+", opts)
keymap.set("n", "<C-S-j>", "<C-w>-", opts)

-- Move cursor at insert mode
keymap.set("i", "<C-f>", "<Right>", opts)
keymap.set("i", "<C-b>", "<Left>", opts)
keymap.set("i", "<C-n>", "<Down>", opts)
keymap.set("i", "<C-p>", "<Up>", opts)
keymap.set("i", "<C-h>", "<BackSpace>", opts)
keymap.set("i", "<C-e>", "<End>", opts)
keymap.set("i", "<C-a>", "<Home>", opts)

keymap.set("v", "<s-tab>", "<gv", opts)
keymap.set("v", "<tab>", ">gv", opts)
keymap.set("n", "<M-Tab>", "<cmd>bNext<CR>", opts)

keymap.set("n", "ZZ", "<cmd>qa<CR>", opts)
