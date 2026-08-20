# Go

Configuration in `after/plugin/lsp.lua` (gopls), `after/plugin/formatting.lua` (goimports + gofumpt), `after/plugin/linting.lua` (golangci-lint), `after/plugin/dap-go.lua` (delve) and `after/plugin/neotest.lua` (tests).

## Install

| Tool | How |
|---|---|
| `gopls` | Mason `ensure_installed` — auto-installed |
| `delve` | `:MasonInstall delve` |
| `golangci-lint` | `:MasonInstall golangci-lint` (or keep it in PATH) |
| `goimports` / `gofumpt` | `:MasonInstall goimports gofumpt` — optional, gopls formats as fallback |
| `gotestsum` | `go install gotest.tools/gotestsum@latest` — required by the neotest runner |

Mason prepends its `bin` directory to `PATH`, so anything installed there is found by conform and nvim-lint without extra configuration.

## LSP

`gopls` has a dedicated `vim.lsp.config["gopls"]` block. Before, it only received `capabilities` — no settings at all, which meant no staticcheck, no analyses, no inlay hints and no code lenses.

### Settings

| Setting | Value | Effect |
|---|---|---|
| `gofumpt` | `true` | gopls formats with gofumpt rules (also the formatting fallback) |
| `staticcheck` | `true` | staticcheck diagnostics inside gopls |
| `usePlaceholders` | `true` | completion inserts parameter placeholders |
| `completeUnimported` | `true` | completes symbols from packages not yet imported |
| `semanticTokens` | `true` | semantic highlighting on top of treesitter |
| `directoryFilters` | `-.git`, `-node_modules`, `-vendor` | keeps those trees out of the workspace scan |

### Analyses

`unusedparams`, `unusedvariable`, `unusedwrite`, `shadow`, `nilness`, `useany`.

### Code lenses

`generate`, `test`, `tidy`, `upgrade_dependency`, `vendor`, `run_govulncheck`, `regenerate_cgo` (`gc_details` is off).

Code lenses refresh on `BufEnter`, `InsertLeave` and `BufWritePost`, and run with `<leader>lc` — the keymap is created by the `LspAttach` handler only for servers that advertise `textDocument/codeLens`.

### Inlay hints

All seven gopls hint kinds are on: `assignVariableTypes`, `compositeLiteralFields`, `compositeLiteralTypes`, `constantValues`, `functionTypeParameters`, `parameterNames`, `rangeVariableTypes`.

Hints are enabled automatically when the buffer attaches; `<leader>lh` toggles them off and on.

All standard LSP keymaps apply (see [lsp-core.md](../plugins/lsp-core.md)). Note that buffer diagnostics go to the loclist with `<leader>ad` — not `<leader>d`, which is the global delete-without-yank.

## Formatting

`goimports` then `gofumpt` via conform.nvim (`after/plugin/formatting.lua`) — imports are organized first, layout second. Runs on save and with `<leader>f`.

If either binary is missing, `lsp_format = "fallback"` lets gopls format instead, which produces the same result because `gofumpt = true` is set above.

## Linting

`golangci-lint` via nvim-lint (`after/plugin/linting.lua`), on `BufWritePost`, `BufReadPost` and `InsertLeave`, plus `<leader>ml` to run it manually.

> This used to be a none-ls source with hardcoded `--out-format=json`, a flag removed in golangci-lint v2 — so it silently produced nothing. nvim-lint runs `golangci-lint version` and picks the flags per version (v1: `--out-format json`; v2.0.x: `--output.json.path=stdout`; v2.1+: same plus `--path-mode=abs`), passes `--issues-exit-code=0` so "found problems" is not treated as a tool failure, and resolves a standalone `.go` file through `go env GOMOD`. Verified working with v2.12.2.

## Debugging (DAP)

Configured in `after/plugin/dap-go.lua`, previously inside `debugging.lua`.

The adapter is registered as **`go`**, not `delve`: that is the name `neotest-golang` expects in its `dap_manual_config`, and it avoids maintaining two names for the same adapter. `dlv` resolves from Mason's `bin` directory, falling back to `PATH`.

### DAP Configurations

| Name | Request | Description |
|---|---|---|
| `Debug arquivo atual` | `launch` | `program = ${file}` |
| `Debug pacote` | `launch` | `program = ./${relativeFileDirname}` |
| `Debug testes do pacote` | `launch`, `mode = test` | all tests in the current package |
| `Attach a processo` | `attach`, `mode = local` | process picker |

Debugging a *single* test comes from neotest (`<leader>tD`), so there is no per-test configuration here.

### DAP keymaps (global)

| Key | Action |
|---|---|
| `F9` | Toggle breakpoint |
| `F5` | Continue / start |
| `F10` | Step over |
| `F11` | Step into |
| `Shift+F11` | Step out |
| `Shift+F5` | Stop session |
| `<leader>Du` | Toggle DAP UI |
| `<leader>Dc` | Close DAP UI |

## Testing

`neotest-golang` (pinned to releases, `version = "*"`) registered in `after/plugin/neotest.lua`.

| Option | Value | Why |
|---|---|---|
| `runner` | `"gotestsum"` | upstream recommendation — the plain `go` runner reads JSON from stdout and suffers truncation; gotestsum writes to a file |
| `go_test_args` | `-v`, `-race`, `-count=1` | verbose output, race detector, no test cache |
| `testify_enabled` | `true` | discovers testify suite methods |
| `dap_mode` | `"manual"` | see below |
| `dap_manual_config` | `type = "go"`, `mode = "test"` | reuses the adapter from `dap-go.lua` |

> **Why `dap_mode = "manual"`:** the default `"dap-go"` mode calls `require("dap-go").setup()` on *every* debug session, and dap-go appends to `dap.configurations.go` without clearing it first — the `F5` picker would grow by 7 entries per debug run. Manual mode points straight at the `go` adapter and removes the need for the `nvim-dap-go` plugin entirely.

> **Known false alarm:** `:checkhealth neotest-golang` reports two errors for `testify/namespace` and `testify/test_method` when `testify_enabled` is on. Its `health.lua` looks for `namespace.scm` and `test_method.scm`, files the plugin does not ship; the runtime actually loads `features/testify/queries/go/{testify_method,suite,package}.scm`, all present. Test discovery works with `testify_enabled` both true and false.

### Test keymaps

| Key | Action |
|---|---|
| `<leader>tt` | Run nearest test |
| `<leader>tf` | Run current file |
| `<leader>ta` | Run whole suite |
| `<leader>tD` | Debug nearest test (via DAP) |
| `<leader>tl` | Re-run last |
| `<leader>tS` | Stop run |
| `<leader>ts` | Toggle summary panel |
| `<leader>to` | Open output for the nearest test |
| `<leader>tp` | Toggle output panel |
| `<leader>tw` | Toggle watch mode for the file |
| `]n` / `[n` | Jump to next / previous failed test |

## Treesitter

The `go`, `gomod`, `gosum` and `gowork` parsers are installed by `nvim-treesitter` (branch `main`) from the list in `lua/default/plugins.lua`; highlighting and folds are started by `after/plugin/treesitter.lua`.
