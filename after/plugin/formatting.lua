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
        javascript      = { "biome", "prettier", stop_after_first = true },
        javascriptreact = { "biome", "prettier", stop_after_first = true },
        typescript      = { "biome", "prettier", stop_after_first = true },
        typescriptreact = { "biome", "prettier", stop_after_first = true },
        json            = { "biome", "prettier", stop_after_first = true },
        jsonc           = { "biome", "prettier", stop_after_first = true },
        css             = { "prettier" },
        html            = { "prettier" },
        yaml            = { "prettier" },
        markdown        = { "prettier" },
        graphql         = { "prettier" },

        -- Toolchains nativas. Binário ausente => conform marca indisponível e
        -- o lsp_format = "fallback" abaixo manda para o LSP da linguagem.
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
