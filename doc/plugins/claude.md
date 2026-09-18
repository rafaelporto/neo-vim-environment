# Claude Code

Configuration is **inline in the lazy spec** in `lua/default/plugins.lua`, not in
`after/plugin/`. There is no `after/plugin/claude.lua` — an eager `require()` there would undo
the lazy-loading the spec sets up (same reasoning as flutter-tools; see
[CLAUDE.md](../../CLAUDE.md) under *What must not load at startup*).

## Concept

[coder/claudecode.nvim](https://github.com/coder/claudecode.nvim) reimplements the Claude Code
IDE protocol in Lua: a WebSocket server plus a lockfile under `~/.claude/ide/<port>.lock`. The
CLI discovers the lockfile and connects with `/ide`.

What that buys: Claude's edits arrive as a **diff in Neovim**, reviewable and editable before
anything reaches disk, instead of being written behind your back.

`terminal = { provider = "none" }` keeps the CLI where it already is — a tmux pane next door.
No nested terminal inside Neovim, and no new dependency: `snacks.nvim` is only required by the
`snacks` provider.

## Keymaps

| Key | Mode | Action |
|---|---|---|
| `<leader>Cc` | n | Start the server |
| `<leader>Cx` | n | Stop the server |
| `<leader>Ci` | n | Connection status |
| `<leader>Cs` | v | Send the selection |
| `<leader>Ca` | n | Add the current file |
| `<leader>Cy` | n | Accept the diff |
| `<leader>Cn` | n | Reject the diff |

The eleven non-terminal `:ClaudeCode*` commands are declared in `cmd` and work the same way.

## Usage

```
<leader>Cc          server up, lockfile written
/ide  (in the CLI)  → "Connected to Neovim"
```

## `<C-s>` is disarmed inside the diff

`<C-s>` is `:w` in `remap.lua`, and inside Claude's diff `:w` means **accept**. The reflex to
save would approve a suggestion without reading it, so a `ClaudeCodeDiffOpened` autocmd
replaces `<C-s>` in the diff buffers with a notification pointing at `<leader>Cy` /
`<leader>Cn`.

> A matching `ClaudeCodeDiffClosed` autocmd deletes those maps. It is not optional: one of the
> diff windows holds the **real file's** buffer, and a buffer-local map does not die with the
> diff — without the cleanup, `<C-s>` stays disarmed in that file for the rest of the session.

## Loading

`cmd` + `keys`, and deliberately **no** `event`. The plugin defaults to `auto_start`, so
`setup()` opens the server and writes the lockfile; loading it eagerly meant one listening
WebSocket per Neovim session regardless of whether Claude Code was used. Both handlers are
needed — `keys` alone leaves the `:ClaudeCode*` commands undefined until a key is pressed, and
`cmd` alone would miss the visual-mode `<leader>Cs`.

The four terminal commands (`ClaudeCode`, `ClaudeCodeOpen`, `ClaudeCodeFocus`,
`ClaudeCodeClose`) are left out of `cmd` on purpose: `provider = "none"` makes them inert.
