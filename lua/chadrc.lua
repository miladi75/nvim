-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.base46 = {
    -- VHDL_COLORS_BEGIN (managed by setup_vhdl_colors.py — do not edit)
    -- Only conventions with no native equivalent are listed.
    -- s_*/v_*/g_*/c_*/enums use @number and t_*/sl/slv/to_*/*_lib use
    -- @type.builtin, so they follow the active theme.
    hl_add = {
        ["@function.vhdl"] = { fg = "#00D9FA" },
    },
    -- VHDL_COLORS_END
    theme = "horizon",
}

-- Diff filler lines (the side that has no lines, e.g. the left side of an
-- added block): muted red hatching like VSCode, drawn with the `diff`
-- fillchar from options.lua. diffview's enhanced_diff_hl links the filler to
-- this group, which otherwise falls back to Comment (grey dashes).
-- Kept outside the VHDL_COLORS block, which setup_vhdl_colors.py rewrites.
M.base46.hl_add = M.base46.hl_add or {}
M.base46.hl_add.DiffviewDiffDeleteDim = { fg = { "red", "black", 40 } }

-- Diff lines keep their syntax colours (VSCode style): base46 gives
-- DiffAdd/DiffChange/DiffText a fg, which paints whole lines one colour.
-- Only the backgrounds mark the change. DiffDelete keeps its red fg: it
-- draws the filler hatching in plain :diffthis windows.
M.base46.hl_override = {
    DiffAdd = { fg = "NONE" },
    DiffChange = { fg = "NONE" },
    DiffText = { fg = "NONE", bg = { "light_grey", "black", 75 } },
}

-- Right-hand tabufline buttons. Shared by the `btns` module and the width
-- calculation in `buffers`, so the buffer list never overlaps them.
local function tabufline_buttons()
    local btn = require("nvchad.tabufline.utils").btn
    -- VSCode-style "open changes with previous revision" (lua/git_prev_revision.lua).
    -- Only for files gitsigns tracks, or inside a diff it opened.
    local prev_rev = ""
    if vim.b.gitsigns_head or vim.t.git_prev_revision then
        require("git_prev_revision") -- defines the TbGitPrevRevision click handler
        prev_rev = btn(" 󰁍 ", "ThemeToggleBtn", "GitPrevRevision")
    end
    local toggle_theme = btn(vim.g.toggle_theme_icon or "   ", "ThemeToggleBtn", "Toggle_theme")
    local close_all = btn(" 󰅖 ", "CloseAllBufsBtn", "CloseAllBufs")
    return prev_rev .. toggle_theme .. close_all
end

M.ui = {
    tabufline = {
        bufwidth = 21,
        modules = {
            btns = tabufline_buttons,
            buffers = function()
                local api = vim.api
                local txt = require("nvchad.tabufline.utils").txt
                local style_buf = require("nvchad.tabufline.utils").style_buf
                local opts = require("nvconfig").ui.tabufline
                local current_buf = api.nvim_get_current_buf()

                local function get_nvimtree_width()
                    for _, win in pairs(api.nvim_tabpage_list_wins(0)) do
                        if vim.bo[api.nvim_win_get_buf(win)].ft == "NvimTree" then
                            return api.nvim_win_get_width(win)
                        end
                    end

                    return 0
                end

                local function tree_offset()
                    local width = get_nvimtree_width()
                    return width == 0 and ""
                        or "%#NvimTreeNormal#" .. string.rep(" ", width) .. "%#NvimTreeWinSeparator#│"
                end

                local function tabs()
                    local fn = vim.fn
                    local btn = require("nvchad.tabufline.utils").btn
                    local result, total_tabs = "", fn.tabpagenr("$")

                    if total_tabs > 1 then
                        for nr = 1, total_tabs do
                            local tab_hl = "TabO" .. (nr == fn.tabpagenr() and "n" or "ff")
                            result = result .. btn(" " .. nr .. " ", tab_hl, "GotoTab", nr)
                        end

                        local new_tab_btn = btn(" 󰐕 ", "TabNewBtn", "NewTab")
                        local tabs_toggle_btn = btn(" TABS ", "TabTitle", "ToggleTabs")
                        local small_btn = btn(" 󰅁 ", "TabTitle", "ToggleTabs")

                        return vim.g.TbTabsToggled == 1 and small_btn or new_tab_btn .. tabs_toggle_btn .. result
                    end

                    return ""
                end

                local function available_space()
                    local layout = tree_offset() .. tabs() .. tabufline_buttons()
                    local modules = api.nvim_eval_statusline(layout, { use_tabline = true })
                    return vim.o.columns - modules.width
                end

                local buffers = {}
                local has_current = false
                local other_width = opts.bufwidth or 21
                local used_width = 0

                local function filename(path)
                    return path:match("([^/\\]+)[/\\]*$") or "No Name"
                end

                local function buf_width(nr)
                    local name = filename(api.nvim_buf_get_name(nr))
                    local content_width = vim.fn.strdisplaywidth(name)

                    -- Match the filename length, plus icon/close button/padding.
                    return math.max(other_width, content_width + 8)
                end

                vim.t.bufs = vim.tbl_filter(api.nvim_buf_is_valid, vim.t.bufs)

                for i, nr in ipairs(vim.t.bufs) do
                    local width = buf_width(nr)

                    if (used_width + width) > available_space() then
                        if has_current then
                            break
                        end

                        local removed = table.remove(buffers, 1)
                        if removed then
                            used_width = used_width - removed.width
                        end
                    end

                    has_current = nr == current_buf or has_current
                    table.insert(buffers, { text = style_buf(nr, i, width), width = width })
                    used_width = used_width + width
                end

                local rendered = {}
                for _, item in ipairs(buffers) do
                    table.insert(rendered, item.text)
                end

                return table.concat(rendered) .. txt("%=", "Fill")
            end,
        },
    },
}

-- Startup dashboard (the big-text screen, like LazyVim's greeter).
-- NOTE: header needs at least 12 lines to fully mask the default one
-- (chadrc is deep-merged element-wise into nvconfig defaults).
M.nvdash = {
    -- Plain `nvim` opens a blank, writable buffer so you can type right
    -- away. The dashboard (with the art below) is still available on
    -- demand: run :Nvdash any time.
    load_on_startup = false,

    -- Each line is centered individually by nvdash. A window must be at
    -- least 12 columns wider than the widest line or nvdash errors, so
    -- MILAD/CHAD are stacked instead of one long word.
    header = {
        "                                          ",
        "███╗   ███╗ ██╗ ██╗       █████╗  ██████╗ ",
        "████╗ ████║ ██║ ██║      ██╔══██╗ ██╔══██╗",
        "██╔████╔██║ ██║ ██║      ███████║ ██║  ██║",
        "██║╚██╔╝██║ ██║ ██║      ██╔══██║ ██║  ██║",
        "██║ ╚═╝ ██║ ██║ ███████╗ ██║  ██║ ██████╔╝",
        "╚═╝     ╚═╝ ╚═╝ ╚══════╝ ╚═╝  ╚═╝ ╚═════╝ ",
        " ██████╗ ██╗  ██╗  █████╗  ██████╗ ",
        "██╔════╝ ██║  ██║ ██╔══██╗ ██╔══██╗",
        "██║      ███████║ ███████║ ██║  ██║",
        "██║      ██╔══██║ ██╔══██║ ██║  ██║",
        "╚██████╗ ██║  ██║ ██║  ██║ ██████╔╝",
        " ╚═════╝ ╚═╝  ╚═╝ ╚═╝  ╚═╝ ╚═════╝ ",
        "                                          ",
        "      hands on keyboard · mind on code    ",
        "                                          ",
    },
}

-- Widen the file explorer (NvimTree) so filenames fit.
M.nvimtree = {
    view = {
        width = 100,
    },
}
-- NOTE: NvChad 2.5 does NOT read mappings from chadrc (M.mappings). All
-- custom keymaps live in lua/mappings.lua — <leader>fg is defined there.
return M
