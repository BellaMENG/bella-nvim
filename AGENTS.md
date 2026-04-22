# AGENTS.md

This repository contains a Neovim configuration built on `lazy.nvim` under the `bella` namespace.

## Overview

- Entry point: `init.lua`
- Core modules live in `lua/bella/core/`
- Plugin specs live in `lua/bella/plugins/`
- LSP-specific specs live in `lua/bella/plugins/lsp/`
- Lazy.nvim bootstrap and plugin discovery live in `lua/bella/lazy.lua`

Each plugin file returns a lazy.nvim spec table. Lazy.nvim auto-discovers files in `bella.plugins` and `bella.plugins.lsp`.

## Architecture

- `init.lua` loads `bella.core`, then `bella.lazy`
- `lua/bella/core/options.lua` owns editor options
- `lua/bella/core/keymaps.lua` owns global keymaps
- `lua/bella/plugins/` contains one file per plugin
- `lua/bella/plugins/lsp/mason.lua` installs tools and language servers
- `lua/bella/plugins/lsp/lspconfig.lua` configures LSP clients

## Key Configuration Details

- Leader key: `Space`
- LSP servers configured explicitly: `sourcekit`, `ts_ls`, `eslint`, `lua_ls`, `html`, `cssls`, `tailwindcss`, `svelte`, `graphql`, `emmet_ls`, `prismals`, `pyright`
- Mason installs: `ts_ls`, `html`, `cssls`, `tailwindcss`, `svelte`, `lua_ls`, `graphql`, `emmet_ls`, `prismals`, `pyright`
- Formatting uses `conform.nvim`
- JS/TS and related filetypes pick the first formatter with repo config in this order: `oxfmt`, `biome`, `prettier`; without repo config they fall back to `oxfmt`, `biome`, `prettier`
- Lua formatting uses `stylua`
- Python formatting uses `isort` and `black`
- Linting uses `eslint_d` for JS/TS-family files and `pylint` for Python

## Keymap Conventions

- `<leader>e*` for file explorer actions
- `<leader>f*` for Telescope and finder actions
- `<leader>s*` for splits and substitute actions
- `<leader>t*` for tab actions
- `<leader>h*` for git hunk actions
- `<leader>w*` for workspace and session actions
- `<leader>x*` for trouble and diagnostics
- `g*` without leader for LSP navigation

All custom keymaps should include `desc` fields for discoverability.

## Working Rules

- Add new plugins as new files under `lua/bella/plugins/`
- Add new Mason-managed servers in `lua/bella/plugins/lsp/mason.lua`
- Add custom LSP behavior in `lua/bella/plugins/lsp/lspconfig.lua`
- Keep formatting decisions inside `lua/bella/plugins/formatting.lua`
- Prefer updating the relevant plugin spec instead of adding ad hoc logic elsewhere

## Style

- Lua formatting is handled by `stylua`
- Editor indentation defaults to 4 spaces
- Keep plugin specs small and focused
- Prefer explicit plugin configuration over implicit side effects
