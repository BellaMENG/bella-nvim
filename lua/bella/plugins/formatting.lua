return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local conform = require("conform")

        conform.setup({
            formatters_by_ft = {
                javascript = { "biome" },
                typescript = { "biome" },
                javascriptreact = { "biome" },
                typescriptreact = { "biome" },
                svelte = { "biome" },
                css = { "biome" },
                html = { "biome" },
                json = { "biome" },
                yaml = { "biome" },
                markdown = { "biome" },
                graphql = { "biome" },
                liquid = { "biome" },
                lua = { "stylua" },
                python = { "isort", "black" },
            },
            format_on_save = {
                lsp_fallback = true,
                async = false,
                timeout_ms = 1000,
            },
            formatters = {
                biome = {
                    command = "biome",
                    args = {
                        "format",
                        "--fix",
                        "--stdin-file-path",
                        "$FILENAME",
                    },
                    cwd = require("conform.util").root_file({
                        "biome.json",
                        "package.json",
                    }),
                },
            },
        })

        vim.g.conform_log_level = "debug"
        vim.keymap.set({ "n", "v" }, "<leader>mp", function()
            conform.format({
                lsp_fallback = true,
                async = false,
                timeout_ms = 1000,
            })
        end, { desc = "Format file or range (in visual mode)" })
    end,
}
