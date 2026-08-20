# Telescope

Configuration in `after/plugin/telescope.lua`.

## Extensions

Loaded in `telescope.lua`, at startup:

- `ui-select` — dropdown theme for pickers (code actions, etc.)
- `noice` — search noice message history

Loaded on demand:

- `dap` — telescope-dap integration, loaded from `lua/default/dap.lua` when the DAP stack initialises

> **`load_extension("dap")` is not called here on purpose.** The extension pulls in telescope-dap, which does `require("dap")` at load — one line in a file that runs at startup was enough to bring nvim-dap, nvim-dap-ui, nvim-dap-virtual-text and nvim-nio into *every* session. It now loads inside `require("default.dap").ensure()`, so `:Telescope dap commands` / `configurations` / `list_breakpoints` / `variables` / `frames` become available once a debug session has been started — which is the only moment they are useful. See [dap-core.md](dap-core.md).

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

> `<leader>stl` needs a treesitter parser for the buffer's language. With only the 7 parsers nvim ships it worked almost nowhere; the parsers installed by `nvim-treesitter` (see [editing-tools.md](editing-tools.md)) cover 31 languages now.

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
