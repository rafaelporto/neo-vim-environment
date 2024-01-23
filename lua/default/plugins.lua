return {
    {
        'rose-pine/neovim',
        name = 'rose-pine'
    },
    'nvim-treesitter/nvim-treesitter-context',
    'mbbill/undotree',
    {
        'github/copilot.vim',
        lazy = false,
        enabled = true
    },
    'tpope/vim-dispatch',
    'clojure-vim/vim-jack-in',
    'radenling/vim-dispatch-neovim',
    {
        'neovim/nvim-lspconfig',
        cmd = 'LspInfo',
        event = { 'BufReadPre', 'BufNewFile' },
        dependencies = {
            { 'hrsh7th/cmp-nvim-lsp' },
        }
    },
    'hoffs/omnisharp-extended-lsp.nvim',
    { "ray-x/lsp_signature.nvim",        lazy = true },
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "nvim-treesitter/nvim-treesitter",
            "antoinemadec/FixCursorHold.nvim",
            "Issafalcon/neotest-dotnet",
        },
        lazy = true
    },
    { 'aznhe21/actions-preview.nvim',    lazy = true },
    { "folke/neodev.nvim",               lazy = true },
    { 'tpope/vim-surround',              lazy = false },
    { "Tastyep/structlog.nvim",          lazy = true },
    { 'rcarriga/nvim-notify',            lazy = true },
    { 'RRethy/vim-illuminate',           lazy = false },
    { 'numToStr/Comment.nvim',           lazy = true },
    { 'mfussenegger/nvim-dap',           lazy = true },
    { 'rcarriga/nvim-dap-ui',            dependencies = { 'mfussenegger/nvim-dap' }, lazy = true },
    { 'theHamsta/nvim-dap-virtual-text', lazy = true },
    { 'tpope/vim-fugitive',              lazy = true },
    { 'rmagatti/goto-preview',           lazy = false },
    {
        'ThePrimeagen/harpoon',
        lazy = false,
        dependencies = {
            { 'nvim-lua/plenary.nvim' }
        }
    },
    {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        dependencies = {
            -- LSP Support
            { 'neovim/nvim-lspconfig',            event = { "BufReadPre", "BufNewFile" }, lazy = true }, -- Required
            {
                -- Optional
                'williamboman/mason.nvim',
                build = function()
                    pcall(vim.cmd, 'MasonUpdate')
                end,
            },
            { 'williamboman/mason-lspconfig.nvim' }, -- Optional

            -- Autocompletion
            { 'hrsh7th/nvim-cmp',                 lazy = true }, -- Required
            { 'hrsh7th/cmp-nvim-lsp',             lazy = true }, -- Required
            { 'L3MON4D3/LuaSnip',                 lazy = true }  -- Required
        },
        lazy = false
    },
    { 'HiPhish/rainbow-delimiters.nvim',        lazy = true },
    { "b0o/schemastore.nvim",                   lazy = true },
    { 'nvim-telescope/telescope-ui-select.nvim' },
    { 'nvim-telescope/telescope-dap.nvim',      lazy = true },
    { 'nvim-telescope/telescope.nvim',          dependencies = { 'nvim-lua/plenary.nvim' }, lazy = true },
    {
        "folke/trouble.nvim",
        dependencies = { { "nvim-tree/nvim-web-devicons" } },
    },
    {
        "iamcco/markdown-preview.nvim",
        lazy = false,
        build = function()
            vim.fn["mkdp#util#install"]()
        end
    },
    { "julienvincent/nvim-paredit" },
    {
        'rose-pine/neovim',
        name = 'rose-pine'
    },
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPre", "BufNewFile" },
        build = ":TSUpdate",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
            "windwp/nvim-ts-autotag",
        }
    },
    {
        "Olical/conjure",
        ft = { "clojure" }, -- languages
        dependencies = {
            {
                "PaterJason/cmp-conjure",
                config = function()
                    local cmp = require("cmp")
                    local config = cmp.get_config()
                    table.insert(config.sources, {
                        name = "buffer",
                        option = {
                            sources = {
                                { name = "conjure" },
                            },
                        },
                    })
                    cmp.setup(config)
                end,
            },
        }
    },
    {
        "scalameta/nvim-metals",
        dependencies = {
            "nvim-lua/plenary.nvim",
            {
                "mfussenegger/nvim-dap",
                config = function(self, opts)
                    -- Debug settings if you're using nvim-dap
                    local dap = require("dap")

                    dap.configurations.scala = {
                        {
                            type = "scala",
                            request = "launch",
                            name = "RunOrTest",
                            metals = {
                                runType = "runOrTestFile",
                                --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
                            },
                        },
                        {
                            type = "scala",
                            request = "launch",
                            name = "Test Target",
                            metals = {
                                runType = "testTarget",
                            },
                        },
                    }
                end
            },
        },
        ft = { "scala", "sbt" },
        opts = function()
            local metals_config = require("metals").bare_config()
            local map = vim.keymap.set

            -- Example of settings
            metals_config.settings = {
                showImplicitArguments = true,
                excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
            }

            -- *READ THIS*
            -- I *highly* recommend setting statusBarProvider to true, however if you do,
            -- you *have* to have a setting to display this in your statusline or else
            -- you'll not see any messages from metals. There is more info in the help
            -- docs about this
            -- metals_config.init_options.statusBarProvider = "on"

            -- Example if you are using cmp how to make sure the correct capabilities for snippets are set
            metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

            metals_config.on_attach = function(client, bufnr)
                require("metals").setup_dap()

                -- LSP mappings
                map("n", "gD", vim.lsp.buf.definition)
                map("n", "K", vim.lsp.buf.hover)
                map("n", "gi", vim.lsp.buf.implementation)
                map("n", "gr", vim.lsp.buf.references)
                map("n", "gds", vim.lsp.buf.document_symbol)
                map("n", "gws", vim.lsp.buf.workspace_symbol)
                map("n", "<leader>cl", vim.lsp.codelens.run)
                map("n", "<leader>sh", vim.lsp.buf.signature_help)
                map("n", "<leader>rn", vim.lsp.buf.rename)
                map("n", "<leader>f", vim.lsp.buf.format)
                map("n", "<leader>ca", vim.lsp.buf.code_action)

                map("n", "<leader>ws", function()
                    require("metals").hover_worksheet()
                end)

                -- all workspace diagnostics
                map("n", "<leader>aa", vim.diagnostic.setqflist)

                -- all workspace errors
                map("n", "<leader>ae", function()
                    vim.diagnostic.setqflist({ severity = "E" })
                end)

                -- all workspace warnings
                map("n", "<leader>aw", function()
                    vim.diagnostic.setqflist({ severity = "W" })
                end)

                -- buffer diagnostics only
                map("n", "<leader>d", vim.diagnostic.setloclist)

                map("n", "[c", function()
                    vim.diagnostic.goto_prev({ wrap = false })
                end)

                map("n", "]c", function()
                    vim.diagnostic.goto_next({ wrap = false })
                end)

                -- Example mappings for usage with nvim-dap. If you don't use that, you can
                -- skip these
                map("n", "<leader>dc", function()
                    require("dap").continue()
                end)

                map("n", "<leader>dr", function()
                    require("dap").repl.toggle()
                end)

                map("n", "<leader>dK", function()
                    require("dap.ui.widgets").hover()
                end)

                map("n", "<leader>dt", function()
                    require("dap").toggle_breakpoint()
                end)

                map("n", "<leader>dso", function()
                    require("dap").step_over()
                end)

                map("n", "<leader>dsi", function()
                    require("dap").step_into()
                end)

                map("n", "<leader>dl", function()
                    require("dap").run_last()
                end)
            end

            return metals_config
        end,
        config = function(self, metals_config)
            local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
            vim.api.nvim_create_autocmd("FileType", {
                pattern = self.ft,
                callback = function()
                    require("metals").initialize_or_attach(metals_config)
                end,
                group = nvim_metals_group,
            })
        end

    }
}
