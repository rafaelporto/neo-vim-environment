# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration targeting **nvim 0.11+**. It uses `lazy.nvim` for plugin management and the native LSP client API (`vim.lsp.config`).

## Load Order

```
init.lua → require("default")
           └── lua/default/init.lua
               ├── require("default.remap")   -- keybindings
               ├── require("default.set")     -- vim options
               └── require("default.lazy")    -- bootstrap lazy.nvim → load plugins.lua
```

After plugins load, Neovim's `after/plugin/` directory is sourced automatically. All plugin-specific configuration lives there.

## Key Architectural Decisions

**Plugin definitions vs plugin configuration are separated:**
- `lua/default/plugins.lua` — lazy.nvim specs (what to install, lazy-load conditions)
- `after/plugin/<name>.lua` — actual configuration for each plugin

**LSP uses nvim 0.11+ native API**, not the old nvim-lspconfig setup pattern. Use `vim.lsp.config["server_name"]` and `vim.lsp.enable()` instead of `require("lspconfig").server.setup()`.

**Mason** manages LSP server installation. Servers are listed in `mason-lspconfig` ensure list in `after/plugin/lsp.lua`.

**Time-based colorscheme switching** in `after/plugin/colors.lua`: before 8am or after 5pm → `dracula`, 8am–5pm → `tokyonight-day`. The `ColorMyPencils()` function handles this.

## Language Support

| Language | LSP | Extras |
|---|---|---|
| Clojure | clojure_lsp | conjure (REPL), vim-jack-in, nvim-paredit |
| Swift/iOS | sourcekit-lsp | xcodebuild.nvim, conform.nvim (swiftformat), nvim-lint (swiftlint) |
| Scala | nvim-metals | separate setup in `after/plugin/nvim-metals.lua` |
| C# | omnisharp | omnisharp-extended-lsp for telescope integration |
| TypeScript | ts_ls + eslint | — |
| Lua | lua_ls | workspace configured for nvim API |
| JSON/YAML | jsonls + yamlls | schemastore.nvim for schema validation |

## Leader Keys

- Leader: `<space>`
- Local leader: `,` (used in Clojure/conjure mappings)

## Adding a New Plugin

1. Add spec to `lua/default/plugins.lua`
2. Create `after/plugin/<name>.lua` for configuration
3. If it's an LSP server, add to `mason-lspconfig` ensure list in `after/plugin/lsp.lua` and configure with `vim.lsp.config["server_name"]`

## Filetype Associations

Custom filetype assignments live in `after/plugin/filetypes.lua` via autocmds. Clojure files (`.clj`, `.cljs`, `.edn`, `.edn.base`) and shell files (`.sh`, `.zsh`, zprofile) have custom assignments.

## Snippets

Custom snippets are in `snippets/swift.snippets` (UltiSnips format, loaded by LuaSnip).
