require("nvchad.options")

local o = vim.o

-- Indenting
o.shiftwidth = 4
o.tabstop = 4
o.softtabstop = 4

-- Line numbers
o.number = true
o.relativenumber = true

-- cargo-installed tools first: nvim-treesitter needs tree-sitter-cli >= 0.26
-- and an older npm one shadows it in the shell PATH.
vim.env.PATH = vim.fn.expand("~/.cargo/bin") .. ":" .. vim.env.PATH

-- Folding comes from treesitter (configs/treesitter.lua); open everything
-- when a file loads, fold on demand with zc / zM / zR.
o.foldlevelstart = 99
o.foldtext = ""

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
