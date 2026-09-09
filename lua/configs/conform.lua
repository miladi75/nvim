local options = {
    formatters_by_ft = {
        lua = { "stylua" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        -- go = { "gofumpt", "goimports-reviser", "golines" },
        -- haskell = { "fourmolu", "stylish-haskell" },
        python = { "isort", "black" },
        vhdl = { "vsg" },
    },

    formatters = {
        -- VHDL Style Guide. On demand only (<leader>fm): --fix rewrites whole
        -- files and is too invasive for format-on-save in the firmware repo.
        vsg = {
            args = function(_, ctx)
                local args = { "-of", "syntastic", "--fix", "-f", "$FILENAME" }
                vim.list_extend(args, require("configs.vsg").config_args(ctx.dirname))
                return args
            end,
        },
        ["clang-format"] = {
            prepend_args = {
                "--fallback-style=LLVM", -- match clangd defaults if no .clang-format file
            },
        },
        -- -- Golang
        -- ["goimports-reviser"] = {
        --     prepend_args = { "-rm-unused" },
        -- },
        -- golines = {
        --     prepend_args = { "--max-len=80" },
        -- },
        -- -- Lua
        -- stylua = {
        --     prepend_args = {
        --         "--column-width", "80",
        --         "--line-endings", "Unix",
        --         "--indent-type", "Spaces",
        --         "--indent-width", "4",
        --         "--quote-style", "AutoPreferDouble",
        --     },
        -- },
        -- Python
        black = {
            prepend_args = {
                "--fast",
                "--line-length",
                "80",
            },
        },
        isort = {
            prepend_args = {
                "--profile",
                "black",
            },
        },
    },

    format_on_save = function(bufnr)
        if vim.bo[bufnr].filetype == "vhdl" then
            return nil -- see formatters.vsg
        end
        -- These options will be passed to conform.format()
        return { timeout_ms = 500, lsp_format = "fallback" }
    end,
}

require("conform").setup(options)
