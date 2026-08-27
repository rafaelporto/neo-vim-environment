# Neotest

Configuration in `after/plugin/neotest.lua`. Plugin spec and adapter list in `lua/default/plugins.lua`.

## Purpose

One test UI for every language: run the nearest test, the file or the whole suite, watch a file, jump between failures, and debug a single test through nvim-dap.

> neotest had been installed since the beginning, but `require("neotest").setup()` was never called anywhere in the repo — no adapter, no keymap, pure dead weight.

## Adapters

| Adapter | Language | Registered as |
|---|---|---|
| [neotest-golang](https://github.com/fredrikaverpil/neotest-golang) | Go | `require("neotest-golang")({ ... })` |
| [neotest-vitest](https://github.com/marilari88/neotest-vitest) | JS/TS (Vitest) | `require("neotest-vitest")` |
| [neotest-jest](https://github.com/nvim-neotest/neotest-jest) | JS/TS (Jest) | `require("neotest-jest")({})` |
| [neotest-dart](https://github.com/sidlatau/neotest-dart) | Dart / Flutter | `require("neotest-dart")({ ... })` |
| [neotest-dotnet](https://github.com/Issafalcon/neotest-dotnet) | C# | `require("neotest-dotnet")({ … })` |

Required dependencies: `plenary.nvim`, `nvim-nio` and `FixCursorHold.nvim`. `neotest-golang` is pinned with `version = "*"` so it tracks releases rather than `main`.

### Registration syntax

Every adapter module is a table carrying a `__call` metamethod, so **both forms are valid and they mean different things**:

- `require("neotest-x")` — register the adapter with its defaults.
- `require("neotest-x")({ ... })` — call it to apply options, and register the result.

Passing options to the bare form (or forgetting the parentheses when you *do* have options) is the classic first-attempt error: the options are silently ignored, or neotest receives something it cannot use. Here `golang`, `jest`, `dart` and `dotnet` are called; only `vitest` is registered bare, because it runs on defaults.

`dotnet` receives two options, and both are worth knowing about:

- `dap = { adapter_name = "netcoredbg" }` — the adapter's own default, stated anyway. neotest-dotnet emits `type = <adapter_name>` in its DAP strategy, and `after/plugin/dap-dotnet.lua` registers both `coreclr` and `netcoredbg`. Declaring the name is what keeps `<leader>tD` from silently pointing at a nonexistent adapter if either name goes away — which is exactly what happened while the adapter was registered bare and the config only defined `coreclr`.
- `discovery_root = "solution"` — the default `"project"` anchors discovery to the current buffer's `.csproj`, so in a solution where only one project holds tests, `<leader>ta` from any other file finds nothing. The cost is that `dotnet test` runs across the whole solution.

Two C# behaviours that look like bugs and are not: a test project can `<Compile Remove=…/>` entire directories, and tests inside them never appear because they are not in the compiled assembly; and a `.runsettings` file is not auto-discovered — point at it with `:NeotestSelectRunsettingsFile`.

## Go (neotest-golang)

| Option | Value | Why |
|---|---|---|
| `runner` | `"gotestsum"` | Strong upstream recommendation — the plain `go` runner reads JSON from stdout and suffers truncation/corruption; gotestsum writes to a file |
| `go_test_args` | `-v`, `-race`, `-count=1` | Verbose output, race detector, no test cache |
| `testify_enabled` | `true` | Discovers testify suite methods |
| `dap_mode` | `"manual"` | See below |
| `dap_manual_config` | `name`, `type = "go"`, `request = "launch"`, `mode = "test"` | Reuses the `go` adapter from `after/plugin/dap-go.lua` |

```sh
go install gotest.tools/gotestsum@latest
```

### Why `dap_mode = "manual"`

The default is `"dap-go"`. In that mode the adapter calls `require("dap-go").setup()` on **every** debug session, and dap-go does `table.insert` into `dap.configurations.go` without clearing it first — so the `F5` picker would grow by 7 entries per debug run.

Manual mode points straight at the `go` adapter defined in `after/plugin/dap-go.lua`. That is also why the adapter is named `go` and not `delve` (see [dap-core.md](dap-core.md)) — and it removes the need for the `nvim-dap-go` plugin entirely.

## JS/TS (vitest, jest)

Both are registered so a monorepo with different runners per package works without editing config.

> **Do not override `jestArguments`.** Without `--forceExit`, `--testLocationInResults`, `--json` and `--outputFile`, the adapter hangs.

> **Do not enable `jest_test_discovery`.** It requires the *global* `discovery.enabled = false`, which would degrade discovery for Go, Dart and dotnet as well.

## Dart / Flutter (neotest-dart)

| Option | Value | Why |
|---|---|---|
| `command` | `"flutter"` | Change to `"fvm flutter"` if the project uses FVM |
| `use_lsp` | `true` | Uses the dartls outline for test names treesitter cannot parse, such as `testWidgets` |

## Keymaps

The `<leader>t` namespace, all in normal mode:

| Key | Action |
|---|---|
| `<leader>tt` | Run nearest test |
| `<leader>tf` | Run current file |
| `<leader>ta` | Run whole suite |
| `<leader>tD` | Debug nearest test (`strategy = "dap"`) |
| `<leader>tl` | Re-run last |
| `<leader>tS` | Stop run |
| `<leader>ts` | Toggle summary panel |
| `<leader>to` | Open output for the nearest test (focuses the window) |
| `<leader>tp` | Toggle output panel |
| `<leader>tw` | Toggle watch mode for the current file |
| `]n` | Jump to next failed test |
| `[n` | Jump to previous failed test |

> **`<leader>tD` calls `require("default.dap").ensure()` first.** neotest brings up nvim-dap on its own for `strategy = "dap"`, but the listeners that open and close the dapui live in `lua/default/dap.lua` — without that call the test would be debugged with no UI at all. See [dap-core.md](dap-core.md).

> **Why `<leader>tD` and not `<leader>td`.** `after/plugin/todo-comment.lua` owns `<leader>td` (`:TodoTelescope`) and is sourced after `neotest.lua` alphabetically, so a `td` here would never fire. The debug map uses the capital, matching `<leader>tS` for stop.

> Three keys in this namespace differ only by case: `<leader>ts` (summary), `<leader>tS` (stop) and `<leader>tD` (debug nearest). Intentional, but worth knowing before reaching for one in a hurry.

## Known risks

- **jest + vitest in the same `package.json` → duplicate entries.** Both adapters recognise the same `*.test.ts` / `*.spec.ts` files, and neotest asks every adapter. A project that lists both runners will show each test twice in the summary. Remove the adapter you do not use, or narrow it, if that becomes annoying.
- **neotest-dotnet is looking for new maintainers** (see the banner in its README and upstream discussion #142). It works today; treat it as the least maintained piece of this setup. `easy-dotnet.nvim` is the modern alternative — solution explorer, dotnet commands and its own neotest adapter — and was considered and left out, to avoid a new global-tool dependency (`dotnet tool install -g EasyDotnet`) and churn in the `<leader>t` maps that already work for Go, Dart and JS. Revisit if this adapter breaks.
- **`:checkhealth neotest-golang` false-alarms on testify.** With `testify_enabled = true` it reports two errors for `testify/namespace` and `testify/test_method`, because its `health.lua` looks for `namespace.scm` and `test_method.scm` — files the plugin does not ship. What the runtime actually loads is `features/testify/queries/go/{testify_method,suite,package}.scm`, all present. Test discovery was verified working with `testify_enabled` both `true` and `false`, finding the same tests either way.
