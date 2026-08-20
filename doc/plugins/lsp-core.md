# LSP Core

Configuration in `after/plugin/lsp.lua`.

## Architecture

This config uses the **nvim 0.11+ native LSP API** — not the old `require("lspconfig").server.setup()` pattern. `nvim-lspconfig` is kept only for its bundled `lsp/<server>.lua` definitions (cmd, filetypes, root markers).

```lua
vim.lsp.config["server_name"] = { capabilities = ..., settings = ... }
vim.lsp.enable("server_name")
```

## Capabilities — one wildcard instead of a loop

```lua
vim.lsp.config("*", { capabilities = capabilities })
```

`capabilities` is `cmp_nvim_lsp.default_capabilities()` with `completionItem.snippetSupport = true`.

This is **merge layer 1**, so it applies to every server resolved through `vim.lsp.config` / `vim.lsp.enable` — including servers configured in *other* files, such as `sourcekit` (`swift-config.lua`) and `roslyn` (`roslyn.lua`). It replaces a per-server loop that had to be kept in sync by hand with the `vim.lsp.enable` list below.

> **One server bypasses it:** `dartls` is started by flutter-tools with a direct `vim.lsp.start()` call, so it sets `capabilities` itself — in the `lsp = { capabilities = ... }` block of the flutter-tools spec in `lua/default/plugins.lua`. `nvim-metals` used to be the second exception; Scala support has been removed.

## Mason

`mason-lspconfig` auto-installs and auto-enables servers on startup.

**`ensure_installed`:** `vtsls`, `eslint`, `gopls`, `lua_ls`, `yamlls`, `jsonls`, `dockerls`

```lua
automatic_enable = { exclude = { "ts_ls" } }
```

> **Why `ts_ls` is excluded:** `mason-lspconfig` auto-enables *every* installed server. `ts_ls` must never run alongside `vtsls` — duplicated diagnostics and double the memory. The exclusion is a guard in case the package gets reinstalled.

Servers not managed by Mason are configured the same way but must be reachable on their own: `sourcekit` (`sourcekit-lsp` on `PATH`, needs Xcode — see [swift.md](../languages/swift.md)), `dartls` (Flutter SDK, via flutter-tools), `roslyn` (manual `:MasonInstall roslyn`).

> **Known and deliberate:** `after/plugin/roslyn.lua` calls `require("roslyn").setup()` at file level, which defeats the `ft = { "cs" }` gate on the plugin's own spec — the plugin loads in every session. It measures ~1.2 ms in total, and neither `roslyn` nor `dotnet` is installed on this machine, so the fix could not be tested. Left alone on purpose; moving the `require` into a `FileType` autocmd (the way `after/plugin/dap-swift.lua` does it) is the obvious change once there is a C# project to verify against.

## Enabled servers

`vim.lsp.enable({ ... })`: `vtsls`, `eslint`, `gopls`, `cssls`, `marksman`, `dockerls`, `docker_compose_language_service`, `bashls`, `jsonls`, `yamlls`, `lua_ls`

> `cssls`, `marksman`, `docker_compose_language_service` and `bashls` are enabled but **not** in `ensure_installed` — enabling a server whose binary is absent is a silent no-op. Install them with `:MasonInstall` if you want them.

## Per-server settings

| Server | Notable settings |
|---|---|
| `gopls` | Full settings block: `gofumpt`, `staticcheck`, `usePlaceholders`, `completeUnimported`, `semanticTokens`, `directoryFilters`, 6 `analyses`, 7 `codelenses`, 7 `hints` — see [go.md](../languages/go.md) |
| `vtsls` | `autoUseWorkspaceTsdk`, `enableMoveToFileCodeAction`, server-side fuzzy match, inlay hints and import preferences for both `typescript` and `javascript` — see [typescript.md](../languages/typescript.md) |
| `eslint` | `format = false` — lint only |
| `jsonls` | `filetypes` extended with `jsonc`; schemas from `schemastore.nvim` |
| `yamlls` | Schemas from `schemastore.nvim` |
| `bashls` | `filetypes` extended with `zsh` |
| `lua_ls` | `on_init` injects the nvim runtime library paths only when the workspace is under `stdpath("config")` or `stdpath("data")` — replaces `neodev.nvim` |

> **Do not add an `on_attach` to `eslint`.** The `lsp/eslint.lua` from `nvim-lspconfig` supplies `workingDirectory = "auto"`, `workspace_required`, a `root_dir` that refuses to attach without an eslint config in the project, and an `on_attach` that creates the `:LspEslintFixAll` command. Overriding it destroys that command, which `after/plugin/formatting.lua` runs on save.

> **Why `format = false` for eslint:** formatting belongs to prettier/biome through conform. Leaving it `true` would let conform's LSP fallback elect eslint as the formatter.

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
| `<leader>ad` | n | Buffer diagnostics → loclist |
| `<leader>rl` | n | Restart LSP |
| `<leader>lu` | n | Toggle virtual lines |

> **`<leader>ad`, not `<leader>d`.** This map is buffer-local, so it used to win over the global delete-without-yank from `remap.lua:22` — breaking `<leader>dd` and `<leader>dw` in *every* buffer with an LSP attached (Go, TS, Swift, Dart, Lua). `<leader>a` is already the diagnostics namespace (`aa` / `ae` / `aw` / `aq`).

### Capability-gated keymaps

Both are registered inside `LspAttach` only when the attached client advertises the method, so they are absent rather than broken on servers that do not implement it.

| Key | Gate | Action |
|---|---|---|
| `<leader>lh` | `textDocument/inlayHint` | Toggle inlay hints for the buffer |
| `<leader>lc` | `textDocument/codeLens` | Run the code lens under the cursor |

- **Inlay hints** are enabled automatically on attach. `dartls` does not implement `textDocument/inlayHint`, so nothing is registered there — its equivalent is flutter-tools' closing labels.
- **Code lens** also installs a refresh autocmd on `BufEnter`, `InsertLeave` and `BufWritePost` for that buffer. `gopls` exposes `generate`, `tidy`, `test` and `run_govulncheck` here.
