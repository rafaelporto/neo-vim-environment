-- Native LSP configuration via vim.lsp.config (nvim 0.11+)

-- ─── Capabilities ─────────────────────────────────────────────────────────────
local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- ─── Mason ────────────────────────────────────────────────────────────────────
require("mason").setup({})
require("mason-lspconfig").setup({
	ensure_installed = {
		"ts_ls",
		"eslint",
		"gopls",
		"lua_ls",
		"yamlls",
		"jsonls",
		"dockerls",
	},
})

-- ─── Diagnostics ──────────────────────────────────────────────────────────────
vim.diagnostic.config({
	virtual_text = true,
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = "✘",
			[vim.diagnostic.severity.WARN] = "▲",
			[vim.diagnostic.severity.HINT] = "⚑",
			[vim.diagnostic.severity.INFO] = "»",
		},
	},
})

-- ─── Server configurations ────────────────────────────────────────────────────

-- Simple servers (capabilities only)
for _, server in ipairs({
	"ts_ls",
	"eslint",
	"cssls",
	"marksman",
	"dockerls",
	"docker_compose_language_service",
}) do
	vim.lsp.config[server] = { capabilities = capabilities }
end

-- ─── Go ───────────────────────────────────────────────────────────────────────
-- Antes o gopls só recebia `capabilities` pelo loop acima, ou seja nenhum
-- setting: sem gofumpt, staticcheck, analyses, inlay hints nem codelenses.
vim.lsp.config["gopls"] = {
	capabilities = capabilities,
	settings = {
		gopls = {
			gofumpt = true,
			staticcheck = true,
			usePlaceholders = true,
			completeUnimported = true,
			semanticTokens = true,
			directoryFilters = { "-.git", "-node_modules", "-vendor" },
			analyses = {
				unusedparams = true,
				unusedvariable = true,
				unusedwrite = true,
				shadow = true,
				nilness = true,
				useany = true,
			},
			codelenses = {
				generate = true,
				test = true,
				tidy = true,
				upgrade_dependency = true,
				vendor = true,
				run_govulncheck = true,
				regenerate_cgo = true,
				gc_details = false,
			},
			hints = {
				assignVariableTypes = true,
				compositeLiteralFields = true,
				compositeLiteralTypes = true,
				constantValues = true,
				functionTypeParameters = true,
				parameterNames = true,
				rangeVariableTypes = true,
			},
		},
	},
}

vim.lsp.config["bashls"] = {
	capabilities = capabilities,
	filetypes = { "sh", "zsh", "bash" },
}

vim.lsp.config["jsonls"] = {
	capabilities = capabilities,
	filetypes = { "json", "jsonc" },
	settings = {
		json = {
			schemas = require("schemastore").json.schemas(),
			validate = { enable = true },
		},
	},
}

vim.lsp.config["yamlls"] = {
	capabilities = capabilities,
	settings = {
		yaml = {
			schemas = require("schemastore").yaml.schemas(),
		},
	},
}

-- lua_ls — replaces lsp.nvim_lua_ls() + neodev.nvim
-- on_init injects neovim runtime paths only when editing nvim config/data dirs
vim.lsp.config["lua_ls"] = {
	capabilities = capabilities,
	on_init = function(client)
		local path = client.workspace_folders and client.workspace_folders[1] and client.workspace_folders[1].name
		if path and (path:find(vim.fn.stdpath("config"), 1, true) or path:find(vim.fn.stdpath("data"), 1, true)) then
			client.config.settings = vim.tbl_deep_extend("force", client.config.settings or {}, {
				Lua = {
					runtime = { version = "LuaJIT" },
					workspace = {
						checkThirdParty = false,
						library = {
							vim.env.VIMRUNTIME,
							"${3rd}/luv/library",
							vim.fn.stdpath("data") .. "/lazy/nvim-dap-ui",
						},
					},
				},
			})
		end
	end,
	settings = {
		Lua = {
			diagnostics = { globals = { "vim" } },
		},
	},
}

-- ─── Enable servers ──────────────────────────────────────────────────────────
vim.lsp.enable({
	"ts_ls",
	"eslint",
	"gopls",
	"cssls",
	"marksman",
	"dockerls",
	"docker_compose_language_service",
	"bashls",
	"jsonls",
	"yamlls",
	"lua_ls",
})

