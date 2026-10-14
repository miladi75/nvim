-- "Open changes with previous revision", like the left-arrow button in the
-- VSCode/GitLens editor title bar. Clicked from the tabufline (chadrc.lua).
--
--   file has uncommitted changes -> HEAD vs working file
--   file is clean                -> the last commit that touched the file
--   clicked again in that diff   -> one commit further back (follows renames)
--
-- Each diff is a diffview tab with the file panel hidden; `q` closes it.

local M = {}

local EMPTY_TREE = "4b825dc642cb6eb9a060e54bf8d69288fbee4904"

local function notify(msg, level)
    vim.notify(msg, level or vim.log.levels.INFO, { title = "Previous revision" })
end

local function git(top, args)
    local res = vim.system(vim.list_extend({ "git", "-C", top }, args), { text = true }):wait()
    return res.code, vim.trim(res.stdout or "")
end

-- Commit `n` (1-based) in the file's history, with the path it had there.
-- Follows renames from HEAD back; one `git log -n n+1` per call.
local function nth_commit(top, path, n)
    local code, out = git(top, { "log", "--follow", "-n", tostring(n + 1), "--format=%x00%H", "--name-only", "--", path })
    if code ~= 0 then
        return nil
    end

    local commits, last_path = {}, path
    for _, chunk in ipairs(vim.split(out, "\0", { plain = true, trimempty = true })) do
        -- "<hash>\n\n<path>"; merge commits list no file, so keep the newer name.
        local hash, file = chunk:match("^(%x+)%s*([^\n]*)")
        last_path = file ~= "" and file or last_path
        table.insert(commits, { hash = hash, path = last_path })
    end
    return commits[n], commits[n + 1]
end

local function open_view(top, rev, paths, state)
    local args = { "-C" .. vim.fn.fnameescape(top), rev }
    -- --imply-local (configs/diffview.lua) swaps HEAD for the working file.
    -- With uncommitted edits that would mix them into a commit's diff.
    if state.dirty and state.step > 0 then
        table.insert(args, "--imply-local=false")
    end
    table.insert(args, "--")
    for _, p in ipairs(paths) do
        table.insert(args, vim.fn.fnameescape(p))
    end

    -- Make sure the plugin (and configs/diffview.lua) is loaded first.
    require("lazy").load({ plugins = { "diffview.nvim" } })
    local view = require("diffview.lib").diffview_open(args)
    if not view then
        return
    end
    view:open()
    -- One file only: the panel is noise. <leader>b brings it back.
    if view.panel:is_open() then
        view.panel:close()
    end
    vim.api.nvim_tabpage_set_var(view.tabpage, "git_prev_revision", state)
end

local function show_step(state)
    local cur, older = nth_commit(state.top, state.path, state.step)
    if not cur then
        notify("No older revision of " .. state.path, vim.log.levels.WARN)
        return false
    end

    local has_parent = git(state.top, { "rev-parse", "-q", "--verify", cur.hash .. "^" }) == 0
    local left = has_parent and cur.hash .. "^" or EMPTY_TREE
    local paths = { cur.path }
    if older and older.path ~= cur.path then
        table.insert(paths, older.path) -- renamed in this commit
    end

    open_view(state.top, left .. ".." .. cur.hash, paths, state)
    return true
end

function M.open()
    -- Clicked again inside one of our diffs: step one commit further back.
    local state = vim.t.git_prev_revision
    if state then
        local next_state = vim.tbl_extend("force", state, { step = state.step + 1 })
        local lib = require("diffview.lib")
        local old_view = lib.get_current_view()
        if show_step(next_state) and old_view then
            old_view:close()
            lib.dispose_view(old_view)
        end
        return
    end

    local file = vim.api.nvim_buf_get_name(0)
    if file == "" or vim.bo.buftype ~= "" then
        notify("Current buffer is not a file", vim.log.levels.WARN)
        return
    end
    file = vim.uv.fs_realpath(file) or file

    local code, top = git(vim.fs.dirname(file), { "rev-parse", "--show-toplevel" })
    if code ~= 0 then
        notify("Not in a git repository", vim.log.levels.WARN)
        return
    end
    local path = vim.fs.relpath(top, file) or file
    if git(top, { "ls-files", "--error-unmatch", "--", path }) ~= 0 then
        notify(path .. " is not tracked by git", vim.log.levels.WARN)
        return
    end

    -- diffview lists files from `git diff`, which reads the disk. Not saving
    -- here on purpose: format-on-save (configs/conform.lua) would kick in.
    if vim.bo.modified then
        notify("Unsaved edits are not compared until you save", vim.log.levels.WARN)
    end

    local dirty = git(top, { "diff", "--quiet", "HEAD", "--", path }) == 1
    state = { top = top, path = path, step = 0, dirty = dirty }
    if dirty then
        open_view(top, "HEAD", { path }, state)
    else
        state.step = 1
        show_step(state)
    end
end

-- Click handler for the tabufline button: %@TbGitPrevRevision@
vim.cmd([[
  function! TbGitPrevRevision(a,b,c,d)
    lua require("git_prev_revision").open()
  endfunction]])

return M
