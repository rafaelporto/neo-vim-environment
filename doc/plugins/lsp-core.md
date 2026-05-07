# LSP Core

Configuration in `after/plugin/lsp.lua`.

## Architecture

This config uses the **nvim 0.11+ native LSP API** — not the old `require("lspconfig").server.setup()` pattern. `nvim-lspconfig` is kept only for its bundled `lsp/<server>.lua` definitions (cmd, filetypes, root markers).

```lua
vim.lsp.config["server_name"] = { capabilities = ..., settings = ... }
vim.lsp.enable("server_name")
```

`mason-lspconfig` auto-installs servers on startup. Servers not managed by Mason (sourcekit, gopls, dartls) are configured the same way but must be available in PATH or via their respective plugins.

## Auto-installed servers (Mason)

`ts_ls`, `eslint`, `clojure_lsp`, `lua_ls`, `yamlls`, `jsonls`, `dockerls`

## Diagnostics

| Icon | Severity |
|---|---|
| `✘` | Error |
| `▲` | Warning |
| `⚑` | Hint |
| `»` | Info |

Virtual text is on by default. Toggle between inline virtual text and underline-style virtual lines with `<leader>lu`.

## Keymaps (active on all LSP-attached buffers)

| Key | Mode | Action |
|---|---|---|
| `gd` | n | Go to definition |
| `gi` | n | Go to implementation |
| `gr` | n | References |
| `K` | n | Hover documentation |
| `<C-h>` | i | Signature help |
| `<leader>vds` | n | Document symbols |
| `<leader>vws` | n | Workspace symbols |
| `<leader>rn` | n | Rename symbol |
| `<leader>ca` | n/v | Code actions (actions-preview UI) |
| `<leader>vd` | n | Diagnostic float |
| `>d` | n | Next diagnostic |
| `<d` | n | Previous diagnostic |
| `<leader>aa` | n | All diagnostics → quickfix |
| `<leader>ae` | n | Workspace errors → quickfix |
| `<leader>aw` | n | Workspace warnings → quickfix |
| `<leader>d` | n | Buffer diagnostics → loclist |
| `<leader>rl` | n | Restart LSP |
| `<leader>lu` | n | Toggle virtual lines |

> **Conflict note:** `<leader>d` is also set globally in `remap.lua` as "delete without clipboard" (visual + normal mode). The buffer-local LspAttach binding wins in LSP-attached buffers.
