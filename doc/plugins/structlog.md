# Structlog

Configuration in `after/plugin/structlog.lua`.

## Purpose

Internal structured logging utility. Used by other plugins and integrations for debug output — not a user-facing feature.

## Pipelines

| Level | Sink | Format |
|---|---|---|
| INFO | Console (`:messages`) | `HH:MM:SS [INFO] logger: message` (colorized) |
| WARN | nvim-notify popup | Plain message text |
| TRACE | `./test.log` (CWD) | `HH:MM:SS [TRACE] logger: message` with stack frames |

> The TRACE sink writes to `./test.log` relative to the **current working directory** when Neovim starts. Check your CWD if you expect to find this file.
