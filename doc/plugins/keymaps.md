# Global Keymaps

Defined in `lua/default/remap.lua`. Active in all buffers regardless of filetype or LSP state.

- Leader: `<Space>`
- Local leader: `,` (used by conjure in Clojure buffers)

## Navigation & Scrolling

| Key | Mode | Action |
|---|---|---|
| `<C-d>` | n | Scroll down half-page, keep cursor centered |
| `<C-u>` | n | Scroll up half-page, keep cursor centered |
| `n` | n | Next search result, centered |
| `N` | n | Previous search result, centered |
| `J` | n | Join line below, keep cursor position |
| `<C-k>` | n | Next quickfix item |
| `<C-j>` | n | Previous quickfix item |
| `<leader>k` | n | Next loclist item |
| `<leader>j` | n | Previous loclist item |

## Editing

| Key | Mode | Action |
|---|---|---|
| `J` | v | Move selected lines down |
| `K` | v | Move selected lines up |
| `<leader>p` | x | Paste over selection without losing clipboard |
| `<leader>y` | n/v | Copy to system clipboard |
| `<leader>Y` | n | Copy line to system clipboard |
| `<leader>d` | n/v | Delete without copying to clipboard |
| `<leader>s` | n | Replace word under cursor (global, interactive) |
| `<C-c>` | i | Exit insert mode (alias for `<Esc>`) |

## File & Session

| Key | Mode | Action |
|---|---|---|
| `<C-s>` | n | Save file |
| `<C-s>` | i | Save file and exit insert mode |
| `<C-q>` | n | Close buffer |
| `<C-qa>` | n | Close all buffers |
| `<leader>pv` | n | Open netrw file explorer |
| `<leader>sp` | n | Show current file path |
| `<leader>x` | n | Make current file executable (`chmod +x`) |
| `<leader>f` | n | Format file (LSP) |
| `<leader><leader>` | n | Source current file (`:so`) |
| `<C-f>` | n | Open tmux sessionizer |
| `Q` | n | Disabled (prevents accidental ex mode) |

## Config Quick-open

| Key | Action |
|---|---|
| `<leader>vpp` | Edit `lua/default/plugins.lua` |
| `<leader>vkm` | Edit `lua/default/remap.lua` |
| `<leader>vtk` | Edit `after/plugin/telescope.lua` |
