# DAP Core

Shared configuration in `after/plugin/debugging.lua`. Adapters live one file per language.

## Stack

- **nvim-dap** — Debug Adapter Protocol client
- **nvim-dap-ui** — debug panels (scopes, call stack, breakpoints, watches, console, REPL)
- **nvim-dap-virtual-text** — inline variable values next to the current line

## UI Layout

**Left panel** (40 columns):
- Scopes (25%)
- Breakpoints
- Stacks
- Watches

**Bottom panel** (25% of height):
- REPL
- Console

The UI opens automatically when a session starts (`attach` or `launch`) and closes on `terminated` or `exited`.

## Global Keymaps

| Key | Action |
|---|---|
| `F9` | Toggle breakpoint |
| `F5` | Continue / start session |
| `F10` | Step over |
| `F11` | Step into |
| `Shift+F11` | Step out |
| `Shift+F5` | Stop session |
| `<leader>du` | Toggle DAP UI |
| `<leader>duc` | Close DAP UI |

## Language-specific adapters

One file per language — `debugging.lua` holds only the UI and the global keymaps.

| Language | File | Adapter | Install |
|---|---|---|---|
| Go | `after/plugin/dap-go.lua` | `go` (delve) | `:MasonInstall delve` |
| JS / TS | `after/plugin/dap-js.lua` | `pwa-node`, `pwa-chrome` (js-debug-adapter) | `:MasonInstall js-debug-adapter` |
| C# | `after/plugin/dap-dotnet.lua` | `coreclr` (netcoredbg) | `:MasonInstall netcoredbg` |
| Swift / iOS | `after/plugin/dap-swift.lua` | wired by xcodebuild.nvim | none — Xcode 16+ needs no `codelldb` |
| Scala | `after/plugin/nvim-metals.lua` | metals DAP (built-in) | none |
| Dart / Flutter | `lua/default/plugins.lua` (flutter-tools spec) | `flutter debug_adapter` | none — bundled with the SDK |

> There is **no** `after/plugin/flutter.lua`. Flutter's config is inline in the `akinsho/flutter-tools.nvim` spec in `lua/default/plugins.lua`, deliberately: `ft = { "dart" }` keeps the plugin, its ~25 commands and its DAP wiring out of every non-Dart session, which an `after/plugin/` file would undo by running at startup.

> `after/plugin/dap-swift.lua` only calls `require("xcodebuild.integrations.dap").setup()`. It does not use `codelldb`.

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
