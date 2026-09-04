-- gitsigns: gutter signs, hunk staging, blame, quick diffs.
-- All hunk/blame keys live in on_attach so they only exist in buffers that are
-- actually tracked by git (and show up in which-key only there).
-- Repo-wide diffs/history/merges are diffview's job (configs/diffview.lua).

-- base46 highlight groups for GitSigns* (NvChad theme integration).
dofile(vim.g.base46_cache .. "git")

local gitsigns = require("gitsigns")

gitsigns.setup({
    signs = {
        add = { text = "┃" },
        change = { text = "┃" },
        delete = { text = "▁" },
        topdelete = { text = "▔" },
        changedelete = { text = "~" },
        untracked = { text = "┆" },
    },
    signs_staged_enable = true, -- staged hunks get their own (dimmer) sign
    numhl = false,
    linehl = false,
    word_diff = false, -- toggle per buffer with <leader>gw
    attach_to_untracked = true,
    update_debounce = 100,
    max_file_length = 40000,

    -- Inline blame for the cursor line. Only while the window has focus, short
    -- delay, relative dates. <leader>gl toggles it, <leader>gb shows the full
    -- commit for the line, <leader>gB opens a fugitive-style blame of the file.
    current_line_blame = true,
    current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol",
        delay = 400,
        ignore_whitespace = true,
        use_focus = true,
    },
    current_line_blame_formatter = "  <abbrev_sha> <author>, <author_time:%R> • <summary>",
    current_line_blame_formatter_nc = "  not committed yet",

    preview_config = {
        border = "rounded",
        style = "minimal",
        relative = "cursor",
        row = 1,
        col = 1,
    },

    on_attach = function(bufnr)
        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc, silent = true })
        end

        -- Navigation. In a diff window (diffthis / diffview) fall back to
        -- vim's own ]c/[c so the same keys work everywhere.
        map("n", "]h", function()
            if vim.wo.diff then
                vim.cmd.normal({ "]c", bang = true })
            else
                gitsigns.nav_hunk("next", { target = "all" })
            end
        end, "Next hunk")
        map("n", "[h", function()
            if vim.wo.diff then
                vim.cmd.normal({ "[c", bang = true })
            else
                gitsigns.nav_hunk("prev", { target = "all" })
            end
        end, "Previous hunk")

        -- Hunks
        map("n", "<leader>gh", gitsigns.preview_hunk_inline, "Git preview hunk (inline)")
        map("n", "<leader>gH", gitsigns.preview_hunk, "Git preview hunk (popup)")
        map("n", "<leader>gs", gitsigns.stage_hunk, "Git stage/unstage hunk")
        map("v", "<leader>gs", function()
            gitsigns.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Git stage selected lines")
        map("n", "<leader>gr", gitsigns.reset_hunk, "Git reset hunk")
        map("v", "<leader>gr", function()
            gitsigns.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
        end, "Git reset selected lines")
        map("n", "<leader>gu", gitsigns.undo_stage_hunk, "Git undo last stage")
        map("n", "<leader>gS", gitsigns.stage_buffer, "Git stage whole buffer")
        map("n", "<leader>gR", gitsigns.reset_buffer, "Git reset whole buffer")
        map("n", "<leader>gq", function()
            gitsigns.setqflist("all")
        end, "Git hunks (all buffers) → quickfix")

        -- Blame
        map("n", "<leader>gb", function()
            gitsigns.blame_line({ full = true })
        end, "Git blame line (full commit)")
        map("n", "<leader>gB", gitsigns.blame, "Git blame file (side window)")
        map("n", "<leader>gl", gitsigns.toggle_current_line_blame, "Git toggle inline line blame")

        -- Quick two-pane diff of this file (no diffview, no tab)
        map("n", "<leader>gd", gitsigns.diffthis, "Git diff file vs index")
        map("n", "<leader>gD", function()
            gitsigns.diffthis("~")
        end, "Git diff file vs HEAD~")

        -- Toggles
        map("n", "<leader>gw", gitsigns.toggle_word_diff, "Git toggle word diff")
        map("n", "<leader>gx", gitsigns.toggle_deleted, "Git toggle deleted lines")

        -- Text object: `ih` = current hunk (dih, yih, vih ...)
        map({ "o", "x" }, "ih", gitsigns.select_hunk, "Select hunk")
    end,
})
