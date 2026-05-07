# Copilot

Configuration in `after/plugin/copilot.lua` and `lua/default/set.lua`.

## Setup

- Always loaded (`lazy = false`)
- Tab key is **disabled** for Copilot (`copilot_no_tab_map = true`, `copilot_assume_mapped = true`)
- Suggestions appear inline as virtual text

## Keymaps

| Key | Mode | Action |
|---|---|---|
| `<C-j>` | insert | Accept Copilot suggestion |

## Why `replace_keycodes = false`

The accept mapping uses `expr = true` to call `copilot#Accept("\\<CR>")`. Without `replace_keycodes = false`, Neovim would expand `<CR>` in the returned string, causing a literal newline instead of triggering the accept function.
