# Formatting

Configuration in `after/plugin/formatting.lua`. **conform.nvim is the single owner of formatting** in this config.

## Why a single owner

Before, three plugins each believed they were in charge:

- `conform.setup()` lived inside `swift-config.lua` with a **global** `format_on_save`
- none-ls impersonated an LSP server and advertised formatting capability
- `<leader>f` called `vim.lsp.buf.format`

The result: Swift was formatted by sourcekit, Dart by dartls and TypeScript by tsserver — precisely the three languages for which `swiftformat`, `dart_format` and `prettier` were configured and never once used. Now conform owns the save hook and `<leader>f`, none-ls is down to a single *diagnostics* source (see [none-ls.md](none-ls.md)), and linting lives in `after/plugin/linting.lua`.

## Formatters by filetype

| Filetypes | Formatters | `lsp_format` |
|---|---|---|
| `javascript`, `javascriptreact`, `typescript`, `typescriptreact`, `json`, `jsonc` | `biome` → `prettier` (`stop_after_first`) | `never` |
| `css`, `html`, `yaml`, `markdown`, `graphql` | `prettier` | `never` |
| `go` | `goimports` → `gofumpt` | `fallback` |
| `dart` | `dart_format` | `fallback` |
| `swift` | `swiftformat` | `fallback` |
| `lua` | `stylua` | `fallback` |
| `cs` | `csharpier` | `fallback` |
| `sql` | `sqlfmt` | `fallback` |

`default_format_opts` sets `timeout_ms = 1000` and `lsp_format = "fallback"` — the current spelling; `lsp_fallback` is deprecated.

## The biome → prettier cascade

With `stop_after_first = true`, conform runs the **first available** formatter and stops. A project with `biome.json` gets biome; a project with a prettier config gets prettier; a project with neither gets nothing.

Both binaries resolve from the project's own `node_modules/.bin` — conform's builtin configs use `util.from_node_modules()` — so **nothing is installed globally**:

```sh
npm i -D prettier            # or: npm i -D @biomejs/biome
```

## `require_cwd = true`

```lua
formatters = {
  prettier = { require_cwd = true },
  biome    = { require_cwd = true },
}
```

Each formatter has a `cwd` function that walks up looking for its config — `biome.json{,c}` / `.biome.json{,c}` for biome, any prettier config file or a `package.json` with a `prettier` key for prettier. With `require_cwd`, conform marks the formatter `available = false` ("Root directory not found") when that search fails, instead of running it with default settings. A repository that deliberately does not use prettier is therefore left alone — and an unavailable formatter is *not* an error.

## `lsp_format`: `never` for web, `fallback` elsewhere

This split is the point of the file, and dropping it silently breaks `require_cwd`.

- **Web filetypes override the global default with `lsp_format = "never"`.** Otherwise, in a project with no prettier and no biome config, the global `"fallback"` hands the buffer to `vtsls`/`jsonls`, which reformats it with tsserver defaults — defeating `require_cwd` and reformatting exactly the repositories that opted out. Verified: `const   x:number=1` became `const x: number = 1`.
- **Native toolchains keep `"fallback"`**, because there the fallback is what you want: if the dedicated binary is missing, sourcekit / roslyn / dartls / gopls produce essentially the same output. `gopls` is configured with `gofumpt = true` precisely so its fallback matches `gofumpt`.

## Format on save: eslint first, then the formatter

One `BufWritePre` autocmd (augroup `format_on_save`), with the order written out explicitly:

1. If an `eslint` client is attached to the buffer, run `:LspEslintFixAll` — this **rewrites code**: sorts imports, applies `prefer-const`, strips unused imports.
2. Then `conform.format({ bufnr = buf })` — this decides the final layout.

> **Why one autocmd and not two.** Two separate `BufWritePre` autocmds would leave the order to registration order, and conform would win — leaving eslint's rewrites unformatted.

The `:LspEslintFixAll` command is created by the `on_attach` from `nvim-lspconfig`'s `lsp/eslint.lua`, which is why `after/plugin/lsp.lua` must not override eslint's `on_attach`. The check is `vim.lsp.get_clients({ bufnr = buf, name = "eslint" })`, so nothing happens in buffers without eslint.

Buffers with filetype `neo-tree` are skipped.

## Keymaps

| Key | Mode | Action |
|---|---|---|
| `<leader>f` | n / v | `conform.format({ async = true })` — whole buffer, or the selected range in visual mode |

The old `<leader>f` → `vim.lsp.buf.format` mapping was removed from `lua/default/remap.lua`.

## External tools

| Formatter | Command | How to install |
|---|---|---|
| `prettier` | `./node_modules/.bin/prettier` | `npm i -D prettier` — per project |
| `biome` | `./node_modules/.bin/biome` | `npm i -D @biomejs/biome` — per project |
| `goimports` | `goimports` | `:MasonInstall goimports` |
| `gofumpt` | `gofumpt` | `:MasonInstall gofumpt` |
| `stylua` | `stylua` | `:MasonInstall stylua` |
| `swiftformat` | `swiftformat` | `brew install swiftformat` |
| `dart_format` | `dart format` | Bundled with the Flutter/Dart SDK |
| `csharpier` | `dotnet csharpier` if the dotnet tool is available, otherwise `csharpier` | `dotnet tool install csharpier` |
| `sqlfmt` | `sqlfmt` | `pip install shandy-sqlfmt` |

Mason prepends its `bin` directory to `PATH`, so anything installed with `:MasonInstall` is found without further configuration.

## Troubleshooting

`log_level` is `vim.log.levels.ERROR`, so only real failures are logged.

| Command | Use |
|---|---|
| `:ConformInfo` | Which formatters are available for this buffer, and why one is not |
| `:checkhealth conform` | Global sanity check |

A formatter reported as unavailable is normal — for `prettier`/`biome` it usually means the project has no config (`require_cwd`), and for the rest it means the binary is not installed, in which case the language server formats instead.
