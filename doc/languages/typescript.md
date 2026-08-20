# TypeScript / JavaScript

Configuration in `after/plugin/lsp.lua` (vtsls + eslint), `after/plugin/formatting.lua` (biome / prettier), `after/plugin/dap-js.lua` (js-debug-adapter), `after/plugin/neotest.lua` (vitest + jest), and the `nvim-ts-autotag` spec in `lua/default/plugins.lua`.

## LSP

| Server | Installed via | Purpose |
|---|---|---|
| `vtsls` | Mason `ensure_installed` | TypeScript/JavaScript language server (wraps tsserver) |
| `eslint` | Mason `ensure_installed` | ESLint diagnostics + `:LspEslintFixAll` |

> **`ts_ls` must never run alongside `vtsls`** — duplicated diagnostics and double the memory. mason-lspconfig auto-enables every installed server, so `ts_ls` is listed in `automatic_enable = { exclude = { "ts_ls" } }` as a guard in case the package is ever reinstalled.

`vtsls` replaced `ts_ls` because it exposes the whole VSCode settings namespace, so inlay hints and import preferences are configurable per workspace; typescript-language-server only accepts preferences through `initializationOptions`.

All standard LSP keymaps apply (see [lsp-core.md](../plugins/lsp-core.md)). Buffer diagnostics go to the loclist with `<leader>ad`.

### vtsls options

| Setting | Value | Effect |
|---|---|---|
| `autoUseWorkspaceTsdk` | `true` | uses the project's own `typescript` package |
| `enableMoveToFileCodeAction` | `true` | "Move to file" refactor |
| `experimental.completion.enableServerSideFuzzyMatch` | `true` | fuzzy matching done server-side |
| `experimental.maxInlayHintLength` | `30` | truncates long hints |

### Inlay hints

The same hint table is applied to both the `typescript` and `javascript` sections:

| Hint | Value |
|---|---|
| `parameterNames` | `"literals"` (+ `suppressWhenArgumentMatchesName`) |
| `parameterTypes` | enabled |
| `variableTypes` | **disabled** (too noisy; `suppressWhenTypeMatchesName` set anyway) |
| `propertyDeclarationTypes` | enabled |
| `functionLikeReturnTypes` | enabled |
| `enumMemberValues` | enabled — **`typescript` section only** (the key does not exist for JS) |

Hints turn on when the buffer attaches; `<leader>lh` toggles them.

### Preferences (both languages)

| Setting | Value |
|---|---|
| `importModuleSpecifier` | `"shortest"` |
| `importModuleSpecifierEnding` | `"auto"` |
| `includePackageJsonAutoImports` | `"auto"` |
| `preferTypeOnlyAutoImports` | `true` |
| `updateImportsOnFileMove` | `"always"` |
| `suggest.completeFunctionCalls` | `true` |

### ESLint

`format = false` — ESLint is a linter here, not a formatter. Leaving it `true` would let conform's LSP fallback elect ESLint as the formatter for web files.

> **No `on_attach` is defined for eslint, on purpose.** nvim-lspconfig's own `lsp/eslint.lua` already provides `workingDirectory` mode `"auto"`, `workspace_required`, a `root_dir` that refuses to attach without an ESLint config in the project, and an `on_attach` that creates the `:LspEslintFixAll` command. Overriding `on_attach` would destroy that command — which `formatting.lua` invokes on every save.

ESLint diagnostics are not duplicated in nvim-lint: the LSP already reports them live.

## Formatting

Owned entirely by `after/plugin/formatting.lua` (conform.nvim). Format on save, or manually with `<leader>f` (normal + visual).

| Filetypes | Formatters |
|---|---|
| `javascript`, `javascriptreact`, `typescript`, `typescriptreact`, `json`, `jsonc` | `biome`, then `prettier` (`stop_after_first`) |
| `css`, `html`, `yaml`, `markdown`, `graphql` | `prettier` |

Both binaries resolve from the project's `node_modules/.bin` (conform's `from_node_modules`), so nothing is installed globally.

Two deliberate details:

- **`require_cwd = true`** on prettier and biome. Without a config file in the project, conform marks the formatter `available = false` ("Root directory not found") instead of erroring — a repo that deliberately does not use prettier is left untouched.
- **`lsp_format = "never"`** on every web filetype. Without it the global `"fallback"` would hand the buffer to vtsls/jsonls whenever the project has no prettier config, reformatting with tsserver defaults and defeating `require_cwd` (verified: `const   x:number=1` became `const x: number = 1`).

### Save order

A single `BufWritePre` autocmd runs, in this order:

