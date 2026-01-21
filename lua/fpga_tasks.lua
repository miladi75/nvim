-- lua/fpga_tasks.lua
-- VSCode tasks.json -> Neovim keymaps (Linux-friendly)
-- Mirrors your VSCode keybindings for VHDL/ModelSim workflows

local M = {}

-- ---------- helpers ----------
local function git_root_for_file(file)
    local ok, util = pcall(require, "lspconfig.util")
    if ok then
        return util.find_git_ancestor(file)
    end
    return nil
end

local function git_root()
    local file = vim.fn.expand("%:p")
    return git_root_for_file(file) or vim.fn.getcwd()
end

local function term_run(cmd, cwd)
    cwd = cwd or git_root()
    -- run in repo root
    vim.cmd("botright split | terminal")
    local chan = vim.b.terminal_job_id
    if cwd and #cwd > 0 then
        vim.fn.chansend(chan, "cd " .. vim.fn.shellescape(cwd) .. "\n")
    end
    vim.fn.chansend(chan, cmd .. "\n")
end

local function echo(msg)
    vim.notify(msg, vim.log.levels.INFO)
end

local function current_file_abs()
    return vim.fn.expand("%:p")
end

local function current_file_rel()
    local file = current_file_abs()
    local root = git_root()
    -- make relative to root (best-effort)
    if file:sub(1, #root) == root then
        local rel = file:sub(#root + 2)
        return rel
    end
    return file
end

local function file_basename()
    return vim.fn.expand("%:t")
end

local function file_basename_no_ext()
    return vim.fn.expand("%:t:r")
end

local function file_dirname()
    return vim.fn.expand("%:p:h")
end

local function exists(path)
    return vim.fn.filereadable(path) == 1
end

-- ---------- config paths ----------
local user_home = os.getenv("HOME")
local ini_modelsim = user_home .. "/git/fw_output/tree_user_config_modelsim.ini"
local ini_riviera = user_home .. "/git/fw_output/tree_user_config_riviera.ini"

-- ---------- task functions ----------

-- treecom (F5 in VSCode)
function M.treecom()
    local root = git_root()
    local file = current_file_abs()
    local cmd = string.format(
        "uv run %s/buildscripts/tree/treecom.py --user_cfg_ini %s --file %s",
        vim.fn.shellescape(root),
        vim.fn.shellescape(ini_modelsim),
        vim.fn.shellescape(file)
    )
    term_run(cmd, root)
end

-- treecom_riviera (Shift+F5 in VSCode)
function M.treecom_riviera()
    local root = git_root()
    local file = current_file_abs()
    local cmd = string.format(
        "uv run %s/buildscripts/tree/treecom.py --user_cfg_ini %s --file %s",
        vim.fn.shellescape(root),
        vim.fn.shellescape(ini_riviera),
        vim.fn.shellescape(file)
    )
    term_run(cmd, root)
end

-- treesim_gui (F6 in VSCode)
function M.treesim_gui()
    local root = git_root()
    local file = current_file_abs()
    local cmd = string.format(
        "uv run %s/buildscripts/tree/treesim.py --user_cfg_ini %s --file %s",
        vim.fn.shellescape(root),
        vim.fn.shellescape(ini_modelsim),
        vim.fn.shellescape(file)
    )
    term_run(cmd, root)
end

-- treesim_riviera_gui (Shift+F6 in VSCode)
function M.treesim_riviera_gui()
    local root = git_root()
    local file = current_file_abs()
    local cmd = string.format(
        "uv run %s/buildscripts/tree/treesim.py --user_cfg_ini %s --file %s",
        vim.fn.shellescape(root),
        vim.fn.shellescape(ini_riviera),
        vim.fn.shellescape(file)
    )
    term_run(cmd, root)
end

-- treesim_batch (F7 in VSCode, but F7 conflicts with kitty, using F8)
function M.treesim_batch()
    local root = git_root()
    local file = current_file_abs()
    local cmd = string.format(
        "uv run %s/buildscripts/tree/treesim.py --user_cfg_ini %s --batch --file %s",
        vim.fn.shellescape(root),
        vim.fn.shellescape(ini_modelsim),
        vim.fn.shellescape(file)
    )
    term_run(cmd, root)
end

-- treesim_riviera_batch (Shift+F7 in VSCode, using Shift+F8)
function M.treesim_riviera_batch()
    local root = git_root()
    local file = current_file_abs()
    local cmd = string.format(
        "uv run %s/buildscripts/tree/treesim.py --user_cfg_ini %s --batch --file %s",
        vim.fn.shellescape(root),
        vim.fn.shellescape(ini_riviera),
        vim.fn.shellescape(file)
    )
    term_run(cmd, root)
end

-- VSG check (Alt+l Alt+c in VSCode)
function M.vsg_check()
    local root = git_root()
    local rel = current_file_rel()
    local cmd = string.format(
        "uv run vsg -c %s/buildscripts/gitlab_pipeline/compile/vsg_rules.yml -f %s",
        vim.fn.shellescape(root),
        vim.fn.shellescape(rel)
    )
    term_run(cmd, root)
end

-- VSG fix (Alt+l Alt+f in VSCode)
function M.vsg_fix()
    local root = git_root()
    local file = current_file_abs()
    local cmd = string.format(
        "uv run vsg -c %s/buildscripts/gitlab_pipeline/compile/vsg_rules.yml -f %s --fix",
        vim.fn.shellescape(root),
        vim.fn.shellescape(file)
    )
    term_run(cmd, root)
end

-- Generate vhdl_ls.toml file (Alt+c Alt+p in VSCode)
function M.generate_vhdl_ls_toml()
    local root = git_root()
    local cmd = string.format(
        "uv run %s/src_vhdl_imp.py --dir %s --config_file",
        vim.fn.shellescape(root),
        vim.fn.shellescape(root)
    )
    term_run(cmd, root)
end

-- Open associated testbench (Ctrl+o Ctrl+t in VSCode)
function M.open_associated_testbench()
    local base = file_basename()
    local dir = file_dirname()
    local tb = string.format("%s_testbench/tb_%s", dir, base)
    if exists(tb) then
        vim.cmd("edit " .. vim.fn.fnameescape(tb))
    else
        echo("No testbench for file " .. file_basename_no_ext())
    end
end

-- Open associated syntest (Ctrl+o Ctrl+s in VSCode)
function M.open_associated_syntest()
    local base = file_basename()
    local dir = file_dirname()
    local st = string.format("%s_syntest/syntest_%s", dir, base)
    if exists(st) then
        vim.cmd("edit " .. vim.fn.fnameescape(st))
    else
        echo("No syntest for file " .. file_basename_no_ext())
    end
end

-- ---------- mappings ----------
local function map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { desc = desc, silent = true })
end

function M.setup_keymaps()
    -- Compile (ModelSim)
    -- F5: treecom (compile with ModelSim)
    -- Shift+F5: treecom_riviera (compile with Riviera)
    map("n", "<F5>", M.treecom, "VHDL: Compile (ModelSim)")
    map("n", "<S-F5>", M.treecom_riviera, "VHDL: Compile (Riviera)")

    -- Simulate GUI
    -- F6: treesim_gui (simulate with ModelSim GUI)
    -- Shift+F6: treesim_riviera_gui (simulate with Riviera GUI)
    map("n", "<F6>", M.treesim_gui, "VHDL: Simulate GUI (ModelSim)")
    map("n", "<S-F6>", M.treesim_riviera_gui, "VHDL: Simulate GUI (Riviera)")

    -- Simulate Batch (F7 conflicts with kitty rotate, using F8)
    -- F8: treesim_batch (simulate batch with ModelSim)
    -- Shift+F8: treesim_riviera_batch (simulate batch with Riviera)
    map("n", "<F8>", M.treesim_batch, "VHDL: Simulate Batch (ModelSim)")
    map("n", "<S-F8>", M.treesim_riviera_batch, "VHDL: Simulate Batch (Riviera)")

    -- VSG formatter (Alt+l Alt+c / Alt+l Alt+f in VSCode)
    -- Using <leader>lc and <leader>lf for nvim
    map("n", "<leader>lc", M.vsg_check, "VSG: Check")
    map("n", "<leader>lf", M.vsg_fix, "VSG: Fix")

    -- Generate vhdl_ls.toml (Alt+c Alt+p in VSCode)
    map("n", "<leader>vg", M.generate_vhdl_ls_toml, "VHDL: Generate vhdl_ls.toml")

    -- Open associated files (Ctrl+o Ctrl+t / Ctrl+o Ctrl+s in VSCode)
    -- Using <leader>ot and <leader>os for nvim
    map("n", "<leader>ot", M.open_associated_testbench, "Open: Associated testbench")
    map("n", "<leader>os", M.open_associated_syntest, "Open: Associated syntest")
end

-- Auto-setup keymaps
M.setup_keymaps()

return M
