# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration using lazy.nvim as the plugin manager. The configuration is organized under `lua/bella/` with a modular plugin architecture.

## Structure

```
init.lua                      # Entry point - loads core and lazy.nvim
lua/bella/
├── core/
│   ├── init.lua              # Loads options and keymaps
│   ├── options.lua           # Vim settings (tabs=4 spaces, relative numbers, etc.)
│   └── keymaps.lua           # Global keybindings (leader=Space)
├── lazy.lua                  # Plugin manager bootstrap
└── plugins/                  # Plugin configs (each file = one plugin spec)
    ├── lsp/
    │   ├── mason.lua         # LSP/tool installation
    │   └── lspconfig.lua     # LSP server configuration
    ├── formatting.lua        # Conform.nvim (biome, stylua, black)
    ├── linting.lua           # nvim-lint (eslint_d, pylint, swiftlint)
    └── ...                   # Other plugins
```

## Adding/Modifying Plugins

Each plugin is a separate file in `lua/bella/plugins/` that returns a lazy.nvim plugin spec table. Example:

```lua
return {
  "plugin/name",
  dependencies = { ... },
  config = function()
    -- setup code
  end,
}
```

LSP-related plugins go in `lua/bella/plugins/lsp/`.

## Key Keybinding Conventions

- **Leader**: Space
- **Pattern**: `<leader>` + 2-char mnemonic (e.g., `ff`=find files, `ee`=explorer, `sv`=split vertical)
- **LSP**: `gd`=definition, `gr`=references, `K`=hover, `<leader>ca`=code actions, `<leader>rn`=rename

## LSP Configuration

- **Mason** (`mason.lua`): Declares which LSP servers and tools to install
- **LSPConfig** (`lspconfig.lua`): Configures each server with capabilities and keybindings
- To add a new language server:
  1. Add server name to `ensure_installed` in `mason.lua`
  2. Add server config in `lspconfig.lua` (or it uses defaults)

## Formatting & Linting

- **Formatting**: Conform.nvim with format-on-save. Add formatters per filetype in `formatting.lua`
- **Linting**: nvim-lint with auto-lint on save/enter. Add linters per filetype in `linting.lua`
