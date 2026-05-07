# neo-vim-environment

Personal Neovim configuration targeting **nvim 0.11+**, with full LSP, DAP, tree-sitter, and multi-language support.

## Requirements

- Neovim 0.11+
- Git
- A [Nerd Font](https://www.nerdfonts.com/) (for icons in the statusline and diagnostics)
- Language-specific external tools (formatters, linters) installed via Mason inside Neovim

## Install

```sh
git clone https://github.com/rafaelporto/neo-vim-environment.git ~/.config/nvim
```

On first launch, [lazy.nvim](https://github.com/folke/lazy.nvim) bootstraps itself and installs all plugins automatically.

## Structure

| Purpose | Path |
|---|---|
| Entry point | `init.lua` |
| Vim options | `lua/default/set.lua` |
| Keybindings | `lua/default/remap.lua` |
| Plugin manager bootstrap | `lua/default/lazy.lua` |
| Plugin specs | `lua/default/plugins.lua` |
| Plugin configs | `after/plugin/<name>.lua` |
| Snippets | `snippets/` |

## Keybindings

**Leader:** `Space` — **Local leader:** `,`

### Navigation

| Key | Action |
|---|---|
| `<leader>pv` | File explorer |
| `<C-f>` | Open tmux-sessionizer |
| `<C-d>` / `<C-u>` | Scroll and center |
| `n` / `N` | Next/prev search result (centered) |

### Telescope (fuzzy finder)

| Key | Action |
|---|---|
| `<leader>pf` | Find files |
| `<leader>sg` | Live grep |
| `<C-p>` | Git files |
| `<leader>sb` | Open buffers |
| `<leader>gd` | LSP definitions |
| `<leader>gi` | LSP implementations |
| `<leader>gr` | LSP references |
| `<leader>gb` | Git branches |
| `<leader>gs` | Git status |

### Harpoon (quick marks)

| Key | Action |
|---|---|
| `<leader>a` | Add file to harpoon |
| `<C-e>` | Toggle harpoon menu |
| `<C-h/j/k/l>` | Jump to mark 1–4 |

### LSP

| Key | Action |
|---|---|
| `K` | Hover docs |
| `gd` | Go to definition |
| `gi` | Go to implementation |
| `gr` | References |
| `<leader>rn` | Rename symbol |
| `<leader>ca` | Code actions |
| `<leader>f` | Format file |
| `[d` / `]d` | Prev/next diagnostic |
| `<leader>e` | Show diagnostic float |

### Editing

| Key | Action |
|---|---|
| `J` / `K` (visual) | Move selection up/down |
| `<leader>p` (visual) | Paste without yanking |
| `<leader>y` / `<leader>Y` | Yank to system clipboard |
| `<leader>s` | Replace word under cursor (global) |
| `<leader>x` | Make file executable |

### Buffers & Quickfix

| Key | Action |
|---|---|
| `<C-s>` | Save |
| `<C-q>` | Close buffer |
| `<C-k>` / `<C-j>` | Quickfix next/prev |
| `<leader>k` / `<leader>j` | Loclist next/prev |

### Config shortcuts

| Key | Action |
|---|---|
| `<leader>vpp` | Edit `plugins.lua` |
| `<leader>vkm` | Edit `remap.lua` |
| `<leader>vtk` | Edit `telescope.lua` |
| `<leader><leader>` | Reload current file (`:so`) |
| `<leader>sp` | Show current file path |

## Language Support

| Language | LSP | Tools |
|---|---|---|
| Clojure | `clojure_lsp` | conjure (REPL), vim-jack-in, nvim-paredit, rainbow-delimiters |
| Swift / iOS | `sourcekit-lsp` | xcodebuild.nvim, swiftformat, swiftlint, codelldb (DAP) |
| Scala | nvim-metals | Full metals integration |
| C# | `roslyn` (seblj/roslyn.nvim) | csharpier (formatting), netcoredbg (DAP) |
| TypeScript / JS | `ts_ls`, `eslint` | — |
| Go | `gopls` | — |
| Lua | `lua_ls` | Neovim API workspace aware |
| JSON | `jsonls` | schemastore.nvim validation |
| YAML | `yamlls` | schemastore.nvim validation |
| Docker | `dockerls` | — |

LSP servers are installed via **Mason** (`:Mason`).

> **Roslyn (C#) requires manual installation:** run `:MasonInstall roslyn` inside Neovim after first launch. The `seblj/roslyn.nvim` plugin manages the LSP lifecycle but does not auto-download the server binary. See the [nvim-lspconfig docs](https://github.com/neovim/nvim-lspconfig/blob/master/doc/configs.md#roslyn_ls) for details.

## Colorscheme

The theme switches automatically based on time of day:

- **Before 8am / after 5pm** → [Dracula](https://github.com/dracula/vim)
- **8am – 5pm** → [Tokyo Night Day](https://github.com/folke/tokyonight.nvim)

Other available themes: `catppuccin`, `rose-pine`, `github-theme`, `darcula`. Change manually with `:colorscheme <name>` or by calling `ColorMyPencils("<name>")`.

## Completion

Powered by `nvim-cmp` + `LuaSnip`:

| Key | Action |
|---|---|
| `<C-Space>` | Trigger completion |
| `<C-n>` / `<C-p>` | Next/prev item |
| `<CR>` | Confirm selection |
| `<C-e>` | Abort |
| `<C-f>` / `<C-b>` | Scroll snippet forward/back |

## Swift / iOS Development

Full Xcode integration via `xcodebuild.nvim`. On first use, the plugin will prompt you to select a scheme and device — the selection is saved per project.

### Build & Run

| Key | Action |
|---|---|
| `<leader>X` | Menu with all Xcodebuild actions |
| `<leader>xf` | Project Manager |
| `<leader>xb` | Build |
| `<leader>xB` | Build for testing |
| `<leader>xr` | Build & Run on simulator/device |
| `<leader>xd` | Select device / simulator |
| `<leader>xp` | Select test plan |
| `<leader>xl` | Toggle build logs |
| `<leader>xq` | Show quickfix list |
| `<leader>xx` | Quickfix current line |
| `<leader>xa` | Code actions |

### Tests & Coverage

| Key | Action |
|---|---|
| `<leader>xt` | Run all tests |
| `<leader>xt` (visual) | Run selected tests |
| `<leader>xT` | Run tests in current class |
| `<leader>x.` | Repeat last test run |
| `<leader>xe` | Toggle Test Explorer |
| `<leader>xc` | Toggle code coverage |
| `<leader>xC` | Show code coverage report |
| `<leader>xs` | Show failing snapshots |

### Formatting & Linting

- **swiftformat** runs automatically on save
- **swiftlint** runs on save and on leaving insert mode (`<leader>ml` to run manually)

### Debugging (DAP)

Requires `codelldb` — install once with `:MasonInstall codelldb`.

**Workflow:**

1. Start the app on the simulator with `<leader>xr`
2. Set a breakpoint with `F9`
3. Press `F5` — codelldb attaches to the running process automatically
4. The DAP UI opens with scopes, call stack, breakpoints, and console

| Key | Action |
|---|---|
| `F9` | Toggle breakpoint |
| `F5` | Start / continue |
| `F10` | Step over |
| `F11` | Step into |
| `Shift+F11` | Step out |
| `Shift+F5` | Stop debug session |
| `<leader>du` | Toggle DAP UI |
| `<leader>duc` | Close DAP UI |

## Clojure Development

| Tool | Purpose |
|---|---|
| conjure | Interactive REPL evaluation (local leader `,`) |
| vim-jack-in | Start nREPL from Neovim |
| nvim-paredit | Structural editing (slurp/barf) |
| cmp-conjure | REPL-aware completions |

## Debugging

DAP (Debug Adapter Protocol) via `nvim-dap` + `nvim-dap-ui`. Telescope integration for browsing breakpoints and frames (`:Telescope dap ...`).
