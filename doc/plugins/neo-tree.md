# Neo-tree

Configuration in `after/plugin/neo-tree.lua`. Lazy-loaded — the `<leader>e` key is declared in the plugin spec's `keys` table in `lua/default/plugins.lua`, so the plugin only loads on first use.

## Config

| Option | Value | Effect |
|---|---|---|
| `close_if_last_window` | `true` | Closes Neovim if neo-tree is the only window left |
| `hijack_netrw_behavior` | `disabled` | Neo-tree does **not** take over netrw — `<leader>pv` still opens netrw |
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

## Xcodebuild integration

`oil.nvim` and `nvim-tree.lua` were removed. They were only **optional** dependencies of `xcodebuild.nvim`, used to sync the `.xcodeproj` when you create, rename or delete a file from the file explorer.

That feature is unaffected: xcodebuild.nvim also ships `integrations/neo-tree.lua` with `neo_tree = { enabled = true }` by default, and neo-tree is the actual explorer here — so the sync keeps working through the path that is in use.
