# Telescope

Configuration in `after/plugin/telescope.lua`.

## Extensions loaded

- `ui-select` — dropdown theme for pickers (code actions, etc.)
- `dap` — telescope-dap integration
- `noice` — search noice message history

## Trouble integration

`<C-t>` inside any picker (insert or normal mode) sends results to Trouble instead of the quickfix list.

## Keymaps

### Files

| Key | Action |
|---|---|
| `<leader>pf` | Find files |
| `<leader>sF` | Find all files (hidden + no-ignore) |
| `<C-p>` | Git files |
| `<leader>sB` | File browser |
| `<leader>so` | Recent files |

### Search

| Key | Action |
|---|---|
| `<leader>sg` | Live grep |
| `<leader>sG` | Live grep everything (hidden + no-ignore) |
| `<leader>ps` | Grep for typed string |
| `<leader>sc` | Fuzzy find in current buffer |

### Buffers & State

| Key | Action |
|---|---|
| `<leader>sb` | Open buffers |
| `<leader>sr` | Registers |
| `<leader>sR` | Resume last picker |
| `<leader>sm` | Marks |
| `<leader>sj` | Jump list |
| `<leader>sqf` | Quickfix list |

### LSP

| Key | Action |
|---|---|
| `<leader>gd` | Definitions |
| `<leader>gD` | Type definitions |
| `<leader>gi` | Implementations |
| `<leader>gr` | References |
| `<leader>sd` | Diagnostics |
| `<leader>stl` | Treesitter symbols |

### Git

| Key | Action |
|---|---|
| `<leader>gs` | Git status (overrides fugitive `<leader>gs`) |
| `<leader>gb` | Git branches |
| `<leader>gS` | Git stash |

### Misc

| Key | Action |
|---|---|
| `<leader>sh` | Help tags |
| `<leader>sk` | Keymaps |
| `<leader>sC` | Colorschemes with preview |
| `<leader>sP` | Projects |
| `<leader>st` | All Telescope pickers |
| `<leader>sT` | All Telescope cached pickers |

> **Conflict note:** `<leader>gs` is set by both `fugitive.lua` (`:Git`) and `telescope.lua` (`git_status`). Since `after/plugin/` files are sourced alphabetically, `telescope.lua` loads after `fugitive.lua` and wins. Use `:Git` directly to open the Fugitive dashboard.