-- ─── Keymaps (LspAttach) ──────────────────────────────────────────────────────
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("lsp_attach_auto_diag", { clear = true }),
	callback = function(ev)
		local bufnr = ev.buf
		local opts = { buffer = bufnr, remap = false }

		vim.keymap.set(
			"n",
			"<leader>rl",
			":LspRestart | LspStart<CR>",
			{ buffer = bufnr, remap = true, desc = "Restart LSP" }
		)

		-- Goto
		vim.keymap.set("n", "gd", function()
			vim.lsp.buf.definition()
		end, { buffer = bufnr, remap = true, desc = "Go to Definition" })
		vim.keymap.set("n", "gi", function()
			vim.lsp.buf.implementation()
		end, vim.tbl_extend("force", opts, { desc = "Go to Implementation" }))
		vim.keymap.set("n", "gr", function()
			vim.lsp.buf.references()
		end, { buffer = bufnr, remap = true, desc = "References" })

		-- LSP actions
		vim.keymap.set("n", "K", function()
			vim.lsp.buf.hover()
		end, { buffer = bufnr, remap = true, desc = "Hover" })
		vim.keymap.set("n", "<leader>vds", function()
			vim.lsp.buf.document_symbol()
		end, vim.tbl_extend("force", opts, { desc = "Document symbols" }))
		vim.keymap.set("n", "<leader>vws", function()
			vim.lsp.buf.workspace_symbol()
		end, vim.tbl_extend("force", opts, { desc = "Workspace symbols" }))
		vim.keymap.set("n", "<leader>rn", function()
			vim.lsp.buf.rename()
		end, { buffer = bufnr, remap = true, desc = "Rename" })
		vim.keymap.set("i", "<C-h>", function()
			vim.lsp.buf.signature_help()
		end, vim.tbl_extend("force", opts, { desc = "Signature help" }))

		-- Diagnostics
		vim.keymap.set("n", "<leader>vd", function()
			vim.diagnostic.open_float()
		end, { buffer = bufnr, remap = false, desc = "Open diagnostic float" })
		vim.keymap.set("n", ">d", function()
			vim.diagnostic.goto_next()
		end, { buffer = bufnr, remap = false, desc = "Next diagnostic" })
		vim.keymap.set("n", "<d", function()
			vim.diagnostic.goto_prev()
		end, { buffer = bufnr, remap = false, desc = "Previous diagnostic" })
		vim.keymap.set("n", "<leader>aa", function()
			vim.diagnostic.setqflist()
		end, { buffer = bufnr, remap = false, desc = "All diagnostics in quickfix" })
		vim.keymap.set("n", "<leader>ae", function()
			vim.diagnostic.setqflist({ severity = "E" })
		end, { buffer = bufnr, remap = false, desc = "All workspace errors in quickfix" })
		vim.keymap.set("n", "<leader>aw", function()
			vim.diagnostic.setqflist({ severity = "W" })
		end, { buffer = bufnr, remap = false, desc = "All workspace warnings in quickfix" })
		vim.keymap.set("n", "<leader>d", function()
			vim.diagnostic.setloclist()
		end, { buffer = bufnr, remap = false, desc = "Buffer diagnostics in loclist" })

		-- Code lens: o gopls expõe generate, tidy, test e run_govulncheck aqui.
		-- Gated por capability, então é no-op em servidores que não implementam.
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if client and client:supports_method("textDocument/codeLens") then
			vim.keymap.set("n", "<leader>lc", vim.lsp.codelens.run,
				{ buffer = bufnr, desc = "Run code lens" })
			vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "BufWritePost" }, {
				buffer = bufnr,
				callback = function() vim.lsp.codelens.refresh({ bufnr = bufnr }) end,
			})
		end
	end,
})

-- ─── Toggle virtual_lines ─────────────────────────────────────────────────────
local function toggleLines()
	local new_value = not vim.diagnostic.config().virtual_lines
	vim.diagnostic.config({ virtual_lines = new_value, virtual_text = not new_value })
	return new_value
end

vim.keymap.set("n", "<leader>lu", toggleLines, { desc = "Toggle Underline Diagnostics", silent = true })
