# Lua

Configuration in `after/plugin/lsp.lua` (lua_ls block).

## LSP

`lua_ls` — auto-installed via Mason.

### Neovim-aware workspace

The `on_init` callback inspects the workspace root. If it is inside `stdpath("config")` (nvim config) or `stdpath("data")` (lazy.nvim plugins), it injects the Neovim runtime paths into the workspace:

| Library | Purpose |
|---|---|
| `$VIMRUNTIME` | Core Neovim Lua API |
| `${3rd}/luv/library` | libuv bindings |
| `stdpath("data")/lazy/nvim-dap-ui` | Completion inside DAP UI config files |

This means `vim.*` APIs autocomplete and have type information only when editing files inside the Neovim config or data directories.

### Settings

- `diagnostics.globals = { "vim" }` — suppresses "undefined global `vim`" warnings

## Formatting

`stylua` via none-ls — runs with `<leader>f`. Requires `stylua` in PATH or installed via Mason (`:MasonInstall stylua`).

## All standard LSP keymaps apply

See [lsp-core.md](../plugins/lsp-core.md).
