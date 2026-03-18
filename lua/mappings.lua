require "nvchad.mappings"
require "fpga_tasks"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

pcall(vim.keymap.del, "n", "<C-s>")
pcall(vim.keymap.del, "t", "<C-x>")

map("n", "<leader>fs", "<cmd>w<CR>", { desc = "Save file" })

-- buffer navigation (works regardless of tabufline)
map("n", "<Tab>", "<cmd>bnext<CR>", { desc = "buffer next" })
map("n", "<S-Tab>", "<cmd>bprev<CR>", { desc = "buffer prev" })

-- nvim-tree toggle
map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file explorer" })

-- markdown preview
map("n", "<leader>mp", function()
  require("lazy").load { plugins = { "peek.nvim" } }
  require("peek").open()
end, { desc = "Markdown preview open" })
map("n", "<leader>po", function()
  require("lazy").load { plugins = { "peek.nvim" } }
  require("peek").open()
end, { desc = "Peek open" })
map("n", "<leader>mc", function()
  require("lazy").load { plugins = { "peek.nvim" } }
  require("peek").close()
end, { desc = "Markdown preview close" })

-- git
map("n", "<leader>gb", "<cmd>Gitsigns blame_line<cr>", { desc = "Git blame line" })
map("n", "<leader>gB", "<cmd>Gitsigns toggle_current_line_blame<cr>", { desc = "Git toggle line blame" })
map("n", "<leader>gh", "<cmd>Gitsigns preview_hunk<cr>", { desc = "Git preview hunk" })
map("n", "<leader>gs", "<cmd>Gitsigns stage_hunk<cr>", { desc = "Git stage hunk" })
map("n", "<leader>gr", "<cmd>Gitsigns reset_hunk<cr>", { desc = "Git reset hunk" })
map("n", "<leader>gv", "<cmd>DiffviewOpen<cr>", { desc = "Git diff view" })
map("n", "<leader>gV", "<cmd>DiffviewFileHistory %<cr>", { desc = "Git file history" })

-- open HTML file in browser
map("n", "<leader>oh", function()
  local file = vim.fn.expand("%:p")
  if vim.bo.filetype == "html" then
    vim.fn.jobstart({ "xdg-open", file }, { detach = true })
  else
    vim.notify("Not an HTML file", vim.log.levels.WARN)
  end
end, { desc = "Open HTML in browser" })

map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("t", "<leader>tq", "<C-\\><C-n><cmd>bd!<CR>", { desc = "Close terminal buffer" })
map("n", "<leader>tq", function()
  if vim.bo.buftype == "terminal" then
    vim.cmd "bd!"
  else
    vim.notify("Current buffer is not a terminal", vim.log.levels.WARN)
  end
end, { desc = "Close terminal buffer" })
