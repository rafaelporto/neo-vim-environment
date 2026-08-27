# DAP Core

Lazy initialisation in `lua/default/dap.lua`; UI layout and global keymaps in `after/plugin/debugging.lua`. Adapters live one file per language.

## Stack

- **nvim-dap** — Debug Adapter Protocol client
- **nvim-dap-ui** — debug panels (scopes, call stack, breakpoints, watches, console, REPL)
- **nvim-dap-virtual-text** — inline variable values next to the current line
- **nvim-nio** — async runtime both of the above depend on

## Lazy initialisation — `lua/default/dap.lua`

**Nothing DAP-related is in `package.loaded` at startup.** The whole stack comes up on the first `F5` / `F9` / `<leader>Du`, or on the first `<leader>tD` from neotest.

Before, all four files under `after/plugin/` — `debugging.lua` plus the three `dap-*.lua` — called `require("dap")` at file level, so the debugger was loaded in every session just to read code. Deferring only one of them would have achieved nothing: any of the remaining three still pulled the stack in. That is why the deferral lives in a single shared module rather than in each file.

The module is a registry plus one entry point:

| API | Purpose |
|---|---|
| `register(fn)` | A language file hands over a function. It is stored, **not** run. |
| `ensure()` | Loads the stack, `setup()`s nvim-dap-virtual-text and dapui with `ui_opts`, installs the dapui open/close listeners, loads the telescope `dap` extension, then calls every registered function with the loaded `dap` module. Returns `dap`. Idempotent — a second call does not re-run the registrations or duplicate configurations. |
| `ui()` | `ensure()` followed by `require("dapui")`. |
| `ui_opts` | The dapui layout, assigned by `debugging.lua` and read when `ensure()` runs. |

So each per-language file is now shaped like this, and its body never runs in a session where you do not debug:

```lua
require("default.dap").register(function(dap)
    dap.adapters.<name> = { ... }
    dap.configurations.<filetype> = { ... }
end)
```

Two callers outside `debugging.lua` matter:

- **`after/plugin/telescope.lua` no longer calls `load_extension("dap")`.** That extension pulls in telescope-dap, which does `require("dap")` — a single line in a startup file was enough to load the entire debugger. It now loads inside `ensure()`. See [telescope.md](telescope.md).
- **neotest's `<leader>tD` calls `ensure()` first.** neotest brings up nvim-dap by itself for `strategy = "dap"`, but the listeners that open and close the dapui live here — without the call the test would be debugged with no UI. See [neotest.md](neotest.md).

## UI Layout

**Left panel** (40 columns):
- Scopes (25%)
- Breakpoints
- Stacks
- Watches

**Bottom panel** (25% of height):
- REPL
- Console

The UI opens automatically when a session starts (`attach` or `launch`) and closes on `terminated` or `exited`. The layout is declared as `lazydap.ui_opts` in `debugging.lua` and handed to `dapui.setup()` when the stack initialises.

## Global Keymaps

| Key | Action |
|---|---|
| `F9` | Toggle breakpoint |
| `F5` | Continue / start session |
| `F10` | Step over |
| `F11` | Step into |
| `Shift+F11` | Step out |
| `Shift+F5` | Stop session |
| `<leader>Du` | Toggle DAP UI |
| `<leader>Dc` | Close DAP UI |

All of them route through a helper that calls `ensure()` before touching `dap`, so any one of them is a valid entry point into the stack.

> **`<leader>Du` / `<leader>Dc`, not `<leader>du` / `<leader>duc`.** `<leader>d` is the delete-without-yank **operator** (`remap.lua`). While a `<leader>du` existed, every `<leader>dw` / `<leader>dip` / `<leader>d}` paid `timeoutlen` waiting to see whether a `u` followed. The capital matches the `<leader>F` (Flutter) and `<leader>X` (xcodebuild) convention. See [keymaps.md](keymaps.md).

## Language-specific adapters

One file per language — `debugging.lua` holds only the dapui layout and the global keymaps.

| Language | File | Adapter | Install |
|---|---|---|---|
| Go | `after/plugin/dap-go.lua` | `go` (delve) | `:MasonInstall delve` |
| JS / TS | `after/plugin/dap-js.lua` | `pwa-node`, `pwa-chrome` (js-debug-adapter) | `:MasonInstall js-debug-adapter` |
| C# | `after/plugin/dap-dotnet.lua` | `coreclr` **and** `netcoredbg` (netcoredbg) | none — the arm64 binary ships inside `netcoredbg-macOS-arm64.nvim`. Do **not** `:MasonInstall netcoredbg` |
| Swift / iOS | `after/plugin/dap-swift.lua` | wired by xcodebuild.nvim, from a `FileType` autocmd | none — Xcode 16+ needs no `codelldb` |
| Dart / Flutter | `lua/default/plugins.lua` (flutter-tools spec) | `flutter debug_adapter` | none — bundled with the SDK |

