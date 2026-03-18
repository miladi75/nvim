require("diffview").setup({
    enhanced_diff_hl = true,
    view = {
        default = {
            layout = "diff2_horizontal",
        },
        merge_tool = {
            layout = "diff3_horizontal",
        },
        file_history = {
            layout = "diff2_horizontal",
        },
    },
    file_panel = {
        listing_style = "tree",
        win_config = {
            position = "left",
            width = 35,
        },
    },
    keymaps = {
        view = {
            { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
        },
        file_panel = {
            { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
        },
        file_history_panel = {
            { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close diffview" } },
        },
    },
    hooks = {
        view_opened = function()
            -- Override :q to close diffview instead of individual splits
            vim.cmd("cabbrev <buffer> q DiffviewClose")
            vim.cmd("cabbrev <buffer> q! DiffviewClose")
        end,
    },
})

-- Also override :q in all diffview-related buffers
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "DiffviewFiles", "DiffviewFileHistory", "DiffviewFileHistoryPanel" },
    callback = function()
        vim.cmd("cabbrev <buffer> q DiffviewClose")
        vim.cmd("cabbrev <buffer> q! DiffviewClose")
        -- Toggle: <leader>gv opens it, <leader>gv also closes it
        vim.keymap.set("n", "<leader>gv", "<cmd>DiffviewClose<cr>", { buffer = true, desc = "Close diffview" })
    end,
})
