local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

-- blink.cmp does not register its capabilities on its own; merge them into
-- NvChad's set so servers know about snippets, resolve support, etc.
do
    local ok, blink = pcall(require, "blink.cmp")
    if ok then
        capabilities = blink.get_lsp_capabilities(capabilities)
        vim.lsp.config("*", { capabilities = capabilities })
    end
end

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
    "pyright",
}

-- list of servers configured with default config.
local default_servers = {
    -- "ols",
    "pyright",
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
    -- cmd as a function: nvim 0.11+ has no on_new_config, so this is where
    -- the per-root --compile-commands-dir gets added.
    cmd = function(dispatchers, config)
        local cmd = { unpack(clangd_base_cmd) }
        local compile_commands_dir = find_compile_commands_dir(config.root_dir)
        if compile_commands_dir then
            table.insert(cmd, "--compile-commands-dir=" .. compile_commands_dir)
        end
        return vim.lsp.rpc.start(cmd, dispatchers, { cwd = config.cmd_cwd, env = config.cmd_env })
    end,
    on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
        on_attach(client, bufnr)
    end,
    on_init = on_init,
    capabilities = capabilities,
})
vim.lsp.enable("clangd")

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
vim.lsp.config("vhdl_ls", {
    cmd = { "/home/milad/dev/open-source/rust_hdl/target/release/vhdl_ls" },
    filetypes = { "vhdl" },
    root_markers = { "vhdl_ls.toml", ".git" },
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
})
vim.lsp.enable("vhdl_ls")

-- Only start servers for buffers that are real files on disk.
--
-- diffview.nvim names its index-side buffers "diffview://<repo>/.git/:0:/<path>"
-- with an empty 'buftype', so they get a filetype and vim.lsp.enable() tries to
-- start a server for them. vim.fs.root() cannot make sense of that name and
-- returns ".", which reaches the server as rootUri "file://." — vhdl_ls then
-- fails with "initializeParams.rootUri is not a valid file path". Same goes for
-- fugitive://, oil://, term:// and any other scheme-prefixed buffer name.
--
-- Wrap every server's root_markers in a root_dir function that bails out for
-- such buffers (never calling on_dir means: no client for this buffer).
local function real_file_root_dir(markers)
    return function(bufnr, on_dir)
        local name = vim.api.nvim_buf_get_name(bufnr)
        if name == "" or name:match("^%a[%w+.-]*://") or vim.bo[bufnr].buftype ~= "" then
            return
        end
        local root = vim.fs.root(bufnr, markers)
        if root then
            on_dir(root)
        end
    end
end

for _, name in ipairs(lspconfig.servers) do
    local markers = vim.lsp.config[name].root_markers
    if markers then
        vim.lsp.config(name, { root_dir = real_file_root_dir(markers) })
    end
end
