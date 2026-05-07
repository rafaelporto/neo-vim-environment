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
    "tpope/vim-dispatch",
    "clojure-vim/vim-jack-in",
    "radenling/vim-dispatch-neovim",
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
            "antoinemadec/FixCursorHold.nvim",
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
    { "julienvincent/nvim-paredit" },
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
        },
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
