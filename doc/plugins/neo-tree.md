# Neo-tree

Configuration in `after/plugin/neo-tree.lua`. Lazy-loaded, opens on `<leader>e`.

## Config

| Option | Value | Effect |
|---|---|---|
| `close_if_last_window` | `true` | Closes Neovim if neo-tree is the only window left |
| `hide_dotfiles` | `false` | Dotfiles visible |
| `hide_gitignored` | `true` | Gitignored files hidden |
| `follow_current_file` | `true` | Tree scrolls to and highlights the active file |
| `position` | `left` | Panel opens on the left |
| `width` | `35` | Panel width in columns |
| `enable_git_status` | `true` | Git status icons in the tree |
| `enable_diagnostics` | `true` | LSP diagnostic icons in the tree |

## Keymaps

| Key | Action |
|---|---|
| `<leader>e` | Toggle file explorer |
