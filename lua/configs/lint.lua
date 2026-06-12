local lint = require("lint")

lint.linters_by_ft = {
    lua = { "luacheck" },
    -- haskell = { "hlint" },
    python = { "flake8" },
}

lint.linters.flake8.args = {
    "--extend-ignore=E501",
    "--format=%(path)s:%(row)d:%(col)d:%(code)s:%(text)s",
    "--no-show-source",
    "--stdin-display-name",
    function()
        return vim.api.nvim_buf_get_name(0)
    end,
    "-",
}

lint.linters.luacheck.args = {
    "--globals",
    "love",
    "vim",
    "--formatter",
    "plain",
    "--codes",
    "--ranges",
    "-",
}

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    callback = function()
        lint.try_lint()
    end,
})
