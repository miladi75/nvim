local lint = package.loaded["lint"]

-- List of linters to ignore during install.
-- vsg is installed with `uv tool install vsg`; letting Mason install it too
-- races with mason-conform ("Package is already installing").
local ignore_install = { "vsg" }

-- Helper function to find if value is in table.
local function table_contains(table, value)
    for _, v in ipairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

-- Build a list of linters to install minus the ignored list.
local all_linters = {}
for _, v in pairs(lint.linters_by_ft) do
    for _, linter in ipairs(v) do
        if not table_contains(ignore_install, linter) then
            table.insert(all_linters, linter)
        end
    end
end

require("mason-nvim-lint").setup({
    ensure_installed = all_linters,
    automatic_installation = false,
})
