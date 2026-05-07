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

**LSP uses nvim 0.11+ native API**, not the old nvim-lspconfig setup pattern. Use `vim.lsp.config["server_name"]` and `vim.lsp.enable()` instead of `require("lspconfig").server.setup()`. For server-specific config options, available servers, and filetype/root detection rules, refer to the [nvim-lspconfig documentation](https://github.com/neovim/nvim-lspconfig).

**Mason** manages LSP server installation. Servers are listed in `mason-lspconfig` ensure list in `after/plugin/lsp.lua`.

> **Exception — Roslyn (C#):** The Roslyn language server is **not** auto-installed. Install it manually inside Neovim with `:MasonInstall roslyn`. The `seblj/roslyn.nvim` plugin manages the LSP lifecycle but expects the binary to already exist in Mason's bin directory. See: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#roslyn_ls

> **Exception — Flutter/Dart:** `dartls` is **not** installed via Mason. It is bundled with the Flutter SDK at `~/sdk-flutter`. The `akinsho/flutter-tools.nvim` plugin manages both LSP and debug adapter lifecycle. If you move the SDK, update the path in `after/plugin/flutter.lua`.

**Time-based colorscheme switching** in `after/plugin/colors.lua`: before 8am or after 5pm → `dracula`, 8am–5pm → `tokyonight-day`. The `ColorMyPencils()` function handles this.

## Language Support

| Language | LSP | Extras |
|---|---|---|
| Clojure | clojure_lsp | conjure (REPL), vim-jack-in, nvim-paredit |
| Swift/iOS | sourcekit-lsp | xcodebuild.nvim, conform.nvim (swiftformat), nvim-lint (swiftlint) |
| Dart/Flutter | dartls (via flutter-tools.nvim) | flutter-tools.nvim (hot reload, devices, emulators, outline), conform.nvim (dart_format), Dart DAP (bundled with SDK) |
| Scala | nvim-metals | separate setup in `after/plugin/nvim-metals.lua` |
| C# | roslyn (seblj/roslyn.nvim) — **requires manual server install** | csharpier (none-ls), netcoredbg (DAP) |
| TypeScript | ts_ls + eslint | — |
| Lua | lua_ls | workspace configured for nvim API |
| JSON/YAML | jsonls + yamlls | schemastore.nvim for schema validation |

## Leader Keys

- Leader: `<space>`
- Local leader: `,` (used in Clojure/conjure mappings)

### Flutter keymaps (`<leader>F` prefix, active on Dart buffers)

| Key | Action |
|---|---|
| `<leader>FR` | Flutter Run |
| `<leader>Fr` | Hot Reload |
| `<leader>FH` | Hot Restart |
| `<leader>Fq` | Flutter Quit |
| `<leader>Fd` | Select Device |
| `<leader>Fe` | Select Emulator |
| `<leader>FD` | Open DevTools |
| `<leader>Fo` | Toggle Widget Outline |
| `<leader>Fl` | Restart LSP |

**Debugging Flutter:** use standard DAP keymaps — `F5` (continue/start), `F9` (toggle breakpoint), `F10` (step over), `F11` (step into), `<S-F11>` (step out), `<S-F5>` (stop). The debug adapter (`flutter debug_adapter`) is bundled with the Flutter SDK — no extra install needed. Set `run_via_dap = true` in `after/plugin/flutter.lua` to launch apps through DAP (enables breakpoints from the start).

## Adding a New Plugin

1. Add spec to `lua/default/plugins.lua`
2. Create `after/plugin/<name>.lua` for configuration
3. If it's an LSP server, add to `mason-lspconfig` ensure list in `after/plugin/lsp.lua` and configure with `vim.lsp.config["server_name"]`

## Filetype Associations

Custom filetype assignments live in `after/plugin/filetypes.lua` via autocmds. Clojure files (`.clj`, `.cljs`, `.edn`, `.edn.base`) and shell files (`.sh`, `.zsh`, zprofile) have custom assignments.

## Snippets

Custom snippets are in `snippets/swift.snippets` (UltiSnips format, loaded by LuaSnip).
