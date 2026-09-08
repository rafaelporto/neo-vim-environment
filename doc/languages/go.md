# Go

Configuration in `after/plugin/lsp.lua` (gopls), `after/plugin/formatting.lua` (formatters resolved from the repo), `after/plugin/linting.lua` (golangci-lint), `after/plugin/dap-go.lua` (delve) and `after/plugin/neotest.lua` (tests).

## Install

| Tool | How |
|---|---|
| `gopls` | Mason `ensure_installed` — auto-installed |
| `delve` | `:MasonInstall delve` |
| `golangci-lint` | `:MasonInstall golangci-lint` (or keep it in PATH) |
| `gofmt` | Ships with the Go SDK — nothing to install |
| `goimports` / `gofumpt` | `:MasonInstall goimports gofumpt` — used only in repositories with no `.golangci` |
| `gotestsum` | `go install gotest.tools/gotestsum@latest` — required by the neotest runner |

Mason prepends its `bin` directory to `PATH`, so anything installed there is found by conform and nvim-lint without extra configuration.

## LSP

`gopls` has a dedicated `vim.lsp.config["gopls"]` block. Before, it only received `capabilities` — no settings at all, which meant no staticcheck, no analyses, no inlay hints and no code lenses.

### Settings

| Setting | Value | Effect |
|---|---|---|
| `gofumpt` | `true` | gopls formats with gofumpt rules — reached only when conform has nothing to run (see [Formatting](#formatting)) |
| `staticcheck` | `true` | staticcheck diagnostics inside gopls |
| `usePlaceholders` | `true` | completion inserts parameter placeholders |
| `completeUnimported` | `true` | completes symbols from packages not yet imported |
| `semanticTokens` | `true` | semantic highlighting on top of treesitter |
| `directoryFilters` | `-.git`, `-node_modules`, `-vendor` | keeps those trees out of the workspace scan |

### Analyses

`unusedparams`, `unusedvariable`, `unusedwrite`, `shadow`, `nilness`, `useany`.

### Code lenses

`generate`, `test`, `tidy`, `upgrade_dependency`, `vendor`, `run_govulncheck`, `regenerate_cgo` (`gc_details` is off).

Code lenses are enabled on attach with `vim.lsp.codelens.enable()` and run with `<leader>lc` — the keymap is created by the `LspAttach` handler only for servers that advertise `textDocument/codeLens`. The provider refreshes itself through `nvim_buf_attach` (200 ms debounce); there is no refresh autocmd.

### Inlay hints

All seven gopls hint kinds are on: `assignVariableTypes`, `compositeLiteralFields`, `compositeLiteralTypes`, `constantValues`, `functionTypeParameters`, `parameterNames`, `rangeVariableTypes`.

Hints are enabled automatically when the buffer attaches; `<leader>lh` toggles them off and on.

All standard LSP keymaps apply (see [lsp-core.md](../plugins/lsp-core.md)). Note that buffer diagnostics go to the loclist with `<leader>ad` — not `<leader>d`, which is the global delete-without-yank.

## Formatting

**The repository decides, not this config.** `formatters_by_ft.go` in `after/plugin/formatting.lua` is a function, not a list. It walks up from the buffer for `.golangci.{yml,yaml,toml,json}` and resolves:

| What the repository has | Formatters | `lsp_format` |
|---|---|---|
| `.golangci` declaring formatters | exactly those, ordered `gci` → `goimports` → `gofmt` → `gofumpt` → `golines` | `never` |
| `.golangci` with no formatter declared | `gofmt` | `never` |
| no `.golangci` | `goimports` → `gofumpt` | `fallback` (the global default) |

Declared formatters are read from `formatters.enable` (golangci v2) or from formatter entries inside `linters.enable` (v1). The scan is a flat indentation walk over every `enable:` list in the file, filtered against the five names above — it never needs to know which block it is in. `disable:` lists are not read. Runs on save and with `<leader>f`; `:ConformInfo` shows what the current buffer resolved to.

The result is memoised per root (`vim.fs.root` on `go.mod` / `.git`), so editing a `.golangci` takes effect only in the next Neovim session.

### Why

gofumpt output is *gofmt-stable* — it is a strict superset, so running plain `gofmt` over a gofumpt-formatted file changes nothing. In a repository whose own standard is plain `gofmt`, that means the repo's formatter never undoes gofumpt: every line gofumpt rewrote, including lines you never touched, rides along into the commit. Same for `goimports` regrouping an import block that the repository keeps as one group.

`lsp_format = "never"` on the two declared branches is not decoration: gopls carries `gofumpt = true` (see [Settings](#settings)), so a `"fallback"` there would hand the buffer right back to gofumpt and undo the whole thing.

### Imports

`gofmt` does not touch the import block, so in a repository that resolves to it an unused import is no longer removed on save — and in Go that is a compile error, not a style nit. gopls flags it as a diagnostic either way, and `<leader>lo` runs the server's `source.organizeImports` on demand.

It is deliberately not wired into the save hook: organizing imports is precisely what regroups an import block that the repository keeps as one group, which is the drift this section exists to avoid.

## Linting

`golangci-lint` via nvim-lint (`after/plugin/linting.lua`), on `BufWritePost`, `BufReadPost` and `InsertLeave`, plus `<leader>ml` to run it manually.

> **Missing linters are skipped.** `linting.lua` passes an `opts.filter` to `lint.try_lint` that checks `vim.fn.executable` on each linter's resolved `cmd`, because nvim-lint spawns without checking — that is what made every Swift buffer error out on an absent `swiftlint` (see [swift.md](swift.md#linting)). Go is unaffected in practice: with `golangci-lint` installed the filter passes it through, and `unusedfunc` / `unusedparams` diagnostics arrive as before. Expect a pause on the first lint of a package — golangci-lint compiles it.

> This used to be a none-ls source with hardcoded `--out-format=json`, a flag removed in golangci-lint v2 — so it silently produced nothing. nvim-lint runs `golangci-lint version` and picks the flags per version (v1: `--out-format json`; v2.0.x: `--output.json.path=stdout`; v2.1+: same plus `--path-mode=abs`), passes `--issues-exit-code=0` so "found problems" is not treated as a tool failure, and resolves a standalone `.go` file through `go env GOMOD`. Verified working with v2.12.2.

## Debugging (DAP)

Configured in `after/plugin/dap-go.lua`, previously inside `debugging.lua`.

> The whole DAP stack is lazy: nothing debug-related loads until the first `F5` / `F9` / `<leader>Du` (or `<leader>tD` from neotest). The adapter and configurations below are *registered* through `require("default.dap").register(...)` and the body only runs when the stack initialises. See [dap-core.md](../plugins/dap-core.md).

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
