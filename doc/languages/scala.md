# Scala

Configuration in `after/plugin/nvim-metals.lua`.

## LSP

[nvim-metals](https://github.com/scalameta/nvim-metals) manages the Metals language server. It does **not** use `vim.lsp.config` or mason-lspconfig — it has its own initialization mechanism.

Metals attaches via a `FileType scala,sbt` autocmd that calls `require("metals").initialize_or_attach(metals_config)`.

### Settings

| Setting | Value |
|---|---|
| `showImplicitArguments` | `true` |
| `statusBarProvider` | `"on"` (shown in lualine_y) |
| `excludedPackages` | akka typed javadsl, swagger akka javadsl |

## Keymaps (buffer-local, active in Scala files)

### LSP

| Key | Action |
|---|---|
| `gd` | Go to definition |
| `gi` | Go to implementation |
| `gr` | References |
| `K` | Hover documentation |
| `<C-h>` | Signature help |
| `<leader>vds` | Document symbols |
| `<leader>vws` | Workspace symbols |
| `<leader>ca` | Code actions (plain LSP — not actions-preview) |
| `<leader>rn` | Rename symbol |
| `<leader>ws` | Hover worksheet |

### Diagnostics

| Key | Action |
|---|---|
| `<leader>vd` | Diagnostic float |
| `>d` | Next diagnostic |
| `<d` | Previous diagnostic |
| `<leader>aa` | All diagnostics → quickfix |
| `<leader>ae` | Workspace errors → quickfix |
| `<leader>aw` | Workspace warnings → quickfix |
| `<leader>d` | Buffer diagnostics → loclist |

### DAP (Metals-native)

| Key | Action |
|---|---|
| `<leader>dc` | Continue |
| `<leader>dr` | Toggle REPL |
| `<leader>dK` | DAP hover widget |
| `<leader>dt` | Toggle breakpoint |
| `<leader>dso` | Step over |
| `<leader>dsi` | Step into |
| `<leader>dl` | Run last |

> These Metals DAP keymaps are separate from the global DAP keymaps (F5/F9/F10/F11) defined in `debugging.lua`. Both sets work in Scala buffers.

## DAP Configurations

| Name | Description |
|---|---|
| RunOrTest | Run or test the current file |
| Test Target | Run the test target |

`require("metals").setup_dap()` is called in `on_attach` to register the Metals DAP adapter automatically.
