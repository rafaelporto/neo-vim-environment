# Clojure

Configuration in `after/plugin/lsp.lua` (clojure_lsp), `after/plugin/nvim-paredit.lua`, `after/plugin/filetypes.lua`, and `lua/default/set.lua` (conjure globals).

## Filetype detection

`.clj`, `.cljs`, `.edn`, `.edn.base` are all set to `filetype=clojure` via an autocmd in `filetypes.lua`.

## LSP

`clojure_lsp` — auto-installed via Mason. Capabilities only, no custom `on_attach`. All standard LSP keymaps apply (see [lsp-core.md](../plugins/lsp-core.md)).

## Linting

`clj-kondo` diagnostics via none-ls — runs automatically for `clojure` buffers.

## Conjure (REPL)

[conjure](https://github.com/Olical/conjure) evaluates Clojure code against a running nREPL. Local leader is `,`.

Start the nREPL with [vim-jack-in](https://github.com/clojure-vim/vim-jack-in): `:JackIn` (uses vim-dispatch under the hood).

| Key | Action |
|---|---|
| `,eb` | Evaluate buffer |
| `,ef` | Evaluate file |
| `,ee` | Evaluate expression under cursor |
| `,er` | Evaluate root form |
| `,em` | Evaluate motion |
| `,ls` | Open log split |
| `,lv` | Open log vsplit |
| `,lq` | Close log |

**Conjure globals** (set in `set.lua`):
- `log#botright = true` — log opens at the bottom
- `debug = false`
- `mapping#doc_word` disabled

## nvim-paredit (Structural editing)

Structural editing for s-expressions. All keys active in `clojure` buffers only.

### Slurp / Barf

| Key | Action |
|---|---|
| `>)` | Slurp forwards |
| `<)` | Barf forwards |
| `<(` | Slurp backwards |
| `>(` | Barf backwards |

### Drag

| Key | Action |
|---|---|
| `>e` | Drag element right |
| `<e` | Drag element left |
| `>f` | Drag form right |
| `<f` | Drag form left |

### Raise

| Key | Action |
|---|---|
| `,o` | Raise form (replace parent with current form) |
| `,O` | Raise element |
| `,@` | Splice (unwrap current form) |

### Navigation

| Key | Mode | Action |
|---|---|---|
| `W` | n/x/o/v | Jump to next element head |
| `E` | n/x/o/v | Jump to next element tail |
| `B` | n/x/o/v | Jump to previous element head |
| `gE` | n/x/o/v | Jump to previous element tail |
| `(` | n/x/v | Jump to parent form start |
| `)` | n/x/v | Jump to parent form end |

### Text objects

| Key | Mode | Selects |
|---|---|---|
| `af` | o/v | Around form |
| `if` | o/v | Inside form |
| `aF` | o/v | Around top-level form |
| `iF` | o/v | Inside top-level form |
| `ae` | o/v | Around element |
| `ie` | o/v | Element |
