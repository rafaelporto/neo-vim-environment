# neo-vim-environment

Personal Neovim configuration for **nvim 0.12+**. Uses `lazy.nvim` for plugin management and the native LSP API (`vim.lsp.config` / `vim.lsp.enable`). Primary language is Go; also supports Swift/iOS, Dart/Flutter, TypeScript/JS, C# and more.

## Requirements

- Neovim 0.12+
- Git
- [Nerd Font](https://www.nerdfonts.com/) — icons in statusline and diagnostics
- A C compiler, `curl` and `tar` — needed to build treesitter parsers
- [`tree-sitter-cli`](https://github.com/tree-sitter/tree-sitter) 0.26.1+ (`brew install tree-sitter-cli`) — **required**; nvim 0.12 ships only 7 parsers, the rest are built by `nvim-treesitter`
- External tools (formatters, linters, debug adapters) installed via `:Mason` inside Neovim

## Install

```sh
git clone https://github.com/rafaelporto/neo-vim-environment.git ~/.config/nvim
```

On first launch, [lazy.nvim](https://github.com/folke/lazy.nvim) bootstraps itself and installs all plugins automatically.

LSP servers install themselves via Mason. The remaining tools are manual:

```vim
:MasonInstall gopls delve golangci-lint gofumpt goimports vtsls js-debug-adapter stylua
:MasonInstall roslyn
```

```sh
brew install tree-sitter-cli editorconfig-checker
brew install swiftformat swiftlint            # Swift, optional
go install gotest.tools/gotestsum@latest      # test runner for Go
npm i -D prettier                             # per project, never global
```

> **Roslyn (C#):** must be installed manually — `seblj/roslyn.nvim` manages the LSP lifecycle but expects the binary to already exist.
> **Flutter/Dart:** `dartls` ships with the Flutter SDK. The SDK is discovered automatically (PATH → project `.fvm` → common paths), so no path needs editing.
> A missing formatter is never an error: conform marks it unavailable and either falls back to the language server or leaves the buffer alone.

## Plugins

### UI & Navigation

| Plugin | Purpose |
|---|---|
| [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Statusline with LSP clients, branch, diagnostics |
| [folke/noice.nvim](https://github.com/folke/noice.nvim) | Command palette, LSP doc borders, notification routing |
| [rcarriga/nvim-notify](https://github.com/rcarriga/nvim-notify) | Notification backend for noice |
| [folke/which-key.nvim](https://github.com/folke/which-key.nvim) | Popup showing what can follow a key prefix |
| [nvim-neo-tree/neo-tree.nvim](https://github.com/nvim-neo-tree/neo-tree.nvim) | File explorer (`<leader>e`) |
| [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) | Fuzzy finder — files, grep, LSP, git, DAP |
| [nvim-telescope/telescope-ui-select.nvim](https://github.com/nvim-telescope/telescope-ui-select.nvim) | Dropdown picker for code actions and selects |
| [ThePrimeagen/harpoon](https://github.com/ThePrimeagen/harpoon) | Per-project file marks with instant navigation |
| [folke/trouble.nvim](https://github.com/folke/trouble.nvim) | Diagnostics list, quickfix, LSP results |
| [rmagatti/goto-preview](https://github.com/rmagatti/goto-preview) | LSP peek in floating windows |
| [mbbill/undotree](https://github.com/mbbill/undotree) | Visual undo history (`<leader>u`) |
| [iamcco/markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim) | Live Markdown preview in browser |

### LSP & Completion

| Plugin | Purpose |
|---|---|
| [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim) | LSP server / tool installer |
| [williamboman/mason-lspconfig.nvim](https://github.com/williamboman/mason-lspconfig.nvim) | Auto-install servers via Mason |
| [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig) | Bundled LSP server definitions (cmd, filetypes, root markers) |
| [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp) | Completion engine |
| [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip) | Snippet engine (VSCode + SnipMate formats) |
| [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets) | Community snippet collection |
| [ray-x/lsp_signature.nvim](https://github.com/ray-x/lsp_signature.nvim) | Signature help while typing |
| [aznhe21/actions-preview.nvim](https://github.com/aznhe21/actions-preview.nvim) | Rich preview for code actions (`<leader>ca`) |
| [b0o/schemastore.nvim](https://github.com/b0o/schemastore.nvim) | JSON/YAML schema validation via SchemaStore |
| [nvimtools/none-ls.nvim](https://github.com/nvimtools/none-ls.nvim) | One source only: `editorconfig_checker` |
| [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim) | Format-on-save for every language — sole owner, see [doc/plugins/formatting.md](doc/plugins/formatting.md) |
| [mfussenegger/nvim-lint](https://github.com/mfussenegger/nvim-lint) | Async linting (Swift, Go) |

### Debugging (DAP)

| Plugin | Purpose |
|---|---|
| [mfussenegger/nvim-dap](https://github.com/mfussenegger/nvim-dap) | Debug Adapter Protocol core |
| [rcarriga/nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) | DAP UI (scopes, watches, console, REPL) |
| [theHamsta/nvim-dap-virtual-text](https://github.com/theHamsta/nvim-dap-virtual-text) | Inline variable values during debug |
| [nvim-telescope/telescope-dap.nvim](https://github.com/nvim-telescope/telescope-dap.nvim) | Telescope integration for DAP |

Adapters live one-per-language: `after/plugin/dap-go.lua` (delve), `after/plugin/dap-js.lua` (js-debug-adapter), `after/plugin/dap-dotnet.lua` (netcoredbg), `after/plugin/dap-swift.lua` (xcodebuild). None of the DAP stack loads at startup — `lua/default/dap.lua` initialises it on the first `F5`/`F9`. See [doc/plugins/dap-core.md](doc/plugins/dap-core.md).

### Testing

| Plugin | Purpose |
|---|---|
| [nvim-neotest/neotest](https://github.com/nvim-neotest/neotest) | Test runner framework — `<leader>t` namespace |
| [fredrikaverpil/neotest-golang](https://github.com/fredrikaverpil/neotest-golang) | Go tests via gotestsum, debug single test |
| [marilari88/neotest-vitest](https://github.com/marilari88/neotest-vitest) | Vitest |
| [nvim-neotest/neotest-jest](https://github.com/nvim-neotest/neotest-jest) | Jest |
| [sidlatau/neotest-dart](https://github.com/sidlatau/neotest-dart) | Dart / Flutter tests |
| [Issafalcon/neotest-dotnet](https://github.com/Issafalcon/neotest-dotnet) | C# tests |

See [doc/plugins/neotest.md](doc/plugins/neotest.md).

### Git

| Plugin | Purpose |
|---|---|
| [tpope/vim-fugitive](https://github.com/tpope/vim-fugitive) | Git integration (`:Git`, `<leader>gs`) |

### Editing

| Plugin | Purpose |
|---|---|
| [github/copilot.vim](https://github.com/github/copilot.vim) | AI completions (`<C-j>` to accept) |
| [numToStr/Comment.nvim](https://github.com/numToStr/Comment.nvim) | Toggle comments (`gcc`, `gc`) |
| [tpope/vim-surround](https://github.com/tpope/vim-surround) | Surround motions (`ys`, `cs`, `ds`) |
| [folke/todo-comments.nvim](https://github.com/folke/todo-comments.nvim) | Highlight and navigate TODO/FIXME/etc |
| [RRethy/vim-illuminate](https://github.com/RRethy/vim-illuminate) | Highlight all occurrences of word under cursor |
| [HiPhish/rainbow-delimiters.nvim](https://github.com/HiPhish/rainbow-delimiters.nvim) | Rainbow bracket coloring |
| [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) | Parser installer + queries (branch `main`); highlighting is done by nvim itself |
| [windwp/nvim-ts-autotag](https://github.com/windwp/nvim-ts-autotag) | Auto-close and rename JSX/TSX/HTML tag pairs |

### Language-specific

| Plugin | Purpose |
|---|---|
| [seblj/roslyn.nvim](https://github.com/seblj/roslyn.nvim) | C# LSP via Roslyn |
| [wojciech-kulik/xcodebuild.nvim](https://github.com/wojciech-kulik/xcodebuild.nvim) | Xcode build/test/run/coverage integration |
| [akinsho/flutter-tools.nvim](https://github.com/akinsho/flutter-tools.nvim) | Dart/Flutter LSP, hot reload, DAP |

## Keymaps

Leader is `<space>`, and [which-key](https://github.com/folke/which-key.nvim) shows the available continuations after any prefix. Namespaces: `<leader>a` diagnostics · `<leader>A` Harpoon add · `<leader>c` code actions · `<leader>d` delete without yank · `<leader>D` DAP UI · `<leader>e` file tree · `<leader>f` format · `<leader>F` Flutter · `<leader>g` git · `<leader>l` LSP toggles · `<leader>m` lint · `<leader>t` tests · `<leader>v` LSP symbols · `<leader>x` xcodebuild (Swift buffers only).

Full list in [doc/plugins/keymaps.md](doc/plugins/keymaps.md).

## Docs

See [doc/](doc/) for per-plugin configuration guides and per-language setup + debug workflows.

- Languages: [go](doc/languages/go.md) · [typescript](doc/languages/typescript.md) · [dart-flutter](doc/languages/dart-flutter.md) · [swift](doc/languages/swift.md) · [csharp](doc/languages/csharp.md) · [lua](doc/languages/lua.md) · [json-yaml](doc/languages/json-yaml.md)
- Cross-cutting: [lsp-core](doc/plugins/lsp-core.md) · [formatting](doc/plugins/formatting.md) · [neotest](doc/plugins/neotest.md) · [dap-core](doc/plugins/dap-core.md) · [editing-tools](doc/plugins/editing-tools.md)
