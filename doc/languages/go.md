# Go

Configuration in `after/plugin/lsp.lua` (gopls), `after/plugin/none-ls.lua` (golangci-lint + goimports), and `after/plugin/debugging.lua` (delve).

## LSP

`gopls` — configured with capabilities only. **Not** in the Mason `ensure_installed` list, so it will not be auto-installed. Install manually:

```vim
:MasonInstall gopls
```

Or ensure `gopls` is in your PATH from a manual `go install golang.org/x/tools/gopls@latest`.

All standard LSP keymaps apply (see [lsp-core.md](../plugins/lsp-core.md)).

## Formatting

`goimports` via none-ls — handles both import organization and formatting. Runs with `<leader>f`.

## Linting

`golangci-lint` via none-ls — runs with `--out-format=json` on the current file. Requires `golangci-lint` in PATH.

## Debugging (DAP)

Uses [delve](https://github.com/go-delve/delve). Requires `dlv` in PATH:

```sh
go install github.com/go-delve/delve/cmd/dlv@latest
```

### DAP Configurations

| Name | Mode | Description |
|---|---|---|
| Debug | launch | Debug current file |
| Debug test | test | Debug test file |
| Debug test (go.mod) | test | Debug test in `./relativeFileDirname` |

### DAP keymaps (global)

| Key | Action |
|---|---|
| `F9` | Toggle breakpoint |
| `F5` | Continue / start |
| `F10` | Step over |
| `F11` | Step into |
| `Shift+F11` | Step out |
| `Shift+F5` | Stop session |
| `<leader>du` | Toggle DAP UI |
| `<leader>duc` | Close DAP UI |
