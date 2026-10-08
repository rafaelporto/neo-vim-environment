# Noice & Notify

Configuration in `after/plugin/noice.lua`. Noice replaces the cmdline UI and routes messages; nvim-notify is its notification backend.

## Noice presets

| Preset | Effect |
|---|---|
| `bottom_search` | Classic bottom cmdline for `/` and `?` |
| `command_palette` | Cmdline and popup menu positioned together |
| `long_message_to_split` | Long messages go to a split instead of a popup |
| `lsp_doc_border` | Border on hover docs and signature help |

## Message routing

- Save ("written") messages are **silently suppressed** — no notification on `:w`.
- LSP markdown rendering is overridden to use Treesitter.

> The override key for that last one is `["vim.lsp.util.stylize_markdown"] = true`, and
> `vim.lsp.util.stylize_markdown()` was **deprecated in nvim 0.12** (replacement:
> `vim.treesitter.start()` with `conceallevel = 2`, which is what noice does anyway). This is a noice
> route name, not a call into the deprecated function, so nothing breaks today — but it is the key to
> revisit if noice ever stops rendering hover docs after an nvim upgrade.

## nvim-notify config

| Option | Value |
|---|---|
| Render | `compact` |
| Animation | `slide` |
| Timeout | 5 seconds |
| Position | top-down |
| Minimum width | 50 |

## Lualine integration

The noice command and search status are shown in `lualine_x` (orange text).

## Keymaps

| Key | Action |
|---|---|
| `<leader>nh` | Noice history |
| `<leader>nt` | Noice history in Telescope |
| `<leader>nl` | Show last message |
| `<leader>nc` | Dismiss current notification |
| `<leader>nd` | Disable Noice |
| `<leader>ne` | Enable Noice |
| `<leader>ner` | Show errors in a split |
| `<S-Enter>` (cmdline) | Redirect cmdline output to a split |
