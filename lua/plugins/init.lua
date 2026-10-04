return {

    -- Completion: blink.cmp via NvChad's own integration (replaces nvim-cmp,
    -- which it disables). Per-keystroke updates with a Rust fuzzy matcher
    -- instead of nvim-cmp's 60 ms debounce.
    { import = "nvchad.blink.lazyspec" },
    {
        "saghen/blink.cmp",
        opts = {
            -- No completion inside :Tutor buffers — it would complete words
            -- scraped from the lesson text and hijack exercise typing.
            enabled = function()
                return vim.bo.filetype ~= "tutor" and vim.bo.buftype ~= "prompt"
            end,
            completion = {
                -- Menu is passive until engaged: nothing preselected or
                -- inserted just because it appeared.
                list = { selection = { preselect = false, auto_insert = false } },
                ghost_text = { enabled = false },
            },
            keymap = {
                -- Enter only accepts an item the user navigated to (Tab/C-n);
                -- with nothing selected it inserts a plain newline.
                ["<CR>"] = { "accept", "fallback" },
                -- Esc with the menu open just dismisses it and stays in insert
                -- mode. `jk` is noremap so it still exits insert unconditionally.
                ["<Esc>"] = {
                    function(cmp)
                        if cmp.is_visible() then
                            cmp.hide()
                            return true
                        end
                    end,
                    "fallback",
                },
            },
        },
    },

    {
        "nvim-tree/nvim-tree.lua",
        opts = function()
            return require("configs.nvimtree")
        end,
    },

    {
        -- `main` branch: the old `master` (nvim-treesitter.configs) is archived.
        -- Highlight/indent/folds are wired up natively in configs/treesitter.lua.
        -- Not lazy: the plugin is tiny and the FileType autocmd must exist
        -- before the first buffer loads.
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            require("configs.treesitter")
        end,
    },

    {
        -- Labelled jumps: `s` + 2 chars jumps anywhere on screen, `S` selects
        -- treesitter nodes. f/F/t/T get labels too. `;` and `,` are left alone
        -- because `;` is remapped to `:` in mappings.lua.
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {
            modes = {
                search = { enabled = false },
                char = { keys = { "f", "F", "t", "T" } },
            },
        },
        keys = {
            { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash jump" },
            { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash treesitter select" },
            { "r", mode = "o", function() require("flash").remote() end, desc = "Flash remote (operator at a jump)" },
            { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Flash treesitter search" },
            { "<c-s>", mode = "c", function() require("flash").toggle() end, desc = "Toggle flash in search" },
        },
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
        config = function()
            require("markview").setup({
                -- Rendering is opt-in per buffer via <leader>mv (see
                -- mappings.lua) instead of auto-on for every markdown file.
                preview = { enable = false },
                -- snacks.nvim renders $...$ math as real images; markview's
                -- text-based latex approximations drew a second copy of
                -- every subscript next to them.
                latex = { enable = false },
            })
        end,
    },

    {
        -- Inline images in kitty via graphics protocol; renders mermaid
        -- fenced blocks in markdown as diagrams (needs mmdc on PATH).
        -- Only the image module is enabled — dashboard etc. stay NvChad's.
        "folke/snacks.nvim",
        priority = 1000,
        lazy = false,
        opts = {
            -- Picker as vim.ui.select (code actions, etc.) — the git pickers in
            -- mappings.lua work without this; it only swaps the select UI.
            picker = { enabled = true },
            image = {
                enabled = true,
                -- Default list minus "pdf": snacks only draws page 1, so PDFs
                -- go to the Brave viewer instead (BufReadCmd in mappings.lua).
                formats = {
                    "png", "jpg", "jpeg", "gif", "bmp", "webp", "tiff", "heic",
                    "avif", "mp4", "mov", "avi", "mkv", "webm", "icns",
                },
                doc = {
                    -- No auto-attach on markdown open; <leader>mv calls
                    -- Snacks.image.doc.attach() explicitly.
                    enabled = false,
                    inline = true,
                    float = true,
                    max_width = 120,
                    max_height = 60,
                    -- Hide the raw ```mermaid source once the diagram
                    -- image is rendered (default only conceals math).
                    conceal = function(lang, type)
                        return type == "math" or lang == "mermaid"
                    end,
                },
                -- Default "Large" + 192dpi renders equations comically
                -- oversized next to 12pt terminal text.
                math = {
                    latex = { font_size = "normalsize" },
                },
                convert = {
                    magick = {
                        -- Transparent border after trim = vertical breathing
                        -- room between stacked equations.
                        math = {
                            "-density",
                            150,
                            "{src}[{page}]",
                            "-trim",
                            "-bordercolor",
                            "transparent",
                            "-border",
                            "0x12",
                        },
                    },
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
                            -- diagrams render tiny; 3 gives a comfortably
                            -- large diagram (display capped by max_width/
                            -- max_height cells).
                            "-s",
                            "3",
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
                -- Only reachable via :PeekOpen now; <leader>mp uses
                -- scripts/preview.sh instead.
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
