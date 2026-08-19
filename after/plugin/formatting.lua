-- Único dono da formatação.
--
-- Antes: conform.setup() morava dentro de swift-config.lua com um
-- format_on_save GLOBAL, o none-ls se fazia passar por LSP, e <leader>f
-- apontava para vim.lsp.buf.format. Resultado: Swift formatava pelo sourcekit
-- (não swiftformat), Dart pelo dartls (não dart_format) e TS pelo tsserver
-- (não prettier) — justamente os três formatters que estavam configurados.

local conform = require("conform")

conform.setup({
    formatters_by_ft = {
        -- Web: biome se o projeto tiver biome.json, senão prettier, senão nada.
        -- Os dois resolvem o binário de ./node_modules/.bin
        -- (conform util.from_node_modules), então nada é instalado global.
        --
        -- lsp_format = "never" aqui é essencial: sem isso o "fallback" global
        -- manda o vtsls/jsonls formatar quando o projeto não tem config de
        -- prettier, com os defaults do tsserver — anulando o require_cwd e
        -- reformatando exatamente os repos que optaram por não usar prettier.
        -- Verificado: `const   x:number=1` virava `const x: number = 1`.
        javascript      = { "biome", "prettier", stop_after_first = true, lsp_format = "never" },
        javascriptreact = { "biome", "prettier", stop_after_first = true, lsp_format = "never" },
        typescript      = { "biome", "prettier", stop_after_first = true, lsp_format = "never" },
        typescriptreact = { "biome", "prettier", stop_after_first = true, lsp_format = "never" },
        json            = { "biome", "prettier", stop_after_first = true, lsp_format = "never" },
        jsonc           = { "biome", "prettier", stop_after_first = true, lsp_format = "never" },
        css             = { "prettier", lsp_format = "never" },
        html            = { "prettier", lsp_format = "never" },
        yaml            = { "prettier", lsp_format = "never" },
        markdown        = { "prettier", lsp_format = "never" },
        graphql         = { "prettier", lsp_format = "never" },

        -- Toolchains nativas. Aqui o fallback do LSP é desejado: binário ausente
        -- => sourcekit/roslyn/dartls/gopls formatam, que é o mesmo resultado que
        -- a ferramenta dedicada produziria.
        go    = { "goimports", "gofumpt" },
        dart  = { "dart_format" },
        swift = { "swiftformat" },
        lua   = { "stylua" },
        cs    = { "csharpier" },
        sql   = { "sqlfmt" },
    },

    formatters = {
        -- Só formata se o projeto optar explicitamente. Sem cwd o conform marca
        -- available = false ("Root directory not found") em vez de erro — assim
        -- um repo que deliberadamente não usa prettier não é reformatado com os
        -- defaults dele.
        prettier = { require_cwd = true },
        biome = { require_cwd = true },
    },

    default_format_opts = {
        timeout_ms = 1000,
        lsp_format = "fallback", -- grafia atual; lsp_fallback está deprecado
    },

    log_level = vim.log.levels.ERROR,
})

-- Um autocmd, ordem explícita: eslint --fix primeiro (reescreve código: ordena
-- imports, prefer-const, remove import não usado), depois o formatter (decide o
-- layout final). Registrar os dois em autocmds separados deixaria a ordem à
-- mercê da ordem de registro, e o conform ganharia — deixando as reescritas do
-- eslint sem formatação.
local ignore_filetypes = { ["neo-tree"] = true }

vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("format_on_save", { clear = true }),
    callback = function(args)
        local buf = args.buf
        if ignore_filetypes[vim.bo[buf].filetype] then
            return
        end

        -- :LspEslintFixAll é criado pelo on_attach do nvim-lspconfig e só existe
        -- quando o cliente eslint realmente anexou a este buffer.
        if next(vim.lsp.get_clients({ bufnr = buf, name = "eslint" })) then
            pcall(vim.api.nvim_buf_call, buf, function()
                vim.cmd("LspEslintFixAll")
            end)
        end

        conform.format({ bufnr = buf })
    end,
})

vim.keymap.set({ "n", "v" }, "<leader>f", function()
    conform.format({ async = true })
end, { desc = "Format buffer/selection" })
