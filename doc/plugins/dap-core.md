# DAP Core

Configuration in `after/plugin/debugging.lua`.

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

## Go Adapter (delve)

Configured in `debugging.lua`. Requires `dlv` in PATH.

| Configuration | Description |
|---|---|
| Debug | Launch current file |
| Debug test | Launch current file in test mode |
| Debug test (go.mod) | Launch test in relative directory |

## Language-specific adapters

Each language has its own adapter file:

| Language | File | Adapter |
|---|---|---|
| Swift/iOS | `after/plugin/dap-swift.lua` | codelldb (`:MasonInstall codelldb`) |
| C# | `after/plugin/dap-dotnet.lua` | netcoredbg (`:MasonInstall netcoredbg`) |
| Scala | `after/plugin/nvim-metals.lua` | metals DAP (built-in) |
| Dart/Flutter | `after/plugin/flutter.lua` | flutter debug_adapter (bundled with SDK) |
| Go | `after/plugin/debugging.lua` | delve (`dlv` in PATH) |

See the corresponding language doc for debug workflows.
