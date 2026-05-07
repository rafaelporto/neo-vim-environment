# JSON / YAML

Configuration in `after/plugin/lsp.lua` (jsonls + yamlls blocks) and `after/plugin/filetypes.lua`.

## JSON

`jsonls` — auto-installed via Mason.

### Filetypes

`json` and `jsonc`. An autocmd in `filetypes.lua` also sets `.json.base` files to `filetype=json`.

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

## All standard LSP keymaps apply

See [lsp-core.md](../plugins/lsp-core.md).
