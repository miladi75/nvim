require "nvchad.mappings"
require "fpga_tasks"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

-- buffer navigation (works regardless of tabufline)
map("n", "<Tab>", "<cmd>bnext<CR>", { desc = "buffer next" })
map("n", "<S-Tab>", "<cmd>bprev<CR>", { desc = "buffer prev" })

-- nvim-tree toggle
map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file explorer" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
