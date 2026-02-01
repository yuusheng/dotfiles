local keymap = vim.keymap
local opts = { noremap = true, silent = true }

keymap.set({ "n", "v" }, "x", '"_x', opts)
keymap.set({ "n", "v" }, "c", '"_c', opts)

-- Save file and quit
keymap.set("n", "<Leader>w", ":update<Return>", opts)
keymap.set("n", "<C-c>", ":quit<Return>", opts)
keymap.set("n", "<D-a>", "ggVG", opts)

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
keymap.set("i", "<C-e>", "<End>", opts)
keymap.set("i", "<C-a>", "<Home>", opts)
keymap.set("i", "<C-l>", "<C-o>A", opts)
keymap.set("i", "<C-h>", "<C-o>I", opts)

keymap.set("v", "<s-tab>", "<gv", opts)
keymap.set("v", "<tab>", ">gv", opts)
keymap.set("n", "<M-Tab>", "<cmd>bNext<CR>", opts)

keymap.set("n", "ZZ", "<cmd>qa<CR>", opts)

-- Command related
keymap.set({ "n", "i", "v" }, "<D-s>", "<cmd>w<CR>", opts)

require("which-key").add({
  "<leader>ub",
  "<cmd>GitBlameToggle<CR>",
  {
    desc = "Toggle Git Blame",
  },
})
