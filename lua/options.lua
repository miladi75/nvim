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

-- Force custom VHDL captures so they remain visible across colorscheme reloads.
local function apply_vhdl_custom_highlights()
    vim.api.nvim_set_hl(0, "@function.vhdl", { fg = "#3B82F6", bold = true })
    vim.api.nvim_set_hl(0, "@generic.vhdl", { fg = "#FFFFFF" })
    vim.api.nvim_set_hl(0, "@constant.vhdl", { fg = "#FFFFFF" })
    vim.api.nvim_set_hl(0, "@vprefix.vhdl", { fg = "#FF8C00" })
    vim.api.nvim_set_hl(0, "@port_signal.vhdl", { fg = "#FF8C00" })
    vim.api.nvim_set_hl(0, "@local_signal.vhdl", { fg = "#E5E510" })
    vim.api.nvim_set_hl(0, "@state.vhdl", { fg = "#33FF00", bold = true })
end

apply_vhdl_custom_highlights()

vim.api.nvim_create_autocmd("ColorScheme", {
    callback = apply_vhdl_custom_highlights,
})
