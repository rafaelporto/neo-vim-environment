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

> One server bypasses the wildcard: `dartls`, which flutter-tools starts with a direct `vim.lsp.start` call rather than through `vim.lsp.config`. It sets `capabilities` itself, in the `lsp = {…}` block in `plugins.lua` — so a change to the shared capabilities has to be mirrored there.

**Mason** manages LSP server installation. Servers are listed in `mason-lspconfig` ensure list in `after/plugin/lsp.lua`. Note `automatic_enable` there: mason-lspconfig enables every *installed* server, so `ts_ls` and `roslyn_ls` are explicitly excluded — `ts_ls` must never run alongside `vtsls`, and `roslyn_ls` must never run alongside the client roslyn.nvim already manages.

> **Exception — Roslyn (C#):** The Roslyn language server is **not** auto-installed, and
> `mason-org` has no package named `roslyn` — only `roslyn-language-server`, which lags the
> version VS Code ships and whose spec carries `neovim.lspconfig = roslyn_ls`. So
> `after/plugin/lsp.lua` declares a second registry, `github:Crashdummyy/mason-registry`,
> whose `roslyn` package is version-matched to vscode-csharp, has a native `darwin_arm64`
> asset, and exposes the bin name `roslyn-language-server` that the plugin looks for.
> Install it manually inside Neovim with `:MasonInstall roslyn`; it needs the dotnet SDK on
> `PATH`, because Roslyn loads the solution through that SDK's MSBuild.
>
> Do **not** switch to nvim-lspconfig's `roslyn_ls`: it is a different client, it does not
> support Razor, and running it alongside `seblyng/roslyn.nvim` means two Roslyn servers per
> buffer — which is what the `automatic_enable` exclusion above prevents.
>
> Diagnosing "nothing happens" is unusually hard here, so: `roslyn/utils.lua` never returns
> `nil`. With nothing installed it falls through to the literal string
> `"Microsoft.CodeAnalysis.LanguageServer"`, so `:checkhealth roslyn` reports *ok, found*
> and the real error surfaces as a spawn failure when a `.cs` buffer opens.

> **Exception — Flutter/Dart:** `dartls` is **not** installed via Mason; it ships with the Flutter SDK. The SDK is **discovered, not hardcoded** — see the Flutter section below.

**Formatting has exactly one owner: `after/plugin/formatting.lua`** (conform.nvim). Linting has exactly one owner: `after/plugin/linting.lua` (nvim-lint). Do not add a `format_on_save` hook or a `conform.setup()` call anywhere else — a previous version kept conform inside `swift-config.lua` with a global save hook while `<leader>f` pointed at `vim.lsp.buf.format`, and the net effect was that every explicitly configured formatter was bypassed.

**Time-based colorscheme switching** in `after/plugin/colors.lua`: before 8am or after 5pm → `dracula`, 8am–5pm → `tokyonight-day`. The `ColorMyPencils()` function handles this.

## Treesitter

nvim 0.12 provides the treesitter **API** but only **7 parsers** (`c`, `lua`, `markdown`, `markdown_inline`, `query`, `vim`, `vimdoc`). There is no `vim.treesitter.install` and no `:Treesitter` command, and none is planned for 0.13.

Parsers therefore come from `nvim-treesitter` on **`branch = "main"`**, where after its rewrite the plugin is *only* a parser installer and query provider — it does not do highlighting, and `ensure_installed` no longer exists. The parser list lives in the spec's `config` as `require("nvim-treesitter").install({...})`.

**`after/plugin/treesitter.lua` owns highlighting.** It guards on `vim.treesitter.highlighter.active[buf]` because `vim.treesitter.start()` builds a highlighter unconditionally and native ftplugins already start `lua`/`markdown`/`help`/`query`. It also sets treesitter folds, which is why `foldlevel`/`foldlevelstart` are 99 in `set.lua`.

- 34 distinct languages resolve after install, against the 7 nvim ships. That is 33 entries in the `install({...})` list plus `dtd`, which `xml` pulls in as a dependency and which therefore never appears in the list. (`nvim_get_runtime_file("parser/*.so")` reports more, because the 7 bundled ones are also in the install list and so appear twice.) Removing a language from the list does **not** uninstall its parser — `scala` kept resolving until `:TSUninstall scala`.
- Host prerequisite: `brew install tree-sitter-cli` (≥ 0.26.1). The `swift` parser needs it to generate.
- Commands: `:TSInstall`, `:TSUpdate`, `:TSUninstall`, `:TSLog`, and `:checkhealth nvim-treesitter`.
- To add a language, add it to the `install({...})` list and run `:TSUpdate`.
- `xml` is there for `.csproj`/`.slnx`/`.props`/`.targets` — nvim already maps those to the
  `xml` filetype, they just had no parser. `proto` is there because a gRPC-heavy C# project
  can hold as many `.proto` files as `.cs` ones, and without it they fall back to the legacy
  `syntax/proto.vim`.
- **Protobuf gets a parser and nothing else, deliberately.** `buf_ls`, the conform `buf`
  formatter and the `buf_lint`/`protolint` linters were all considered and left out: they
  need a `buf.yaml`, and a project that generates its stubs through MSBuild `<Protobuf
  Include=…/>` (Grpc.Tools) has none. The formatter would be dead code — `conform`'s `buf`
  declares `cwd = root_file({ "buf.yaml" })` and marks itself unavailable without it — and
  `buf_ls` would start via its `.git` fallback but resolve no imports, filling the buffer
  with "file not found" for code that builds fine. Revisit only if a project adopts buf.
- `razor` is available upstream but not installed: nothing here uses `.razor`/`.cshtml`. The
  Roslyn server does support Razor via co-hosting if that changes — add the parser and
  `razor` to the plugin's `ft`.

## Language Support

| Language | LSP | Extras |
|---|---|---|
| Go | gopls (gofumpt, staticcheck, analyses, inlay hints, codelenses) | conform (goimports + gofumpt), nvim-lint (golangci-lint), delve (`after/plugin/dap-go.lua`), neotest-golang |
| Swift/iOS | sourcekit-lsp | xcodebuild.nvim, conform (swiftformat), nvim-lint (swiftlint) |
| Dart/Flutter | dartls (via flutter-tools.nvim) | flutter-tools.nvim (hot reload, devices, emulators, outline), conform (dart_format), Dart DAP (bundled with SDK), neotest-dart |
| TypeScript/JS | vtsls + eslint | conform (prettier/biome from `node_modules`), js-debug-adapter (`after/plugin/dap-js.lua`), nvim-ts-autotag, neotest-vitest/jest |
| C# | roslyn (seblyng/roslyn.nvim) — **requires manual server install, from a second Mason registry** | Roslyn is the sole formatter (csharpier deliberately not installed), netcoredbg via `netcoredbg-macOS-arm64.nvim` (DAP), neotest-dotnet |
| Lua | lua_ls | workspace configured for nvim API, conform (stylua) |
| JSON/YAML | jsonls + yamlls | schemastore.nvim for schema validation |

### External tools

LSP servers come from Mason's `ensure_installed`. Everything else is installed manually, following the Roslyn precedent:

```vim
:MasonInstall gopls delve golangci-lint gofumpt goimports vtsls js-debug-adapter stylua
:MasonInstall roslyn                          " C#, needs the Crashdummyy registry
```

```sh
brew install tree-sitter-cli editorconfig-checker
brew install swiftformat swiftlint            # Swift, optional
go install gotest.tools/gotestsum@latest      # neotest-golang runner
npm i -D prettier                             # per project, never global
```

**The .NET SDK does not come from Homebrew.** The `dotnet@6` formula was disabled upstream
on 2025-11-12 and there is no `dotnet-sdk@6` cask, so older SDKs have to come from
Microsoft's installer or `dotnet-install.sh`. Install oldest-first so the final host/muxer
is the newest one, and point every SDK at the same root (`/usr/local/share/dotnet` on
macOS) — a second root would make `dotnet --list-sdks` show only one of them. Microsoft's
installer drops `/etc/paths.d/dotnet`, so `PATH` needs no shell config, but an already-open
terminal will not see it: **open a new shell before starting Neovim**, or Mason and Roslyn
inherit a `PATH` without `dotnet`.

Building a target framework older than the newest installed SDK works — the SDK pulls the
targeting pack from NuGet — but emits `NETSDK1138` (framework out of support) on every
build. That is a warning, not an error; pin with `global.json` only if the project wants it.

A missing formatter is not an error: conform marks it unavailable and either falls back to the language server or leaves the buffer alone (see below).

## Leader Keys

- Leader: `<space>`
- Local leader: `,` — currently unused. It belonged to conjure; kept in case another localleader plugin arrives.

### Namespaces

`<leader>a` diagnostics (`aa`/`ad`/`ae`/`aq`/`aw`) · `<leader>A` Harpoon add · `<leader>c` code actions + chmod · `<leader>d` delete-without-yank · `<leader>D` DAP UI · `<leader>e` neo-tree · `<leader>f` format · `<leader>F` Flutter · `<leader>g` git · `<leader>l` LSP toggles · `<leader>m` lint · `<leader>t` tests · `<leader>v` LSP symbols · `<leader>x` xcodebuild (buffer-local to Swift)

Before adding a keymap, grep for the key. `<leader>d` and `<leader>x` each had two owners at once, and in both cases the collision silently broke the older binding — `<leader>dd` was dead in every LSP buffer, and `<leader>xq` resolved to a command that does not exist.

**which-key.nvim shows the continuations** after a prefix, which is why `timeoutlen` is deliberately left at its default of 1000 — the problem was never the wait, it was not remembering the key. Do not lower it as an "optimization": a short window makes deliberately-typed sequences fail, and this config has 79 `<leader>` mappings in normal mode alone (100 counting every mode and buffer-local ones).

**Still a rough edge:** a key that is both a complete mapping *and* a prefix pays `timeoutlen` before firing. The frequent offenders were fixed (Harpoon add → `<leader>A`, DAP UI → `<leader>D*`), but these remain, all pre-existing: `n` (vs `ntd`), `p` (vs `ptd`), `<leader>s` (vs 21 telescope maps), `<leader>vd` (vs `<leader>vds`), `<leader>ne`, `<leader>st`. Listed so a future keymap is not added to an already-crowded prefix without noticing.

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

## What must not load at startup

The rule: a language's tooling loads only for files that use it. Verified by
`package.loaded` being empty for all of these on a bare `nvim`:

| Thing | How it stays out |
|---|---|
| nvim-dap, nvim-dap-ui, nvim-dap-virtual-text, nvim-nio | `lua/default/dap.lua` — a registry plus `ensure()`, triggered by the F-keys, `<leader>D*` or neotest's `<leader>tD` |
| xcodebuild.nvim | `ft = { "swift", "objc", "objcpp" }` on the spec; `dap-swift.lua` defers its setup into a `once` FileType autocmd |
| neotest and its five adapters | memoised helper in `after/plugin/neotest.lua`, triggered by the `<leader>t` maps |
| flutter-tools.nvim | `ft = { "dart" }`, config inline in the spec |
| which-key.nvim | `event = "VeryLazy"` |
| github-theme, catppuccin | `setup()` runs from a table keyed by colorscheme, only when selected |

**`lua/default/dap.lua` exists because deferring one file achieved nothing.** All
four DAP files used to `require("dap")` at the top, so any one of them dragged in
the whole stack. Language files now call `register(function(dap) ... end)` and the
body runs at first use. Two non-obvious members of that stack: `telescope.lua`
must **not** `load_extension("dap")` (it pulls telescope-dap and with it nvim-dap
into every startup — the extension loads inside `ensure()` instead), and
neotest's debug map has to call `ensure()` itself, or the session runs with no UI
because the dapui listeners were never registered.

**Never spawn a subprocess at startup.** `swift-config.lua` used to resolve
sourcekit with `vim.fn.system("xcrun -f sourcekit-lsp")`, costing 16.97 ms of its
17.3 ms in every session including Go ones. nvim-lspconfig already ships the
`cmd`, filetypes, `root_dir` and capabilities — deleting the line took the file to
0.29 ms and made it more correct, since the toolchain is now resolved when the
LSP starts rather than frozen at nvim startup.

Measured effect: `after/plugin/` self-time went from 55.9 ms to 27.1 ms, the
remainder being `lsp.lua` (mason) and `colors.lua` (lualine). End-to-end startup,
from an interleaved A/B of 10 stash/pop pairs, went from a median of 187.8 ms to
133.5 ms — distributions that do not overlap (slowest "after" run, 135.6 ms, still
beat the fastest "before" run, 169.2 ms).

If you re-measure, interleave the two states in one loop. Sequential
before-then-after comparisons on this machine drift with the page cache badly
enough to hide a 50 ms change, and per-file `--startuptime` self-times are the
stable signal.

**The roslyn.nvim exception is gone.** `after/plugin/roslyn.lua` used to call
`require("roslyn").setup()` at file level, which loaded the plugin in every session and
defeated its own `ft = { "cs" }`. The plugin options now live in `opts = {}` on the lazy
spec, and the file is purely declarative: `vim.lsp.config("roslyn", …)` registers a merge
layer without touching the module.

What made this safe to change is that `vim.lsp.enable()` ends with
`vim.cmd.doautoall('nvim.lsp.enable FileType')`, guarded by
`vim.v.vim_did_enter == 1 or vim.fn.did_filetype() == 1`. So when lazy loads the plugin on
`FileType` and the plugin's own `plugin/roslyn.lua` calls `vim.lsp.enable("roslyn")`, the
`.cs` buffer that triggered the load still gets the client attached. If that ever regresses,
the fallback is an explicit `vim.lsp.enable("roslyn")` in `lsp.lua` — at the cost of loading
the plugin at startup again.

## Formatting and linting

`after/plugin/formatting.lua` is the only place conform is configured, and it holds the single `BufWritePre` hook. That hook runs `:LspEslintFixAll` first when an eslint client is attached, then `conform.format` — one autocmd, explicit order, because two separate autocmds would leave ordering to registration order and let the formatter win over eslint's rewrites.

- `prettier` and `biome` resolve from the project's `node_modules/.bin`, so nothing is installed globally. Both carry `require_cwd = true`: with no config in the project they are marked unavailable rather than run with their own defaults.
- The **web filetypes carry `lsp_format = "never"`**. Without it the global `lsp_format = "fallback"` sends the buffer to vtsls, which reformats with tsserver defaults and defeats `require_cwd`. Swift, C#, Dart and Go keep the fallback, where the language server is a legitimate formatter.
- Go formats with `goimports` then `gofumpt`.
- **C# is formatted by Roslyn, not by csharpier.** The `cs = { "csharpier" }` entry stays on
  purpose — with the binary absent conform marks it unavailable and `lsp_format = "fallback"`
  routes the buffer to Roslyn — so installing csharpier later needs no config change. It is
  deliberately *not* installed: unlike prettier and biome it carries no `require_cwd`, so in a
  project without `.csharpierrc` it would reformat to its own defaults and produce a large
  diff in code that follows another style. Roslyn instead gets
  `["csharp|formatting"] = { dotnet_organize_imports_on_format = true }` in
  `after/plugin/roslyn.lua`, which is the `goimports` equivalent for C#.

`after/plugin/linting.lua` covers `swift` (swiftlint) and `go` (golangcilint). Deliberately no eslint entry — the eslint LSP already provides diagnostics and adding it would double every warning.

`after/plugin/none-ls.lua` survives for **one** source, `editorconfig_checker`, behind an `executable()` guard. Everything else moved to conform or nvim-lint. Do not add formatters back to none-ls; with only a diagnostics source it no longer claims formatting capability, which is what keeps it from competing with conform.

## Adding a New Plugin

1. Add spec to `lua/default/plugins.lua`
2. Create `after/plugin/<name>.lua` for configuration
3. If it's an LSP server, add to `mason-lspconfig` ensure list in `after/plugin/lsp.lua` and configure with `vim.lsp.config["server_name"]`
4. If it needs a keymap, grep for the key first (see Namespaces above)

## Filetype Associations

Custom filetype assignments live in `after/plugin/filetypes.lua` via autocmds: JSON files (`.json`, `.jsonc`, `.json.base`) and shell files (`.sh`, `.zsh`, `.tmux`, zprofile). Treesitter language aliases (`jsonc`/`json5` → `json`, `zsh` → `bash`) are registered separately in `after/plugin/treesitter.lua`.

Before adding an autocmd here, check `$VIMRUNTIME/lua/vim/filetype.lua` — nvim 0.12 already
maps far more than it looks. `.csproj`/`.slnx`/`.csproj.user` → `xml`, `.sln` → `solution`,
`.razor`/`.cshtml` → `razor`, `.proto` → `proto` all come from the runtime, so the .NET work
needed parsers, not filetype rules. (`solution` has no treesitter parser upstream, so `.sln`
stays unhighlighted.)

## Snippets

Custom snippets are in `snippets/swift.snippets` (UltiSnips format, loaded by LuaSnip).
