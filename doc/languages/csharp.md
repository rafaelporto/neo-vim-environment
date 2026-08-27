# C# (.NET)

Configuration in `after/plugin/roslyn.lua` (LSP + server settings),
`after/plugin/dap-dotnet.lua` (debug), `after/plugin/lsp.lua` (Mason registries) and
`after/plugin/neotest.lua` (tests). Formatting is owned by Roslyn, not by conform — see
below.

## Prerequisites

The dotnet SDK must be on `PATH`: Roslyn loads the solution through that SDK's MSBuild, and
Mason needs it to install NuGet-based packages. Microsoft's installer drops
`/etc/paths.d/dotnet`, so no shell config is required — but an already-open terminal will
not see it. **Open a new shell before starting Neovim**, otherwise Neovim inherits a `PATH`
without `dotnet` and the failure looks like a broken plugin.

Multiple SDKs coexist under one root (`/usr/local/share/dotnet` on macOS). Install
oldest-first so the final host/muxer is the newest, and keep them in the same root or
`dotnet --list-sdks` will only show one. Homebrew is not a source for out-of-support SDKs:
the `dotnet@6` formula was disabled upstream on 2025-11-12 and there is no `dotnet-sdk@6`
cask.

## LSP

[seblyng/roslyn.nvim](https://github.com/seblyng/roslyn.nvim) manages the Roslyn language
server lifecycle. The plugin registers its base config in `lsp/roslyn.lua` and its own
`plugin/roslyn.lua` calls `vim.lsp.enable("roslyn")`.

> **Manual install required, from a second registry.** `mason-org` has no package named
> `roslyn` — only `roslyn-language-server`, which lags the version VS Code ships and whose
> spec carries `neovim.lspconfig = roslyn_ls`. `after/plugin/lsp.lua` therefore declares
> `github:Crashdummyy/mason-registry` alongside the default one; its `roslyn` package is
> version-matched to vscode-csharp, has a native `darwin_arm64` asset, and exposes the bin
> name `roslyn-language-server` that the plugin looks for. Run `:MasonInstall roslyn` once.

> **Do not enable nvim-lspconfig's `roslyn_ls`.** It is a different client and does not
> support Razor. Running it alongside this one means two Roslyn servers per buffer, which is
> why `roslyn_ls` sits in the `automatic_enable` exclude list next to `ts_ls`.

**Debugging a missing server is unusually hard**, so it is worth knowing:
`roslyn/utils.lua` never returns `nil`. With nothing installed it falls through to the
literal string `"Microsoft.CodeAnalysis.LanguageServer"`, so `:checkhealth roslyn` reports
*ok, found* and the real error only surfaces as a spawn failure when a `.cs` buffer opens.

### Lazy loading

The spec carries `ft = { "cs" }` and `opts = {}`. `opts` matters: it makes lazy call
`require("roslyn").setup(opts)` at load time, so `after/plugin/roslyn.lua` does not have to
— and must not. A file-level `require("roslyn")` there would load the plugin in every
session and defeat the `ft` gate, which is exactly the bug this config used to carry.

`vim.lsp.config("roslyn", …)` at startup is fine: it only registers a merge layer in a
table and never touches the module. Attaching still works on the buffer that triggered the
load, because `vim.lsp.enable()` ends with
`vim.cmd.doautoall('nvim.lsp.enable FileType')`.

`capabilities` is not set here — the `vim.lsp.config("*", …)` wildcard in `lsp.lua` is merge
layer 1 and already covers this server.

### Server settings

`after/plugin/roslyn.lua` enables, via the `csharp|…` setting groups, inlay hints (with the
three "suppress redundant" flags on), references and tests code lens, completion from
unimported namespaces, and `dotnet_organize_imports_on_format`.

No new machinery was needed for hints or lenses: `lsp.lua` already enables inlay hints for
any client advertising `textDocument/inlayHint` (toggle `<leader>lh`) and already wires
`vim.lsp.codelens.run`/`refresh` (`<leader>lc`). The settings only tell the *server* to
produce them.

`["csharp|background_analysis"]` is **deliberately absent**. The chosen scope is
`openFiles`, which is already the server default, so declaring the key would be a no-op.
`fullSolution` gives Rider-like diagnostics in unopened files at a continuous CPU and RAM
cost — reconsider only on a machine that is not also running gopls.

### Keymaps

All standard LSP keymaps apply (see [lsp-core.md](../plugins/lsp-core.md)). There are **no**
C#-specific keymaps: a `<leader>gdr` alias existed for OmniSharp muscle memory and was
removed, because `<leader>gd` (telescope) already calls the same `lsp_definitions` function
and the extra mapping made `<leader>gd` pay the full `timeoutlen` in C# buffers.

Buffer diagnostics go to the loclist with `<leader>ad` — not `<leader>d`, which stayed the
global delete-without-yank.

## Formatting

**Roslyn is the sole formatter.** `after/plugin/formatting.lua` declares
`cs = { "csharpier" }` and that entry stays on purpose: with the binary absent conform marks
it unavailable and the global `lsp_format = "fallback"` routes the buffer to Roslyn, so
installing csharpier later needs no config change.

csharpier is deliberately **not** installed. Unlike prettier and biome it carries no
`require_cwd`, so in a project without `.csharpierrc` it would reformat to its own defaults
(100 columns, its own ordering) and produce a large diff in code that follows another style.
`dotnet_organize_imports_on_format` on the Roslyn side covers the part that actually
mattered — it is the `goimports` equivalent for C#.

## Linting

None, on purpose. Roslyn's own analyzers are the diagnostics source; adding a linter would
duplicate every warning. `<leader>ml` in a `.cs` buffer reports that no linter is
configured, which is the intended answer.

## Debugging (DAP)

Uses `netcoredbg` — but **not** the Mason package. Mason's `netcoredbg` serves
`netcoredbg-osx-amd64.tar.gz` to the `darwin_arm64` target, and a x64 debugger cannot attach
to an arm64 process: netcoredbg goes through `dbgshim`/`ICorDebug`, which requires matching
architectures.

The adapter comes from
[Cliffback/netcoredbg-macOS-arm64.nvim](https://github.com/Cliffback/netcoredbg-macOS-arm64.nvim),
which ships an arm64 build committed in the plugin repo — so the lazy clone is the whole
install, with no download step. The binary is ad-hoc (linker-signed) and carries no
quarantine xattr when it arrives via git, so Gatekeeper lets it run.

`after/plugin/dap-dotnet.lua` calls the plugin's `setup()` **first** — it registers both
`dap.adapters.coreclr` and `dap.adapters.netcoredbg` — and only then overwrites
`dap.configurations.cs`. Order matters: the plugin also defines `configurations.cs`, with a
single entry that prompts for `ASPNETCORE_*` on every launch, and the last writer wins.

> The whole DAP stack is lazy: nothing debug-related loads until the first `F5` / `F9` /
> `<leader>Du` (or `<leader>tD` from neotest). The adapter and configurations are
> *registered* through `require("default.dap").register(...)` and the body only runs when
> the stack initialises. That is also why the plugin spec is `lazy = true` with no `ft` and
> no `nvim-dap` dependency — the `require` inside the closure is what loads it, and
> declaring the dependency would drag nvim-dap into the startup graph.
> See [dap-core.md](../plugins/dap-core.md).

### DAP Configurations

| Name | Request | Notes |
|---|---|---|
| Launch | `launch` | Prompts for the `.dll`, pre-filled by searching `**/bin/Debug/net*/*.dll` from the solution root. `ASPNETCORE_ENVIRONMENT=Development` is fixed, so the app loads `appsettings.Development.json` |
| Attach a processo | `attach` | Process picker — select the running dotnet process |

The pre-fill searches from the *solution* root, not the current file's directory, so it
still finds an executable's dll while you are editing a library. The plugin's own
`get_dll_path()` looks in `<current file dir>/bin/Debug` and falls back to the cwd, which
misses from any subdirectory.

**Launch workflow:** `dotnet build` → `F9` for breakpoints → `F5` → "Launch" → accept or
correct the pre-filled dll path.

**Attach workflow:** `dotnet run` → `F5` → "Attach a processo" → pick the process.

### DAP keymaps (global)

| Key | Action |
|---|---|
| `F9` | Toggle breakpoint |
| `F5` | Continue / start |
| `F10` | Step over |
| `F11` | Step into |
| `Shift+F11` | Step out |
| `Shift+F5` | Stop |
| `<leader>Du` | Toggle DAP UI |
| `<leader>Dc` | Close DAP UI |

## Testing

`neotest-dotnet` (`Issafalcon/neotest-dotnet`) is registered in `after/plugin/neotest.lua`
with explicit options:

- `dap = { adapter_name = "netcoredbg" }` — the adapter's own default, declared anyway. It
  emits `type = <adapter_name>` in its DAP strategy, and this config registers both
  `coreclr` and `netcoredbg`; stating the name is what stops `<leader>tD` from silently
  pointing at a nonexistent adapter if either name goes away. It previously did exactly
  that.
- `discovery_root = "solution"` — the default `"project"` anchors discovery to the current
  buffer's `.csproj`, so in a solution where only one project holds tests, `<leader>ta` from
  any other file finds nothing. The cost is that `dotnet test` runs across the solution.

Two things that look like bugs and are not: a test project can `<Compile Remove=…/>` whole
directories, and tests in them will never appear because they are not in the assembly; and
a `.runsettings` file is not auto-discovered — point at it with
`:NeotestSelectRunsettingsFile`.

`neotest-dotnet` upstream is looking for maintainers, so treat it as the least maintained
piece of this setup. `easy-dotnet.nvim` is the modern alternative (solution explorer, dotnet
commands, its own neotest adapter) and was considered; it was left out to avoid a new global
tool dependency and churn in the `<leader>t` maps that already work for Go, Dart and JS.

| Key | Action |
|---|---|
| `<leader>tt` | Run nearest test |
| `<leader>tf` | Run current file |
| `<leader>ta` | Run whole suite |
| `<leader>tD` | Debug nearest test (via `netcoredbg`) |
| `<leader>tl` | Re-run last |
| `<leader>tS` | Stop run |
| `<leader>ts` | Toggle summary panel |
| `<leader>to` | Open output for the nearest test |
| `<leader>tp` | Toggle output panel |
| `<leader>tw` | Toggle watch mode for the file |
| `]n` / `[n` | Jump to next / previous failed test |

## Project files and protobuf

nvim 0.12 already maps `.csproj`/`.slnx`/`.csproj.user` to `xml`, `.sln` to `solution` and
`.razor`/`.cshtml` to `razor`, so no filetype rules were needed — only parsers. `xml` and
`proto` are in the treesitter install list; `solution` has no upstream parser, and `razor`
is not installed because nothing here uses it.

Protobuf gets a parser and nothing else. `buf_ls`, conform's `buf` formatter and the
`buf_lint`/`protolint` linters all need a `buf.yaml`, which a project generating stubs
through MSBuild `<Protobuf Include=…/>` (Grpc.Tools) does not have. See the Treesitter
section of `CLAUDE.md` for why that makes them dead code or pure noise.
