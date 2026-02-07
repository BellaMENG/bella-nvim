return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        { "antosha417/nvim-lsp-file-operations", config = true },
        { "folke/lazydev.nvim", opts = {} },
    },
    config = function()
        local cmp_nvim_lsp = require("cmp_nvim_lsp")
        local keymap = vim.keymap

        -- Set default capabilities for all LSP servers
        vim.lsp.config("*", {
            capabilities = cmp_nvim_lsp.default_capabilities(),
        })

        -- LSP keybindings and per-server on_attach logic
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
            callback = function(ev)
                if not ev.buf or type(ev.buf) ~= "number" or not vim.api.nvim_buf_is_valid(ev.buf) then
                    return
                end

                local client = vim.lsp.get_client_by_id(ev.data.client_id)

                -- Disable formatting for ts_ls (use conform.nvim instead)
                if client and client.name == "ts_ls" then
                    client.server_capabilities.documentFormattingProvider = false
                end

                -- Enable omnifunc for sourcekit
                if client and client.name == "sourcekit" then
                    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"
                end

                local opts = { buffer = ev.buf, silent = true }

                opts.desc = "Show LSP references"
                keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
                opts.desc = "Go to declaration"
                keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
                opts.desc = "Show LSP definitions"
                keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
                opts.desc = "Show LSP implementations"
                keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
                opts.desc = "Show LSP type definitions"
                keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
                opts.desc = "See available code actions"
                keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
                opts.desc = "Smart rename"
                keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                opts.desc = "Show buffer diagnostics"
                keymap.set("n", "<leader>D", function()
                    local bufnr = vim.api.nvim_get_current_buf()
                    if vim.api.nvim_buf_is_valid(bufnr) then
                        require("telescope.builtin").diagnostics({ bufnr = bufnr })
                    end
                end, opts)
                opts.desc = "Show line diagnostics"
                keymap.set("n", "<leader>d", vim.diagnostic.open_float, opts)
                opts.desc = "Go to previous diagnostic"
                keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)
                opts.desc = "Go to next diagnostic"
                keymap.set("n", "]d", vim.diagnostic.goto_next, opts)
                opts.desc = "Show documentation for what is under cursor"
                keymap.set("n", "K", vim.lsp.buf.hover, opts)
                opts.desc = "Restart LSP"
                keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
            end,
        })

        -- Configure individual servers (overrides lspconfig defaults)
        vim.lsp.config("sourcekit", {
            cmd = { "sourcekit-lsp", "--scratch-path", ".nativeBuild" },
            root_dir = function(bufnr)
                local fname = vim.api.nvim_buf_get_name(bufnr)
                if string.match(fname, "Crossplatform") or string.match(fname, "CommonSwift") then
                    return "/Users/bellameng/GoodNotes-5/Crossplatform"
                end
                return vim.fs.root(bufnr, "Package.swift")
            end,
        })

        vim.lsp.config("eslint", {
            root_markers = { ".eslintrc", ".eslintrc.json", ".eslintrc.js", "package.json" },
        })

        -- Disable stylua LSP (stylua is a formatter, not an LSP server)
        vim.lsp.enable("stylua", false)

        vim.lsp.config("lua_ls", {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim" },
                    },
                    completion = {
                        callSnippet = "Replace",
                    },
                },
            },
        })

        -- Enable all servers
        vim.lsp.enable({
            "sourcekit",
            "ts_ls",
            "eslint",
            "lua_ls",
            "html",
            "cssls",
            "tailwindcss",
            "svelte",
            "graphql",
            "emmet_ls",
            "prismals",
            "pyright",
        })

        -- Diagnostic signs
        vim.diagnostic.config({
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = " ",
                    [vim.diagnostic.severity.WARN] = " ",
                    [vim.diagnostic.severity.HINT] = "󰠠 ",
                    [vim.diagnostic.severity.INFO] = " ",
                },
            },
        })
    end,
}
