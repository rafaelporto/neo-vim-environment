# Completion

Configuration in `after/plugin/completions.lua`.

## Stack

- **nvim-cmp** — completion engine
- **LuaSnip** — snippet engine
- **friendly-snippets** — VSCode-format community snippets (lazy-loaded)
- **snippets/swift.snippets** — custom Swift snippets in SnipMate format (loaded via `loaders.from_snipmate`)

## Sources (priority order)

| Source | Provides |
|---|---|
| `nvim_lsp` | LSP completions |
| `luasnip` | Snippets |
| `buffer` | Words in current buffer |
| `path` | Filesystem paths |
| `conjure` | Clojure REPL symbols (injected for Clojure buffers only) |

## Keymaps

| Key | Mode | Action |
|---|---|---|
| `<C-Space>` | i | Trigger completion |
| `<C-e>` | i | Abort / close completion menu |
| `<C-p>` | i | Select previous item |
| `<C-n>` | i | Select next item |
| `<CR>` | i | Confirm selected item |
| `<C-f>` | i/s | Jump to next snippet placeholder |
| `<C-b>` | i/s | Jump to previous snippet placeholder |
| `<C-u>` | i | Scroll docs up |
| `<C-d>` | i | Scroll docs down |

## Windows

Both the completion popup and documentation window use a bordered style (`cmp.config.window.bordered()`).
