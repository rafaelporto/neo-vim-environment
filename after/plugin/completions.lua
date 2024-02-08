local lsp = require("lsp-zero")
local cmp = require("cmp")
local cmp_action = lsp.cmp_action()
local cmp_select = { behavior = cmp.SelectBehavior.Select }

require("luasnip.loaders.from_vscode").lazy_load()

cmp.setup({
	window = {
		completion = cmp.config.window.bordered(),
		documentation = cmp.config.window.bordered(),
	},
	mapping = cmp.mapping.preset.insert({
		["<C-Space>"] = cmp.mapping.complete(),
		["<C-e>"] = cmp.mapping.abort(),
		["<C-f>"] = cmp_action.luasnip_jump_forward(),
		["<C-b>"] = cmp_action.luasnip_jump_backward(),
		["<C-u>"] = cmp.mapping.scroll_docs(-5),
		["<C-d>"] = cmp.mapping.scroll_docs(5),
		["<C-p>"] = cmp.mapping.select_prev_item(cmp_select),
		["<C-n>"] = cmp.mapping.select_next_item(cmp_select),
		["<Tab>"] = cmp.mapping.confirm({ select = true }),
		["<Enter>"] = cmp.mapping.confirm({ select = true }),
	}),
	sources = {
		{ name = "nvim_lsp" },
		{ name = "luasnip" },
		{ name = "buffer" },
	},
	snippet = {
		expand = function(args)
			require("luasnip").lsp_expand(args.body)
		end,
	},
})
