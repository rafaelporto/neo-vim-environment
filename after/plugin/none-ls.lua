-- none-ls existe apenas pelo editorconfig_checker: é a única fonte que não tem
-- equivalente no conform (formatação) nem no nvim-lint (lint).
--
-- Com só uma fonte de *diagnostics*, o none-ls deixa de reivindicar capacidade
-- de formatação — então não há disputa com o conform nem ambiguidade quando
-- algo chama vim.lsp.buf.format.

-- O binário não vem com o plugin. Sem o guard, o null-ls registra a fonte e
-- falha em cada arquivo aberto com "command editorconfig-checker is not
-- executable".
if vim.fn.executable("editorconfig-checker") == 0 then
    return
end

local null_ls = require("null-ls")

null_ls.setup({
    should_attach = function(bufnr)
        local bufname = vim.api.nvim_buf_get_name(bufnr)
        return vim.bo[bufnr].buftype == ""
            and bufname ~= ""
            and vim.fn.isdirectory(bufname) == 0
    end,
    sources = {
        null_ls.builtins.diagnostics.editorconfig_checker,
    },
})
