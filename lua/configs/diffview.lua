-- diffview: repo-wide diffs, file history and merge conflicts in one tab.
-- Per-hunk work (stage/reset/blame) is gitsigns (configs/gitsigns.lua).

require("diffview").setup({
    enhanced_diff_hl = true,
    use_icons = true,
    default_args = {
        -- --imply-local: the right-hand side of a working-tree diff is the real
        -- file, so LSP, gitsigns and normal editing keep working there.
        DiffviewOpen = { "--imply-local" },
    },
    view = {
        default = { layout = "diff2_horizontal", disable_diagnostics = true },
        merge_tool = { layout = "diff3_horizontal", disable_diagnostics = true },
        file_history = { layout = "diff2_horizontal", disable_diagnostics = true },
    },
    file_panel = {
        listing_style = "tree",
        win_config = { position = "left", width = 35 },
    },
    file_history_panel = {
        log_options = {
            git = {
                single_file = { follow = true },
            },
        },
    },
    hooks = {
        diff_buf_read = function(bufnr)
            -- Diffs are easier to read without wrapping or trailing-space marks.
            vim.opt_local.wrap = false
            vim.opt_local.list = false
            vim.opt_local.colorcolumn = ""
            -- Diff-mode ]c/[c jumps via the same keys gitsigns uses elsewhere.
            vim.keymap.set("n", "]h", "]c", { buffer = bufnr, desc = "Next change" })
            vim.keymap.set("n", "[h", "[c", { buffer = bufnr, desc = "Previous change" })
        end,
    },
    keymaps = {
        view = {
            { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
            { "n", "<leader>gv", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
        },
        file_panel = {
            { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
            { "n", "<leader>gv", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
        },
        file_history_panel = {
            { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
            { "n", "<leader>gv", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
        },
    },
})

-- Removed lines (left side): diffview copies DiffDelete, red fg included,
-- which hides the syntax colours. Keep only the red background. Re-applied on
-- ColorScheme after diffview's own handler (registered earlier, in setup).
local function diff_delete_bg_only()
    local bg = vim.api.nvim_get_hl(0, { name = "DiffDelete", link = false }).bg
    vim.api.nvim_set_hl(0, "DiffviewDiffAddAsDelete", { bg = bg })
end
diff_delete_bg_only()
vim.api.nvim_create_autocmd("ColorScheme", { callback = diff_delete_bg_only })

-- `:q` in a panel closes the whole view instead of leaving a broken layout.
-- Only panels: diff buffers may be real files (--imply-local) and a cabbrev
-- there would outlive the view.
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "DiffviewFiles", "DiffviewFileHistory" },
    callback = function()
        vim.cmd("cabbrev <buffer> q DiffviewClose")
        vim.cmd("cabbrev <buffer> q! DiffviewClose")
    end,
})
