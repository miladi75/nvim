require "nvchad.mappings"
require "fpga_tasks"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

pcall(vim.keymap.del, "n", "<C-s>")
pcall(vim.keymap.del, "t", "<C-x>")

map("n", "<leader>fs", "<cmd>w<CR>", { desc = "Save file" })
map("n", "<leader>qq", "<cmd>qa!<CR>", { desc = "Quit Neovim without saving" })
map("n", "<C-c>", "<cmd>%y+<CR>", { desc = "Copy whole file to system clipboard" })
map("v", "<C-c>", '"+y', { desc = "Copy selection to system clipboard" })

-- telescope live grep (NvChad's M.mappings in chadrc is NOT read in 2.5,
-- so these must live here). <leader>fg = normal grep (respects .gitignore,
-- skips hidden/binary). <leader>fG = grep EVERYTHING incl. ignored + hidden.
map("n", "<leader>fg", "<cmd>Telescope live_grep<CR>", { desc = "Telescope live grep" })
map("n", "<leader>fG", function()
  require("telescope.builtin").live_grep {
    additional_args = { "--hidden", "--no-ignore", "--glob", "!**/.git/*" },
    prompt_title = "Live Grep (all files: hidden + ignored)",
  }
end, { desc = "Telescope live grep (all files)" })

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
-- Rich markdown preview: markview decorations + snacks image rendering
-- (mermaid diagrams, latex math) toggled together. Off by default —
-- markview preview.enable=false and snacks doc.enabled=false, so nothing
-- renders until this fires.
map("n", "<leader>mv", function()
  local buf = vim.api.nvim_get_current_buf()
  if vim.b[buf].md_rich_preview then
    vim.b[buf].md_rich_preview = false
    vim.cmd("Markview disable")
    -- snacks has attach but no detach: close image placements, drop the
    -- inline watcher, clear the attached flag so re-attach starts fresh.
    require("snacks.image.placement").clean(buf)
    pcall(vim.api.nvim_del_augroup_by_name, "snacks.image.inline." .. buf)
    pcall(vim.api.nvim_del_augroup_by_name, "snacks.image.doc." .. buf)
    vim.b[buf].snacks_image_attached = nil
  else
    vim.b[buf].md_rich_preview = true
    vim.cmd("Markview enable")
    require("snacks.image.doc").attach(buf)
  end
end, { desc = "Toggle rich markdown preview (markview + diagrams/math)" })

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

-- Nvim tutorial course (see tutor/README.md): :Tutorial opens the overview,
-- :Tutorial 01-basics jumps to a chapter.
-- Lesson buffers are throwaway: no swap files, so a killed session can
-- never trigger the swap-recovery prompt (recovering resurrects a stale
-- lesson whose text no longer matches the ✓/✗ check positions).
vim.api.nvim_create_autocmd("FileType", {
  pattern = "tutor",
  callback = function()
    vim.opt_local.swapfile = false
  end,
})
vim.api.nvim_create_user_command("Tutorial", function(opts)
  local name = "tutorial" .. (opts.args ~= "" and "-" .. opts.args or "")
  -- :Tutor reuses an already-open (possibly edited) lesson buffer via
  -- :drop, so it would NOT reset the exercises; wipe it first.
  for _, b in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_get_name(b):match("/tutor/" .. vim.pesc(name) .. "%.tutor$") then
      vim.api.nvim_buf_delete(b, { force = true })
    end
  end
  vim.cmd("Tutor " .. name)
end, { nargs = "?", desc = "Open the nvim tutorial course (tutor/)" })

-- Diagnose and repair the tutorial ✓/✗ checks in the current lesson buffer
vim.api.nvim_create_user_command("TutorialDoctor", function()
  local out = {}
  local function add(s)
    table.insert(out, s)
  end
  add("filetype=" .. vim.bo.filetype .. "  buftype=" .. vim.bo.buftype)
  local meta = vim.b.tutor_metadata
  local n_checks = meta and meta.expect and vim.tbl_count(meta.expect) or 0
  add("checks loaded: " .. (n_checks > 0 and ("yes (" .. n_checks .. ")") or "NO"))
  local ok_au, aus = pcall(vim.api.nvim_get_autocmds, { group = "tutor_interactive", buffer = 0 })
  add("live-update autocmds: " .. (ok_au and #aus or "MISSING GROUP"))
  local ok_cmp, cmp = pcall(require, "cmp")
  if ok_cmp then
    local ok_en, en = pcall(function()
      return cmp.get_config().enabled()
    end)
    add("completion here: " .. (ok_en and tostring(en) or ("ERROR " .. tostring(en))))
  end
  if n_checks > 0 then
    local lnum = vim.fn.line "."
    local exp = meta.expect[tostring(lnum)]
    if exp then
      add("cursor line " .. lnum .. ":")
      add("  yours:    [" .. vim.fn.getline(lnum) .. "]")
      add("  expected: [" .. (exp == -1 and "(anything)" or exp) .. "]")
      add("  match: " .. tostring(exp == -1 or vim.fn.getline(lnum) == exp))
    else
      add("cursor line " .. lnum .. ": not a checked exercise line")
    end
    local ok_fix, err = pcall(function()
      require("nvim.tutor").apply_marks()
    end)
    add(ok_fix and "checks RE-SYNCED — correct lines show ✓ now" or ("re-sync FAILED: " .. tostring(err)))
  end
  vim.notify(table.concat(out, "\n"))
end, { desc = "Diagnose/repair tutorial checks" })

map("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })
map("t", "<leader>qq", "<C-\\><C-n><cmd>qa!<CR>", { desc = "Quit Neovim without saving" })
map("t", "<leader>tq", "<C-\\><C-n><cmd>bd!<CR>", { desc = "Close terminal buffer" })
map("n", "<leader>tq", function()
  if vim.bo.buftype == "terminal" then
    vim.cmd "bd!"
  else
    vim.notify("Current buffer is not a terminal", vim.log.levels.WARN)
  end
end, { desc = "Close terminal buffer" })
