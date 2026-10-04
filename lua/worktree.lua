-- Git worktrees and branches from a Snacks picker.
--
-- Every worktree lives in its own tab (tab-local :tcd), so NvChad's tabufline
-- keeps a separate buffer list per worktree and nvim-tree, LSP roots, gitsigns
-- and the pickers all follow the tab you are in. Unfinished work stays where
-- it is: nothing is stashed, committed or checked out underneath you.
--
--   <leader>gW  worktrees    enter    go to the worktree's tab (opened on first use)
--                            <c-e>    switch this tab to it instead of opening a tab
--                            <c-a>    new worktree from a branch (same as <leader>gn)
--                            <c-x>    remove the worktree (asks; extra warning if dirty)
--   <leader>gn  new worktree to review a branch: pick any local or remote branch;
--              it is checked out under <worktree root>/<branch> and opened in a tab
--                            <c-f>    git fetch, then refresh the list (for branches
--                                     pushed since your last fetch)
--   <leader>go  branches     enter    checkout here; a branch that already has a
--                                     worktree jumps to it; a dirty tree asks first
--                            <c-t>    open the branch in a worktree tab instead
--
-- A worktree without its own vhdl_ls.toml (gitignored) gets the main clone's,
-- with the paths rewritten, the first time you switch to it.
--
-- New worktrees go to ~/git/worktrees/<repo>/<branch>, next to the main clone
-- (~/git/<repo>). Override with vim.g.worktree_root = "/some/dir" (the repo name
-- is still appended).
local M = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "worktree" })
end

local function git(args, cwd)
  local res = vim.system(vim.list_extend({ "git" }, args), { cwd = cwd, text = true }):wait()
  return res.code == 0, vim.trim(res.stdout or ""), vim.trim(res.stderr or "")
end

local function norm(path)
  return vim.fs.normalize(vim.fn.fnamemodify(path, ":p")):gsub("/$", "")
end

local function toplevel(dir)
  local ok, out = git({ "rev-parse", "--show-toplevel" }, dir or vim.fn.getcwd())
  return ok and norm(out) or nil
end

