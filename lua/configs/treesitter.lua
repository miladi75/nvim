-- nvim-treesitter `main` branch: it only ships parsers and queries; highlight,
-- indent and folds are Neovim's own APIs, enabled per buffer below.
-- Parsers install to stdpath("data")/site/parser via tree-sitter-cli.

-- base46 highlight groups for treesitter captures (NvChad theme).
pcall(function()
    dofile(vim.g.base46_cache .. "syntax")
    dofile(vim.g.base46_cache .. "treesitter")
end)

local ts = require("nvim-treesitter")

local ensure_installed = {
    "bash",
    "c",
    "cmake",
    "cpp",
    "fish",
    "html",
    "latex", -- snacks.image math rendering
    "lua",
    "luadoc",
    "make",
    "markdown",
    "markdown_inline",
    "printf",
    "python",
    "query",
    "regex",
    "toml",
    "vhdl",
    "vim",
    "vimdoc",
    "yaml",
}

-- Install what is missing, in the background. Never blocks startup.
local installed = ts.get_installed("parsers")
local missing = vim.tbl_filter(function(lang)
    return not vim.tbl_contains(installed, lang)
end, ensure_installed)
if #missing > 0 then
    ts.install(missing)
end

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
    callback = function(ev)
        local lang = vim.treesitter.language.get_lang(ev.match)
        if not lang then
            return
        end
        -- start() errors when no parser is installed for the language.
        if not pcall(vim.treesitter.start, ev.buf, lang) then
            return
        end
        vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        -- Folds from the syntax tree; foldlevelstart=99 (options.lua) keeps
        -- everything open until zc/zM is used.
        vim.wo[0][0].foldmethod = "expr"
        vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
    end,
})
