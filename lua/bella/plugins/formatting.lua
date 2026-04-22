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
        local oxfmt_root_markers = { ".oxfmtrc.json", ".oxfmtrc.jsonc" }
        local biome_root_markers = { "biome.json", "biome.jsonc" }
        local prettier_root_markers = {
            ".prettierrc",
            ".prettierrc.json",
            ".prettierrc.json5",
            ".prettierrc.yml",
            ".prettierrc.yaml",
            ".prettierrc.js",
            ".prettierrc.cjs",
            ".prettierrc.mjs",
            "prettier.config.js",
            "prettier.config.cjs",
            "prettier.config.mjs",
        }

        local function has_root_marker(bufnr, markers)
            return vim.fs.find(markers, {
                upward = true,
                path = vim.fs.dirname(vim.api.nvim_buf_get_name(bufnr)),
                type = "file",
            })[1] ~= nil
        end

        local function repo_aware_formatters(bufnr)
            if has_root_marker(bufnr, oxfmt_root_markers) then
                return { "oxfmt", "biome", "prettier", stop_after_first = true }
            end

            if has_root_marker(bufnr, biome_root_markers) then
                return { "biome", "prettier", "oxfmt", stop_after_first = true }
            end

            if has_root_marker(bufnr, prettier_root_markers) then
                return { "prettier", "biome", "oxfmt", stop_after_first = true }
            end

            return { "oxfmt", "biome", "prettier", stop_after_first = true }
        end

        local function should_use_lsp_fallback(bufnr)
            local filetype = vim.bo[bufnr].filetype
            if not repo_aware_filetypes[filetype] then
                return "fallback"
            end

            local configured_formatters = conform.list_formatters_for_buffer(bufnr)
            for _, formatter in ipairs(configured_formatters) do
                if conform.get_formatter_info(formatter, bufnr).available then
                    return "never"
                end
            end

            return "fallback"
        end

        conform.setup({
            formatters_by_ft = {
                javascript = repo_aware_formatters,
                typescript = repo_aware_formatters,
                javascriptreact = repo_aware_formatters,
                typescriptreact = repo_aware_formatters,
                svelte = repo_aware_formatters,
                css = repo_aware_formatters,
                html = repo_aware_formatters,
                json = repo_aware_formatters,
                yaml = repo_aware_formatters,
                markdown = repo_aware_formatters,
                graphql = repo_aware_formatters,
                liquid = repo_aware_formatters,
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
