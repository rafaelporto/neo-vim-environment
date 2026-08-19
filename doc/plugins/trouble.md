# Trouble

Configuration in `after/plugin/trouble.lua`. Version 3.

## Purpose

Trouble provides a structured list view for diagnostics, quickfix, LSP references, and telescope results — replacing the default quickfix window.

## setup() is required

`trouble.setup({})` was never called. `setup()` is what creates the `:Trouble` command (`trouble/config/init.lua:242`), so any `<cmd>Trouble ...<cr>` mapping died with `E492: Not an editor command`. The omission went unnoticed because the Lua API used by the Xcodebuild autocmd below works fine without it. It is now called.

## Telescope integration

`<C-t>` inside any Telescope picker (insert or normal mode) sends the results to Trouble instead of the quickfix list.

## Xcodebuild integration

After each build or test run, an autocmd on `XcodebuildBuildFinished` / `XcodebuildTestsFinished` fires (cancelled runs are ignored):
- **Success** → Trouble closes automatically
- **Failure** → Trouble opens with the quickfix list if it has entries, then refreshes; otherwise it closes

This uses the Lua API (`trouble.open`, `trouble.close`, `trouble.refresh`) and is unchanged.

## Keymaps

| Key | Action |
|---|---|
| `<leader>aq` | `Trouble quickfix toggle` |

> **Two bugs, one move.** The mapping used to be `<leader>xq` → `TroubleToggle quickfix`: v2 syntax, and the installed v3 has no `TroubleToggle` command at all (it appears in no file of the plugin). Worse, `trouble.lua` is sourced *after* `swift-config.lua` alphabetically, so that broken mapping overwrote xcodebuild's working `<cmd>Telescope quickfix<cr>` on `<leader>xq`. Moving it to the `<leader>a` diagnostics namespace gives `<leader>xq` back to xcodebuild and puts it next to `<leader>aa` / `<leader>ae` / `<leader>aw` / `<leader>ad`.
