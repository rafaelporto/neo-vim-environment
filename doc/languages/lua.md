# Lua

Configuration in `after/plugin/lsp.lua` (lua_ls block) and `after/plugin/formatting.lua` (stylua).

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

### Inlay hints

`lua_ls` advertises `textDocument/inlayHint`, so the `LspAttach` handler enables hints and creates `<leader>lh` to toggle them. Note that lua-language-server only *emits* hints when `Lua.hint.enable = true`, which this config does not set — add it to the `settings.Lua` block if you want them.

## Formatting

`stylua` via conform.nvim (`after/plugin/formatting.lua`) — runs on save and with `<leader>f`, which calls `conform.format` (it used to call `vim.lsp.buf.format`). Requires `stylua` in PATH or installed via Mason (`:MasonInstall stylua`); otherwise `lsp_format = "fallback"` lets `lua_ls` format.

Config lives in `.stylua.toml` / `stylua.toml` at the project root.

## All standard LSP keymaps apply

See [lsp-core.md](../plugins/lsp-core.md). Buffer diagnostics go to the loclist with `<leader>ad` — `<leader>d` stayed the global delete-without-yank.
