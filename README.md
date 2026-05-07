# neo-vim-environment

Personal Neovim configuration for **nvim 0.11+**. Uses `lazy.nvim` for plugin management and the native LSP API (`vim.lsp.config` / `vim.lsp.enable`). Supports Clojure, Swift/iOS, Dart/Flutter, Scala, C#, Go, TypeScript, and more.

## Requirements

- Neovim 0.11+
- Git
- [Nerd Font](https://www.nerdfonts.com/) — icons in statusline and diagnostics
- External tools (formatters, linters, debug adapters) installed via `:Mason` inside Neovim

## Install

```sh
git clone https://github.com/rafaelporto/neo-vim-environment.git ~/.config/nvim
```

On first launch, [lazy.nvim](https://github.com/folke/lazy.nvim) bootstraps itself and installs all plugins automatically.

> **Roslyn (C#):** must be installed manually with `:MasonInstall roslyn` inside Neovim.
> **Flutter/Dart:** `dartls` ships with the Flutter SDK — no Mason install needed.

## Plugins

### UI & Navigation

| Plugin | Purpose |
|---|---|
| [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim) | Statusline with LSP clients, branch, diagnostics |
| [folke/noice.nvim](https://github.com/folke/noice.nvim) | Command palette, LSP doc borders, notification routing |
| [rcarriga/nvim-notify](https://github.com/rcarriga/nvim-notify) | Notification backend for noice |
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
| [nvimtools/none-ls.nvim](https://github.com/nvimtools/none-ls.nvim) | Formatters and linters as LSP sources |
| [stevearc/conform.nvim](https://github.com/stevearc/conform.nvim) | Format-on-save (Swift, Dart) |
| [mfussenegger/nvim-lint](https://github.com/mfussenegger/nvim-lint) | Async linting (Swift) |

### Debugging (DAP)

| Plugin | Purpose |
|---|---|
| [mfussenegger/nvim-dap](https://github.com/mfussenegger/nvim-dap) | Debug Adapter Protocol core |
| [rcarriga/nvim-dap-ui](https://github.com/rcarriga/nvim-dap-ui) | DAP UI (scopes, watches, console, REPL) |
| [theHamsta/nvim-dap-virtual-text](https://github.com/theHamsta/nvim-dap-virtual-text) | Inline variable values during debug |
| [nvim-telescope/telescope-dap.nvim](https://github.com/nvim-telescope/telescope-dap.nvim) | Telescope integration for DAP |
| [nvim-neotest/neotest](https://github.com/nvim-neotest/neotest) | Test runner framework |

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

### Language-specific

| Plugin | Purpose |
|---|---|
| [Olical/conjure](https://github.com/Olical/conjure) | Clojure REPL evaluation |
| [clojure-vim/vim-jack-in](https://github.com/clojure-vim/vim-jack-in) | Start nREPL from Neovim |
| [julienvincent/nvim-paredit](https://github.com/julienvincent/nvim-paredit) | Structural Clojure editing |
| [scalameta/nvim-metals](https://github.com/scalameta/nvim-metals) | Scala LSP + DAP via Metals |
| [seblj/roslyn.nvim](https://github.com/seblj/roslyn.nvim) | C# LSP via Roslyn |
| [wojciech-kulik/xcodebuild.nvim](https://github.com/wojciech-kulik/xcodebuild.nvim) | Xcode build/test/run/coverage integration |
| [akinsho/flutter-tools.nvim](https://github.com/akinsho/flutter-tools.nvim) | Dart/Flutter LSP, hot reload, DAP |

See [doc/](doc/) for per-plugin configuration guides and per-language setup + debug workflows.
