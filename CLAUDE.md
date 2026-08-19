# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration targeting **nvim 0.12+**. It uses `lazy.nvim` for plugin management and the native LSP client API (`vim.lsp.config`). The primary language is **Go**; Swift/iOS, Flutter/Dart and JS/TS are also in active use.

## Load Order

```
init.lua → require("default")
           └── lua/default/init.lua
               ├── require("default.remap")   -- keybindings
               ├── require("default.set")     -- vim options
               └── require("default.lazy")    -- bootstrap lazy.nvim → load plugins.lua
```

After plugins load, Neovim's `after/plugin/` directory is sourced automatically. All plugin-specific configuration lives there.

> **`after/plugin/` is sourced alphabetically, and that has bitten this config twice.** A keymap set in a later file silently overwrites the same key from an earlier one. If you add a keymap that already exists elsewhere, check the load order before assuming yours wins.

## Key Architectural Decisions

**Plugin definitions vs plugin configuration are separated:**
- `lua/default/plugins.lua` — lazy.nvim specs (what to install, lazy-load conditions)
- `after/plugin/<name>.lua` — actual configuration for each plugin

**LSP uses the nvim native API**, not the old nvim-lspconfig setup pattern. Use `vim.lsp.config["server_name"]` and `vim.lsp.enable()` instead of `require("lspconfig").server.setup()`. For server-specific config options, available servers, and filetype/root detection rules, refer to the [nvim-lspconfig documentation](https://github.com/neovim/nvim-lspconfig).

`vim.lsp.config("*", { capabilities = capabilities })` in `after/plugin/lsp.lua` is merge layer 1 and applies to every server that goes **through** `vim.lsp.config` — including `sourcekit` and `roslyn`, which are configured in other files. Do not reintroduce a per-server capabilities loop; it has to be kept in lockstep with `vim.lsp.enable` and drifts.

> Two servers bypass the wildcard: `dartls` (flutter-tools calls `vim.lsp.start` directly) and Metals (nvim-metals builds its own config). Both set `capabilities` themselves — flutter-tools in the `lsp = {…}` block in `plugins.lua`, Metals in `nvim-metals.lua`. If you change the shared capabilities, update those two too.

**Mason** manages LSP server installation. Servers are listed in `mason-lspconfig` ensure list in `after/plugin/lsp.lua`. Note `automatic_enable` there: mason-lspconfig enables every *installed* server, so `ts_ls` is explicitly excluded — it must never run alongside `vtsls`.

> **Exception — Roslyn (C#):** The Roslyn language server is **not** auto-installed. Install it manually inside Neovim with `:MasonInstall roslyn`. The `seblj/roslyn.nvim` plugin manages the LSP lifecycle but expects the binary to already exist in Mason's bin directory. See: https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#roslyn_ls

> **Exception — Flutter/Dart:** `dartls` is **not** installed via Mason; it ships with the Flutter SDK. The SDK is **discovered, not hardcoded** — see the Flutter section below.

**Formatting has exactly one owner: `after/plugin/formatting.lua`** (conform.nvim). Linting has exactly one owner: `after/plugin/linting.lua` (nvim-lint). Do not add a `format_on_save` hook or a `conform.setup()` call anywhere else — a previous version kept conform inside `swift-config.lua` with a global save hook while `<leader>f` pointed at `vim.lsp.buf.format`, and the net effect was that every explicitly configured formatter was bypassed.

**Time-based colorscheme switching** in `after/plugin/colors.lua`: before 8am or after 5pm → `dracula`, 8am–5pm → `tokyonight-day`. The `ColorMyPencils()` function handles this.

## Treesitter

nvim 0.12 provides the treesitter **API** but only **7 parsers** (`c`, `lua`, `markdown`, `markdown_inline`, `query`, `vim`, `vimdoc`). There is no `vim.treesitter.install` and no `:Treesitter` command, and none is planned for 0.13.

Parsers therefore come from `nvim-treesitter` on **`branch = "main"`**, where after its rewrite the plugin is *only* a parser installer and query provider — it does not do highlighting, and `ensure_installed` no longer exists. The parser list lives in the spec's `config` as `require("nvim-treesitter").install({...})`.

**`after/plugin/treesitter.lua` owns highlighting.** It guards on `vim.treesitter.highlighter.active[buf]` because `vim.treesitter.start()` builds a highlighter unconditionally and native ftplugins already start `lua`/`markdown`/`help`/`query`. It also sets treesitter folds, which is why `foldlevel`/`foldlevelstart` are 99 in `set.lua`.

- 32 distinct languages resolve after install, against the 7 nvim ships. (`nvim_get_runtime_file("parser/*.so")` reports 39 because the 7 bundled ones are also in the install list and therefore present twice.)
- Host prerequisite: `brew install tree-sitter-cli` (≥ 0.26.1). The `swift` parser needs it to generate.
- Commands: `:TSInstall`, `:TSUpdate`, `:TSUninstall`, `:TSLog`, and `:checkhealth nvim-treesitter`.
- To add a language, add it to the `install({...})` list and run `:TSUpdate`.

## Language Support

| Language | LSP | Extras |
|---|---|---|
| Go | gopls (gofumpt, staticcheck, analyses, inlay hints, codelenses) | conform (goimports + gofumpt), nvim-lint (golangci-lint), delve (`after/plugin/dap-go.lua`), neotest-golang |
| Swift/iOS | sourcekit-lsp | xcodebuild.nvim, conform (swiftformat), nvim-lint (swiftlint) |
| Dart/Flutter | dartls (via flutter-tools.nvim) | flutter-tools.nvim (hot reload, devices, emulators, outline), conform (dart_format), Dart DAP (bundled with SDK), neotest-dart |
| TypeScript/JS | vtsls + eslint | conform (prettier/biome from `node_modules`), js-debug-adapter (`after/plugin/dap-js.lua`), nvim-ts-autotag, neotest-vitest/jest |
| Scala | nvim-metals | separate setup in `after/plugin/nvim-metals.lua` |
| C# | roslyn (seblj/roslyn.nvim) — **requires manual server install** | conform (csharpier, falls back to Roslyn), netcoredbg (DAP), neotest-dotnet |
| Lua | lua_ls | workspace configured for nvim API, conform (stylua) |
| JSON/YAML | jsonls + yamlls | schemastore.nvim for schema validation |

### External tools

LSP servers come from Mason's `ensure_installed`. Everything else is installed manually, following the Roslyn precedent:

```vim
:MasonInstall gopls delve golangci-lint gofumpt goimports vtsls js-debug-adapter stylua
```

```sh
brew install tree-sitter-cli editorconfig-checker
brew install swiftformat swiftlint            # Swift, optional
go install gotest.tools/gotestsum@latest      # neotest-golang runner
npm i -D prettier                             # per project, never global
```

A missing formatter is not an error: conform marks it unavailable and either falls back to the language server or leaves the buffer alone (see below).

## Leader Keys

- Leader: `<space>`
- Local leader: `,` — currently unused. It belonged to conjure; kept in case another localleader plugin arrives.

### Namespaces

`<leader>a` Harpoon add + diagnostics (`aa`/`ae`/`aw`/`ad`/`aq`) · `<leader>c` code actions + chmod · `<leader>d` delete-without-yank · `<leader>e` neo-tree · `<leader>f` format · `<leader>F` Flutter · `<leader>g` git · `<leader>l` LSP toggles · `<leader>m` lint · `<leader>t` tests · `<leader>v` LSP symbols · `<leader>x` xcodebuild (buffer-local to Swift)

Before adding a keymap, grep for the key. `<leader>d` and `<leader>x` each had two owners at once, and in both cases the collision silently broke the older binding — `<leader>dd` was dead in every LSP buffer, and `<leader>xq` resolved to a command that does not exist.

**Known rough edge:** these keys are both a complete mapping *and* a prefix, so each pays `timeoutlen` while Neovim waits to see whether a longer sequence follows: `<leader>a` (Harpoon add, competing with the five `<leader>a?` diagnostics maps), `<leader>d` (vs `<leader>du`), `<leader>s` (vs `<leader>sB`), `<leader>vd` (vs `<leader>vds`), `<leader>ne`, `<leader>st`, `<leader>du`. All pre-existing; listed so a future keymap is not added to an already-crowded prefix without noticing.

### Tests (`<leader>t`, all languages via neotest)

| Key | Action |
|---|---|
| `<leader>tt` | Run nearest test |
| `<leader>tf` | Run current file |
| `<leader>ta` | Run whole suite |
| `<leader>tD` | Debug nearest test |
| `<leader>tl` | Re-run last |
| `<leader>tS` | Stop |
| `<leader>ts` | Toggle summary |
| `<leader>to` | Open output |
| `<leader>tp` | Toggle output panel |
| `<leader>tw` | Toggle watch on file |
| `]n` / `[n` | Next / previous failure |

### Flutter keymaps (`<leader>F` prefix, active on Dart buffers)

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
| `<leader>Fp` | Pub Get |
| `<leader>FL` | Toggle Flutter Log |

## Flutter/Dart SDK discovery

The Flutter config is **inline in the lazy spec** in `lua/default/plugins.lua`, not in `after/plugin/`. This is deliberate: `ft = { "dart" }` is what keeps flutter-tools, its ~25 user commands and its DAP wiring out of every non-Dart session, and an `after/plugin/flutter.lua` would `require()` it at startup and undo that. (There is no `after/plugin/flutter.lua` — older docs referenced one that had been deleted.)

`find_flutter()` tries, in order: `exepath("flutter")` → a project-local `.fvm` → known paths (`~/fvm/default`, `~/development/flutter`, `~/flutter`, `~/sdk-flutter`). In the PATH case it returns an empty table **on purpose**, so flutter-tools runs its own search chain — setting `flutter_path` short-circuits that chain, which is exactly how the previous hardcoded `~/sdk-flutter` prevented discovery.

If no SDK is found, `setup()` is skipped and the plugin's own "Flutter executable could not be found…" message is the single notification.

**Debugging Flutter:** standard DAP keymaps — `F5` (continue/start), `F9` (toggle breakpoint), `F10` (step over), `F11` (step into), `<S-F11>` (step out), `<S-F5>` (stop). The debug adapter is bundled with the Flutter SDK. `debugger.enabled = true` alone routes `FlutterRun` through DAP; **`run_via_dap` no longer exists in flutter-tools** — do not add it back.

Two settings are deliberately absent from the Dart LSP config: `analysisExcludedFolders` (the plugin default already excludes `<sdk>/packages` and `<sdk>/.pub-cache`, and settings merge with `tbl_deep_extend("force")`, so declaring the key would delete both — use `analysis_options.yaml` instead), and `completeFunctionCalls`/`showTodos`/`updateImportsOnRename` (already plugin defaults).

## Formatting and linting

`after/plugin/formatting.lua` is the only place conform is configured, and it holds the single `BufWritePre` hook. That hook runs `:LspEslintFixAll` first when an eslint client is attached, then `conform.format` — one autocmd, explicit order, because two separate autocmds would leave ordering to registration order and let the formatter win over eslint's rewrites.

- `prettier` and `biome` resolve from the project's `node_modules/.bin`, so nothing is installed globally. Both carry `require_cwd = true`: with no config in the project they are marked unavailable rather than run with their own defaults.
- The **web filetypes carry `lsp_format = "never"`**. Without it the global `lsp_format = "fallback"` sends the buffer to vtsls, which reformats with tsserver defaults and defeats `require_cwd`. Swift, C#, Dart and Go keep the fallback, where the language server is a legitimate formatter.
- Go formats with `goimports` then `gofumpt`.

`after/plugin/linting.lua` covers `swift` (swiftlint) and `go` (golangcilint). Deliberately no eslint entry — the eslint LSP already provides diagnostics and adding it would double every warning.

`after/plugin/none-ls.lua` survives for **one** source, `editorconfig_checker`, behind an `executable()` guard. Everything else moved to conform or nvim-lint. Do not add formatters back to none-ls; with only a diagnostics source it no longer claims formatting capability, which is what keeps it from competing with conform.

## Adding a New Plugin

1. Add spec to `lua/default/plugins.lua`
2. Create `after/plugin/<name>.lua` for configuration
3. If it's an LSP server, add to `mason-lspconfig` ensure list in `after/plugin/lsp.lua` and configure with `vim.lsp.config["server_name"]`
4. If it needs a keymap, grep for the key first (see Namespaces above)

## Filetype Associations

Custom filetype assignments live in `after/plugin/filetypes.lua` via autocmds: JSON files (`.json`, `.jsonc`, `.json.base`) and shell files (`.sh`, `.zsh`, `.tmux`, zprofile). Treesitter language aliases (`jsonc`/`json5` → `json`, `zsh` → `bash`) are registered separately in `after/plugin/treesitter.lua`.

## Snippets

Custom snippets are in `snippets/swift.snippets` (UltiSnips format, loaded by LuaSnip).
