# Global Keymaps

Defined in `lua/default/remap.lua`. Active in all buffers regardless of filetype or LSP state.

- Leader: `<Space>`
- Local leader: `,` — **currently unused.** It was conjure's prefix in Clojure buffers; Clojure support has been removed, but `maplocalleader` is still set so any future plugin picks up a sane value.

## Namespaces

| Prefix | Owner |
|---|---|
| `<leader>a` | Diagnostics lists (`lsp.lua`, `trouble.lua`) |
| `<leader>A` | Harpoon add file — a complete mapping, not a prefix |
| `<leader>c` | Code actions and `chmod +x` |
| `<leader>d` | Delete without yank (`remap.lua`) — an **operator**, nothing else may live under it |
| `<leader>D` | DAP UI (`Du`, `Dc`) |
| `<leader>e` | File tree (neo-tree) |
| `<leader>f` | Format (conform) |
| `<leader>F` | Flutter (Dart buffers only) |
| `<leader>g` | Git and LSP goto (Telescope) |
| `<leader>l` | LSP toggles (`lh`, `lc`, `lu`) |
| `<leader>m` | Lint (`ml`) |
| `<leader>n` | Noice |
| `<leader>p` | Find files, previews, paste |
| `<leader>s` | Telescope search |
| `<leader>t` | Tests (neotest) |
| `<leader>v` | LSP symbols and config quick-open |
| `<leader>x` | Xcodebuild — **buffer-local to Swift/ObjC buffers**, where the plugin is the only place it loads |

> Every prefix above is registered as a which-key group, so pressing one shows its continuations with their descriptions. `timeoutlen` was left at its default on purpose — see [which-key.md](which-key.md).

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
| `<leader>cx` | n | Make current file executable (`chmod +x`) |
| `<leader><leader>` | n | Source current file (`:so`) |
| `<C-f>` | n | Open tmux sessionizer |
| `Q` | n | Disabled (prevents accidental ex mode) |

## Config Quick-open

| Key | Action |
|---|---|
| `<leader>vpp` | Edit `lua/default/plugins.lua` |
| `<leader>vkm` | Edit `lua/default/remap.lua` |
| `<leader>vtk` | Edit `after/plugin/telescope.lua` |

## Testing — `<leader>t` (neotest)

Set in `after/plugin/neotest.lua`. Full detail in [neotest.md](neotest.md).

| Key | Action |
|---|---|
| `<leader>tt` | Run nearest test |
| `<leader>tf` | Run current file |
| `<leader>ta` | Run whole suite |
| `<leader>tD` | Debug nearest test |
| `<leader>tl` | Re-run last |
| `<leader>tS` | Stop run |
| `<leader>ts` | Toggle summary panel |
| `<leader>to` | Open output for the nearest test |
| `<leader>tp` | Toggle output panel |
| `<leader>tw` | Toggle watch mode for the current file |
| `]n` / `[n` | Next / previous failed test |

> `<leader>td` belongs to `todo-comment.lua` (`:TodoTelescope`), which is sourced after `neotest.lua`, so neotest's debug map uses `<leader>tD` instead.

## LSP additions

Set in `after/plugin/lsp.lua` on `LspAttach`, both gated on client capability. Full list in [lsp-core.md](lsp-core.md).

| Key | Action |
|---|---|
| `<leader>lh` | Toggle inlay hints (enabled on attach) |
| `<leader>lc` | Run code lens |
| `<leader>ad` | Buffer diagnostics → loclist |

## Diagnostics lists — `<leader>a`

| Key | Owner | Action |
|---|---|---|
| `<leader>aa` | `lsp.lua` | All diagnostics → quickfix |
| `<leader>ae` | `lsp.lua` | Workspace errors → quickfix |
| `<leader>aw` | `lsp.lua` | Workspace warnings → quickfix |
| `<leader>ad` | `lsp.lua` | Buffer diagnostics → loclist |
| `<leader>aq` | `trouble.lua` | `Trouble quickfix toggle` |

> Harpoon's add-file used to be a bare `<leader>a` here. Because the five maps above use it as a prefix, it only fired after `timeoutlen`; it moved to `<leader>A` — see [harpoon.md](harpoon.md).

## Recent moves and why

| Was | Is | Reason |
|---|---|---|
| `<leader>d` (buffer diagnostics → loclist) | `<leader>ad` | The buffer-local LSP map shadowed the global delete-without-yank, breaking `<leader>dd` and `<leader>dw` in every buffer with an LSP attached |
| `<leader>x` (`chmod +x`) | `<leader>cx` | `<leader>x` is the prefix of the 19 xcodebuild maps, so each of them paid `timeoutlen` waiting to see whether the sequence ended here. `<leader>c` only had `ca` |
| `<leader>xq` (`TroubleToggle quickfix`) | `<leader>aq` (`Trouble quickfix toggle`) | v2 command syntax against the installed v3, and it overwrote xcodebuild's working `<leader>xq`. See [trouble.md](trouble.md) |
| `<leader>f` → `vim.lsp.buf.format` | `<leader>f` → `conform.format` | Formatting has a single owner now. The mapping moved out of `remap.lua` into `after/plugin/formatting.lua`, and it works in visual mode too. See [formatting.md](formatting.md) |
| 19 xcodebuild maps, global | 19 xcodebuild maps, buffer-local | They were global by accident — `swift-config.lua` built an `opts` table with `buffer = bufnr` and never passed it, so a single sourcekit attach defined them everywhere |
| `<leader>du` / `<leader>duc` (DAP UI) | `<leader>Du` / `<leader>Dc` | `<leader>d` is the delete-without-yank **operator**. While a `<leader>du` existed, every `<leader>dw` / `<leader>dip` / `<leader>d}` paid `timeoutlen` waiting to see whether a `u` followed. The capital follows `<leader>F` (Flutter) and `<leader>X` (xcodebuild). See [dap-core.md](dap-core.md) |
| `<leader>a` (harpoon add file) | `<leader>A` | `<leader>a` is the diagnostics namespace (`aa` / `ad` / `ae` / `aq` / `aw`), so a complete `<leader>a` paid `timeoutlen` on every add — on one of the most frequent actions there is. `<C-e>` and `<leader>1`–`<leader>4` are unchanged. See [harpoon.md](harpoon.md) |

> The pattern in the last two rows is the same one: a **complete** mapping that is also the **prefix** of others costs `timeoutlen` every single time. Moving it to a capital is cheaper than lowering `timeoutlen` globally, and which-key removes the reason people lower it in the first place.
