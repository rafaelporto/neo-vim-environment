# Swift / iOS

Configuration in `after/plugin/swift-config.lua` (sourcekit + xcodebuild keymaps), `after/plugin/dap-swift.lua`, `after/plugin/formatting.lua` (swiftformat), `after/plugin/linting.lua` (swiftlint) and the `xcodebuild.nvim` spec in `lua/default/plugins.lua`.

## LSP

`sourcekit` — not installed through Mason; requires Xcode. Everything about *how* it starts comes from the `lsp/sourcekit.lua` bundled with `nvim-lspconfig`: `cmd = { "sourcekit-lsp" }`, the Swift/ObjC filetypes, a `root_dir` that understands `buildServer.json`, `.bsp`, `*.xcodeproj`, `*.xcworkspace`, `Package.swift` and `.git`, plus extra capabilities. `swift-config.lua` adds only `capabilities` and `on_attach` on top.

> **`swift-config.lua` no longer sets `cmd`.** It used to be `cmd = { vim.trim(vim.fn.system("xcrun -f sourcekit-lsp")) }` — an `xcrun` subprocess spawned in *every* session, Go and TypeScript included, purely to resolve one path. Measured at 16.97 ms of the file's 17.3 ms total; the file now costs 0.29 ms. Dropping it is also more correct: the `sourcekit-lsp` shim on `PATH` respects `xcode-select`, so the toolchain is resolved when the server starts instead of being frozen at nvim startup. Verified: sourcekit still attaches, with `cmd = { "sourcekit-lsp" }` and the root resolved from `Package.swift`.

Enabled with `vim.lsp.enable("sourcekit")`. All standard LSP keymaps apply (see [lsp-core.md](../plugins/lsp-core.md)); buffer diagnostics go to the loclist with `<leader>ad`, not `<leader>d`.

## Formatting

`swiftformat` via conform.nvim — runs automatically on save for `swift` files, and with `<leader>f`. Timeout 1000ms, `lsp_format = "fallback"` (sourcekit formats if `swiftformat` is missing).

> `conform.setup()` used to live in this file with a **global** `format_on_save`, while `<leader>f` called `vim.lsp.buf.format` — so Swift was actually formatted by sourcekit, never by swiftformat. Formatting now has a single owner, `after/plugin/formatting.lua`.

## Linting

`swiftlint` via nvim-lint, extracted into `after/plugin/linting.lua` — runs on `BufWritePost`, `BufReadPost`, `InsertLeave`. Skips `.swiftinterface` files.

| Key | Action |
|---|---|
| `<leader>ml` | Run linter manually |

> **Missing linters are skipped, not attempted.** nvim-lint does not check availability before spawning, so with `swiftlint` absent — which it is on this machine — *every* Swift buffer opened with `Error in BufReadPost Autocommands: Error running swiftlint: ENOENT`. `linting.lua` now passes `opts.filter` to `lint.try_lint`, nvim-lint's own hook, which hands over the already-resolved linter, and checks `vim.fn.executable` on its `cmd`.
>
> Two subtleties in that filter: `lint.linters[name]` may be a table **or a function returning one**, and `.cmd` may itself be a function — so the filter resolves both before testing. Swift buffers now open clean; install swiftlint (`brew install swiftlint`) and the diagnostics appear with no config change.

> `<leader>ml` notifies instead of doing nothing when the current filetype has no linter configured.

## Xcodebuild

Integration via `xcodebuild.nvim`. On first use, the plugin prompts for scheme and device — the selection is saved per project.

> **All 19 keymaps below are buffer-local** (registered in sourcekit's `on_attach`). They used to be global by accident: the file built an `opts` table with `buffer = bufnr` and never used it, so one sourcekit attach was enough to define them in every buffer. Related fix: `chmod +x` moved from `<leader>x` to `<leader>cx`, so the `<leader>x` prefix no longer waits out `timeoutlen`.

> **The plugin spec carries `ft = { "swift", "objc", "objcpp" }`.** It used to be eager, dragging in telescope and nui and running `setup()` in every session — 11.04 ms measured, in Go, TypeScript or Dart, for a plugin that only works on Xcode projects. The consequence to know about: **the `:Xcodebuild*` commands now exist only in Swift/ObjC buffers.** That is consistent with how they were already reachable, since the 19 keymaps were already buffer-local to the same filetypes. Verified: xcodebuild is not loaded in a Go session; opening a `.swift` file loads it, `:XcodebuildBuild` exists, all 19 keymaps attach (18 normal + 1 visual) and the DAP adapter is registered.

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

That call is made from a `FileType` autocmd with `once = true` on `swift` / `objc` / `objcpp`, not at file level. Safe to defer: the adapter only has to exist before a debug session starts, which by definition happens after a Swift buffer is open.

> The dapui itself is lazy too — nothing debug-related loads until you press one of the keys below. See [dap-core.md](../plugins/dap-core.md).

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
