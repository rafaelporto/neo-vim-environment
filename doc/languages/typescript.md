# TypeScript / JavaScript

## LSP

| Server | Installed via | Purpose |
|---|---|---|
| `ts_ls` | Mason (auto) | TypeScript/JavaScript language server |
| `eslint` | Mason (auto) | ESLint diagnostics as LSP |

Both servers use capabilities only — no custom `on_attach`. All standard LSP keymaps from `lsp.lua` apply (see [lsp-core.md](../plugins/lsp-core.md)).

## Formatting

`prettier` via none-ls runs on `.js`, `.ts`, `.jsx`, `.tsx`, `.json`, `.yaml`, `.html`, `.css`, `.md`, and more.

Format with `<leader>f`.

## Linting

ESLint diagnostics come through the `eslint` LSP server directly (not none-ls).

## Debugging

No DAP adapter is configured. To add JavaScript/TypeScript debugging:
1. `:MasonInstall js-debug-adapter`
2. Add `dap.adapters["pwa-node"]` and `dap.configurations.javascript` / `typescript` in a new `after/plugin/dap-js.lua`
