-- Único dono da formatação.
--
-- Antes: conform.setup() morava dentro de swift-config.lua com um
-- format_on_save GLOBAL, o none-ls se fazia passar por LSP, e <leader>f
-- apontava para vim.lsp.buf.format. Resultado: Swift formatava pelo sourcekit
-- (não swiftformat), Dart pelo dartls (não dart_format) e TS pelo tsserver
-- (não prettier) — justamente os três formatters que estavam configurados.

local conform = require("conform")

-- ─── Go: o padrão é o do repositório ─────────────────────────────────────────
-- goimports+gofumpt num repo que formata com gofmt puro suja o diff: a saída do
-- gofumpt é gofmt-estável, então o gofmt do repo NÃO desfaz — a reformatação de
-- linhas não tocadas vai junto no commit.
local GO_FORMATTERS = { "gci", "goimports", "gofmt", "gofumpt", "golines" }
local go_default = { "goimports", "gofumpt" }
local go_cache = {}

local function go_declared(dir)
    local cfg = vim.fs.find(
        { ".golangci.yml", ".golangci.yaml", ".golangci.toml", ".golangci.json" },
        { upward = true, path = dir, type = "file" }
    )[1]
    if not cfg then
        return go_default
    end

    -- Varredura por indentação, não parser de YAML: só interessa quais dos
    -- cinco nomes acima aparecem sob algum `enable:`, e essa lista é plana.
    -- Serve v1 (formatters vivem em linters.enable) e v2 (formatters.enable)
    -- sem precisar saber em qual bloco está.
    local declared, in_enable = {}, false
    for _, line in ipairs(vim.fn.readfile(cfg)) do
        local inline = line:match("^%s+enable:%s*%[(.*)%]")
        if inline then
            for name in inline:gmatch("[%w_]+") do
                declared[name] = true
            end
        elseif line:match("^%S") then
            in_enable = false
        elseif line:match("^%s+enable:%s*$") then
            in_enable = true
        elseif in_enable then
            local name = line:match("^%s+%-%s*([%w_]+)")
            if name then
                declared[name] = true
            elseif line:match("%S") and not line:match("^%s*#") then
                in_enable = false
            end
        end
    end

    local resolved = {}
    for _, name in ipairs(GO_FORMATTERS) do
        if declared[name] then
            table.insert(resolved, name)
        end
    end
    if #resolved == 0 then
        resolved = { "gofmt" }
    end
    -- O repo declarou um padrão, então o gopls não pode entrar como fallback:
    -- o `gofumpt = true` de lsp.lua reintroduziria exatamente o que se evitou.
    resolved.lsp_format = "never"
    return resolved
end

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
        go = function(bufnr)
            local name = vim.api.nvim_buf_get_name(bufnr)
            local dir = name ~= "" and vim.fs.dirname(name) or assert(vim.uv.cwd())
            local root = vim.fs.root(dir, { "go.mod", ".git" }) or dir
            if go_cache[root] == nil then
                go_cache[root] = go_declared(dir)
            end
            return go_cache[root]
        end,
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
