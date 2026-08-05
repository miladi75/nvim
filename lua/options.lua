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

-- markview can't draw table borders in wrapped windows (falls back to raw
-- pipes), so markdown buffers get nowrap.
vim.api.nvim_create_autocmd("FileType", {
    pattern = "markdown",
    callback = function()
        vim.opt_local.wrap = false
    end,
})

-- set filetype for .CBL COBOL files.
-- vim.cmd([[ au BufRead,BufNewFile *.CBL set filetype=cobol ]])
