# Actions Preview

Configuration in `after/plugin/actions-preview.lua`.

## Purpose

Replaces the default `vim.lsp.buf.code_action()` picker with a richer preview UI that shows a diff of each action before applying it.

## Keymaps

| Key | Mode | Action |
|---|---|---|
| `<leader>ca` | n / v | Open code actions with preview |

> **Sole owner of `<leader>ca`.** `nvim-metals.lua` used to set the same key buffer-locally in its `on_attach`, so Scala buffers got the plain `vim.lsp.buf.code_action()` picker instead. Scala support has been removed, so actions-preview now answers `<leader>ca` in every language.
