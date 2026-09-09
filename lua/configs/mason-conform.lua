require("mason-conform").setup({
    -- List of formatters to ignore during install.
    -- vsg comes from `uv tool install vsg` (see configs/mason-lint.lua).
    ignore_install = { "vsg" },
})
