-- lua/fpga_tasks.lua
-- VSCode tasks.json -> Neovim keymaps (Linux-friendly)

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

local function starts_with(s, prefix)
  return s:sub(1, #prefix) == prefix
end

local function exists(path)
  return vim.fn.filereadable(path) == 1
end

-- ---------- task translations ----------

-- 1) build (msbuild) - likely Windows-only; leaving as-is but runnable if msbuild exists
--function M.build_msbuild()
--  term_run("msbuild /property:GenerateFullPaths=true /t:build /consoleloggerparameters:NoSummary")
--end

-- 2) VHDL Compile
function M.vhdl_compile()
  local root = git_root()
  local file = current_file_abs()
  local cmd = string.format(
    "python3 %s/buildscripts/tree/treecom.py --user_cfg_ini /home/rst/FPGA/Setup/tree_config_modelsim.ini --file %s",
    vim.fn.shellescape(root),
    vim.fn.shellescape(file)
  )
  term_run(cmd, root)
end

-- helper: compute associated tb file like VSCode PowerShell logic
local function associated_testbench_file()
  local base_no_ext = file_basename_no_ext()
  local base = file_basename()
  local dir = file_dirname()

  if starts_with(base_no_ext, "tb_") then
    return current_file_abs()
  end

  local tb = string.format("%s_testbench/tb_%s", dir, base)
  if exists(tb) then
    return tb
  end
  return nil
end

-- 3) VHDL Run (batch)
function M.vhdl_run_batch()
  local root = git_root()
  local tb = associated_testbench_file()
  if not tb then
    echo("No testbench for file " .. file_basename_no_ext())
    return
  end
  -- Note: tasks.json uses two different ini files depending on branch; keeping that behavior.
  local ini = starts_with(file_basename_no_ext(), "tb_")
      and "/home/rst/FPGA/Setup/tree_config_modelsim.ini"
      or "/home/rst/FPGA/Setup/tree_config.ini"

  local cmd = string.format(
    "uv run %s/buildscripts/tree/treesim.py --user_cfg_ini %s --batch --file %s",
    vim.fn.shellescape(root),
    vim.fn.shellescape(ini),
    vim.fn.shellescape(tb)
  )
  term_run(cmd, root)
end

-- 4) VHDL Simulate (non-batch)
function M.vhdl_simulate()
  local root = git_root()
  local tb = associated_testbench_file()
  if not tb then
    echo("No testbench for file " .. file_basename_no_ext())
    return
  end
  local ini = starts_with(file_basename_no_ext(), "tb_")
      and "/home/rst/FPGA/Setup/tree_config_modelsim.ini"
      or "/home/rst/FPGA/Setup/tree_config.ini"

  local cmd = string.format(
    "uv run %s/buildscripts/tree/treesim.py --user_cfg_ini %s --file %s",
    vim.fn.shellescape(root),
    vim.fn.shellescape(ini),
    vim.fn.shellescape(tb)
  )
  term_run(cmd, root)
end

-- 5) Generate vhdl_ls.toml file
function M.generate_vhdl_ls_toml()
  local root = git_root()
  local cmd = string.format(
    "uv run %s/src_vhdl_imp.py --dir %s --config_file --ini ~/FPGA/Setup/vhdl_ls.ini",
    vim.fn.shellescape(root),
    vim.fn.shellescape(root)
  )
  term_run(cmd, root)
end

-- 6) Open associated testbench (Linux: open in current nvim)
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

-- 7) Open associated syntest
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

-- 8) vsg-check (relative file)
function M.vsg_check()
  local root = git_root()
  local rel = current_file_rel()
  local cmd = string.format(
    "uv run vsg -f %s -c %s/buildscripts/gitlab_pipeline/compile/vsg_rules.yml",
    vim.fn.shellescape(rel),
    vim.fn.shellescape(root)
  )
  term_run(cmd, root)
end

-- 9) vsg-fix
function M.vsg_fix()
  local root = git_root()
  local rel = current_file_rel()
  local cmd = string.format(
    "uv run vsg -f %s --fix -c %s/buildscripts/gitlab_pipeline/compile/vsg_rules.yml",
    vim.fn.shellescape(rel),
    vim.fn.shellescape(root)
  )
  term_run(cmd, root)
end

-- 10) Open fwlibs quartus project (PowerShell -> Lua/bash equivalent)
-- tasks.json: fwlibs_quartus = (<fileBasename>.Split('_')[0] + 'lib')
-- then: quartus ${workspaceFolder}/fwlibs/$fwlibs_quartus/syntest/
function M.open_fwlibs_quartus_project()
  local root = git_root()
  local base = file_basename()               -- e.g. foo_bar.vhd
  local prefix = vim.split(base, "_")[1] or base
  local fwlibs = prefix .. "lib"
  local path = string.format("%s/fwlibs/%s/syntest/", root, fwlibs)
  term_run("quartus " .. vim.fn.shellescape(path), root)
end

-- ---------- mappings ----------
-- set your leader elsewhere: vim.g.mapleader = " "
local function map(lhs, rhs, desc)
  vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true })
end

function M.setup_keymaps()
  --map("<leader>mb", M.build_msbuild, "Task: build (msbuild)")
  map("<leader>vc", M.vhdl_compile, "Task: VHDL Compile")
  map("<leader>vr", M.vhdl_run_batch, "Task: VHDL Run (batch)")
  map("<leader>vs", M.vhdl_simulate, "Task: VHDL Simulate")
  map("<leader>vv", M.generate_vhdl_ls_toml, "Task: Generate vhdl_ls.toml")
  map("<leader>vot", M.open_associated_testbench, "Task: Open associated testbench")
  map("<leader>vos", M.open_associated_syntest, "Task: Open associated syntest")
  map("<leader>vsc", M.vsg_check, "Task: vsg-check")
  map("<leader>vsf", M.vsg_fix, "Task: vsg-fix")
  map("<leader>vqo", M.open_fwlibs_quartus_project, "Task: Open fwlibs quartus project")
end

-- Auto-setup if you want:
M.setup_keymaps()

return M
