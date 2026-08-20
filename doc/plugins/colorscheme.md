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

| Theme | Plugin | `setup()` |
|---|---|---|
| `dracula` | `dracula/vim` | not needed |
| `tokyonight-day` | `folke/tokyonight.nvim` | not needed |
| `catppuccin` | `catppuccin/nvim` | `transparent_background = true`, on selection |
| `github_dark` / `github_light` | `projekt0n/github-nvim-theme` | `options.transparent = true`, on selection |
| `rose-pine` | `rose-pine/neovim` | not needed |
| `darcula` | `doums/darcula` | not needed |

## Theme setup runs on demand

`colors.lua` holds a `theme_setup` table keyed by colorscheme name. `ColorMyPencils(color)` looks the name up, runs the entry if there is one, and only then calls `vim.cmd.colorscheme`.

Before, `require("github-theme").setup()` and `require("catppuccin").setup()` ran unconditionally at file level — two theme plugins configured in every session even though the time-based branch only ever passes `dracula` or `tokyonight-day`. Switching manually still applies their options, because the lookup happens inside `ColorMyPencils`.

> Themes with no entry need no configuration; `vim.cmd.colorscheme` is enough for them. Note that `<leader>sC` (`:Telescope colorscheme`) applies a scheme directly and does **not** go through `ColorMyPencils`, so previewing `catppuccin` or `github_*` that way shows them without their transparency options. Use `:lua ColorMyPencils("catppuccin")` to get the configured version.

## Lualine

Lualine uses `theme = "auto"`, which tracks the active colorscheme automatically. Active LSP clients are shown in `lualine_y`.
