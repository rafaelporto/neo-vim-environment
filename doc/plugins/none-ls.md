# None-ls (null-ls)

Configuration in `after/plugin/none-ls.lua`.

## Purpose

Bridges external formatters and linters into the LSP client so they work with `vim.lsp.buf.format()` and produce diagnostics like any LSP server.

## Sources

| Source | Type | Filetype |
|---|---|---|
| `golangci_lint` | diagnostics | `go` |
| `clj_kondo` | diagnostics | `clojure` |
| `editorconfig_checker` | diagnostics | all |
| `prettier` | formatting | js, ts, json, yaml, html, css, markdown, and more |
| `stylua` | formatting | `lua` |
| `sqlfmt` | formatting | `sql` |
| `goimports` | formatting | `go` |
| `csharpier` | formatting | `cs` |

## should_attach guard

None-ls skips attaching to:
- Buffers with a non-empty `buftype` (terminal, quickfix, etc.)
- Unnamed buffers
- Directory buffers

## Usage

Format with `<leader>f` (calls `vim.lsp.buf.format`). None-ls sources appear as a virtual LSP client named `null-ls`.
