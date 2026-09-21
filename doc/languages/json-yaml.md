# JSON / YAML

Configuration in `after/plugin/lsp.lua` (jsonls + yamlls blocks) and `after/plugin/formatting.lua`.

## JSON

`jsonls` — auto-installed via Mason.

### Filetypes

`json` and `jsonc`, both detected natively by nvim: `.json` → `json`; `.jsonc` and `tsconfig.json` → `jsonc`.

### Schema validation

[schemastore.nvim](https://github.com/b0o/schemastore.nvim) provides the full [SchemaStore](https://www.schemastore.org/) catalog automatically:

```lua
schemas = require("schemastore").json.schemas()
validate = { enable = true }
```

Schemas are matched by filename (e.g. `package.json`, `.eslintrc.json`, `tsconfig.json`, `docker-compose.yml`).

## YAML

`yamlls` — auto-installed via Mason.

### Schema validation

Same schemastore.nvim integration:

```lua
schemas = require("schemastore").yaml.schemas()
```

Helm charts get their own treatment — templates and `values.yaml` have a
dedicated filetype and LSP, so yamlls doesn't try to parse Go-template syntax
as plain YAML. See [helm.md](helm.md).

## Formatting

Owned by conform.nvim (`after/plugin/formatting.lua`), on save and with `<leader>f`:

| Filetypes | Formatters |
|---|---|
| `json`, `jsonc` | `biome`, then `prettier` (`stop_after_first`) |
| `yaml` | `prettier` |

Both binaries resolve from the project's `node_modules/.bin`, carry `require_cwd = true`, and the filetypes are marked `lsp_format = "never"`.

> The consequence is intentional: in a project with no prettier/biome configuration, JSON and YAML files are **left untouched** on save. Without `lsp_format = "never"`, the global `"fallback"` would hand the buffer to `jsonls`/`yamlls` and reformat exactly the repos that chose not to use prettier.

## Treesitter

The `json` and `yaml` parsers come from `nvim-treesitter` (branch `main`). `after/plugin/treesitter.lua` also registers `jsonc` and `json5` against the `json` parser, since neither ships one of its own.

## All standard LSP keymaps apply

See [lsp-core.md](../plugins/lsp-core.md). Buffer diagnostics go to the loclist with `<leader>ad`.
