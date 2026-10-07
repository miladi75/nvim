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

-- Linters read the buffer over stdin, so re-running on unchanged text only
-- reproduces the same diagnostics. vsg costs ~3 s of CPU on a 2600-line file,
-- and BufEnter fires on every window/buffer switch, so skip runs unless the
-- buffer changed since its last lint. :lua require("lint").try_lint() and the
-- <leader>vsg toggle bypass this check.
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
    callback = function(args)
        -- try_lint() lints the current buffer; :wa fires BufWritePost for
        -- others, which must not be marked as linted.
        if args.buf ~= vim.api.nvim_get_current_buf() then
            return
        end
        local tick = vim.b[args.buf].changedtick
        if vim.b[args.buf].lint_tick == tick then
            return
        end
        vim.b[args.buf].lint_tick = tick
        lint.try_lint()
    end,
})
