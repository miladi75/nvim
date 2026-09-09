local lint = require("lint")

lint.linters_by_ft = {
    lua = { "luacheck" },
    -- haskell = { "hlint" },
    python = { "flake8" },
    vhdl = { "vsg" },
}

-- vsg with the repo's rule file (configs/vsg.lua); the built-in linter only
-- knows the standard vsg_config.* names.
do
    local builtin = require("lint.linters.vsg")()
    builtin.args = {
        "-of",
        "syntastic",
        "--stdin",
        function()
            return unpack(require("configs.vsg").config_args(vim.fn.expand("%:p:h")))
        end,
    }
    lint.linters.vsg = builtin
end

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
