# Dart / Flutter

Configuration in `after/plugin/flutter.lua`.

## Setup

[flutter-tools.nvim](https://github.com/akinsho/flutter-tools.nvim) manages the entire Flutter/Dart stack: LSP, commands, and DAP. Lazy-loaded on `ft = dart`.

> **SDK path:** hardcoded to `~/sdk-flutter`. If you move the SDK, update `flutter_path` in `after/plugin/flutter.lua`.
> **No Mason install needed** — `dartls` is bundled with the Flutter SDK.

## LSP

`dartls` is configured through flutter-tools' `lsp` block — not via `vim.lsp.config`. All standard LSP keymaps apply (see [lsp-core.md](../plugins/lsp-core.md)).

### LSP settings

| Setting | Value |
|---|---|
| `showTodos` | `true` |
| `completeFunctionCalls` | `true` |
| `renameFilesWithClasses` | `"prompt"` |
| `enableSnippets` | `true` |
| `updateImportsOnRename` | `true` |
| Color previews | virtual text `■` |

## Formatting

`dart_format` via conform.nvim — runs `dart format` on save for `dart` files.

## Flutter Commands (keymaps active in Dart buffers)

| Key | Action |
|---|---|
| `<leader>FR` | Flutter Run |
| `<leader>Fr` | Hot Reload |
| `<leader>FH` | Hot Restart |
| `<leader>Fq` | Flutter Quit |
| `<leader>Fd` | Select Device |
| `<leader>Fe` | Select Emulator |
| `<leader>FD` | Open DevTools |
| `<leader>Fo` | Toggle Widget Outline |
| `<leader>Fl` | Restart LSP |

## Debugging (DAP)

`run_via_dap = true` — the app is launched through the DAP protocol, so breakpoints work from the very first frame.

The debug adapter is `flutter debug_adapter`, bundled with the Flutter SDK — no extra install needed.

**Workflow:**
1. `<leader>FR` — Flutter Run (via DAP)
2. `F9` — set breakpoints before or after launch
3. `F5` — continue if paused at startup

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

## Dev Log

The Flutter device log opens in a new tab (`tabedit`) when the app is running.
