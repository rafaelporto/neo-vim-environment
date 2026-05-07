# Actions Preview

Configuration in `after/plugin/actions-preview.lua`.

## Purpose

Replaces the default `vim.lsp.buf.code_action()` picker with a richer preview UI that shows a diff of each action before applying it.

## Keymaps

| Key | Mode | Action |
|---|---|---|
| `<leader>ca` | n / v | Open code actions with preview |

> **Conflict note:** `nvim-metals.lua` also sets `<leader>ca` buffer-locally in its `on_attach`. The metals binding (plain `vim.lsp.buf.code_action()`) wins in Scala buffers. In all other languages, actions-preview is used.
