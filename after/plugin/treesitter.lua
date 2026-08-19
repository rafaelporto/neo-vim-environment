-- Highlight por treesitter.
--
-- O nvim 0.12 traz a API nativa (vim.treesitter.start) mas só 7 parsers:
-- c, lua, markdown, markdown_inline, query, vim, vimdoc. Não existe
-- vim.treesitter.install nem comando :Treesitter — os demais parsers e suas
-- queries vêm do nvim-treesitter (branch main), instalados em
-- stdpath("data")/site. Ver o spec em lua/default/plugins.lua.
--
-- Na branch main o plugin NÃO faz highlight: quem liga é este arquivo.
--
-- ftplugins nativos já chamam vim.treesitter.start() para lua, markdown, help e
-- query; este autocmd cobre o resto e pula o que já foi iniciado.

-- Filetypes sem parser próprio: reaproveitar um compatível.
vim.treesitter.language.register("json", { "jsonc", "json5" })
vim.treesitter.language.register("bash", { "zsh" })

vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("ts_highlight", { clear = true }),
    callback = function(args)
        local buf = args.buf

        -- Já iniciado por um ftplugin nativo -> nada a fazer. Sem este guard,
        -- vim.treesitter.start constrói um segundo highlighter para o buffer.
        if vim.treesitter.highlighter.active[buf] then
            return
        end

        local lang = vim.treesitter.language.get_lang(args.match)
        -- language.add() devolve false + mensagem quando o parser falta (não
        -- lança erro), então dispensa pcall e não engole erros reais do start().
        if not lang or not vim.treesitter.language.add(lang) then
            return
        end

        vim.treesitter.start(buf, lang)

        -- Folds por treesitter (as queries vêm com o nvim-treesitter).
        vim.wo[0][0].foldexpr = "v:lua.vim.treesitter.foldexpr()"
        vim.wo[0][0].foldmethod = "expr"
    end,
})
