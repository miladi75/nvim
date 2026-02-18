-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v2.5/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.base46 = {
    theme = "catppuccin",

    -- hl_override = {
    -- 	Comment = { italic = true },
    -- 	["@comment"] = { italic = true },
    -- },
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
