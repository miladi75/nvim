return {

    {
        -- No autocomplete popups inside :Tutor buffers — cmp completes
        -- words scraped from the lesson text and hijacks exercise typing
        -- (Enter accepts a suggestion instead of inserting a newline).
        "hrsh7th/nvim-cmp",
        opts = function(_, opts)
            local cmp = require("cmp")

            opts.enabled = function()
                if vim.bo.filetype == "tutor" then
                    return false
                end
                return require("cmp.config.default")().enabled()
            end

            -- Popup is passive until explicitly engaged: nothing is
            -- preselected or inserted just because the menu appeared.
            opts.preselect = cmp.PreselectMode.None
            opts.completion = { completeopt = "menu,menuone,noinsert,noselect" }

            -- Enter only accepts an item the user actually navigated to
            -- (Tab/C-n); otherwise it inserts a plain newline.
            opts.mapping["<CR>"] = cmp.mapping.confirm({ select = false })

            -- Esc with the menu open just dismisses it and stays in insert
            -- mode. jk is noremap so it still exits insert unconditionally.
            opts.mapping["<Esc>"] = cmp.mapping(function(fallback)
                if cmp.visible() then
                    cmp.abort()
                else
                    fallback()
                end
            end, { "i" })
        end,
    },

    {
        "nvim-tree/nvim-tree.lua",
        opts = function()
            return require("configs.nvimtree")
        end,
    },

    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("configs.treesitter")
        end,
    },

    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("nvchad.configs.lspconfig").defaults()
            require("configs.lspconfig")
        end,
    },

    {
        "williamboman/mason-lspconfig.nvim",
        event = "VeryLazy",
        dependencies = { "nvim-lspconfig" },
        config = function()
            require("configs.mason-lspconfig")
        end,
    },

    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("configs.lint")
        end,
    },

    {
        "rshkarin/mason-nvim-lint",
        event = "VeryLazy",
        dependencies = { "nvim-lint" },
        config = function()
            require("configs.mason-lint")
        end,
    },

    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        config = function()
            require("configs.conform")
        end,
    },

    {
        "zapling/mason-conform.nvim",
        event = "VeryLazy",
        dependencies = { "conform.nvim" },
        config = function()
            require("configs.mason-conform")
        end,
    },

    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        config = function()
            require("configs.gitsigns")
        end,
    },

    {
        "sindrets/diffview.nvim",
        cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
        dependencies = { "nvim-lua/plenary.nvim" },
        config = function()
            require("configs.diffview")
        end,
    },

    {
        -- In-buffer markdown rendering (headings, tables, checkboxes, code
        -- blocks) — complements peek.nvim, which previews in the browser.
        -- Plugin manages its own lazy-loading; lazy = false is required.
        "OXY2DEV/markview.nvim",
        lazy = false,
    },

    {
        -- Inline images in kitty via graphics protocol; renders mermaid
        -- fenced blocks in markdown as diagrams (needs mmdc on PATH).
        -- Only the image module is enabled — dashboard etc. stay NvChad's.
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            image = {
                enabled = true,
                doc = {
                    inline = true,
                    float = true,
                    max_width = 80,
                    max_height = 40,
                    -- Hide the raw ```mermaid source once the diagram
                    -- image is rendered (default only conceals math).
                    conceal = function(lang, type)
                        return type == "math" or lang == "mermaid"
                    end,
                },
                convert = {
                    -- Ubuntu AppArmor blocks chromium's user-namespace
                    -- sandbox, so mmdc needs a puppeteer config passing
                    -- --no-sandbox or every render dies at launch.
                    mermaid = function()
                        local theme = vim.o.background == "light" and "neutral" or "dark"
                        return {
                            "-p",
                            vim.fn.stdpath("config") .. "/mermaid-puppeteer.json",
                            "-i",
                            "{src}",
                            "-o",
                            "{file}",
                            "-b",
                            "transparent",
                            "-t",
                            theme,
                            -- terminal.size().scale is 1 here, which makes
                            -- diagrams render tiny; 2 fills the cell cap.
                            "-s",
                            "2",
                        }
                    end,
                },
            },
        },
    },

    {
        "toppair/peek.nvim",
        event = { "VeryLazy" },
        build = "deno task --quiet build:fast",
        config = function()
            require("peek").setup({
                auto_load = true,
                syntax_theme = "dark",
                theme = "dark",
                app = "browser",
                filetype = { "markdown" },
            })
            vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
            vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
        end,
    },

    {
        "mikesmithgh/kitty-scrollback.nvim",
        lazy = true,
        cmd = { "KittyScrollbackGenerateKittens", "KittyScrollbackCheckHealth" },
        event = { "User KittyScrollbackLaunch" },
        config = function()
            require("kitty-scrollback").setup()
        end,
    },
}
