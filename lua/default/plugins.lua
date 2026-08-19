return {
    { "folke/tokyonight.nvim",       name = "tokyonight-theme", priority = 1000 },
    { "rose-pine/neovim",            name = "rose-pine-theme" },
    { "projekt0n/github-nvim-theme", name = "github-theme" },
    { "catppuccin/nvim",             name = "catppuccin-theme", priority = 1000 },
    { "doums/darcula",               name = "darcula-theme",    priority = 1000 },
    { "dracula/vim",                 name = "dracula-theme",    priority = 1000 },
    "mbbill/undotree",
    {
        "github/copilot.vim",
        lazy = false,
        enabled = true,
    },
    {
        "williamboman/mason.nvim",
        build = function()
            pcall(vim.cmd, "MasonUpdate")
        end,
    },
    {
        "williamboman/mason-lspconfig.nvim",
        dependencies = { "williamboman/mason.nvim" },
    },
    -- Kept for its lsp/<server>.lua configs (cmd, filetypes, root_markers).
    -- Do NOT call require("lspconfig") — use vim.lsp.config instead.
    { "neovim/nvim-lspconfig" },
    {
        "seblj/roslyn.nvim",
        ft = { "cs" },
        dependencies = { "nvim-telescope/telescope.nvim" },
    },
    { "ray-x/lsp_signature.nvim",     lazy = true },
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-neotest/nvim-nio", -- dependência obrigatória do neotest
            "antoinemadec/FixCursorHold.nvim",
            {
                -- v2+ exige o parser Go da branch main do nvim-treesitter,
                -- garantido pelo spec do nvim-treesitter acima.
                "fredrikaverpil/neotest-golang",
                version = "*", -- rastreia releases, não o main
            },
            "marilari88/neotest-vitest",
            "nvim-neotest/neotest-jest",
            "sidlatau/neotest-dart",
            "Issafalcon/neotest-dotnet",
        },
        lazy = true,
    },
    { "aznhe21/actions-preview.nvim", lazy = true },
    { "tpope/vim-surround",           lazy = false },
    { "Tastyep/structlog.nvim",       lazy = true },
    { "RRethy/vim-illuminate",        lazy = false },
    { "mfussenegger/nvim-dap",        lazy = true },
    {
        "rcarriga/nvim-dap-ui",
        dependencies =
        {
            "mfussenegger/nvim-dap",
            "nvim-neotest/nvim-nio"
        },
        lazy = true
    },
    { "theHamsta/nvim-dap-virtual-text", lazy = true },
    { "tpope/vim-fugitive",              lazy = false },
    { "rmagatti/goto-preview",           lazy = false },
    {
        "ThePrimeagen/harpoon",
        lazy = false,
        dependencies = {
            { "nvim-lua/plenary.nvim" },
        },
    },
    { "HiPhish/rainbow-delimiters.nvim",        lazy = true },
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main", -- master está congelada e não suporta nvim 0.12
        lazy = false,    -- upstream: "this plugin does not support lazy-loading"
        build = ":TSUpdate",
        config = function()
            -- setup() é opcional: install_dir default é stdpath("data")/site.
            -- install() é assíncrono e no-op para parser já instalado.
            -- Requer tree-sitter-cli (brew install tree-sitter-cli) e um compilador C.
            require("nvim-treesitter").install({
                "bash", "c", "c_sharp", "css", "dart", "diff", "dockerfile",
                "gitcommit", "gitignore", "go", "gomod", "gosum", "gowork",
                "html", "javascript", "jsdoc", "json", "lua", "luadoc",
                "markdown", "markdown_inline", "query", "regex", "scala",
                "sql", "swift", "toml", "tsx", "typescript", "vim", "vimdoc",
                "yaml",
            })
        end,
    },
    {
        -- opts = {} faz o lazy.nvim chamar setup({}), que é OBRIGATÓRIO: o
        -- caminho zero-config do plugin faz require("nvim-treesitter.configs"),
        -- módulo que não existe na branch main, e quebra.
        "windwp/nvim-ts-autotag",
        ft = { "html", "javascript", "javascriptreact", "typescript", "typescriptreact", "markdown" },
        opts = {},
    },
    { "b0o/schemastore.nvim",                   lazy = true },
    { "nvim-telescope/telescope-ui-select.nvim" },
    { "nvim-telescope/telescope-dap.nvim",      lazy = true },
    { "nvim-telescope/telescope.nvim",          dependencies = { "nvim-lua/plenary.nvim" }, lazy = true },
    {
        "folke/trouble.nvim",
        dependencies = { { "nvim-tree/nvim-web-devicons" } },
    },
    {
        "iamcco/markdown-preview.nvim",
        lazy = false,
        build = function()
            vim.fn["mkdp#util#install"]()
        end,
    },
    {
        "scalameta/nvim-metals",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "mfussenegger/nvim-dap",
        },
    },
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
    },
    {
        "nvimtools/none-ls.nvim",
        lazy = true,
        dependencies = { "nvim-lua/plenary.nvim" },
    },
    {
        "folke/noice.nvim",
        event = "VeryLazy",
        dependencies = {
            "MunifTanjim/nui.nvim",
            "rcarriga/nvim-notify",
        },
    },
    {
        "hrsh7th/nvim-cmp",
        lazy = true,
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-buffer",
        },
    },
    { "hrsh7th/cmp-path",          lazy = true },
    { "hrsh7th/cmp-buffer",        lazy = true },
    { "hrsh7th/cmp-nvim-lsp",      lazy = false },
    {
        "L3MON4D3/LuaSnip",
        lazy = false,
        config = function(opts)
            require('luasnip').setup(opts)
            require('luasnip.loaders.from_snipmate').load()
        end,
    },
    { "saadparwaiz1/cmp_luasnip",     lazy = false },
    { "rafamadriz/friendly-snippets", lazy = false },
    { "numToStr/Comment.nvim",        lazy = false },
    {
        "folke/todo-comments.nvim",
        dependencies = { "nvim-lua/plenary.nvim" },
    },
{ "wojciech-kulik/xcodebuild.nvim",
    dependencies = {
        "nvim-telescope/telescope.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-tree.lua",     -- (optional) to manage project files
        "stevearc/oil.nvim",           -- (optional) to manage project files
    },
    config = function()
        require("xcodebuild").setup({
            -- put some options here or leave it empty to use default settings
        })
    end},
{
    -- NOTA: a config fica inline aqui, não em after/plugin/, de propósito.
    -- ft = { "dart" } mantém o flutter-tools, seus ~25 comandos e a fiação de
    -- DAP fora de toda sessão não-Dart; um after/plugin/flutter.lua rodaria no
    -- startup e faria require() sempre, desfazendo isso — foi essa classe de
    -- problema que o commit 72413e7 corrigiu.
    "akinsho/flutter-tools.nvim",
    ft = { "dart" },
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
        -- O flutter-tools já busca o SDK nesta ordem (executable.lua M.get):
        --   config.fvm -> config.flutter_path -> flutter_lookup_cmd -> exepath
        -- Por isso NÃO definimos flutter_path a menos que o SDK esteja em lugar
        -- não-padrão: fazê-lo curto-circuita a cadeia na 2ª posição, que era
        -- exatamente o bug do "~/sdk-flutter" fixo (diretório inexistente).
        local function find_flutter()
            -- No PATH: homebrew cask, asdf/mise, instalação com bin/ no PATH.
            if vim.fn.exepath("flutter") ~= "" then
                return {} -- deixa o flutter-tools resolver
            end

            -- FVM por projeto (.fvm/flutter_sdk).
            if vim.fs.find(".fvm", { path = vim.uv.cwd(), upward = true, type = "directory" })[1] then
                return { fvm = true }
            end

            -- Locais conhecidos fora do PATH, incluindo o default global do FVM.
            for _, candidate in ipairs({
                "~/fvm/default/bin/flutter",
                "~/development/flutter/bin/flutter",
                "~/flutter/bin/flutter",
                "~/sdk-flutter/bin/flutter",
            }) do
                local bin = vim.fn.expand(candidate)
                if vim.fn.executable(bin) == 1 then
                    return { flutter_path = bin }
                end
            end

            return nil
        end

        local sdk = find_flutter()
        if not sdk then
            -- Sem SDK, não chamar setup(): evita entregar um flutter_path
            -- inexistente e curto-circuitar a busca do plugin.
            --
            -- Sem notify próprio de propósito. O ftplugin/dart/init.lua do
            -- flutter-tools chama lsp.attach() em todo buffer .dart de qualquer
            -- forma, e o get_server_config já avisa "Flutter executable could
            -- not be found..." explicando como resolver. Um vim.notify aqui
            -- daria duas mensagens para o mesmo problema.
            return
        end

        require("flutter-tools").setup(vim.tbl_extend("error", sdk, {
            widget_guides = { enabled = false },
            closing_tags = {
                -- Era ErrorMsg, o que fazia toda closing tag parecer uma falha.
                highlight = "Comment",
                prefix = " // ",
                enabled = true,
            },
            dev_log = {
                enabled = true,
                -- Era "tabedit", que rouba uma aba a cada run; um split embaixo
                -- mantém o código visível. Alterna com <leader>FL.
                open_cmd = "botright 15split",
            },
            debugger = {
                -- Só isto já roteia o FlutterRun pelo DAP. run_via_dap foi
                -- REMOVIDO do flutter-tools (zero ocorrências na fonte) — a
                -- opção que estava aqui era morta.
                enabled = true,
                exception_breakpoints = {},
                evaluate_to_string_in_debug_views = true,
            },
            lsp = {
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
                -- NÃO definir analysisExcludedFolders aqui: o default do plugin
                -- já exclui <sdk>/packages e <sdk>/.pub-cache, e o merge é
                -- tbl_deep_extend("force"), então uma lista nossa apagaria as
                -- duas. Para excluir pasta gerada, usar analysis_options.yaml.
                -- completeFunctionCalls, showTodos e updateImportsOnRename já
                -- são default (lsp/init.lua) — estavam duplicados aqui.
                settings = {
                    renameFilesWithClasses = "prompt",
                    enableSnippets = true,
                    lineLength = 100,
                },
                on_attach = function(_, bufnr)
                    local function map(key, cmd, desc)
                        vim.keymap.set("n", key, cmd, { buffer = bufnr, desc = desc })
                    end
                    map("<leader>FR", "<cmd>FlutterRun<cr>", "Flutter Run")
                    map("<leader>Fd", "<cmd>FlutterDevices<cr>", "Flutter Devices")
                    map("<leader>Fe", "<cmd>FlutterEmulators<cr>", "Flutter Emulators")
                    map("<leader>Fq", "<cmd>FlutterQuit<cr>", "Flutter Quit")
                    map("<leader>Fr", "<cmd>FlutterReload<cr>", "Flutter Hot Reload")
                    map("<leader>FH", "<cmd>FlutterRestart<cr>", "Flutter Hot Restart")
                    map("<leader>Fl", "<cmd>FlutterLspRestart<cr>", "Flutter LSP Restart")
                    map("<leader>Fo", "<cmd>FlutterOutlineToggle<cr>", "Flutter Outline")
                    map("<leader>FD", "<cmd>FlutterDevTools<cr>", "Flutter DevTools")
                    map("<leader>Fp", "<cmd>FlutterPubGet<cr>", "Flutter Pub Get")
                    map("<leader>FL", "<cmd>FlutterLogToggle<cr>", "Toggle Flutter Log")
                end,
            },
        }))
    end,
},
{"stevearc/conform.nvim", lazy = true },
{"mfussenegger/nvim-lint", lazy = true },
{
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    keys = {
        { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file tree" },
    },
    lazy = true,
},
}
