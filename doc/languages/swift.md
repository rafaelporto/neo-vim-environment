# Swift / iOS

Configuration in `after/plugin/swift-config.lua` and `after/plugin/dap-swift.lua`.

## LSP

`sourcekit` — located at runtime via `xcrun -f sourcekit-lsp`. Not installed through Mason; requires Xcode to be installed.

Enabled with `vim.lsp.enable("sourcekit")`. All standard LSP keymaps apply (see [lsp-core.md](../plugins/lsp-core.md)).

## Formatting

`swiftformat` via conform.nvim — runs automatically on save for `swift` files. Timeout: 500ms with LSP fallback.

## Linting

`swiftlint` via nvim-lint — runs on `BufWritePost`, `BufReadPost`, `InsertLeave`. Skips `.swiftinterface` files.

| Key | Action |
|---|---|
| `<leader>ml` | Run linter manually |

## Xcodebuild

Integration via `xcodebuild.nvim`. On first use, the plugin prompts for scheme and device — the selection is saved per project.

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
| `<leader>xq` | Quickfix list (Telescope) |
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

Uses `codelldb` with an attach workflow. Install once with `:MasonInstall codelldb`.

**Workflow:**
1. `<leader>xr` — build and run the app on the simulator
2. `F9` — set a breakpoint in your code
3. `F5` — codelldb attaches to the running process automatically
4. DAP UI opens with scopes, call stack, breakpoints, and console

| Key | Action |
|---|---|
| `F9` | Toggle breakpoint |
| `F5` | Attach / continue |
| `F10` | Step over |
| `F11` | Step into |
| `Shift+F11` | Step out |
| `Shift+F5` | Stop session |
| `<leader>du` | Toggle DAP UI |
| `<leader>duc` | Close DAP UI |