> **Why C# does not use Mason's netcoredbg:** the package serves
> `netcoredbg-osx-amd64.tar.gz` to the `darwin_arm64` target, and a x64 debugger cannot
> attach to an arm64 process — netcoredbg goes through `dbgshim`/`ICorDebug`, which requires
> matching architectures. `Cliffback/netcoredbg-macOS-arm64.nvim` ships an arm64 build
> committed in its own repo, so the lazy clone *is* the install. Its `setup()` registers both
> adapter names, and `netcoredbg` is the one neotest-dotnet asks for. `dap-dotnet.lua` calls
> that `setup()` before overwriting `dap.configurations.cs`, because the plugin defines a
> `configurations.cs` of its own and the last writer wins.

> There is **no** `after/plugin/flutter.lua`. Flutter's config is inline in the `akinsho/flutter-tools.nvim` spec in `lua/default/plugins.lua`, deliberately: `ft = { "dart" }` keeps the plugin, its ~25 commands and its DAP wiring out of every non-Dart session, which an `after/plugin/` file would undo by running at startup.

> `after/plugin/dap-swift.lua` only calls `require("xcodebuild.integrations.dap").setup()`, and it does so from a `FileType` autocmd with `once = true` on `swift` / `objc` / `objcpp` rather than at file level. It does not use `codelldb`.
>
> Requiring it eagerly loaded the whole of xcodebuild.nvim in every session — Go, TypeScript and Dart included — 11.04 ms to register an adapter only Swift can use. Safe to defer: the adapter only has to exist before a debug session starts, which by definition happens after a Swift buffer is open. Note that this file is **not** what loads xcodebuild for the keymaps; the plugin spec carries `ft = { "swift", "objc", "objcpp" }` of its own. See [swift.md](../languages/swift.md).

See the corresponding language doc for debug workflows.

## Go — `after/plugin/dap-go.lua`

`dlv` resolves from Mason's `bin` directory, falling back to `PATH`.

> **The adapter is named `go`, not `delve`.** nvim-dap resolves an adapter by a configuration's `type`, and `go` is the name `neotest-golang` expects in its `dap_manual_config` (see [neotest.md](neotest.md)) — so one name serves both.

| Configuration | Request | Description |
|---|---|---|
| `Debug arquivo atual` | `launch` | `program = ${file}` |
| `Debug pacote` | `launch` | `program = ./${relativeFileDirname}` |
| `Debug testes do pacote` | `launch`, `mode = test` | all tests in the current package |
| `Attach a processo` | `attach`, `mode = local` | process picker |

Debugging a *single* test comes from neotest (`<leader>tD`), so there is no per-test configuration here.

## JavaScript / TypeScript — `after/plugin/dap-js.lua`

Adapter names follow vscode-js-debug: `pwa-node` and `pwa-chrome`, both run as `type = "server"` on `${port}`.

The file returns early and silently if `js-debug-adapter` is not in Mason's `bin` — no startup warning for a tool you may not want.

The same 5 configurations are registered for `javascript`, `typescript`, `javascriptreact` and `typescriptreact`:

| Configuration | Adapter | Request | Notes |
|---|---|---|---|
| `Launch arquivo atual` | `pwa-node` | `launch` | `program = ${file}`; Node's native type stripping runs `.ts` directly, so there is no `ts-node`/`tsx` config |
| `Launch npm script` | `pwa-node` | `launch` | Prompts for the script name (defaults to `dev`) in an `integratedTerminal` |
| `Attach a processo` | `pwa-node` | `attach` | Process picker |
| `Launch Chrome em localhost` | `pwa-chrome` | `launch` | Prompts for a URL (defaults to `http://localhost:3000`) |
| `Attach ao Chrome` | `pwa-chrome` | `attach` | Port `9222` — start Chrome with `--remote-debugging-port=9222` |

`runtimeArgs` and `url` are **functions**, so the prompt fires on `F5` and not at startup. All node configs set `sourceMaps = true` and skip `<node_internals>` and `node_modules`.

Test debugging comes from neotest (`<leader>tD`), so there is no jest/vitest configuration here.
