local null_ls = require("null-ls")

null_ls.setup({
	should_attach = function(bufnr)
		local bufname = vim.api.nvim_buf_get_name(bufnr)
		return vim.bo[bufnr].buftype == ""
			and bufname ~= ""
			and vim.fn.isdirectory(bufname) == 0
	end,
	sources = {
		null_ls.builtins.diagnostics.golangci_lint.with({
			filetypes = { "go" },
			command = "golangci-lint",
			args = { "run", "$FILENAME", "--out-format=json" },
		}),
		null_ls.builtins.diagnostics.clj_kondo,
		null_ls.builtins.diagnostics.editorconfig_checker,
		null_ls.builtins.formatting.prettier,
		null_ls.builtins.formatting.stylua,
		null_ls.builtins.formatting.sqlfmt,
		null_ls.builtins.formatting.goimports,
        null_ls.builtins.formatting.csharpier
	},
})
