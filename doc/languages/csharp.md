# C# (.NET)

Configuration in `after/plugin/roslyn.lua` and `after/plugin/dap-dotnet.lua`.

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

All standard LSP keymaps also apply (see [lsp-core.md](../plugins/lsp-core.md)).

## Formatting

`csharpier` via none-ls — runs with `<leader>f`.

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

`neotest-dotnet` is available as a neotest adapter (`Issafalcon/neotest-dotnet`) but has no keymaps configured yet.
