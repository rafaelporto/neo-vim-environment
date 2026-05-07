# Colorscheme

Configuration in `after/plugin/colors.lua`.

## Time-based switching

The colorscheme switches automatically based on the hour at startup:

| Time | Colorscheme |
|---|---|
| Before 08:00 | `dracula` |
| 08:00 – 16:59 | `tokyonight-day` |
| 17:00 and after | `dracula` |

## Manual override

```vim
:lua ColorMyPencils("theme-name")
```

## Available themes

| Theme | Plugin |
|---|---|
| `dracula` | `dracula/vim` |
| `tokyonight-day` | `folke/tokyonight.nvim` |
| `catppuccin` | `catppuccin/nvim` (transparent background) |
| `github_dark` / `github_light` | `projekt0n/github-nvim-theme` (transparent) |
| `rose-pine` | `rose-pine/neovim` |
| `darcula` | `doums/darcula` |

## Lualine

Lualine uses `theme = "auto"`, which tracks the active colorscheme automatically. Active LSP clients are shown in `lualine_y`.
