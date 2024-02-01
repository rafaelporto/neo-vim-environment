local null_ls = require("null-ls")

null_ls.setup({
	sources = {
		null_ls.builtins.diagnostics.eslint_d,
		null_ls.builtins.diagnostics.golangci_lint.with({
			filetypes = { "go" },
			command = "golangci-lint",
			args = { "run", "$FILENAME", "--out-format=json" },
		}),
		null_ls.builtins.diagnostics.clj_kondo,
		null_ls.builtins.formatting.prettier,
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.sqlfmt,
		null_ls.builtins.formatting.goimports,
	},
})
