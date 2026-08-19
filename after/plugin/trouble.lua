-- Era `TroubleToggle quickfix`, sintaxe da v2: a v3 instalada expõe apenas o
-- comando `Trouble` (TroubleToggle não aparece em nenhum arquivo do plugin).
-- Pior, este arquivo carrega depois do swift-config.lua na ordem alfabética, então
-- o mapa quebrado sobrescrevia o `<cmd>Telescope quickfix<cr>` que funcionava.
-- Movido para o namespace <leader>a (diagnósticos), devolvendo <leader>xq ao
-- xcodebuild.
local trouble = require("trouble")

-- setup() é o que cria o comando :Trouble (trouble/config/init.lua:242) e nunca
-- era chamado aqui. A API Lua usada no autocmd abaixo funciona sem ele, então a
-- falta passava despercebida — mas qualquer keymap via <cmd>Trouble ...<cr>
-- morria com "E492: Not an editor command".
trouble.setup({})

vim.keymap.set("n", "<leader>aq", "<cmd>Trouble quickfix toggle<cr>",
    { silent = true, noremap = true, desc = "Trouble quickfix" })

vim.api.nvim_create_autocmd("User", {
    pattern = { "XcodebuildBuildFinished", "XcodebuildTestsFinished" },
    callback = function(event)
        if event.data.cancelled then
            return
        end

        if event.data.success then
            trouble.close()
        elseif not event.data.failedCount or event.data.failedCount > 0 then
            if next(vim.fn.getqflist()) then
                trouble.open("quickfix")
            else
                trouble.close()
            end

            trouble.refresh()
        end
    end,
})
