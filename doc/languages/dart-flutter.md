# Dart / Flutter

Configuration lives **inline in the flutter-tools spec** in `lua/default/plugins.lua`. Formatting is in `after/plugin/formatting.lua`, tests in `after/plugin/neotest.lua`.

> There is no `after/plugin/flutter.lua`, on purpose. `ft = { "dart" }` keeps flutter-tools, its ~25 commands and the whole DAP wiring out of every non-Dart session; a file in `after/plugin/` would run at startup and `require()` the plugin unconditionally — the same class of problem `after/plugin/roslyn.lua` had, where a file-level `require("roslyn").setup()` defeated the plugin's own `ft = { "cs" }`.

## Setup

[flutter-tools.nvim](https://github.com/akinsho/flutter-tools.nvim) manages the entire Flutter/Dart stack: LSP, commands and DAP. Lazy-loaded on `ft = dart`.

> **No Mason install needed** — `dartls` and the debug adapter are bundled with the Flutter SDK.

### SDK discovery

The hardcoded `flutter_path = ~/sdk-flutter` is gone — it pointed at a directory that did not exist, and setting `flutter_path` short-circuits the plugin's own lookup chain (`config.fvm` → `config.flutter_path` → `flutter_lookup_cmd` → `exepath`) at the second position. A `find_flutter()` helper now resolves the SDK in this order:

| Order | Check | What is passed to `setup()` |
|---|---|---|
| 1 | `flutter` in `PATH` (homebrew cask, asdf/mise, manual install) | `{}` — flutter-tools resolves it itself |
| 2 | `.fvm` directory found upward from the cwd | `{ fvm = true }` |
| 3 | `~/fvm/default/bin/flutter` | `{ flutter_path = ... }` |
| 4 | `~/development/flutter/bin/flutter` | `{ flutter_path = ... }` |
| 5 | `~/flutter/bin/flutter` | `{ flutter_path = ... }` |
| 6 | `~/sdk-flutter/bin/flutter` | `{ flutter_path = ... }` |

If nothing is found, `setup()` is **not** called — handing over a non-existent `flutter_path` would only short-circuit the plugin's own search. There is no custom `vim.notify` either: flutter-tools' `ftplugin/dart` attaches to every `.dart` buffer anyway and its `get_server_config` already prints *"Flutter executable could not be found..."* with instructions. Two messages for one problem would be noise.

If your SDK lives somewhere else, add the path to the candidate list rather than pinning `flutter_path`.

## LSP

`dartls` is configured through flutter-tools' `lsp` block — not via `vim.lsp.config`. Capabilities come from `cmp_nvim_lsp`. All standard LSP keymaps apply (see [lsp-core.md](../plugins/lsp-core.md)); buffer diagnostics go to the loclist with `<leader>ad`.

### LSP settings (explicitly set)

| Setting | Value |
|---|---|
| `renameFilesWithClasses` | `"prompt"` |
| `enableSnippets` | `true` |
| `lineLength` | `100` |

`completeFunctionCalls`, `showTodos` and `updateImportsOnRename` are **already flutter-tools defaults** (`lsp/init.lua`) and were removed from this block as duplicates.

> **`analysisExcludedFolders` is deliberately not set.** The plugin default already excludes `<sdk>/packages` and `<sdk>/.pub-cache`, and the merge is `tbl_deep_extend("force")` — any list of ours would erase both. To exclude a generated folder, use `analysis_options.yaml` in the project.

### Inlay hints

Dart has none: `dartls` does not implement `textDocument/inlayHint`. The `LspAttach` handler is capability-gated, so it is simply a no-op here and `<leader>lh` is not created. The equivalent feature is flutter-tools' **closing labels**.

### UI options

| Option | Value | Note |
|---|---|---|
| `closing_tags.highlight` | `Comment` | was `ErrorMsg`, which made every closing tag look like a failure |
| `closing_tags.prefix` | `" // "` | |
| `widget_guides.enabled` | `false` | |

## Formatting

`dart_format` via conform.nvim (`after/plugin/formatting.lua`) — runs on save and with `<leader>f`. If the `dart` binary is not reachable, `lsp_format = "fallback"` lets `dartls` format, which produces the same output.

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
| `<leader>Fp` | Pub Get |
| `<leader>FL` | Toggle Flutter log window |
| `<leader>Fl` | Restart LSP |

All of them are buffer-local, registered in the `lsp.on_attach`.

## Debugging (DAP)

`debugger.enabled = true` is all that is needed — it routes `FlutterRun` through DAP, so breakpoints work from the first frame.

> **`run_via_dap` no longer exists in flutter-tools** (zero occurrences in the source). The option that used to be set here was dead code; drop it from any local notes.

Other debugger options: `exception_breakpoints = {}` and `evaluate_to_string_in_debug_views = true`.

The debug adapter is `flutter debug_adapter`, bundled with the Flutter SDK — no extra install needed. Dart is the one language whose adapter is *not* registered through `require("default.dap").register(...)`: flutter-tools wires nvim-dap itself when it loads on `ft = dart`.

> **The dapui panels come from `lua/default/dap.lua`, not from flutter-tools.** The listeners that open the UI on `launch`/`attach` and close it on `terminated`/`exited` are installed by `ensure()`. Because `FlutterRun` starts its own DAP session without going through that module, `<leader>FR` calls `ensure()` before issuing the command — otherwise the app would run under the debugger with no panels. `F5` / `F9` / `<leader>Du` / `<leader>tD` do the same. See [dap-core.md](../plugins/dap-core.md).

> Not verified on this machine: there is no Flutter SDK here, so `find_flutter()` returns nil, `setup()` is skipped and the `<leader>F*` keymaps are never registered. The `ensure()` call on `<leader>FR` is reasoned from flutter-tools' `runners/debugger_runner.lua`, which does its own `require("dap")` and sets `dap.adapters.dart`.

**Workflow:**
1. `<leader>FR` — Flutter Run (through DAP)
2. `F9` — set breakpoints, before or after launch
3. `F5` — continue if paused

The DAP keymaps are global and identical for every language — `F9`, `F5`, `F10`, `F11`,
step out, stop, `<leader>Du` / `<leader>Dc`. Single source:
[dap-core.md](../plugins/dap-core.md#global-keymaps).

## Testing

`neotest-dart` registered in `after/plugin/neotest.lua`:

| Option | Value | Note |
|---|---|---|
| `command` | `"flutter"` | change to `"fvm flutter"` when using FVM |
| `use_lsp` | `true` | uses the dartls outline for test names treesitter cannot parse (`testWidgets`, etc.) |

The `<leader>t` keymaps are the same for every language — nearest, file, suite, debug,
re-run, stop, summary, output, watch, and `]n` / `[n` between failures. Single source:
[neotest.md](../plugins/neotest.md#keymaps).

## Dev Log

The Flutter device log opens in a 15-line split at the bottom (`botright 15split`), which keeps the code visible — it used to be `tabedit`, stealing a tab on every run. Toggle it with `<leader>FL`.

## Treesitter

The `dart` parser is installed by `nvim-treesitter` (branch `main`) from the list in `lua/default/plugins.lua`; highlighting and folds come from `after/plugin/treesitter.lua`.
