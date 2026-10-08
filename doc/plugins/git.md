# Git

Configuration in `after/plugin/fugitive.lua`.

## vim-fugitive

| Key | Action |
|---|---|
| `<leader>gs` | Open Fugitive dashboard (`:Git`) |

> **Conflict note:** `<leader>gs` is also bound by `telescope.lua` to `builtin.git_status`. Since `after/plugin/` files are sourced alphabetically, `telescope.lua` loads after `fugitive.lua` and **wins**. The effective binding is Telescope git status. To open the full Fugitive dashboard, run `:Git` directly.

## Common Fugitive commands

| Command | Action |
|---|---|
| `:Git` | Open interactive git dashboard |
| `:Git commit` | Commit staged changes |
| `:Git push` | Push to remote |
| `:Git diff` | View diff |
| `:GBrowse` | Open file on GitHub |
| `:GBlame` | Toggle git blame |

## `:DiffTool` — built into nvim 0.12

nvim 0.12 ships a `difftool` plugin: `:DiffTool {left} {right}` opens a diff of two files **or two
directories** (`:h difftool`). No `:packadd` needed.

It does not overlap with fugitive — it knows nothing about git, revisions or the index. It is useful
next to it: comparing a worktree against an export, or two checkouts of the same tree. `:Git diff`
stays the tool for anything revision-aware.
