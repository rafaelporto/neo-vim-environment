local lsp = require("lsp-zero")
local lspconfig = require("lspconfig")
local schemas = require("schemastore")

lsp.preset("recommended")

local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

require("mason").setup({})
require("mason-lspconfig").setup({
	ensure_installed = {
		"tsserver",
		"eslint",
		"clojure_lsp",
		"omnisharp",
		"lua_ls",
		"yamlls",
		"jsonls",
		"dockerls",
	},
	handlers = {
		lsp.default_setup,
		omnisharp = function()
			local omnisharp_extended = require("omnisharp_extended")
			require("lspconfig").omnisharp.setup({
				capabilities = capabilities,
				enable_roslyn_analysers = true,
				enable_import_completion = true,
				organize_imports_on_format = true,
				filetypes = { "cs", "vb", "csproj", "sln", "props" },
				handlers = {
					["textDocument/definition"] = omnisharp_extended.handler,
					["on_attach"] = function()
						vim.keymap.set("n", "<leader>gdr", omnisharp_extended.telescope_lsp_definitions(), {})
					end,
				},
			})
		end,
		gopls = function()
			lspconfig.gopls.setup({
				capabilities = capabilities,
			})
		end,
		jsonls = function()
			lspconfig.jsonls.setup({
				settings = {
					json = {
						schemas = schemas.json.schemas(),
						validate = { enable = true },
					},
				},
				filetypes = { "json", "jsonc", "*json.base" },
				capabilities = capabilities,
			})
		end,
		bashls = function()
			lspconfig.bashls.setup({
				capabilities = capabilities,
				filetypes = { "sh", "zsh", "bash", "*zprofile" },
			})
		end,
		docker_compose_language_service = function()
			lspconfig.docker_compose_language_service.setup({
				capabilities = capabilities,
			})
		end,
		marksman = function()
			lspconfig.marksman.setup({
				capabilities = capabilities,
			})
		end,
		dockerls = function()
			lspconfig.dockerls.setup({
				capabilities = capabilities,
			})
		end,
		cssls = function()
			lspconfig.cssls.setup({
				capabilities = capabilities,
			})
		end,
		lua_ls = function()
			local lua_opts = lsp.nvim_lua_ls()
			lspconfig.lua_ls.setup(lua_opts)
		end,
		clojure_lsp = function()
			lspconfig.clojure_lsp.setup({
				capabilities = capabilities,
			})
		end,
		tsserver = function()
			lspconfig.tsserver.setup({
				capabilities = capabilities,
			})
		end,
		yamlls = function()
			lspconfig.yamlls.setup({
				capabilities = capabilities,
				settings = {
					yamlls = {
						schemas = schemas.yaml.schemas(),
					},
				},
			})
		end,
	},
})

lsp.set_preferences({
	suggest_lsp_servers = false,
	sign_icons = {
		error = "✘",
		warn = "▲",
		hint = "⚑",
		info = "»",
	},
})

lsp.on_attach(function(_, bufnr)
	local opts = { buffer = bufnr, remap = false }

	-- Goto mappings
	vim.keymap.set("n", "gd", function()
		vim.lsp.buf.definition()
	end, { buffer = bufnr, remap = true, desc = "Go to Definition" })
	vim.keymap.set("n", "gi", function()
		vim.lsp.buf.implementation()
	end, { buffer = opts.buffer, remap = opts.remap, desc = "Go to Implementation" })
	vim.keymap.set("n", "gr", function()
		vim.lsp.buf.references()
	end, { buffer = bufnr, remap = true, desc = "References" })

	-- LSP mappings
	vim.keymap.set("n", "K", function()
		vim.lsp.buf.hover()
	end, { buffer = bufnr, remap = true, desc = "Hover" })
	vim.keymap.set("n", "<leader>vds", function()
		vim.lsp.buf.document_symbol()
	end, opts)
	vim.keymap.set("n", "<leader>vws", function()
		vim.lsp.buf.workspace_symbol()
	end, opts)
	vim.keymap.set("n", "<leader>ca", function()
		vim.lsp.buf.code_action()
	end, { buffer = bufnr, remap = true, desc = "Code Action" })
	vim.keymap.set("n", "<leader>rn", function()
		vim.lsp.buf.rename()
	end, { buffer = bufnr, remap = true, desc = "Rename" })
	vim.keymap.set("i", "<C-h>", function()
		vim.lsp.buf.signature_help()
	end, { buffer = opts.buffer, remap = opts.remap, desc = "Signature Help" })

	-- Diagnostics
	vim.keymap.set("n", "<leader>vd", function()
		vim.diagnostic.open_float()
	end, { buffer = opts.buffer, remap = opts.remap, desc = "Abre diagnóstico em modal" })
	vim.keymap.set("n", ">d", function()
		vim.diagnostic.goto_next()
	end, { buffer = opts.buffer, remap = opts.remap, desc = "Próximo diagnóstico" })
	vim.keymap.set("n", "<d", function()
		vim.diagnostic.goto_prev()
	end, { buffer = opts.buffer, remap = opts.remap, desc = "Diagnóstico anterior" })
	vim.keymap.set("n", "<leader>aa", function()
		vim.diagnostic.setqflist()
	end, { buffer = opts.buffer, remap = opts.remap, desc = "Todos diagnósticos" })
	vim.keymap.set("n", "<leader>ae", function()
		vim.diagnostic.setqflist({ severity = "E" }) -- all workspace errors
	end, { buffer = opts.buffer, remap = opts.remap, desc = "Todos os erros do workspace" })
	vim.keymap.set("n", "<leader>aw", function()
		vim.diagnostic.setqflist({ severity = "W" }) -- all workspace warnings
	end, { buffer = opts.buffer, remap = opts.remap, desc = "Todos os warnings do workspace" })
	vim.keymap.set("n", "<leader>d", function()
		vim.diagnostic.setloclist()
	end, { buffer = opts.buffer, remap = opts.remap, desc = "Adicionar diagnóstico de buffer à lista de locais"})
end)

vim.diagnostic.config({
	virtual_text = true,
})

local function toggleLines()
	local new_value = not vim.diagnostic.config().virtual_lines
	vim.diagnostic.config({ virtual_lines = new_value, virtual_text = not new_value })
	return new_value
end

vim.keymap.set("n", "<leader>lu", toggleLines, { desc = "Toggle Underline Diagnostics", silent = true })

lsp.setup()
