local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

-- local lspconfig = require("lspconfig") -- pre nvim 0.11
local lspconfig = require("nvchad.configs.lspconfig") -- nvim 0.11

-- list of all servers configured.
lspconfig.servers = {
    "lua_ls",
    "clangd",
    "vhdl_ls",
    -- "gopls",
    -- "hls",
    -- "ols",
    -- "pyright",
}

-- list of servers configured with default config.
local default_servers = {
    -- "ols",
    -- "pyright",
}

-- lsps with default config
for _, lsp in ipairs(default_servers) do
    -- lspconfig[lsp].setup({ -- pre nvim 0.11
    vim.lsp.config(lsp, { -- nvim 0.11
        on_attach = on_attach,
        on_init = on_init,
        capabilities = capabilities,
    })
end

local uv = vim.uv or vim.loop

-- Try to locate compile_commands.json in common out-of-tree build directories.
local function find_compile_commands_dir(root)
    if not root then
        return nil
    end

    local preferred_dirs = {
        root,
        vim.fs.joinpath(root, "build"),
        vim.fs.joinpath(root, "cmake-build-debug"),
        vim.fs.joinpath(root, "cmake-build-release"),
    }

    for _, dir in ipairs(preferred_dirs) do
        local candidate = vim.fs.joinpath(dir, "compile_commands.json")
        if uv.fs_stat(candidate) then
            if dir == root then
                return nil
            end
            return dir
        end
    end
end

local clangd_base_cmd = {
    "clangd",
    "--background-index",
    "--background-index-priority=low",
    "--completion-style=detailed",
    "--header-insertion=iwyu",
    "--log=error",
    "--clang-tidy",
    "--fallback-style=none",
}

vim.lsp.config("clangd", {
    cmd = clangd_base_cmd,
    on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        on_attach(client, bufnr)
    end,
    on_new_config = function(new_config, root_dir)
        local cmd = { unpack(clangd_base_cmd) }
        local compile_commands_dir = find_compile_commands_dir(root_dir)

        if compile_commands_dir then
            table.insert(cmd, "--compile-commands-dir=" .. compile_commands_dir)
        end

        new_config.cmd = cmd
    end,
    on_init = on_init,
    capabilities = capabilities,
})

-- -- lspconfig.gopls.setup({ -- pre nvim 0.11
-- vim.lsp.config("gopls", { -- nvim 0.11
--     on_attach = function(client, bufnr)
--         client.server_capabilities.documentFormattingProvider = false
--         client.server_capabilities.documentRangeFormattingProvider = false
--         on_attach(client, bufnr)
--     end,
--     on_init = on_init,
--     capabilities = capabilities,
--     cmd = { "gopls" },
--     filetypes = { "go", "gomod", "gotmpl", "gowork" },
--     -- root_dir = lspconfig.util.root_pattern("go.work", "go.mod", ".git"), -- pre nvim 0.11
--     root_dir = require("lspconfig.util").root_pattern("go.work", "go.mod", ".git"), -- nvim 0.11
--     settings = {
--         gopls = {
--             analyses = {
--                 unusedparams = true,
--             },
--             completeUnimported = true,
--             usePlaceholders = true,
--             staticcheck = true,
--         },
--     },
-- })

-- -- lspconfig.hls.setup({ -- pre nvim 0.11
-- vim.lsp.config("hls", { -- nvim 0.11
--     on_attach = function(client, bufnr)
--         client.server_capabilities.documentFormattingProvider = false
--         client.server_capabilities.documentRangeFormattingProvider = false
--         on_attach(client, bufnr)
--     end,
--
--     on_init = on_init,
--     capabilities = capabilities,
-- })

-- lspconfig.lua_ls.setup({ -- pre nvim 0.11
vim.lsp.config("lua_ls", { -- nvim 0.11
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,

    settings = {
        Lua = {
            diagnostics = {
                enable = false, -- Disable all diagnostics from lua_ls
                -- globals = { "vim" },
            },
            workspace = {
                library = {
                    vim.fn.expand("$VIMRUNTIME/lua"),
                    vim.fn.expand("$VIMRUNTIME/lua/vim/lsp"),
                    vim.fn.stdpath("data") .. "/lazy/ui/nvchad_types",
                    vim.fn.stdpath("data") .. "/lazy/lazy.nvim/lua/lazy",
                    "${3rd}/love2d/library",
                },
                maxPreload = 100000,
                preloadFileSize = 10000,
            },
        },
    },
})

-- VHDL Language Server (vhdl_ls from rust_hdl)
-- Requires a vhdl_ls.toml config file in your project root
vim.lsp.config("vhdl_ls", {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
    cmd = { "/home/milad/dev/open-source/rust_hdl/target/release/vhdl_ls" },
    filetypes = { "vhdl" },
    root_dir = require("lspconfig.util").root_pattern("vhdl_ls.toml", ".git"),
})
