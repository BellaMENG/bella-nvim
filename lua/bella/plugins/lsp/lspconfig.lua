return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        { "hrsh7th/cmp-nvim-lsp", commit = "39e2eda76828d88b773cc27a3f61d2ad851b4263" }, -- Pin to stable version
        { "antosha417/nvim-lsp-file-operations", config = true },
        { "folke/neodev.nvim", opts = {} },
    },
    config = function()
        -- import lspconfig plugin
        local lspconfig = require("lspconfig")

        -- import mason_lspconfig plugin
        local mason_lspconfig = require("mason-lspconfig")

        -- import cmp-nvim-lsp plugin
        local cmp_nvim_lsp = require("cmp_nvim_lsp")

        local keymap = vim.keymap -- for conciseness

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", { clear = true }),
            callback = function(ev)
                -- Ensure ev.buf is a valid buffer number
                if not ev.buf or type(ev.buf) ~= "number" or not vim.api.nvim_buf_is_valid(ev.buf) then
                    return
                end

                -- Buffer local mappings.
                local opts = { buffer = ev.buf, silent = true }

                -- set keybinds
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

        -- Get default capabilities and ensure they are properly configured
        local capabilities = cmp_nvim_lsp.default_capabilities()

        -- Change the Diagnostic symbols in the sign column (gutter)
        local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

        -- Setup handlers for Mason-installed servers
        mason_lspconfig.setup_handlers({
            -- default handler for installed servers
            function(server_name)
                -- Don't setup sourcekit here since we handle it above
                if server_name == "sourcekit" then
                    return
                end

                lspconfig[server_name].setup({
                    capabilities = capabilities,
                })
            end,

            -- Configure TypeScript server
            ["ts_ls"] = function()
                lspconfig.ts_ls.setup({
                    capabilities = capabilities,
                })
            end,

            -- Configure Lua server (with special settings)
            ["lua_ls"] = function()
                lspconfig.lua_ls.setup({
                    capabilities = capabilities,
                    settings = {
                        Lua = {
                            -- make the language server recognize "vim" global
                            diagnostics = {
                                globals = { "vim" },
                            },
                            completion = {
                                callSnippet = "Replace",
                            },
                        },
                    },
                })
            end,
        })
    end,
}
