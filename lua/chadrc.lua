-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.base46 = {
    hl_override = {
        ["@state.vhdl"] = { fg = "#02710C", bold = true },
        ["@vprefix.vhdl"] = { fg = "#00C2B5" },
        ["@function.vhdl"] = { fg = "#1E69E2", bold = true },
        ["@constant.vhdl"] = { fg = "#FFFFFF" },
        ["@generic.vhdl"] = { fg = "#FFFFFF" },
        ["@type_prefix.vhdl"] = { fg = "#04F792" },
        ["@port_signal.vhdl"] = { fg = "#FF8400" },
        ["@local_signal.vhdl"] = { fg = "#FF8400" },
    },
    theme = "catppuccin",
}

-- Widen the file explorer (NvimTree) so filenames fit.
M.nvimtree = {
    view = {
        width = 100,
    },
}
-- ADD THE M.mappings TABLE HERE
M.mappings = {
    -- Keymaps for Normal mode (n)
    n = {
        -- This line adds the <Leader>fg keymap to run Telescope Live Grep
        ["<leader>fg"] = { "<cmd>Telescope live_grep<cr>", "Telescope Live Grep" },
    },

    -- You can add mappings for other modes if needed, e.g., Visual mode (v), Insert mode (i), etc.
    -- v = {},
    -- i = {},
}
return M
