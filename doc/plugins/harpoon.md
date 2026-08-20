# Harpoon

Configuration in `after/plugin/harpoon.lua`.

## Concept

Harpoon maintains a per-project list of file marks (up to 4 slots). Marks persist across sessions. Navigating to a marked file is instant — no fuzzy search needed.

## Keymaps

| Key | Action |
|---|---|
| `<leader>A` | Add current file to harpoon list |
| `<C-e>` | Toggle harpoon quick menu |
| `<leader>1` | Jump to mark slot 1 |
| `<leader>2` | Jump to mark slot 2 |
| `<leader>3` | Jump to mark slot 3 |
| `<leader>4` | Jump to mark slot 4 |

> **Note:** `<C-e>` also closes the nvim-cmp completion menu (abort), but cmp is only active in insert mode while harpoon uses normal mode — no conflict.

> **Why `<leader>A` and not `<leader>a`.** `<leader>a` is the diagnostics namespace (`aa`, `ad`, `ae`, `aq`, `aw` — see [keymaps.md](keymaps.md)), so a complete `<leader>a` mapping was also a prefix: adding a file worked, but only after `timeoutlen` had elapsed, on an action you perform constantly. The capital follows the `<leader>F` (Flutter) and `<leader>X` (xcodebuild) convention. Only the add key moved — `<C-e>` and `<leader>1`–`<leader>4` are unchanged.
