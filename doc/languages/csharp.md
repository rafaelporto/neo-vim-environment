# C# (.NET)

Configuration in `after/plugin/roslyn.lua`, `after/plugin/dap-dotnet.lua`, `after/plugin/formatting.lua` (csharpier) and `after/plugin/neotest.lua` (tests).

## LSP

[seblj/roslyn.nvim](https://github.com/seblj/roslyn.nvim) manages the Roslyn language server lifecycle. The plugin registers its base config in `lsp/roslyn.lua` and calls `vim.lsp.enable("roslyn")` automatically.

> **Manual install required:** Run `:MasonInstall roslyn` inside Neovim once. The server binary must exist before the plugin activates.

Additional capabilities (snippet support) and `on_attach` are merged via:
```lua
vim.lsp.config("roslyn", { capabilities = ..., on_attach = ... })
```

Note the string-call form — not the bracket form used for other servers.

### Extra keymap (buffer-local)

| Key | Action |
|---|---|
| `<leader>gdr` | Telescope definitions (muscle-memory alias from old OmniSharp setup) |

All standard LSP keymaps also apply (see [lsp-core.md](../plugins/lsp-core.md)). Buffer diagnostics go to the loclist with `<leader>ad` — not `<leader>d`, which stayed the global delete-without-yank. `<leader>lh` (toggle inlay hints) and `<leader>lc` (run code lens) are created only when Roslyn advertises the matching capability.

## Formatting

`csharpier` via conform.nvim (`after/plugin/formatting.lua`) — runs on save and with `<leader>f`, which now calls `conform.format` instead of `vim.lsp.buf.format`.

The binary is not installed automatically; add it with `:MasonInstall csharpier` (or `dotnet tool install -g csharpier`). Without it, `lsp_format = "fallback"` lets Roslyn format the buffer instead.

## Debugging (DAP)

Uses `netcoredbg`. Install once with `:MasonInstall netcoredbg`.

### DAP Configurations

| Name | Request | Notes |
|---|---|---|
| Launch | `launch` | Prompts for path to `.dll`; defaults to `./bin/Debug/` |
| Attach | `attach` | Process picker — select the running dotnet process |

**Launch workflow:**
1. Build the project (`dotnet build`)
2. `F5` → select "Launch" → enter path to the built `.dll`
3. Set breakpoints with `F9`

**Attach workflow:**
1. Start the app (`dotnet run`)
2. `F5` → select "Attach" → pick the process from the list

### DAP keymaps (global)

| Key | Action |
|---|---|
| `F9` | Toggle breakpoint |
| `F5` | Continue / start |
| `F10` | Step over |
| `F11` | Step into |
| `Shift+F11` | Step out |
| `Shift+F5` | Stop |
| `<leader>du` | Toggle DAP UI |
| `<leader>duc` | Close DAP UI |

## Testing

`neotest-dotnet` (`Issafalcon/neotest-dotnet`) is registered in `after/plugin/neotest.lua` — `require("neotest").setup()` used never to be called anywhere, so the adapter was dead weight. It is registered bare (no call), like `neotest-vitest`.

| Key | Action |
|---|---|
| `<leader>tt` | Run nearest test |
| `<leader>tf` | Run current file |
| `<leader>ta` | Run whole suite |
| `<leader>tD` | Debug nearest test (via `netcoredbg`) |
| `<leader>tl` | Re-run last |
| `<leader>tS` | Stop run |
| `<leader>ts` | Toggle summary panel |
| `<leader>to` | Open output for the nearest test |
| `<leader>tp` | Toggle output panel |
| `<leader>tw` | Toggle watch mode for the file |
| `]n` / `[n` | Jump to next / previous failed test |
