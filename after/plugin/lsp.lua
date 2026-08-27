-- Native LSP configuration via vim.lsp.config (nvim 0.11+)

-- ─── Capabilities ─────────────────────────────────────────────────────────────
local capabilities = require("cmp_nvim_lsp").default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

-- ─── Mason ────────────────────────────────────────────────────────────────────
-- O registry Crashdummyy fornece o pacote `roslyn` (mesma versão usada no
-- vscode-csharp, com asset nativo darwin_arm64). Não existe pacote `roslyn` no
-- registry mason-org — só `roslyn-language-server`, da nuget.org e atrás do
-- vscode —, então sem esta lista o `:MasonInstall roslyn` falha com 404.
-- mason-org fica explícito de propósito: declarar `registries` substitui o
-- default, e omitir mason-org quebraria gopls, vtsls e todo o resto.
require("mason").setup({
	registries = {
		"github:mason-org/mason-registry",
		"github:Crashdummyy/mason-registry",
	},
})
require("mason-lspconfig").setup({
	ensure_installed = {
		"vtsls",
		"eslint",
		"gopls",
		"lua_ls",
		"yamlls",
		"jsonls",
		"dockerls",
	},
	-- mason-lspconfig auto-habilita todo servidor instalado. ts_ls nunca deve
	-- subir junto do vtsls (diagnostics duplicados + memória dobrada), então
	-- fica excluído aqui como garantia caso o pacote seja reinstalado.
	-- roslyn_ls pelo mesmo motivo: o pacote `roslyn-language-server` do mason-org
	-- carrega `neovim.lspconfig = roslyn_ls`, então se ele for instalado o
	-- automatic_enable subiria um segundo cliente Roslyn junto do que o
	-- roslyn.nvim já gerencia. O pacote `roslyn` do Crashdummyy não tem essa
	-- chave, então hoje não há colisão — isto é garantia, não correção.
	automatic_enable = { exclude = { "ts_ls", "roslyn_ls" } },
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

-- Camada de merge 1: vale para TODO servidor, inclusive os configurados fora
-- deste arquivo (sourcekit, dartls). Substitui o antigo loop por servidor, que
-- tinha de ser mantido em sincronia com a lista do vim.lsp.enable abaixo.
vim.lsp.config("*", { capabilities = capabilities })

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

-- ─── TypeScript / JavaScript (vtsls) ─────────────────────────────────────────
-- vtsls no lugar do ts_ls: expõe todo o namespace de settings do VSCode, então
-- inlay hints e preferences de import são configuráveis por workspace. O
-- typescript-language-server só aceita preferences via initializationOptions.
-- Nunca habilitar os dois juntos (ver automatic_enable.exclude acima).
local ts_inlay_hints = {
	parameterNames = { enabled = "literals", suppressWhenArgumentMatchesName = true },
	parameterTypes = { enabled = true },
	variableTypes = { enabled = false, suppressWhenTypeMatchesName = true },
	propertyDeclarationTypes = { enabled = true },
	functionLikeReturnTypes = { enabled = true },
}

local ts_preferences = {
	importModuleSpecifier = "shortest",
	importModuleSpecifierEnding = "auto",
	includePackageJsonAutoImports = "auto",
	preferTypeOnlyAutoImports = true,
}

vim.lsp.config["vtsls"] = {
	settings = {
		vtsls = {
			autoUseWorkspaceTsdk = true, -- respeita o typescript do projeto
			enableMoveToFileCodeAction = true,
			experimental = {
				completion = { enableServerSideFuzzyMatch = true },
				maxInlayHintLength = 30,
			},
		},
		typescript = {
			inlayHints = vim.tbl_extend("error", ts_inlay_hints, {
				enumMemberValues = { enabled = true }, -- chave só de typescript
			}),
			preferences = ts_preferences,
			updateImportsOnFileMove = { enabled = "always" },
			suggest = { completeFunctionCalls = true },
		},
		javascript = {
			inlayHints = ts_inlay_hints,
			preferences = ts_preferences,
			updateImportsOnFileMove = { enabled = "always" },
			suggest = { completeFunctionCalls = true },
		},
	},
}

-- O lsp/eslint.lua do nvim-lspconfig já fornece workingDirectory mode "auto",
-- workspace_required, um root_dir que se recusa a anexar sem config de eslint no
-- projeto, e um on_attach que cria o :LspEslintFixAll.
-- NÃO definir on_attach aqui: substituiria aquele e destruiria o comando, que o
-- after/plugin/formatting.lua usa no save.
vim.lsp.config["eslint"] = {
	settings = {
		-- Só lint. Formatação é do prettier/biome via conform; deixar true
		-- permitiria o fallback do conform eleger o eslint como formatter.
		format = false,
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
	"vtsls",
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
		-- <leader>ad, não <leader>d: este mapa é buffer-local e vencia o
		-- delete-sem-yank global de remap.lua:22, quebrando <leader>dd e
		-- <leader>dw em TODO buffer com LSP — Go, TS, Swift, Dart, Lua.
		-- <leader>a já é o namespace de diagnósticos (aa/ae/aw/aq).
		vim.keymap.set("n", "<leader>ad", function()
			vim.diagnostic.setloclist()
		end, { buffer = bufnr, remap = false, desc = "Buffer diagnostics in loclist" })

		-- Code lens: o gopls expõe generate, tidy, test e run_govulncheck aqui.
		-- Gated por capability, então é no-op em servidores que não implementam.
		local client = vim.lsp.get_client_by_id(ev.data.client_id)

		-- Inlay hints: gated por capability, então é no-op em servidores que não
		-- implementam textDocument/inlayHint — o dartls entre eles, cujo
		-- equivalente são as closing labels do flutter-tools.
		if client and client:supports_method("textDocument/inlayHint") then
			vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
			vim.keymap.set("n", "<leader>lh", function()
				vim.lsp.inlay_hint.enable(
					not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }),
					{ bufnr = bufnr }
				)
			end, { buffer = bufnr, desc = "Toggle inlay hints" })
		end

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