--- All worktrees of the repo that `dir` belongs to, main worktree first.
--- Each: { path, branch?, head, detached, locked, prunable, main, dirty? }
function M.list(dir)
  local ok, out, err = git({ "worktree", "list", "--porcelain" }, dir or vim.fn.getcwd())
  if not ok then
    return nil, err
  end
  local list, cur = {}, nil
  for line in (out .. "\n\n"):gmatch "(.-)\n" do
    local key, val = line:match "^(%S+)%s?(.*)$"
    if key == "worktree" then
      cur = { path = norm(val), main = #list == 0 }
      table.insert(list, cur)
    elseif cur and key == "HEAD" then
      cur.head = val:sub(1, 10)
    elseif cur and key == "branch" then
      cur.branch = val:gsub("^refs/heads/", "")
    elseif cur and key then
      cur[key] = true -- detached, bare, locked, prunable
    end
  end
  return list
end

--- Count uncommitted changes in every worktree, in parallel.
local function add_dirty(list)
  local jobs = {}
  for i, wt in ipairs(list) do
    if not wt.prunable and not wt.bare then
      jobs[i] = vim.system({ "git", "status", "--porcelain" }, { cwd = wt.path, text = true })
    end
  end
  for i, job in pairs(jobs) do
    local res = job:wait()
    list[i].dirty = res.code == 0 and #vim.split(res.stdout, "\n", { trimempty = true }) or nil
  end
end

local function worktree_root(list)
  local main = list[1].path
  local name = vim.fs.basename(main)
  local base = vim.g.worktree_root or vim.fs.joinpath(vim.fs.dirname(main), "worktrees")
  return vim.fs.joinpath(norm(base), name)
end

local function tab_of(path)
  for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
    local nr = vim.api.nvim_tabpage_get_number(tab)
    if norm(vim.fn.getcwd(-1, nr)) == path then
      return tab
    end
  end
end

--- The file in the other worktree that corresponds to the current buffer.
local function counterpart(from_root, to_root)
  local name = vim.api.nvim_buf_get_name(0)
  if name == "" or not vim.startswith(name, from_root .. "/") then
    return nil
  end
  local target = to_root .. name:sub(#from_root + 1)
  return vim.uv.fs_stat(target) and target or nil
end

--- Gitignored per-clone config that a fresh worktree lacks. vhdl_ls.toml lists
--- every source file by absolute path, so the main clone's copy is reused with
--- its paths pointed at the worktree; without it vhdl_ls has no library mapping.
--- Files the branch adds are not in the copy: <leader>vv regenerates it exactly.
local SEED_FILES = { "vhdl_ls.toml" }

local function seed_config(path, main)
  if path == main then
    return
  end
  for _, name in ipairs(SEED_FILES) do
    local src, dst = vim.fs.joinpath(main, name), vim.fs.joinpath(path, name)
    if vim.uv.fs_stat(src) and not vim.uv.fs_stat(dst) and git({ "check-ignore", "-q", name }, path) then
      local text = table.concat(vim.fn.readfile(src, "b"), "\n")
      text = text:gsub(vim.pesc(main .. "/"), ((path .. "/"):gsub("%%", "%%%%")))
      vim.fn.writefile(vim.split(text, "\n", { plain = true }), dst, "b")
      notify(("%s copied from the main clone (<leader>vv regenerates it)"):format(name))
    end
  end
end

--- Make `path` the working directory of a tab.
--- how = "tab": its existing tab, else a new one. how = "here": the current tab.
function M.switch(path, how)
  path = norm(path)
  local from = toplevel() or norm(vim.fn.getcwd())
  if how ~= "here" then
    local tab = tab_of(path)
    if tab then
      vim.api.nvim_set_current_tabpage(tab)
      return
    end
  end
  local list = M.list(path)
  if list then
    seed_config(path, list[1].path)
  end
  local file = counterpart(from, path)
  if how ~= "here" then
    vim.cmd "tabnew"
  end
  vim.cmd.tcd(vim.fn.fnameescape(path))
  if file then
    vim.cmd.edit(vim.fn.fnameescape(file))
  elseif how ~= "here" then
    Snacks.picker.files { cwd = path }
  end
  local _, branch = git({ "branch", "--show-current" }, path)
  notify(("%s  %s"):format(branch ~= "" and branch or "(detached)", vim.fn.fnamemodify(path, ":~")))
end

--- Check out `branch` (local "name" or remote "remotes/origin/name") in a new
--- worktree, or jump to the one that already has it.
function M.add(branch, list)
  list = list or M.list()
  if not list then
    return notify("not in a git repository", vim.log.levels.ERROR)
  end
  local name = branch:gsub("^remotes/[^/]+/", "")
  for _, wt in ipairs(list) do
    if wt.branch == name then
      return M.switch(wt.path)
    end
  end
  local path = vim.fs.joinpath(worktree_root(list), name)
  if vim.uv.fs_stat(path) then
    return notify(path .. " already exists but is not a worktree of this repo", vim.log.levels.ERROR)
  end
  -- A bare local branch name that only exists as origin/<name> makes git create
  -- a local tracking branch (worktree add's --guess-remote behaviour).
  notify(("creating worktree for %s …"):format(name))
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  vim.system({ "git", "worktree", "add", path, name }, { cwd = list[1].path, text = true }, function(res)
    vim.schedule(function()
      if res.code ~= 0 then
        return notify("git worktree add failed:\n" .. vim.trim(res.stderr), vim.log.levels.ERROR)
      end
      M.switch(path)
    end)
  end)
end

--- Remove a worktree after confirmation; closes its tab and buffers first.
function M.remove(wt)
  if wt.main then
    return notify("the main worktree cannot be removed", vim.log.levels.WARN)
  end
  if norm(vim.fn.getcwd()) == wt.path or vim.startswith(norm(vim.fn.getcwd()), wt.path .. "/") then
    return notify("switch this tab to another worktree first", vim.log.levels.WARN)
  end
  local label = wt.branch or wt.path
  local msg = ("Remove worktree %s?\n%s"):format(label, vim.fn.fnamemodify(wt.path, ":~"))
  if (wt.dirty or 0) > 0 then
    msg = msg .. ("\n\n%d UNCOMMITTED CHANGE(S) WILL BE LOST."):format(wt.dirty)
  end
  if vim.fn.confirm(msg, "&Remove\n&Cancel", 2) ~= 1 then
    return
  end
  local tab = tab_of(wt.path)
  if tab then
    vim.cmd.tabclose(vim.api.nvim_tabpage_get_number(tab))
  end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.startswith(vim.api.nvim_buf_get_name(buf), wt.path .. "/") then
      pcall(vim.api.nvim_buf_delete, buf, { force = true })
    end
  end
  local args = { "worktree", "remove", wt.path }
  if (wt.dirty or 0) > 0 then
    table.insert(args, 3, "--force")
  end
  local ok, _, err = git(args, vim.fn.getcwd())
  if ok then
    notify(("removed %s (the branch itself is kept)"):format(label))
  else
    notify("git worktree remove failed:\n" .. err, vim.log.levels.ERROR)
  end
end

local function format_worktree(item)
  local a = Snacks.picker.util.align
  local wt = item.wt
  local ret = {}
  ret[#ret + 1] = { a(item.here and "" or (tab_of(wt.path) and "󰓩" or ""), 2), "SnacksPickerGitBranchCurrent" }
  ret[#ret + 1] = { a(wt.branch or ("(detached " .. (wt.head or "?") .. ")"), 42, { truncate = true }), "SnacksPickerGitBranch" }
  ret[#ret + 1] = { " " }
  if wt.prunable then
    ret[#ret + 1] = { a("missing", 12), "DiagnosticError" }
  elseif (wt.dirty or 0) > 0 then
    ret[#ret + 1] = { a(("● %d changed"):format(wt.dirty), 12), "DiagnosticWarn" }
  else
    ret[#ret + 1] = { a("clean", 12), "Comment" }
  end
  ret[#ret + 1] = { " " }
  ret[#ret + 1] = { vim.fn.fnamemodify(wt.path, ":~") .. (wt.main and "  (main)" or ""), "SnacksPickerDir" }
  return ret
end

local function preview_worktree(ctx)
  local sh = "git -c color.ui=always status --short --branch && echo"
    .. " && git -c color.ui=always log --oneline --decorate --graph -n 60"
  return Snacks.picker.preview.cmd({ "sh", "-c", sh }, ctx)
end

--- <leader>gW: pick a worktree.
function M.pick()
  local list, err = M.list()
  if not list then
    return notify("not in a git repository\n" .. (err or ""), vim.log.levels.WARN)
  end
  add_dirty(list)
  local here = toplevel()
  local items = {}
  for _, wt in ipairs(list) do
    items[#items + 1] = {
      text = (wt.branch or "") .. " " .. wt.path,
      wt = wt,
      cwd = wt.path, -- preview runs here
      here = wt.path == here,
    }
  end
  Snacks.picker.pick {
    title = "Worktrees",
    items = items,
    format = format_worktree,
    preview = preview_worktree,
    confirm = function(picker, item)
      picker:close()
      if item then
        M.switch(item.wt.path)
      end
    end,
    actions = {
      wt_here = function(picker, item)
        picker:close()
        if item then
          M.switch(item.wt.path, "here")
        end
      end,
      wt_add = function(picker)
        picker:close()
        M.pick_branch_for_worktree()
      end,
      wt_remove = function(picker, item)
        picker:close()
        if item then
          M.remove(item.wt)
        end
      end,
    },
    win = {
      input = {
        keys = {
          ["<c-e>"] = { "wt_here", mode = { "n", "i" }, desc = "switch this tab" },
          ["<c-a>"] = { "wt_add", mode = { "n", "i" }, desc = "new worktree" },
          ["<c-x>"] = { "wt_remove", mode = { "n", "i" }, desc = "remove worktree" },
        },
      },
    },
  }
end

--- <leader>gn: pick a local or remote branch and open it in a worktree tab.
function M.pick_branch_for_worktree()
  local list = M.list()
  if not list then
    return notify("not in a git repository", vim.log.levels.WARN)
  end
  Snacks.picker.git_branches {
    all = true,
    title = "New worktree from branch  (ctrl-f: fetch)",
    confirm = function(picker, item)
      picker:close()
      if item and item.branch then
        M.add(item.branch, list)
      end
    end,
    actions = {
      wt_fetch = function(picker)
        M.fetch(list[1].path, function()
          if not picker.closed then
            picker:find()
          end
        end)
      end,
    },
    win = {
      input = {
        keys = {
          ["<c-f>"] = { "wt_fetch", mode = { "n", "i" }, desc = "git fetch, then refresh" },
        },
      },
    },
  }
end

--- `git fetch --all --prune` in the background, then on_done(). Prompts are
--- turned off (no tty to answer them), so a missing ssh key fails fast instead
--- of hanging.
function M.fetch(cwd, on_done)
  notify "fetching …"
  local env = {
    GIT_TERMINAL_PROMPT = "0",
    GIT_SSH_COMMAND = (vim.env.GIT_SSH_COMMAND or "ssh") .. " -o BatchMode=yes",
  }
  vim.system({ "git", "fetch", "--all", "--prune" }, { cwd = cwd, env = env, text = true, timeout = 120000 }, function(res)
    vim.schedule(function()
      if res.code ~= 0 then
        return notify("git fetch failed:\n" .. vim.trim(res.stderr or ""), vim.log.levels.ERROR)
      end
      notify "fetched · branch list refreshed"
      on_done()
    end)
  end)
end

--- <leader>go: branch picker that knows about worktrees and uncommitted work.
function M.pick_branch()
  local list = M.list()
  if not list then
    return notify("not in a git repository", vim.log.levels.WARN)
  end
  local by_branch = {}
  for _, wt in ipairs(list) do
    if wt.branch then
      by_branch[wt.branch] = wt
    end
  end
  local here = toplevel()
  Snacks.picker.git_branches {
    all = true,
    confirm = function(picker, item)
      if not (item and item.branch) or item.current then
        return picker:close()
      end
      local name = item.branch:gsub("^remotes/[^/]+/", "")
      local wt = by_branch[name]
      if wt and wt.path ~= here then
        picker:close()
        return M.switch(wt.path)
      end
      local _, status = git({ "status", "--porcelain", "--untracked-files=no" }, here)
      if status ~= "" then
        local n = #vim.split(status, "\n")
        local choice = vim.fn.confirm(
          ("%d uncommitted change(s) here. Open %s in a worktree tab instead?"):format(n, name),
          "&Worktree tab\n&Checkout anyway\n&Cancel",
          1
        )
        if choice == 1 then
          picker:close()
          return M.add(item.branch, list)
        elseif choice ~= 2 then
          return
        end
      end
      Snacks.picker.actions.git_checkout(picker, item)
    end,
    actions = {
      wt_open = function(picker, item)
        picker:close()
        if item and item.branch then
          M.add(item.branch, list)
        end
      end,
    },
    win = {
      input = {
        keys = {
          ["<c-t>"] = { "wt_open", mode = { "n", "i" }, desc = "open in worktree tab" },
        },
      },
    },
  }
end

return M
