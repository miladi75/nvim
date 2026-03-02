require("nvchad.options")

local o = vim.o

-- Indenting
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4

-- Line numbers
o.number = true
o.relativenumber = true

-- o.cursorlineopt ='both' -- to enable cursorline!

-- set filetype for .CBL COBOL files.
-- vim.cmd([[ au BufRead,BufNewFile *.CBL set filetype=cobol ]])

-- VHDL_COLORS_BEGIN (managed by setup_vhdl_colors.py — do not edit)
local function apply_vhdl_custom_highlights()
    vim.api.nvim_set_hl(0, "@state.vhdl", { fg = "#02710C", bold = true })
    vim.api.nvim_set_hl(0, "@vprefix.vhdl", { fg = "#F0E806" })
    vim.api.nvim_set_hl(0, "@function.vhdl", { fg = "#1E69E2", bold = true })
    vim.api.nvim_set_hl(0, "@constant.vhdl", { fg = "#FFFFFF" })
    vim.api.nvim_set_hl(0, "@generic.vhdl", { fg = "#FFFFFF" })
    vim.api.nvim_set_hl(0, "@type_prefix.vhdl", { fg = "#04F792" })
    vim.api.nvim_set_hl(0, "@port_signal.vhdl", { fg = "#00C2B5" })
    vim.api.nvim_set_hl(0, "@local_signal.vhdl", { fg = "#FF8400" })
end

apply_vhdl_custom_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = apply_vhdl_custom_highlights,
})
-- VHDL_COLORS_END
