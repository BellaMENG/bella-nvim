return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local conform = require("conform")
        local util = require("conform.util")

        local biome_bin = util.find_executable({
            "node_modules/.bin/biome",
        }, "biome") or "biome"

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
                yaml = { "prettier" },
                markdown = { "prettier" },
                graphql = { "prettier" },
                liquid = { "prettier" },
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
                lsp_fallback = true,
                async = false,
                timeout_ms = 1000,
            })
        end, { desc = "Format file or range (in visual mode)" })
    end,
}
