return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local conform = require("conform")
        local util = require("conform.util")

        local biome_bin = util.find_executable({
            "node_modules/.bin/biome",
        }, "biome") or "biome"
        local repo_aware_filetypes = {
            javascript = true,
            typescript = true,
            javascriptreact = true,
            typescriptreact = true,
            svelte = true,
            css = true,
            html = true,
            json = true,
            yaml = true,
            markdown = true,
            graphql = true,
            liquid = true,
        }

        local function should_use_lsp_fallback(bufnr)
            local filetype = vim.bo[bufnr].filetype
            if not repo_aware_filetypes[filetype] then
                return "fallback"
            end

            local configured_formatters = conform.formatters_by_ft[filetype] or {}
            for _, formatter in ipairs(configured_formatters) do
                if conform.get_formatter_info(formatter, bufnr).available then
                    return "never"
                end
            end

            return "fallback"
        end

        conform.setup({
            formatters_by_ft = {
                javascript = { "oxfmt", "biome", "prettier", stop_after_first = true },
                typescript = { "oxfmt", "biome", "prettier", stop_after_first = true },
                javascriptreact = { "oxfmt", "biome", "prettier", stop_after_first = true },
                typescriptreact = { "oxfmt", "biome", "prettier", stop_after_first = true },
                svelte = { "oxfmt", "biome", "prettier", stop_after_first = true },
                css = { "oxfmt", "biome", "prettier", stop_after_first = true },
                html = { "oxfmt", "biome", "prettier", stop_after_first = true },
                json = { "oxfmt", "biome", "prettier", stop_after_first = true },
                yaml = { "oxfmt", "biome", "prettier", stop_after_first = true },
                markdown = { "oxfmt", "biome", "prettier", stop_after_first = true },
                graphql = { "oxfmt", "biome", "prettier", stop_after_first = true },
                liquid = { "oxfmt", "biome", "prettier", stop_after_first = true },
                lua = { "stylua" },
                python = { "isort", "black" },
            },

            format_on_save = function(bufnr)
                return {
                    lsp_format = should_use_lsp_fallback(bufnr),
                    async = false,
                    timeout_ms = 1000,
                }
            end,

            formatters = {
                biome = {
                    command = biome_bin,
                    args = {
                        "format",
                        "--fix",
                        "--stdin-file-path",
                        "$FILENAME",
                    },
                    cwd = util.root_file({
                        "biome.json",
                        "package.json",
                    }) or vim.loop.cwd(),
                },
            },
        })

        vim.keymap.set({ "n", "v" }, "<leader>mp", function()
            conform.format({
                lsp_format = should_use_lsp_fallback(vim.api.nvim_get_current_buf()),
                async = false,
                timeout_ms = 1000,
            })
        end, { desc = "Format file or range (in visual mode)" })
    end,
}
