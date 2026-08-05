local options = {
    ensure_installed = {
        "bash",
        "c",
        "cmake",
        "cpp",
        "fish",
        -- "go",
        -- "gomod",
        -- "gosum",
        -- "gotmpl",
        -- "gowork",
        -- "haskell",
        "html",
        "lua",
        "luadoc",
        "make",
        "markdown",
        "markdown_inline",
        -- "odin",
        "printf",
        "query",
        "python",
        "toml",
        "vhdl",
        "vim",
        "vimdoc",
        "yaml",
    },

    highlight = {
        enable = true,
        use_languagetree = true,
    },

    indent = { enable = true },
}

require("nvim-treesitter.configs").setup(options)