1. `:LspEslintFixAll` — only if an `eslint` client is attached to that buffer. This rewrites *code*: import order, `prefer-const`, unused imports.
2. `conform.format` — decides the final layout.

Registering the two in separate autocmds would leave the order up to registration order, and conform would win — leaving ESLint's rewrites unformatted.

## Debugging (DAP)

Configured in `after/plugin/dap-js.lua`. Install the adapter once:

```vim
:MasonInstall js-debug-adapter
```

If the binary is absent the file returns early and stays silent instead of warning on every startup. Adapter names follow vscode-js-debug: `pwa-node` and `pwa-chrome`, both launched as servers on `${port}`.

> The whole DAP stack is lazy: nothing debug-related loads until the first `F5` / `F9` / `<leader>Du` (or `<leader>tD` from neotest). The adapter and configurations below are *registered* through `require("default.dap").register(...)` and the body only runs when the stack initialises. See [dap-core.md](../plugins/dap-core.md).

> The executable check is the one thing that still runs at file level — it decides whether to register at all, and it is a `vim.fn.executable` call on a known path.

### DAP Configurations

Registered for `javascript`, `typescript`, `javascriptreact` and `typescriptreact`:

| Name | Adapter | Request | Notes |
|---|---|---|---|
| `Launch arquivo atual` | `pwa-node` | `launch` | runs `${file}`, source maps on, skips `node_internals` and `node_modules` |
| `Launch npm script` | `pwa-node` | `launch` | prompts for the script name (default `dev`) in an integrated terminal |
| `Attach a processo` | `pwa-node` | `attach` | process picker |
| `Launch Chrome em localhost` | `pwa-chrome` | `launch` | prompts for the URL (default `http://localhost:3000`) |
| `Attach ao Chrome (--remote-debugging-port=9222)` | `pwa-chrome` | `attach` | port 9222 |

Prompts are wrapped in functions, so they fire on `F5` rather than at startup.

> **No ts-node / tsx configuration**, on purpose: Node 26 strips types natively, so `.ts` files run directly. Debugging a *test* comes from neotest (`<leader>tD`), so there is no jest/vitest configuration here either.

### DAP keymaps (global)

| Key | Action |
|---|---|
| `F9` | Toggle breakpoint |
| `F5` | Continue / start |
| `F10` | Step over |
| `F11` | Step into |
| `Shift+F11` | Step out |
| `Shift+F5` | Stop session |
| `<leader>Du` | Toggle DAP UI |
| `<leader>Dc` | Close DAP UI |

## Testing

`neotest-vitest` and `neotest-jest` are registered in `after/plugin/neotest.lua`. Both adapters gate on their own dependency being declared in `package.json`, so a repo using one is not confused by the other being loaded.

> **The one exception:** a project mid-migration with *both* `jest` and `vitest` in `package.json`. Both adapters will claim the same `*.test.ts` and the summary shows duplicate entries. Fix it per project by overriding `is_test_file` (vitest) or `isTestFile` (jest).

> Registration syntax differs per adapter: `neotest-vitest` is used bare, `neotest-jest` is called (`require("neotest-jest")({})`).

> **Do not override `jestArguments`:** without `--forceExit`, `--testLocationInResults`, `--json` and `--outputFile` the adapter hangs. And do not enable `jest_test_discovery` — it requires the global `discovery.enabled = false`, which would degrade Go, Dart and .NET discovery.

| Key | Action |
|---|---|
| `<leader>tt` | Run nearest test |
| `<leader>tf` | Run current file |
| `<leader>ta` | Run whole suite |
| `<leader>tD` | Debug nearest test (via DAP) |
| `<leader>tl` | Re-run last |
| `<leader>tS` | Stop run |
| `<leader>ts` | Toggle summary panel |
| `<leader>to` | Open output for the nearest test |
| `<leader>tp` | Toggle output panel |
| `<leader>tw` | Toggle watch mode for the file |
| `]n` / `[n` | Jump to next / previous failed test |

## Editing

[nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag) closes and renames HTML/JSX tags. Loaded on `html`, `javascript`, `javascriptreact`, `typescript`, `typescriptreact` and `markdown`.

> The spec passes `opts = {}` so lazy.nvim calls `setup({})`, which is **mandatory**: the plugin's zero-config path does `require("nvim-treesitter.configs")`, a module that does not exist on the `main` branch, and breaks.

The `typescript`, `tsx`, `javascript`, `jsdoc`, `json`, `css` and `html` parsers come from `nvim-treesitter` (branch `main`); highlighting and folds are started by `after/plugin/treesitter.lua`.
