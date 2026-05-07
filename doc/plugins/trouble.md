# Trouble

Configuration in `after/plugin/trouble.lua`.

## Purpose

Trouble provides a structured list view for diagnostics, quickfix, LSP references, and telescope results — replacing the default quickfix window.

## Telescope integration

`<C-t>` inside any Telescope picker (insert or normal mode) sends the results to Trouble instead of the quickfix list.

## Xcodebuild integration

After each build or test run, an autocmd fires:
- **Success** → Trouble closes automatically
- **Failure** → Trouble opens with the quickfix list (if entries exist)

## Keymaps

| Key | Action |
|---|---|
| `<leader>xq` | Toggle Trouble quickfix |

> **Conflict note:** `<leader>xq` is set globally by `trouble.lua` and also buffer-locally by `swift-config.lua` (as Telescope quickfix inside Swift buffers). The buffer-local binding wins in Swift files.
