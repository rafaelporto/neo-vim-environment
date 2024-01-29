return {
	{ "folke/tokyonight.nvim", priority = 1000 },
	{ "rose-pine/neovim", name = "rose-pine" },
	"nvim-treesitter/nvim-treesitter-context",
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
		"neovim/nvim-lspconfig",
		cmd = "LspInfo",
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "hrsh7th/cmp-nvim-lsp" },
		},
	},
	"hoffs/omnisharp-extended-lsp.nvim",
	{ "ray-x/lsp_signature.nvim", lazy = true },
	{
		"nvim-neotest/neotest",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"antoinemadec/FixCursorHold.nvim",
			"Issafalcon/neotest-dotnet",
		},
		lazy = true,
	},
	{ "aznhe21/actions-preview.nvim", lazy = true },
	{ "folke/neodev.nvim", lazy = true },
	{ "tpope/vim-surround", lazy = false },
	{ "Tastyep/structlog.nvim", lazy = true },
	{ "rcarriga/nvim-notify", lazy = true },
	{ "RRethy/vim-illuminate", lazy = false },
	{ "numToStr/Comment.nvim", lazy = true },
	{ "mfussenegger/nvim-dap", lazy = true },
	{ "rcarriga/nvim-dap-ui", dependencies = { "mfussenegger/nvim-dap" }, lazy = true },
	{ "theHamsta/nvim-dap-virtual-text", lazy = true },
	{ "tpope/vim-fugitive", lazy = false },
	{ "rmagatti/goto-preview", lazy = false },
	{
		"ThePrimeagen/harpoon",
		lazy = false,
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
		},
	},
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "v2.x",
		dependencies = {
			-- LSP Support
			{ "neovim/nvim-lspconfig", event = { "BufReadPre", "BufNewFile" }, lazy = true }, -- Required
			{
				-- Optional
				"williamboman/mason.nvim",
				build = function()
					pcall(vim.cmd, "MasonUpdate")
				end,
			},
			{ "williamboman/mason-lspconfig.nvim" }, -- Optional

			-- Autocompletion
			{ "hrsh7th/nvim-cmp", lazy = true }, -- Required
			{ "hrsh7th/cmp-nvim-lsp", lazy = true }, -- Required
			{ "L3MON4D3/LuaSnip", lazy = true }, -- Required
		},
		lazy = false,
	},
	{ "HiPhish/rainbow-delimiters.nvim", lazy = true },
	{ "b0o/schemastore.nvim", lazy = true },
	{ "nvim-telescope/telescope-ui-select.nvim" },
	{ "nvim-telescope/telescope-dap.nvim", lazy = true },
	{ "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" }, lazy = true },
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
		"rose-pine/neovim",
		name = "rose-pine",
	},
	{
		"nvim-treesitter/nvim-treesitter",
		event = { "BufReadPre", "BufNewFile" },
		build = ":TSUpdate",
		dependencies = {
			"nvim-treesitter/nvim-treesitter-textobjects",
			"windwp/nvim-ts-autotag",
		},
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
	}
}
