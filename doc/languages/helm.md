# Helm

Configuration in `after/plugin/filetypes.lua` (filetype detection),
`after/plugin/lsp.lua` (helm_ls), and `lua/default/plugins.lua` (treesitter
parser).

## Why this exists

`yamlls` tries to parse every `*.yaml`/`*.yml` as plain YAML. A Helm template
mixes YAML with Go-template syntax (`{{- if .strategy }}`), which is not valid
YAML before Helm renders it — and breaks the yamlls parser with errors like:

```
Unexpected flow-map-end token in YAML stream: "}"
```

on lines such as:

```yaml
type: {{ if .strategy }} {{ default "Recreate" .strategy.type }} {{ else }} Recreate {{ end }}
```

nvim-lspconfig's `lsp/yamlls.lua` lists
`filetypes = { "yaml", "yaml.docker-compose", "yaml.gitlab", "yaml.helm-values" }` —
no plain `helm`. So giving Helm templates a dedicated `helm` filetype already
takes them out of yamlls's reach, with no manual exclusion needed.

## Filetypes

`after/plugin/filetypes.lua` registers two `vim.filetype.add({ pattern = {...} })`
rules, each guarded by a Chart.yaml check so a `templates/` folder that isn't
part of an actual Helm chart is unaffected — the detector functions return
`nil` in that case, and Neovim falls back to the default extension-based
`yaml`:

- `templates/**/*.yaml`, `templates/**/*.yml`, `templates/**/*.tpl` → `helm`,
  gated on a Chart.yaml found by walking **up** from the file (covers
  `templates/tests/test-connection.yaml`, N levels below the chart root).
- `values.yaml`, `values.yml`, `values-*.yaml`, `values.*.yaml` →
  `yaml.helm-values`, gated on a Chart.yaml **sibling** (values files always
  live next to Chart.yaml, never inside `templates/`).

`yaml.helm-values` is deliberately a composite filetype: both `yamlls` and
`helm_ls` already list it by default, so `values.yaml` keeps normal YAML
validation from yamlls *and* gains `.Values` completion/hover from helm_ls,
both attached to the same buffer.

> `vim.filetype.add` patterns resolve before the generic extension rule
> (`.yaml` → `yaml`), so registering these patterns is enough to intercept the
> file — no priority tuning, no need to undo the default mapping.

> A buffer already open before this rule existed keeps its old filetype —
> `vim.filetype.add` is only consulted on initial detection. Reopen it (`:e`)
> or run `:set filetype=helm` by hand.

## LSP

`helm_ls` ([mrjosh/helm-ls](https://github.com/mrjosh/helm-ls)), installed via
Mason (package `helm-ls`, native `darwin_arm64` asset).

> **No dedicated `vim.lsp.config["helm_ls"]` block**, following the same
> pattern as `cssls`/`marksman`/`dockerls` in this file: servers with no
> special settings don't get one. nvim-lspconfig's default already ships
> `filetypes = {"helm", "yaml.helm-values"}` and `root_markers = {"Chart.yaml"}`,
> and capabilities arrive through the `vim.lsp.config("*", {...})` wildcard
> layer like every other server.

In a monorepo with multiple charts, `root_markers = {"Chart.yaml"}` resolves
the *nearest* Chart.yaml — same search the filetype detector does — so each
chart gets its own isolated `helm_ls` instance, and a subchart's `values.yaml`
resolves against the subchart's own Chart.yaml, not the parent's.

## Treesitter

The `helm` parser (tier 2 in nvim-treesitter's registry,
`ngalaiko/tree-sitter-go-template`, `dialects/helm`) is in the `install({...})`
list in `lua/default/plugins.lua`.

`gotmpl` is **not** installed separately. `queries/helm/injections.scm`
declares `; inherits: gotmpl`, but that's query-*text* inheritance
(`nvim_get_runtime_file`), not a parser dependency — nvim-treesitter ships
`runtime/queries/gotmpl/*.scm` inside the plugin itself, independent of the
install list. The same injections query already re-injects `yaml` into the
text outside `{{ }}` blocks, so the YAML parts of a template keep normal
highlighting.

No change was needed in `after/plugin/treesitter.lua`: `get_lang("helm")`
resolves to `"helm"` and `get_lang("yaml.helm-values")` resolves to `"yaml"`
without any `vim.treesitter.language.register()` — the existing generic
highlighting autocmd covers both filetypes automatically.

## Formatting

None, on purpose. Adding a `helm` entry to `formatters_by_ft` would mean
prettier — which does not understand `{{ }}`/`{{- -}}` — mangling the
template. Without an entry, the global `lsp_format = "fallback"` applies: if
`helm_ls` doesn't implement `textDocument/formatting`, nothing happens on
save. Worst case is "doesn't format", never "formats wrong".

`values.yaml` is unaffected: conform falls back from `yaml.helm-values` to the
existing `yaml` entry (prettier) when no exact key matches, so it keeps
formatting normally.

## Linting

None — `after/plugin/linting.lua` has no `yamllint` today, so there is nothing
to exclude for `helm`.

## All standard LSP keymaps apply

See [lsp-core.md](../plugins/lsp-core.md).
