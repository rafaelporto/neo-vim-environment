# Swift / iOS

Configuration in `after/plugin/swift-config.lua` (sourcekit + xcodebuild keymaps), `after/plugin/dap-swift.lua`, `after/plugin/formatting.lua` (swiftformat) and `after/plugin/linting.lua` (swiftlint).

## LSP

`sourcekit` — located at runtime via `xcrun -f sourcekit-lsp`. Not installed through Mason; requires Xcode to be installed.

Enabled with `vim.lsp.enable("sourcekit")`. All standard LSP keymaps apply (see [lsp-core.md](../plugins/lsp-core.md)); buffer diagnostics go to the loclist with `<leader>ad`, not `<leader>d`.

## Formatting

`swiftformat` via conform.nvim — runs automatically on save for `swift` files, and with `<leader>f`. Timeout 1000ms, `lsp_format = "fallback"` (sourcekit formats if `swiftformat` is missing).

> `conform.setup()` used to live in this file with a **global** `format_on_save`, while `<leader>f` called `vim.lsp.buf.format` — so Swift was actually formatted by sourcekit, never by swiftformat. Formatting now has a single owner, `after/plugin/formatting.lua`.

## Linting

`swiftlint` via nvim-lint, extracted into `after/plugin/linting.lua` — runs on `BufWritePost`, `BufReadPost`, `InsertLeave`. Skips `.swiftinterface` files.

| Key | Action |
|---|---|
| `<leader>ml` | Run linter manually |

## Xcodebuild

Integration via `xcodebuild.nvim`. On first use, the plugin prompts for scheme and device — the selection is saved per project.

> **All 19 keymaps below are buffer-local** (registered in sourcekit's `on_attach`). They used to be global by accident: the file built an `opts` table with `buffer = bufnr` and never used it, so one sourcekit attach was enough to define them in every buffer. Related fix: `chmod +x` moved from `<leader>x` to `<leader>cx`, so the `<leader>x` prefix no longer waits out `timeoutlen`.

### Build & Run

| Key | Action |
|---|---|
| `<leader>X` | All Xcodebuild actions (picker) |
| `<leader>xf` | Project Manager |
| `<leader>xb` | Build |
| `<leader>xB` | Build for testing |
| `<leader>xr` | Build & Run on simulator/device |
| `<leader>xd` | Select device / simulator |
| `<leader>xp` | Select test plan |
| `<leader>xl` | Toggle build logs |
| `<leader>xq` | Quickfix list (Telescope) — Trouble's own toggle moved to `<leader>aq` |
| `<leader>xx` | Quickfix current line |
| `<leader>xa` | Code actions |

### Tests & Coverage

| Key | Action |
|---|---|
| `<leader>xt` | Run all tests |
| `<leader>xt` (visual) | Run selected tests |
| `<leader>xT` | Run tests in current class |
| `<leader>x.` | Repeat last test run |
| `<leader>xe` | Toggle Test Explorer |
| `<leader>xc` | Toggle code coverage |
| `<leader>xC` | Show code coverage report |
| `<leader>xs` | Show failing snapshots |

## Debugging (DAP)

`after/plugin/dap-swift.lua` just calls `require("xcodebuild.integrations.dap").setup()` — xcodebuild.nvim wires the adapter itself. On Xcode 16+ **`codelldb` is no longer required**.

**Workflow:**
1. `<leader>xr` — build and run the app on the simulator
2. `F9` — set a breakpoint in your code
3. `F5` — attach to the running process
4. DAP UI opens with scopes, call stack, breakpoints, and console

| Key | Action |
|---|---|
| `F9` | Toggle breakpoint |
| `F5` | Attach / continue |
| `F10` | Step over |
| `F11` | Step into |
| `Shift+F11` | Step out |
| `Shift+F5` | Stop session |
| `<leader>Du` | Toggle DAP UI |
| `<leader>Dc` | Close DAP UI |

## Treesitter

The `swift` parser comes from `nvim-treesitter` (branch `main`). Building it needs the tree-sitter CLI on the host:

```sh
brew install tree-sitter-cli
```

Highlighting and folds are started by `after/plugin/treesitter.lua`.
