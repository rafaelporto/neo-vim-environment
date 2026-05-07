# Editing Tools

Small utility plugins configured across several `after/plugin/` files.

## Comment.nvim

Configuration in `after/plugin/comment.lua`. Bare `setup()` call — uses default keymaps.

| Key | Mode | Action |
|---|---|---|
| `gcc` | n | Toggle line comment |
| `gc` + motion | n | Comment motion (e.g. `gcap` = comment paragraph) |
| `gc` | v | Toggle comment on selection |

## vim-surround

`lazy = false`. Standard tpope surround bindings.

| Key | Action |
|---|---|
| `ys{motion}{char}` | Add surround |
| `cs{old}{new}` | Change surround |
| `ds{char}` | Delete surround |

Example: `ysiw"` surrounds word with quotes; `cs"'` changes `"` to `'`.

## Undotree

Configuration in `after/plugin/undotree.lua`. Persistent undo stored in `~/.vim/undodir` (set in `set.lua`).

| Key | Action |
|---|---|
| `<leader>u` | Toggle undotree panel |

## Todo Comments

Configuration in `after/plugin/todo-comment.lua`. Highlights `TODO`, `FIXME`, `HACK`, `NOTE`, `BUG`, `PERF`, `WARN` in comments.

| Key | Action |
|---|---|
| `ntd` | Jump to next TODO comment |
| `ptd` | Jump to previous TODO comment |
| `<leader>td` | List all TODOs in Telescope |

## Treesitter

Configuration in `after/plugin/treesitter.lua`. nvim 0.12+ ships parsers bundled — no `nvim-treesitter` plugin needed. An autocmd calls `pcall(vim.treesitter.start, buf)` on every `FileType` event to handle any filetype not auto-started by a built-in ftplugin.

## Rainbow Delimiters

Configuration in `after/plugin/rainbow-delimiters.lua`. Colors nested brackets/parens/braces with a 7-color cycle.

| Option | Value |
|---|---|
| Default strategy | `global` |
| Vim files strategy | `local` |
| Default priority | 110 |
| Lua priority | 210 |

Colors (in order): Green → Yellow → Blue → Violet → Cyan → Orange → Red.

## vim-illuminate

`lazy = false`. Automatically highlights all other occurrences of the word under the cursor using LSP, Treesitter, or regex (in that priority order). No configuration or keymaps needed.
