# None-ls (null-ls)

Configuration in `after/plugin/none-ls.lua`.

## Purpose

none-ls exists here for **one source only**: `editorconfig_checker`. It is the single tool in the old source list with no equivalent in conform (formatting) or nvim-lint (linting).

## Sources

| Source | Type | Filetype |
|---|---|---|
| `editorconfig_checker` | diagnostics | all |

With a *diagnostics* source and nothing else, none-ls no longer advertises formatting capability — so there is no contest with conform and no ambiguity about who answers `vim.lsp.buf.format()`.

## Executable guard

```lua
if vim.fn.executable("editorconfig-checker") == 0 then
  return
end
```

The binary does not ship with the plugin. Without this guard null-ls registers the source anyway and fails on **every file opened** with `command editorconfig-checker is not executable`.

```sh
brew install editorconfig-checker
```

## should_attach guard

None-ls skips attaching to:
- Buffers with a non-empty `buftype` (terminal, quickfix, etc.)
- Unnamed buffers
- Directory buffers

## Where the old sources went

Previously none-ls declared 8 sources. **None of the 8 binaries was present on this machine**, so the practical effect was attaching an LSP client to every buffer and registering nothing.

| Old source | Now |
|---|---|
| `golangci_lint` | nvim-lint — [linting](../languages/go.md#linting). Its hardcoded `--out-format=json` was removed in golangci-lint v2, so Go linting was dead |
| `prettier` | conform — [formatting.md](formatting.md) |
| `stylua` | conform |
| `sqlfmt` | conform |
| `goimports` | conform |
| `csharpier` | conform |
| `editorconfig_checker` | kept here |
| `clj_kondo` | removed with Clojure support |

## Usage

Diagnostics appear like any other LSP diagnostics and show up as a client named `null-ls`. Formatting is **not** done here — `<leader>f` goes to conform (see [formatting.md](formatting.md)).
