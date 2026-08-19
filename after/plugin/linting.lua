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

local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

vim.api.nvim_create_autocmd({ "BufWritePost", "BufReadPost", "InsertLeave" }, {
    group = lint_augroup,
    callback = function()
        if not vim.endswith(vim.fn.bufname(), "swiftinterface") then
            lint.try_lint()
        end
    end,
})

vim.keymap.set("n", "<leader>ml", function()
    lint.try_lint()
end, { desc = "Lint file" })
