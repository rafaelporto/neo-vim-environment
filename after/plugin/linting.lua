-- Lint via nvim-lint. Extraído de swift-config.lua.

local lint = require("lint")

lint.linters_by_ft = {
    swift = { "swiftlint" },
    -- O nvim-lint roda `golangci-lint version` e escolhe as flags certas por
    -- versão (v1: --out-format json / v2.0.x: --output.json.path=stdout /
    -- v2.1+: idem + --path-mode=abs), passa --issues-exit-code=0 para que
    -- "achou problemas" não pareça falha da ferramenta, e trata arquivo .go
    -- solto consultando `go env GOMOD`. Nada disso existia no none-ls, cujas
    -- args fixas usavam --out-format=json — removida na v2.
    go = { "golangcilint" },
    -- Sem eslint aqui de propósito: o LSP do eslint já entrega diagnostics ao
    -- vivo e somar os dois duplicaria cada warning.
}

-- Só roda linter cujo binário existe. Sem isto, um swiftlint ausente faz TODO
-- buffer swift abrir com
--   "Error in BufReadPost Autocommands: Error running swiftlint: ENOENT"
-- porque o nvim-lint não checa disponibilidade antes de spawnar.
--
-- Usa o opts.filter do próprio nvim-lint, que já entrega o linter resolvido —
-- lint.linters[name] pode ser tabela OU função que devolve a tabela, e o .cmd
-- também pode ser função.
local function is_available(linter)
    local cmd = linter.cmd
    if type(cmd) == "function" then
        local ok, resolved = pcall(cmd)
        if not ok then
            return false
        end
        cmd = resolved
    end
    return type(cmd) == "string" and vim.fn.executable(cmd) == 1
end

local function run_lint()
    lint.try_lint(nil, { filter = is_available })
end

local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
    group = lint_augroup,
    callback = function()
        if vim.endswith(vim.fn.bufname(), "swiftinterface") then
            return
        end
        run_lint()
    end,
})

vim.keymap.set("n", "<leader>ml", function()
    local names = lint.linters_by_ft[vim.bo.filetype]
    if not names or #names == 0 then
        vim.notify("Nenhum linter configurado para " .. vim.bo.filetype, vim.log.levels.WARN)
        return
    end
    run_lint()
end, { desc = "Lint file" })
